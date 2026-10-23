extends TestCase
## Rules of NACHHALL (EchoSim).

const ARENA := Rect2(10, 150, 700, 1110)
var cfg: Dictionary


func before_each() -> void:
	cfg = Config.load_balance("echo")


## Plays one run; path_fn(sim) returns the wanted movement of light 0.
func run_with(sim: EchoSim, path_fn: Callable, starts: Array = []) -> void:
	sim.begin_run(starts)
	while sim.state == "running":
		sim.step([path_fn.call(sim)])


func idle(_s: EchoSim) -> Vector2:
	return Vector2.ZERO


## A sim with a hand-made wave of resting shadows (speed 0, already spawned).
func fixed_sim(specs: Array) -> EchoSim:
	var sim := EchoSim.new(cfg, ARENA, 1)
	sim.wave = []
	for s in specs:
		var spec := {"id": sim.wave.size(), "tick": 0, "from": s[0], "speed": 0.0, "type": s[1],
			"twin": s[2] if s.size() > 2 else -1, "side": 0, "inside": true}
		sim.wave.append(spec)
	return sim


func test_wave_is_deterministic() -> void:
	var a := EchoSim.new(cfg, ARENA, 42)
	var b := EchoSim.new(cfg, ARENA, 42)
	a.wave_index = 3
	b.wave_index = 3
	a._start_wave()
	b._start_wave()
	assert_eq(str(a.wave), str(b.wave), "same seed and wave -> same specs")
	var c := EchoSim.new(cfg, ARENA, 43)
	c.wave_index = 3
	c._start_wave()
	assert_true(str(a.wave) != str(c.wave), "another seed -> another wave")


func test_every_shadow_arrives_within_the_run() -> void:
	for seed_value in 40:
		var sim := EchoSim.new(cfg, ARENA, 900 + seed_value)
		for w in sim.waves_per_round():
			sim.wave_index = w
			sim._start_wave()
			for spec in sim.wave:
				assert_true(int(spec.tick) >= 0, "spawns after the run starts")
				assert_true(sim.arrival_tick(spec) < sim.run_ticks(), "arrives before time is up (seed %d wave %d)" % [seed_value, w])


func test_echo_replays_path_and_strike_moments() -> void:
	var sim := EchoSim.new(cfg, ARENA, 2)
	sim.wave_index = 1
	sim._start_wave()
	var bot := EchoBot.new(sim, "perfect")
	bot.prepare_run()
	run_with(sim, func(_s): return bot.delta())
	var rec: Dictionary = sim.echoes[0]
	assert_true(rec.strikes.size() >= 2, "the run struck at least twice")
	var seen := []
	var ctx := {"sim": sim}
	var on_strike := func(id, pos, _hits, is_echo):
		if is_echo and id == 0:
			seen.append([ctx.sim.tick, pos])
	sim.light_struck.connect(on_strike)
	run_with(sim, idle)
	sim.light_struck.disconnect(on_strike)
	assert_eq(seen.size(), rec.strikes.size(), "echo strikes as often as recorded")
	for i in seen.size():
		assert_eq(seen[i][0], rec.strikes[i], "same tick")
		assert_vec_near(seen[i][1], rec.path[rec.strikes[i]], 0.001, "same place")
	assert_vec_near(sim.lights_at(77)[0], rec.path[77], 0.001, "echo position follows the recording")


func test_teaching_wave_is_provably_unsolvable_for_one_light() -> void:
	var sim := EchoSim.new(cfg, ARENA, 5)
	assert_eq(sim.wave.size(), 2, "two teaching shadows")
	# Each shadow can only be hit from its spawn to the tick before it reaches
	# the lantern. If both windows fit inside one recharge time, a single light
	# (whatever its speed) can strike at most one of them.
	var lo := 1 << 30
	var hi := -1
	for spec in sim.wave:
		lo = mini(lo, int(spec.tick))
		hi = maxi(hi, sim.arrival_tick(spec) - 1)
	assert_true(hi - lo < sim.recharge_ticks(), "both hit windows lie within one recharge (%d < %d ticks)" % [hi - lo, sim.recharge_ticks()])
	# Empirical cross-check with the planner at the rules' top speed.
	var bot := EchoBot.new(sim, "perfect", float(cfg.max_light_speed))
	bot.prepare_run()
	run_with(sim, func(_s): return bot.delta())
	assert_eq(sim.last_run.leaked, 1, "alone, one shadow gets through")
	bot.prepare_run()
	run_with(sim, func(_s): return bot.delta())
	assert_eq(sim.last_run.leaked, 0, "with the echo, nothing gets through")


