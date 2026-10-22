extends Node2D
## SCHWARM prototype: lead a school of fish with one or two fingers.

var cfg: Dictionary
var sim: SwarmSim
var tracker: PointerTracker
var fx: SparkParticles
var score_label: Label
var info_label: Label
var hint_label: Label
var over_label: Label
var debug_overlay: TouchDebugOverlay
var best := 0
var round_index := 0
var over_time := -1.0
var seed_override := -1
var t := 0.0
var shake := 0.0
var _warnings: Array = []  # {from, to, t}

const COL_BG_TOP := Color("#04121f")
const COL_BG_BOTTOM := Color("#0a2a3a")
const COL_FISH := [Color("#7ff0ff"), Color("#ffd27f")]
const COL_PLANKTON := Color("#b8ff7a")


func _ready() -> void:
	cfg = Config.load_balance("schwarm")
	tracker = PointerTracker.new()
	add_child(tracker)
	tracker.pointer_down.connect(_on_down)
	tracker.pointer_moved.connect(_on_move)
	tracker.pointer_up.connect(_on_up)
	tracker.pointer_cancelled.connect(_on_up)
	fx = SparkParticles.new()
	fx.gravity = Vector2(0, -20)
	add_child(fx)
	var layer := CanvasLayer.new()
	add_child(layer)
	score_label = _label(layer, Vector2(24, 28), 44)
	info_label = _label(layer, Vector2(24, 82), 26)
	hint_label = _label(layer, Vector2.ZERO, 34)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	over_label = _label(layer, Vector2.ZERO, 40)
	over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
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
	_new_round()


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


func _new_round() -> void:
	round_index += 1
	var seed_value := seed_override + round_index if seed_override >= 0 else Time.get_ticks_usec() + round_index
	sim = SwarmSim.new(cfg, arena(), seed_value)
	sim.fish_eaten.connect(func(p):
		fx.emit_burst(p, 14, Color(1, 0.4, 0.4), 40, 160, 0.5, 3.0)
		shake = maxf(shake, 3.0))
	sim.fish_joined.connect(func(p): fx.emit_burst(p, 8, COL_FISH[0], 20, 90, 0.5, 2.5))
	sim.plankton_bitten.connect(func(p): fx.emit_burst(p, 2, COL_PLANKTON, 10, 60, 0.4, 2.0))
	sim.predator_warned.connect(func(_k, from, to): _warnings.append({"from": from, "to": to, "t": 0.0}))
	sim.game_over.connect(_on_game_over)
	over_label.visible = false
	over_time = -1.0
	hint_label.text = "Berühren und führen"
	hint_label.visible = true


func _physics_process(delta: float) -> void:
	sim.step(delta)


func _process(delta: float) -> void:
	t += delta
	shake = maxf(shake - delta * 30.0, 0.0)
	for w in _warnings:
		w.t += delta
	_warnings = _warnings.filter(func(w): return w.t < cfg.pike_warning + 0.6)
	score_label.text = "%d" % sim.score
	info_label.text = "Fische %d   Zeit %d s" % [sim.fish_count(), int(sim.time)]
	var vr := get_viewport_rect()
	hint_label.position = Vector2(0, vr.size.y * 0.45)
	hint_label.size = Vector2(vr.size.x, 60)
	over_label.position = Vector2(0, vr.size.y * 0.35)
	over_label.size = Vector2(vr.size.x, 300)
	if sim.time > 2.5 and hint_label.text == "Berühren und führen":
		hint_label.visible = false
	if sim.time > 14.0 and sim.time < 20.0 and sim.stats.splits == 0:
		hint_label.text = "Zwei Finger teilen den Schwarm"
		hint_label.visible = true
	elif hint_label.text == "Zwei Finger teilen den Schwarm" and (sim.stats.splits > 0 or sim.time >= 20.0):
		hint_label.visible = false
	position = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake
	queue_redraw()


func _draw() -> void:
	var vr := get_viewport_rect()
	draw_polygon(PackedVector2Array([vr.position, Vector2(vr.end.x, vr.position.y), vr.end, Vector2(vr.position.x, vr.end.y)]),
		PackedColorArray([COL_BG_TOP, COL_BG_TOP, COL_BG_BOTTOM, COL_BG_BOTTOM]))
	for pl in sim.plankton:
		var k: float = float(pl.left) / pl.max
		for j in 9:
			var a := j * 0.7 + t * 0.6
			var off: Vector2 = Vector2(cos(a * 1.3), sin(a)) * pl.r * 0.6 * (0.4 + 0.6 * k)
			draw_circle(pl.pos + off, 3.0 + 2.0 * k, Color(COL_PLANKTON, 0.8))
	for w in _warnings:
		var a := clampf(1.0 - w.t / (cfg.pike_warning + 0.6), 0.0, 1.0)
		draw_line(w.from, w.to, Color(1, 0.3, 0.3, 0.35 * a), 26.0)
	for pr in sim.predators:
		if pr.state != "active":
			continue
		if pr.kind == SwarmSim.Pred.PIKE:
			var d: Vector2 = pr.vel.normalized()
			draw_colored_polygon(PackedVector2Array([pr.pos + d * 50, pr.pos + d.orthogonal() * 16 - d * 30, pr.pos - d * 70, pr.pos - d.orthogonal() * 16 - d * 30]), Color("#1a0d14"))
			draw_circle(pr.pos + d * 30 + d.orthogonal() * 6, 4, Color(1, 0.3, 0.3))
		else:
			draw_circle(pr.pos, cfg.jelly_radius, Color(0.9, 0.5, 1.0, 0.35))
			for j in 5:
				var x := (j - 2) * 10.0
				draw_line(pr.pos + Vector2(x, 10), pr.pos + Vector2(x + sin(t * 3 + j) * 6, 60), Color(0.9, 0.5, 1.0, 0.4), 2.0)
	for i in sim.pos.size():
		var p := sim.pos[i]
		var v := sim.vel[i]
		var d := v.normalized() if v.length() > 1.0 else Vector2.UP
		var c: Color = COL_FISH[clampi(sim.group[i], 0, 1)]
		draw_circle(p, 9, Color(c, 0.15))
		draw_colored_polygon(PackedVector2Array([p + d * 9, p + d.orthogonal() * 4, p - d * 8, p - d.orthogonal() * 4]), c)
	for id in sim.attractors:
		var a: Vector2 = sim.attractors[id]
		draw_arc(a, 28 + 4 * sin(t * 5), 0, TAU, 32, Color(1, 1, 1, 0.35), 2.0, true)


func _on_down(p: PointerTracker.Pointer) -> void:
	if sim.over:
		if over_time >= 0.0 and Time.get_ticks_msec() / 1000.0 - over_time > 0.8:
			_new_round()
		return
	sim.set_attractor(p.id, p.pos)


func _on_move(p: PointerTracker.Pointer) -> void:
	sim.set_attractor(p.id, p.pos)


func _on_up(p: PointerTracker.Pointer) -> void:
	sim.clear_attractor(p.id)


func _on_game_over(score: int) -> void:
	best = maxi(best, score)
	over_time = Time.get_ticks_msec() / 1000.0
	over_label.text = "Gefressen!\n%d Punkte\nBestwert %d\nmax. Schwarm %d · Zeit %d s\n\nTippen für neue Runde" % [score, best, sim.stats.max_fish, int(sim.time)]
	over_label.visible = true
	tracker.cancel_all()
