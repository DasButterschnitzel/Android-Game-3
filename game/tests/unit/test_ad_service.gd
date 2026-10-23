extends TestCase
## AdService: never blocks, consent once at a natural break, caps respected.

var ads: AdService
var save: SaveStore


func before_each() -> void:
	save = get_node("/root/Save") as SaveStore
	save.data.ads.consent = "unknown"
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
## config is one of Google's public test ids, and release builds have no ads.
func test_config_holds_only_google_test_ids() -> void:
	assert_eq(ads.config.get("adapter_release"), "none", "release builds: no ad backend")
	var ids: Dictionary = ads.config.admob_test_ids
	assert_true(str(ids.app_id).begins_with("ca-app-pub-3940256099942544~"), "app id is Google's test app id")
	for key in ids:
		assert_true(str(ids[key]).begins_with("ca-app-pub-3940256099942544"), "%s is a Google test id" % key)


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
