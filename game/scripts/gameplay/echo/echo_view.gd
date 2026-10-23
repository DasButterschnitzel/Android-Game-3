class_name EchoView
extends Node2D
## Renders NACHHALL as a paper theatre by lantern light (docs/art/STYLE_GUIDE.md):
##   paper - lantern, skyline, UI cards: matt, cut edge, hard offset shadow;
##   light - live light (warm = present) and echoes (cool = past): additive glow;
##   ink   - ghosts only: #0a0613 with a coloured rim and an ink outline.
## A ghost's type is told by its shape (eyes, plates, symbol), colour is only a
## second channel; an echo's identity is its number. Reads the sim every frame
## and never changes it; all juice lives here.

const LIVE_COL := Color("#fff1b8")
const LIVE_GLOW := Color("#ffcf7a")
## "Moonlight": every echo is cool, warm belongs to the live light only.
## At most five echoes are on screen (the sixth light banks automatically);
## the number on each echo tells them apart, colour separates past from present.
const ECHO_COLS := [Color("#a6f0ff"), Color("#29ccb1"), Color("#a6cbff"), Color("#47c1cc"), Color("#a6ffe1")]
const ENEMY_COLS := [Color("#ff6b8a"), Color("#c58bff"), Color("#ffa25c")]
const PAPER := Color("#ffd58a")
const PAPER_DARK := Color("#e0a656")
const INK := Color("#0a0613")
const SHADOW := Color(0.02, 0.012, 0.047, 0.35)
const SPAWN_ANIM := 0.25  # s for a ghost to rise to full size
const TRAIL := 12  # live light trail length in frames
const PREVIEW_TICKS := 60  # echo path shown ahead of each echo (1 s)
const RING_TICKS := 120  # echo strikes announced ahead (2 s)

var sim: EchoSim
var effects := 1.0
var ready_pos := Vector2.ZERO
var targets: Array[Vector2] = []
var score_anchor := Vector2(110, 60)  # where banked points fly to
var t := 0.0
var popups: Array = []  # {pos, text, age, color, size, life}
var flashes: Array = []  # {pos, color, age, big}
var splats: Array = []  # dying ghosts {pos, color, age, r}
var stains: Array = []  # ink stains {pos, r, age, drops}
var beams: Array = []  # twin links {a, b, color, age}
var waves_fx: Array = []  # shockwaves {pos, color, age, size}
var fliers: Array = []  # banked points flying to the score {from, to, age, delay, color}
var _enemy_flash := {}  # enemy id -> seconds left
var _lantern_hit := 0.0
var _sway := 0.0  # lantern angle (rad)
var _sway_v := 0.0
var _flame_out: Array = []  # per life: seconds since it went out (-1 = burning)
var _live_trail: Array = []  # per live light: PackedVector2Array of recent positions
var _live_pulse: Array = []  # per live light: strike pulse 1..0
var _ready_pulse: Array = []  # per live light: "charged again" pulse 1..0
var _was_full: Array = []
var _sky: ColorRect
var _sky_mat: ShaderMaterial
var _skyline: Array[PackedVector2Array] = []
var _windows: Array = []
var _glow: Texture2D
var _font: Font
var _paper := PAPER  # lantern paper colours (cosmetic unlocks)
var _rib := PAPER_DARK


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
	for arr in [popups, flashes, splats, stains, beams, waves_fx, fliers, _flame_out, _live_trail, _live_pulse, _ready_pulse, _was_full]:
		arr.clear()
	_enemy_flash.clear()
	_sway_v = 0.0
	if sim:
		for i in int(sim.cfg.core_lives):
			_flame_out.append(-1.0)
		ready_pos = sim.start_pos
	var vr := get_viewport_rect()
	_skyline = ArtKit.skyline(vr.size.x, vr.size.y - 10.0, seed_value, 3)
	for i in _skyline.size():
		_skyline[i] = _jitter(_skyline[i], seed_value + i)
	_windows.clear()
	for i in _skyline.size():
		_windows.append(ArtKit.windows(_skyline[i], seed_value + 17 * i, 0.14))


## Hand-cut look: deterministic +-1.5 px wobble on every skyline corner.
static func _jitter(poly: PackedVector2Array, seed_value: int) -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var out := PackedVector2Array()
	for p in poly:
		out.append(p + Vector2(rng.randf_range(-1.5, 1.5), rng.randf_range(-1.5, 1.5)))
	return out


