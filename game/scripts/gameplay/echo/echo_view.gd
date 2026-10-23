class_name EchoView
extends Node2D
## Renders NACHHALL in the "paper night" style: a paper lantern hanging over a
## sleeping cut-paper town, ink ghosts walking towards it, the player's light
## and its echoes. Reads the sim every frame and never changes it.

const LIVE_COL := Color("#fff1b8")
## Echo colours stay clear of the ghost colours (rose, violet, orange).
const ECHO_COLS := [Color("#7fd6ff"), Color("#a6ff9e"), Color("#ffe27a"), Color("#8fa8ff"), Color("#d6ff7a"), Color("#c4f6ff")]
const ENEMY_COLS := [Color("#ff6b8a"), Color("#c58bff"), Color("#ffa25c")]
const PAPER := Color("#ffd58a")
const PAPER_DARK := Color("#e0a656")
const INK := Color("#0a0613")

var sim: EchoSim
var effects := 1.0
var ready_pos := Vector2.ZERO
var targets: Array[Vector2] = []
var t := 0.0
var popups: Array = []  # {pos, text, age, color, size}
var flashes: Array = []  # {pos, color, age, big}
var _enemy_flash := {}  # enemy id -> seconds left
var _lantern_hit := 0.0
var _flame_out: Array = []  # per life: seconds since it went out (-1 = burning)
var _sky: ColorRect
var _sky_mat: ShaderMaterial
var _skyline: Array[PackedVector2Array] = []
var _windows: Array = []
var _glow: Texture2D
var _font: Font


func _ready() -> void:
	_glow = ArtKit.glow_texture()
	_font = UiTheme.FONT_BOLD
	_sky = ColorRect.new()
	_sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sky_mat = ShaderMaterial.new()
	_sky_mat.shader = load("res://assets/shaders/night_sky.gdshader")
	_sky.material = _sky_mat
	_sky.show_behind_parent = true
	add_child(_sky)


## Call when a new round starts: new town, fresh lantern.
func setup(new_sim: EchoSim, seed_value: int) -> void:
	sim = new_sim
	if not is_inside_tree():
		await ready
	popups.clear()
	flashes.clear()
	_enemy_flash.clear()
	_flame_out.clear()
	if sim:
		for i in int(sim.cfg.core_lives):
			_flame_out.append(-1.0)
		ready_pos = sim.start_pos
	var vr := get_viewport_rect()
	_skyline = ArtKit.skyline(vr.size.x, vr.size.y - 10.0, seed_value, 3)
	_windows.clear()
	for i in _skyline.size():
		_windows.append(ArtKit.windows(_skyline[i], seed_value + 17 * i, 0.14))


static func enemy_color(type: int) -> Color:
	return ENEMY_COLS[clampi(type, 0, ENEMY_COLS.size() - 1)]


## Echo k keeps its colour for the whole wave; live lights are warm white.
func light_color(light_id: int) -> Color:
	if sim and light_id < sim.echoes.size():
		return ECHO_COLS[light_id % ECHO_COLS.size()]
	return LIVE_COL


func popup(pos: Vector2, text: String, color: Color, size := 30) -> void:
	popups.append({"pos": pos, "text": text, "age": 0.0, "color": color, "size": size})


func strike_flash(pos: Vector2, color: Color, is_echo: bool) -> void:
	flashes.append({"pos": pos, "color": color, "age": 0.0, "big": not is_echo})


func flash_enemy(id: int) -> void:
	_enemy_flash[id] = 0.25


func lantern_hit() -> void:
	_lantern_hit = 1.0


func run_started() -> void:
	flashes.clear()


