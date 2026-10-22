class_name FuseSim
extends RefCounted
## Pure gameplay simulation of LUNTE (no rendering, no input handling).
##
## A fuse is a polyline with uniformly spaced points (STEP px apart), so a point
## index is also an arc-length coordinate. Fire is modelled consistently:
## - a spark burns along the fuse in one direction and marks points as burnt,
## - when a spark reaches a point where the fuse crosses itself (junction), the
##   fire also jumps to the partner point and burns from there in both directions,
## - a banger explosion ignites every unburnt fuse run inside its blast radius,
## - two fires meeting extinguish each other (a spark dies on burnt points),
## - a forward spark reaching the fuse head catches the player's finger.
## The scene feeds finger positions via begin/extend/release; the renderer reads state.

signal fuse_started(fuse_id: int)
signal firework_spawned(fw: Firework)
signal firework_threaded(fw: Firework)
signal firework_ignited(fw: Firework, points: int, heat: int, chain: int)
signal firework_fizzled(fw: Firework)
signal rocket_launched(fw: Firework, from: Vector2, to: Vector2)
signal blast(pos: Vector2, radius: float)
signal junction_created(pos: Vector2)
signal fuse_ignited_by_blast(pos: Vector2)
signal head_caught(fuse_id: int, pos: Vector2)
signal game_over(score: int)

const STEP := 8.0
const CELL := 32.0

enum Kind { FOUNTAIN, ROCKET, BANGER, SPLITTER }
enum FwState { WAITING, ARMED, EXPLODED, FIZZLED }


class Firework:
	var id: int
	var kind: int
	var pos: Vector2
	var radius: float
	var dir := Vector2.UP
	var life: float
	var max_life: float
	var state := FwState.WAITING
	var fuse_id := -1
	var fuse_idx := -1
	var age := 0.0


class Fuse:
	var id: int
	var pts := PackedVector2Array()
	var burnt := PackedByteArray()
	var junctions := {}  # point idx -> Array[Vector2i(fuse_id, idx)]
	var alive := true  # false once fire reached the head
	var pointer_id := -1  # finger currently drawing this fuse (-1 = lifted)
	var lit := false  # spark started

	func head() -> Vector2:
		return pts[pts.size() - 1]

	func size() -> int:
		return pts.size()


class Spark:
	var fuse_id: int
	var s: float
	var dir: int
	var alive := true


class Rocket:
	var from: Vector2
	var to: Vector2
	var t := 0.0  # 0..1 progress
	var source_id: int
	var hit := {}  # firework ids already ignited by this rocket

	func pos() -> Vector2:
		return from.lerp(to, t)


var cfg: Dictionary
var rng := RandomNumberGenerator.new()
var arena: Rect2
var fuses: Array[Fuse] = []
var sparks: Array[Spark] = []
var fireworks: Array[Firework] = []
var rockets: Array[Rocket] = []
var time := 0.0
var score := 0
var ignitions := 0
var best_chain := 0
var chain := 0
var last_ignite_time := -100.0
var over := false
var started := false
var stats := {"threaded": 0, "fizzled": 0, "junctions": 0, "blast_fuse_hits": 0, "max_heat": 1}

var _grid := {}  # Vector2i -> Array[Vector2i(fuse_id, seg_start_idx)]
var _next_fw_id := 1
var _spawn_timer := 0.0


func _init(config: Dictionary, arena_rect: Rect2, seed_value: int) -> void:
	cfg = config
	arena = arena_rect
	rng.seed = seed_value


## Current spark speed in px/s.
func speed() -> float:
	var t := maxf(time - float(cfg.spark_delay), 0.0)
	var v: float = cfg.spark_speed_start + cfg.spark_accel * t + cfg.spark_accel2 * t * t + cfg.spark_speed_per_ignition * ignitions
	return minf(v, cfg.spark_speed_max)


# --- player interface -------------------------------------------------------