## Cosmetic lantern paper (Progression.PAPERS); unknown ids keep the classic paper.
func set_paper(id: String) -> void:
	var p: Dictionary = Progression.PAPERS.get(id, Progression.PAPERS["classic"])
	_paper = p.paper
	_rib = p.rib


static func enemy_color(type: int) -> Color:
	return ENEMY_COLS[clampi(type, 0, ENEMY_COLS.size() - 1)]


static func echo_color(echo_index: int) -> Color:
	return ECHO_COLS[echo_index % ECHO_COLS.size()]


## Echo k keeps its colour for the whole wave; live lights are warm white.
func light_color(light_id: int) -> Color:
	if sim and light_id < sim.echoes.size():
		return echo_color(light_id)
	return LIVE_COL


## Ghost type symbol shared by field anchors and the HUD timeline:
## normal = triangle, twins = two triangles, armored = square; ink outlined.
static func draw_type_symbol(ci: CanvasItem, pos: Vector2, type: int, size: float, angle := 0.0) -> void:
	var c := enemy_color(type)
	var shapes: Array[PackedVector2Array] = []
	match type:
		EchoSim.Type.TWIN:
			for dx in [-0.42, 0.42]:
				shapes.append(_triangle(pos, size * 0.62, angle, Vector2(dx * size, 0).rotated(angle)))
		EchoSim.Type.ARMOR:
			var h := size * 0.45
			var sq := PackedVector2Array([Vector2(-h, -h), Vector2(h, -h), Vector2(h, h), Vector2(-h, h)])
			for i in sq.size():
				sq[i] = pos + sq[i].rotated(angle)
			shapes.append(sq)
		_:
			shapes.append(_triangle(pos, size, angle, Vector2.ZERO))
	for s in shapes:
		ci.draw_colored_polygon(s, c)
		ci.draw_polyline(s + PackedVector2Array([s[0]]), INK, 2.0, true)


static func _triangle(pos: Vector2, size: float, angle: float, offset: Vector2) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in 3:
		var a := angle + TAU * k / 3.0
		pts.append(pos + offset + Vector2.from_angle(a) * size * 0.55)
	return pts


# --- effect triggers (called by EchoGame) ------------------------------------------

func popup(pos: Vector2, text: String, color: Color, size := 30, life := 1.2) -> void:
	popups.append({"pos": pos, "text": text, "age": 0.0, "color": color, "size": size, "life": life})


## A short label that rides with a light (by id) instead of floating up, so
## "Dein Echo" stays on the echo it names.
func light_label(light_id: int, text: String, color: Color, size := 26, life := 1.8, lift := 36.0) -> void:
	var at := _light_pos(light_id, sim.start_pos if sim else Vector2.ZERO)
	popups.append({"pos": at - Vector2(0, lift), "text": text, "age": 0.0, "color": color, "size": size,
		"life": life, "light": light_id, "lift": lift})


## Where a light is now: a live light, or an echo replaying its path.
func _light_pos(light_id: int, fallback: Vector2) -> Vector2:
	if sim == null or sim.state != "running":
		return fallback
	for l in sim.live:
		if int(l.id) == light_id:
			return l.pos
	for ec in sim.echoes:
		if int(ec.id) == light_id:
			var path: PackedVector2Array = ec.path
			return path[mini(sim.tick, path.size() - 1)]
	return fallback


func strike_flash(pos: Vector2, color: Color, is_echo: bool, light_index := -1) -> void:
	flashes.append({"pos": pos, "color": color, "age": 0.0, "big": not is_echo})
	if light_index >= 0:
		while _live_pulse.size() <= light_index:
			_live_pulse.append(0.0)
		_live_pulse[light_index] = 1.0


func ghost_destroyed(pos: Vector2, color: Color, armor: bool) -> void:
	splats.append({"pos": pos, "color": color, "age": 0.0, "r": 26.0 if armor else 22.0})
	if effects > 0.0:
		var drops := []
		for i in randi_range(2, 3):
			drops.append([Vector2.from_angle(randf() * TAU) * randf_range(16, 26), randf_range(2, 4)])
		stains.append({"pos": pos, "r": randf_range(12, 18), "age": 0.0, "drops": drops})
		if stains.size() > 30:
			stains.pop_front()


