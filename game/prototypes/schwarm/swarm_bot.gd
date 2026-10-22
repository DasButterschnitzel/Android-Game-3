class_name SwarmBot
extends RefCounted
## Heuristic SCHWARM player for simulations/captures (not a human substitute).
## "one": single finger chases the nearest plankton and dodges pike lanes.
## "two": additionally splits the school when two plankton clouds are far apart.

var sim: SwarmSim
var two_fingers := false
var targets := {}  # pointer id -> Vector2 (current finger positions)
const MOVE_SPEED := 700.0  # how fast the bot's fingers move (px/s)


func _init(s: SwarmSim, profile := "one") -> void:
	sim = s
	two_fingers = profile == "two"


## Returns desired finger positions: {pointer_id: Vector2}; missing id = finger up.
func next_fingers(dt: float) -> Dictionary:
	var center := sim._school_center()
	var goals := []
	var pl := sim.plankton.duplicate()
	pl.sort_custom(func(a, b): return a.pos.distance_to(center) < b.pos.distance_to(center))
	if pl.is_empty():
		goals.append(sim.arena.get_center())
	else:
		goals.append(pl[0].pos)
		if two_fingers and pl.size() >= 2 and sim.fish_count() >= 8 and pl[0].pos.distance_to(pl[1].pos) > 320.0:
			goals.append(pl[1].pos)
	# Dodge: push goals away from active/warned pike lanes near the school.
	for pr in sim.predators:
		if pr.kind != SwarmSim.Pred.PIKE:
			continue
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(center, pr.from, pr.to)
		var off: Vector2 = center - closest
		if off.length() < 140.0:
			var away: Vector2 = off.normalized() if off.length() > 1.0 else (pr.to - pr.from).normalized().orthogonal()
			for k in goals.size():
				goals[k] = center + away * 220.0
	for jl in sim.predators:
		if jl.kind == SwarmSim.Pred.JELLY and jl.pos.distance_to(center) < 160.0:
			for k in goals.size():
				goals[k] = goals[k] + (center - jl.pos).normalized() * 150.0
	var out := {}
	for k in goals.size():
		var g: Vector2 = goals[k]
		var cur: Vector2 = targets.get(k, center)
		out[k] = cur.move_toward(g, MOVE_SPEED * dt)
	targets = out
	return out
