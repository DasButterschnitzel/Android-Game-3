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
## Draw order; `only_layers` (profiling, tests/capture/draw_breakdown.gd) restricts drawing to some of them.
const LAYERS := ["skyline", "stains", "routes", "echo_guides", "shockwaves", "lantern", "enemies", "splats",
	"beams", "echo_lights", "start_ring", "live_lights", "flashes", "fliers", "popups"]
static var only_layers: PackedStringArray = []
static var draw_usec := 0  # profiling: script time of the last _draw

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
var _atlas: Texture2D
var _fills := Batch2D.new()
var _texts: Array = []  # deferred labels [pos, text, size, color, outline size, outline color]
# Prebuilt skyline (one triangle array); only window light and the dawn edge change per frame.
var _sky_pts := PackedVector2Array()
var _sky_cols := PackedColorArray()
var _sky_idx := PackedInt32Array()
var _sky_edge := Vector2i(-1, -1)  # vertex range of the back layer's cut edge
var _sky_lights: Array = []  # [first vertex, x] per window pane
var _sky_dawn := -1.0
var _sky_mat: ShaderMaterial
var _skyline: Array[PackedVector2Array] = []
var _windows: Array = []
var _font: Font
var _paper := PAPER  # lantern paper colours (cosmetic unlocks)
var _rib := PAPER_DARK


func _ready() -> void:
	_atlas = ArtKit.atlas()
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
	_build_skyline_mesh()


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
	# Atlas sprites with the ink outline baked in (one batch with other dots).
	var c := enemy_color(type)
	match type:
		EchoSim.Type.TWIN:
			for dx in [-0.42, 0.42]:
				ArtKit.sprite(ci, "tri", pos + Vector2(dx * size, 0).rotated(angle), size * 0.62 * 0.55, c, angle)
		EchoSim.Type.ARMOR:
			ArtKit.sprite(ci, "square", pos, size * 0.45, c, angle)
		_:
			ArtKit.sprite(ci, "tri", pos, size * 0.55, c, angle)


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
	var t0 := Time.get_ticks_usec()
	_texts.clear()
	if only_layers.is_empty():
		_draw_skyline()
		if sim != null:
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
	else:
		for layer in LAYERS:  # profiling: only the requested layers
			if only_layers.has(layer) and (sim != null or layer == "skyline"):
				call("_draw_" + layer)
	_draw_texts()
	draw_usec = Time.get_ticks_usec() - t0


# --- batching helpers (see Batch2D: fills = one triangle array, strokes = lines,
# dots and glows = rects of one atlas texture, text last) ---------------------------

func _glow_rect(r: Rect2, c: Color) -> void:
	draw_texture_rect_region(_atlas, r, ArtKit.ATLAS_GLOW, c)


func _dot(p: Vector2, r: float, c: Color) -> void:
	var dr: Array = ArtKit.disc_rect(p, r)
	draw_texture_rect_region(_atlas, dr[0], dr[1], c)


## Text is collected and drawn after everything else: one batch per size.
func _text(p: Vector2, text: String, fs: int, col: Color) -> void:
	var sz := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	_texts.append([p + Vector2(-sz.x * 0.5, fs * 0.36), text, fs, col, 0, Color()])


func _draw_texts() -> void:
	for x in _texts:
		if int(x[4]) > 0:
			draw_string_outline(_font, x[0], x[1], HORIZONTAL_ALIGNMENT_LEFT, -1, x[2], x[4], x[5])
	for x in _texts:
		draw_string(_font, x[0], x[1], HORIZONTAL_ALIGNMENT_LEFT, -1, x[2], x[3])