func twin_beam(a: Vector2, b: Vector2, color: Color) -> void:
	beams.append({"a": a, "b": b, "color": color, "age": 0.0})


func shockwave(pos: Vector2, color: Color, size: float) -> void:
	waves_fx.append({"pos": pos, "color": color, "age": 0.0, "size": size})


## Points travel from the lantern to the score when a wave is banked.
func fly_points(from: Vector2, count: int, color: Color) -> void:
	for i in clampi(count, 1, 14):
		fliers.append({"from": from + Vector2(randf_range(-30, 30), randf_range(-20, 20)), "to": score_anchor,
			"age": 0.0, "delay": 0.04 * i, "color": color})


func flash_enemy(id: int) -> void:
	_enemy_flash[id] = 0.25


func lantern_hit() -> void:
	_lantern_hit = 1.0
	_sway_v += (0.9 if randf() < 0.5 else -0.9) * (0.4 + 0.6 * effects)


func run_started() -> void:
	flashes.clear()
	for arr in [_live_trail, _live_pulse, _ready_pulse, _was_full]:
		arr.clear()


func wave_started() -> void:
	stains.clear()
	if sim:
		shockwave(sim.core, Color(1.0, 0.8, 0.5), 220.0)


func _process(delta: float) -> void:
	t += delta
	for p in popups:
		p.age += delta
		if p.has("light"):
			var lift := Vector2(0, float(p.lift))
			p.pos = _light_pos(int(p.light), p.pos + lift) - lift
		else:
			p.pos += Vector2(0, -36) * delta
	popups = popups.filter(func(p): return p.age < p.life)
	for arr in [flashes, splats, beams, waves_fx, fliers, stains]:
		for f in arr:
			f.age += delta
	flashes = flashes.filter(func(f): return f.age < 0.45)
	splats = splats.filter(func(f): return f.age < 0.5)
	beams = beams.filter(func(f): return f.age < 0.45)
	waves_fx = waves_fx.filter(func(f): return f.age < 0.9)
	fliers = fliers.filter(func(f): return f.age < f.delay + 0.7)
	stains = stains.filter(func(f): return f.age < 4.0)
	for id in _enemy_flash.keys():
		_enemy_flash[id] -= delta
		if _enemy_flash[id] <= 0.0:
			_enemy_flash.erase(id)
	for i in _live_pulse.size():
		_live_pulse[i] = maxf(float(_live_pulse[i]) - delta * 4.0, 0.0)
	for i in _ready_pulse.size():
		_ready_pulse[i] = maxf(float(_ready_pulse[i]) - delta / 0.15, 0.0)
	_lantern_hit = maxf(_lantern_hit - delta * 2.0, 0.0)
	# Lantern sway: damped pendulum plus a slow idle breeze.
	var target := 0.025 * sin(t * 0.9) * effects
	_sway_v += ((target - _sway) * 14.0 - _sway_v * 3.2) * delta
	_sway += _sway_v * delta
	_sway = clampf(_sway, -0.3, 0.3)
	if sim:
		for i in _flame_out.size():
			if i >= sim.core_hp and _flame_out[i] < 0.0:
				_flame_out[i] = 0.0
			elif _flame_out[i] >= 0.0:
				_flame_out[i] += delta
		_update_lights()
	var vr := get_viewport_rect()
	_sky.position = vr.position - position
	_sky.size = vr.size
	_sky_mat.set_shader_parameter("dawn", night_progress())
	_sky_mat.set_shader_parameter("time_s", t)
	_sky_mat.set_shader_parameter("screen_px", vr.size)
	queue_redraw()


func _update_lights() -> void:
	if sim.state != "running":
		_live_trail.clear()
		return
	while _live_trail.size() < sim.live.size():
		_live_trail.append(PackedVector2Array())
		_ready_pulse.append(0.0)
		_was_full.append(true)
	for k in sim.live.size():
		var tr: PackedVector2Array = _live_trail[k]
		tr.append(sim.live[k].pos)
		if tr.size() > TRAIL:
			tr.remove_at(0)
		_live_trail[k] = tr
		var full := sim.charge_of(sim.live[k]) >= 1.0
		if full and not _was_full[k]:
			_ready_pulse[k] = 1.0
		_was_full[k] = full


