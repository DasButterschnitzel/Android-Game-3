class_name EchoHud
extends Control
## HUD for NACHHALL. Only what is read during a run sits in the top band:
## score (left), wave (centre), multiplier with the lights used (right) and the
## run timeline (ghost arrivals as type symbols below, echo strikes above).
## Teaching texts never appear during a run: they wait for the next break and
## are shown as a paper note above the start ring (docs/art/ART_REVIEW_0.4.md).

signal pause_pressed

## Names and banner lines of the wave formations (EchoSim.wave_formation).
const FORMATION_TITLES := {"streu": "Streuung", "kette": "Ketten", "zange": "Zangen", "regen": "Regen"}
const FORMATION_HINTS := {"kette": "Kette – ein Schlag kann zwei treffen", "zange": "Zange – von beiden Seiten zugleich",
	"regen": "Regen – alle von oben"}
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
var _note_transient := false  # about this very moment ("how to start"): gone once a run starts
var _note_seen := 0.0  # seconds the current note was fully visible
var _queued: Array = []  # [text, transient], oldest first
var _was_calm := false
var _banner := ""
var _banner_sub := ""
var _banner_alpha := 0.0
var _last_mult := 0.0
var _mult_pop := 0.0
var _atlas: Texture2D
var _texts: Array = []  # queued labels, drawn last (see _draw_texts)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_atlas = ArtKit.atlas()
	_pause = Button.new()
	_pause.focus_mode = Control.FOCUS_NONE
	_pause.custom_minimum_size = Vector2(UiTheme.TOUCH_MIN, UiTheme.TOUCH_MIN)
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
## `transient` notes describe the current situation ("how to start", "one light is
## not enough") and expire when the next run starts, read or not. All others
## wait in the queue until they have been on screen for a second.
func show_hint(text: String, _seconds := 0.0, transient := false) -> void:
	if text == "" or text == _note_text:
		return
	for q in _queued:
		if q[0] == text:
			return
	_queued.append([text, transient])


## Text currently shown on the paper note ("" if none); for tests.
func note_text() -> String:
	return _note_text if _note.visible else ""


func wave_banner(wave: int, total: int, tag: String, formation := "") -> void:
	_banner = "Welle %d von %d" % [wave + 1, total]
	_banner_sub = {"twins": "Zwillinge – beide fast gleichzeitig treffen", "armor": "Gepanzert – zwei verschiedene Lichter"}.get(tag,
		FORMATION_HINTS.get(formation, ""))
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
	# At each break the newest note comes first; an unread older one waits for a
	# later break. During a long break, a read note makes room for the next.
	if calm and (not _was_calm or _note_text == "" or (_note_seen >= 1.0 and not _queued.is_empty())):
		_next_note()
	if not calm and _was_calm:
		# A run starts: situational notes are outdated now, read ones are done.
		if _note_transient or _note_seen >= 1.0:
			_note_text = ""
			_note_seen = 0.0
		_queued = _queued.filter(func(q): return not q[1])
	_was_calm = calm
	var show_note := calm and _note_text != ""
	_note.modulate.a = move_toward(_note.modulate.a, 1.0 if show_note else 0.0, delta / 0.15)
	_note.visible = show_note or _note.modulate.a > 0.01
	if show_note and _note.modulate.a >= 0.99:
		_note_seen += delta
	var w := minf(600.0, size.x - 40.0)
	_note.custom_minimum_size = Vector2(w, 0)
	_note.size = Vector2(w, 0)
	var ring_top := sim.start_pos.y - float(sim.cfg.start_ring) - position.y
	_note.position = Vector2((size.x - w) * 0.5, ring_top - 24.0 - _note.size.y)
	var banner_on := sim.state == "ready" and _note_text == ""
	_banner_alpha = move_toward(_banner_alpha, 1.0 if banner_on else 0.0, delta / (0.3 if banner_on else 0.15))


func _next_note() -> void:
	if _note_text != "" and _note_seen < 1.0 and not _note_transient:
		_queued.push_front([_note_text, false])  # unread: comes back after the newer ones
	if _queued.is_empty():
		_note_text = ""
		return
	var q: Array = _queued.pop_back()
	if q[0] != _note_text:
		_note_text = q[0]
		_note.text = _note_text
		_note_seen = 0.0
		# Fade in from zero: a label shows its new text only once it is laid out.
		_note.modulate.a = 0.0
	_note_transient = q[1]