## Cut-paper stage, prebuilt as one triangle array per round (_build_skyline_mesh):
## each frame only the window light flickers and the back edge warms at dawn.
func _draw_skyline() -> void:
	if _sky_idx.is_empty():
		return
	var dawn := night_progress()
	if absf(dawn - _sky_dawn) > 0.004 and _sky_edge.x >= 0:
		_sky_dawn = dawn
		var ec := Color("#2b2756").lerp(Color("#ff9d6b"), dawn * 0.6)
		for v in range(_sky_edge.x, _sky_edge.y):
			_sky_cols[v] = ec
	for w in _sky_lights:
		var flick := 0.75 + 0.25 * sin(t * 1.3 + float(w[1]) * 0.07)
		var wc := Color(1.0, 0.8, 0.45, 0.28 * flick)
		var v0: int = w[0]
		for v in range(v0, v0 + 6):
			_sky_cols[v] = wc
	RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), _sky_idx, _sky_pts, _sky_cols)


## Per layer: hard offset shadow, flat paper, 2 px cut edge on the top contour,
## lit windows with a window cross. Built once per round.
func _build_skyline_mesh() -> void:
	var b := Batch2D.new()
	var tones := [Color("#1a1838"), Color("#131130"), Color("#0b0a22")]
	var edges := [Color("#2b2756"), Color("#221f47"), Color("#17143a")]
	_sky_lights.clear()
	_sky_edge = Vector2i(-1, -1)
	for i in _skyline.size():
		var poly := _skyline[i]
		if poly.size() < 3:
			continue
		var tri := Geometry2D.triangulate_polygon(poly)
		if tri.is_empty():
			continue
		var tone: Color = tones[mini(i, tones.size() - 1)]
		_add_poly(b, Transform2D(0.0, Vector2(5, 7)) * poly, tri, SHADOW)
		_add_poly(b, poly, tri, tone)
		var e0 := b.points.size()
		var top := poly.slice(1, poly.size() - 1)
		for k in top.size() - 1:
			b.band(top[k], top[k + 1], 2.0, edges[mini(i, edges.size() - 1)], 1.0)
		if i == 0:
			_sky_edge = Vector2i(e0, b.points.size())
		for w: Vector2 in _windows[i]:
			_sky_lights.append([b.points.size(), w.x])
			b.quad(w + Vector2(-5, -7), w + Vector2(5, -7), w + Vector2(5, 7), w + Vector2(-5, 7), Color(1.0, 0.8, 0.45, 0.28))
			b.band(w + Vector2(0, -7), w + Vector2(0, 7), 2.0, tone)
			b.band(w + Vector2(-5, 0), w + Vector2(5, 0), 2.0, tone)
	_sky_pts = b.points
	_sky_cols = b.colors
	_sky_idx = b.indices
	_sky_dawn = -1.0


static func _add_poly(b: Batch2D, pts: PackedVector2Array, tri: PackedInt32Array, color: Color) -> void:
	var base := b.points.size()
	b.points.append_array(pts)
	var c := PackedColorArray()
	c.resize(pts.size())
	c.fill(color)
	b.colors.append_array(c)
	for k in tri:
		b.indices.append(base + k)


# --- field ------------------------------------------------------------------------

## Routes: between runs all of them (the wave repeats, so planning is fair);
## during a run only for ghosts that appear within the next two seconds.
## Edge anchors carry the ghost's type symbol, pointing at the lantern.
func _draw_routes() -> void:
	var running := sim.state == "running"
	var anchors: Array = []  # edge symbols go out after all lines (one sprite batch)
	for spec in sim.wave:
		var until := int(spec.tick) - sim.tick if running else 0
		if running and (until < 0 or until > 120):
			continue
		var c: Color = enemy_color(spec.type)
		var a := 0.18 if not running else lerpf(0.30, 0.13, float(until) / 120.0)
		var from: Vector2 = spec.from
		var dir: Vector2 = (sim.core - from).normalized()
		var len: float = from.distance_to(sim.core) - float(sim.cfg.core_radius) - 6.0
		draw_multiline(Batch2D.dashes(from, from + dir * len, 7.0, 7.0), Color(c, a), 2.0)
		if spec.inside:
			# Ink drop warning where a ghost will rise.
			var k := 1.0 if not running else clampf(1.0 - float(until) / 60.0, 0.0, 1.0)
			Batch2D.prim_disc(self, from, 10.0 + 12.0 * k, Color(INK, 0.55), 16)
			draw_multiline(Batch2D.ring(from, 12.0 + 12.0 * k, 28, 0.5), Color(c, 0.55), 2.0, true)
		else:
			anchors.append([_edge_anchor(from), spec.type, dir.angle()])
	for an in anchors:
		draw_type_symbol(self, an[0], an[1], 16.0, an[2])


