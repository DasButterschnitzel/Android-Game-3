extends Node2D
## LUNTE prototype: playable core loop with placeholder visuals.

const Board := preload("res://prototypes/lunte/lunte_board.gd")

var cfg: Dictionary
var sim: FuseSim
var tracker: PointerTracker
var board: Node2D
var fx: SparkParticles
var score_label: Label
var heat_label: Label
var hint_label: Label
var over_label: Label
var debug_overlay: TouchDebugOverlay
var shake := 0.0
var best := 0
var round_index := 0
var over_time := -1.0
var paused := false
var seed_override := -1  # set by capture/demo tools for reproducible rounds
## "direct": the finger is the fuse head. "offset": the head sits above the
## fingertip so the hand does not hide it. "relative": touch anywhere, finger
## movement is applied to the head like a trackpad (no occlusion, one-handed).
var control_mode := "offset"
const MODES := ["direct", "offset", "relative"]
const MODE_NAMES := {"direct": "Direkt", "offset": "Versatz", "relative": "Relativ"}
const RELATIVE_GAIN := 1.35
const OFFSET := Vector2(0, -64)
var hud: Control
var _virtual := {}  # pointer id -> virtual head position (relative mode)
var mode_button: Button


func _ready() -> void:
	add_to_group("back_handler")
	cfg = Config.load_balance("lunte")
	tracker = PointerTracker.new()
	tracker.name = "Tracker"
	add_child(tracker)
	tracker.pointer_down.connect(_on_down)
	tracker.pointer_moved.connect(_on_move)
	tracker.pointer_up.connect(_on_up)
	tracker.pointer_cancelled.connect(_on_up)
	board = Node2D.new()
	board.set_script(Board)
	add_child(board)
	fx = SparkParticles.new()
	add_child(fx)
	_build_hud()
	_new_round()


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	score_label = _label(layer, Vector2(24, 28), 44)
	heat_label = _label(layer, Vector2(24, 82), 26)
	hint_label = _label(layer, Vector2(0, 0), 34)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	over_label = _label(layer, Vector2(0, 0), 40)
	over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	over_label.visible = false
	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.draw.connect(_draw_hud)
	layer.add_child(hud)
	debug_overlay = TouchDebugOverlay.new()
	debug_overlay.tracker_path = tracker.get_path()
	debug_overlay.visible = false
	layer.add_child(debug_overlay)
	var back := Button.new()
	back.text = "≡"
	back.add_theme_font_size_override("font_size", 34)
	back.position = Vector2(get_viewport_rect().size.x - 84, 20)
	back.size = Vector2(64, 64)
	back.focus_mode = Control.FOCUS_NONE
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://prototypes/lab.tscn"))
	layer.add_child(back)
	var dbg := Button.new()
	dbg.text = "T"
	dbg.add_theme_font_size_override("font_size", 26)
	dbg.position = Vector2(get_viewport_rect().size.x - 160, 20)
	dbg.size = Vector2(64, 64)
	dbg.focus_mode = Control.FOCUS_NONE
	dbg.pressed.connect(func(): debug_overlay.visible = not debug_overlay.visible)
	layer.add_child(dbg)
	mode_button = Button.new()
	mode_button.add_theme_font_size_override("font_size", 22)
	mode_button.position = Vector2(get_viewport_rect().size.x - 330, 20)
	mode_button.size = Vector2(160, 64)
	mode_button.focus_mode = Control.FOCUS_NONE
	mode_button.pressed.connect(_toggle_mode)
	layer.add_child(mode_button)
	_update_mode_button()


func _toggle_mode() -> void:
	control_mode = MODES[(MODES.find(control_mode) + 1) % MODES.size()]
	_update_mode_button()
	tracker.cancel_all()


func _update_mode_button() -> void:
	mode_button.text = MODE_NAMES[control_mode]