## Starts the first fuse at the candle position.
func start(candle: Vector2) -> void:
	var f := Fuse.new()
	f.id = 0
	f.pts.append(candle)
	f.burnt.append(0)
	fuses.append(f)
	started = true
	_spawn_opening_fireworks(candle)
	fuse_started.emit(0)


## Returns the id of a fuse whose head is within grab radius of pos and free, or -1.
func grab(pointer_id: int, pos: Vector2) -> int:
	var best := -1
	var best_d := float(cfg.grab_radius)
	for f in fuses:
		if f.alive and f.pointer_id == -1:
			var d := pos.distance_to(f.head())
			if d <= best_d:
				best = f.id
				best_d = d
	if best >= 0:
		fuses[best].pointer_id = pointer_id
	return best


func release(pointer_id: int) -> void:
	for f in fuses:
		if f.pointer_id == pointer_id:
			f.pointer_id = -1


## Extends the fuse held by pointer_id towards pos (uniform STEP spacing).
func extend(pointer_id: int, pos: Vector2) -> void:
	if over:
		return
	var f := _fuse_of_pointer(pointer_id)
	if f == null or not f.alive:
		return
	pos = Vector2(clampf(pos.x, arena.position.x, arena.end.x), clampf(pos.y, arena.position.y, arena.end.y))
	var from := f.head()
	var d := from.distance_to(pos)
	if d < STEP:
		return
	var dir := (pos - from) / d
	var n := int(d / STEP)
	for k in range(1, n + 1):
		_add_point(f, from + dir * STEP * k)
	if f.id == 0 and not f.lit:
		f.lit = true


func _fuse_of_pointer(pointer_id: int) -> Fuse:
	for f in fuses:
		if f.pointer_id == pointer_id:
			return f
	return null


func _add_point(f: Fuse, p: Vector2) -> void:
	var i := f.pts.size()
	f.pts.append(p)
	f.burnt.append(0)
	var a := f.pts[i - 1]
	# Self/other crossings against existing unburnt segments create junctions.
	for cand in _query_segments(a, p):
		var fid: int = cand.x
		var k: int = cand.y
		if fid == f.id and k >= i - 3:
			continue
		var other := fuses[fid]
		var c = Geometry2D.segment_intersects_segment(a, p, other.pts[k], other.pts[k + 1])
		if c == null:
			continue
		var j := k if c.distance_to(other.pts[k]) <= c.distance_to(other.pts[k + 1]) else k + 1
		if other.burnt[j] == 1:
			continue  # crossing ash is harmless
		_link(f, i, other, j)
		stats.junctions += 1
		junction_created.emit(c)
	_register_segment(f.id, i - 1, a, p)
	# Thread waiting fireworks the new point passes through.
	for fw in fireworks:
		if fw.state == FwState.WAITING and p.distance_to(fw.pos) <= fw.radius + cfg.thread_tolerance:
			fw.state = FwState.ARMED
			fw.fuse_id = f.id
			fw.fuse_idx = i
			stats.threaded += 1
			firework_threaded.emit(fw)


func _link(f: Fuse, i: int, other: Fuse, j: int) -> void:
	if not f.junctions.has(i):
		f.junctions[i] = []
	f.junctions[i].append(Vector2i(other.id, j))
	if not other.junctions.has(j):
		other.junctions[j] = []
	other.junctions[j].append(Vector2i(f.id, i))


func _register_segment(fid: int, k: int, a: Vector2, b: Vector2) -> void:
	var c0 := Vector2i(floori(minf(a.x, b.x) / CELL), floori(minf(a.y, b.y) / CELL))
	var c1 := Vector2i(floori(maxf(a.x, b.x) / CELL), floori(maxf(a.y, b.y) / CELL))
	for cx in range(c0.x, c1.x + 1):
		for cy in range(c0.y, c1.y + 1):
			var key := Vector2i(cx, cy)
			if not _grid.has(key):
				_grid[key] = []
			_grid[key].append(Vector2i(fid, k))


