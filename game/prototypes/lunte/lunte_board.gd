extends Node2D
## Placeholder renderer for the LUNTE prototype: reads FuseSim state every frame.
## Geometry only (no textures) – the prototype tests the mechanic, not the art.

var sim: FuseSim
var t := 0.0
var cursor_offset := Vector2.ZERO
var popups: Array = []  # {pos, text, age, color, size}

const COL_BG_TOP := Color("#0a0c1c")
const COL_BG_BOTTOM := Color("#1b1430")
const COL_FUSE := Color("#ffb347")
const COL_FUSE_GLOW := Color(1.0, 0.6, 0.2, 0.18)
const COL_ASH := Color("#3b3447")
const KIND_COL := {
	FuseSim.Kind.FOUNTAIN: Color("#46e0c8"),
	FuseSim.Kind.ROCKET: Color("#ff5fd2"),
	FuseSim.Kind.BANGER: Color("#ff4b4b"),
	FuseSim.Kind.SPLITTER: Color("#b48cff"),
}
const HEAT_COL := [Color.WHITE, Color("#ffe066"), Color("#ff9a3c"), Color("#ff3b3b")]


func popup(pos: Vector2, text: String, color: Color, size := 30) -> void:
	popups.append({"pos": pos, "text": text, "age": 0.0, "color": color, "size": size})


func _process(delta: float) -> void:
	t += delta
	for p in popups:
		p.age += delta
		p.pos += Vector2(0, -40) * delta
	popups = popups.filter(func(p): return p.age < 1.1)
	queue_redraw()


func _draw() -> void:
	var vr := get_viewport_rect()
	# The sky brightens towards dawn (night progress), a visible session budget.
	var dawn := sim.night_progress() if sim else 0.0
	var top := COL_BG_TOP.lerp(Color("#3a4a7a"), dawn * dawn)
	var bottom := COL_BG_BOTTOM.lerp(Color("#d9825b"), pow(dawn, 3.0))
	draw_polygon(PackedVector2Array([vr.position, Vector2(vr.end.x, vr.position.y), vr.end, Vector2(vr.position.x, vr.end.y)]),
		PackedColorArray([top, top, bottom, bottom]))
	if sim == null:
		return
	for lp in sim.loops:
		if not lp.fired and lp.fw_ids.size() > 0:
			draw_colored_polygon(lp.polygon, Color(1, 0.9, 0.4, 0.07 + 0.03 * sin(t * 6.0)))
	var bangers := sim.armed_bangers()
	for f in sim.fuses:
		_draw_fuse(f)
		_draw_danger(f, bangers)
		_draw_jump_zones(f)
	for fw in sim.fireworks:
		_draw_firework(fw)
	for r in sim.rockets:
		var p: Vector2 = r.pos()
		var dir: Vector2 = (r.to - r.from).normalized()
		draw_line(p - dir * 26, p, KIND_COL[FuseSim.Kind.ROCKET], 5.0, true)
		draw_circle(p, 6, Color.WHITE)
	for sp in sim.sparks:
		var f := sim.fuses[sp.fuse_id]
		var p := _point_at(f, sp.s)
		var flick := 0.8 + 0.2 * sin(t * 40.0 + sp.s)
		draw_circle(p, 18 * flick, Color(1, 0.55, 0.15, 0.25))
		draw_circle(p, 8 * flick, Color(1, 0.85, 0.4, 0.9))
		draw_circle(p, 4, Color.WHITE)
	_draw_heads()
	var font := ThemeDB.fallback_font
	for p in popups:
		var a: float = 1.0 - p.age / 1.1
		var c: Color = p.color
		c.a = a
		draw_string(font, p.pos - Vector2(60, 0), p.text, HORIZONTAL_ALIGNMENT_CENTER, 120, p.size, c)


func _point_at(f: FuseSim.Fuse, s: float) -> Vector2:
	var i := clampi(int(floor(s)), 0, f.size() - 1)
	var j := mini(i + 1, f.size() - 1)
	return f.pts[i].lerp(f.pts[j], s - floor(s))


func _draw_fuse(f: FuseSim.Fuse) -> void:
	var n := f.size()
	if n < 2:
		return
	var fade: float = sim.cfg.get("ash_fade", 5.0)
	var run := PackedVector2Array()
	var cols := PackedColorArray()
	var state := f.burnt[0]
	run.append(f.pts[0])
	cols.append(_ash_col(f, 0, fade))
	for i in range(1, n):
		var b := f.burnt[i]
		run.append(f.pts[i])
		cols.append(_ash_col(f, i, fade))
		if b != state or i == n - 1:
			_draw_run(run, cols, state)
			run = PackedVector2Array([f.pts[i]])
			cols = PackedColorArray([_ash_col(f, i, fade)])
			state = b


func _ash_col(f: FuseSim.Fuse, i: int, fade: float) -> Color:
	if f.burnt[i] == 0:
		return COL_FUSE
	var age := sim.time - f.burn_t[i]
	return Color(COL_ASH, clampf(1.0 - age / fade, 0.0, 1.0))