func _edge_anchor(from: Vector2) -> Vector2:
	var a := sim.arena
	return Vector2(clampf(from.x, a.position.x + 12, a.end.x - 12), clampf(from.y, a.position.y + 12, a.end.y - 12))


func _draw_stains() -> void:
	for s in stains:
		var a := clampf(1.0 - float(s.age) / 4.0, 0.0, 1.0) * 0.12
		if a <= 0.0:
			continue
		_dot(s.pos, float(s.r), Color(INK, a))
		for d in s.drops:
			_dot(s.pos + (d[0] as Vector2), float(d[1]), Color(INK, a))


func _draw_lantern() -> void:
	var r := float(sim.cfg.core_radius)
	var pivot := sim.core + Vector2(0, -r * 1.3)
	# String from the top of the field, with a knot.
	var top := Vector2(pivot.x, sim.arena.position.y)
	draw_line(top, pivot, Color(0.55, 0.5, 0.6, 0.7), 2.0)
	Batch2D.prim_disc(self, top, 4.0, Color("#8a7f99"), 8)
	var lives := sim.core_hp
	var max_lives := int(sim.cfg.core_lives)
	var warm := 0.35 + 0.65 * float(lives) / max_lives
	var flick := 1.0 + 0.05 * sin(t * 9.0) + 0.03 * sin(t * 23.0)
	# Everything below swings around the cap.
	draw_set_transform(pivot, _sway, Vector2.ONE)
	var c := Vector2(0, r * 1.3)
	var halo := r * 6.0 * warm * flick
	_glow_rect(Rect2(c - Vector2(halo, halo), Vector2(halo, halo) * 2.0), Color(1.0, 0.65, 0.3, 0.42 * warm))
	var rx := r * 1.02
	var ry := r * 1.18
	var body := _ellipse(c, rx, ry, 36)
	var paper := _paper.lerp(Color("#6b4a5c"), 1.0 - warm)
	if _lantern_hit > 0.0:
		paper = paper.lerp(UiTheme.DANGER, _lantern_hit * 0.6)
	_fills.fan(c, body, paper)
	# Right half in shade: paper is lit from the left.
	var shade := PackedVector2Array()
	for i in 19:
		var a := lerpf(-PI * 0.5, PI * 0.5, i / 18.0)
		shade.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	_fills.fan(c, shade, paper.darkened(0.12))
	_fills.flush(self)
	# Inner glow around the flames.
	_glow_rect(Rect2(c + Vector2(-rx * 0.62, -ry * 0.55), Vector2(rx * 1.24, ry * 1.5)), Color("#fff3cf", 0.55 * warm))
	var ribs := PackedVector2Array()
	for k in [-0.62, -0.25, 0.25, 0.62]:
		var rib := PackedVector2Array()
		for i in 9:
			var a := lerpf(-PI * 0.5, PI * 0.5, i / 8.0)
			rib.append(c + Vector2(k * r * cos(a), sin(a) * r * 1.16))
		ribs.append_array(Batch2D.path(rib, false, 0.5))
	draw_multiline(ribs, Color(_rib, 0.8), 2.5, true)
	draw_multiline(Batch2D.path(_ellipse(c, rx, ry, 24), true, 0.5), Color(_rib, 0.9), 2.5, true)
	var cap := Color("#3a2b3f")
	var cap_hi := Color("#6b5570")
	_prim_rect(Rect2(c + Vector2(-r * 0.55, -r * 1.3), Vector2(r * 1.1, r * 0.2)), cap)
	draw_line(c + Vector2(-r * 0.55, -r * 1.3 + 1), c + Vector2(r * 0.55, -r * 1.3 + 1), cap_hi, 2.0)
	_prim_rect(Rect2(c + Vector2(-r * 0.45, r * 1.12), Vector2(r * 0.9, r * 0.18)), cap)
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
		_prim_rect(Rect2(fp + Vector2(-2, -2), Vector2(4, 8)), Color("#3a2b3f"))  # wick
		if out < 0.0:
			var hw := r * 0.18
			var h := r * 0.64 * (1.0 + 0.1 * sin(t * 11.0 + i * 1.7))
			var outer := Color("#ff9a3c")
			if i >= lives - at_risk:
				outer = outer.lerp(Color("#ff5d5d"), 0.5 + 0.5 * sin(t * TAU * 3.0))
				Batch2D.prim_disc(self, fp + Vector2(0, -h - 10), 4.0, INK, 8)
			_prim_quad(fp + Vector2(-hw, -2), fp + Vector2(0, -h), fp + Vector2(hw, -2), fp + Vector2(0, 4), outer)
			_prim_quad(fp + Vector2(-hw * 0.5, -2), fp + Vector2(0, -h * 0.6), fp + Vector2(hw * 0.5, -2), fp + Vector2(0, 2), Color("#fff3c4"))
		elif out < 1.5:
			var a := 1.0 - out / 1.5
			Batch2D.prim_disc(self, fp + Vector2(sin(out * 6.0) * 4.0, -8.0 - out * 30.0), 4.0 + out * 4.0, Color(0.6, 0.55, 0.65, 0.45 * a), 12)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Four-point primitives stay inside the current line batch (draw_rect would not).
