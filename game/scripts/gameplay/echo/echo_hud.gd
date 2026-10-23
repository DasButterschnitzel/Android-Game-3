class_name EchoHud
extends Control
## HUD for NACHHALL. Everything the player reads during a run sits at the top
## edge, because the steering thumb usually covers the lower screen:
## score, wave ("hour of the night"), multiplier with the lights used, and the
## run timeline with ghost arrivals and echo strike moments.

signal pause_pressed

var sim: EchoSim
var game: EchoGame
var best := 0
var _shown_score := 0.0
var _score_pop := 0.0
var _pause: Button
var _hint_label: Label
var _hint_time := 0.0
var _banner := ""
var _banner_sub := ""
var _banner_time := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pause = Button.new()
	_pause.text = "II"
	_pause.focus_mode = Control.FOCUS_NONE
	_pause.add_theme_font_override("font", UiTheme.FONT_BOLD)
	_pause.add_theme_font_size_override("font_size", 30)
	_pause.custom_minimum_size = Vector2(76, 76)
	_pause.add_theme_stylebox_override("normal", UiTheme._box(Color(1, 1, 1, 0.08), 38))
	_pause.add_theme_stylebox_override("pressed", UiTheme._box(Color(1, 1, 1, 0.18), 38))
	_pause.add_theme_stylebox_override("hover", UiTheme._box(Color(1, 1, 1, 0.12), 38))
	_pause.pressed.connect(func(): pause_pressed.emit())
	add_child(_pause)
	_hint_label = UiTheme.label("", 27, UiTheme.TEXT, true)
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.add_theme_constant_override("outline_size", 8)
	_hint_label.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.08, 0.85))
	_hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hint_label)


func pause_button_rect() -> Rect2:
	return _pause.get_global_rect().grow(8)


## Short hint line under the HUD; "" hides it.
func show_hint(text: String, seconds := 5.0) -> void:
	_hint_label.text = text
	_hint_time = seconds if text != "" else 0.0


func wave_banner(wave: int, total: int, tag: String) -> void:
	_banner = "Welle %d von %d" % [wave + 1, total]
	_banner_sub = {"twins": "Zwillinge – beide fast gleichzeitig treffen", "armor": "Gepanzert – zwei verschiedene Lichter"}.get(tag, "")
	if wave == 0:
		_banner_sub = "Zwei Schatten, ein Licht?"
	_banner_time = 2.2


func _process(delta: float) -> void:
	# Parent is a CanvasLayer, so size from the viewport (anchors may not be resolved yet).
	size = get_viewport_rect().size
	_pause.position = Vector2(size.x - 100, 24)
	_hint_time = maxf(_hint_time - delta, 0.0)
	_hint_label.position = Vector2(30, 170)
	_hint_label.size = Vector2(size.x - 60, 0)
	_hint_label.modulate.a = clampf(_hint_time * 2.0, 0.0, 1.0)
	_banner_time = maxf(_banner_time - delta, 0.0)
	if sim:
		var target := float(sim.score)
		if target > _shown_score + 0.5:
			_score_pop = 1.0
		_shown_score = minf(target, _shown_score + maxf(30.0, (target - _shown_score) * 8.0) * delta) if target > _shown_score else target
	_score_pop = maxf(_score_pop - delta * 3.0, 0.0)
	queue_redraw()


