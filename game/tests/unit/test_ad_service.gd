extends TestCase
## AdService: never blocks, consent once at a natural break, caps respected.

var ads: AdService
var save: SaveStore


func before_each() -> void:
	save = get_node("/root/Save") as SaveStore
	save.data.ads.consent = "unknown"
	ads = AdService.new()
	add_child(ads)
	await frames(1)


func after_each() -> void:
	ads.queue_free()
	await frames(1)


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