func _process(delta: float) -> void:
	t += delta
	for p in popups:
		p.age += delta
		p.pos += Vector2(0, -42) * delta
	popups = popups.filter(func(p): return p.age < 1.2)
	for f in flashes:
		f.age += delta
	flashes = flashes.filter(func(f): return f.age < 0.45)
	for id in _enemy_flash.keys():
		_enemy_flash[id] -= delta
		if _enemy_flash[id] <= 0.0:
			_enemy_flash.erase(id)
	_lantern_hit = maxf(_lantern_hit - delta * 2.0, 0.0)
	if sim:
		for i in _flame_out.size():
			if i >= sim.core_hp and _flame_out[i] < 0.0:
				_flame_out[i] = 0.0
			elif _flame_out[i] >= 0.0:
				_flame_out[i] += delta
	var vr := get_viewport_rect()
	_sky.position = vr.position - position
	_sky.size = vr.size
	_sky_mat.set_shader_parameter("dawn", night_progress())
	_sky_mat.set_shader_parameter("time_s", t)
	_sky_mat.set_shader_parameter("screen_px", vr.size)
	queue_redraw()


## 0 at the first wave, 1 at dawn; drives the sky colour.
func night_progress() -> float:
	if sim == null:
		return 0.0
	var waves := float(sim.waves_per_round())
	var inner := float(sim.tick) / sim.run_ticks() if sim.state == "running" else 0.0
	var p := (sim.wave_index + inner * 0.3) / waves
	if sim.state == "over" and sim.stats.dawn:
		p = 1.0
	return clampf(p, 0.0, 1.0)


func _draw() -> void:
	_draw_skyline()
	if sim == null:
		return
	_draw_routes()
	_draw_echo_trails()
	_draw_lantern()
	_draw_enemies()
	_draw_echo_lights()
	_draw_start_ring()
	_draw_live_lights()
	_draw_flashes()
	_draw_popups()


func _draw_skyline() -> void:
	var tones := [Color("#1a1838"), Color("#131130"), Color("#0b0a22")]
	for i in _skyline.size():
		var poly := _skyline[i]
		if poly.size() >= 3:
			draw_colored_polygon(poly, tones[mini(i, tones.size() - 1)])
		for w in _windows[i]:
			var flick := 0.75 + 0.25 * sin(t * 1.3 + w.x * 0.07)
			draw_rect(Rect2(w - Vector2(5, 7), Vector2(10, 14)), Color(1.0, 0.8, 0.45, 0.28 * flick))


# --- field ------------------------------------------------------------------------

## Faint routes from each spawn point to the lantern: the wave repeats every
## run, so showing where ghosts will come from is fair and helps planning.
func _draw_routes() -> void:
	var running := sim.state == "running"
	for spec in sim.wave:
		if running and sim.tick >= int(spec.tick):
			continue
		var c: Color = enemy_color(spec.type)
		var from: Vector2 = spec.from
		var dir: Vector2 = (sim.core - from).normalized()
		var len: float = from.distance_to(sim.core) - float(sim.cfg.core_radius) - 6.0
		var dash := 14.0
		var s := 0.0
		while s < len:
			draw_line(from + dir * s, from + dir * minf(s + dash * 0.5, len), Color(c, 0.13), 2.0)
			s += dash
		var anchor := _edge_anchor(from)
		if spec.inside:
			# Ink drop warning where a ghost will rise.
			var k := 1.0
			if running:
				k = clampf(1.0 - float(int(spec.tick) - sim.tick) / 60.0, 0.0, 1.0)
			draw_circle(from, 10.0 + 12.0 * k, Color(INK, 0.55))
			draw_arc(from, 12.0 + 12.0 * k, 0, TAU, 28, Color(c, 0.55), 2.0, true)
		else:
			draw_circle(anchor, 7.0, Color(c, 0.75))
			draw_circle(anchor, 3.0, Color.WHITE)


func _edge_anchor(from: Vector2) -> Vector2:
	var a := sim.arena
	return Vector2(clampf(from.x, a.position.x + 8, a.end.x - 8), clampf(from.y, a.position.y + 8, a.end.y - 8))


