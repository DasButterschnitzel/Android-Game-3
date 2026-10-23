class_name AdMobAdapter
extends AdAdapter
## Google AdMob backend via the NachhallAds Android plugin (singleton
## "NachhallAds", source in android_plugins/nachhall_ads). Only the
## experimental "Android-AdsTest" export contains it, with Google's public TEST
## ids only (docs/compliance/ADS_TEST_BUILD.md); everywhere else is_available()
## is false and AdService shows no ads.
##
## Never blocks: every call resolves on the plugin's result signal or after a
## timeout. Time is counted in frames the game actually runs (clamped per
## frame), so an ad in front of the paused app does not run the clock out,
## while a silent plugin can never hold the game.

const SINGLETON := "NachhallAds"
## Google's public sample publisher id; any other id is refused.
const TEST_PUBLISHER := "ca-app-pub-3940256099942544"

## Seconds to wait for the consent information (network) before giving up.
var consent_timeout := 8.0
## Upper bound while a consent or privacy form is on screen (the player reads it).
var form_timeout := 300.0
## Seconds of running game time to wait for the ad to appear after asking.
var show_timeout := 8.0
## Upper bound once the ad is on screen (normally the paused app counts no time).
var ad_timeout := 120.0
## A load without an answer counts as lost after this many seconds.
var load_stale_after := 60.0

var _plugin: Object
var _unit_id := ""
var _test_device_ids := ""
var _consent := "unknown"  # last status reported by the plugin
var _can_request_ads := false
var _loading := false
var _load_started_ms := 0
var _loaded_personalized := false
# Results of the call in flight; "" while waiting.
var _consent_result := ""
var _form_open := false
var _show_result := ""  # "closed" or "failed"
var _shown := false


func _init() -> void:
	if Engine.has_singleton(SINGLETON):
		_plugin = Engine.get_singleton(SINGLETON)


func is_available() -> bool:
	return _plugin != null


## Tests: drive the adapter with a stand-in for the Android singleton.
func attach(plugin: Object) -> void:
	_plugin = plugin


func configure(config: Dictionary) -> void:
	var ids = config.get("admob_test_ids", {})
	var unit := str(ids.get("interstitial", "")) if ids is Dictionary else ""
	_unit_id = unit if unit.begins_with(TEST_PUBLISHER + "/") else ""
	if _unit_id == "":
		push_warning("AdMobAdapter: interstitial id is not a Google TEST ad unit; no ads")
	var devices = config.get("admob_test_device_hashed_ids", [])
	_test_device_ids = ",".join(PackedStringArray(devices)) if devices is Array else ""


func _ready() -> void:
	if _plugin == null:
		return
	for s in _signals():
		_plugin.connect(s, _signals()[s])
	_plugin.initialize(true, _test_device_ids)  # test mode is not optional in this build


func _exit_tree() -> void:
	if _plugin == null:
		return
	for s in _signals():
		if _plugin.is_connected(s, _signals()[s]):
			_plugin.disconnect(s, _signals()[s])


## UMP: consent form if a decision is needed, privacy options form with force.
## "unknown" if nothing could be decided in time (e.g. offline): AdService asks
## again at a later natural break.
func request_consent(force := false) -> String:
	if _plugin == null or not is_inside_tree():
		return "unknown"
	_consent_result = ""
	_form_open = false
	_plugin.request_consent(force)
	var waited := 0.0
	while _consent_result == "":
		if waited >= (form_timeout if _form_open else consent_timeout):
			push_warning("AdMobAdapter: no consent result in time")
			return "unknown"
		waited += await _frame()
	return _consent_result


## Shows a preloaded interstitial and returns after it was closed. Never waits
## for a load at the natural break: without a ready ad it returns false at once
## and loads one for the next break.
func show_interstitial(personalized: bool) -> bool:
	if _plugin == null or _unit_id == "" or not is_inside_tree():
		return false
	if not _plugin.is_interstitial_ready() or _loaded_personalized != personalized:
		_preload(personalized, true)
		return false
	_show_result = ""
	_shown = false
	_plugin.show_interstitial()
	var waited := 0.0
	while _show_result == "":
		if waited >= (ad_timeout if _shown else show_timeout):
			push_warning("AdMobAdapter: interstitial did not report back in time")
			break
		waited += await _frame()
	_preload(personalized)
	return _show_result == "closed" or (_shown and _show_result == "")


## Starts loading the next interstitial in the background when consent allows
## it. force: also replace a ready ad (it was loaded for another consent choice).
func _preload(personalized: bool, force := false) -> void:
	if _plugin == null or _unit_id == "" or not _can_request_ads:
		return
	if _loading and Time.get_ticks_msec() - _load_started_ms < int(load_stale_after * 1000.0):
		return
	if not force and _plugin.is_interstitial_ready():
		return
	_loading = true
	_load_started_ms = Time.get_ticks_msec()
	_loaded_personalized = personalized
	_plugin.load_interstitial(_unit_id, personalized)


## One frame; returns its length in seconds, clamped so that the time Android
## kept the app paused (ad or form in front) does not count as waiting.
func _frame() -> float:
	var t0 := Time.get_ticks_msec()
	await get_tree().process_frame
	return minf((Time.get_ticks_msec() - t0) / 1000.0, 0.1)


func _signals() -> Dictionary:
	return {
		"initialized": _on_initialized,
		"consent_form_shown": _on_consent_form_shown,
		"consent_result": _on_consent_result,
		"interstitial_loaded": _on_loaded,
		"interstitial_failed_to_load": _on_load_failed,
		"interstitial_shown": _on_shown,
		"interstitial_failed_to_show": _on_show_failed,
		"interstitial_closed": _on_closed,
	}


func _on_initialized(status: String, can_request_ads: bool, info: String) -> void:
	print("AdMobAdapter: NachhallAds consent=%s ads_allowed=%s (%s)" % [status, can_request_ads, info])
	if status == "refused":  # the plugin's own test-id guard stopped it
		_unit_id = ""
		return
	_consent = status
	_can_request_ads = can_request_ads
	_preload(_consent == "granted")  # consent from an earlier session


func _on_consent_form_shown() -> void:
	_form_open = true


func _on_consent_result(status: String, can_request_ads: bool, error: String) -> void:
	if error != "":
		push_warning("AdMobAdapter: consent flow: " + error)
	_consent = status
	_can_request_ads = can_request_ads
	_form_open = false
	_consent_result = status
	_preload(_consent == "granted")


func _on_loaded() -> void:
	_loading = false


func _on_load_failed(code: int, message: String) -> void:
	_loading = false
	push_warning("AdMobAdapter: no interstitial (%d %s)" % [code, message])


func _on_shown() -> void:
	_shown = true


func _on_show_failed(code: int, message: String) -> void:
	_show_result = "failed"
	push_warning("AdMobAdapter: interstitial not shown (%d %s)" % [code, message])


func _on_closed() -> void:
	_show_result = "closed"
