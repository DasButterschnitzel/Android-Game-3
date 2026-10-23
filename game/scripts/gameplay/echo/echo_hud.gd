class_name EchoHud
extends Control
## HUD for NACHHALL. Only what is read during a run sits in the top band:
## score (left), wave (centre), multiplier with the lights used (right) and the
## run timeline (ghost arrivals as type symbols below, echo strikes above).
## Teaching texts never appear during a run: they wait for the next break and
## are shown as a paper note above the start ring (docs/art/ART_REVIEW_0.4.md).

signal pause_pressed

const NOTE_BG := Color("#f3e6cc")
const NOTE_INK := Color("#22162e")
const NOTE_EDGE := Color("#cbb48c")

var sim: EchoSim
var game: EchoGame
var best := 0
var _shown_score := 0.0
var _score_pop := 0.0
var _pause: Button
var _note: Label
var _note_text := ""
var _note_seen := 0.0  # seconds the current note was fully visible
var _queued: Array[String] = []
var _banner := ""
var _banner_sub := ""
var _banner_alpha := 0.0
var _last_mult := 0.0
var _mult_pop := 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pause = Button.new()
	_pause.focus_mode = Control.FOCUS_NONE
	_pause.custom_minimum_size = Vector2(88, 88)
	_pause.icon = _pause_icon()
	_pause.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var box := UiTheme._box(Color(1, 1, 1, 0.10), 44)
	box.border_color = Color(1, 1, 1, 0.18)
	box.set_border_width_all(2)
	_pause.add_theme_stylebox_override("normal", box)
	var pressed := box.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(1, 1, 1, 0.2)
	_pause.add_theme_stylebox_override("pressed", pressed)
	_pause.add_theme_stylebox_override("hover", pressed)
	_pause.pressed.connect(func(): pause_pressed.emit())
	add_child(_pause)
	_note = UiTheme.label("", 26, NOTE_INK)
	_note.add_theme_font_override("font", UiTheme.FONT_MEDIUM)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var paper := UiTheme._box(NOTE_BG, 14, 18, 12)
	paper.border_color = NOTE_EDGE
	paper.border_width_bottom = 4
	paper.shadow_color = Color(0.02, 0.012, 0.047, 0.45)
	paper.shadow_size = 3
	paper.shadow_offset = Vector2(5, 7)
	_note.add_theme_stylebox_override("normal", paper)
	_note.visible = false
	_note.modulate.a = 0.0
	add_child(_note)


