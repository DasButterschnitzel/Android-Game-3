class_name AdService
extends Node
## Ads facade (autoload "Ads"). Gameplay only ever calls:
##   on_round_finished()                  a night ended (not a restart or quit)
##   await maybe_show_interstitial()      at a natural break; returns when closed or skipped
##   show_consent_form()                  from the privacy panel
## Every decision goes through AdPolicy. Ads never block the game: a missing
## SDK, no network, no consent or a failed load simply means "no ad".
## Adapters: "none" (no ads at all), "mock" (offline placeholder clearly marked
## as a test, for debug builds and tests), "admob" (Android plugin with
## Google's public test ad units only; see docs/compliance/ADS_AND_CONSENT.md).

signal consent_changed(status: String)
signal interstitial_closed(shown: bool)

const CONFIG_PATH := "res://data/ads.json"

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
	policy.configure(config)
	var save := _save()
	if save:
		policy.lifetime_rounds = int(save.data.stats.rounds_played)
	var wanted := str(config.get("adapter_debug" if OS.is_debug_build() else "adapter_release", "none"))
	use_adapter(wanted)


func _process(delta: float) -> void:
	_clock += delta


func _save() -> SaveStore:
	return get_node_or_null("/root/Save") as SaveStore


## Switches the backend (also used by tests). Unknown or unavailable -> "none".
func use_adapter(name: String) -> void:
	if _adapter:
		_adapter.queue_free()
		_adapter = null
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
		add_child(_adapter)


func ads_enabled() -> bool:
	return _adapter != null


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
	if _adapter == null or _busy:
		return false
	_busy = true
	if not consent_ready() and policy.lifetime_rounds >= int(config.get("consent_after_rounds", 2)):
		var status: String = await _adapter.request_consent()
		_set_consent(status)
	var shown := false
	if policy.should_show_interstitial(_clock, consent_ready()):
		shown = await _adapter.show_interstitial(consent_status() == "granted")
		if shown:
			policy.on_interstitial_shown(_clock)
	_busy = false
	interstitial_closed.emit(shown)
	return shown


## Privacy panel: change consent at any time.
func show_consent_form() -> void:
	if _adapter == null or _busy:
		return
	_busy = true
	var status: String = await _adapter.request_consent(true)
	_set_consent(status)
	_busy = false