func _prim_quad(a: Vector2, b: Vector2, c: Vector2, d: Vector2, col: Color) -> void:
	draw_primitive(PackedVector2Array([a, b, c, d]), PackedColorArray([col, col, col, col]), PackedVector2Array())


func _prim_rect(r: Rect2, col: Color) -> void:
	_prim_quad(r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y), col)


func _ellipse(c: Vector2, rx: float, ry: float, n: int) -> PackedVector2Array:
	return Transform2D(0.0, Vector2(rx, ry), 0.0, c) * Batch2D.unit_circle(n)


## Ghosts in four batches: trails and glows (sprites), shadows, ink outlines and
## bodies (one triangle array), rims and twin threads (lines), plates and eyes (sprites).
func _draw_enemies() -> void:
	if sim.state != "running":
		return
	var shown: Array = []  # [enemy, drawn position, grow]
	for e in sim.enemies:
		if not e.alive:
			continue
		var spec: Dictionary = e.spec
		var grow := clampf(float(sim.tick - int(spec.tick)) * EchoSim.DT / SPAWN_ANIM, 0.0, 1.0)
		grow = 1.0 - pow(1.0 - grow, 3.0)
		var p: Vector2 = (e.pos as Vector2) + Vector2(0, sin(t * 7.0 + float(spec.id)) * 1.5)  # walking bob
		shown.append([e, p, grow])
	if shown.is_empty():
		return
	for s in shown:
		var spec: Dictionary = s[0].spec
		var grow: float = s[2]
		# Fading ink trail behind the ghost.
		for k in range(4, 0, -1):
			var back: Variant = sim.enemy_pos_at(spec, maxi(int(spec.tick), sim.tick - k * 5))
			if back != null:
				_dot(back, (17.0 - k * 2.5) * grow, Color(INK, 0.28 - k * 0.05))
		var glow := 46.0 * grow
		_glow_rect(Rect2((s[1] as Vector2) - Vector2(glow, glow), Vector2(glow, glow) * 2.0), Color(enemy_color(spec.type), 0.35))
	var bodies: Array[PackedVector2Array] = []
	for s in shown:
		var spec: Dictionary = s[0].spec
		var p: Vector2 = s[1]
		var body := _ghost_shape(p, (22.0 if spec.type != EchoSim.Type.ARMOR else 25.0) * float(s[2]), float(spec.id))
		bodies.append(body)
		# Paper-theatre depth: hard offset shadow (only visible once the sky brightens).
		_fills.fan(p + Vector2(4, 6), Transform2D(0.0, Vector2(4, 6)) * body, Color(INK, 0.25))
		# Ink outline: the blob grown by 3.5 px keeps the coloured rim readable on any sky.
		var ink := PackedVector2Array()
		for q in body:
			ink.append(q + (q - p).normalized() * 3.5)
		_fills.fan(p, ink, INK)
		var fl: float = _enemy_flash.get(spec.id, 0.0)
		_fills.fan(p, body, INK.lerp(Color.WHITE, fl * 2.0))
	_fills.flush(self)
	var window := sim.twin_window_ticks()
	for i in shown.size():
		var e: Dictionary = shown[i][0]
		var spec: Dictionary = e.spec
		var p: Vector2 = shown[i][1]
		var c := enemy_color(spec.type)
		draw_multiline(Batch2D.path(bodies[i], true), c, 3.5, true)
		if float(shown[i][2]) < 0.6:
			continue
		match spec.type:
			EchoSim.Type.TWIN:
				var partner: Variant = sim._enemy_by_id(spec.twin)
				if partner != null and partner.alive and spec.id < spec.twin:
					var thread := Batch2D.dashes(p, partner.pos, 8.0, 8.0, fmod(t * 30.0, 16.0))
					draw_multiline(thread, Color(INK, 0.8), 5.0)
					draw_multiline(thread, Color(c, 0.6), 3.0)
				# Countdown ring: the partner was just hit, strike me now!
				if partner != null and partner.alive and int(partner.hit_tick) >= 0:
					var left := window - (sim.tick - int(partner.hit_tick))
					if left > 0:
						var f := float(left) / window
						draw_multiline(Batch2D.arc(p, 32.0, -PI * 0.5, -PI * 0.5 + TAU * f, 32), Color.WHITE, 4.0, true)
	for s in shown:
		if float(s[2]) < 0.6:
			continue
		var spec: Dictionary = s[0].spec
		var p: Vector2 = s[1]
		if spec.type == EchoSim.Type.ARMOR:
			# Plate ring (half of it after the first hit), ink-backed sprite.
			ArtKit.sprite(self, "plates3" if s[0].hitters.size() >= 1 else "plates", p, 32.0, Color(enemy_color(spec.type), 0.95), t * 0.6)
		var look: Vector2 = (sim.core - p).normalized()
		var side := Vector2(-look.y, look.x)
		if spec.type == EchoSim.Type.TWIN:
			# One big eye: the pair shares one face.
			var ep: Vector2 = p + look * 4.0 + Vector2(0, -3)
			_dot(ep, 6.5, Color.WHITE)
			_dot(ep + look * 2.4, 3.0, INK)
		else:
			for sg in [-1.0, 1.0]:
				var ep: Vector2 = p + look * 6.0 + side * sg * 7.0 + Vector2(0, -3)
				_dot(ep, 4.2, Color.WHITE)
				_dot(ep + look * 1.6, 2.0, INK)


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


