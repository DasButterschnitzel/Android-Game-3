class_name EchoSim
extends RefCounted
## Deterministic rules of NACHHALL (production version of the ECHO prototype).
##
## A wave is a fixed list of shadows that walk straight to the lantern (core).
## The player defends it in runs of at most run_seconds. A light strikes on its
## own when it is charged and touches a shadow: every living shadow within
## hit_radius is hit, then the light needs recharge_seconds to glow again.
## Every finished run becomes an echo that replays the path AND the strike
## moments exactly, so echo strikes are fixed (tick, position) events.
## Consequences, each covered by a test:
##   - one light never hits two shadows less than recharge_seconds apart, so
##     the teaching wave and every twin pair provably need two lights;
##   - an extra light never saves a shadow that would otherwise be destroyed
##     (outcomes are monotone, which keeps echoes predictable).
## After a run the player banks (points x multiplier, leaks cost lantern lives)
## or runs again with one more light and a lower multiplier. The multiplier
## counts lights, so a second finger is a faster route, not a free bonus.
## Fixed timestep DT so recordings replay bit-exactly.

signal run_started(index: int)
signal run_ended(index: int, destroyed: int, leaked: int)
signal enemy_spawned(e: Dictionary)
signal enemy_hit(e: Dictionary, light_id: int)
signal enemy_destroyed(e: Dictionary, light_id: int)
signal enemy_leaked(e: Dictionary)
signal light_struck(light_id: int, pos: Vector2, hits: int, is_echo: bool)
signal wave_banked(wave: int, points: int, leaked: int)
signal wave_started(wave: int)
signal game_over(score: int, survived: bool)

enum Type { NORMAL, TWIN, ARMOR }
const DT := 1.0 / 60.0
const TYPE_KEYS := ["normal", "twin", "armor"]

var cfg: Dictionary
var seed_value: int
var arena: Rect2
var core: Vector2
var start_pos: Vector2
var wave_index := 0
var wave: Array = []  # specs: {id, tick, from, speed, type, twin, side}
var wave_def: Dictionary = {}
var run_index := 0
## Recorded lights of this wave: {id, path: PackedVector2Array, strikes: PackedInt32Array, run}
var echoes: Array = []
## Lights of the running run: {id, pos, path, strikes, last, joined}
var live: Array = []
var enemies: Array = []  # runtime: {spec, pos, alive, spawned, leaked, hitters, hit_tick, hit_by}
var tick := 0
var state := "ready"  # ready | running | between | over
var core_hp: int
var score := 0
var last_run := {"destroyed": 0, "leaked": 0, "points": 0}
var stats := {"runs": 0, "waves_banked": 0, "perfect_waves": 0, "leaks": 0, "strikes": 0, "lights": 0, "dawn": false,
	"solo_perfect": 0, "echo_perfect": 0, "duo_runs": 0}
var _cursor: PackedInt32Array = PackedInt32Array()  # next strike index per echo
## Look-ahead copies (see fork) run the echoes only, without live lights.
var probe := false


func _init(config: Dictionary, arena_rect: Rect2, seed_v: int) -> void:
	cfg = config
	arena = arena_rect
	seed_value = seed_v
	core = Vector2(arena.get_center().x, arena.position.y + arena.size.y * float(cfg.core_y))
	start_pos = core + Vector2(0, float(cfg.start_below_core))
	core_hp = int(cfg.core_lives)
	_start_wave()


func run_ticks() -> int:
	return int(round(float(cfg.run_seconds) / DT))


func recharge_ticks() -> int:
	return int(round(float(cfg.recharge_seconds) / DT))


func twin_window_ticks() -> int:
	return int(round(float(cfg.twin_window) / DT))


func waves_per_round() -> int:
	return (cfg.waves as Array).size()


## Lights in play for the multiplier: recorded echoes plus the running lights.
func lights_used() -> int:
	return echoes.size() + live.size()


## Multiplier for a given number of lights (1 light = best).
func multiplier_for(lights: int) -> float:
	var m: Array = cfg.light_multipliers
	return float(m[clampi(lights - 1, 0, m.size() - 1)])


func multiplier() -> float:
	return multiplier_for(maxi(lights_used(), 1))


## Multiplier the next run would have (one more light).
func next_multiplier() -> float:
	return multiplier_for(echoes.size() + 1)


func can_run_again() -> bool:
	return state == "between" and echoes.size() < int(cfg.max_lights)


# --- wave generation (deterministic per seed and wave) ------------------------

