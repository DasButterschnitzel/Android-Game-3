class_name FuseSim
extends RefCounted
## Pure gameplay simulation of LUNTE v2 (no rendering, no input handling).
##
## A fuse is a polyline with uniformly spaced points (STEP px apart), so a point
## index is also an arc-length coordinate. Fire is modelled consistently:
## - a spark burns along the fuse in one direction and marks points as burnt,
## - where the fuse crosses itself (junction) fire jumps to the partner point
##   and burns from there in both directions,
## - a closed loop encloses free fireworks; they all go off when fire reaches the
##   loop's junction ("Kurzschluss") - big reward, but the fire jumps closer,
## - a banger explosion ignites other fuse runs inside its blast radius,
## - two fires meeting extinguish each other,
## - a forward spark reaching a fuse head catches it.
##
## v2 economy (see docs/decisions/0001): drawing spends a visible fuse spool;
## spool is refunded only when a threaded firework actually ignites. Spark speed
## rises with recent ignitions (decays otherwise) and is capped below normal
## drawing speed; being close to the fire (heat) makes it burn faster.

signal fuse_started(fuse_id: int)
signal firework_spawned(fw: Firework)
signal firework_threaded(fw: Firework)
signal firework_enclosed(fw: Firework)
signal firework_ignited(fw: Firework, points: int, heat: int, chain: int)
signal firework_fizzled(fw: Firework)
signal rocket_launched(fw: Firework, from: Vector2, to: Vector2)
signal blast(pos: Vector2, radius: float)
signal junction_created(pos: Vector2)
signal loop_closed(loop_id: int, count: int)
signal short_circuit(pos: Vector2, count: int)
signal fuse_ignited_by_blast(pos: Vector2)
signal fire_jumped(from: Vector2, to: Vector2)
signal spool_refunded(pos: Vector2, amount: float)
signal spool_empty
signal head_caught(fuse_id: int, pos: Vector2)
signal branch_created(fuse_id: int, pos: Vector2)
signal finale_started(count: int)
signal dawn
signal game_over(score: int)

const STEP := 8.0
const CELL := 32.0

enum Kind { FOUNTAIN, ROCKET, BANGER, SPLITTER }
enum FwState { WAITING, ARMED, ENCLOSED, EXPLODED, FIZZLED }


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
	var loop_id := -1
	var age := 0.0

	## Still on the board and able to explode.
	func is_live() -> bool:
		return state == FwState.WAITING or state == FwState.ARMED or state == FwState.ENCLOSED


class Fuse:
	var id: int
	var pts := PackedVector2Array()
	var burnt := PackedByteArray()
	var burn_t := PackedFloat32Array()  # sim time each point burnt (ash fading)
	var junctions := {}  # point idx -> Array[Vector2i(fuse_id, idx)]
	var alive := true  # false once fire reached the head
	var pointer_id := -1  # finger currently drawing this fuse (-1 = lifted)
	var lit := false  # player has started drawing it
	var ignite_at := -1.0  # branch fuses: sim time when fire enters (delayed start)
	var lift_time := -100.0  # sim time the finger last let go

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


class Loop:
	var id: int
	var fuse_id: int
	var a: int  # older junction index
	var b: int  # newer junction index
	var fw_ids: Array[int] = []
	var polygon := PackedVector2Array()
	var fired := false


var cfg: Dictionary
var rng := RandomNumberGenerator.new()
var arena: Rect2
var fuses: Array[Fuse] = []
var sparks: Array[Spark] = []
var fireworks: Array[Firework] = []
var rockets: Array[Rocket] = []
var loops: Array[Loop] = []
var time := 0.0
var score := 0
var ignitions := 0
var best_chain := 0
var chain := 0
var last_ignite_time := -100.0
var spool := 0.0
var fire_energy := 0.0
var over := false  # every head has been caught (or dawn arrived)
var survived_dawn := false  # the round ended by reaching dawn, not by being caught
var finished := false  # finale done; final score is known
var started := false
var finale_queue: Array[Firework] = []
var stats := {
	"threaded": 0, "fizzled": 0, "junctions": 0, "blast_fuse_hits": 0, "max_heat": 1,
	"branches": 0, "twin_ignitions": 0, "finale_points": 0, "loops": 0, "loop_ignitions": 0,
	"spool_empty": 0, "drawn_px": 0.0, "refunded_px": 0.0,
}

