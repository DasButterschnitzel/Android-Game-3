class_name EchoBot
extends RefCounted
## Heuristic ECHO players for simulations (not a substitute for humans).
## Strategies:
##   "solo"     - banks after the first run, never uses echoes.
##   "perfect"  - plans intercepts for shadows the echoes would miss; banks at 0 leaks.
##   "early"    - like perfect, but banks as soon as at most one shadow leaks.
##   "sector"   - recipe play: run k only hunts shadows from one fixed edge.

var sim: EchoSim
var strategy: String
var speed: float  # px/s the bot can move its light
var _plan: Array = []  # waypoints {tick, pos}
var _wp := 0


func _init(s: EchoSim, strat := "perfect", light_speed := 500.0) -> void:
	sim = s
	strategy = strat
	speed = light_speed


## Called before each run: builds the movement plan.
func prepare_run() -> void:
	_plan.clear()
	_wp = 0
	var targets := _targets_for_run()
	var pos := sim.start_pos
	var t := 0
	var handled := {}
	var hits := _predicted_hit_ticks()
	while true:
		var best: Variant = null
		var best_tick := 1 << 30
		for spec in targets:
			if handled.has(spec.id):
				continue
			var window := _window_for(spec, hits)
			var tau := _earliest_intercept(spec, pos, t, window)
			if tau >= 0 and tau < best_tick:
				best_tick = tau
				best = spec
		if best == null:
			break
		handled[best.id] = true
		pos = sim.enemy_pos_at(best, best_tick)
		t = best_tick
		_plan.append({"tick": t, "pos": pos})


## Movement for the current tick (towards the next waypoint, arriving on time).
func delta() -> Vector2:
	var p: Vector2 = sim.live_pos[0]
	while _wp < _plan.size() and sim.tick > int(_plan[_wp].tick) + 1:
		_wp += 1
	if _wp >= _plan.size():
		return Vector2.ZERO
	var target: Vector2 = _plan[_wp].pos
	# Full speed towards the waypoint; arriving early just means waiting there.
	return (target - p).limit_length(speed * EchoSim.DT)


func should_bank() -> bool:
	var leaked: int = sim.last_run.leaked
	match strategy:
		"solo":
			return true
		"early":
			return leaked <= 1
		_:
			return leaked == 0


# --- planning helpers -----------------------------------------------------------

## Shadows this run should take care of: the ones the existing echoes miss.
func _targets_for_run() -> Array:
	var survivors := _dry_run_survivors()
	if strategy != "sector":
		return survivors
	var sides := [-1, 1, 0]
	var side: int = sides[sim.run_index % sides.size()]
	return survivors.filter(func(spec): return _side_of(spec) == side)


func _side_of(spec: Dictionary) -> int:
	if spec.from.x < sim.arena.position.x:
		return -1
	if spec.from.x > sim.arena.end.x:
		return 1
	return 0


## Replays the run with only the echoes (live light parked away) to see which
## shadows would get through. Deterministic, so the prediction is exact.
func _dry_run_survivors() -> Array:
	var probe := EchoSim.new(sim.cfg, sim.arena, sim.seed_value)
	probe.wave = sim.wave.duplicate(true)
	probe.echoes = sim.echoes.duplicate()
	probe.start_pos = Vector2(-5000, -5000)
	probe.begin_run()
	var hits := {}
	probe.enemy_hit.connect(func(e): hits[e.spec.id] = probe.tick)
	while probe.state == "running":
		probe.step([Vector2.ZERO])
	_last_probe_hits = hits
	var out := []
	for e in probe.enemies:
		if e.leaked or e.alive:
			out.append(e.spec)
	return out


var _last_probe_hits := {}


func _predicted_hit_ticks() -> Dictionary:
	return _last_probe_hits


## Twins whose partner gets hit by an echo must be hit near that tick.
func _window_for(spec: Dictionary, hits: Dictionary) -> Vector2i:
	if spec.type == EchoSim.Type.TWIN and hits.has(spec.twin):
		var w := int(sim.cfg.twin_window / EchoSim.DT) - 2
		return Vector2i(int(hits[spec.twin]) - w, int(hits[spec.twin]) + w)
	return Vector2i(0, 1 << 30)


func _earliest_intercept(spec: Dictionary, from: Vector2, t0: int, window: Vector2i) -> int:
	var arrive := int(spec.tick + (spec.from.distance_to(sim.core) - sim.cfg.core_radius) / spec.speed / EchoSim.DT)
	var start := maxi(maxi(t0, int(spec.tick)), window.x)
	var stop := mini(mini(arrive - 1, sim.run_ticks() - 1), window.y)
	for tau in range(start, stop + 1, 2):
		var ep: Variant = sim.enemy_pos_at(spec, tau)
		if ep == null:
			continue
		var reach: float = speed * (tau - t0) * EchoSim.DT + float(sim.cfg.hit_radius) * 0.8
		if from.distance_to(ep) <= reach:
			return tau
	return -1
