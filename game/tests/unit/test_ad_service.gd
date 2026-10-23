extends TestCase
## AdService: never blocks, consent once at a natural break, caps respected.

const AdMobTest := preload("res://tests/unit/test_admob_adapter.gd")
const TEST_PUBLISHER := "ca-app-pub-3940256099942544"

var ads: AdService
var save: SaveStore


func before_each() -> void:
	save = get_node("/root/Save") as SaveStore
	save.data.ads.consent = "unknown"
	save.data.ads.last_interstitial_unix = 0
	save.set_setting("ads_preview", true)
	ads = AdService.new()
	add_child(ads)
	await frames(1)


func after_each() -> void:
	ads.queue_free()
	save.set_setting("ads_preview", false)
	await frames(1)


func _mock() -> MockAdAdapter:
	ads.use_adapter("mock")
	return ads.get_child(ads.get_child_count() - 1) as MockAdAdapter


func test_no_adapter_means_no_ads_and_no_wait() -> void:
	ads.use_adapter("none")
	for i in 10:
		ads.on_round_finished()
	var shown: bool = await ads.maybe_show_interstitial()
	assert_false(shown, "nothing shown")
	assert_eq(ads.consent_status(), "unknown", "no consent question without an ad backend")


func test_admob_without_plugin_falls_back_to_none() -> void:
	ads.use_adapter("admob")
	assert_eq(ads.adapter_name, "none", "no plugin in this build -> no ads")


## Hard rule until the owner decides otherwise: every AdMob id in the shipped
## config, also after the ads test build's overrides, is one of Google's public
## test ids, and release builds have no ads.
func test_config_holds_only_google_test_ids() -> void:
	assert_eq(ads.config.get("adapter_release"), "none", "release builds: no ad backend")
	for cfg in [ads.config, AdService.ads_test_config(ads.config)]:
		var ids: Dictionary = cfg.admob_test_ids
		assert_true(str(ids.app_id).begins_with(TEST_PUBLISHER + "~"), "app id is Google's test app id")
		for key in ids:
			if key != "app_id":
				assert_true(str(ids[key]).begins_with(TEST_PUBLISHER + "/"), "%s is a Google test ad unit" % key)
		var found: Array[String] = []
		_ids_in(cfg, found)
		assert_true(found.size() >= 3, "all ids found")
		for id in found:
			assert_true(id.begins_with(TEST_PUBLISHER + "~") or id.begins_with(TEST_PUBLISHER + "/"), "%s is a Google test id" % id)


## Every string anywhere in the config that looks like an AdMob id.
func _ids_in(v: Variant, out: Array[String]) -> void:
	if v is Dictionary:
		for k in v:
			_ids_in(v[k], out)
	elif v is Array:
		for x in v:
			_ids_in(x, out)
	elif v is String and (v as String).contains("ca-app-pub-"):
		out.append(v)


func test_master_switch_off_means_no_backend_at_all() -> void:
	var cfg: Dictionary = ads.config.duplicate(true)
	assert_eq(AdService.backend_for(cfg, false, true), "mock", "debug build: placeholders")
	assert_eq(AdService.backend_for(cfg, false, false), "none", "release build: no ads")
	assert_eq(AdService.backend_for(cfg, true, true), "admob", "ads test build: AdMob test ads")
	cfg["ads_enabled"] = false
	for ads_test in [false, true]:
		for debug in [false, true]:
			assert_eq(AdService.backend_for(cfg, ads_test, debug), "none", "switched off: nothing is even created")


func _fake_admob() -> RefCounted:
	var plugin = AdMobTest.FakePlugin.new()
	var a := AdMobAdapter.new()
	a.attach(plugin)
	ads.use_adapter("admob", a)
	return plugin


func test_admob_does_not_start_while_ads_are_off() -> void:
	save.set_setting("ads_preview", false)
	var plugin = _fake_admob()
	await frames(1)
	assert_false(plugin.calls.any(func(c: String) -> bool: return c.begins_with("initialize")), "tester toggle off: the SDK side is not even started")
	assert_false(await ads.maybe_show_interstitial(), "no ad")
	save.set_setting("ads_preview", true)
	await ads.maybe_show_interstitial()
	assert_true(plugin.calls.any(func(c: String) -> bool: return c.begins_with("initialize")), "switched on: started at the next break")


## Regression (UMP 4: canRequestAds() is false until the update): in a later
## app session the update at start brings the stored decision back, ads load
## again and nobody is asked a second time.
func test_admob_later_session_gets_ads_without_a_new_question() -> void:
	save.data.ads.consent = "granted"
	var plugin = _fake_admob()
	await frames(1)
	plugin.initialized.emit("unknown", false, "25.5.0")
	plugin.consent_info.emit("granted", true, "")
	assert_eq(ads.consent_status(), "granted", "decision unchanged")
	assert_true(plugin.calls.has("load:%s:true" % AdMobTest.TEST_UNIT), "preloaded after the update")
	plugin.ready = true
	plugin.interstitial_loaded.emit()
	ads.policy.lifetime_rounds = 50
	for i in 5:
		ads.on_round_finished()
	ads._clock += 1000.0
	get_tree().create_timer(0.05).timeout.connect(func(): plugin.interstitial_shown.emit())
	get_tree().create_timer(0.1).timeout.connect(func():
		plugin.ready = false
		plugin.interstitial_closed.emit())
	assert_true(await ads.maybe_show_interstitial(), "the interstitial appears at the natural break")
	assert_false(plugin.calls.any(func(c: String) -> bool: return c.begins_with("request_consent")), "no second consent question")
	assert_true(int(save.data.ads.last_interstitial_unix) > 0, "time of the ad stored for the cap across restarts")