## A destroyed ghost bursts: its ink body swells and thins out into a ring.
func _draw_splats() -> void:
	if splats.is_empty():
		return
	for s in splats:
		var k: float = float(s.age) / 0.5
		var r: float = float(s.r) * (1.0 + 0.9 * k)
		_fills.disc(s.pos, r * (1.0 - k * 0.6), Color(INK, 0.55 * (1.0 - k)), 20)
	_fills.flush(self)
	for s in splats:
		var k: float = float(s.age) / 0.5
		var r: float = float(s.r) * (1.0 + 0.9 * k)
		var a := 1.0 - k
		draw_multiline(Batch2D.ring(s.pos, r, 28, 0.5), Color(s.color, 0.8 * a), 3.0 * a + 1.0, true)


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
		draw_multiline(Batch2D.ring(w.pos, r, 48, 0.5), Color(w.color, 0.45 * (1.0 - k)), 4.0 * (1.0 - k) + 1.0, true)


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
	if running:
		for k in sim.echoes.size():
			var ec: Dictionary = sim.echoes[k]
			var c := echo_color(int(ec.id))
			var path: PackedVector2Array = ec.path
			var j := at + 6
			while j <= mini(at + PREVIEW_TICKS, path.size() - 1):
				var f := float(j - at) / PREVIEW_TICKS
				_dot(path[j], lerpf(3.0, 1.5, f), Color(c, 0.55 * (1.0 - f)))
				j += 6
	for k in sim.echoes.size():
		var ec: Dictionary = sim.echoes[k]
		var c := echo_color(int(ec.id))
		var path: PackedVector2Array = ec.path
		if path.is_empty():
			continue
		if not running and k == sim.echoes.size() - 1 and path.size() >= 2:
			draw_multiline(Batch2D.path(_thin(path, 3), false, 0.5), Color(c, 0.25), 2.0, true)
		for st in (ec.strikes as PackedInt32Array):
			if running and (st < at or st > at + RING_TICKS):
				continue
			var sp: Vector2 = path[mini(st, path.size() - 1)]
			var soon := clampf(1.0 - float(st - at) / 45.0, 0.0, 1.0) if running else 0.0
			var a := (0.5 + 0.5 * soon) if running else 0.5
			# Ink halo under a coloured ring, baked into one atlas sprite.
			ArtKit.sprite(self, "guide", sp, 16.0 + 4.0 * soon, Color(c, a))
			_text(sp, str(k + 1), 14, Color(c, a))


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
		var p: Vector2 = path[mini(sim.tick, path.size() - 1)]
		var c := echo_color(int(ec.id))
		var a := _echo_alpha(k)
		var r := lerpf(11.0, 13.0, a)
		_glow_rect(Rect2(p - Vector2(34, 34), Vector2(68, 68)), Color(c, lerpf(0.2, 0.55, a)))
		_dot(p, r + 2.0, INK)
		_dot(p, r, Color(c, maxf(0.85, a)))
		_text(p, str(k + 1), 20, INK)


