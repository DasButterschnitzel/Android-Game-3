extends Node2D
## ECHO prototype: defend the core in 8-second runs together with your echoes.
## Relative control: drag anywhere, the light moves by the finger's motion.

var cfg: Dictionary
var sim: EchoSim
var tracker: PointerTracker
var fx: SparkParticles
var score_label: Label
var info_label: Label
var center_label: Label
var bank_button: Button
var debug_overlay: TouchDebugOverlay
var seed_override := -1
var round_index := 0
var best := 0
var t := 0.0
var _pending := [Vector2.ZERO, Vector2.ZERO]
var _light_pointer := {}  # pointer id -> live light index
var _start_travel := 0.0

const ECHO_COLS := [Color("#7fd6ff"), Color("#a6ff9e"), Color("#ffd27f"), Color("#ff9ed8"), Color("#c3a6ff"), Color("#9effe8")]
const COL_BG_TOP := Color("#07101f")
const COL_BG_BOTTOM := Color("#122340")


func _ready() -> void:
	cfg = Config.load_balance("echo")
	tracker = PointerTracker.new()
	add_child(tracker)
	tracker.pointer_down.connect(_on_down)
	tracker.pointer_moved.connect(_on_move)
	tracker.pointer_up.connect(_on_up)
	tracker.pointer_cancelled.connect(_on_up)
	fx = SparkParticles.new()
	fx.gravity = Vector2.ZERO
	add_child(fx)
	var layer := CanvasLayer.new()
	add_child(layer)
	score_label = _label(layer, Vector2(24, 28), 44)
	info_label = _label(layer, Vector2(24, 82), 24)
	center_label = _label(layer, Vector2.ZERO, 32)
	center_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bank_button = Button.new()
	bank_button.add_theme_font_size_override("font_size", 32)
	bank_button.focus_mode = Control.FOCUS_NONE
	bank_button.pressed.connect(func():
		if sim.state == "between":
			sim.bank()
			_after_state_change())
	layer.add_child(bank_button)
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
	return Rect2(r.position.x + 10, r.position.y + 150, r.size.x - 20, r.size.y - 170)


func _new_round() -> void:
	round_index += 1
	var seed_value := seed_override + round_index if seed_override >= 0 else Time.get_ticks_usec() + round_index
	sim = EchoSim.new(cfg, arena(), seed_value)
	sim.enemy_destroyed.connect(func(e): fx.emit_burst(e.pos, 30, _enemy_col(e.spec.type), 60, 260, 0.6, 3.5))
	sim.enemy_hit.connect(func(e): fx.emit_burst(e.pos, 8, Color.WHITE, 30, 120, 0.3, 2.5))
	sim.enemy_leaked.connect(func(e): fx.emit_burst(sim.core, 24, Color(1, 0.3, 0.3), 60, 200, 0.6, 3.0))
	sim.game_over.connect(func(score): best = maxi(best, score))
	_after_state_change()


func _after_state_change() -> void:
	var vr := get_viewport_rect()
	bank_button.visible = sim.state == "between"
	bank_button.size = Vector2(300, 96)
	bank_button.position = Vector2(vr.size.x * 0.5 - 150, vr.size.y - 170)
	if sim.state == "between":
		var pts := int(round(sim.last_run.points * sim.multiplier()))
		bank_button.text = "KASSIEREN  +%d" % pts


func _physics_process(_delta: float) -> void:
	if sim.state == "running":
		var deltas := []
		for k in sim.live_pos.size():
			deltas.append(_pending[k])
			_pending[k] = Vector2.ZERO
		sim.step(deltas)
		if sim.state != "running":
			_after_state_change()


func _process(delta: float) -> void:
	t += delta
	var vr := get_viewport_rect()
	score_label.text = "%d" % sim.score
	info_label.text = "Welle %d/%d   Lauf %d   ×%s   Kern %d" % [sim.wave_index + 1, cfg.waves_per_round, sim.run_index + 1, str(sim.multiplier()), sim.core_hp]
	center_label.position = Vector2(0, vr.size.y * 0.62)
	center_label.size = Vector2(vr.size.x, 200)
	match sim.state:
		"ready":
			center_label.text = "Ziehen startet Lauf %d" % (sim.run_index + 1) + ("\nDeine Echos helfen mit" if sim.run_index > 0 else "\nBeschütze den Kern")
		"running":
			center_label.text = ""
		"between":
			var nxt := float(cfg.run_multipliers[mini(sim.run_index + 1, cfg.run_multipliers.size() - 1)])
			center_label.text = "%d zerstört · %d entkommen\nZiehen = neuer Lauf mit Echo (×%s)" % [sim.last_run.destroyed, sim.last_run.leaked, str(nxt)]
		"over":
			center_label.text = "Kern erloschen!\n%d Punkte · Bestwert %d\nTippen für neue Runde" % [sim.score, best] if sim.core_hp <= 0 else "Nacht überstanden!\n%d Punkte · Bestwert %d\nTippen für neue Runde" % [sim.score, best]
	queue_redraw()


