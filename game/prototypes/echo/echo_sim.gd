class_name EchoSim
extends RefCounted
## Deterministic simulation of the ECHO prototype.
##
## A wave is a fixed list of shadows that walk from the edge to the core. The
## player defends it in runs of RUN_TICKS; every finished run becomes an echo
## that replays exactly in all later runs of the same wave. After any run the
## player may bank: fewer runs = higher multiplier, but every shadow that leaked
## in the banked run costs one core life. The round ends when the core has no
## lives left or all waves are done (visible budget, no hidden clock).
## Fixed timestep (DT) so recordings replay bit-exactly.

signal run_started(index: int)
signal run_ended(index: int, destroyed: int, leaked: int)
signal enemy_spawned(e: Dictionary)
signal enemy_destroyed(e: Dictionary)
signal enemy_hit(e: Dictionary)
signal enemy_leaked(e: Dictionary)
signal wave_banked(wave: int, points: int, leaked: int)
signal wave_started(wave: int)
signal game_over(score: int)

enum Type { NORMAL, TWIN, ARMOR }
const DT := 1.0 / 60.0

var cfg: Dictionary
var seed_value: int
var arena: Rect2
var core: Vector2
var start_pos: Vector2
var wave_index := 0
var wave: Array = []  # specs: {id, tick, from, speed, type, twin}
var run_index := 0
var echoes: Array = []  # Array of Array[PackedVector2Array] (one entry per run, one path per live light)
var live_paths: Array = []  # current run: PackedVector2Array per live light
var live_pos: Array[Vector2] = []
var enemies: Array = []  # runtime: {spec, pos, alive, leaked, hitters, hit_tick}
var tick := 0
var state := "ready"  # ready | running | between | over
var core_hp: int
var score := 0
var last_run := {"destroyed": 0, "leaked": 0, "points": 0}
var stats := {"runs": 0, "waves_banked": 0, "perfect_waves": 0, "leaks": 0}


func _init(config: Dictionary, arena_rect: Rect2, seed_v: int) -> void:
	cfg = config
	arena = arena_rect
	seed_value = seed_v
	core = Vector2(arena.get_center().x, arena.position.y + arena.size.y * cfg.core_y)
	start_pos = core + Vector2(0, cfg.start_below_core)
	core_hp = int(cfg.core_lives)
	_start_wave()


func run_ticks() -> int:
	return int(round(cfg.run_seconds / DT))


func multiplier() -> float:
	var m: Array = cfg.run_multipliers
	return float(m[mini(run_index, m.size() - 1)])


# --- wave generation (deterministic per seed and wave) ------------------------

func _start_wave() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([seed_value, wave_index])
	wave.clear()
	echoes.clear()
	run_index = 0
	var count := mini(int(cfg.wave_base) + int(cfg.wave_growth) * wave_index, int(cfg.wave_max))
	var id := 0
	if wave_index == 0:
		# Teaching wave: two shadows at the same moment from opposite sides. One
		# light cannot stop both; the second run shows the first echo helping.
		for side in [-1, 1]:
			wave.append({"id": id, "tick": int(1.2 / DT), "from": _edge_point(side, 0.35), "speed": cfg.enemy_speed, "type": Type.NORMAL, "twin": -1})
			id += 1
		count -= 2
	var types := [Type.NORMAL]
	if wave_index >= int(cfg.twin_from_wave):
		types.append(Type.TWIN)
	if wave_index >= int(cfg.armor_from_wave):
		types.append(Type.ARMOR)
	while count > 0:
		var t: int = types[rng.randi_range(0, types.size() - 1)]
		var tick_at := int(rng.randf_range(0.4, cfg.run_seconds - 3.2) / DT)
		var speed: float = cfg.enemy_speed * rng.randf_range(0.85, 1.2)
		if t == Type.TWIN and count >= 2:
			# Twins arrive together from different edges; both must be hit within the window.
			var s1 := rng.randf_range(-1.0, 1.0)
			var a := _edge_point(-1 if s1 < 0 else 1, rng.randf_range(0.1, 0.6))
			var b := _edge_point(1 if s1 < 0 else -1, rng.randf_range(0.1, 0.6))
			wave.append({"id": id, "tick": tick_at, "from": a, "speed": speed, "type": Type.TWIN, "twin": id + 1})
			wave.append({"id": id + 1, "tick": tick_at, "from": b, "speed": speed, "type": Type.TWIN, "twin": id})
			id += 2
			count -= 2
		else:
			if t == Type.TWIN:
				t = Type.NORMAL
			var side := rng.randi_range(-1, 1)
			wave.append({"id": id, "tick": tick_at, "from": _edge_point(side, rng.randf_range(0.0, 0.6)), "speed": speed, "type": t, "twin": -1})
			id += 1
			count -= 1
	state = "ready"
	wave_started.emit(wave_index)


## side -1 = left edge, 1 = right edge, 0 = top edge. along: 0..1 position.
func _edge_point(side: int, along: float) -> Vector2:
	var m := 10.0
	match side:
		-1:
			return Vector2(arena.position.x - m, lerpf(arena.position.y + 40, core.y + 220, along))
		1:
			return Vector2(arena.end.x + m, lerpf(arena.position.y + 40, core.y + 220, along))
		_:
			return Vector2(lerpf(arena.position.x + 60, arena.end.x - 60, along * 1.6 - 0.3 if along < 0.8 else along), arena.position.y - m)


