class_name SwarmSim
extends RefCounted
## Pure simulation of the SCHWARM prototype: a flock of fish follows the player's
## finger(s). Each extra finger becomes another attractor; every fish follows its
## nearest attractor (with hysteresis), so two fingers split the school.
## Plankton grows the school, predators eat stragglers. Round ends at 0 fish.

signal fish_eaten(pos: Vector2)
signal fish_joined(pos: Vector2)
signal plankton_bitten(pos: Vector2)
signal plankton_spawned(pos: Vector2)
signal predator_warned(kind: int, from: Vector2, to: Vector2)
signal game_over(score: int)

enum Pred { PIKE, JELLY }

const CELL := 48.0

var cfg: Dictionary
var rng := RandomNumberGenerator.new()
var arena: Rect2
var pos := PackedVector2Array()
var vel := PackedVector2Array()
var group := PackedInt32Array()  # index into attractor slots (0/1), -1 none
var attractors := {}  # pointer id -> Vector2
var plankton: Array = []  # {pos, left, max, r}
var predators: Array = []  # {kind, pos, vel, state, t, from, to}
var time := 0.0
var score := 0
var eaten_total := 0
var collected := 0
var over := false
var stats := {"max_fish": 0, "splits": 0, "split_time": 0.0, "pike_attacks": 0}
var _grid := {}
var _plankton_timer := 0.0
var _pred_timer := 0.0
var _grow_progress := 0.0
var _was_split := false
var _resplit := false


func _init(config: Dictionary, arena_rect: Rect2, seed_value: int) -> void:
	cfg = config
	arena = arena_rect
	rng.seed = seed_value
	var c := arena.get_center() + Vector2(0, arena.size.y * 0.2)
	for i in int(cfg.start_fish):
		_add_fish(c + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(0, 50))
	_pred_timer = cfg.first_predator
	_plankton_timer = 0.0
	for i in 2:
		_spawn_plankton()


func fish_count() -> int:
	return pos.size()


func _add_fish(p: Vector2) -> void:
	pos.append(p)
	vel.append(Vector2.from_angle(rng.randf() * TAU) * 40.0)
	group.append(0)
	stats.max_fish = maxi(stats.max_fish, pos.size())


func _remove_fish(i: int) -> void:
	pos.remove_at(i)
	vel.remove_at(i)
	group.remove_at(i)


# --- input ------------------------------------------------------------------

func set_attractor(pointer_id: int, p: Vector2) -> void:
	if attractors.has(pointer_id) or attractors.size() < 2:
		if not attractors.has(pointer_id) and attractors.size() == 1:
			_resplit = true  # second finger arrived: divide the school
		attractors[pointer_id] = Vector2(clampf(p.x, arena.position.x, arena.end.x), clampf(p.y, arena.position.y, arena.end.y))


func clear_attractor(pointer_id: int) -> void:
	attractors.erase(pointer_id)


# --- step ---------------------------------------------------------------------

func step(dt: float) -> void:
	if over:
		return
	time += dt
	_rebuild_grid()
	_assign_groups()
	_steer(dt)
	_eat_plankton()
	_update_predators(dt)
	_spawn(dt)
	var split := _is_split()
	if split:
		stats.split_time += dt
		if not _was_split:
			stats.splits += 1
	_was_split = split
	if pos.is_empty():
		over = true
		game_over.emit(score)


func _is_split() -> bool:
	if attractors.size() < 2:
		return false
	var counts := [0, 0]
	for g in group:
		if g >= 0 and g < 2:
			counts[g] += 1
	return counts[0] >= 3 and counts[1] >= 3


func _rebuild_grid() -> void:
	_grid.clear()
	for i in pos.size():
		var k := Vector2i(floori(pos[i].x / CELL), floori(pos[i].y / CELL))
		if not _grid.has(k):
			_grid[k] = PackedInt32Array()
		_grid[k].append(i)


func _neighbors(p: Vector2) -> PackedInt32Array:
	var out := PackedInt32Array()
	var c := Vector2i(floori(p.x / CELL), floori(p.y / CELL))
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var arr = _grid.get(c + Vector2i(dx, dy))
			if arr:
				out.append_array(arr)
	return out


