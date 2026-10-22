extends TestCase
## Rules of the ECHO prototype simulation.

const ARENA := Rect2(0, 130, 720, 1130)
var cfg: Dictionary


func before_each() -> void:
	cfg = Config.load_balance("echo")


func run_with(sim: EchoSim, path_fn: Callable) -> void:
	sim.begin_run()
	while sim.state == "running":
		sim.step([path_fn.call(sim)])


func test_wave_is_deterministic() -> void:
	var a := EchoSim.new(cfg, ARENA, 42)
	var b := EchoSim.new(cfg, ARENA, 42)
	a.wave_index = 3
	b.wave_index = 3
	a._start_wave()
	b._start_wave()
	assert_eq(str(a.wave), str(b.wave), "same seed and wave -> same specs")


func test_echo_replays_exactly() -> void:
	var sim := EchoSim.new(cfg, ARENA, 1)
	run_with(sim, func(s): return Vector2(3, -2))
	var rec: PackedVector2Array = sim.echoes[0][0]
	sim.next_run()
	sim.begin_run()
	for i in 100:
		sim.step([Vector2.ZERO])
	assert_vec_near(sim.lights_at(50)[0], rec[50], 0.001, "echo at tick 50 matches recording")


func test_teaching_wave_needs_an_echo() -> void:
	# A light that goes left catches only the left shadow; with its echo, a second
	# run that goes right completes the wave.
	var sim := EchoSim.new(Config.with_overrides(cfg, {"wave_base": 2}), ARENA, 7)
	assert_eq(sim.wave.size(), 2, "only the two teaching shadows")
	var go := func(target: Vector2) -> Callable:
		return func(s: EchoSim) -> Vector2:
			var e = s.enemies[0] if target.x < 360 else s.enemies[1]
			var aim: Vector2 = e.pos if e.alive else target
			return (aim - s.live_pos[0]).limit_length(cfg.max_light_speed * EchoSim.DT)
	run_with(sim, go.call(Vector2(100, 400)))
	assert_eq(sim.last_run.leaked, 1, "alone, one shadow leaks")
	sim.next_run()
	run_with(sim, go.call(Vector2(600, 400)))
	assert_eq(sim.last_run.leaked, 0, "with the echo, nothing leaks")


func test_banking_applies_multiplier_and_costs_lives() -> void:
	var sim := EchoSim.new(cfg, ARENA, 3)
	run_with(sim, func(s): return Vector2.ZERO)  # idle: everything leaks
	var leaked: int = sim.last_run.leaked
	var lives := sim.core_hp
	sim.bank()
	assert_eq(sim.core_hp, lives - leaked, "leaks cost lives")
	assert_eq(sim.wave_index, 1, "next wave")


func test_armor_needs_two_different_lights() -> void:
	var sim := EchoSim.new(cfg, ARENA, 5)
	sim.wave = [{"id": 0, "tick": 0, "from": Vector2(360, 900), "speed": 0.0, "type": EchoSim.Type.ARMOR, "twin": -1}]
	sim.start_pos = Vector2(360, 900)
	sim.begin_run()
	for i in 30:
		sim.step([Vector2.ZERO])
	assert_true(sim.enemies[0].alive, "one light is not enough")
	sim._end_run()
	sim.next_run()
	sim.begin_run()
	for i in 30:
		sim.step([Vector2.ZERO])
	assert_false(sim.enemies[0].alive, "echo + live light destroy it")


func test_twins_need_hits_within_window() -> void:
	var sim := EchoSim.new(cfg, ARENA, 6)
	sim.wave = [
		{"id": 0, "tick": 0, "from": Vector2(200, 900), "speed": 0.0, "type": EchoSim.Type.TWIN, "twin": 1},
		{"id": 1, "tick": 0, "from": Vector2(520, 900), "speed": 0.0, "type": EchoSim.Type.TWIN, "twin": 0},
	]
	sim.start_pos = Vector2(200, 900)
	sim.begin_run()
	for i in 20:
		sim.step([Vector2.ZERO])
	assert_true(sim.enemies[0].alive, "single twin hit does not kill")
	sim.live_pos[0] = Vector2(360, 500)  # leave both twins alone for > window
	for i in 30:
		sim.step([Vector2.ZERO])
	sim.live_pos[0] = Vector2(520, 900)
	sim.step([Vector2.ZERO])
	assert_true(sim.enemies[1].alive, "too late for the window")
	sim.live_pos[0] = Vector2(360, 500)
	for i in 30:
		sim.step([Vector2.ZERO])
	# Within the window both go down: hit A again, then B right away.
	sim.live_pos[0] = Vector2(200, 900)
	sim.step([Vector2.ZERO])
	sim.live_pos[0] = Vector2(520, 900)
	sim.step([Vector2.ZERO])
	assert_false(sim.enemies[0].alive or sim.enemies[1].alive, "both destroyed when hits are close in time")
