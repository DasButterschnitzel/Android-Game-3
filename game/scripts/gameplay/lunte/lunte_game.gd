class_name LunteGame
extends Node2D
## LUNTE game controller: round lifecycle, input mapping, juice, persistence.
## The rules live in FuseSim; this node only connects player, sim and senses.

signal round_finished(score: int, is_best: bool)

const OFFSET := Vector2(0, -64)  # "offset" control mode: head sits above the fingertip
const RELATIVE_GAIN := 1.35

var cfg: Dictionary
var sim: FuseSim
var tracker: PointerTracker
var view: LunteView
var fx: SparkParticles
var hud: LunteHud
var audio: LunteAudio
var onboarding: Onboarding
var hint_label: Label
var debug_overlay: TouchDebugOverlay
var ui_layer: CanvasLayer

var state := "ready"  # ready | playing | paused | results
var control_mode := "offset"
var effects := 1.0
var seed_override := -1  # tests/captures: reproducible rounds
var daily := false  # same seed for everyone today
var round_index := 0
var shake := 0.0
var _virtual := {}  # pointer id -> virtual head position (relative mode)
var _hint_time := 0.0
var _overlay: Control
var _round_seed := 0


func _save() -> SaveStore:
	return get_node_or_null("/root/Save") as SaveStore


func _ready() -> void:
	add_to_group("back_handler")
	cfg = Config.load_balance("lunte")
	var save := _save()
	if save:
		control_mode = save.get_setting("control_mode")
		effects = float(save.get_setting("effects"))
		Haptics.enabled = bool(save.get_setting("haptics"))
		daily = bool(save.data.get("pending_daily", false))
	tracker = PointerTracker.new()
	tracker.name = "Tracker"
	add_child(tracker)
	tracker.pointer_down.connect(_on_down)
	tracker.pointer_moved.connect(_on_move)
	tracker.pointer_up.connect(_on_up)
	tracker.pointer_cancelled.connect(_on_up)
	view = LunteView.new()
	view.effects = effects
	add_child(view)
	fx = SparkParticles.new()
	fx.intensity = 0.4 + 0.6 * effects
	add_child(fx)
	audio = LunteAudio.new()
	add_child(audio)
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	hud = LunteHud.new()
	hud.pause_pressed.connect(pause)
	ui_layer.add_child(hud)
	hint_label = UiTheme.label("", 28, UiTheme.TEXT)
	hint_label.add_theme_constant_override("outline_size", 8)
	hint_label.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.08, 0.85))
	ui_layer.add_child(hint_label)
	debug_overlay = TouchDebugOverlay.new()
	debug_overlay.tracker_path = tracker.get_path()
	debug_overlay.visible = save != null and bool(save.get_setting("touch_debug"))
	ui_layer.add_child(debug_overlay)
	onboarding = Onboarding.new(save)
	onboarding.hint.connect(_show_hint)
	new_round()


func arena() -> Rect2:
	var r := get_viewport_rect()
	# Top band reserved for the HUD, bottom margin keeps strokes off the home-gesture edge.
	return Rect2(r.position.x + 16, r.position.y + 190, r.size.x - 32, r.size.y - 190 - 70)


func candle_pos() -> Vector2:
	var a := arena()
	return Vector2(a.get_center().x, a.position.y + a.size.y * 0.62)


func new_round() -> void:
	round_index += 1
	if daily:
		var d := Time.get_date_dict_from_system()
		_round_seed = d.year * 10000 + d.month * 100 + d.day
	elif seed_override >= 0:
		_round_seed = seed_override + round_index
	else:
		_round_seed = int(Time.get_unix_time_from_system()) * 1000 + round_index
	sim = FuseSim.new(cfg, arena(), _round_seed)
	var save := _save()
	var rounds_played: int = 99  # parked prototype: no first-round hints in the lab
	onboarding.watch(sim, rounds_played)
	_connect_sim()
	sim.start(candle_pos())
	view.setup(sim, _round_seed)
	hud.sim = sim
	hud.best = int(save.data.lab.lunte_best) if save else 0
	audio.attach(sim)
	fx.clear()
	_virtual.clear()
	tracker.cancel_all()
	state = "ready"
	_close_overlay()
	_show_hint("Zieh von der Kerze los!" if rounds_played < 5 else "")