## 0 at the first wave, 0.87 in the last; the full dawn is the reward on the
## results screen. Keeps the field dark enough for the ghosts' rims.
func night_progress() -> float:
	if sim == null:
		return 0.0
	if sim.state == "over" and sim.stats.dawn:
		return 1.0
	var waves := float(sim.waves_per_round())
	var inner := float(sim.tick) / sim.run_ticks() if sim.state == "running" else 0.0
	return clampf((sim.wave_index + inner * 0.3) / waves, 0.0, 1.0) * 0.87


func _draw() -> void:
	_draw_skyline()
	if sim == null:
		return
	_draw_stains()
	_draw_routes()
	_draw_echo_guides()
	_draw_shockwaves()
	_draw_lantern()
	_draw_enemies()
	_draw_splats()
	_draw_beams()
	_draw_echo_lights()
	_draw_start_ring()
	_draw_live_lights()
	_draw_flashes()
	_draw_fliers()
	_draw_popups()


## Cut-paper stage: hard offset shadow, flat layer, 2 px cut edge on the top
## contour (the back edge warms up at dawn), lit windows with a window cross.
func _draw_skyline() -> void:
	var tones := [Color("#1a1838"), Color("#131130"), Color("#0b0a22")]
	var edges := [Color("#2b2756"), Color("#221f47"), Color("#17143a")]
	var dawn := night_progress()
	for i in _skyline.size():
		var poly := _skyline[i]
		if poly.size() < 3:
			continue
		draw_set_transform(Vector2(5, 7))
		draw_colored_polygon(poly, SHADOW)
		draw_set_transform(Vector2.ZERO)
		draw_colored_polygon(poly, tones[mini(i, tones.size() - 1)])
		var edge: Color = edges[mini(i, edges.size() - 1)]
		if i == 0:
			edge = edge.lerp(Color("#ff9d6b"), dawn * 0.6)
		draw_polyline(poly.slice(1, poly.size() - 1), edge, 2.0, true)
		for w in _windows[i]:
			var flick := 0.75 + 0.25 * sin(t * 1.3 + w.x * 0.07)
			var wc := Color(1.0, 0.8, 0.45, 0.28 * flick)
			draw_rect(Rect2(w - Vector2(5, 7), Vector2(10, 14)), wc)
			draw_line(w + Vector2(0, -7), w + Vector2(0, 7), tones[mini(i, tones.size() - 1)], 2.0)
			draw_line(w + Vector2(-5, 0), w + Vector2(5, 0), tones[mini(i, tones.size() - 1)], 2.0)


# --- field ------------------------------------------------------------------------

## Routes: between runs all of them (the wave repeats, so planning is fair);
## during a run only for ghosts that appear within the next two seconds.
## Edge anchors carry the ghost's type symbol, pointing at the lantern.
func _draw_routes() -> void:
	var running := sim.state == "running"
	for spec in sim.wave:
		var until := int(spec.tick) - sim.tick if running else 0
		if running and (until < 0 or until > 120):
			continue
		var c: Color = enemy_color(spec.type)
		var a := 0.18 if not running else lerpf(0.30, 0.13, float(until) / 120.0)
		var from: Vector2 = spec.from
		var dir: Vector2 = (sim.core - from).normalized()
		var len: float = from.distance_to(sim.core) - float(sim.cfg.core_radius) - 6.0
		var s := 0.0
		while s < len:
			draw_line(from + dir * s, from + dir * minf(s + 7.0, len), Color(c, a), 2.0)
			s += 14.0
		if spec.inside:
			# Ink drop warning where a ghost will rise.
			var k := 1.0 if not running else clampf(1.0 - float(until) / 60.0, 0.0, 1.0)
			draw_circle(from, 10.0 + 12.0 * k, Color(INK, 0.55))
			draw_arc(from, 12.0 + 12.0 * k, 0, TAU, 28, Color(c, 0.55), 2.0, true)
		else:
			draw_type_symbol(self, _edge_anchor(from), spec.type, 16.0, dir.angle())


func _edge_anchor(from: Vector2) -> Vector2:
	var a := sim.arena
	return Vector2(clampf(from.x, a.position.x + 12, a.end.x - 12), clampf(from.y, a.position.y + 12, a.end.y - 12))


func _draw_stains() -> void:
	for s in stains:
		var a := clampf(1.0 - float(s.age) / 4.0, 0.0, 1.0) * 0.12
		if a <= 0.0:
			continue
		draw_circle(s.pos, float(s.r), Color(INK, a))
		for d in s.drops:
			draw_circle(s.pos + (d[0] as Vector2), float(d[1]), Color(INK, a))


