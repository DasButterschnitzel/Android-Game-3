extends TestCase
## Rules of the LUNTE simulation.

const ARENA := Rect2(0, 0, 720, 1280)
var base_cfg: Dictionary


func before_each() -> void:
	base_cfg = Config.load_balance("lunte")


## Sim with no automatic spawns and no opening fireworks.
func make_sim(overrides := {}) -> FuseSim:
	var cfg := Config.with_overrides(base_cfg, {"fireworks_start": 0, "fireworks_max": 0, "spark_accel": 0.0, "spark_accel2": 0.0, "spark_speed_per_ignition": 0.0})
	cfg = Config.with_overrides(cfg, overrides)
	var sim := FuseSim.new(cfg, ARENA, 1)
	sim.start(Vector2(360, 1200))
	sim.fireworks.clear()
	sim.grab(0, Vector2(360, 1200))
	return sim


func draw_path(sim: FuseSim, pts: Array) -> void:
	for p in pts:
		sim.extend(0, p)


func run_until_over(sim: FuseSim, max_t := 60.0) -> float:
	var t := 0.0
	while not sim.over and t < max_t:
		sim.step(1.0 / 60.0)
		t += 1.0 / 60.0
	return t


func test_points_are_uniformly_spaced() -> void:
	var sim := make_sim()
	draw_path(sim, [Vector2(360, 1100)])
	var f := sim.fuses[0]
	assert_eq(f.size(), 13, "100 px / 8 px + start")
	for i in range(1, f.size()):
		assert_near(f.pts[i].distance_to(f.pts[i - 1]), FuseSim.STEP, 0.001, "spacing")


func test_nothing_happens_before_first_stroke() -> void:
	var cfg := Config.with_overrides(base_cfg, {})
	var sim := FuseSim.new(cfg, ARENA, 3)
	sim.start(Vector2(360, 1200))
	for i in 300:
		sim.step(1.0 / 60.0)
	assert_eq(sim.time, 0.0, "time frozen until lit")
	assert_true(sim.sparks.is_empty(), "no spark yet")
	assert_false(sim.over, "not over")


func test_spark_catches_a_resting_head() -> void:
	var sim := make_sim()
	draw_path(sim, [Vector2(360, 800)])  # 400 px
	var t := run_until_over(sim)
	var expected: float = base_cfg.spark_delay + 400.0 / base_cfg.spark_speed_start
	assert_true(sim.over, "game over")
	assert_near(t, expected, 0.15, "catch time")


func test_threaded_firework_ignites_and_scores() -> void:
	var sim := make_sim()
	var fw := sim._add_firework(FuseSim.Kind.FOUNTAIN, Vector2(365, 1000))
	draw_path(sim, [Vector2(360, 700)])
	assert_eq(fw.state, FuseSim.FwState.ARMED, "threaded")
	run_until_over(sim)
	assert_eq(fw.state, FuseSim.FwState.EXPLODED, "ignited")
	assert_true(sim.score >= 10, "scored")


func test_untouched_firework_fizzles() -> void:
	var sim := make_sim()
	var fw := sim._add_firework(FuseSim.Kind.FOUNTAIN, Vector2(100, 300))
	fw.life = 2.0
	draw_path(sim, [Vector2(360, 900)])
	run_until_over(sim)
	assert_eq(fw.state, FuseSim.FwState.FIZZLED, "fizzled")
	assert_eq(sim.score, 0, "no points")


func test_self_crossing_creates_shortcut() -> void:
	# Up 400, right 200, down 200, left 300: the last leg crosses the first leg.
	var loop_path := [Vector2(360, 800), Vector2(560, 800), Vector2(560, 1000), Vector2(260, 1000)]
	var sim := make_sim()
	draw_path(sim, loop_path)
	assert_true(sim.stats.junctions >= 1, "junction registered")
	var t_loop := run_until_over(sim)
	var length := 0.0
	var prev := Vector2(360, 1200)
	for p in loop_path:
		length += prev.distance_to(p)
		prev = p
	var t_full: float = base_cfg.spark_delay + length / base_cfg.spark_speed_start
	assert_true(t_loop < t_full - 2.0, "fire took the shortcut (%.2f < %.2f)" % [t_loop, t_full])