func _draw_lantern() -> void:
	var c := sim.core
	var r := float(sim.cfg.core_radius)
	var lives := sim.core_hp
	var max_lives := int(sim.cfg.core_lives)
	var warm := 0.35 + 0.65 * float(lives) / max_lives
	var flick := 1.0 + 0.05 * sin(t * 9.0) + 0.03 * sin(t * 23.0)
	# String from the top of the screen.
	draw_line(Vector2(c.x, get_viewport_rect().position.y), c + Vector2(0, -r * 1.25), Color(0.55, 0.5, 0.6, 0.7), 2.0)
	# Halo.
	var halo := r * 6.0 * warm * flick
	draw_texture_rect(_glow, Rect2(c - Vector2(halo, halo), Vector2(halo, halo) * 2.0), false, Color(1.0, 0.65, 0.3, 0.42 * warm))
	# Paper body: an ellipse with ribs.
	var body := _ellipse(c, r * 1.02, r * 1.18, 36)
	var paper := PAPER.lerp(Color("#6b4a5c"), 1.0 - warm)
	if _lantern_hit > 0.0:
		paper = paper.lerp(UiTheme.DANGER, _lantern_hit * 0.6)
	draw_colored_polygon(body, paper)
	for k in [-0.62, -0.25, 0.25, 0.62]:
		var rib := PackedVector2Array()
		for i in 13:
			var a := lerpf(-PI * 0.5, PI * 0.5, i / 12.0)
			rib.append(c + Vector2(k * r * cos(a), sin(a) * r * 1.16))
		draw_polyline(rib, Color(PAPER_DARK, 0.55), 2.0, true)
	draw_polyline(body + PackedVector2Array([body[0]]), Color(PAPER_DARK, 0.9), 2.5, true)
	# Caps.
	draw_rect(Rect2(c + Vector2(-r * 0.55, -r * 1.3), Vector2(r * 1.1, r * 0.2)), Color("#3a2b3f"))
	draw_rect(Rect2(c + Vector2(-r * 0.45, r * 1.12), Vector2(r * 0.9, r * 0.18)), Color("#3a2b3f"))
	# Flames inside: one per life; a dead one leaves a short smoke curl.
	for i in max_lives:
		var fx_ := c + Vector2((i - (max_lives - 1) * 0.5) * r * 0.52, r * 0.3)
		var out: float = _flame_out[i] if i < _flame_out.size() else -1.0
		if out < 0.0:
			var h := r * 0.42 * (1.0 + 0.12 * sin(t * 11.0 + i * 1.7))
			draw_colored_polygon(PackedVector2Array([fx_ + Vector2(-r * 0.12, 0), fx_ + Vector2(0, -h), fx_ + Vector2(r * 0.12, 0), fx_ + Vector2(0, r * 0.1)]), Color("#ff9a3c"))
			draw_colored_polygon(PackedVector2Array([fx_ + Vector2(-r * 0.06, 0), fx_ + Vector2(0, -h * 0.6), fx_ + Vector2(r * 0.06, 0), fx_ + Vector2(0, r * 0.06)]), Color("#fff3c4"))
		elif out < 1.5:
			var a := 1.0 - out / 1.5
			draw_circle(fx_ + Vector2(sin(out * 6.0) * 4.0, -out * 30.0), 4.0 + out * 4.0, Color(0.6, 0.55, 0.65, 0.45 * a))