func _connect_sim() -> void:
	sim.firework_ignited.connect(_on_ignited)
	sim.blast.connect(_on_blast)
	sim.firework_threaded.connect(func(fw):
		view.popup(fw.pos + Vector2(0, -44), "+", Color(1, 0.9, 0.6), 34)
		fx.emit_burst(fw.pos, 10, Color(1, 0.85, 0.5), 30, 110, 0.35, 3.0))
	sim.firework_fizzled.connect(func(fw): fx.emit_burst(fw.pos, 8, Color(0.5, 0.5, 0.6), 20, 60, 0.6, 3))
	sim.junction_created.connect(func(p): fx.emit_burst(p, 8, Color(1, 0.5, 0.2), 30, 100, 0.4, 3))
	sim.fuse_ignited_by_blast.connect(func(p): view.popup(p, "!", UiTheme.DANGER, 48))
	sim.fire_jumped.connect(func(_a, b): fx.emit_burst(b, 16, Color(1, 0.55, 0.2), 40, 180, 0.45, 3.5))
	sim.head_caught.connect(_on_caught)
	sim.spool_empty.connect(func():
		if sim.fuses[0].alive:
			view.popup(sim.fuses[0].head() + Vector2(0, -60), "Lunte leer!", Color(1, 0.55, 0.45), 30))
	sim.loop_closed.connect(func(_id, n):
		if n > 0:
			view.popup(sim.fuses[0].head() + Vector2(0, -64), "%d eingeschlossen" % n, Color(1, 0.92, 0.55), 28))
	sim.short_circuit.connect(func(pos, n):
		view.popup(pos + Vector2(0, -54), "KURZSCHLUSS ×%d" % n, Color(1, 0.95, 0.5), 36)
		fx.emit_burst(pos, 90, Color(1, 0.9, 0.45), 100, 460, 0.9, 4.5)
		_shake(10.0))
	sim.branch_created.connect(func(_fid, pos):
		view.popup(pos + Vector2(0, -50), "2. Finger!", FireworkArt.color_of(FuseSim.Kind.SPLITTER), 30)
		fx.emit_burst(pos, 40, FireworkArt.color_of(FuseSim.Kind.SPLITTER), 60, 260, 0.8, 4.0))
	sim.dawn.connect(func(): _show_hint("Morgengrauen! Alles zündet zum vollen Wert."))
	sim.finale_started.connect(func(n):
		if n > 0 and not sim.survived_dawn:
			_show_hint("Finale!"))
	sim.game_over.connect(_on_game_over)


# --- loop -------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if state == "paused" or state == "results":
		return
	sim.step(delta)
	if sim.fuses[0].lit and state == "ready":
		state = "playing"
		_show_hint("")
	for sp in sim.sparks:
		var f := sim.fuses[sp.fuse_id]
		var i := clampi(int(sp.s), 0, f.size() - 1)
		var j := clampi(i - sp.dir, 0, f.size() - 1)
		fx.emit_trail(f.pts[i], (f.pts[j] - f.pts[i]).normalized(), Color(1, 0.6, 0.2), 1)
	for r in sim.rockets:
		fx.emit_trail(r.pos(), (r.from - r.to).normalized(), Color(1, 0.45, 0.85), 2)


func _process(delta: float) -> void:
	shake = maxf(shake - delta * 30.0, 0.0)
	var off := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake
	view.position = off
	fx.position = off
	view.cursor_offset = OFFSET if control_mode == "offset" else Vector2.ZERO
	if state == "playing":
		onboarding.tick(sim)
	audio.update(delta, _drawing_speed(), state == "playing")
	_hint_time = maxf(_hint_time - delta, 0.0)
	var vr := get_viewport_rect()
	hint_label.position = Vector2(24, 200)
	hint_label.size = Vector2(vr.size.x - 48, 80)
	hint_label.modulate.a = clampf(_hint_time, 0.0, 1.0) if _hint_time < 99.0 else 1.0


func _drawing_speed() -> float:
	var v := 0.0
	for p in tracker.pointers.values():
		if sim.fuse_of_pointer(p.id) != null:
			v = maxf(v, p.velocity.length())
	return v


func _shake(amount: float) -> void:
	shake = maxf(shake, amount * effects)