var _grid := {}  # Vector2i -> Array[Vector2i(fuse_id, seg_start_idx)]
var _loop_at := {}  # Vector2i(fuse_id, idx) -> Array of loop ids
var _next_fw_id := 1
var _spawn_timer := 0.0
var _finale_timer := 0.0
var _in_finale := false
var _spool_warned := false


func _init(config: Dictionary, arena_rect: Rect2, seed_value: int) -> void:
	cfg = config
	arena = arena_rect
	rng.seed = seed_value
	spool = cfg.spool_start


# --- speed model --------------------------------------------------------------

## Spark speed (px/s) before per-fuse modifiers: rises with recent ignitions,
## decays when nothing ignites, capped below comfortable drawing speed.
func base_speed() -> float:
	return minf(cfg.spark_speed_base + cfg.spark_energy_gain * fire_energy, cfg.spark_speed_cap)


## HUD/compat alias.
func speed() -> float:
	return base_speed()


## Effective speed of fire on a fuse: heat (closeness) makes it burn faster;
## right after the finger lets go there is a short grace for regripping.
func speed_for(f: Fuse) -> float:
	var heat_speed: Array = cfg.heat_speed
	var v := base_speed() * (1.0 + float(heat_speed[heat_for_fuse(f) - 1]))
	if f.pointer_id == -1 and f.lit and time - f.lift_time < cfg.grip_grace:
		v *= cfg.grip_grace_factor
	return v


# --- player interface ---------------------------------------------------------

## Starts the first fuse at the candle position.
func start(candle: Vector2) -> void:
	var f := Fuse.new()
	f.id = 0
	f.pts.append(candle)
	f.burnt.append(0)
	f.burn_t.append(0.0)
	fuses.append(f)
	started = true
	_spawn_opening_fireworks(candle)
	fuse_started.emit(0)


## Returns the id of a free fuse whose head is within grab radius of pos, or -1.
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


## Assigns the first free live fuse to this pointer regardless of distance
## (relative/trackpad control). Returns fuse id or -1.
func grab_any(pointer_id: int) -> int:
	for f in fuses:
		if f.alive and f.pointer_id == -1:
			f.pointer_id = pointer_id
			return f.id
	return -1


func release(pointer_id: int) -> void:
	for f in fuses:
		if f.pointer_id == pointer_id:
			f.pointer_id = -1
			f.lift_time = time


## Extends the fuse held by pointer_id towards pos (uniform STEP spacing),
## spending spool. Returns false when the spool ran dry.
func extend(pointer_id: int, pos: Vector2) -> bool:
	if over:
		return true
	var f := fuse_of_pointer(pointer_id)
	if f == null or not f.alive:
		return true
	pos = Vector2(clampf(pos.x, arena.position.x, arena.end.x), clampf(pos.y, arena.position.y, arena.end.y))
	var from := f.head()
	var d := from.distance_to(pos)
	if d < STEP:
		return true
	var dir := (pos - from) / d
	var n := int(d / STEP)
	for k in range(1, n + 1):
		if spool < STEP:
			if not _spool_warned:
				_spool_warned = true
				stats.spool_empty += 1
				spool_empty.emit()
			return false
		spool -= STEP
		stats.drawn_px += STEP
		_add_point(f, from + dir * STEP * k)
	_spool_warned = false
	if not f.lit:
		f.lit = true
	return true


func fuse_of_pointer(pointer_id: int) -> Fuse:
	for f in fuses:
		if f.pointer_id == pointer_id:
			return f
	return null


func _add_point(f: Fuse, p: Vector2) -> void:
	var i := f.pts.size()
	f.pts.append(p)
	f.burnt.append(0)
	f.burn_t.append(0.0)
	var a := f.pts[i - 1]
	# Crossings against existing unburnt segments create junctions.
	for cand in _query_segments(a, p):
		var fid: int = cand.x
		var k: int = cand.y
		if fid == f.id and k >= i - 3:
			continue
		var other := fuses[fid]
		var c = Geometry2D.segment_intersects_segment(a, p, other.pts[k], other.pts[k + 1])
		if c == null:
			continue
		if c.distance_to(a) < 0.01:
			continue  # touches at our segment start: counted with the previous segment
		var j := k if c.distance_to(other.pts[k]) <= c.distance_to(other.pts[k + 1]) else k + 1
		if other.burnt[j] == 1:
			continue  # crossing ash is harmless
		if _has_junction_near(f, i, other.id, j):
			continue  # same physical crossing seen through a neighbouring segment
		_link(f, i, other, j)
		stats.junctions += 1
		junction_created.emit(c)
		if other == f:
			_close_loop(f, j, i)
	_register_segment(f.id, i - 1, a, p)
	# Thread free fireworks the new point passes through.
	for fw in fireworks:
		if (fw.state == FwState.WAITING or fw.state == FwState.ENCLOSED) and p.distance_to(fw.pos) <= fw.radius + cfg.thread_tolerance:
			fw.state = FwState.ARMED
			fw.fuse_id = f.id
			fw.fuse_idx = i
			stats.threaded += 1
			firework_threaded.emit(fw)