## An expired or reset decision (the update says a decision is needed) is
## asked again at the next natural break, not silently kept.
func test_admob_expired_decision_is_asked_again() -> void:
	save.data.ads.consent = "granted"
	var plugin = _fake_admob()
	await frames(1)
	plugin.consent_info.emit("unknown", false, "")
	assert_eq(ads.consent_status(), "unknown", "the stored answer no longer counts")
	ads.policy.lifetime_rounds = 50
	get_tree().create_timer(0.05).timeout.connect(func(): plugin.consent_result.emit("denied", true, ""))
	await ads.maybe_show_interstitial()
	assert_true(plugin.calls.has("request_consent:false"), "the form flow runs at the break")
	assert_eq(ads.consent_status(), "denied", "new answer stored")


func test_time_cap_holds_across_a_restart() -> void:
	var cfg := {"min_rounds_before_first": 0, "rounds_between": 1, "min_seconds_between": 300.0, "min_lifetime_rounds": 0}
	var p := AdPolicy.new()
	p.configure(cfg)
	p.on_round_finished()
	assert_true(p.should_show_interstitial(0.0, true, 10000.0), "first ad allowed")
	p.on_interstitial_shown(0.0, 10000.0)
	var q := AdPolicy.new()  # new app session, time of the last ad from the save
	q.configure(cfg)
	q.last_shown_unix = p.last_shown_unix
	q.on_round_finished()
	assert_false(q.should_show_interstitial(0.0, true, 10100.0), "restarted 100 s later: still capped")
	assert_true(q.should_show_interstitial(0.0, true, 10301.0), "five minutes later: allowed")
	assert_true(q.should_show_interstitial(0.0, true, 9000.0), "clock set back: only the in-session cap applies")


func test_ads_test_build_config() -> void:
	var cfg := AdService.ads_test_config(ads.config)
	assert_eq(cfg.get("adapter_ads_test"), "admob", "the Android-AdsTest build uses the AdMob plugin")
	assert_eq(int(cfg.consent_after_rounds), 1, "test overrides applied")
	assert_eq(int(ads.config.consent_after_rounds), 2, "normal config untouched")
	assert_false(OS.has_feature(AdService.ADS_TEST_FEATURE), "tests do not run as the ads test build")


func test_mock_asks_consent_once_then_respects_caps() -> void:
	ads.use_adapter("mock")
	var mock := ads.get_child(ads.get_child_count() - 1) as MockAdAdapter
	mock.auto_answer = "denied"
	mock.auto_close = true
	ads.policy.lifetime_rounds = 0
	ads.on_round_finished()
	var shown: bool = await ads.maybe_show_interstitial()
	assert_false(shown, "first night: no ad")
	assert_eq(ads.consent_status(), "unknown", "no consent question in the very first night")
	ads.on_round_finished()
	shown = await ads.maybe_show_interstitial()
	assert_eq(ads.consent_status(), "denied", "asked after the second night, answer stored")
	assert_false(shown, "still within the new-player grace period")
	for i in 5:
		ads.on_round_finished()
	ads._clock += 1000.0
	shown = await ads.maybe_show_interstitial()
	assert_true(shown, "after the grace period and caps an ad may appear")
	ads.on_round_finished()
	shown = await ads.maybe_show_interstitial()
	assert_false(shown, "right after one ad: capped")


func test_rewarded_pays_only_when_watched_and_asks_consent_first() -> void:
	var mock := _mock()
	mock.auto_answer = "granted"
	mock.auto_reward = "earned"
	assert_true(ads.rewarded_available(), "rewarded offered with the mock")
	var earned: bool = await ads.show_rewarded()
	assert_true(earned, "watched to the end -> reward")
	assert_eq(ads.consent_status(), "granted", "consent asked before the first ad, even in the first night")
	mock.auto_reward = "cancel"
	earned = await ads.show_rewarded()
	assert_false(earned, "cancelled -> no reward")


func test_master_switch_and_tester_toggle_turn_everything_off() -> void:
	var mock := _mock()
	mock.auto_answer = "granted"
	mock.auto_close = true
	mock.auto_reward = "earned"
	ads.policy.lifetime_rounds = 50
	ads.config["ads_enabled"] = false
	for i in 10:
		ads.on_round_finished()
	ads._clock += 10000.0
	assert_false(await ads.maybe_show_interstitial(), "master switch off: no interstitial")
	assert_false(ads.rewarded_available(), "master switch off: no rewarded")
	assert_eq(ads.consent_status(), "unknown", "and no consent question")
	ads.config["ads_enabled"] = true
	save.set_setting("ads_preview", false)
	assert_false(await ads.maybe_show_interstitial(), "tester toggle off: no interstitial")
	assert_eq(ads.consent_status(), "unknown", "tester toggle off: no consent question")
	save.set_setting("ads_preview", true)
	assert_true(await ads.maybe_show_interstitial(), "both on: the capped interstitial may appear")


func test_worst_case_ad_load_stays_moderate() -> void:
	var p := AdPolicy.new()
	p.configure(ads.config)
	for night_seconds in [20.0, 45.0, 90.0, 180.0]:
		assert_true(p.worst_case_ads_per_hour(night_seconds) <= 12.0, "at most 12 interstitials per hour (nights of %d s)" % int(night_seconds))
	assert_true(p.min_rounds_before_first >= 3 and p.rounds_between >= 3, "never in the first nights of a session, never after every loss")
	assert_true(p.min_seconds_between >= 300.0, "at least five minutes apart")