func test_recharge_blocks_a_second_strike() -> void:
	var sim := fixed_sim([[Vector2(300, 900), EchoSim.Type.NORMAL], [Vector2(330, 900), EchoSim.Type.NORMAL]])
	sim.wave[1].from = Vector2(400, 900)
	sim.start_pos = Vector2(300, 900)
	sim.begin_run()
	sim.step([Vector2.ZERO])
	assert_false(sim.enemies[0].alive, "first touch strikes")
	for i in 10:  # move onto the second shadow within the recharge time
		sim.step([Vector2(10, 0)])
	assert_true(sim.enemies[1].alive, "still recharging: no second strike")
	for i in sim.recharge_ticks():
		sim.step([Vector2.ZERO])
	assert_false(sim.enemies[1].alive, "recharged light strikes again")


func test_strike_hits_every_shadow_in_reach() -> void:
	var sim := fixed_sim([[Vector2(300, 900), EchoSim.Type.NORMAL], [Vector2(330, 900), EchoSim.Type.NORMAL]])
	sim.start_pos = Vector2(315, 900)
	sim.begin_run()
	sim.step([Vector2.ZERO])
	assert_false(sim.enemies[0].alive or sim.enemies[1].alive, "one burst takes both")
	assert_eq(sim.stats.strikes, 1, "with a single strike")


func test_armor_needs_two_different_lights() -> void:
	var sim := fixed_sim([[Vector2(360, 900), EchoSim.Type.ARMOR]])
	sim.start_pos = Vector2(360, 900)
	sim.begin_run()
	for i in 200:
		sim.step([Vector2.ZERO])
	assert_true(sim.enemies[0].alive, "the same light cannot crack it twice")
	assert_eq(sim.stats.strikes, 1, "and does not waste strikes on it")
	sim._end_run()
	sim.begin_run()
	sim.step([Vector2.ZERO])
	assert_false(sim.enemies[0].alive, "echo + live light destroy it")


func test_twins_need_two_lights_within_the_window() -> void:
	var a := Vector2(200, 900)
	var b := Vector2(520, 900)
	var sim := fixed_sim([[a, EchoSim.Type.TWIN, 1], [b, EchoSim.Type.TWIN, 0]])
	sim.start_pos = a
	sim.begin_run()
	sim.step([Vector2.ZERO])
	for i in 40:  # dash to the other twin: arrives inside the window but uncharged
		sim.step([(b - sim.live[0].pos).limit_length(15)])
	assert_true(sim.enemies[1].alive, "one light alone cannot do both")
	for i in 100:
		sim.step([Vector2.ZERO])
	assert_true(sim.enemies[0].alive, "later hits by the same light never count")
	sim._end_run()
	# Run 2: the echo strikes twin A at tick 0 and again later; the live light
	# waits at B and strikes it at tick 0 too -> both inside the window.
	sim.begin_run([b])
	sim.step([Vector2.ZERO])
	assert_false(sim.enemies[0].alive or sim.enemies[1].alive, "echo + live light within the window")


func test_extra_light_never_saves_a_shadow() -> void:
	# Monotonicity: replaying the same echoes with one more random light must
	# destroy a superset of the shadows destroyed without it.
	for seed_value in 12:
		var sim := EchoSim.new(cfg, ARENA, 100 + seed_value)
		sim.wave_index = 4
		sim._start_wave()
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value
		for r in 2:
			var walk := {"dir": Vector2.from_angle(rng.randf() * TAU) * 8.0}
			run_with(sim, func(s: EchoSim):
				if s.tick % 30 == 0:
					walk.dir = walk.dir.rotated(rng.randf_range(-1.5, 1.5))
				return walk.dir)
		var without := _destroyed_ids(sim.fork(), [])
		var probe := sim.fork()
		probe.probe = false
		var with_light := _destroyed_ids(probe, [Vector2(rng.randf_range(100, 600), rng.randf_range(300, 900))])
		for id in without:
			assert_true(with_light.has(id), "seed %d: shadow %d stays destroyed with an extra light" % [seed_value, id])


func _destroyed_ids(s: EchoSim, starts: Array) -> Dictionary:
	s.begin_run(starts)
	var t := 0
	while s.state == "running":
		t += 1
		s.step([Vector2(sin(t * 0.05), cos(t * 0.031)) * 7.0])
	var out := {}
	for e in s.enemies:
		if e.spawned and not e.leaked:
			out[e.spec.id] = true
	return out