func _query_segments(a: Vector2, b: Vector2) -> Array:
	var seen := {}
	var c0 := Vector2i(floori(minf(a.x, b.x) / CELL), floori(minf(a.y, b.y) / CELL))
	var c1 := Vector2i(floori(maxf(a.x, b.x) / CELL), floori(maxf(a.y, b.y) / CELL))
	for cx in range(c0.x, c1.x + 1):
		for cy in range(c0.y, c1.y + 1):
			var arr = _grid.get(Vector2i(cx, cy))
			if arr:
				for v in arr:
					seen[v] = true
	return seen.keys()


## Unburnt fuse points within radius of pos (used for spawn fairness).
func min_unburnt_distance(pos: Vector2, radius: float) -> float:
	var best := INF
	var r := int(ceil(radius / CELL))
	var c := Vector2i(floori(pos.x / CELL), floori(pos.y / CELL))
	for cx in range(c.x - r, c.x + r + 1):
		for cy in range(c.y - r, c.y + r + 1):
			var arr = _grid.get(Vector2i(cx, cy))
			if arr:
				for v in arr:
					var f := fuses[v.x]
					if f.burnt[v.y] == 0:
						best = minf(best, pos.distance_to(f.pts[v.y]))
	return best


# --- simulation step --------------------------------------------------------

func step(dt: float) -> void:
	if over or not started:
		return
	var main := fuses[0]
	if not main.lit:
		return  # nothing happens until the first stroke
	time += dt
	if sparks.is_empty() and time >= cfg.spark_delay and main.burnt[0] == 0:
		_spawn_spark(0, 0, 1)
	_advance_sparks(dt)
	_advance_rockets(dt)
	_update_fireworks(dt)
	_spawn_fireworks(dt)
	if time - last_ignite_time > cfg.chain_window:
		chain = 0
	_check_over()


func _spawn_spark(fid: int, idx: int, dir: int) -> void:
	var sp := Spark.new()
	sp.fuse_id = fid
	sp.s = idx
	sp.dir = dir
	fuses[fid].burnt[idx] = 1
	sparks.append(sp)


func _advance_sparks(dt: float) -> void:
	var di := speed() / STEP * dt
	# Iterate over a snapshot: junctions may append new sparks during this step.
	var current := sparks.duplicate()
	for sp: Spark in current:
		if not sp.alive:
			continue
		var f := fuses[sp.fuse_id]
		var target: float = sp.s + sp.dir * di
		var i0 := int(floor(sp.s)) + 1 if sp.dir > 0 else int(ceil(sp.s)) - 1
		var i := i0
		while sp.alive and ((sp.dir > 0 and i <= floor(target)) or (sp.dir < 0 and i >= ceil(target))):
			if i < 0:
				sp.alive = false
				break
			if i >= f.size():
				# Reached the head (end of fuse).
				sp.s = f.size() - 1
				if sp.dir > 0 and f.alive:
					_catch(f)
				sp.alive = false
				break
			if f.burnt[i] == 1:
				sp.alive = false  # meets existing fire / ash
				break
			_burn_point(f, i)
			i += sp.dir
		if sp.alive:
			sp.s = clampf(target, 0.0, f.size() - 1)
			# A forward spark sitting exactly on the head has caught it.
			if sp.dir > 0 and int(floor(sp.s)) >= f.size() - 1 and f.alive:
				_catch(f)
				sp.alive = false
	sparks = sparks.filter(func(s): return s.alive)


func _burn_point(f: Fuse, i: int) -> void:
	f.burnt[i] = 1
	if f.junctions.has(i):
		for partner in f.junctions[i]:
			var of := fuses[partner.x]
			if of.burnt[partner.y] == 0:
				_spawn_spark(partner.x, partner.y, 1)
				_spawn_spark_from_burnt(partner.x, partner.y, -1)
	for fw in fireworks:
		if fw.state == FwState.ARMED and fw.fuse_id == f.id and fw.fuse_idx == i:
			_ignite(fw)