## Position of an enemy spec at a given tick of the run (null before spawn).
func enemy_pos_at(spec: Dictionary, at_tick: int) -> Variant:
	if at_tick < spec.tick:
		return null
	var dir: Vector2 = (core - spec.from).normalized()
	var travelled: float = (at_tick - spec.tick) * DT * spec.speed
	var dist: float = spec.from.distance_to(core)
	return spec.from + dir * minf(travelled, dist)


# --- run control ----------------------------------------------------------------

func begin_run(live_count := 1) -> void:
	if state == "over":
		return
	tick = 0
	live_pos.clear()
	live_paths.clear()
	for k in live_count:
		live_pos.append(start_pos + Vector2((k - (live_count - 1) * 0.5) * 80.0, 0))
		live_paths.append(PackedVector2Array())
	enemies.clear()
	for spec in wave:
		enemies.append({"spec": spec, "pos": spec.from, "alive": false, "spawned": false, "leaked": false, "hitters": {}, "hit_tick": -1000})
	state = "running"
	stats.runs += 1
	run_started.emit(run_index)


## Advance one tick. deltas: movement of each live light this tick.
func step(deltas: Array = []) -> void:
	if state != "running":
		return
	for k in live_pos.size():
		var d: Vector2 = deltas[k] if k < deltas.size() else Vector2.ZERO
		var p: Vector2 = live_pos[k] + d.limit_length(cfg.max_light_speed * DT)
		live_pos[k] = Vector2(clampf(p.x, arena.position.x, arena.end.x), clampf(p.y, arena.position.y, arena.end.y))
		live_paths[k].append(live_pos[k])
	var lights := lights_at(tick)
	for e in enemies:
		var spec: Dictionary = e.spec
		if not e.spawned and tick >= spec.tick:
			e.spawned = true
			e.alive = true
			enemy_spawned.emit(e)
		if not e.alive:
			continue
		e.pos = enemy_pos_at(spec, tick)
		if e.pos.distance_to(core) <= cfg.core_radius:
			e.alive = false
			e.leaked = true
			enemy_leaked.emit(e)
			continue
		for li in lights.size():
			if lights[li].distance_to(e.pos) <= cfg.hit_radius:
				_hit(e, li)
				if not e.alive:
					break
	tick += 1
	if tick >= run_ticks() or _wave_resolved():
		_end_run()


## Positions of all lights at a tick: echoes first (stable ids), then live ones.
func lights_at(at_tick: int) -> Array[Vector2]:
	var out: Array[Vector2] = []
	for run_paths in echoes:
		for path: PackedVector2Array in run_paths:
			if path.is_empty():
				continue
			out.append(path[mini(at_tick, path.size() - 1)])
	for p in live_pos:
		out.append(p)
	return out


func _hit(e: Dictionary, light_id: int) -> void:
	var spec: Dictionary = e.spec
	match spec.type:
		Type.NORMAL:
			_destroy(e)
		Type.ARMOR:
			e.hitters[light_id] = true
			enemy_hit.emit(e)
			if e.hitters.size() >= 2:
				_destroy(e)
		Type.TWIN:
			e.hit_tick = tick
			enemy_hit.emit(e)
			var partner = _enemy_by_id(spec.twin)
			if partner != null and partner.alive and tick - int(partner.hit_tick) <= int(cfg.twin_window / DT):
				_destroy(e)
				_destroy(partner)


func _enemy_by_id(id: int) -> Variant:
	for e in enemies:
		if e.spec.id == id:
			return e
	return null


func _destroy(e: Dictionary) -> void:
	if not e.alive:
		return
	e.alive = false
	enemy_destroyed.emit(e)


func _wave_resolved() -> bool:
	for e in enemies:
		if not e.spawned or e.alive:
			return false
	return true


func _end_run() -> void:
	var destroyed := 0
	var leaked := 0
	var pts := 0
	for e in enemies:
		if e.leaked:
			leaked += 1
		elif e.spawned and not e.alive:
			destroyed += 1
			pts += int(cfg.points[Type.keys()[e.spec.type].to_lower()])
	last_run = {"destroyed": destroyed, "leaked": leaked, "points": pts}
	# Pad recordings to full run length so echoes stay put at their last position.
	for path: PackedVector2Array in live_paths:
		var last := path[path.size() - 1] if path.size() > 0 else start_pos
		while path.size() < run_ticks():
			path.append(last)
	echoes.append(live_paths.duplicate())
	state = "between"
	run_ended.emit(run_index, destroyed, leaked)
	if run_index + 1 >= int(cfg.max_runs):
		bank()


## Banks the last run: points x run multiplier; leaked shadows cost core lives.
func bank() -> void:
	if state != "between":
		return
	var pts := int(round(last_run.points * multiplier()))
	score += pts
	core_hp -= int(last_run.leaked)
	stats.leaks += int(last_run.leaked)
	stats.waves_banked += 1
	if last_run.leaked == 0:
		stats.perfect_waves += 1
	wave_banked.emit(wave_index, pts, last_run.leaked)
	if core_hp <= 0 or wave_index + 1 >= int(cfg.waves_per_round):
		state = "over"
		game_over.emit(score)
		return
	wave_index += 1
	_start_wave()


## Another run of the same wave (one more echo, lower multiplier).
func next_run() -> void:
	if state != "between":
		return
	run_index += 1
	state = "ready"
