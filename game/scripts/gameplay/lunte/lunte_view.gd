class_name LunteView
extends Node2D
## Renders a FuseSim in the "paper night" style. Reads state every frame and
## never changes it; all juice (particles, popups, shake) lives here or in
## LunteGame, so the simulation stays deterministic and testable.

const COL_FUSE := Color("#ffc15e")
const COL_FUSE_GLOW := Color(1.0, 0.6, 0.2, 0.16)
const COL_ASH := Color("#3b3447")
const COL_DANGER := Color("#ff4b3e")
const HEAT_COL := [Color("#9ad1ff"), Color("#ffb347"), Color("#ff4b4b")]
const SKY_TONES := [Color("#1d1940"), Color("#151233"), Color("#0c0a22")]

var sim: FuseSim
var cursor_offset := Vector2.ZERO
var effects := 1.0
var t := 0.0
var popups: Array = []  # {pos, text, age, color, size}
var _sky: ColorRect
var _sky_mat: ShaderMaterial
var _skyline: Array[PackedVector2Array] = []
var _windows: Array = []
var _glow: Texture2D


func _ready() -> void:
	_glow = ArtKit.glow_texture()
	_sky = ColorRect.new()
	_sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sky_mat = ShaderMaterial.new()
	_sky_mat.shader = load("res://assets/shaders/night_sky.gdshader")
	_sky.material = _sky_mat
	_sky.show_behind_parent = true
	add_child(_sky)


## Call when a new round starts: new town, new sky.
func setup(new_sim: FuseSim, seed_value: int) -> void:
	sim = new_sim
	if not is_inside_tree():
		await ready
	popups.clear()
	var vr := get_viewport_rect()
	_skyline = ArtKit.skyline(vr.size.x, vr.size.y - 40.0, seed_value, 3)
	_windows.clear()
	for i in _skyline.size():
		_windows.append(ArtKit.windows(_skyline[i], seed_value + 17 * i, 0.16))


func popup(pos: Vector2, text: String, color: Color, size := 30) -> void:
	popups.append({"pos": pos, "text": text, "age": 0.0, "color": color, "size": size})


func _process(delta: float) -> void:
	t += delta
	for p in popups:
		p.age += delta
		p.pos += Vector2(0, -46) * delta
	popups = popups.filter(func(p): return p.age < 1.2)
	var vr := get_viewport_rect()
	_sky.position = vr.position - position
	_sky.size = vr.size
	_sky_mat.set_shader_parameter("dawn", sim.night_progress() if sim else 0.0)
	_sky_mat.set_shader_parameter("time_s", t)
	_sky_mat.set_shader_parameter("screen_px", vr.size)
	queue_redraw()


func _draw() -> void:
	_draw_skyline()
	if sim == null:
		return
	for lp in sim.loops:
		if not lp.fired and lp.fw_ids.size() > 0 and lp.polygon.size() >= 3:
			draw_colored_polygon(lp.polygon, Color(1, 0.88, 0.45, 0.07 + 0.03 * sin(t * 6.0)))
	var bangers := sim.armed_bangers()
	for b in sim.fireworks:
		if b.kind == FuseSim.Kind.BANGER and b.is_live():
			var armed := b.state != FuseSim.FwState.WAITING
			draw_arc(b.pos, sim.cfg.banger_radius, 0, TAU, 56, Color(COL_DANGER, 0.45 if armed else 0.16), 3.0 if armed else 2.0, true)
	for f in sim.fuses:
		_draw_fuse(f)
		_draw_danger(f, bangers)
		_draw_jump_zone(f)
	for fw in sim.fireworks:
		_draw_firework(fw)
	for r in sim.rockets:
		var p: Vector2 = r.pos()
		var dir: Vector2 = (r.to - r.from).normalized()
		_glow_at(p, 46, Color(1, 0.45, 0.85, 0.5))
		FireworkArt.draw(self, FuseSim.Kind.ROCKET, p, 20.0, dir)
	for sp in sim.sparks:
		var f := sim.fuses[sp.fuse_id]
		var p := _point_at(f, sp.s)
		var flick := 0.85 + 0.15 * sin(t * 37.0 + sp.s)
		_glow_at(p, 70 * flick, Color(1, 0.55, 0.15, 0.55))
		_glow_at(p, 26 * flick, Color(1, 0.9, 0.6, 0.9))
		draw_circle(p, 3.5, Color.WHITE)
	_draw_heads()
	_draw_popups()


func _draw_skyline() -> void:
	var dawn := sim.night_progress() if sim else 0.0
	for i in _skyline.size():
		var tone: Color = SKY_TONES[i].lerp(Color("#2b2347"), dawn * 0.6)
		draw_colored_polygon(_skyline[i], tone)
		var lit := 1.0 - smoothstep(0.55, 1.0, dawn)
		for w in _windows[i]:
			draw_rect(Rect2(w, Vector2(7, 10)), Color(1, 0.8, 0.45, (0.55 - i * 0.12) * lit))


func _glow_at(p: Vector2, size: float, c: Color) -> void:
	draw_texture_rect(_glow, Rect2(p - Vector2(size, size) * 0.5, Vector2(size, size)), false, c)


func _point_at(f: FuseSim.Fuse, s: float) -> Vector2:
	var i := clampi(int(floor(s)), 0, f.size() - 1)
	var j := mini(i + 1, f.size() - 1)
	return f.pts[i].lerp(f.pts[j], s - floor(s))