func _draw_run(run: PackedVector2Array, cols: PackedColorArray, burnt: int) -> void:
	if run.size() < 2:
		return
	if burnt == 1:
		draw_polyline_colors(run, cols, 3.0, true)
	else:
		draw_polyline(run, COL_FUSE_GLOW, 14.0, true)
		draw_polyline(run, COL_FUSE, 4.0, true)


## Unburnt fuse that an armed banger's blast would light glows red.
func _draw_danger(f: FuseSim.Fuse, bangers: Array[FuseSim.Firework]) -> void:
	if bangers.is_empty():
		return
	for i in f.size():
		if sim.in_blast_danger(f, i, bangers):
			draw_circle(f.pts[i], 5.0, Color(1, 0.2, 0.15, 0.55 + 0.35 * sin(t * 12.0)))


## After every threaded firework the fire will jump forward when it ignites;
## the zone (depends on current heat) is shown as small sparks on the fuse.
func _draw_jump_zones(f: FuseSim.Fuse) -> void:
	if not f.alive:
		return
	var n := sim.jump_points_for(f)
	if n <= 0:
		return
	for fw in sim.fireworks:
		if fw.state == FuseSim.FwState.ARMED and fw.fuse_id == f.id:
			for k in range(1, n + 1, 2):
				var i := fw.fuse_idx + k
				if i < f.size() and f.burnt[i] == 0:
					draw_circle(f.pts[i], 3.0, Color(1, 0.85, 0.4, 0.5))


func _draw_firework(fw: FuseSim.Firework) -> void:
	var c: Color = KIND_COL[fw.kind]
	match fw.state:
		FuseSim.FwState.EXPLODED:
			return
		FuseSim.FwState.FIZZLED:
			draw_circle(fw.pos, fw.radius * 0.6, Color(0.4, 0.4, 0.45, 0.5))
			return
	var pulse := 1.0
	if fw.state == FuseSim.FwState.WAITING and fw.life < 3.0:
		pulse = 0.75 + 0.25 * sin(t * 14.0)
	if fw.kind == FuseSim.Kind.BANGER:
		draw_arc(fw.pos, sim.cfg.banger_radius, 0, TAU, 48, Color(c, 0.18), 2.0, true)
	draw_circle(fw.pos, fw.radius, Color(c, 0.85 * pulse))
	draw_circle(fw.pos, fw.radius * 0.55, Color(0.05, 0.05, 0.1, 0.8))
	match fw.kind:
		FuseSim.Kind.FOUNTAIN:
			var s := fw.radius * 0.45
			draw_colored_polygon(PackedVector2Array([fw.pos + Vector2(0, -s), fw.pos + Vector2(s * 0.9, s * 0.6), fw.pos + Vector2(-s * 0.9, s * 0.6)]), c)
		FuseSim.Kind.ROCKET:
			draw_line(fw.pos - fw.dir * 10, fw.pos + fw.dir * 44, c, 4.0, true)
			var tip := fw.pos + fw.dir * 48
			draw_colored_polygon(PackedVector2Array([tip, tip - fw.dir * 14 + fw.dir.orthogonal() * 8, tip - fw.dir * 14 - fw.dir.orthogonal() * 8]), c)
		FuseSim.Kind.BANGER:
			draw_circle(fw.pos, fw.radius * 0.3, c)
		FuseSim.Kind.SPLITTER:
			draw_line(fw.pos + Vector2(0, 8), fw.pos + Vector2(-9, -8), c, 3.0, true)
			draw_line(fw.pos + Vector2(0, 8), fw.pos + Vector2(9, -8), c, 3.0, true)
	if fw.state == FuseSim.FwState.WAITING:
		var frac := clampf(fw.life / fw.max_life, 0.0, 1.0)
		draw_arc(fw.pos, fw.radius + 7, -PI / 2, -PI / 2 + TAU * frac, 32, Color(1, 1, 1, 0.55), 3.0, true)
	elif fw.state == FuseSim.FwState.ENCLOSED:
		draw_arc(fw.pos, fw.radius + 8 + 3 * sin(t * 8.0), 0, TAU, 32, Color(1, 0.95, 0.5, 0.9), 3.0, true)
	else:
		draw_arc(fw.pos, fw.radius + 6, 0, TAU, 32, Color(1, 0.9, 0.6, 0.9), 3.0, true)


func _draw_heads() -> void:
	for f in sim.fuses:
		if not f.alive:
			continue
		var h := f.head()
		var heat := sim.heat_level()
		var hc: Color = HEAT_COL[heat]
		if f.pointer_id == -1:
			var r := 46.0 + 8.0 * sin(t * 6.0)
			draw_arc(h, r, 0, TAU, 40, Color(1, 1, 1, 0.7), 3.0, true)
		elif cursor_offset != Vector2.ZERO:
			# Faint tether from the (hidden) fingertip to the visible head.
			draw_line(h, h - cursor_offset, Color(1, 1, 1, 0.18), 2.0, true)
		draw_circle(h, 9, hc)
		if heat >= 2 and f.lit:
			draw_arc(h, 24 + 3 * sin(t * 20.0), 0, TAU, 32, Color(hc, 0.8), 3.0, true)