func _draw_lantern() -> void:
	var r := float(sim.cfg.core_radius)
	var pivot := sim.core + Vector2(0, -r * 1.3)
	# String from the top of the field, with a knot.
	var top := Vector2(pivot.x, sim.arena.position.y)
	draw_line(top, pivot, Color(0.55, 0.5, 0.6, 0.7), 2.0)
	draw_circle(top, 4.0, Color("#8a7f99"))
	var lives := sim.core_hp
	var max_lives := int(sim.cfg.core_lives)
	var warm := 0.35 + 0.65 * float(lives) / max_lives
	var flick := 1.0 + 0.05 * sin(t * 9.0) + 0.03 * sin(t * 23.0)
	# Everything below swings around the cap.
	draw_set_transform(pivot, _sway, Vector2.ONE)
	var c := Vector2(0, r * 1.3)
	var halo := r * 6.0 * warm * flick
	draw_texture_rect(_glow, Rect2(c - Vector2(halo, halo), Vector2(halo, halo) * 2.0), false, Color(1.0, 0.65, 0.3, 0.42 * warm))
	var rx := r * 1.02
	var ry := r * 1.18
	var body := _ellipse(c, rx, ry, 36)
	var paper := _paper.lerp(Color("#6b4a5c"), 1.0 - warm)
	if _lantern_hit > 0.0:
		paper = paper.lerp(UiTheme.DANGER, _lantern_hit * 0.6)
	draw_colored_polygon(body, paper)
	# Right half in shade: paper is lit from the left.
	var shade := PackedVector2Array()
	for i in 19:
		var a := lerpf(-PI * 0.5, PI * 0.5, i / 18.0)
		shade.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(shade, paper.darkened(0.12))
	# Inner glow around the flames.
	draw_texture_rect(_glow, Rect2(c + Vector2(-rx * 0.62, -ry * 0.55), Vector2(rx * 1.24, ry * 1.5)), false, Color("#fff3cf", 0.55 * warm))
	for k in [-0.62, -0.25, 0.25, 0.62]:
		var rib := PackedVector2Array()
		for i in 13:
			var a := lerpf(-PI * 0.5, PI * 0.5, i / 12.0)
			rib.append(c + Vector2(k * r * cos(a), sin(a) * r * 1.16))
		draw_polyline(rib, Color(_rib, 0.8), 2.5, true)
	draw_polyline(body + PackedVector2Array([body[0]]), Color(_rib, 0.9), 2.5, true)
	var cap := Color("#3a2b3f")
	var cap_hi := Color("#6b5570")
	draw_rect(Rect2(c + Vector2(-r * 0.55, -r * 1.3), Vector2(r * 1.1, r * 0.2)), cap)
	draw_line(c + Vector2(-r * 0.55, -r * 1.3 + 1), c + Vector2(r * 0.55, -r * 1.3 + 1), cap_hi, 2.0)
	draw_rect(Rect2(c + Vector2(-r * 0.45, r * 1.12), Vector2(r * 0.9, r * 0.18)), cap)
	draw_line(c + Vector2(-r * 0.45, r * 1.12 + 1), c + Vector2(r * 0.45, r * 1.12 + 1), cap_hi, 2.0)
	var tassel_sway := sin(t * 2.0) * 3.0 - _sway * 40.0
	draw_line(c + Vector2(0, r * 1.3), c + Vector2(tassel_sway, r * 1.75), Color("#c2413c"), 3.0)
	# Flames: one fixed slot per life. A lost life leaves a dark wick, and
	# between runs the flames a bank would cost flicker red.
	var at_risk := 0
	if sim.state == "between":
		at_risk = mini(int(sim.last_run.leaked), lives)
	for i in max_lives:
		var fp := c + Vector2((i - (max_lives - 1) * 0.5) * r * 0.55, r * 0.42)
		var out: float = _flame_out[i] if i < _flame_out.size() else -1.0
		draw_rect(Rect2(fp + Vector2(-2, -2), Vector2(4, 8)), Color("#3a2b3f"))  # wick
		if out < 0.0:
			var hw := r * 0.18
			var h := r * 0.64 * (1.0 + 0.1 * sin(t * 11.0 + i * 1.7))
			var outer := Color("#ff9a3c")
			if i >= lives - at_risk:
				outer = outer.lerp(Color("#ff5d5d"), 0.5 + 0.5 * sin(t * TAU * 3.0))
				draw_circle(fp + Vector2(0, -h - 10), 4.0, INK)
			draw_colored_polygon(PackedVector2Array([fp + Vector2(-hw, -2), fp + Vector2(0, -h), fp + Vector2(hw, -2), fp + Vector2(0, 4)]), outer)
			draw_colored_polygon(PackedVector2Array([fp + Vector2(-hw * 0.5, -2), fp + Vector2(0, -h * 0.6), fp + Vector2(hw * 0.5, -2), fp + Vector2(0, 2)]), Color("#fff3c4"))
		elif out < 1.5:
			var a := 1.0 - out / 1.5
			draw_circle(fp + Vector2(sin(out * 6.0) * 4.0, -8.0 - out * 30.0), 4.0 + out * 4.0, Color(0.6, 0.55, 0.65, 0.45 * a))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


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
		var grow := clampf(float(sim.tick - int(spec.tick)) * EchoSim.DT / SPAWN_ANIM, 0.0, 1.0)
		grow = 1.0 - pow(1.0 - grow, 3.0)
		p += Vector2(0, sin(t * 7.0 + float(spec.id)) * 1.5)  # walking bob
		# Fading ink trail behind the ghost.
		for k in range(4, 0, -1):
			var back: Variant = sim.enemy_pos_at(spec, maxi(int(spec.tick), sim.tick - k * 5))
			if back != null:
				draw_circle(back, (17.0 - k * 2.5) * grow, Color(INK, 0.28 - k * 0.05))
		var fl: float = _enemy_flash.get(spec.id, 0.0)
		var glow := 46.0 * grow
		draw_texture_rect(_glow, Rect2(p - Vector2(glow, glow), Vector2(glow, glow) * 2.0), false, Color(c, 0.35))
		var body := _ghost_shape(p, (22.0 if spec.type != EchoSim.Type.ARMOR else 25.0) * grow, float(spec.id))
		var closed := body + PackedVector2Array([body[0]])
		# Paper-theatre depth: hard offset shadow (only visible once the sky brightens).
		draw_set_transform(Vector2(4, 6))
		draw_colored_polygon(body, Color(INK, 0.25))
		draw_set_transform(Vector2.ZERO)
		draw_colored_polygon(body, INK.lerp(Color.WHITE, fl * 2.0))
		# Ink outline under the coloured rim keeps the rim readable on any sky.
		draw_polyline(closed, INK, 7.0, true)
		draw_polyline(closed, c, 3.5, true)
		if grow < 0.6:
			continue
		var look: Vector2 = (sim.core - p).normalized()
		var side := Vector2(-look.y, look.x)
		if spec.type == EchoSim.Type.TWIN:
			# One big eye: the pair shares one face.
			var ep: Vector2 = p + look * 4.0 + Vector2(0, -3)
			draw_circle(ep, 6.5, Color.WHITE)
			draw_circle(ep + look * 2.4, 3.0, INK)
		else:
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
					draw_arc(p, 32.0, a0, a0 + TAU / 6.0 * 0.8, 6, INK, 7.0, true)
					draw_arc(p, 32.0, a0, a0 + TAU / 6.0 * 0.8, 6, Color(c, 0.95), 4.0, true)
			EchoSim.Type.TWIN:
				var partner: Variant = sim._enemy_by_id(spec.twin)
				if partner != null and partner.alive and spec.id < spec.twin:
					_dashed(p, partner.pos, Color(INK, 0.8), 5.0)
					_dashed(p, partner.pos, Color(c, 0.6), 3.0)
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
		pts.append(p + Vector2(cos(a), sin(a) * 1.08) * maxf(r, 0.5) * w)
	return pts