func _start_wave() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([seed_value, wave_index])
	wave.clear()
	echoes.clear()
	live.clear()
	enemies.clear()
	run_index = 0
	tick = 0
	var defs: Array = cfg.waves
	wave_def = defs[mini(wave_index, defs.size() - 1)]
	if wave_def.get("teach", false):
		_build_teaching_wave()
	else:
		_build_wave(rng)
	state = "ready"
	wave_started.emit(wave_index)


## Two shadows, left and right of the lantern, rising close to it and arriving
## together. Each can only be hit between its spawn and its arrival, a window
## shorter than the recharge time, so one light cannot stop both (see tests).
func _build_teaching_wave() -> void:
	var d := float(cfg.teach_distance)
	var v := float(cfg.teach_speed)
	var arrive := float(cfg.teach_arrival)
	var id := 0
	for side in [-1, 1]:
		var from := core + Vector2(side, -0.32).normalized() * d
		var travel := (d - float(cfg.core_radius)) / v
		wave.append({"id": id, "tick": int(round((arrive - travel) / DT)), "from": from, "speed": v,
			"type": Type.NORMAL, "twin": -1, "side": side, "inside": true})
		id += 1


func _build_wave(rng: RandomNumberGenerator) -> void:
	# Slots in arrival order: twins arrive together as one slot.
	var slots: Array = []
	for i in int(wave_def.get("normal", 0)):
		slots.append(Type.NORMAL)
	for i in int(wave_def.get("twins", 0)):
		slots.append(Type.TWIN)
	for i in int(wave_def.get("armor", 0)):
		slots.append(Type.ARMOR)
	# Deterministic shuffle.
	for i in range(slots.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = slots[i]
		slots[i] = slots[j]
		slots[j] = tmp
	var t0 := float(cfg.arrive_from)
	var span := float(cfg.arrive_until) - t0
	var id := 0
	for k in slots.size():
		# Stratified arrival times keep the wave spread over the whole run.
		var arrive := t0 + span * (k + rng.randf_range(0.15, 0.85)) / slots.size()
		var t: int = slots[k]
		if t == Type.TWIN:
			var left_first := rng.randf() < 0.5
			var a := _edge_point(-1 if left_first else 1, rng.randf_range(0.15, 0.7))
			var b := _edge_point(1 if left_first else -1, rng.randf_range(0.15, 0.7))
			wave.append(_spec(id, a, arrive, Type.TWIN, id + 1, rng))
			wave.append(_spec(id + 1, b, arrive, Type.TWIN, id, rng))
			id += 2
		else:
			var side := rng.randi_range(-1, 1)
			wave.append(_spec(id, _edge_point(side, rng.randf_range(0.0, 0.75)), arrive, t, -1, rng))
			id += 1


func _spec(id: int, from: Vector2, arrive: float, type: int, twin: int, rng: RandomNumberGenerator) -> Dictionary:
	var dist := from.distance_to(core) - float(cfg.core_radius)
	var speed := float(cfg.enemy_speed) * rng.randf_range(0.85, 1.2)
	if type == Type.ARMOR:
		speed *= 0.8  # armored shadows are heavier and slower
	var spawn := arrive - dist / speed
	var min_spawn := float(cfg.min_spawn)
	if spawn < min_spawn:
		speed = dist / (arrive - min_spawn)
		spawn = min_spawn
	var side := -1 if from.x < arena.position.x else (1 if from.x > arena.end.x else 0)
	return {"id": id, "tick": int(round(spawn / DT)), "from": from, "speed": speed, "type": type,
		"twin": twin, "side": side, "inside": false}


## side -1 = left edge, 1 = right edge, 0 = top edge. along: 0..1 position.
func _edge_point(side: int, along: float) -> Vector2:
	var m := 12.0
	match side:
		-1:
			return Vector2(arena.position.x - m, lerpf(arena.position.y + 40, core.y + 200, along))
		1:
			return Vector2(arena.end.x + m, lerpf(arena.position.y + 40, core.y + 200, along))
		_:
			return Vector2(lerpf(arena.position.x + 70, arena.end.x - 70, along / 0.75), arena.position.y - m)


## Position of an enemy spec at a given tick of the run (null before spawn).
func enemy_pos_at(spec: Dictionary, at_tick: int) -> Variant:
	if at_tick < spec.tick:
		return null
	var dir: Vector2 = (core - spec.from).normalized()
	var travelled: float = (at_tick - spec.tick) * DT * spec.speed
	var dist: float = spec.from.distance_to(core)
	return spec.from + dir * minf(travelled, dist)


## Tick at which a spec reaches the lantern edge (it leaks on that tick).
func arrival_tick(spec: Dictionary) -> int:
	var dist: float = spec.from.distance_to(core) - float(cfg.core_radius)
	return int(spec.tick) + int(ceil(dist / spec.speed / DT))


# --- run control ----------------------------------------------------------------

## Starts a run. starts: initial positions of the live lights (default: one at
## the start position). Allowed in "ready", and in "between" as "run again".
func begin_run(starts: Array = []) -> void:
	if state == "between":
		if not can_run_again():
			return
		run_index += 1
	elif state != "ready":
		return
	if probe:
		starts = []
	elif starts.is_empty():
		starts = [start_pos]
	tick = 0
	live.clear()
	for p in starts:
		if lights_used() >= int(cfg.max_lights):
			break
		_add_light(_clamp_arena(p))
	enemies.clear()
	for spec in wave:
		enemies.append({"spec": spec, "pos": spec.from, "alive": false, "spawned": false, "leaked": false,
			"hitters": {}, "hit_tick": -100000, "hit_by": -1})
	_cursor = PackedInt32Array()
	_cursor.resize(echoes.size())
	_cursor.fill(0)
	state = "running"
	stats.runs += 1
	run_started.emit(run_index)


## A second finger joins mid-run: another live light starts at pos. Its echo
## waits at that spot until the joining tick, so the replay stays exact.
## Returns the index in live, or -1 if no light is left for this wave.
func add_live_light(pos: Vector2) -> int:
	if state != "running" or lights_used() >= int(cfg.max_lights):
		return -1
	_add_light(_clamp_arena(pos))
	if live.size() == 2:
		stats.duo_runs += 1
	return live.size() - 1


func _add_light(pos: Vector2) -> void:
	var path := PackedVector2Array()
	for i in tick:
		path.append(pos)
	live.append({"id": lights_used(), "pos": pos, "path": path, "strikes": PackedInt32Array(),
		"last": -100000, "joined": tick})


func is_charged(light: Dictionary) -> bool:
	return tick - int(light.last) >= recharge_ticks()


## 0..1 recharge progress of a live light (1 = ready to strike).
func charge_of(light: Dictionary) -> float:
	return clampf(float(tick - int(light.last)) / recharge_ticks(), 0.0, 1.0)


## Advance one tick. deltas: wanted movement of each live light this tick.
func step(deltas: Array = []) -> void:
	if state != "running":
		return
	var max_step := float(cfg.max_light_speed) * DT
	for k in live.size():
		var l: Dictionary = live[k]
		var d: Vector2 = deltas[k] if k < deltas.size() else Vector2.ZERO
		l.pos = _clamp_arena(l.pos + d.limit_length(max_step))
		l.path.append(l.pos)
	for e in enemies:
		var spec: Dictionary = e.spec
		if not e.spawned and tick >= spec.tick:
			e.spawned = true
			e.alive = true
			enemy_spawned.emit(e)
		if not e.alive:
			continue
		e.pos = enemy_pos_at(spec, tick)
		if e.pos.distance_to(core) <= float(cfg.core_radius):
			e.alive = false
			e.leaked = true
			enemy_leaked.emit(e)
	# Echo strikes are fixed events: same tick, same place as when recorded.
	for i in echoes.size():
		var ec: Dictionary = echoes[i]
		var strikes: PackedInt32Array = ec.strikes
		if _cursor[i] < strikes.size() and strikes[_cursor[i]] == tick:
			_cursor[i] += 1
			var path: PackedVector2Array = ec.path
			_strike(ec.id, path[mini(tick, path.size() - 1)], true)
	# Live lights strike on their own when charged and touching a shadow.
	for l in live:
		if is_charged(l) and _has_target(l.id, l.pos):
			l.strikes.append(tick)
			l.last = tick
			stats.strikes += 1
			_strike(l.id, l.pos, false)
	tick += 1
	if tick >= run_ticks() or _wave_resolved():
		_end_run()


## Positions of all lights at a tick: echoes first (ids 0..n-1), then live ones.
func lights_at(at_tick: int) -> Array[Vector2]:
	var out: Array[Vector2] = []
	for ec in echoes:
		var path: PackedVector2Array = ec.path
		if not path.is_empty():
			out.append(path[mini(at_tick, path.size() - 1)])
	for l in live:
		out.append(l.pos)
	return out


func _has_target(light_id: int, pos: Vector2) -> bool:
	var r := float(cfg.hit_radius)
	for e in enemies:
		if e.alive and e.pos.distance_to(pos) <= r and _can_affect(e, light_id):
			return true
	return false


## A light never wastes a strike on an armored shadow it already cracked.
func _can_affect(e: Dictionary, light_id: int) -> bool:
	return not (e.spec.type == Type.ARMOR and e.hitters.has(light_id))


func _strike(light_id: int, pos: Vector2, is_echo: bool) -> void:
	var r := float(cfg.hit_radius)
	var hits := 0
	for e in enemies:
		if e.alive and e.pos.distance_to(pos) <= r and _can_affect(e, light_id):
			hits += 1
			_hit(e, light_id)
	light_struck.emit(light_id, pos, hits, is_echo)


func _hit(e: Dictionary, light_id: int) -> void:
	var spec: Dictionary = e.spec
	match spec.type:
		Type.NORMAL:
			_destroy(e, light_id)
		Type.ARMOR:
			e.hitters[light_id] = true
			if e.hitters.size() >= 2:
				_destroy(e, light_id)
			else:
				enemy_hit.emit(e, light_id)
		Type.TWIN:
			e.hit_tick = tick
			e.hit_by = light_id
			var partner: Variant = _enemy_by_id(spec.twin)
			if partner != null and partner.alive and partner.hit_by != light_id \
					and tick - int(partner.hit_tick) <= twin_window_ticks():
				_destroy(e, light_id)
				_destroy(partner, light_id)
			else:
				enemy_hit.emit(e, light_id)


func _enemy_by_id(id: int) -> Variant:
	for e in enemies:
		if e.spec.id == id:
			return e
	return null


func _destroy(e: Dictionary, light_id: int) -> void:
	if not e.alive:
		return
	e.alive = false
	enemy_destroyed.emit(e, light_id)


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
		if e.alive:
			# Safety net: a shadow still walking when time is up counts as through.
			e.alive = false
			e.leaked = true
		if e.leaked:
			leaked += 1
		elif e.spawned:
			destroyed += 1
			pts += int(cfg.points[TYPE_KEYS[e.spec.type]])
	last_run = {"destroyed": destroyed, "leaked": leaked, "points": pts}
	# Pad recordings to full run length so echoes stay put at their last position.
	for l in live:
		var path: PackedVector2Array = l.path
		var last: Vector2 = path[path.size() - 1] if path.size() > 0 else l.pos
		while path.size() < run_ticks():
			path.append(last)
		echoes.append({"id": l.id, "path": path, "strikes": l.strikes, "run": run_index})
		stats.lights += 1
	live.clear()
	state = "between"
	run_ended.emit(run_index, destroyed, leaked)
	if not probe and echoes.size() >= int(cfg.max_lights):
		bank()


## Banks the last run: points x multiplier; leaked shadows cost lantern lives.
func bank() -> void:
	if state != "between":
		return
	var pts := int(round(last_run.points * multiplier_for(echoes.size())))
	score += pts
	core_hp -= int(last_run.leaked)
	stats.leaks += int(last_run.leaked)
	stats.waves_banked += 1
	if last_run.leaked == 0:
		stats.perfect_waves += 1
		if echoes.size() == 1:
			stats.solo_perfect += 1
		else:
			stats.echo_perfect += 1
	wave_banked.emit(wave_index, pts, last_run.leaked)
	if core_hp <= 0:
		core_hp = 0
		state = "over"
		game_over.emit(score, false)
		return
	if wave_index + 1 >= waves_per_round():
		score += dawn_bonus()
		stats.dawn = true
		state = "over"
		game_over.emit(score, true)
		return
	wave_index += 1
	_start_wave()


## Bonus for keeping the lantern alight until dawn (every life left counts).
func dawn_bonus() -> int:
	return int(cfg.get("dawn_bonus", 0)) + core_hp * int(cfg.dawn_bonus_per_life)


func _clamp_arena(p: Vector2) -> Vector2:
	return Vector2(clampf(p.x, arena.position.x, arena.end.x), clampf(p.y, arena.position.y, arena.end.y))


## Look-ahead copy (bots, previews): same wave and echoes, a fresh run that
## replays the echoes only. Signals are not copied.
func fork() -> EchoSim:
	var f := EchoSim.new(cfg, arena, seed_value)
	f.wave_index = wave_index
	f.wave = wave.duplicate()
	f.wave_def = wave_def
	f.echoes = echoes.duplicate()
	f.start_pos = start_pos
	f.probe = true
	f.state = "ready"
	return f