func _draw() -> void:
	if sim == null:
		return
	var bold: Font = UiTheme.FONT_BOLD
	var med: Font = UiTheme.FONT_MEDIUM
	var x0 := 28.0
	var shadow := Color(0.03, 0.03, 0.08, 0.7)
	# Score with a small bounce when it grows.
	var sc := 58 + int(_score_pop * 10)
	draw_string_outline(bold, Vector2(x0, 80), fmt(int(_shown_score)), HORIZONTAL_ALIGNMENT_LEFT, -1, sc, 8, shadow)
	draw_string(bold, Vector2(x0, 80), fmt(int(_shown_score)), HORIZONTAL_ALIGNMENT_LEFT, -1, sc, UiTheme.TEXT)
	draw_string(med, Vector2(x0 + 2, 110), "Best %s" % fmt(best), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, UiTheme.TEXT_DIM)
	# Wave as hours of the night.
	var cx := size.x * 0.5 + 40.0
	draw_string(med, Vector2(cx - 70, 48), "Welle %d/%d" % [sim.wave_index + 1, sim.waves_per_round()], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, UiTheme.TEXT_DIM)
	for i in sim.waves_per_round():
		var done := i < sim.wave_index
		var cur := i == sim.wave_index
		draw_circle(Vector2(cx - 62 + i * 22, 66), 6.0 if cur else 4.5, UiTheme.ACCENT if done else (UiTheme.TEXT if cur else Color(1, 1, 1, 0.2)))
	# Multiplier and lights of this wave.
	var lights := sim.lights_used() if sim.state == "running" else sim.echoes.size()
	var mult := sim.multiplier_for(maxi(lights, 1))
	var mx := cx + 70
	draw_string_outline(bold, Vector2(mx, 64), "×" + EchoGame._fmt_mult(mult), HORIZONTAL_ALIGNMENT_LEFT, -1, 40, 6, shadow)
	draw_string(bold, Vector2(mx, 64), "×" + EchoGame._fmt_mult(mult), HORIZONTAL_ALIGNMENT_LEFT, -1, 40, UiTheme.ACCENT)
	var max_l := int(sim.cfg.max_lights)
	for i in max_l:
		var used := i < lights
		var c: Color = (EchoView.ECHO_COLS[i % EchoView.ECHO_COLS.size()] if i < sim.echoes.size() else EchoView.LIVE_COL) if used else Color(1, 1, 1, 0.18)
		draw_circle(Vector2(mx + 6 + i * 16, 86), 5.0, c)
	_draw_timeline()
	_draw_state_text()
	if _banner_time > 0.0:
		var a := clampf(minf(_banner_time, 2.2 - _banner_time) * 3.0, 0.0, 1.0)
		var y := sim.core.y + 160
		_centered(bold, _banner, y, 46, Color(UiTheme.TEXT, a), size.x)
		if _banner_sub != "":
			_centered(med, _banner_sub, y + 40, 26, Color(UiTheme.ACCENT, a), size.x - 40)


## Run timeline: progress, ghost arrivals (below), echo strikes (above).
func _draw_timeline() -> void:
	var y := sim.arena.position.y - 16.0
	var x0 := 28.0
	var w := size.x - 56.0
	var rt := float(sim.run_ticks())
	draw_rect(Rect2(x0, y - 3, w, 6), Color(1, 1, 1, 0.10))
	if sim.state == "running":
		draw_rect(Rect2(x0, y - 3, w * sim.tick / rt, 6), Color(EchoView.LIVE_COL, 0.8))
	for spec in sim.wave:
		var ax: float = x0 + w * minf(float(sim.arrival_tick(spec)) / rt, 1.0)
		var c := EchoView.enemy_color(spec.type)
		draw_colored_polygon(PackedVector2Array([Vector2(ax, y + 5), Vector2(ax - 5, y + 13), Vector2(ax + 5, y + 13)]), c)
	for k in sim.echoes.size():
		var ec: Dictionary = sim.echoes[k]
		var c: Color = EchoView.ECHO_COLS[ec.id % EchoView.ECHO_COLS.size()]
		for st in (ec.strikes as PackedInt32Array):
			var sx: float = x0 + w * float(st) / rt
			var d := 4.0
			draw_colored_polygon(PackedVector2Array([Vector2(sx, y - 6 - d * 2), Vector2(sx + d, y - 6 - d), Vector2(sx, y - 6), Vector2(sx - d, y - 6 - d)]), c)
	if sim.state == "running":
		for l in sim.live:
			for st in (l.strikes as PackedInt32Array):
				var sx: float = x0 + w * float(st) / rt
				draw_line(Vector2(sx, y - 14), Vector2(sx, y - 4), EchoView.LIVE_COL, 2.0)


## Guidance next to the start ring between runs.
func _draw_state_text() -> void:
	var med: Font = UiTheme.FONT_MEDIUM
	var y := sim.start_pos.y + float(sim.cfg.start_ring) + 44
	match sim.state:
		"ready":
			_centered(med, "Zieh das Licht aus dem Ring", y, 26, Color(UiTheme.TEXT, 0.8), size.x)
		"between":
			if game and game._bank_timer >= 0.0:
				return
			if sim.can_run_again():
				_centered(med, "Ziehen: noch ein Licht  ×%s" % EchoGame._fmt_mult(sim.next_multiplier()), y, 26, Color(UiTheme.TEXT, 0.85), size.x)


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