## A self-crossing closed a loop: enclose the free fireworks inside it.
func _close_loop(f: Fuse, a: int, b: int) -> void:
	var poly := f.pts.slice(a, b + 1)
	if poly.size() < 4:
		return
	var lp := Loop.new()
	lp.id = loops.size()
	lp.fuse_id = f.id
	lp.a = a
	lp.b = b
	lp.polygon = poly
	for fw in fireworks:
		if fw.state == FwState.WAITING and Geometry2D.is_point_in_polygon(fw.pos, poly):
			fw.state = FwState.ENCLOSED
			fw.loop_id = lp.id
			lp.fw_ids.append(fw.id)
			firework_enclosed.emit(fw)
	loops.append(lp)
	for idx in [a, b]:
		var key := Vector2i(f.id, idx)
		if not _loop_at.has(key):
			_loop_at[key] = []
		_loop_at[key].append(lp.id)
	stats.loops += 1
	loop_closed.emit(lp.id, lp.fw_ids.size())


## True if a junction already links points near i (this fuse) and j (other fuse).
func _has_junction_near(f: Fuse, i: int, other_id: int, j: int) -> bool:
	for di in range(-2, 3):
		var arr = f.junctions.get(i + di)
		if arr:
			for v in arr:
				if v.x == other_id and absi(v.y - j) <= 2:
					return true
	return false


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


## True if a straight stroke from a to b would cross unburnt fuse (excluding the
## last few points behind the given fuse's head, i.e. the stroke's own start).
func would_cross_unburnt(a: Vector2, b: Vector2, own: Fuse = null) -> bool:
	for cand in _query_segments(a, b):
		var f := fuses[cand.x]
		var k: int = cand.y
		if own != null and f == own and k >= own.size() - 4:
			continue
		if f.burnt[k] == 1 and f.burnt[k + 1] == 1:
			continue
		if Geometry2D.segment_intersects_segment(a, b, f.pts[k], f.pts[k + 1]) != null:
			return true
	return false


## Distance from pos to the nearest unburnt fuse point within radius (INF if none).
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


## Length (in points) of the jump an ignition causes on this fuse right now.
func jump_points_for(f: Fuse) -> int:
	var jumps: Array = cfg.ignite_jump
	return int(round(float(jumps[heat_for_fuse(f) - 1]) / STEP))


## Armed bangers whose blast could light the fuse (for warnings and bots).
func armed_bangers() -> Array[Firework]:
	var out: Array[Firework] = []
	for fw in fireworks:
		if fw.kind == Kind.BANGER and (fw.state == FwState.ARMED or fw.state == FwState.ENCLOSED):
			out.append(fw)
	return out


## The banger's own passage: the contiguous run of its fuse that stays inside the
## blast circle around the point where it was threaded. That run never ignites;
## only fuse that *re-enters* the circle does. Returns Vector2i(first, last) or
## (-1, -1) if the banger is not on this fuse.
func blast_exempt_range(f: Fuse, b: Firework) -> Vector2i:
	if b.fuse_id != f.id or b.fuse_idx < 0:
		return Vector2i(-1, -1)
	var r: float = cfg.banger_radius
	var a := b.fuse_idx
	while a > 0 and f.pts[a - 1].distance_to(b.pos) <= r:
		a -= 1
	var z := b.fuse_idx
	while z < f.size() - 1 and f.pts[z + 1].distance_to(b.pos) <= r:
		z += 1
	return Vector2i(a, z)


## True if an unburnt fuse point would be lit by an armed banger's blast.
func in_blast_danger(f: Fuse, i: int, bangers: Array[Firework]) -> bool:
	if f.burnt[i] == 1:
		return false
	for b in bangers:
		if f.pts[i].distance_to(b.pos) > cfg.banger_radius:
			continue
		var ex := blast_exempt_range(f, b)
		if i >= ex.x and i <= ex.y:
			continue
		return true
	return false


# --- simulation step ------------------------------------------------------------