func _ellipse(c: Vector2, rx: float, ry: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a := TAU * i / n
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


func _draw_enemies() -> void:
	if sim.state != "running":
		return
	var window := sim.twin_window_ticks()
	for e in sim.enemies:
		if not e.alive:
			continue
		var spec: Dictionary = e.spec
		var c: Color = enemy_color(spec.type)
		var p: Vector2 = e.pos
		# Fading ink trail behind the ghost.
		for k in range(4, 0, -1):
			var back: Variant = sim.enemy_pos_at(spec, maxi(int(spec.tick), sim.tick - k * 5))
			if back != null:
				draw_circle(back, 17.0 - k * 2.5, Color(INK, 0.28 - k * 0.05))
		var fl: float = _enemy_flash.get(spec.id, 0.0)
		draw_texture_rect(_glow, Rect2(p - Vector2(46, 46), Vector2(92, 92)), false, Color(c, 0.35))
		var body := _ghost_shape(p, 22.0 if spec.type != EchoSim.Type.ARMOR else 25.0, float(spec.id))
		draw_colored_polygon(body, INK.lerp(Color.WHITE, fl * 2.0))
		draw_polyline(body + PackedVector2Array([body[0]]), c, 2.5, true)
		# Eyes look at the lantern.
		var look: Vector2 = (sim.core - p).normalized()
		var side := Vector2(-look.y, look.x)
		for s in [-1.0, 1.0]:
			var ep: Vector2 = p + look * 6.0 + side * s * 7.0 + Vector2(0, -3)
			draw_circle(ep, 4.2, Color.WHITE)
			draw_circle(ep + look * 1.6, 2.0, INK)
		match spec.type:
			EchoSim.Type.ARMOR:
				var cracked: bool = e.hitters.size() >= 1
				for i in 6:
					if cracked and i % 2 == 0:
						continue
					var a0 := TAU * i / 6.0 + t * 0.6
					draw_arc(p, 32.0, a0, a0 + TAU / 6.0 * 0.8, 6, Color(c, 0.95), 4.0, true)
			EchoSim.Type.TWIN:
				var partner: Variant = sim._enemy_by_id(spec.twin)
				if partner != null and partner.alive and spec.id < spec.twin:
					_dashed(p, partner.pos, Color(c, 0.35), 2.0)
				# Countdown ring: the partner was just hit, strike me now!
				if partner != null and partner.alive and int(partner.hit_tick) >= 0:
					var left := window - (sim.tick - int(partner.hit_tick))
					if left > 0:
						var f := float(left) / window
						draw_arc(p, 32.0, -PI * 0.5, -PI * 0.5 + TAU * f, 32, Color.WHITE, 4.0, true)


## Wobbly ink blob with a ragged lower hem.
func _ghost_shape(p: Vector2, r: float, phase: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var n := 22
	for i in n:
		var a := TAU * i / n
		var w := 1.0 + 0.1 * sin(3.0 * a + t * 2.2 + phase) + 0.05 * sin(5.0 * a - t * 3.1 + phase * 2.0)
		if sin(a) > 0.35:  # hem
			w += 0.16 * absf(sin(a * 4.0 + t * 4.0 + phase))
		pts.append(p + Vector2(cos(a), sin(a) * 1.08) * r * w)
	return pts


func _dashed(a: Vector2, b: Vector2, c: Color, width: float) -> void:
	var len := a.distance_to(b)
	var dir := (b - a) / maxf(len, 0.001)
	var s := fmod(t * 30.0, 16.0)
	while s < len:
		draw_line(a + dir * s, a + dir * minf(s + 8.0, len), c, width)
		s += 16.0


# --- lights -----------------------------------------------------------------------

func _echo_alpha(k: int) -> float:
	# Older echoes are fainter so runs 4-6 stay readable.
	var n := sim.echoes.size()
	return clampf(1.0 - 0.13 * (n - 1 - k), 0.35, 1.0)


func _draw_echo_trails() -> void:
	var at := sim.tick if sim.state == "running" else 0
	for k in sim.echoes.size():
		var ec: Dictionary = sim.echoes[k]
		var c: Color = light_color(ec.id)
		var a := _echo_alpha(k)
		var path: PackedVector2Array = ec.path
		if path.size() >= 2:
			draw_polyline(_thin(path, 3), Color(c, 0.13 * a), 2.0, true)
		# Upcoming strike points: "this echo strikes here".
		for st in (ec.strikes as PackedInt32Array):
			if st < at:
				continue
			var sp: Vector2 = path[mini(st, path.size() - 1)]
			var soon := clampf(1.0 - float(st - at) / 45.0, 0.0, 1.0) if sim.state == "running" else 0.0
			draw_arc(sp, 11.0 + 5.0 * soon, 0, TAU, 20, Color(c, (0.35 + 0.6 * soon) * a), 2.0 + 2.0 * soon, true)


func _thin(path: PackedVector2Array, step: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in range(0, path.size(), step):
		out.append(path[i])
	out.append(path[path.size() - 1])
	return out


func _draw_echo_lights() -> void:
	if sim.state != "running":
		return
	for k in sim.echoes.size():
		var ec: Dictionary = sim.echoes[k]
		var path: PackedVector2Array = ec.path
		var p: Vector2 = path[mini(sim.tick, path.size() - 1)]
		var c: Color = light_color(ec.id)
		var a := _echo_alpha(k)
		draw_texture_rect(_glow, Rect2(p - Vector2(34, 34), Vector2(68, 68)), false, Color(c, 0.55 * a))
		draw_circle(p, 8.0, Color(c, 0.95 * a))
		draw_string(_font, p + Vector2(10, -10), str(k + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(c, 0.8 * a))


func _draw_start_ring() -> void:
	if sim.state == "running" or sim.state == "over":
		return
	var ring := float(sim.cfg.start_ring)
	var pulse := 0.5 + 0.5 * sin(t * 4.0)
	var ok := sim.state == "ready" or sim.can_run_again()
	var c := Color(LIVE_COL, 0.35 + 0.35 * pulse) if ok else Color(1, 1, 1, 0.15)
	var segs := 16
	for i in segs:
		var a0 := TAU * i / segs + t * 0.4
		draw_arc(sim.start_pos, ring, a0, a0 + TAU / segs * 0.55, 6, c, 3.0, true)
	if ok:
		draw_texture_rect(_glow, Rect2(ready_pos - Vector2(46, 46), Vector2(92, 92)), false, Color(LIVE_COL, 0.7))
		draw_circle(ready_pos, 10.0, LIVE_COL)


func _draw_live_lights() -> void:
	if sim.state != "running":
		return
	for k in sim.live.size():
		var l: Dictionary = sim.live[k]
		var p: Vector2 = l.pos
		var charge := sim.charge_of(l)
		var full := charge >= 1.0
		if k < targets.size() and targets[k].distance_to(p) > 24.0:
			draw_line(p, targets[k], Color(LIVE_COL, 0.18), 2.0)
			draw_circle(targets[k], 4.0, Color(LIVE_COL, 0.3))
		var glow := 64.0 if full else 40.0
		draw_texture_rect(_glow, Rect2(p - Vector2(glow, glow), Vector2(glow, glow) * 2.0), false, Color(LIVE_COL, 0.75 if full else 0.3))
		draw_circle(p, 11.0 if full else 8.0, LIVE_COL if full else Color(LIVE_COL, 0.45))
		if not full:
			draw_arc(p, 20.0, -PI * 0.5, -PI * 0.5 + TAU * charge, 28, Color(LIVE_COL, 0.85), 3.0, true)
		else:
			draw_arc(p, float(sim.cfg.hit_radius), 0, TAU, 40, Color(LIVE_COL, 0.16), 1.5, true)


func _draw_flashes() -> void:
	for f in flashes:
		var k: float = f.age / 0.45
		var r: float = lerpf(10.0, float(sim.cfg.hit_radius) * (1.6 if f.big else 1.2), k)
		draw_arc(f.pos, r, 0, TAU, 32, Color(f.color, (1.0 - k) * 0.9), 4.0 * (1.0 - k) + 1.0, true)


func _draw_popups() -> void:
	for p in popups:
		var a := clampf(1.0 - (p.age - 0.7) / 0.5, 0.0, 1.0)
		var fs: int = p.size
		var w := _font.get_string_size(p.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var pos: Vector2 = p.pos - Vector2(w * 0.5, 0)
		draw_string_outline(_font, pos, p.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 8, Color(0.03, 0.03, 0.08, 0.8 * a))
		draw_string(_font, pos, p.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(p.color, a))
