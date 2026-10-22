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


func _ready() -> void:
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
	var a := arena()
	return Vector2(a.get_center().x, a.end.y - 70)


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
	shake = maxf(shake - delta * 30.0, 0.0)
	board.position = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake
	fx.position = board.position
	score_label.text = "%d" % sim.score
	var heat := sim.heat_level() if sim.time > cfg.spark_delay else 1
	heat_label.text = "Hitze ×%d   Tempo %d   Kette %d" % [heat, int(sim.speed()), sim.chain]
	var vr := get_viewport_rect()
	hint_label.position = Vector2(0, vr.size.y * 0.45)
	hint_label.size = Vector2(vr.size.x, 60)
	over_label.position = Vector2(0, vr.size.y * 0.35)
	over_label.size = Vector2(vr.size.x, 300)
	if sim.fuses[0].lit:
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
	if sim.grab(p.id, p.pos) < 0:
		# Show where to continue.
		for f in sim.fuses:
			if f.alive:
				board.popup(f.head() + Vector2(0, -50), "hier!", Color(1, 1, 1, 0.9), 28)


func _on_move(p: PointerTracker.Pointer) -> void:
	sim.extend(p.id, p.pos)


func _on_up(p: PointerTracker.Pointer) -> void:
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
	over_label.text = "Eingeholt!\n%d Punkte\nBestwert %d\nZündungen %d · beste Kette %d\n\nTippen für neue Runde" % [score, best, sim.ignitions, sim.best_chain]
	over_label.visible = true
	tracker.cancel_all()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if sim and sim.fuses.size() > 0 and sim.fuses[0].lit and not sim.over:
			paused = true
