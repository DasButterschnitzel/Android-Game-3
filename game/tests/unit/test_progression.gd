extends TestCase
## Achievements and cosmetic unlocks.


func test_achievements_unlock_once() -> void:
	var unlocks := {}
	var stats := {"perfect_waves": 3, "rounds_played": 1}
	var night := {"score": 1100, "survived": true, "flames_left": 2, "echo_perfect": true, "solo_perfect": false, "daily": false, "duo": false}
	var first := Progression.evaluate(night, stats, unlocks)
	assert_true(first.has("dawn") and first.has("score_1000") and first.has("first_echo"), "earned: %s" % str(first))
	assert_false(first.has("dawn_full"), "not with only two flames")
	assert_false(first.has("score_1500"), "score too low")
	var again := Progression.evaluate(night, stats, unlocks)
	assert_eq(again.size(), 0, "nothing is earned twice")


func test_papers_follow_achievements() -> void:
	var unlocks := {}
	assert_true(Progression.paper_unlocked("classic", unlocks), "classic paper always available")
	assert_false(Progression.paper_unlocked("blossom", unlocks), "blossom needs a dawn")
	var earned := Progression.evaluate({"survived": true, "flames_left": 3}, {}, unlocks)
	assert_true(Progression.paper_unlocked("blossom", unlocks), "dawn unlocks blossom")
	assert_true(Progression.paper_unlocked("ink", unlocks), "full dawn unlocks ink")
	assert_eq(Progression.papers_for(earned).size(), 2, "results screen lists the two new papers")


func test_sim_counts_solo_and_echo_perfect_waves() -> void:
	var cfg := Config.load_balance("echo")
	var sim := EchoSim.new(cfg, Rect2(10, 150, 700, 1110), 2)
	sim.wave_index = 1
	sim._start_wave()
	var bot := EchoBot.new(sim, "perfect", 900.0)
	var guard := 0
	while sim.wave_index == 1 and guard < 6:
		guard += 1
		bot.prepare_run()
		sim.begin_run()
		while sim.state == "running":
			sim.step([bot.delta()])
		if sim.state == "between":
			if sim.last_run.leaked == 0:
				sim.bank()
	assert_eq(sim.stats.solo_perfect + sim.stats.echo_perfect, sim.stats.perfect_waves, "every perfect wave is solo or echo")
	assert_true(sim.stats.perfect_waves >= 1, "the planner clears wave 2")


func test_fullmoon_mode_overrides_base_balance() -> void:
	var base := Config.load_balance("echo")
	var moon := Config.load_mode("echo", "fullmoon")
	assert_true(float(moon.enemy_speed) > float(base.enemy_speed), "faster ghosts")
	assert_true(float(moon.twin_window) < float(base.twin_window), "tighter twin window")
	assert_eq(moon.core_lives, base.core_lives, "everything else unchanged")
	assert_eq(str(Config.load_mode("echo", "")), str(base), "no mode = base")
	var sim := EchoSim.new(moon, Rect2(10, 150, 700, 1110), 4)
	sim.wave_index = 4
	sim._start_wave()
	assert_eq(sim.wave.size(), 6 + 4 + 2, "denser last wave (6 normal, 2 twin pairs, 2 armored)")
