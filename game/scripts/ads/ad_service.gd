class_name AdService
extends Node
## Ads facade (autoload "Ads"). Gameplay only ever calls:
##   on_round_finished()                  a night ended (not a restart or quit)
##   await maybe_show_interstitial()      at a natural break; returns when closed or skipped
##   show_consent_form()                  from the privacy panel
##   rewarded_available() / await show_rewarded()   only when the player asks for it
## Every decision goes through AdPolicy. Ads never block the game: a missing
## SDK, no network, no consent or a failed load simply means "no ad".
## Adapters: "none" (no ads at all), "mock" (offline placeholder clearly marked
## as a test, for debug builds and tests), "admob" (Android plugin with
## Google's public test ad units only; see docs/compliance/ADS_AND_CONSENT.md).
## The experimental "Android-AdsTest" export (feature tag "nachhall_ads") uses
## "adapter_ads_test" and "ads_test_overrides" from the config instead
## (docs/compliance/ADS_TEST_BUILD.md).

signal consent_changed(status: String)
signal interstitial_closed(shown: bool)

const CONFIG_PATH := "res://data/ads.json"
const ADS_TEST_FEATURE := "nachhall_ads"

var policy := AdPolicy.new()
var config: Dictionary = {}
var adapter_name := "none"
var _adapter: AdAdapter
var _clock := 0.0  # seconds of app time, for the time cap
var _busy := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var f := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if f:
		var data = JSON.parse_string(f.get_as_text())
		if typeof(data) == TYPE_DICTIONARY:
			config = data
	var ads_test := OS.has_feature(ADS_TEST_FEATURE)
	if ads_test:
		config = ads_test_config(config)
	policy.configure(config)
	var save := _save()
	if save:
		policy.lifetime_rounds = int(save.data.stats.rounds_played)
		policy.last_shown_unix = float(save.data.ads.last_interstitial_unix)
	use_adapter(backend_for(config, ads_test, OS.is_debug_build()))


## Backend of this build; "none" when the master switch is off, so nothing can
## even start.
static func backend_for(cfg: Dictionary, ads_test: bool, debug: bool) -> String:
	if not bool(cfg.get("ads_enabled", true)):
		return "none"
	var key := "adapter_ads_test" if ads_test else ("adapter_debug" if debug else "adapter_release")
	return str(cfg.get(key, "none"))


## Config of the experimental ads test build: "ads_test_overrides" (shorter
## intervals so a device test reaches consent and an ad quickly) on top.
static func ads_test_config(base: Dictionary) -> Dictionary:
	var merged := base.duplicate(true)
	var overrides = merged.get("ads_test_overrides", {})
	if overrides is Dictionary:
		merged.merge(overrides, true)
	return merged


func _process(delta: float) -> void:
	_clock += delta


func _save() -> SaveStore:
	return get_node_or_null("/root/Save") as SaveStore


## Switches the backend (also used by tests, which may pass their own
## instance). Unknown or unavailable -> "none". The backend starts (for AdMob:
## consent information update) only while ads are switched on.
func use_adapter(name: String, instance: AdAdapter = null) -> void:
	if _adapter:
		_adapter.queue_free()
		_adapter = null
	if instance:
		_adapter = instance
	else:
		match name:
			"mock":
				_adapter = MockAdAdapter.new()
			"admob":
				var a := AdMobAdapter.new()
				if a.is_available():
					_adapter = a
				else:
					a.free()
	adapter_name = name if _adapter else "none"
	if _adapter:
		_adapter.configure(config)
		_adapter.consent_info_changed.connect(_on_adapter_consent)
		add_child(_adapter)
		_start_adapter()


## Starts the backend once ads are on (also later, after the tester toggle).
func _start_adapter() -> bool:
	if not ads_enabled():
		return false
	_adapter.start()
	return true


## The backend's own, fresh view of consent wins over the stored answer: an
## expired or reset decision becomes "unknown" and is asked again at a break.
func _on_adapter_consent(status: String) -> void:
	if status != consent_status():
		_set_consent(status)


## False when there is no backend, the master switch in ads.json is off, or a
## tester switched the placeholders off (debug setting "ads_preview").
func ads_enabled() -> bool:
	if _adapter == null or not bool(config.get("ads_enabled", true)):
		return false
	var save := _save()
	if save and OS.is_debug_build() and not bool(save.get_setting("ads_preview")):
		return false
	return true


## Consent state from the save: unknown | granted | denied | not_required.
func consent_status() -> String:
	var save := _save()
	return str(save.data.ads.consent) if save else "unknown"


func consent_ready() -> bool:
	return consent_status() != "unknown"


func _set_consent(status: String) -> void:
	var save := _save()
	if save:
		save.data.ads.consent = status
		save.mark_dirty("ads")
	consent_changed.emit(status)


func on_round_finished() -> void:
	policy.on_round_finished()


## Natural break (results -> "again" or "menu"). Asks for consent once, after a
## few nights rather than at the first start; then shows an interstitial if the
## caps allow it. Always returns; never longer than the ad itself.
func maybe_show_interstitial() -> bool:
	if _busy or not _start_adapter():
		return false
	_busy = true
	if not consent_ready() and policy.lifetime_rounds >= int(config.get("consent_after_rounds", 2)):
		var status: String = await _adapter.request_consent()
		_set_consent(status)
	var shown := false
	var now_unix := Time.get_unix_time_from_system()
	if policy.should_show_interstitial(_clock, consent_ready(), now_unix):
		shown = await _adapter.show_interstitial(consent_status() == "granted")
		if shown:
			policy.on_interstitial_shown(_clock, now_unix)
			var save := _save()
			if save:  # the time cap also holds across app restarts
				save.data.ads.last_interstitial_unix = int(now_unix)
				save.mark_dirty("ads")
	_busy = false
	interstitial_closed.emit(shown)
	return shown


## Optional rewarded ad (cosmetic reward only, never needed to win).
func rewarded_available() -> bool:
	return ads_enabled() and bool(config.get("rewarded_enabled", false)) and _adapter.supports_rewarded()


## The player asked for it: consent first if it was never asked, then the ad.
## True only if the ad was watched to the end.
func show_rewarded() -> bool:
	if not rewarded_available() or _busy or not _start_adapter():
		return false
	_busy = true
	if not consent_ready():
		_set_consent(await _adapter.request_consent())
	var earned: bool = await _adapter.show_rewarded(consent_status() == "granted")
	_busy = false
	return earned


## Privacy panel: offer "change consent" only where the backend needs it
## (Google: privacy options required, e.g. in the EEA).
func privacy_options_available() -> bool:
	return _start_adapter() and _adapter.privacy_options_required()


## Privacy panel: change consent at any time.
func show_consent_form() -> void:
	if _busy or not _start_adapter():
		return
	_busy = true
	var status: String = await _adapter.request_consent(true)
	_set_consent(status)
	_busy = false
