class_name LunteHud
extends Control
## Top HUD for LUNTE. Everything the player must read while drawing sits at the
## top edge, because the drawing hand usually covers the lower screen.

signal pause_pressed

var sim: FuseSim
var best := 0
var _shown_score := 0.0
var _score_pop := 0.0
var _chain_show := 0.0
var _last_chain := 0
var _pause: Button


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


func pause_button_rect() -> Rect2:
	return _pause.get_global_rect()


func _process(delta: float) -> void:
	# Parent is a CanvasLayer, so size from the viewport (anchors may not be resolved yet).
	size = get_viewport_rect().size
	_pause.position = Vector2(size.x - 100, 24)
	if sim:
		var target := float(sim.score)
		if target > _shown_score:
			_score_pop = 1.0
		_shown_score = minf(target, _shown_score + maxf(12.0, (target - _shown_score) * 10.0) * delta) if target > _shown_score else target
		if sim.chain >= 2 and sim.chain != _last_chain:
			_chain_show = 1.2
		_last_chain = sim.chain
	_score_pop = maxf(_score_pop - delta * 3.0, 0.0)
	_chain_show = maxf(_chain_show - delta, 0.0)
	queue_redraw()


func _draw() -> void:
	if sim == null:
		return
	var bold: Font = UiTheme.FONT_BOLD
	var med: Font = UiTheme.FONT_MEDIUM
	var x0 := 28.0
	var w := size.x - 56.0
	# Score with a small bounce when it grows.
	var sc := 60 + int(_score_pop * 10)
	draw_string_outline(bold, Vector2(x0, 82), _fmt(int(_shown_score)), HORIZONTAL_ALIGNMENT_LEFT, -1, sc, 8, Color(0.03, 0.03, 0.08, 0.7))
	draw_string(bold, Vector2(x0, 82), _fmt(int(_shown_score)), HORIZONTAL_ALIGNMENT_LEFT, -1, sc, UiTheme.TEXT)
	draw_string(med, Vector2(x0 + 2, 114), "Best %s" % _fmt(best), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, UiTheme.TEXT_DIM)
	# Heat badge.
	var heat := sim.heat_level() if sim.sparks.size() > 0 and not sim.over else 1
	var hp: Array = sim.cfg.heat_points
	if heat > 1:
		var col: Color = LunteView.HEAT_COL[heat - 1]
		var txt := "×%s" % str(hp[heat - 1]).replace(".", ",")
		var bx := Vector2(x0 + 250, 44)
		draw_rect(Rect2(bx, Vector2(96, 44)), Color(col, 0.22), true)
		draw_string(bold, bx + Vector2(12, 34), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 32, col)
	if _chain_show > 0.0:
		var a := clampf(_chain_show, 0.0, 1.0)
		draw_string(bold, Vector2(x0 + 360, 78), "Kette %d" % sim.chain, HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color(1, 0.88, 0.45, a))
	# Spool bar ("Lunte").
	var y := 134.0
	var frac := clampf(sim.spool / float(sim.cfg.spool_max), 0.0, 1.0)
	var low := sim.spool < 300.0
	var spool_col := UiTheme.ACCENT if not low else Color(1, 0.35, 0.3, 0.6 + 0.4 * sin(Time.get_ticks_msec() / 90.0))
	draw_string(med, Vector2(x0, y + 4), "Lunte", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, UiTheme.TEXT_DIM)
	var bx0 := x0 + 70
	var bw := w - 70
	draw_rect(Rect2(bx0, y - 10, bw, 10), Color(1, 1, 1, 0.10))
	draw_rect(Rect2(bx0, y - 10, bw * frac, 10), spool_col)
	# Gap bar ("Funke"): how many seconds the fire is behind; ticks mark heat thresholds.
	var y2 := y + 24
	var g := sim.gap_time()
	var gap := 3.0 if g == INF else minf(g, 3.0)
	var gcol: Color = LunteView.HEAT_COL[heat - 1]
	draw_string(med, Vector2(x0, y2 + 4), "Funke", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, UiTheme.TEXT_DIM)
	draw_rect(Rect2(bx0, y2 - 8, bw, 6), Color(1, 1, 1, 0.08))
	draw_rect(Rect2(bx0, y2 - 8, bw * gap / 3.0, 6), gcol)
	for th in [sim.cfg.heat3_gap, sim.cfg.heat2_gap]:
		var tx: float = bx0 + bw * float(th) / 3.0
		draw_line(Vector2(tx, y2 - 12), Vector2(tx, y2 + 2), Color(1, 1, 1, 0.5), 2.0)
	# Night progress: the moon crosses the top edge; dawn at the right.
	var np := sim.night_progress()
	var mx := bx0 + bw * np
	draw_circle(Vector2(mx, 12), 6.0, Color(1, 0.95, 0.75, 0.85 * (1.0 - np * 0.6)))
	draw_line(Vector2(bx0, 12), Vector2(bx0 + bw, 12), Color(1, 1, 1, 0.06), 2.0)


static func _fmt(n: int) -> String:
	var s := str(n)
	var out := ""
	while s.length() > 3:
		out = "." + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return s + out