func test_multiplier_counts_lights_not_runs() -> void:
	var sim := EchoSim.new(cfg, ARENA, 9)
	sim.begin_run()
	assert_eq(sim.multiplier(), 6.0, "one light")
	sim.add_live_light(sim.start_pos + Vector2(80, 0))
	assert_eq(sim.multiplier(), 4.0, "a second finger costs like a second run")
	while sim.state == "running":
		sim.step()
	assert_eq(sim.echoes.size(), 2, "both lights become echoes")
	assert_eq(sim.next_multiplier(), 3.0, "the next run would be the third light")


func test_joining_light_echo_waits_until_it_joined() -> void:
	var sim := EchoSim.new(cfg, ARENA, 9)
	sim.begin_run()
	for i in 50:
		sim.step([Vector2(2, 0)])
	var join := sim.start_pos + Vector2(-90, 0)
	assert_eq(sim.add_live_light(join), 1, "second light joins")
	for i in 10:
		sim.step([Vector2.ZERO, Vector2(0, -3)])
	while sim.state == "running":
		sim.step()
	var rec: PackedVector2Array = sim.echoes[1].path
	assert_vec_near(rec[0], join, 0.001, "echo waits at the join point")
	assert_vec_near(rec[49], join, 0.001, "until the join tick")
	assert_vec_near(rec[59], join + Vector2(0, -30), 0.001, "then moves as recorded")


func test_banking_costs_lives_and_ends_the_night() -> void:
	var sim := EchoSim.new(cfg, ARENA, 3)
	run_with(sim, idle)  # idle at the start: both teaching shadows get through
	assert_eq(sim.last_run.leaked, 2, "two leaks")
	sim.bank()
	assert_eq(sim.core_hp, int(cfg.core_lives) - 2, "leaks cost lives")
	assert_eq(sim.wave_index, 1, "next wave")
	var over := []
	sim.game_over.connect(func(score, survived): over.append([score, survived]))
	run_with(sim, idle)
	sim.bank()
	assert_eq(sim.state, "over", "lantern goes out")
	assert_eq(over.size(), 1, "game over once")
	assert_false(over[0][1], "not survived")


func test_max_lights_banks_automatically() -> void:
	var sim := EchoSim.new(cfg, ARENA, 4)
	for r in int(cfg.max_lights):
		assert_true(sim.state in ["ready", "between"], "can start run %d" % r)
		run_with(sim, idle)
	assert_eq(sim.wave_index, 1, "sixth light banked the wave")


func test_dawn_bonus_counts_remaining_lives() -> void:
	var sim := EchoSim.new(cfg, ARENA, 4)
	sim.wave_index = sim.waves_per_round() - 1
	sim._start_wave()
	sim.begin_run()
	sim._end_run()
	for e in sim.enemies:
		e.leaked = false
	sim.last_run = {"destroyed": 0, "leaked": 0, "points": 0}
	var before := sim.score
	sim.bank()
	assert_eq(sim.state, "over", "last wave ends the night")
	assert_eq(sim.score - before, sim.core_hp * int(cfg.dawn_bonus_per_life) + int(cfg.get("dawn_bonus", 0)), "dawn bonus")
	assert_true(sim.stats.dawn, "dawn reached")


# --- formations (0.5) --------------------------------------------------------------

func _with_formation(f: String) -> Dictionary:
	var c := cfg.duplicate(true)
	c.formations.weights = {f: 1}
	return c


func _wave_of(c: Dictionary, seed_value: int, w: int) -> EchoSim:
	var sim := EchoSim.new(c, ARENA, seed_value)
	sim.wave_index = w
	sim.wave.clear()
	sim._start_wave()
	return sim


func _groups(sim: EchoSim) -> Dictionary:
	var g := {}
	for spec in sim.wave:
		if spec.has("group"):
			if not g.has(spec.group):
				g[spec.group] = []
			g[spec.group].append(spec)
	return g


func test_every_formation_arrives_within_the_run() -> void:
	for f in ["streu", "kette", "zange", "regen"]:
		var c := _with_formation(f)
		for seed_value in 30:
			for w in range(1, 5):
				var sim := _wave_of(c, 700 + seed_value, w)
				assert_eq(sim.wave_formation, f, "formation forced by its weight")
				for spec in sim.wave:
					assert_true(int(spec.tick) >= 0 and sim.arrival_tick(spec) < sim.run_ticks(),
						"%s: arrives in time (seed %d wave %d)" % [f, seed_value, w])