func _targets() -> Array:
	return attractors.values()


func _assign_groups() -> void:
	var t := _targets()
	if t.size() == 2 and _resplit:
		_split_by_axis(t[0], t[1])
	_resplit = false
	for i in pos.size():
		if t.is_empty():
			group[i] = -1
			continue
		if t.size() == 1:
			group[i] = 0
			continue
		var d0 := pos[i].distance_to(t[0])
		var d1 := pos[i].distance_to(t[1])
		var g := group[i]
		# Fish stay loyal to their finger; they only switch when the other finger
		# is much closer (that is how two groups merge when the fingers meet).
		if g == 0 and d1 < d0 * cfg.split_hysteresis:
			group[i] = 1
		elif g == 1 and d0 < d1 * cfg.split_hysteresis:
			group[i] = 0
		elif g < 0 or g > 1:
			group[i] = 0 if d0 <= d1 else 1


## Divides the school in half along the axis from finger 1 to finger 2: the half
## lying towards finger 2 follows finger 2.
func _split_by_axis(a: Vector2, b: Vector2) -> void:
	var axis := (b - a).normalized()
	var order := []
	for i in pos.size():
		order.append([pos[i].dot(axis), i])
	order.sort_custom(func(x, y): return x[0] < y[0])
	var half := order.size() / 2
	for k in order.size():
		group[order[k][1]] = 1 if k >= half else 0


func _steer(dt: float) -> void:
	var t := _targets()
	var center := Vector2.ZERO
	for p in pos:
		center += p
	if pos.size() > 0:
		center /= pos.size()
	var new_vel := vel.duplicate()
	for i in pos.size():
		var p := pos[i]
		var sep := Vector2.ZERO
		var ali := Vector2.ZERO
		var coh := Vector2.ZERO
		var n := 0
		for j in _neighbors(p):
			if j == i or group[j] != group[i]:
				continue
			var d := p.distance_to(pos[j])
			if d < cfg.view_radius and d > 0.01:
				n += 1
				ali += vel[j]
				coh += pos[j]
				if d < cfg.sep_radius:
					sep += (p - pos[j]) / (d * d)
		var acc := Vector2.ZERO
		if n > 0:
			acc += sep * cfg.w_sep
			acc += (ali / n - vel[i]) * cfg.w_ali
			acc += (coh / n - p) * cfg.w_coh
		# Follow the finger (or idle around the school center).
		var goal: Vector2 = t[group[i]] if group[i] >= 0 and group[i] < t.size() else center
		var to_goal := goal - p
		var desired := to_goal.limit_length(cfg.max_speed) if group[i] >= 0 else to_goal.limit_length(cfg.max_speed * 0.3)
		acc += (desired - vel[i]) * cfg.w_follow
		# Flee predators.
		for pr in predators:
			if pr.state != "active":
				continue
			var away: Vector2 = p - pr.pos
			var dist := away.length()
			if dist < cfg.flee_radius and dist > 0.01:
				acc += away / dist * cfg.w_flee * (1.0 - dist / cfg.flee_radius)
		# Soft walls.
		var m: float = cfg.wall_margin
		if p.x < arena.position.x + m: acc.x += cfg.w_wall
		if p.x > arena.end.x - m: acc.x -= cfg.w_wall
		if p.y < arena.position.y + m: acc.y += cfg.w_wall
		if p.y > arena.end.y - m: acc.y -= cfg.w_wall
		acc = acc.limit_length(cfg.max_force)
		# Bigger schools are slower: emergent risk of growing.
		var top: float = cfg.max_speed * (1.0 - cfg.size_slowdown * clampf(pos.size() / 100.0, 0.0, 1.0))
		new_vel[i] = (vel[i] + acc * dt).limit_length(top)
	vel = new_vel
	for i in pos.size():
		pos[i] += vel[i] * dt
		pos[i] = Vector2(clampf(pos[i].x, arena.position.x, arena.end.x), clampf(pos[i].y, arena.position.y, arena.end.y))