## Second spark at an already-burnt start point (the forward one marked it).
func _spawn_spark_from_burnt(fid: int, idx: int, dir: int) -> void:
	var sp := Spark.new()
	sp.fuse_id = fid
	sp.s = idx
	sp.dir = dir
	sparks.append(sp)


func _catch(f: Fuse) -> void:
	f.alive = false
	f.pointer_id = -1
	head_caught.emit(f.id, f.head())


func _check_over() -> void:
	if over:
		return
	for f in fuses:
		if f.alive:
			return
	over = true
	game_over.emit(score)


# --- fireworks ---------------------------------------------------------------

func heat_level() -> int:
	var gap := gap_time()
	if gap < cfg.heat3_gap:
		return 3
	if gap < cfg.heat2_gap:
		return 2
	return 1


## Seconds until the most advanced forward spark reaches the main fuse head.
func gap_time() -> float:
	var best := INF
	for f in fuses:
		if not f.alive:
			continue
		var front := -1.0
		for sp in sparks:
			if sp.fuse_id == f.id and sp.dir > 0:
				front = maxf(front, sp.s)
		if front < 0.0:
			continue
		best = minf(best, (f.size() - 1 - front) * STEP / speed())
	return best


func _ignite(fw: Firework) -> void:
	if fw.state == FwState.EXPLODED or fw.state == FwState.FIZZLED:
		return
	fw.state = FwState.EXPLODED
	ignitions += 1
	if time - last_ignite_time <= cfg.chain_window:
		chain += 1
	else:
		chain = 1
	last_ignite_time = time
	best_chain = maxi(best_chain, chain)
	var heat := heat_level()
	stats.max_heat = maxi(stats.max_heat, heat)
	var base: int = cfg.points[Kind.keys()[fw.kind].to_lower()]
	var pts := int(round(base * heat * (1.0 + cfg.chain_bonus * (chain - 1))))
	score += pts
	firework_ignited.emit(fw, pts, heat, chain)
	match fw.kind:
		Kind.ROCKET:
			_launch_rocket(fw)
		Kind.BANGER:
			_explode_banger(fw)


func _launch_rocket(fw: Firework) -> void:
	var r := Rocket.new()
	r.from = fw.pos
	r.to = fw.pos + fw.dir * cfg.rocket_range
	r.source_id = fw.id
	rockets.append(r)
	rocket_launched.emit(fw, r.from, r.to)


func _advance_rockets(dt: float) -> void:
	for r: Rocket in rockets.duplicate():
		var prev := r.pos()
		r.t = minf(r.t + dt * cfg.rocket_speed / cfg.rocket_range, 1.0)
		var now := r.pos()
		for other in fireworks:
			if other.id == r.source_id or r.hit.has(other.id):
				continue
			if other.state == FwState.EXPLODED or other.state == FwState.FIZZLED:
				continue
			var closest := Geometry2D.get_closest_point_to_segment(other.pos, prev, now)
			if closest.distance_to(other.pos) <= other.radius + cfg.rocket_hit_radius:
				r.hit[other.id] = true
				_ignite(other)
	rockets = rockets.filter(func(r): return r.t < 1.0)


func _explode_banger(fw: Firework) -> void:
	var r: float = cfg.banger_radius
	blast.emit(fw.pos, r)
	for other in fireworks:
		if other != fw and other.state != FwState.EXPLODED and other.state != FwState.FIZZLED:
			if other.pos.distance_to(fw.pos) <= r:
				_ignite(other)
	# Flying embers ignite unburnt fuse runs inside the blast - except the fuse's
	# own way in and out of this banger (that part is "under" the banger), so the
	# danger comes from routing *other* fuse sections past an armed banger.
	var own_skip := int(ceil(r * cfg.banger_own_fuse_factor / STEP))
	for f in fuses:
		var i := 0
		while i < f.size():
			if f.id == fw.fuse_id and absi(i - fw.fuse_idx) <= own_skip:
				i += 1
				continue
			if f.burnt[i] == 0 and f.pts[i].distance_to(fw.pos) <= r:
				var a := i
				while i < f.size() and f.burnt[i] == 0 and f.pts[i].distance_to(fw.pos) <= r \
						and not (f.id == fw.fuse_id and absi(i - fw.fuse_idx) <= own_skip):
					i += 1
				var b := i - 1
				stats.blast_fuse_hits += 1
				fuse_ignited_by_blast.emit(f.pts[(a + b) / 2])
				for k in range(a, b + 1):
					_burn_point(f, k)
				if a > 0:
					_spawn_spark_from_burnt(f.id, a, -1)
				if b < f.size() - 1:
					_spawn_spark_from_burnt(f.id, b, 1)
				elif f.alive:
					_catch(f)
			else:
				i += 1