func _draw_fuse(f: FuseSim.Fuse) -> void:
	var n := f.size()
	if n < 2:
		return
	var fade: float = sim.cfg.get("ash_fade", 5.0)
	var run := PackedVector2Array([f.pts[0]])
	var cols := PackedColorArray([_ash_col(f, 0, fade)])
	var state := f.burnt[0]
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
	return Color(COL_ASH, clampf(1.0 - (sim.time - f.burn_t[i]) / fade, 0.0, 1.0))


func _draw_run(run: PackedVector2Array, cols: PackedColorArray, burnt: int) -> void:
	if run.size() < 2:
		return
	if burnt == 1:
		draw_polyline_colors(run, cols, 3.0, true)
		return
	for k in range(0, run.size(), 3):
		_glow_at(run[k], 30, COL_FUSE_GLOW)
	draw_polyline(run, COL_FUSE, 4.5, true)
	draw_polyline(run, Color(1, 0.95, 0.8, 0.55), 1.5, true)


## Unburnt fuse an armed banger's blast would light glows red.
func _draw_danger(f: FuseSim.Fuse, bangers: Array[FuseSim.Firework]) -> void:
	if bangers.is_empty():
		return
	var pulse := 0.55 + 0.35 * sin(t * 12.0)
	for i in range(0, f.size(), 2):
		if sim.in_blast_danger(f, i, bangers):
			_glow_at(f.pts[i], 22, Color(COL_DANGER, 0.5 * pulse))
			draw_circle(f.pts[i], 3.0, Color(COL_DANGER, pulse))


## Where the fire will jump when a threaded firework ignites (depends on heat).
func _draw_jump_zone(f: FuseSim.Fuse) -> void:
	if not f.alive:
		return
	var n := sim.jump_points_for(f)
	if n <= 0:
		return
	for fw in sim.fireworks:
		if fw.state == FuseSim.FwState.ARMED and fw.fuse_id == f.id:
			for k in range(2, n + 1, 3):
				var i := fw.fuse_idx + k
				if i < f.size() and f.burnt[i] == 0:
					draw_circle(f.pts[i], 3.2, Color(1, 0.4 + 0.3 * sin(t * 18.0 + k), 0.2, 0.9))


func _draw_firework(fw: FuseSim.Firework) -> void:
	var r: float = fw.radius
	match fw.state:
		FuseSim.FwState.EXPLODED:
			return
		FuseSim.FwState.FIZZLED:
			var k := clampf(1.0 - fw.age * 0.0, 0.0, 1.0)
			FireworkArt.draw(self, fw.kind, fw.pos, r * 0.8, fw.dir, 0.25)
			return
	var wobble := t * 4.0 + fw.id
	var alpha := 1.0
	if fw.state == FuseSim.FwState.WAITING and fw.life < 2.5:
		alpha = 0.55 + 0.45 * absf(sin(t * 9.0))  # about to fizzle
	if fw.state != FuseSim.FwState.WAITING:
		_glow_at(fw.pos, r * 4.0, Color(1, 0.8, 0.4, 0.25))
	FireworkArt.draw(self, fw.kind, fw.pos, r, fw.dir, alpha, wobble)
	if fw.kind == FuseSim.Kind.ROCKET:
		# Dotted flight path preview: rockets are planning tools.
		var steps := 9
		for k in range(1, steps + 1):
			var q: Vector2 = fw.pos + fw.dir * sim.cfg.rocket_range * k / steps
			draw_circle(q, 2.4, Color(FireworkArt.color_of(fw.kind), 0.35))
	match fw.state:
		FuseSim.FwState.WAITING:
			var frac := clampf(fw.life / fw.max_life, 0.0, 1.0)
			draw_arc(fw.pos, r + 12, -PI / 2, -PI / 2 + TAU * frac, 36, Color(1, 1, 1, 0.45), 3.0, true)
		FuseSim.FwState.ARMED:
			draw_arc(fw.pos, r + 11, 0, TAU, 36, Color(1, 0.85, 0.5, 0.95), 3.0, true)
		FuseSim.FwState.ENCLOSED:
			draw_arc(fw.pos, r + 12 + 3.0 * sin(t * 8.0), 0, TAU, 36, Color(1, 0.95, 0.55, 0.95), 3.0, true)


func _draw_heads() -> void:
	for f in sim.fuses:
		if not f.alive:
			continue
		var h := f.head()
		var heat := sim.heat_for_fuse(f) if f.lit else 1
		var hc: Color = HEAT_COL[heat - 1]
		if f.pointer_id == -1:
			var r := 44.0 + 7.0 * sin(t * 6.0)
			draw_arc(h, r, 0, TAU, 40, Color(1, 1, 1, 0.65), 3.0, true)
		elif cursor_offset != Vector2.ZERO:
			draw_line(h, h - cursor_offset, Color(1, 1, 1, 0.16), 2.0, true)
			draw_arc(h - cursor_offset, 26, 0, TAU, 28, Color(1, 1, 1, 0.12), 2.0, true)
		_glow_at(h, 40, Color(hc, 0.5))
		draw_circle(h, 7, hc)
		if heat >= 2 and f.lit:
			draw_arc(h, 20 + 3 * sin(t * 20.0), 0, TAU, 32, Color(hc, 0.85), 3.0, true)


func _draw_popups() -> void:
	var font: Font = UiTheme.FONT_BOLD
	for p in popups:
		var a: float = 1.0 - p.age / 1.2
		var c: Color = p.color
		c.a = a
		var w := 320.0
		draw_string_outline(font, p.pos - Vector2(w * 0.5, 0), p.text, HORIZONTAL_ALIGNMENT_CENTER, w, p.size, 6, Color(0.05, 0.04, 0.1, a * 0.8))
		draw_string(font, p.pos - Vector2(w * 0.5, 0), p.text, HORIZONTAL_ALIGNMENT_CENTER, w, p.size, c)