func _draw_start_ring() -> void:
	if sim.state == "running" or sim.state == "over":
		return
	var ring := float(sim.cfg.start_ring)
	var pulse := 0.5 + 0.5 * sin(t * 4.0)
	var ok := sim.state == "ready" or sim.can_run_again()
	var c := Color(LIVE_COL, 0.35 + 0.35 * pulse) if ok else Color(1, 1, 1, 0.15)
	ArtKit.sprite(self, "dashring", sim.start_pos, ring, c, t * 0.4)  # 16 turning dashes
	if ok:
		# How far the light is pulled towards the edge: the ring tightens.
		var pull := clampf(ready_pos.distance_to(sim.start_pos) / ring, 0.0, 1.0)
		if pull > 0.05:
			draw_multiline(Batch2D.ring(sim.start_pos, ring, 48, 0.5), Color(LIVE_COL, 0.25 + 0.5 * pull), 2.0 + 3.0 * pull, true)
		_glow_rect(Rect2(ready_pos - Vector2(56, 56), Vector2(112, 112)), Color(LIVE_GLOW, 0.75))
		_dot(ready_pos, 12.0, LIVE_COL)


## The player's own light is always the clearest thing on screen: full core,
## warm glow; only the ring shows the recharge, with one pulse when ready.
func _draw_live_lights() -> void:
	if sim.state != "running":
		return
	for k in sim.live.size():
		var l: Dictionary = sim.live[k]
		var p: Vector2 = l.pos
		if k < _live_trail.size():
			var tr: PackedVector2Array = _live_trail[k]
			if tr.size() >= 2:
				var cols := PackedColorArray()
				for j in tr.size() - 1:
					cols.append(Color(LIVE_GLOW, 0.5 * float(j + 1) / (tr.size() - 1)))
				draw_multiline_colors(Batch2D.path(tr, false, 0.5), cols, 8.0, true)
		if k < targets.size() and targets[k].distance_to(p) > 24.0:
			draw_line(p, targets[k], Color(LIVE_COL, 0.18), 2.0)
			Batch2D.prim_disc(self, targets[k], 4.0, Color(LIVE_COL, 0.3), 8)
	for k in sim.live.size():
		var l: Dictionary = sim.live[k]
		var p: Vector2 = l.pos
		var full := sim.charge_of(l) >= 1.0
		var pulse: float = _live_pulse[k] if k < _live_pulse.size() else 0.0
		var glow := (72.0 if full else 48.0) + 40.0 * pulse
		_glow_rect(Rect2(p - Vector2(glow, glow), Vector2(glow, glow) * 2.0), Color(LIVE_GLOW, 0.8 if full else 0.45))
		_dot(p, 12.0 + 6.0 * pulse, LIVE_COL)
	for k in sim.live.size():
		var l: Dictionary = sim.live[k]
		var p: Vector2 = l.pos
		var charge := sim.charge_of(l)
		var ready_pulse: float = _ready_pulse[k] if k < _ready_pulse.size() else 0.0
		if charge < 1.0:
			ArtKit.sprite(self, "track", p, 22.0, Color(LIVE_COL, 0.2))
		else:
			if ready_pulse > 0.0:
				ArtKit.sprite(self, "track", p, 22.0 * (1.0 + 0.3 * (1.0 - ready_pulse)), Color(LIVE_COL, 0.9 * ready_pulse))
			ArtKit.sprite(self, "hitring", p, float(sim.cfg.hit_radius), Color(LIVE_COL, 0.2))
	for k in sim.live.size():
		var charge := sim.charge_of(sim.live[k])
		if charge < 1.0:
			var sides := maxi(4, int(24.0 * charge))
			draw_multiline(Batch2D.arc(sim.live[k].pos, 22.0, -PI * 0.5, -PI * 0.5 + TAU * charge, sides), Color(LIVE_COL, 0.9), 4.0, true)