func test_crossing_ash_is_harmless() -> void:
	var sim := make_sim()
	draw_path(sim, [Vector2(360, 1000)])
	# Let the fire burn the first 120 px, then cross that burnt part.
	for i in int((base_cfg.spark_delay + 1.6) * 60):
		sim.step(1.0 / 60.0)
	draw_path(sim, [Vector2(560, 1000), Vector2(560, 1150), Vector2(200, 1150)])
	assert_eq(sim.stats.junctions, 0, "no junction on ash")


func test_banger_blast_ignites_fuse_ahead() -> void:
	var sim := make_sim({"banger_radius": 120.0})
	var banger := sim._add_firework(FuseSim.Kind.BANGER, Vector2(360, 1100))
	# Thread the banger, go up, come back down passing close to it (within blast radius).
	draw_path(sim, [Vector2(360, 700), Vector2(470, 700), Vector2(470, 1100), Vector2(470, 1250)])
	assert_eq(banger.state, FuseSim.FwState.ARMED, "banger threaded")
	var t := run_until_over(sim)
	assert_true(sim.stats.blast_fuse_hits >= 1, "blast hit the fuse")
	var full_len := 500.0 + 110.0 + 400.0 + 150.0
	var t_full: float = base_cfg.spark_delay + full_len / base_cfg.spark_speed_start
	assert_true(t < t_full - 3.0, "caught early by ember (%.2f < %.2f)" % [t, t_full])


func test_rocket_ignites_firework_in_flight_path() -> void:
	var sim := make_sim()
	var rocket := sim._add_firework(FuseSim.Kind.ROCKET, Vector2(360, 1050))
	rocket.dir = Vector2.RIGHT
	var target := sim._add_firework(FuseSim.Kind.FOUNTAIN, Vector2(600, 1050))
	draw_path(sim, [Vector2(360, 700)])
	run_until_over(sim)
	assert_eq(target.state, FuseSim.FwState.EXPLODED, "rocket chained the fountain")
	assert_true(sim.best_chain >= 2, "chain counted")


func test_heat_rises_when_fire_is_close() -> void:
	var sim := make_sim()
	draw_path(sim, [Vector2(360, 900)])  # 300 px ahead
	for i in int((base_cfg.spark_delay + 0.1) * 60):
		sim.step(1.0 / 60.0)
	assert_eq(sim.heat_level(), 1, "far away = x1")
	# Let it approach until the gap is below the x3 threshold.
	while sim.gap_time() > base_cfg.heat3_gap * 0.8 and not sim.over:
		sim.step(1.0 / 60.0)
	assert_eq(sim.heat_level(), 3, "close = x3")


func test_lifting_and_regrabbing_continues_fuse() -> void:
	var sim := make_sim()
	draw_path(sim, [Vector2(360, 1000)])
	sim.release(0)
	sim.extend(0, Vector2(360, 900))
	assert_eq(sim.fuses[0].size(), 26, "no drawing while lifted")
	assert_eq(sim.grab(5, Vector2(300, 600)), -1, "too far from head")
	assert_eq(sim.grab(5, Vector2(380, 1010)), 0, "regrab near head")
	sim.extend(5, Vector2(360, 900))
	assert_true(sim.fuses[0].size() > 26, "drawing continues with new finger")


func test_same_seed_same_result() -> void:
	var results := []
	for run in 2:
		var cfg := Config.with_overrides(base_cfg, {})
		var sim := FuseSim.new(cfg, ARENA, 1234)
		sim.start(Vector2(360, 1200))
		sim.grab(0, Vector2(360, 1200))
		var head := Vector2(360, 1200)
		for i in 1800:
			# Deterministic scripted wobble path.
			head = Vector2(360 + sin(i * 0.03) * 250, 1200 - fmod(i * 1.5, 1000))
			sim.extend(0, head)
			sim.step(1.0 / 60.0)
		results.append([sim.score, sim.ignitions, sim.fireworks.size(), sim.over])
	assert_eq(results[0], results[1], "deterministic")