func step(dt: float) -> void:
	if finished or not started:
		return
	var main := fuses[0]
	if not main.lit:
		return  # nothing happens until the first stroke
	time += dt
	if over:
		_advance_finale(dt)
		_advance_rockets(dt)
		return
	fire_energy *= exp(-dt / float(cfg.spark_energy_tau))
	if time >= float(cfg.night_length):
		_reach_dawn()
		return
	if sparks.is_empty() and time >= cfg.spark_delay and main.burnt[0] == 0:
		_spawn_spark(0, 0, 1)
	for f in fuses:
		if f.ignite_at >= 0.0 and time >= f.ignite_at:
			f.ignite_at = -1.0
			if f.burnt[0] == 0:
				_spawn_spark(f.id, 0, 1)
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
	fuses[fid].burn_t[idx] = time
	sparks.append(sp)


## Second spark at an already-burnt start point (the forward one marked it).
func _spawn_spark_from_burnt(fid: int, idx: int, dir: int) -> void:
	var sp := Spark.new()
	sp.fuse_id = fid
	sp.s = idx
	sp.dir = dir
	sparks.append(sp)


func _advance_sparks(dt: float) -> void:
	# Speeds are evaluated once per fuse per step (heat depends on spark positions).
	var speeds := {}
	for f in fuses:
		speeds[f.id] = speed_for(f) / STEP * dt
	# Iterate over a snapshot: junctions may append new sparks during this step.
	var current := sparks.duplicate()
	for sp: Spark in current:
		if not sp.alive:
			continue
		var f := fuses[sp.fuse_id]
		var target: float = sp.s + sp.dir * float(speeds[sp.fuse_id])
		var i := int(floor(sp.s)) + 1 if sp.dir > 0 else int(ceil(sp.s)) - 1
		while sp.alive and ((sp.dir > 0 and i <= floor(target)) or (sp.dir < 0 and i >= ceil(target))):
			if i < 0:
				sp.alive = false
				break
			if i >= f.size():
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
			if sp.dir > 0 and int(floor(sp.s)) >= f.size() - 1 and f.alive:
				_catch(f)
				sp.alive = false
	sparks = sparks.filter(func(s): return s.alive)


func _burn_point(f: Fuse, i: int) -> void:
	f.burnt[i] = 1
	f.burn_t[i] = time
	if f.junctions.has(i):
		for partner in f.junctions[i]:
			var of := fuses[partner.x]
			if of.burnt[partner.y] == 0:
				_spawn_spark(partner.x, partner.y, 1)
				_spawn_spark_from_burnt(partner.x, partner.y, -1)
	var loop_ids = _loop_at.get(Vector2i(f.id, i))
	if loop_ids != null:
		for lid in loop_ids:
			_fire_loop(loops[lid], f.pts[i])
	for fw in fireworks:
		if fw.state == FwState.ARMED and fw.fuse_id == f.id and fw.fuse_idx == i:
			_ignite(fw)
			_jump_fire(f, i)


## An ignition flings embers forward along the fuse: fire restarts some distance
## ahead (both directions). The distance grows with heat, so hugging the spark
## is what gets punished, not slow drawing; the jump zone is shown to the player.
func _jump_fire(f: Fuse, i: int) -> void:
	var j := i + jump_points_for(f)
	if j <= i or j >= f.size() or f.burnt[j] == 1:
		if j >= f.size() and f.alive:
			fire_jumped.emit(f.pts[i], f.head())
			_catch(f)
		return
	fire_jumped.emit(f.pts[i], f.pts[j])
	_burn_point(f, j)
	if j + 1 < f.size():
		_spawn_spark_from_burnt(f.id, j, 1)
	_spawn_spark_from_burnt(f.id, j, -1)


## Fire reached a loop's junction: everything enclosed goes off together.
func _fire_loop(lp: Loop, at: Vector2) -> void:
	if lp.fired:
		return
	lp.fired = true
	var n := 0
	for fw in fireworks:
		if fw.state == FwState.ENCLOSED and fw.loop_id == lp.id:
			n += 1
			stats.loop_ignitions += 1
			_ignite(fw)
	if n > 0:
		short_circuit.emit(at, n)


func _catch(f: Fuse) -> void:
	f.alive = false
	f.pointer_id = -1
	head_caught.emit(f.id, f.head())


## Night is over: the round ends successfully; everything threaded goes off at
## full value as the dawn finale.
func _reach_dawn() -> void:
	survived_dawn = true
	for f in fuses:
		if f.alive:
			f.alive = false
			f.pointer_id = -1
	dawn.emit()
	_check_over()