func _dashed(a: Vector2, b: Vector2, c: Color, width: float) -> void:
	var len := a.distance_to(b)
	var dir := (b - a) / maxf(len, 0.001)
	var s := fmod(t * 30.0, 16.0)
	while s < len:
		draw_line(a + dir * s, a + dir * minf(s + 8.0, len), c, width)
		s += 16.0


## A destroyed ghost bursts: its ink body swells and thins out into a ring.
func _draw_splats() -> void:
	for s in splats:
		var k: float = float(s.age) / 0.5
		var r: float = float(s.r) * (1.0 + 0.9 * k)
		var a := 1.0 - k
		draw_circle(s.pos, r * (1.0 - k * 0.6), Color(INK, 0.55 * a))
		draw_arc(s.pos, r, 0, TAU, 28, Color(s.color, 0.8 * a), 3.0 * a + 1.0, true)


func _draw_beams() -> void:
	for b in beams:
		var k: float = float(b.age) / 0.45
		var a := 1.0 - k
		draw_line(b.a, b.b, Color(b.color, 0.5 * a), 10.0 * a + 2.0)
		draw_line(b.a, b.b, Color(1, 1, 1, 0.9 * a), 3.0)


func _draw_shockwaves() -> void:
	for w in waves_fx:
		var k: float = float(w.age) / 0.9
		var r: float = float(w.size) * (0.2 + 0.8 * (1.0 - pow(1.0 - k, 2.0)))
		draw_arc(w.pos, r, 0, TAU, 64, Color(w.color, 0.45 * (1.0 - k)), 4.0 * (1.0 - k) + 1.0, true)