func _eat_plankton() -> void:
	for pl in plankton:
		if pl.left <= 0:
			continue
		for i in _neighbors(pl.pos):
			if pos[i].distance_to(pl.pos) < pl.r:
				pl.left -= 1
				collected += 1
				score += 1 + pos.size() / int(cfg.score_fish_div)
				plankton_bitten.emit(pl.pos)
				_grow_progress += 1.0
				if _grow_progress >= cfg.bites_per_fish:
					_grow_progress -= cfg.bites_per_fish
					_add_fish(pos[i] + Vector2(rng.randf_range(-8, 8), rng.randf_range(-8, 8)))
					fish_joined.emit(pos[pos.size() - 1])
				if pl.left <= 0:
					break
	plankton = plankton.filter(func(pl): return pl.left > 0)


func _update_predators(dt: float) -> void:
	for pr in predators:
		pr.t += dt
		match pr.state:
			"warn":
				if pr.t >= cfg.pike_warning:
					pr.state = "active"
					pr.t = 0.0
			"active":
				pr.pos += pr.vel * dt
				var eat_r: float = cfg.pike_eat_radius if pr.kind == Pred.PIKE else cfg.jelly_radius
				var i := pos.size() - 1
				while i >= 0:
					if pos[i].distance_to(pr.pos) < eat_r:
						fish_eaten.emit(pos[i])
						eaten_total += 1
						_remove_fish(i)
					i -= 1
				if not arena.grow(200).has_point(pr.pos):
					pr.state = "gone"
	predators = predators.filter(func(pr): return pr.state != "gone")


func _spawn(dt: float) -> void:
	_plankton_timer -= dt
	if _plankton_timer <= 0.0 and plankton.size() < cfg.plankton_max:
		_plankton_timer = cfg.plankton_interval
		_spawn_plankton()
		# Sometimes spawn a pair far apart to invite splitting.
		if rng.randf() < cfg.plankton_pair_chance:
			_spawn_plankton()
	_pred_timer -= dt
	if _pred_timer <= 0.0:
		var interval: float = maxf(cfg.predator_interval_min, cfg.predator_interval_start - cfg.predator_interval_ramp * time)
		_pred_timer = interval
		if rng.randf() < cfg.jelly_chance:
			_spawn_jelly()
		else:
			_spawn_pike()


func _spawn_plankton() -> void:
	var m: float = cfg.wall_margin + 20
	var p := Vector2(rng.randf_range(arena.position.x + m, arena.end.x - m), rng.randf_range(arena.position.y + m, arena.end.y - m))
	plankton.append({"pos": p, "left": int(cfg.plankton_bites), "max": int(cfg.plankton_bites), "r": cfg.plankton_radius})
	plankton_spawned.emit(p)


func _school_center() -> Vector2:
	var c := Vector2.ZERO
	for p in pos:
		c += p
	return c / maxf(pos.size(), 1)


func _spawn_pike() -> void:
	# Charges in a straight line through the school's current center.
	var target := _school_center()
	var side := rng.randi_range(0, 3)
	var from: Vector2
	match side:
		0: from = Vector2(arena.position.x - 60, rng.randf_range(arena.position.y, arena.end.y))
		1: from = Vector2(arena.end.x + 60, rng.randf_range(arena.position.y, arena.end.y))
		2: from = Vector2(rng.randf_range(arena.position.x, arena.end.x), arena.position.y - 60)
		_: from = Vector2(rng.randf_range(arena.position.x, arena.end.x), arena.end.y + 60)
	var dir := (target - from).normalized()
	predators.append({"kind": Pred.PIKE, "pos": from, "vel": dir * cfg.pike_speed, "state": "warn", "t": 0.0, "from": from, "to": from + dir * 2000.0})
	stats.pike_attacks += 1
	predator_warned.emit(Pred.PIKE, from, from + dir * 2000.0)


func _spawn_jelly() -> void:
	var x := rng.randf_range(arena.position.x + 60, arena.end.x - 60)
	var from := Vector2(x, arena.end.y + 60)
	var to := Vector2(x + rng.randf_range(-120, 120), arena.position.y - 60)
	predators.append({"kind": Pred.JELLY, "pos": from, "vel": (to - from).normalized() * cfg.jelly_speed, "state": "active", "t": 0.0, "from": from, "to": to})
	predator_warned.emit(Pred.JELLY, from, to)