func _draw_flashes() -> void:
	for f in flashes:
		var k: float = f.age / 0.45
		var r: float = lerpf(10.0, float(sim.cfg.hit_radius) * (1.6 if f.big else 1.2), k)
		draw_multiline(Batch2D.ring(f.pos, r, 32, 0.5), Color(f.color, (1.0 - k) * 0.9), 4.0 * (1.0 - k) + 1.0, true)


func _draw_fliers() -> void:
	for f in fliers:
		var k := clampf((float(f.age) - float(f.delay)) / 0.7, 0.0, 1.0)
		if k <= 0.0:
			continue
		var e := k * k * (3.0 - 2.0 * k)
		var mid: Vector2 = (f.from + f.to) * 0.5 + Vector2(0, -120)
		var p: Vector2 = f.from.lerp(mid, e).lerp(mid.lerp(f.to, e), e)
		_glow_rect(Rect2(p - Vector2(18, 18), Vector2(36, 36)), Color(f.color, 0.9 * (1.0 - k * 0.5)))
		_dot(p, 4.0, Color(1, 1, 1, 0.9))


func _draw_popups() -> void:
	for p in popups:
		var life: float = p.life
		var a := clampf(1.0 - (p.age - (life - 0.5)) / 0.5, 0.0, 1.0)
		var fs: int = p.size
		var w := _font.get_string_size(p.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		_texts.append([(p.pos as Vector2) - Vector2(w * 0.5, 0), p.text, fs, Color(p.color, a), 8, Color(0.03, 0.03, 0.08, 0.85 * a)])