# --- lights -----------------------------------------------------------------------

func _echo_alpha(k: int) -> float:
	# Older echoes step back (glow and size), but stay readable.
	var n := sim.echoes.size()
	return clampf(1.0 - 0.15 * (n - 1 - k), 0.4, 1.0)


## What an echo will do next: a dotted path for the coming second and a ring
## (with the echo's number) for every strike in the coming two seconds.
## Between runs: the newest echo's whole path and all strike rings, dimmed.
func _draw_echo_guides() -> void:
	var running := sim.state == "running"
	var at := sim.tick if running else 0
	for k in sim.echoes.size():
		var ec: Dictionary = sim.echoes[k]
		var c := echo_color(int(ec.id))
		var path: PackedVector2Array = ec.path
		if path.is_empty():
			continue
		if running:
			var j := at + 6
			while j <= mini(at + PREVIEW_TICKS, path.size() - 1):
				var f := float(j - at) / PREVIEW_TICKS
				draw_circle(path[j], lerpf(3.0, 1.5, f), Color(c, 0.55 * (1.0 - f)))
				j += 6
		elif k == sim.echoes.size() - 1 and path.size() >= 2:
			draw_polyline(_thin(path, 3), Color(c, 0.25), 2.0, true)
		for st in (ec.strikes as PackedInt32Array):
			if running and (st < at or st > at + RING_TICKS):
				continue
			var sp: Vector2 = path[mini(st, path.size() - 1)]
			var soon := clampf(1.0 - float(st - at) / 45.0, 0.0, 1.0) if running else 0.0
			var a := (0.5 + 0.5 * soon) if running else 0.5
			draw_arc(sp, 16.0 + 4.0 * soon, 0, TAU, 24, Color(INK, 0.5 * a), 6.0, true)
			draw_arc(sp, 16.0 + 4.0 * soon, 0, TAU, 24, Color(c, a), 3.0, true)
			_centered_text(sp, str(k + 1), 14, Color(c, a))