## Fraction of the night that has passed (0..1), for the sky/HUD.
func night_progress() -> float:
	return clampf(time / float(cfg.night_length), 0.0, 1.0)


func _check_over() -> void:
	if over:
		return
	for f in fuses:
		if f.alive:
			return
	over = true
	# Grand finale: every firework still threaded goes off, nearest to the catch
	# first. Failure should look spectacular, not punishing.
	for fw in fireworks:
		if fw.state == FwState.ARMED or fw.state == FwState.ENCLOSED:
			finale_queue.append(fw)
	finale_queue.sort_custom(func(a, b): return a.fuse_idx > b.fuse_idx)
	finale_started.emit(finale_queue.size())
	_finale_timer = 0.35


func _advance_finale(dt: float) -> void:
	_finale_timer -= dt
	if _finale_timer > 0.0:
		return
	if finale_queue.is_empty():
		if rockets.is_empty():
			finished = true
			game_over.emit(score)
		return
	_in_finale = true
	_ignite(finale_queue.pop_front())
	_in_finale = false
	_finale_timer = cfg.finale_interval


# --- heat ---------------------------------------------------------------------

## Heat of the hottest fuse (HUD).
func heat_level() -> int:
	return _heat_from_gap(gap_time())


func heat_for(fuse_id: int) -> int:
	return heat_for_fuse(fuses[fuse_id])


func heat_for_fuse(f: Fuse) -> int:
	return _heat_from_gap(gap_time_for(f))


func _heat_from_gap(gap: float) -> int:
	if gap < cfg.heat3_gap:
		return 3
	if gap < cfg.heat2_gap:
		return 2
	return 1


## Seconds until fire reaches the most threatened head.
func gap_time() -> float:
	var best := INF
	for f in fuses:
		best = minf(best, gap_time_for(f))
	return best


## Seconds (at base speed) until the most advanced forward spark reaches this head.
func gap_time_for(f: Fuse) -> float:
	if not f.alive:
		return INF
	var front := -1.0
	for sp in sparks:
		if sp.fuse_id == f.id and sp.dir > 0:
			front = maxf(front, sp.s)
	if front < 0.0:
		return INF
	return (f.size() - 1 - front) * STEP / base_speed()


## Unburnt fuse length (px) between the front spark and the head ("in transit").
func gap_px_for(f: Fuse) -> float:
	var front := -1.0
	for sp in sparks:
		if sp.fuse_id == f.id and sp.dir > 0:
			front = maxf(front, sp.s)
	if front < 0.0:
		return (f.size() - 1) * STEP
	return (f.size() - 1 - front) * STEP


func held_count() -> int:
	var n := 0
	for f in fuses:
		if f.alive and f.pointer_id != -1:
			n += 1
	return n


# --- fireworks ------------------------------------------------------------------

func _ignite(fw: Firework) -> void:
	if not fw.is_live():
		return
	var attached := fw.state == FwState.ARMED or fw.state == FwState.ENCLOSED
	fw.state = FwState.EXPLODED
	ignitions += 1
	if time - last_ignite_time <= cfg.chain_window:
		chain += 1
	else:
		chain = 1
	last_ignite_time = time
	best_chain = maxi(best_chain, chain)
	var heat := 1
	var mult := 1.0
	var kind_name: String = Kind.keys()[fw.kind].to_lower()
	if _in_finale:
		mult = 1.0 if survived_dawn else float(cfg.finale_factor)
	else:
		heat = heat_for(fw.fuse_id) if fw.fuse_id >= 0 and fuses[fw.fuse_id].alive else heat_level()
		if held_count() >= 2:
			mult = cfg.twin_bonus
			stats.twin_ignitions += 1
		fire_energy += 1.0
		var refund: float = float(cfg.refund[kind_name]) * (1.0 + cfg.refund_chain_bonus * (chain - 1))
		spool = minf(spool + refund, cfg.spool_max)
		stats.refunded_px += refund
		spool_refunded.emit(fw.pos, refund)
	stats.max_heat = maxi(stats.max_heat, heat)
	var heat_points: Array = cfg.heat_points
	var pts := int(round(float(cfg.points[kind_name]) * float(heat_points[heat - 1]) * mult * (1.0 + cfg.chain_bonus * (chain - 1))))
	score += pts
	if _in_finale:
		stats.finale_points += pts
	firework_ignited.emit(fw, pts, heat, chain)
	match fw.kind:
		Kind.ROCKET:
			_launch_rocket(fw)
		Kind.BANGER:
			_explode_banger(fw, attached)
		Kind.SPLITTER:
			if not over:
				_split(fw)


