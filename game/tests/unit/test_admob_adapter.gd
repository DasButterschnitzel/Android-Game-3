extends TestCase
## AdMobAdapter against a stand-in for the Android singleton "NachhallAds":
## results arrive as signals; silence, failures and refusals resolve within
## their timeouts, so the game never waits on the ad SDK. Like UMP 4, the fake
## allows nothing before the consent information update that start() triggers.

const TEST_UNIT := "ca-app-pub-3940256099942544/1033173712"


## Same methods and signals as android_plugins/nachhall_ads (NachhallAdsPlugin).
class FakePlugin:
	extends RefCounted
	signal initialized(consent_status: String, can_request_ads: bool, sdk_version: String)
	signal consent_info(status: String, can_request_ads: bool, error: String)
	signal consent_form_shown
	signal consent_result(status: String, can_request_ads: bool, error: String)
	signal interstitial_loaded
	signal interstitial_failed_to_load(code: int, message: String)
	signal interstitial_shown
	signal interstitial_failed_to_show(code: int, message: String)
	signal interstitial_closed

	var calls: Array[String] = []
	var ready := false
	var privacy_required := false

	func initialize(test_mode: bool, _test_device_ids: String, max_ad_content_rating: String) -> void:
		calls.append("initialize:%s:%s" % [test_mode, max_ad_content_rating])

	func refresh_consent() -> void:
		calls.append("refresh_consent")

	func request_consent(force: bool) -> void:
		calls.append("request_consent:%s" % force)

	func cancel_consent() -> void:
		calls.append("cancel_consent")

	func is_privacy_options_required() -> bool:
		return privacy_required

	func load_interstitial(unit_id: String, personalized: bool) -> void:
		calls.append("load:%s:%s" % [unit_id, personalized])

	func is_interstitial_ready() -> bool:
		return ready

	func show_interstitial() -> void:
		calls.append("show")


var plugin: FakePlugin
var ad: AdMobAdapter


func before_each() -> void:
	plugin = FakePlugin.new()
	ad = AdMobAdapter.new()
	ad.attach(plugin)
	ad.configure({"admob_test_ids": {"interstitial": TEST_UNIT}})
	ad.consent_timeout = 0.3
	ad.show_timeout = 0.3
	add_child(ad)
	ad.start()
	await frames(1)


func after_each() -> void:
	ad.queue_free()
	await frames(1)


func _later(seconds: float, action: Callable) -> void:
	get_tree().create_timer(seconds).timeout.connect(action)


## A loaded interstitial, as after the update at start found an earlier decision.
func _ready_ad() -> void:
	plugin.consent_info.emit("granted", true, "")
	plugin.ready = true
	plugin.interstitial_loaded.emit()


## The update at start found that a decision is needed (UMP REQUIRED).
func _decision_needed() -> void:
	plugin.consent_info.emit("unknown", false, "")


func _loads() -> Array:
	return plugin.calls.filter(func(c: String) -> bool: return c.begins_with("load:"))


func test_unavailable_without_android_singleton() -> void:
	var real := AdMobAdapter.new()
	assert_false(real.is_available(), "no NachhallAds singleton outside the Android test build")
	real.free()


func test_nothing_starts_before_ads_are_switched_on() -> void:
	var p2 := FakePlugin.new()
	var a2 := AdMobAdapter.new()
	a2.attach(p2)
	add_child(a2)
	await frames(1)
	assert_true(p2.calls.is_empty(), "no plugin call (and no network) until AdService starts it")
	assert_eq(await a2.request_consent(), "unknown", "not started: nothing to ask")
	a2.free()


func test_starts_in_test_mode_and_preloads_only_after_the_consent_update() -> void:
	assert_true(plugin.calls.has("initialize:true:G"), "test mode, ads capped at content rating G")
	plugin.initialized.emit("unknown", false, "25.5.0")  # UMP 4: nothing allowed before the update
	assert_true(_loads().is_empty(), "no ad request before the update")
	plugin.consent_info.emit("granted", true, "")
	assert_true(plugin.calls.has("load:%s:true" % TEST_UNIT), "the update found the earlier decision: preload")


func test_misconfigured_ump_without_a_decision_requests_no_ads() -> void:
	# UMP's "publisher misconfiguration" flag makes canRequestAds() true without anyone being asked.
	plugin.initialized.emit("unknown", true, "25.5.0")
	plugin.consent_info.emit("unknown", true, "")
	assert_true(_loads().is_empty(), "no decision -> no ad request")
	var shown: bool = await ad.show_interstitial(false)
	assert_false(shown, "and nothing shown")
	assert_true(_loads().is_empty(), "still no request")


func test_fresh_consent_information_is_reported_to_the_service() -> void:
	var seen: Array[String] = []
	ad.consent_info_changed.connect(func(s: String): seen.append(s))
	plugin.consent_info.emit("unknown", false, "")
	plugin.consent_info.emit("granted", true, "2: network error")
	assert_eq(seen, ["unknown"] as Array[String], "only a successful update counts (a failed one keeps the old state)")