func _thin(path: PackedVector2Array, step: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in range(0, path.size(), step):
		out.append(path[i])
	out.append(path[path.size() - 1])
	return out


## Echoes are numbered discs: the number says which echo, older ones are
## smaller with less glow; the disc stays opaque so the number stays readable.
func _draw_echo_lights() -> void:
	if sim.state != "running":
		return
	for k in sim.echoes.size():
		var ec: Dictionary = sim.echoes[k]
		var path: PackedVector2Array = ec.path
		var i := mini(sim.tick, path.size() - 1)
		var p: Vector2 = path[i]
		var c := echo_color(int(ec.id))
		var a := _echo_alpha(k)
		var r := lerpf(11.0, 13.0, a)
		draw_texture_rect(_glow, Rect2(p - Vector2(34, 34), Vector2(68, 68)), false, Color(c, lerpf(0.2, 0.55, a)))
		draw_circle(p, r + 2.0, INK)
		draw_circle(p, r, Color(c, maxf(0.85, a)))
		_centered_text(p, str(k + 1), 20, INK)


func _centered_text(p: Vector2, text: String, fs: int, col: Color) -> void:
	var sz := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	draw_string(_font, p + Vector2(-sz.x * 0.5, fs * 0.36), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


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
		# How far the light is pulled towards the edge: the ring tightens.
		var pull := clampf(ready_pos.distance_to(sim.start_pos) / ring, 0.0, 1.0)
		if pull > 0.05:
			draw_arc(sim.start_pos, ring, 0, TAU, 48, Color(LIVE_COL, 0.25 + 0.5 * pull), 2.0 + 3.0 * pull, true)
		draw_texture_rect(_glow, Rect2(ready_pos - Vector2(56, 56), Vector2(112, 112)), false, Color(LIVE_GLOW, 0.75))
		draw_circle(ready_pos, 12.0, LIVE_COL)


## The player's own light is always the clearest thing on screen: full core,
## warm glow; only the ring shows the recharge, with one pulse when ready.
func _draw_live_lights() -> void:
	if sim.state != "running":
		return
	for k in sim.live.size():
		var l: Dictionary = sim.live[k]
		var p: Vector2 = l.pos
		var charge := sim.charge_of(l)
		var full := charge >= 1.0
		var pulse: float = _live_pulse[k] if k < _live_pulse.size() else 0.0
		var ready_pulse: float = _ready_pulse[k] if k < _ready_pulse.size() else 0.0
		if k < _live_trail.size():
			var tr: PackedVector2Array = _live_trail[k]
			if tr.size() >= 2:
				var cols := PackedColorArray()
				for j in tr.size():
					cols.append(Color(LIVE_GLOW, 0.5 * float(j) / (tr.size() - 1)))
				draw_polyline_colors(tr, cols, 8.0, true)
		if k < targets.size() and targets[k].distance_to(p) > 24.0:
			draw_line(p, targets[k], Color(LIVE_COL, 0.18), 2.0)
			draw_circle(targets[k], 4.0, Color(LIVE_COL, 0.3))
		var glow := (72.0 if full else 48.0) + 40.0 * pulse
		draw_texture_rect(_glow, Rect2(p - Vector2(glow, glow), Vector2(glow, glow) * 2.0), false, Color(LIVE_GLOW, 0.8 if full else 0.45))
		draw_circle(p, 12.0 + 6.0 * pulse, LIVE_COL)
		if not full:
			draw_arc(p, 22.0, 0, TAU, 32, Color(LIVE_COL, 0.2), 4.0, true)
			draw_arc(p, 22.0, -PI * 0.5, -PI * 0.5 + TAU * charge, 32, Color(LIVE_COL, 0.9), 4.0, true)
		else:
			if ready_pulse > 0.0:
				draw_arc(p, 22.0 * (1.0 + 0.3 * (1.0 - ready_pulse)), 0, TAU, 32, Color(LIVE_COL, 0.9 * ready_pulse), 4.0, true)
			draw_arc(p, float(sim.cfg.hit_radius), 0, TAU, 40, Color(LIVE_COL, 0.2), 1.5, true)


func _draw_flashes() -> void:
	for f in flashes:
		var k: float = f.age / 0.45
		var r: float = lerpf(10.0, float(sim.cfg.hit_radius) * (1.6 if f.big else 1.2), k)
		draw_arc(f.pos, r, 0, TAU, 32, Color(f.color, (1.0 - k) * 0.9), 4.0 * (1.0 - k) + 1.0, true)


func _draw_fliers() -> void:
	for f in fliers:
		var k := clampf((float(f.age) - float(f.delay)) / 0.7, 0.0, 1.0)
		if k <= 0.0:
			continue
		var e := k * k * (3.0 - 2.0 * k)
		var mid: Vector2 = (f.from + f.to) * 0.5 + Vector2(0, -120)
		var p: Vector2 = f.from.lerp(mid, e).lerp(mid.lerp(f.to, e), e)
		draw_texture_rect(_glow, Rect2(p - Vector2(18, 18), Vector2(36, 36)), false, Color(f.color, 0.9 * (1.0 - k * 0.5)))
		draw_circle(p, 4.0, Color(1, 1, 1, 0.9))


func _draw_popups() -> void:
	for p in popups:
		var life: float = p.life
		var a := clampf(1.0 - (p.age - (life - 0.5)) / 0.5, 0.0, 1.0)
		var fs: int = p.size
		var w := _font.get_string_size(p.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var pos: Vector2 = p.pos - Vector2(w * 0.5, 0)
		draw_string_outline(_font, pos, p.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 8, Color(0.03, 0.03, 0.08, 0.85 * a))
		draw_string(_font, pos, p.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(p.color, a))
