class_name EchoBot
extends RefCounted
## Heuristic NACHHALL players for simulations and captures. Bots are not
## humans: they see everything, never hesitate and move at an exact speed.
## Strategies:
##   "solo"    - plans one run and banks it, never uses echoes.
##   "perfect" - before each run replays the echoes, then hunts what they miss;
##               banks only without leaks.
##   "early"   - like perfect, but banks with at most one leak.
##   "sector"  - recipe play: run k only hunts shadows from one fixed edge.
##   "chaser"  - reactive, no look-ahead: always chases the shadow closest to
##               the lantern and ignores echoes; banks with at most one leak.

var sim: EchoSim
var strategy: String
var speed: float  # px/s the bot moves its light
## enemy id -> need {kind: "kill" | "setup", lo: tick, hi: tick, partner: id}
var needs: Dictionary = {}
var _target := -1
var _target_tick := -1
var _plan_cool := 0
var _probe: EchoSim  # run being simulated by begin_prepare()/prepare_step()
var _twin_hits := {}  # id -> Array of hit ticks by echoes, filled by the probe


func _init(s: EchoSim, strat := "perfect", light_speed := 600.0) -> void:
	sim = s
	strategy = strat
	speed = light_speed


## Called before each run: works out what the echoes will miss.
func prepare_run() -> void:
	begin_prepare()
	while not prepare_step(1 << 30):
		pass


## The same planning in slices (main-menu attract mode): begin_prepare() once,
## then prepare_step() every frame until it returns true, so the simulated run
## does not cost one long frame.
func begin_prepare() -> void:
	_target = -1
	_target_tick = -1
	needs.clear()
	_probe = null
	if strategy == "chaser":
		return
	_probe = sim.fork()
	_twin_hits = {}
	var twin_hits := _twin_hits
	# The lambda must not capture the probe (reference cycle); twins carry their hit tick.
	_probe.enemy_hit.connect(func(e, _l):
		if e.spec.type == EchoSim.Type.TWIN:
			if not twin_hits.has(e.spec.id):
				twin_hits[e.spec.id] = []
			twin_hits[e.spec.id].append(int(e.hit_tick)))
	_probe.begin_run()


## Simulates up to max_ticks of the planned run; true once the plan is ready.
func prepare_step(max_ticks: int) -> bool:
	if _probe == null:
		return true
	var n := 0
	while _probe.state == "running" and n < max_ticks:
		_probe.step()
		n += 1
	if _probe.state == "running":
		return false
	var probe := _probe
	var twin_hits := _twin_hits
	_probe = null
	var side_filter := 2
	if strategy == "sector":
		side_filter = [-1, 1, 0][sim.run_index % 3]
	for e in probe.enemies:
		var spec: Dictionary = e.spec
		if not e.leaked:
			continue  # the echoes handle it
		if side_filter != 2 and int(spec.side) != side_filter:
			continue
		var lo := int(spec.tick)
		var hi := sim.arrival_tick(spec) - 1
		match spec.type:
			EchoSim.Type.NORMAL:
				needs[spec.id] = {"kind": "kill", "lo": lo, "hi": hi}
			EchoSim.Type.ARMOR:
				needs[spec.id] = {"kind": "kill" if e.hitters.size() >= 1 else "setup", "lo": lo, "hi": hi}
			EchoSim.Type.TWIN:
				var partner: int = spec.twin
				if twin_hits.has(partner):
					# Strike this one close to an echo strike on the partner.
					var w := sim.twin_window_ticks() - 2
					var h: int = twin_hits[partner][0]
					needs[spec.id] = {"kind": "kill", "lo": maxi(lo, h - w), "hi": mini(hi, h + w)}
				elif not twin_hits.has(spec.id) and not needs.has(partner):
					needs[spec.id] = {"kind": "setup", "lo": lo, "hi": hi}
	return true


## Movement for the current tick.
func delta() -> Vector2:
	if sim.live.is_empty():
		return Vector2.ZERO
	var light: Dictionary = sim.live[0]
	var p: Vector2 = light.pos
	if strategy == "chaser":
		return _chase(p)
	if _target >= 0 and not _target_valid(light):
		_target = -1
	if _target < 0:
		_plan_cool -= 1
		if _plan_cool <= 0:
			_choose_target(light)
			_plan_cool = 3
	if _target < 0:
		return (sim.start_pos.lerp(sim.core, 0.45) - p).limit_length(speed * 0.5 * EchoSim.DT)
	var e: Dictionary = _enemy(_target)
	var aim: Vector2 = sim.enemy_pos_at(e.spec, maxi(_target_tick, sim.tick))
	return (aim - p).limit_length(speed * EchoSim.DT)


func should_bank() -> bool:
	var leaked: int = sim.last_run.leaked
	match strategy:
		"solo":
			return true
		"early", "chaser":
			return leaked <= 1
		_:
			return leaked == 0


# --- helpers -------------------------------------------------------------------

func _target_valid(light: Dictionary) -> bool:
	var e: Dictionary = _enemy(_target)
	if not needs.has(_target) or e.leaked or (e.spawned and not e.alive):
		needs.erase(_target)
		return false
	if needs[_target].kind == "setup" and _setup_done(e):
		needs.erase(_target)
		return false
	# Struck something else on the way and will not be charged in time: re-plan.
	if int(light.last) + sim.recharge_ticks() > _target_tick:
		return false
	return sim.tick <= int(needs[_target].hi)


func _setup_done(e: Dictionary) -> bool:
	if e.spec.type == EchoSim.Type.ARMOR:
		return e.hitters.size() >= 1
	return e.hit_tick >= 0 and e.hit_by >= sim.echoes.size()


func _choose_target(light: Dictionary) -> void:
	var ready := sim.tick + maxi(0, sim.recharge_ticks() - (sim.tick - int(light.last)))
	var best := -1
	var best_tick := 1 << 30
	for pass_kind in ["kill", "setup"]:
		for id in needs:
			var n: Dictionary = needs[id]
			if n.kind != pass_kind:
				continue
			var e: Dictionary = _enemy(id)
			if e.leaked or (e.spawned and not e.alive):
				continue
			var tau := _earliest_intercept(e.spec, light.pos, maxi(ready, int(n.lo)), int(n.hi))
			if tau >= 0 and tau < best_tick:
				best_tick = tau
				best = id
		if best >= 0:
			break
	_target = best
	_target_tick = best_tick


func _earliest_intercept(spec: Dictionary, from: Vector2, lo: int, hi: int) -> int:
	var start := maxi(maxi(lo, sim.tick), int(spec.tick))
	var reach_margin := float(sim.cfg.hit_radius) * 0.75
	for tau in range(start, hi + 1, 2):
		var ep: Variant = sim.enemy_pos_at(spec, tau)
		if ep == null:
			continue
		if from.distance_to(ep) - reach_margin <= speed * (tau - sim.tick) * EchoSim.DT:
			return tau
	return -1


func _chase(p: Vector2) -> Vector2:
	var best: Variant = null
	var best_d := INF
	for e in sim.enemies:
		if not e.alive:
			continue
		var d: float = e.pos.distance_to(sim.core)
		if d < best_d:
			best_d = d
			best = e
	if best == null:
		return Vector2.ZERO
	return (best.pos - p).limit_length(speed * EchoSim.DT)


func _enemy(id: int) -> Dictionary:
	for e in sim.enemies:
		if e.spec.id == id:
			return e
	return {}