func _show_hint(text: String) -> void:
	hint_label.text = text
	_hint_time = 4.0 if text != "" else 0.0
	if text != "" and state == "ready" and text.begins_with("Zieh"):
		_hint_time = 999.0  # stays until the first stroke


# --- input ------------------------------------------------------------------------

func _on_down(p: PointerTracker.Pointer) -> void:
	if state == "paused" or state == "results":
		return
	if hud.pause_button_rect().has_point(p.pos):
		return
	if control_mode == "relative":
		var fid := sim.grab_any(p.id)
		if fid >= 0:
			_virtual[p.id] = sim.fuses[fid].head()
		return
	if sim.grab(p.id, _target(p.pos)) < 0:
		for f in sim.fuses:
			if f.alive and f.pointer_id == -1:
				view.popup(f.head() + Vector2(0, -56), "hier weiter", Color(1, 1, 1, 0.9), 26)
				break


func _on_move(p: PointerTracker.Pointer) -> void:
	if state == "paused" or state == "results":
		return
	if control_mode == "relative":
		if not _virtual.has(p.id):
			return
		var a := sim.arena
		var v: Vector2 = _virtual[p.id] + (p.pos - p.prev_pos) * RELATIVE_GAIN
		v = Vector2(clampf(v.x, a.position.x, a.end.x), clampf(v.y, a.position.y, a.end.y))
		_virtual[p.id] = v
		sim.extend(p.id, v)
		return
	sim.extend(p.id, _target(p.pos))


func _on_up(p: PointerTracker.Pointer) -> void:
	_virtual.erase(p.id)
	sim.release(p.id)


func _target(pos: Vector2) -> Vector2:
	return pos + OFFSET if control_mode == "offset" else pos


# --- events -----------------------------------------------------------------------

func _on_ignited(fw: FuseSim.Firework, pts: int, heat: int, chain: int) -> void:
	var c := FireworkArt.color_of(fw.kind)
	match fw.kind:
		FuseSim.Kind.FOUNTAIN:
			fx.emit_burst(fw.pos, 70, c, 160, 520, 1.2, 4.0, 1.4, 1.1, Vector2.UP)
		FuseSim.Kind.ROCKET:
			fx.emit_burst(fw.pos, 30, c, 60, 240, 0.7, 3.5)
		FuseSim.Kind.SPLITTER:
			fx.emit_burst(fw.pos, 60, c, 100, 380, 1.0, 4.0)
		_:
			pass
	fx.emit_burst(fw.pos, 18, Color(1, 0.95, 0.8), 40, 160, 0.5, 3.0)
	var hp: Array = cfg.heat_points
	var txt := "+%d" % pts
	if heat > 1:
		txt += "  ×%s" % str(hp[heat - 1]).replace(".", ",")
	view.popup(fw.pos + Vector2(0, -34), txt, c.lerp(Color.WHITE, 0.45), 30 + heat * 4)
	if chain >= 3:
		view.popup(fw.pos + Vector2(0, 8), "Kette %d!" % chain, Color(1, 0.9, 0.45), 28)
	_shake(3.0 + heat * 1.5)


func _on_blast(pos: Vector2, radius: float) -> void:
	fx.emit_burst(pos, 140, FireworkArt.color_of(FuseSim.Kind.BANGER), 200, radius * 5.0, 0.9, 5.0)
	fx.emit_burst(pos, 40, Color(1, 0.95, 0.8), 80, 300, 0.4, 6.0)
	_shake(14.0)


func _on_caught(_fid: int, pos: Vector2) -> void:
	fx.emit_burst(pos, 160, Color(1, 0.7, 0.3), 100, 620, 1.2, 5.0)
	_shake(20.0)


func _on_game_over(score: int) -> void:
	var save := _save()
	var is_best := false
	if save:
		is_best = save.record_lunte_round(score)
	state = "results"
	tracker.cancel_all()
	audio.stop_all()
	round_finished.emit(score, is_best)
	_show_results(score, is_best)


# --- overlays ---------------------------------------------------------------------

func _close_overlay() -> void:
	if _overlay:
		_overlay.queue_free()
		_overlay = null