## Drawn in three batches (Batch2D): lines and four-point primitives (timeline,
## symbols, slots, flame), then dots from the atlas, then all text grouped by size.
## Pops scale the text instead of changing its size (no new glyph caches mid-game).
func _draw() -> void:
	if sim == null:
		return
	_texts.clear()
	var bold: Font = UiTheme.FONT_BOLD
	var med: Font = UiTheme.FONT_MEDIUM
	var shadow := Color(0.03, 0.03, 0.08, 0.7)
	var cx := size.x * 0.5
	var n := sim.waves_per_round()
	var right := size.x - 124.0
	var lights := sim.lights_used() if sim.state == "running" else sim.echoes.size()
	var max_l := int(sim.cfg.max_lights)
	# 1) lines and primitives
	_draw_timeline()
	_draw_bank_cost()
	# 2) dots: waves (done, current, coming) and the lights of this wave
	for i in n:
		var px := cx + (i - (n - 1) * 0.5) * 22.0
		var cur := i == sim.wave_index
		var done := i < sim.wave_index
		_dot(Vector2(px, 70), 7.0 if cur else 5.0, UiTheme.ACCENT if done else (UiTheme.TEXT if cur else Color(1, 1, 1, 0.22)))
	for i in max_l:
		if i < lights:
			_dot(_slot_pos(i, max_l, right), 6.0, EchoView.echo_color(i) if i < sim.echoes.size() else EchoView.LIVE_COL)
		else:
			ArtKit.sprite(self, "slot", _slot_pos(i, max_l, right), 5.5, Color(1, 1, 1, 0.35))
	# 3) text: score (left) with a small bounce when it grows, wave exactly centred,
	# multiplier right-aligned next to the pause button.
	_label(Vector2(28, 80), fmt(int(_shown_score)), bold, 58, UiTheme.TEXT, 8, shadow, 1.0 + _score_pop * 10.0 / 58.0)
	_label(Vector2(30, 110), "Best %s" % fmt(best), med, 22, UiTheme.TEXT_DIM)
	var wave_text := "Welle %d/%d" % [sim.wave_index + 1, n]
	var ww := med.get_string_size(wave_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	_label(Vector2(cx - ww * 0.5, 48), wave_text, med, 24, UiTheme.TEXT_DIM)
	var mtext := "×" + EchoGame._fmt_mult(sim.multiplier_for(maxi(lights, 1)))
	var mscale := 1.0 + _mult_pop * 12.0 / 44.0
	var mw := bold.get_string_size(mtext, HORIZONTAL_ALIGNMENT_LEFT, -1, 44).x * mscale
	_label(Vector2(right - mw, 64), mtext, bold, 44, UiTheme.ACCENT.lerp(Color.WHITE, _mult_pop * 0.6), 6, shadow, mscale)
	_draw_state_text()
	if _banner_alpha > 0.0 and _banner != "":
		var ring_top := sim.start_pos.y - float(sim.cfg.start_ring) - position.y
		_centered(bold, _banner, ring_top - 70.0, 44, Color(UiTheme.TEXT, _banner_alpha), size.x)
		if _banner_sub != "":
			_centered(med, _banner_sub, ring_top - 32.0, 26, Color(UiTheme.ACCENT, _banner_alpha), size.x - 40)
	_draw_texts()


func _slot_pos(i: int, max_l: int, right: float) -> Vector2:
	return Vector2(right - (max_l - 1 - i) * 17.0 - 6.0, 88)


func _dot(p: Vector2, r: float, c: Color) -> void:
	var dr: Array = ArtKit.disc_rect(p, r)
	draw_texture_rect_region(_atlas, dr[0], dr[1], c)


## Queues text; outlines are drawn first, then fills, each sorted by font and size.
func _label(pos: Vector2, text: String, font: Font, fs: int, col: Color, outline := 0, outline_col := Color(), scale := 1.0, max_w := -1.0) -> void:
	_texts.append({"pos": pos, "text": text, "font": font, "fs": fs, "col": col, "outline": outline,
		"outline_col": outline_col, "scale": scale, "max_w": max_w, "key": "%d/%d" % [font.get_instance_id(), fs]})


func _draw_texts() -> void:
	var order := _texts.duplicate()
	order.sort_custom(func(a, b): return a.key < b.key)
	for x in order:
		if int(x.outline) > 0:
			_text_cmd(x, true)
	for x in order:
		_text_cmd(x, false)
	draw_set_transform(Vector2.ZERO)


func _text_cmd(x: Dictionary, outline: bool) -> void:
	var at: Vector2 = x.pos
	var sc: float = x.scale
	if sc != 1.0:
		draw_set_transform(at, 0.0, Vector2(sc, sc))
		at = Vector2.ZERO
	if outline:
		draw_string_outline(x.font, at, x.text, HORIZONTAL_ALIGNMENT_LEFT, x.max_w, x.fs, x.outline, x.outline_col)
	else:
		draw_string(x.font, at, x.text, HORIZONTAL_ALIGNMENT_LEFT, x.max_w, x.fs, x.col)
	if sc != 1.0:
		draw_set_transform(Vector2.ZERO)


## Run timeline: progress with a playhead, ghost arrivals as type symbols
## (one per twin pair) below, echo strikes as diamonds and own strikes as ticks above.
func _draw_timeline() -> void:
	var y := sim.arena.position.y - 16.0 - position.y
	var x0 := 28.0
	var w := size.x - 56.0
	var rt := float(sim.run_ticks())
	var track := Color(1, 1, 1, 0.12)
	draw_line(Vector2(x0, y), Vector2(x0 + w, y), track, 8.0)
	Batch2D.prim_disc(self, Vector2(x0, y), 4.0, track, 8)
	Batch2D.prim_disc(self, Vector2(x0 + w, y), 4.0, track, 8)
	if sim.state == "running":
		var hx := x0 + w * sim.tick / rt
		draw_line(Vector2(x0, y), Vector2(hx, y), Color(EchoView.LIVE_COL, 0.85), 8.0)
		draw_line(Vector2(hx, y - 11), Vector2(hx, y + 11), EchoView.LIVE_COL, 4.0)
	for spec in sim.wave:
		if spec.type == EchoSim.Type.TWIN and int(spec.id) > int(spec.twin):
			continue
		var ax: float = x0 + w * minf(float(sim.arrival_tick(spec)) / rt, 1.0)
		EchoView.draw_type_symbol(self, Vector2(ax, y + 17), spec.type, 14.0, -PI * 0.5)
	for k in sim.echoes.size():
		var ec: Dictionary = sim.echoes[k]
		var c := EchoView.echo_color(int(ec.id))
		for st in (ec.strikes as PackedInt32Array):
			ArtKit.sprite(self, "diamond", Vector2(x0 + w * float(st) / rt, y - 15), 6.0, c)
	if sim.state == "running":
		for l in sim.live:
			for st in (l.strikes as PackedInt32Array):
				var sx: float = x0 + w * float(st) / rt
				draw_line(Vector2(sx, y - 22), Vector2(sx, y - 8), EchoView.LIVE_COL, 3.0)


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
	var col := UiTheme.DANGER
	draw_primitive(PackedVector2Array([Vector2(fx, y - 8), Vector2(fx + 7, y - 26), Vector2(fx + 14, y - 8), Vector2(fx + 7, y - 2)]),
		PackedColorArray([col, col, col, col]), PackedVector2Array())
	_label(Vector2(fx + 24, y - 6), text, med, 24, UiTheme.DANGER, 6, Color(0.03, 0.03, 0.08, 0.8))


func _centered(font: Font, text: String, y: float, fs: int, col: Color, max_w: float) -> void:
	var w := minf(font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x, max_w)
	_label(Vector2((size.x - w) * 0.5, y), text, font, fs, col, 7, Color(0.03, 0.03, 0.08, 0.8 * col.a), 1.0, max_w)


static func fmt(n: int) -> String:
	var s := str(n)
	var out := ""
	while s.length() > 3:
		out = "." + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return s + out