func test_without_fresh_information_the_break_does_not_wait() -> void:
	plugin.consent_info.emit("unknown", false, "2: offline")
	var t0 := Time.get_ticks_msec()
	var status: String = await ad.request_consent()
	assert_eq(status, "unknown", "nothing decided")
	assert_true(Time.get_ticks_msec() - t0 < 100, "returns at once instead of waiting on the network")
	assert_true(plugin.calls.has("refresh_consent"), "a new update runs in the background")
	assert_false(plugin.calls.has("request_consent:false"), "no form flow without consent information")


func test_decided_status_needs_no_form() -> void:
	plugin.consent_info.emit("not_required", true, "")
	var status: String = await ad.request_consent()
	assert_eq(status, "not_required", "the update already decided")
	assert_false(plugin.calls.has("request_consent:false"), "no form")


func test_consent_result_is_returned_and_starts_a_preload() -> void:
	_decision_needed()
	_later(0.05, func(): plugin.consent_result.emit("denied", true, ""))
	var status: String = await ad.request_consent()
	assert_eq(status, "denied", "plugin answer passed through")
	assert_true(plugin.calls.has("request_consent:false"), "first-run flow, not the privacy options")
	assert_true(plugin.calls.has("load:%s:false" % TEST_UNIT), "after consent: non-personalised preload")


func test_silent_plugin_resolves_as_unknown_and_cancels_the_flow() -> void:
	var t0 := Time.get_ticks_msec()
	var status: String = await ad.request_consent(true)
	assert_eq(status, "unknown", "no answer (e.g. offline) -> unknown, asked again later")
	assert_between((Time.get_ticks_msec() - t0) / 1000.0, 0.25, 2.0, "resolved after the consent timeout")
	assert_true(plugin.calls.has("cancel_consent"), "a form that has not appeared must not pop up later")


func test_late_answer_keeps_the_service_in_sync() -> void:
	var seen: Array[String] = []
	ad.consent_info_changed.connect(func(s: String): seen.append(s))
	assert_eq(await ad.request_consent(true), "unknown", "timed out")
	plugin.consent_result.emit("granted", true, "")  # the form was already up and answered later
	assert_eq(seen, ["granted"] as Array[String], "the late answer still reaches AdService")


func test_privacy_options_follow_the_plugin() -> void:
	assert_false(ad.privacy_options_required(), "not required (e.g. outside the EEA)")
	plugin.privacy_required = true
	assert_true(ad.privacy_options_required(), "required -> the privacy page offers it")


func test_visible_form_is_not_cut_off_by_the_network_timeout() -> void:
	_decision_needed()
	_later(0.05, func(): plugin.consent_form_shown.emit())
	_later(0.6, func(): plugin.consent_result.emit("granted", true, ""))
	var status: String = await ad.request_consent()
	assert_eq(status, "granted", "the player answered the form after 0.6 s (timeout 0.3 s)")


func test_no_ready_ad_returns_at_once_and_loads_for_next_break() -> void:
	plugin.consent_info.emit("granted", true, "")
	plugin.interstitial_failed_to_load.emit(3, "no fill")
	var t0 := Time.get_ticks_msec()
	var shown: bool = await ad.show_interstitial(true)
	assert_false(shown, "nothing ready -> no ad")
	assert_true(Time.get_ticks_msec() - t0 < 100, "no waiting at the natural break")
	assert_eq(_loads().size(), 2, "the failed preload is retried for the next break")


func test_ready_ad_is_shown_until_closed() -> void:
	_ready_ad()
	_later(0.05, func(): plugin.interstitial_shown.emit())
	_later(0.5, func():
		plugin.ready = false
		plugin.interstitial_closed.emit()
	)
	var shown: bool = await ad.show_interstitial(true)
	assert_true(shown, "shown and closed (0.5 s > show timeout: the ad on screen extends the wait)")
	assert_true(plugin.calls.has("show"), "show requested")


func test_failed_show_resolves_false() -> void:
	_ready_ad()
	_later(0.05, func(): plugin.interstitial_failed_to_show.emit(-3, "no interstitial loaded"))
	var shown: bool = await ad.show_interstitial(true)
	assert_false(shown, "failure reported -> no ad")


func test_silent_show_resolves_false_after_timeout() -> void:
	_ready_ad()
	var shown: bool = await ad.show_interstitial(true)
	assert_false(shown, "never shown, never closed -> false after the show timeout")


func test_ad_loaded_for_another_consent_choice_is_replaced() -> void:
	_ready_ad()
	var shown: bool = await ad.show_interstitial(false)
	assert_false(shown, "loaded as personalised, now non-personalised requested")
	assert_false(plugin.calls.has("show"), "not shown")
	assert_true(plugin.calls.has("load:%s:false" % TEST_UNIT), "reloaded with the current choice")


func test_refuses_ad_units_that_are_not_google_test_ids() -> void:
	ad.configure({"admob_test_ids": {"interstitial": "ca-app-pub-1234567890123456/1234567890"}})
	_ready_ad()
	var shown: bool = await ad.show_interstitial(true)
	assert_false(shown, "no ad with a non-test unit id")
	assert_true(_loads().is_empty(), "never loaded")


func test_plugin_refusal_disables_ads() -> void:
	plugin.initialized.emit("refused", false, "app id is not a Google test id")
	plugin.ready = true
	var shown: bool = await ad.show_interstitial(true)
	assert_false(shown, "the plugin's own test-id guard stopped it")
	assert_true(_loads().is_empty(), "never loaded")