## Top HUD: spool bar (fuse left to draw) and gap bar (seconds until the fire
## reaches the head, coloured by heat). Shown at the top because the drawing
## hand usually covers the lower part of the screen.
func _draw_hud() -> void:
	if sim == null:
		return
	var w := hud.size.x
	var x0 := 24.0
	var bw := w - 48.0
	# Spool.
	var spool_frac := clampf(sim.spool / float(cfg.spool_max), 0.0, 1.0)
	var low := sim.spool < 300.0
	var spool_col := Color("#ffb347") if not low else Color(1, 0.35, 0.3, 0.6 + 0.4 * sin(Time.get_ticks_msec() / 90.0))
	hud.draw_rect(Rect2(x0, 112, bw, 10), Color(1, 1, 1, 0.12))
	hud.draw_rect(Rect2(x0, 112, bw * spool_frac, 10), spool_col)
	# Gap (0..3 s) with heat thresholds.
	var gap := minf(sim.gap_time(), 3.0) if sim.gap_time() != INF else 3.0
	var heat := sim.heat_level() if sim.time > cfg.spark_delay else 1
	var gcol: Color = [Color("#9ad1ff"), Color("#ffb347"), Color("#ff4b4b")][heat - 1]
	hud.draw_rect(Rect2(x0, 128, bw, 6), Color(1, 1, 1, 0.10))
	hud.draw_rect(Rect2(x0, 128, bw * gap / 3.0, 6), gcol)
	for t in [cfg.heat3_gap, cfg.heat2_gap]:
		hud.draw_line(Vector2(x0 + bw * t / 3.0, 124), Vector2(x0 + bw * t / 3.0, 138), Color(1, 1, 1, 0.5), 2.0)
	# Night progress: a small moon travelling along the top edge.
	var np := sim.night_progress()
	hud.draw_circle(Vector2(x0 + bw * np, 100), 5.0, Color(1, 0.95, 0.75, 0.9))


