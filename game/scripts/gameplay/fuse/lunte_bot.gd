class_name LunteBot
extends RefCounted
## Heuristic LUNTE player used for balancing simulations and rendered demos.
## It is NOT a substitute for human playtests: it plays mechanically, never
## panics, and has perfect information. Profiles differ in how close they let
## the spark come (risk appetite) and how fast they draw.

var sim: FuseSim
var target_gap: float  # seconds of safety margin the bot tries to keep
var draw_speed: float  # px/s while drawing
var rng := RandomNumberGenerator.new()
var head := Vector2.ZERO
var finger := Vector2.INF  # accumulated finger position (like a real touch point)
var _target_id := -1
var _retarget := 0.0
var _target := Vector2.ZERO

const PROFILES := {
	"cautious": {"gap": 2.2, "speed": 230.0},
	"normal": {"gap": 1.3, "speed": 300.0},
	"greedy": {"gap": 0.75, "speed": 360.0},
}


func _init(s: FuseSim, profile := "normal", seed_value := 1) -> void:
	sim = s
	target_gap = PROFILES[profile].gap
	draw_speed = PROFILES[profile].speed
	rng.seed = seed_value


## Returns the next finger position for this tick (or the current head if waiting).
func next_position(dt: float) -> Vector2:
	var f := sim.fuses[0]
	head = f.head()
	if finger == Vector2.INF or finger.distance_to(head) > FuseSim.STEP * 2.0:
		finger = head  # (re)attach to the head, e.g. after it was blocked
	if not f.lit:
		finger += Vector2(0, -draw_speed * dt)
		return finger
	var gap := sim.gap_time()
	# Wait while comfortably ahead; draw when the spark approaches.
	if gap != INF and gap > target_gap + 0.4:
		return finger
	_retarget -= dt
	if _retarget <= 0.0 or not _target_alive():
		_target = _pick_target()
		_retarget = 0.25
	var target := _target
	var desired := (target - head).normalized() if target.distance_to(head) > 1.0 else Vector2.UP
	var dir := _safe_direction(desired)
	if dir == Vector2.ZERO:
		return finger  # boxed in: nothing safe, wait for the fire to free space
	finger += dir * draw_speed * dt
	return finger


func _target_alive() -> bool:
	for fw in sim.fireworks:
		if fw.id == _target_id:
			return fw.state == FuseSim.FwState.WAITING
	return _target_id == -1


func _pick_target() -> Vector2:
	var best_score := INF
	var best := Vector2.ZERO
	var found := false
	var prev_target := _target_id
	_target_id = -1
	for fw in sim.fireworks:
		if fw.state != FuseSim.FwState.WAITING:
			continue
		var d := head.distance_to(fw.pos)
		var time_needed := d / draw_speed
		if time_needed > fw.life:
			continue
		var cost := d
		if d < 700.0 and _crosses_unburnt(head, fw.pos):
			cost += 600.0
		if fw.kind == FuseSim.Kind.BANGER:
			cost += 120.0  # bangers are risky near the own fuse
		if fw.id == prev_target:
			cost *= 0.7  # stickiness avoids dithering
		if cost < best_score:
			best_score = cost
			best = fw.pos
			_target_id = fw.id
			found = true
	if found:
		return best
	# No reachable firework: head for the emptiest area (away from unburnt fuse).
	var a := sim.arena
	var probe := Vector2.ZERO
	var best_free := -1.0
	for i in 8:
		var p := Vector2(rng.randf_range(a.position.x + 60, a.end.x - 60), rng.randf_range(a.position.y + 60, a.end.y - 60))
		var free := sim.min_unburnt_distance(p, 96.0)
		if free > best_free:
			best_free = free
			probe = p
	return probe


func _crosses_unburnt(a: Vector2, b: Vector2) -> bool:
	var n := int(a.distance_to(b) / 32.0)
	for i in range(1, n):
		var p := a.lerp(b, float(i) / n)
		if sim.min_unburnt_distance(p, 24.0) < 12.0:
			return true
	return false


func _safe_direction(desired: Vector2) -> Vector2:
	var a := sim.arena.grow(-30)
	for k: int in [0, 1, -1, 2, -2, 3, -3, 4, -4, 5, -5, 6, -6]:
		var d := desired.rotated(k * 0.35)
		var ok := true
		for step: float in [16.0, 32.0, 56.0]:
			var p := head + d * step
			if not a.has_point(p):
				ok = false
				break
			if sim.min_unburnt_distance(p, 24.0) < 14.0 and not _is_own_recent(p):
				ok = false
				break
		if ok:
			return d
	return Vector2.ZERO


## Points right behind the head are part of the fuse we just drew; ignore them.
func _is_own_recent(p: Vector2) -> bool:
	var f := sim.fuses[0]
	var n := f.size()
	for i in range(maxi(0, n - 8), n):
		if f.pts[i].distance_to(p) < 20.0:
			return true
	return false