func test_formations_are_deterministic_and_all_occur() -> void:
	var seen := {}
	for seed_value in 60:
		var a := _wave_of(cfg, 300 + seed_value, 2)
		var b := _wave_of(cfg, 300 + seed_value, 2)
		assert_eq(a.wave_formation, b.wave_formation, "same seed -> same formation")
		assert_eq(str(a.wave), str(b.wave), "same seed -> same wave")
		seen[a.wave_formation] = true
	for f in ["streu", "kette", "zange", "regen"]:
		assert_true(seen.has(f), "%s occurs in 60 nights" % f)


func test_chain_members_share_a_route_and_keep_their_gap() -> void:
	var c := _with_formation("kette")
	var gap := float(c.formations.chain_gap)
	var chains := 0
	for seed_value in 20:
		var sim := _wave_of(c, 40 + seed_value, 2)
		for members in _groups(sim).values():
			chains += 1
			assert_true(members.size() >= 2 and members.size() <= int(c.formations.chain_max), "chain length")
			for j in range(1, members.size()):
				var a: Dictionary = members[j - 1]
				var b: Dictionary = members[j]
				assert_vec_near(b.from, a.from, 0.01, "same route")
				assert_near(float(b.speed), float(a.speed), 0.001, "same speed")
				var at := int(b.tick) + 5
				var d: float = (sim.enemy_pos_at(a, at) as Vector2).distance_to(sim.enemy_pos_at(b, at))
				assert_near(d, gap, 3.0, "keeps its gap")
				assert_true(d * 0.5 < float(c.hit_radius), "a strike between two reaches both")
	assert_true(chains >= 20, "chains were built (%d)" % chains)


func test_a_strike_between_chain_members_hits_both() -> void:
	var sim := _wave_of(_with_formation("kette"), 41, 2)
	var pair: Array = _groups(sim).values()[0]
	var a: Dictionary = pair[0]
	var b: Dictionary = pair[1]
	var at := int(b.tick) + 20
	sim.begin_run([Vector2(sim.arena.position.x + 20, sim.arena.end.y - 20)])  # far away, charged
	while sim.tick < at:
		sim.step([Vector2.ZERO])
	var ea: Dictionary = sim._enemy_by_id(a.id)
	var eb: Dictionary = sim._enemy_by_id(b.id)
	sim.live[0].pos = ((ea.pos as Vector2) + (eb.pos as Vector2)) * 0.5
	sim.step([Vector2.ZERO])
	assert_false(ea.alive, "first chain member destroyed")
	assert_false(eb.alive, "second chain member destroyed by the same strike")


func test_pincer_pairs_are_mirrored_and_arrive_together() -> void:
	var c := _with_formation("zange")
	for seed_value in 20:
		var sim := _wave_of(c, 60 + seed_value, 3)
		for members in _groups(sim).values():
			assert_eq(members.size(), 2, "a pair")
			var a: Dictionary = members[0]
			var b: Dictionary = members[1]
			assert_near(absf(a.from.x - sim.core.x), absf(b.from.x - sim.core.x), 0.01, "mirrored")
			assert_true(signf(a.from.x - sim.core.x) != signf(b.from.x - sim.core.x), "opposite sides")
			assert_true(absi(sim.arrival_tick(a) - sim.arrival_tick(b)) <= 1, "arrive together")


func test_rain_comes_from_the_top_in_separate_lanes() -> void:
	var sim := _wave_of(_with_formation("regen"), 77, 4)
	var xs: Array = []
	for spec in sim.wave:
		if spec.type == EchoSim.Type.NORMAL:
			assert_eq(int(spec.side), 0, "from the top edge")
			xs.append(float(spec.from.x))
	xs.sort()
	for i in range(1, xs.size()):
		assert_true(xs[i] - xs[i - 1] > 10.0, "own lane")


func test_first_night_is_always_scattered() -> void:
	var c := cfg.duplicate(true)
	c["first_night"] = true
	for seed_value in 30:
		for w in range(1, 5):
			assert_eq(_wave_of(c, seed_value, w).wave_formation, "streu", "first night: familiar waves")


func test_daily_feature_dominates_the_night() -> void:
	var c := cfg.duplicate(true)
	c["formation_feature"] = "kette"
	var hits := 0
	var total := 0
	for seed_value in 50:
		for w in range(1, 5):
			total += 1
			if _wave_of(c, 500 + seed_value, w).wave_formation == "kette":
				hits += 1
	assert_true(float(hits) / total > 0.5, "featured formation in most waves (%d/%d)" % [hits, total])