func _label(parent: Node, pos: Vector2, size: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


func arena() -> Rect2:
	var r := get_viewport_rect()
	return Rect2(r.position.x + 10, r.position.y + 130, r.size.x - 20, r.size.y - 150)


func candle_pos() -> Vector2:
	# Middle third: away from the Android home-gesture area at the bottom edge.
	var a := arena()
	return Vector2(a.get_center().x, a.position.y + a.size.y * 0.62)


func _new_round() -> void:
	round_index += 1
	var seed_value := seed_override + round_index if seed_override >= 0 else Time.get_ticks_usec() + round_index
	sim = FuseSim.new(cfg, arena(), seed_value)
	sim.firework_ignited.connect(_on_ignited)
	sim.blast.connect(_on_blast)
	sim.firework_threaded.connect(func(fw): board.popup(fw.pos + Vector2(0, -40), "✓", Color(1, 1, 1), 26))
	sim.firework_fizzled.connect(func(fw): fx.emit_burst(fw.pos, 8, Color(0.5, 0.5, 0.55), 20, 60, 0.6, 3))
	sim.junction_created.connect(func(p): fx.emit_burst(p, 6, Color(1, 0.4, 0.2), 30, 90, 0.4, 3))
	sim.fuse_ignited_by_blast.connect(func(p): board.popup(p, "!", Color(1, 0.3, 0.2), 44))
	sim.head_caught.connect(_on_caught)
	sim.branch_created.connect(func(_fid, pos):
		board.popup(pos + Vector2(0, -46), "2. Finger!", Color("#b48cff"), 30)
		fx.emit_burst(pos, 40, Color("#b48cff"), 60, 260, 0.8, 4.0))
	sim.finale_started.connect(func(n):
		if n > 0 and not sim.survived_dawn:
			hint_label.text = "FINALE!"
			hint_label.visible = true)
	sim.dawn.connect(func():
		hint_label.text = "MORGENGRAUEN!"
		hint_label.visible = true)
	sim.spool_empty.connect(func():
		board.popup(sim.fuses[0].head() + Vector2(0, -60), "Lunte leer!", Color(1, 0.5, 0.4), 30))
	sim.short_circuit.connect(func(pos, n):
		board.popup(pos + Vector2(0, -50), "KURZSCHLUSS ×%d" % n, Color(1, 0.95, 0.5), 34)
		fx.emit_burst(pos, 80, Color(1, 0.9, 0.4), 100, 420, 0.9, 4.0)
		shake = maxf(shake, 10.0))
	sim.loop_closed.connect(func(_id, n):
		if n > 0:
			board.popup(sim.fuses[0].head() + Vector2(0, -60), "Schleife: %d eingeschlossen" % n, Color(1, 0.95, 0.6), 26))
	sim.fire_jumped.connect(func(a, b):
		fx.emit_burst(b, 14, Color(1, 0.6, 0.2), 40, 160, 0.4, 3.0))
	sim.game_over.connect(_on_game_over)
	sim.start(candle_pos())
	board.sim = sim
	over_label.visible = false
	over_time = -1.0
	hint_label.text = "Zieh von der Kerze los!"
	hint_label.visible = true


func _physics_process(delta: float) -> void:
	if paused:
		return
	sim.step(delta)
	for sp in sim.sparks:
		var f := sim.fuses[sp.fuse_id]
		var i := clampi(int(sp.s), 0, f.size() - 1)
		var j := clampi(i - sp.dir, 0, f.size() - 1)
		fx.emit_trail(f.pts[i], (f.pts[j] - f.pts[i]).normalized(), Color(1, 0.6, 0.2), 1)
	for r in sim.rockets:
		fx.emit_trail(r.pos(), (r.from - r.to).normalized(), Color(1, 0.4, 0.85), 2)


func _process(delta: float) -> void:
	hud.queue_redraw()
	shake = maxf(shake - delta * 30.0, 0.0)
	board.position = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake
	fx.position = board.position
	score_label.text = "%d" % sim.score
	var heat := sim.heat_level() if sim.time > cfg.spark_delay else 1
	var heat_pts: Array = cfg.heat_points
	heat_label.text = "Hitze ×%s   Kette %d   %s" % [str(heat_pts[heat - 1]), sim.chain, MODE_NAMES[control_mode]]
	board.cursor_offset = OFFSET if control_mode == "offset" else Vector2.ZERO
	var vr := get_viewport_rect()
	hint_label.position = Vector2(0, vr.size.y * 0.45)
	hint_label.size = Vector2(vr.size.x, 60)
	over_label.position = Vector2(0, vr.size.y * 0.35)
	over_label.size = Vector2(vr.size.x, 300)
	if sim.fuses[0].lit and not sim.over:
		hint_label.visible = false
	if paused:
		hint_label.visible = true
		hint_label.text = "Pause – tippen zum Weiterspielen"


func _on_down(p: PointerTracker.Pointer) -> void:
	if paused:
		paused = false
		return
	if sim.over:
		if over_time >= 0.0 and Time.get_ticks_msec() / 1000.0 - over_time > 0.8:
			_new_round()
		return
	if control_mode == "relative":
		# Any touch takes the first free fuse; movement is applied relatively.
		var fid := sim.grab_any(p.id)
		if fid >= 0:
			_virtual[p.id] = sim.fuses[fid].head()
		return
	if sim.grab(p.id, _finger_target(p.pos)) < 0:
		# Show where to continue.
		for f in sim.fuses:
			if f.alive:
				board.popup(f.head() + Vector2(0, -50), "hier!", Color(1, 1, 1, 0.9), 28)


func _on_move(p: PointerTracker.Pointer) -> void:
	if control_mode == "relative":
		if not _virtual.has(p.id):
			return
		var a := sim.arena
		var v: Vector2 = _virtual[p.id] + (p.pos - p.prev_pos) * RELATIVE_GAIN
		v = Vector2(clampf(v.x, a.position.x, a.end.x), clampf(v.y, a.position.y, a.end.y))
		_virtual[p.id] = v
		sim.extend(p.id, v)
		return
	sim.extend(p.id, _finger_target(p.pos))


## Where the fuse head should be for a finger position (offset mode lifts it
## above the fingertip so the hand does not cover the head).
func _finger_target(pos: Vector2) -> Vector2:
	return pos + OFFSET if control_mode == "offset" else pos


func _on_up(p: PointerTracker.Pointer) -> void:
	_virtual.erase(p.id)
	sim.release(p.id)


func _on_ignited(fw: FuseSim.Firework, pts: int, heat: int, chain: int) -> void:
	var c: Color = board.KIND_COL[fw.kind]
	fx.emit_burst(fw.pos, 60, c, 120, 420, 1.1, 4.0)
	fx.emit_burst(fw.pos, 20, Color(1, 0.95, 0.8), 40, 160, 0.6, 3.0)
	var txt := "+%d" % pts
	if heat > 1:
		txt += " ×%d" % heat
	board.popup(fw.pos + Vector2(0, -30), txt, c.lerp(Color.WHITE, 0.4), 30 + heat * 4)
	if chain >= 2:
		board.popup(fw.pos + Vector2(0, 10), "Kette %d" % chain, Color(1, 0.9, 0.4), 26)
	shake = maxf(shake, 4.0 + heat * 2.0)


func _on_blast(pos: Vector2, radius: float) -> void:
	fx.emit_burst(pos, 120, Color(1, 0.35, 0.25), 200, radius * 5.0, 0.8, 5.0)
	shake = maxf(shake, 14.0)


func _on_caught(_fid: int, pos: Vector2) -> void:
	fx.emit_burst(pos, 160, Color(1, 0.7, 0.3), 100, 600, 1.2, 5.0)
	shake = 20.0


func _on_game_over(score: int) -> void:
	best = maxi(best, score)
	over_time = Time.get_ticks_msec() / 1000.0
	var title := "Morgengrauen!" if sim.survived_dawn else "Eingeholt!"
	over_label.text = "%s\n%d Punkte\nBestwert %d\nZündungen %d · beste Kette %d\n\nTippen für neue Runde" % [title, score, best, sim.ignitions, sim.best_chain]
	over_label.visible = true
	hint_label.visible = false
	tracker.cancel_all()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if sim and sim.fuses.size() > 0 and sim.fuses[0].lit and not sim.over:
			paused = true


func on_back() -> bool:
	get_tree().change_scene_to_file("res://prototypes/lab.tscn")
	return true
