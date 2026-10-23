extends TestCase
## Interstitial frequency caps.


func test_no_ad_in_first_rounds() -> void:
	var p := AdPolicy.new()
	p.lifetime_rounds = 100
	var t := 0.0
	for i in 2:
		p.on_round_finished()
		t += 400.0
		assert_false(p.should_show_interstitial(t, true), "round %d: too early in session" % (i + 1))


func test_rounds_and_time_caps() -> void:
	var p := AdPolicy.new()
	p.lifetime_rounds = 100
	var t := 0.0
	var shown := []
	for i in 30:
		p.on_round_finished()
		t += 60.0  # one-minute rounds
		if p.should_show_interstitial(t, true):
			p.on_interstitial_shown(t)
			shown.append(i + 1)
	assert_true(shown.size() > 0, "ads appear eventually")
	for k in range(1, shown.size()):
		assert_true(shown[k] - shown[k - 1] >= 4, "at least 4 rounds apart")
	# 60 s rounds: the 180 s time cap is weaker than 4 rounds; both respected.
	assert_eq(shown[0], 4, "first after round 4 (>= 3 rounds and 4 since start)")


func test_time_cap_wins_for_short_rounds() -> void:
	var p := AdPolicy.new()
	p.lifetime_rounds = 100
	var t := 0.0
	var last := -1000.0
	for i in 40:
		p.on_round_finished()
		t += 20.0  # very short rounds
		if p.should_show_interstitial(t, true):
			assert_true(t - last >= 180.0, "never more often than every 3 minutes")
			p.on_interstitial_shown(t)
			last = t


func test_disabled_or_no_consent_never_shows() -> void:
	var p := AdPolicy.new()
	p.lifetime_rounds = 100
	for i in 10:
		p.on_round_finished()
	assert_false(p.should_show_interstitial(9999.0, false), "consent pending")
	p.enabled = false
	assert_false(p.should_show_interstitial(9999.0, true), "disabled")


func test_worst_case_load() -> void:
	var p := AdPolicy.new()
	assert_near(p.worst_case_ads_per_hour(90.0), 10.0, 0.01, "90 s rounds: one ad per 6 min")
	assert_near(p.worst_case_ads_per_hour(30.0), 20.0, 0.01, "30 s rounds: time cap limits to 20/h")


func test_brand_new_players_see_no_ads() -> void:
	var p := AdPolicy.new()
	var t := 0.0
	for i in 4:
		p.on_round_finished()
		t += 600.0
		assert_false(p.should_show_interstitial(t, true), "night %d of a new player stays ad-free" % (i + 1))
	p.on_round_finished()
	assert_true(p.should_show_interstitial(t + 600.0, true), "from the 5th finished night on, caps decide")