func _draw() -> void:
	var vr := get_viewport_rect()
	draw_polygon(PackedVector2Array([vr.position, Vector2(vr.end.x, vr.position.y), vr.end, Vector2(vr.position.x, vr.end.y)]),
		PackedColorArray([COL_BG_TOP, COL_BG_TOP, COL_BG_BOTTOM, COL_BG_BOTTOM]))
	# Timeline of the run.
	var frac := float(sim.tick) / sim.run_ticks() if sim.state == "running" else (1.0 if sim.state == "between" else 0.0)
	draw_rect(Rect2(24, 124, vr.size.x - 48, 8), Color(1, 1, 1, 0.12))
	draw_rect(Rect2(24, 124, (vr.size.x - 48) * frac, 8), Color("#ffe27a"))
	for spec in sim.wave:
		var x: float = 24 + (vr.size.x - 48) * float(spec.tick) / sim.run_ticks()
		draw_line(Vector2(x, 118), Vector2(x, 138), _enemy_col(spec.type), 2.0)
	# Enemy routes (the wave repeats every run, so routes are shown up front).
	for spec in sim.wave:
		draw_line(spec.from, sim.core, Color(_enemy_col(spec.type), 0.10), 2.0)
	# Core with remaining lives.
	draw_circle(sim.core, cfg.core_radius + 10 + 3 * sin(t * 3), Color(1, 0.85, 0.5, 0.15))
	draw_circle(sim.core, cfg.core_radius, Color("#ffd98a"))
	for i in int(cfg.core_lives):
		var a := TAU * i / float(cfg.core_lives) - PI / 2
		draw_circle(sim.core + Vector2.from_angle(a) * (cfg.core_radius + 22), 6.0, Color("#ffd98a") if i < sim.core_hp else Color(1, 1, 1, 0.15))
	# Echo trails and lights.
	var lights := sim.lights_at(sim.tick if sim.state == "running" else 0)
	var li := 0
	for r in sim.echoes.size():
		for path: PackedVector2Array in sim.echoes[r]:
			var c: Color = ECHO_COLS[r % ECHO_COLS.size()]
			draw_polyline(path, Color(c, 0.22), 2.0, true)
			if li < lights.size():
				draw_circle(lights[li], 16, Color(c, 0.25))
				draw_circle(lights[li], 8, Color(c, 0.85))
			li += 1
	# Shadows.
	for e in sim.enemies:
		if not e.alive:
			continue
		var c := _enemy_col(e.spec.type)
		draw_circle(e.pos, 18, Color(0.02, 0.02, 0.05, 0.9))
		draw_arc(e.pos, 18, 0, TAU, 24, c, 3.0, true)
		if e.spec.type == EchoSim.Type.ARMOR:
			draw_arc(e.pos, 25, 0, TAU * (1.0 - e.hitters.size() / 2.0), 24, Color.WHITE, 3.0, true)
		if e.spec.type == EchoSim.Type.TWIN:
			var partner = sim._enemy_by_id(e.spec.twin)
			if partner and partner.alive and e.spec.id < e.spec.twin:
				draw_line(e.pos, partner.pos, Color(c, 0.35), 2.0, true)
	# Live lights.
	for p in sim.live_pos:
		draw_circle(p, 26, Color(1, 0.95, 0.6, 0.18))
		draw_circle(p, 11, Color("#fff4b8"))
	if sim.state != "running":
		draw_circle(sim.start_pos, 11, Color(1, 1, 1, 0.5 + 0.3 * sin(t * 5)))


func _enemy_col(type: int) -> Color:
	match type:
		EchoSim.Type.TWIN:
			return Color("#c58bff")
		EchoSim.Type.ARMOR:
			return Color("#ff8a5c")
	return Color("#ff5d7a")


func _on_down(p: PointerTracker.Pointer) -> void:
	if sim.state == "over":
		_new_round()
		return
	if sim.state == "between" and bank_button.get_global_rect().has_point(p.pos):
		return  # the button handles it
	if _light_pointer.size() < 2:
		_light_pointer[p.id] = _light_pointer.size()
	_start_travel = 0.0


func _on_move(p: PointerTracker.Pointer) -> void:
	if not _light_pointer.has(p.id):
		return
	var d := (p.pos - p.prev_pos) * float(cfg.relative_gain)
	if sim.state == "between":
		sim.next_run()
	if sim.state == "ready":
		_start_travel += d.length()
		if _start_travel > 12.0:
			sim.begin_run(1)
			_after_state_change()
		return
	if sim.state == "running":
		var k: int = _light_pointer[p.id]
		if k < sim.live_pos.size():
			_pending[k] += d


func _on_up(p: PointerTracker.Pointer) -> void:
	_light_pointer.erase(p.id)