## The fire splits: a short branch fuse appears at the splitter. A second finger
## can grab its head and draw it; fire enters it after a short delay.
func _split(fw: Firework) -> void:
	var f := Fuse.new()
	f.id = fuses.size()
	var p := fw.pos
	f.pts.append(p)
	f.burnt.append(0)
	f.burn_t.append(0.0)
	fuses.append(f)
	var dir := fw.dir
	for k in int(cfg.splitter_stub / STEP):
		var q := p + dir * STEP * (k + 1)
		if not arena.grow(-20).has_point(q):
			dir = -dir
			q = p + dir * STEP * (k + 1)
		_add_point(f, q)
	f.lit = true
	f.ignite_at = time + cfg.splitter_delay
	stats.branches += 1
	branch_created.emit(f.id, f.head())


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
			if other.id == r.source_id or r.hit.has(other.id) or not other.is_live():
				continue
			var closest := Geometry2D.get_closest_point_to_segment(other.pos, prev, now)
			if closest.distance_to(other.pos) <= other.radius + cfg.rocket_hit_radius:
				r.hit[other.id] = true
				_ignite(other)
	rockets = rockets.filter(func(r): return r.t < 1.0)


## attached: the banger was threaded/enclosed by the player. Only those can light
## the fuse (their danger zone is shown); bangers set off by rockets or chains
## only ignite other fireworks, so no death comes from something unmarked.
func _explode_banger(fw: Firework, attached: bool) -> void:
	var r: float = cfg.banger_radius
	blast.emit(fw.pos, r)
	for other in fireworks:
		if other != fw and other.is_live() and other.pos.distance_to(fw.pos) <= r:
			_ignite(other)
	if not attached:
		return
	# Embers ignite unburnt fuse runs inside the blast - except the banger's own
	# passage, so danger only comes from routing fuse back into its circle.
	for f in fuses:
		var ex := blast_exempt_range(f, fw)
		var i := 0
		while i < f.size():
			if i >= ex.x and i <= ex.y:
				i += 1
				continue
			if f.burnt[i] == 0 and f.pts[i].distance_to(fw.pos) <= r:
				var a := i
				while i < f.size() and f.burnt[i] == 0 and f.pts[i].distance_to(fw.pos) <= r \
						and not (i >= ex.x and i <= ex.y):
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
	fireworks = fireworks.filter(func(fw): return fw.is_live() or fw.age < 3.0)


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
	var heads: Array[Vector2] = []
	for f in fuses:
		if f.alive:
			heads.append(f.head())
	for attempt in 24:
		var p := Vector2(
			rng.randf_range(arena.position.x + cfg.edge_margin, arena.end.x - cfg.edge_margin),
			rng.randf_range(arena.position.y + cfg.edge_margin, arena.end.y - cfg.edge_margin))
		var ok := true
		for h in heads:
			if p.distance_to(h) < cfg.spawn_min_head_dist:
				ok = false
		if not ok or min_unburnt_distance(p, cfg.spawn_min_fuse_dist) < cfg.spawn_min_fuse_dist:
			continue
		for fw in fireworks:
			if fw.is_live() and fw.pos.distance_to(p) < cfg.spawn_min_fw_dist:
				ok = false
				break
		if ok:
			_add_firework(_roll_kind(), p)
			return


func _roll_kind() -> int:
	var w: Dictionary = cfg.kind_weights
	var unlock: Dictionary = cfg.get("kind_unlock_time", {})
	var allowed := {}
	var total := 0.0
	for k in w:
		if k == "splitter" and not cfg.get("splitter_enabled", false):
			continue
		if time >= float(unlock.get(k, 0.0)):
			allowed[k] = float(w[k])
			total += float(w[k])
	var r := rng.randf() * total
	for k in allowed:
		r -= allowed[k]
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
	# A gentle, readable opening: two fountains on the natural first stroke,
	# then a rocket aimed at a fourth firework (first chain without effort).
	_add_firework(Kind.FOUNTAIN, candle + Vector2(-30, -170))
	_add_firework(Kind.FOUNTAIN, candle + Vector2(70, -320))
	var rocket := _add_firework(Kind.ROCKET, candle + Vector2(-60, -460))
	rocket.dir = Vector2(1, -0.25).normalized()
	_add_firework(Kind.FOUNTAIN, rocket.pos + rocket.dir * 260)
	for fw in fireworks:
		fw.life = fw.max_life + 6.0