func _show_results(score: int, is_best: bool) -> void:
	_close_overlay()
	var save := _save()
	var o := VBoxContainer.new()
	o.theme = UiTheme.get_theme()
	o.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	o.alignment = BoxContainer.ALIGNMENT_CENTER
	o.offset_left = 40
	o.offset_right = -40
	var title := "Morgengrauen!" if sim.survived_dawn else "Eingeholt!"
	o.add_child(UiTheme.label(title, 54, UiTheme.ACCENT if sim.survived_dawn else UiTheme.TEXT, true))
	o.add_child(UiTheme.label(LunteHud._fmt(score), 96, UiTheme.TEXT, true))
	if is_best:
		o.add_child(UiTheme.label("Neuer Bestwert!", 36, UiTheme.GOOD, true))
	else:
		o.add_child(UiTheme.label("Bestwert %s" % LunteHud._fmt(int(save.data.lab.lunte_best) if save else score), 30, UiTheme.TEXT_DIM))
	var stats := "%d Zündungen · beste Kette %d · %d s" % [sim.ignitions, sim.best_chain, int(sim.time)]
	if sim.stats.loop_ignitions > 0:
		stats += "\n%d per Kurzschluss" % sim.stats.loop_ignitions
	o.add_child(UiTheme.label(stats, 26, UiTheme.TEXT_DIM))
	var again := UiTheme.primary_button("Nochmal")
	again.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	again.pressed.connect(_on_again)
	o.add_child(again)
	var menu := UiTheme.button("Menü", Vector2(260, 80))
	menu.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu.pressed.connect(_to_menu)
	o.add_child(menu)
	o.modulate.a = 0.0
	ui_layer.add_child(o)
	_overlay = o
	# Short delay so a finger still on the screen cannot hit "again" by accident.
	again.disabled = true
	var tw := create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(o, "modulate:a", 1.0, 0.25)
	tw.tween_callback(func(): again.disabled = false)


func _on_again() -> void:
	var ads := get_node_or_null("/root/Ads")
	if ads and ads.has_method("maybe_show_interstitial"):
		await ads.maybe_show_interstitial()
	new_round()


func _to_menu() -> void:
	var ads := get_node_or_null("/root/Ads")
	if ads and ads.has_method("maybe_show_interstitial"):
		await ads.maybe_show_interstitial()
	var flow := get_node_or_null("/root/Flow")
	if flow:
		flow.go("res://scenes/menus/main_menu.tscn")


func pause() -> void:
	if state == "results" or state == "paused":
		return
	var prev := state
	state = "paused"
	tracker.cancel_all()
	_close_overlay()
	var o := VBoxContainer.new()
	o.theme = UiTheme.get_theme()
	o.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	o.alignment = BoxContainer.ALIGNMENT_CENTER
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_layer.add_child(dim)
	o.add_child(UiTheme.label("Pause", 56, UiTheme.TEXT, true))
	var resume := UiTheme.primary_button("Weiter")
	resume.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	o.add_child(resume)
	var restart := UiTheme.button("Neu starten")
	restart.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	o.add_child(restart)
	var settings := UiTheme.button("Einstellungen")
	settings.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	o.add_child(settings)
	var menu := UiTheme.button("Menü")
	menu.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	o.add_child(menu)
	ui_layer.add_child(o)
	_overlay = o
	var close := func():
		dim.queue_free()
		_close_overlay()
	resume.pressed.connect(func():
		close.call()
		state = prev if prev != "paused" else "playing")
	restart.pressed.connect(func():
		close.call()
		new_round())
	settings.pressed.connect(func():
		var s := SettingsMenu.new()
		s.closed.connect(_reload_settings)
		ui_layer.add_child(s))
	menu.pressed.connect(func():
		close.call()
		_to_menu())


func _reload_settings() -> void:
	var save := _save()
	if save == null:
		return
	control_mode = save.get_setting("control_mode")
	effects = float(save.get_setting("effects"))
	fx.intensity = 0.4 + 0.6 * effects
	view.effects = effects
	debug_overlay.visible = bool(save.get_setting("touch_debug"))


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT:
			if state == "playing":
				pause()


## Android back: pause while playing, otherwise back to the menu.
func on_back() -> bool:
	if state in ["ready", "playing"]:
		pause()
	else:
		_to_menu()
	return true