func test_splitter_creates_branch_that_second_finger_can_draw() -> void:
	var sim := make_sim()
	var sp := sim._add_firework(FuseSim.Kind.SPLITTER, Vector2(360, 1050))
	sp.dir = Vector2.LEFT
	draw_path(sim, [Vector2(360, 700)])
	# Run until the splitter ignites.
	while sim.fuses.size() < 2 and not sim.over:
		sim.step(1.0 / 60.0)
	assert_eq(sim.fuses.size(), 2, "branch created")
	var branch := sim.fuses[1]
	assert_true(branch.size() > 3, "branch has a stub")
	assert_eq(sim.grab(1, branch.head()), 1, "second finger grabs branch head")
	sim.extend(1, branch.head() + Vector2(-150, 0))
	assert_true(branch.size() > 20, "second finger extends the branch")
	assert_eq(sim.held_count(), 2, "two fuses held")


func test_game_continues_while_any_head_survives() -> void:
	var sim := make_sim()
	var sp := sim._add_firework(FuseSim.Kind.SPLITTER, Vector2(360, 1150))
	sp.dir = Vector2.RIGHT
	draw_path(sim, [Vector2(360, 1000)])  # main fuse is short and will be caught
	while sim.fuses.size() < 2 and not sim.over:
		sim.step(1.0 / 60.0)
	sim.grab(1, sim.fuses[1].head())
	sim.extend(1, sim.fuses[1].head() + Vector2(0, -600))  # long branch
	var t := 0.0
	while sim.fuses[0].alive and t < 30.0:
		sim.step(1.0 / 60.0)
		t += 1.0 / 60.0
	assert_false(sim.fuses[0].alive, "main head caught")
	assert_false(sim.over, "branch still alive, game continues")
	run_until_over(sim)
	assert_true(sim.over, "over once every head is caught")


func test_twin_bonus_applies_with_two_held_fuses() -> void:
	var sim := make_sim()
	var fw := sim._add_firework(FuseSim.Kind.FOUNTAIN, Vector2(360, 1100))
	draw_path(sim, [Vector2(360, 800)])
	# Fake a second held fuse to isolate the scoring rule.
	var f2 := FuseSim.Fuse.new()
	f2.id = 1
	f2.pts.append(Vector2(100, 300))
	f2.burnt.append(0)
	f2.burn_t.append(0.0)
	f2.pointer_id = 9
	sim.fuses.append(f2)
	while fw.state != FuseSim.FwState.EXPLODED and not sim.over:
		sim.step(1.0 / 60.0)
	assert_eq(sim.stats.twin_ignitions, 1, "twin ignition counted")
	assert_true(sim.score >= int(round(10 * base_cfg.twin_bonus)), "bonus applied (%d)" % sim.score)


func test_finale_ignites_remaining_threaded_fireworks() -> void:
	var sim := make_sim()
	# Two fireworks near the head end, spark is far away. A banger-free setup:
	var a := sim._add_firework(FuseSim.Kind.FOUNTAIN, Vector2(360, 760))
	var b := sim._add_firework(FuseSim.Kind.FOUNTAIN, Vector2(360, 720))
	draw_path(sim, [Vector2(360, 700)])
	assert_eq(a.state, FuseSim.FwState.ARMED, "a armed")
	# Force a catch by blasting the head area: simulate by catching directly.
	sim._catch(sim.fuses[0])
	sim._check_over()
	assert_true(sim.over, "over")
	assert_false(sim.finished, "finale pending")
	var guard := 0
	while not sim.finished and guard < 600:
		sim.step(1.0 / 60.0)
		guard += 1
	assert_true(sim.finished, "finale finished")
	assert_eq(a.state, FuseSim.FwState.EXPLODED, "a exploded in finale")
	assert_eq(b.state, FuseSim.FwState.EXPLODED, "b exploded in finale")
	assert_true(sim.stats.finale_points > 0, "finale points counted")