func _update_fireworks(dt: float) -> void:
	for fw in fireworks:
		fw.age += dt
		if fw.state == FwState.WAITING:
			fw.life -= dt
			if fw.life <= 0.0:
				fw.state = FwState.FIZZLED
				stats.fizzled += 1
				firework_fizzled.emit(fw)
	fireworks = fireworks.filter(func(fw): return fw.state == FwState.WAITING or fw.state == FwState.ARMED or fw.age < 3.0)


func waiting_count() -> int:
	var n := 0
	for fw in fireworks:
		if fw.state == FwState.WAITING:
			n += 1
	return n


func _target_count() -> int:
	return mini(int(cfg.fireworks_start) + int(time / float(cfg.fireworks_grow_every)), int(cfg.fireworks_max))


func _spawn_fireworks(dt: float) -> void:
	_spawn_timer -= dt
	if _spawn_timer > 0.0 or waiting_count() >= _target_count():
		return
	_spawn_timer = cfg.spawn_interval
	var head := fuses[0].head()
	for attempt in 24:
		var p := Vector2(
			rng.randf_range(arena.position.x + cfg.edge_margin, arena.end.x - cfg.edge_margin),
			rng.randf_range(arena.position.y + cfg.edge_margin, arena.end.y - cfg.edge_margin))
		if p.distance_to(head) < cfg.spawn_min_head_dist:
			continue
		if min_unburnt_distance(p, cfg.spawn_min_fuse_dist) < cfg.spawn_min_fuse_dist:
			continue
		var ok := true
		for fw in fireworks:
			if fw.state <= FwState.ARMED and fw.pos.distance_to(p) < cfg.spawn_min_fw_dist:
				ok = false
				break
		if ok:
			_add_firework(_roll_kind(), p)
			return


func _roll_kind() -> int:
	var w: Dictionary = cfg.kind_weights
	var total := 0.0
	for k in w:
		total += float(w[k])
	var r := rng.randf() * total
	for k in w:
		r -= float(w[k])
		if r <= 0.0:
			return Kind[k.to_upper()]
	return Kind.FOUNTAIN


func _add_firework(kind: int, p: Vector2) -> Firework:
	var fw := Firework.new()
	fw.id = _next_fw_id
	_next_fw_id += 1
	fw.kind = kind
	fw.pos = p
	fw.radius = cfg.firework_radius
	fw.max_life = rng.randf_range(cfg.firework_life_min, cfg.firework_life_max)
	fw.life = fw.max_life
	fw.dir = Vector2.from_angle(rng.randf() * TAU)
	fireworks.append(fw)
	firework_spawned.emit(fw)
	return fw


func _spawn_opening_fireworks(candle: Vector2) -> void:
	# Three easy fireworks along the natural first stroke, slightly fanned out.
	var up := Vector2(0, -1)
	_add_firework(Kind.FOUNTAIN, candle + up * 190 + Vector2(-40, 0))
	_add_firework(Kind.FOUNTAIN, candle + up * 380 + Vector2(60, 0))
	var rocket := _add_firework(Kind.ROCKET, candle + up * 560 + Vector2(-30, 0))
	rocket.dir = Vector2(1, -0.35).normalized()
	_add_firework(Kind.FOUNTAIN, rocket.pos + rocket.dir * 260)
	for fw in fireworks:
		fw.life = fw.max_life + 6.0