static func _pause_icon() -> Texture2D:
	var img := Image.create(28, 28, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	img.fill_rect(Rect2i(3, 0, 8, 28), UiTheme.TEXT)
	img.fill_rect(Rect2i(17, 0, 8, 28), UiTheme.TEXT)
	return ImageTexture.create_from_image(img)


func pause_button_rect() -> Rect2:
	return _pause.get_global_rect().grow(8)


## A teaching text. Waits for the next break if a run is in progress.
func show_hint(text: String, _seconds := 0.0) -> void:
	if text == "":
		return
	if not _queued.has(text) and _note_text != text:
		_queued.append(text)


## Text currently shown on the paper note ("" if none); for tests.
func note_text() -> String:
	return _note_text if _note.visible else ""


func wave_banner(wave: int, total: int, tag: String) -> void:
	_banner = "Welle %d von %d" % [wave + 1, total]
	_banner_sub = {"twins": "Zwillinge – beide fast gleichzeitig treffen", "armor": "Gepanzert – zwei verschiedene Lichter"}.get(tag, "")
	if wave == 0:
		_banner_sub = "Zwei Schatten, ein Licht?"


func _process(delta: float) -> void:
	# Parent is a CanvasLayer, so size from the viewport (anchors may not be resolved yet).
	# The whole HUD moves below a camera cut-out (safe area).
	var inset := SafeArea.top(get_viewport())
	position = Vector2(0, inset)
	size = get_viewport_rect().size - Vector2(0, inset)
	_pause.position = Vector2(size.x - 108, 18)
	if sim:
		var target := float(sim.score)
		if target > _shown_score + 0.5:
			_score_pop = 1.0
		_shown_score = minf(target, _shown_score + maxf(30.0, (target - _shown_score) * 8.0) * delta) if target > _shown_score else target
		var lights := sim.lights_used() if sim.state == "running" else sim.echoes.size()
		var m := sim.multiplier_for(maxi(lights, 1))
		if m != _last_mult and _last_mult != 0.0:
			_mult_pop = 1.0
		_last_mult = m
		_update_note(delta)
	_score_pop = maxf(_score_pop - delta * 3.0, 0.0)
	_mult_pop = maxf(_mult_pop - delta * 2.5, 0.0)
	queue_redraw()


## The note (and the wave banner) live above the start ring between runs and
## fade out within 0.15 s when a run starts.
func _update_note(delta: float) -> void:
	var calm := sim.state in ["ready", "between"]
	# At a break, the newest note wins: older queued ones are already outdated
	# (e.g. "how to start" once the player has started a run).
	if calm and not _queued.is_empty():
		_note_text = _queued.pop_back()
		_queued.clear()
		_note.text = _note_text
		_note_seen = 0.0
		# Fade in from zero: a label shows its new text only once it is laid out.
		_note.modulate.a = 0.0
	var show_note := calm and _note_text != ""
	_note.modulate.a = move_toward(_note.modulate.a, 1.0 if show_note else 0.0, delta / 0.15)
	_note.visible = show_note or _note.modulate.a > 0.01
	if show_note and _note.modulate.a >= 0.99:
		_note_seen += delta
	# A note counts as read after 1 s on screen; if the next run starts sooner,
	# it comes back at the following break (unless a newer note replaces it).
	if not calm and _note.modulate.a <= 0.01 and _note_seen >= 1.0:
		_note_text = ""
		_note_seen = 0.0
	var w := minf(600.0, size.x - 40.0)
	_note.custom_minimum_size = Vector2(w, 0)
	_note.size = Vector2(w, 0)
	var ring_top := sim.start_pos.y - float(sim.cfg.start_ring) - position.y
	_note.position = Vector2((size.x - w) * 0.5, ring_top - 24.0 - _note.size.y)
	var banner_on := sim.state == "ready" and _note_text == ""
	_banner_alpha = move_toward(_banner_alpha, 1.0 if banner_on else 0.0, delta / (0.3 if banner_on else 0.15))


func _draw() -> void:
	if sim == null:
		return
	var bold: Font = UiTheme.FONT_BOLD
	var med: Font = UiTheme.FONT_MEDIUM
	var shadow := Color(0.03, 0.03, 0.08, 0.7)
	# Score (left) with a small bounce when it grows.
	var sc := 58 + int(_score_pop * 10)
	draw_string_outline(bold, Vector2(28, 80), fmt(int(_shown_score)), HORIZONTAL_ALIGNMENT_LEFT, -1, sc, 8, shadow)
	draw_string(bold, Vector2(28, 80), fmt(int(_shown_score)), HORIZONTAL_ALIGNMENT_LEFT, -1, sc, UiTheme.TEXT)
	draw_string(med, Vector2(30, 110), "Best %s" % fmt(best), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, UiTheme.TEXT_DIM)
	# Wave, exactly centred.
	var cx := size.x * 0.5
	var wave_text := "Welle %d/%d" % [sim.wave_index + 1, sim.waves_per_round()]
	var ww := med.get_string_size(wave_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	draw_string(med, Vector2(cx - ww * 0.5, 48), wave_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, UiTheme.TEXT_DIM)
	var n := sim.waves_per_round()
	for i in n:
		var px := cx + (i - (n - 1) * 0.5) * 22.0
		var cur := i == sim.wave_index
		var done := i < sim.wave_index
		draw_circle(Vector2(px, 70), 7.0 if cur else 5.0, UiTheme.ACCENT if done else (UiTheme.TEXT if cur else Color(1, 1, 1, 0.22)))
	# Multiplier, right-aligned next to the pause button, and the lights of this wave.
	var right := size.x - 124.0
	var lights := sim.lights_used() if sim.state == "running" else sim.echoes.size()
	var mult := sim.multiplier_for(maxi(lights, 1))
	var mtext := "×" + EchoGame._fmt_mult(mult)
	var mfs := 44 + int(_mult_pop * 12.0)
	var mw := bold.get_string_size(mtext, HORIZONTAL_ALIGNMENT_LEFT, -1, mfs).x
	var mcol := UiTheme.ACCENT.lerp(Color.WHITE, _mult_pop * 0.6)
	draw_string_outline(bold, Vector2(right - mw, 64), mtext, HORIZONTAL_ALIGNMENT_LEFT, -1, mfs, 6, shadow)
	draw_string(bold, Vector2(right - mw, 64), mtext, HORIZONTAL_ALIGNMENT_LEFT, -1, mfs, mcol)
	var max_l := int(sim.cfg.max_lights)
	for i in max_l:
		var p := Vector2(right - (max_l - 1 - i) * 17.0 - 6.0, 88)
		if i < lights:
			var c: Color = EchoView.echo_color(i) if i < sim.echoes.size() else EchoView.LIVE_COL
			draw_circle(p, 6.0, c)
		else:
			draw_arc(p, 5.5, 0, TAU, 16, Color(1, 1, 1, 0.35), 1.5, true)
	_draw_timeline()
	_draw_state_text()
	if _banner_alpha > 0.0 and _banner != "":
		var ring_top := sim.start_pos.y - float(sim.cfg.start_ring) - position.y
		_centered(bold, _banner, ring_top - 70.0, 44, Color(UiTheme.TEXT, _banner_alpha), size.x)
		if _banner_sub != "":
			_centered(med, _banner_sub, ring_top - 32.0, 26, Color(UiTheme.ACCENT, _banner_alpha), size.x - 40)
	_draw_bank_cost()


## Run timeline: progress with a playhead, ghost arrivals as type symbols
## (one per twin pair) below, echo strikes as diamonds and own strikes as ticks above.
func _draw_timeline() -> void:
	var y := sim.arena.position.y - 16.0 - position.y
	var x0 := 28.0
	var w := size.x - 56.0
	var rt := float(sim.run_ticks())
	draw_line(Vector2(x0, y), Vector2(x0 + w, y), Color(1, 1, 1, 0.12), 8.0)
	draw_circle(Vector2(x0, y), 4.0, Color(1, 1, 1, 0.12))
	draw_circle(Vector2(x0 + w, y), 4.0, Color(1, 1, 1, 0.12))
	if sim.state == "running":
		var hx := x0 + w * sim.tick / rt
		draw_line(Vector2(x0, y), Vector2(hx, y), Color(EchoView.LIVE_COL, 0.85), 8.0)
		draw_rect(Rect2(hx - 2, y - 11, 4, 22), EchoView.LIVE_COL)
	for spec in sim.wave:
		if spec.type == EchoSim.Type.TWIN and int(spec.id) > int(spec.twin):
			continue
		var ax: float = x0 + w * minf(float(sim.arrival_tick(spec)) / rt, 1.0)
		EchoView.draw_type_symbol(self, Vector2(ax, y + 17), spec.type, 14.0, -PI * 0.5)
	for k in sim.echoes.size():
		var ec: Dictionary = sim.echoes[k]
		var c := EchoView.echo_color(int(ec.id))
		for st in (ec.strikes as PackedInt32Array):
			var sx: float = x0 + w * float(st) / rt
			var d := 6.0
			var dia := PackedVector2Array([Vector2(sx, y - 9 - d * 2), Vector2(sx + d, y - 9 - d), Vector2(sx, y - 9), Vector2(sx - d, y - 9 - d)])
			draw_colored_polygon(dia, c)
			draw_polyline(dia + PackedVector2Array([dia[0]]), EchoView.INK, 1.5, true)
	if sim.state == "running":
		for l in sim.live:
			for st in (l.strikes as PackedInt32Array):
				var sx: float = x0 + w * float(st) / rt
				draw_rect(Rect2(sx - 1.5, y - 22, 3, 14), EchoView.LIVE_COL)


## Guidance next to the start ring between runs.
func _draw_state_text() -> void:
	var med: Font = UiTheme.FONT_MEDIUM
	var y := sim.start_pos.y + float(sim.cfg.start_ring) + 44 - position.y
	match sim.state:
		"ready":
			_centered(med, "Zieh das Licht aus dem Ring", y, 26, Color(UiTheme.TEXT, 0.8), size.x)
		"between":
			if game and game._bank_timer >= 0.0:
				return
			if sim.can_run_again():
				_centered(med, "Ziehen: noch ein Licht  ×%s" % EchoGame._fmt_mult(sim.next_multiplier()), y, 26, Color(UiTheme.TEXT, 0.85), size.x)


## What banking would cost, on its own red label above the bank button.
func _draw_bank_cost() -> void:
	if game == null or not game.bank_button.visible or sim.last_run.leaked <= 0:
		return
	var r := game.bank_button.get_global_rect()
	var leaked: int = sim.last_run.leaked
	var text := "kostet %d %s" % [leaked, "Flamme" if leaked == 1 else "Flammen"]
	if leaked >= sim.core_hp:
		text += " – die Laterne erlischt"  # banking now ends the night
	var med: Font = UiTheme.FONT_MEDIUM
	var tw := med.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	var cx := r.get_center().x
	var y := r.position.y - position.y - 14.0
	var fx := cx - (tw + 26.0) * 0.5
	var flame := PackedVector2Array([Vector2(fx, y - 8), Vector2(fx + 7, y - 26), Vector2(fx + 14, y - 8), Vector2(fx + 7, y - 2)])
	draw_colored_polygon(flame, UiTheme.DANGER)
	draw_string_outline(med, Vector2(fx + 24, y - 6), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, 6, Color(0.03, 0.03, 0.08, 0.8))
	draw_string(med, Vector2(fx + 24, y - 6), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, UiTheme.DANGER)


func _centered(font: Font, text: String, y: float, fs: int, col: Color, max_w: float) -> void:
	var w := minf(font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x, max_w)
	var x := (size.x - w) * 0.5
	draw_string_outline(font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, max_w, fs, 7, Color(0.03, 0.03, 0.08, 0.8 * col.a))
	draw_string(font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, max_w, fs, col)


static func fmt(n: int) -> String:
	var s := str(n)
	var out := ""
	while s.length() > 3:
		out = "." + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return s + out
