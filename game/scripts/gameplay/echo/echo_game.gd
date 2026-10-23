class_name EchoGame
extends Node2D
## NACHHALL game controller: round lifecycle, input mapping, juice, persistence.
## The rules live in EchoSim; this node only connects player, sim and senses.
##
## Control is relative: a finger anywhere moves the light by its own motion
## (times relative_gain). The light follows that target at the rules' top
## speed, so a fast swipe lags a little but never drifts.
## A run starts only when the light is pulled out of its start ring; a finger
## that is still down when a run ends never starts the next one.

signal round_finished(score: int, is_best: bool)

const START_LOCK := 0.35  # s after a run ends before a new start gesture counts
const SECOND_FINGER_DRAG := 40.0  # px of finger travel before a second light joins
const PERFECT_BANK_DELAY := 1.0  # s of "perfect" celebration before the auto-bank

var cfg: Dictionary
var sim: EchoSim
var tracker: PointerTracker
var view: EchoView
var fx: SparkParticles
var hud: EchoHud
var audio: EchoAudio
var onboarding: EchoOnboarding
var ui_layer: CanvasLayer
var debug_overlay: TouchDebugOverlay
var bank_button: Button

var state := "play"  # play | paused | results
var effects := 1.0
var sensitivity := 1.0  # player setting, scales relative_gain
var second_finger := true
var seed_override := -1  # tests/captures: reproducible rounds
var daily := false  # same seed for everyone today
var mode := ""  # "" normal night, "fullmoon"
var earned: Array[String] = []  # achievements of the last finished night
var round_index := 0
var round_seed := 0
var ready_pos: Vector2  # the light inside its start ring before a run
var targets: Array[Vector2] = []  # wanted position per live light
var shake := 0.0
var _steer := {}  # pointer id -> live light index (0 also steers the ring light)
var _pending := {}  # pointer id -> finger travel of a possible second light
var _lock := 0.0
var _bank_timer := -1.0
var _overlay: Control
var _dim: ColorRect
var _round_time := 0.0
var _freeze := 0  # physics frames of hit-stop left (the sim just waits; replays stay exact)
var again_button: Button  # results screen, for tests and captures


func _save() -> SaveStore:
	return get_node_or_null("/root/Save") as SaveStore


func _ready() -> void:
	add_to_group("back_handler")
	var save := _save()
	if save:
		daily = bool(save.data.get("pending_daily", false))
		mode = "" if daily else str(save.data.get("pending_mode", ""))
	cfg = Config.load_mode("echo", mode)
	if save:
		effects = float(save.get_setting("effects"))
		sensitivity = float(save.get_setting("sensitivity"))
		second_finger = bool(save.get_setting("second_finger"))
		Haptics.enabled = bool(save.get_setting("haptics"))
	tracker = PointerTracker.new()
	tracker.name = "Tracker"
	add_child(tracker)
	tracker.pointer_down.connect(_on_down)
	tracker.pointer_moved.connect(_on_move)
	tracker.pointer_up.connect(_on_up)
	tracker.pointer_cancelled.connect(_on_up)
	view = EchoView.new()
	view.effects = effects
	add_child(view)
	fx = SparkParticles.new()
	fx.gravity = Vector2(0, 40)
	fx.intensity = 0.4 + 0.6 * effects
	add_child(fx)
	audio = EchoAudio.new()
	add_child(audio)
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	hud = EchoHud.new()
	hud.game = self
	hud.pause_pressed.connect(pause)
	ui_layer.add_child(hud)
	bank_button = UiTheme.primary_button("Kassieren")
	bank_button.visible = false
	bank_button.pressed.connect(_on_bank_pressed)
	ui_layer.add_child(bank_button)
	debug_overlay = TouchDebugOverlay.new()
	debug_overlay.tracker_path = tracker.get_path()
	debug_overlay.visible = save != null and bool(save.get_setting("touch_debug"))
	ui_layer.add_child(debug_overlay)
	onboarding = EchoOnboarding.new(save)
	onboarding.hint.connect(_on_hint)
	new_round()


## Fixed-size field so every device plays the same geometry (daily seed);
## extra screen height goes to the margins.
func arena() -> Rect2:
	var vr := get_viewport_rect()
	var w := minf(700.0, vr.size.x - 20.0)
	# Below the HUD and any camera cut-out; extra height of tall phones is split.
	var top := maxf(150.0 + SafeArea.top(get_viewport()), 150.0 + maxf(0.0, (vr.size.y - 1280.0) * 0.5))
	return Rect2(vr.position.x + (vr.size.x - w) * 0.5, vr.position.y + top, w, 1110.0)


func new_round() -> void:
	round_index += 1
	if daily:
		var d := Time.get_date_dict_from_system()
		round_seed = d.year * 10000 + d.month * 100 + d.day
	elif seed_override >= 0:
		round_seed = seed_override + round_index
	else:
		round_seed = int(Time.get_unix_time_from_system()) * 1000 + round_index
	sim = EchoSim.new(cfg, arena(), round_seed)
	_connect_sim()
	view.setup(sim, round_seed)
	hud.sim = sim
	var save := _save()
	hud.best = _best(save)
	if save:
		view.set_paper(str(save.get_setting("lantern_paper")))
	audio.attach(sim)
	fx.clear()
	_reset_input()
	ready_pos = sim.start_pos
	targets.clear()
	_bank_timer = -1.0
	_round_time = 0.0
	state = "play"
	_close_overlay()
	onboarding.round_started(sim, save.data.stats.rounds_played if save else 0)
	hud.wave_banner(sim.wave_index, sim.waves_per_round(), "")
	_update_bank_button()


func _connect_sim() -> void:
	sim.light_struck.connect(_on_struck)
	sim.enemy_destroyed.connect(_on_destroyed)
	sim.enemy_hit.connect(func(e, _id):
		fx.emit_burst(e.pos, 10, Color.WHITE, 40, 160, 0.35, 3.0)
		if e.spec.type == EchoSim.Type.ARMOR:
			fx.emit_burst(e.pos, 16, EchoView.enemy_color(EchoSim.Type.ARMOR), 90, 260, 0.6, 4.0)  # plates fly off
		view.flash_enemy(e.spec.id))
	sim.enemy_leaked.connect(_on_leaked)
	sim.enemy_spawned.connect(func(e):
		if e.spec.type == EchoSim.Type.TWIN and e.spec.id < e.spec.twin and _rounds_played() < 3:
			var partner: Variant = sim._enemy_by_id(e.spec.twin)
			if partner != null:
				var mid: Vector2 = ((e.spec.from as Vector2) + (partner.spec.from as Vector2)) * 0.5
				view.popup(Vector2(clampf(mid.x, 140, 580), sim.core.y - 120), "Zwillinge!", EchoView.enemy_color(EchoSim.Type.TWIN), 28, 1.5))
	sim.run_started.connect(func(_i):
		onboarding.run_started(sim)
		view.run_started()
		view.shockwave(sim.start_pos, EchoView.LIVE_COL, 110.0))
	sim.run_ended.connect(func(_i, _d, _l): _after_run.call_deferred())
	sim.wave_banked.connect(_on_banked)
	sim.wave_started.connect(func(w):
		ready_pos = sim.start_pos
		view.wave_started()
		var tag := str(sim.wave_def.get("announce", ""))
		hud.wave_banner(w, sim.waves_per_round(), tag)
		onboarding.wave_started(sim))
	sim.game_over.connect(_on_game_over)


# --- loop -------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if state != "play" or sim.state != "running":
		return
	_round_time += delta
	if _freeze > 0:
		_freeze -= 1
		return
	var deltas: Array = []
	for k in sim.live.size():
		var here: Vector2 = sim.live[k].pos
		var want: Vector2 = targets[k] if k < targets.size() else here
		deltas.append(want - here)
	sim.step(deltas)
	audio.on_step(sim)
	if sim.state == "running":
		onboarding.tick(sim)


func _process(delta: float) -> void:
	_lock = maxf(_lock - delta, 0.0)
	if state == "play" and _bank_timer >= 0.0:
		_bank_timer -= delta
		if _bank_timer < 0.0 and sim.state == "between":
			sim.bank()
	# The ring light drifts home when no finger holds it.
	if not _steers_ring():
		ready_pos = ready_pos.lerp(sim.start_pos, minf(1.0, delta * 8.0))
	shake = maxf(shake - delta * 30.0, 0.0)
	var off := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake
	view.position = off
	fx.position = off
	view.ready_pos = ready_pos
	view.targets = targets
	view.score_anchor = Vector2(110, 60 + hud.position.y)
	_update_bank_button()


func _steers_ring() -> bool:
	return sim.state in ["ready", "between"] and not _steer.is_empty()


func _shake(amount: float) -> void:
	shake = maxf(shake, amount * effects)


# --- input ------------------------------------------------------------------------

func _on_ui(pos: Vector2) -> bool:
	if hud.pause_button_rect().has_point(pos):
		return true
	return bank_button.visible and bank_button.get_global_rect().grow(12).has_point(pos)


func _on_down(p: PointerTracker.Pointer) -> void:
	if state != "play" or _on_ui(p.pos):
		return
	match sim.state:
		"ready", "between":
			if _steer.is_empty() and _bank_timer < 0.0:
				_steer[p.id] = 0
		"running":
			for k in sim.live.size():
				if not _steer.values().has(k):
					_steer[p.id] = k  # a finger takes over a light that lost its finger
					return
			if second_finger and sim.lights_used() < int(cfg.max_lights) and sim.live.size() < 2:
				_pending[p.id] = 0.0


func _on_move(p: PointerTracker.Pointer) -> void:
	if state != "play":
		return
	var d := (p.pos - p.prev_pos) * float(cfg.relative_gain) * sensitivity
	if _steer.has(p.id):
		if sim.state == "running":
			var k: int = _steer[p.id]
			if k < targets.size():
				targets[k] = _clamp_arena(targets[k] + d)
		elif sim.state in ["ready", "between"]:
			_move_ring_light(d)
	elif _pending.has(p.id) and sim.state == "running":
		_pending[p.id] = float(_pending[p.id]) + (p.pos - p.prev_pos).length()
		if float(_pending[p.id]) >= SECOND_FINGER_DRAG:
			_pending.erase(p.id)
			var at := sim.start_pos + Vector2(70 if sim.live[0].pos.x < sim.start_pos.x else -70, 0)
			var k := sim.add_live_light(at)
			if k >= 0:
				_steer[p.id] = k
				targets.append(sim.live[k].pos)
				view.popup(at + Vector2(0, -50), "2. Licht  ×%s" % _fmt_mult(sim.multiplier()), EchoView.LIVE_COL, 30)
				audio.play_ui("second")
				Haptics.bump()


## Before a run the light moves inside its start ring; pulling it out of the
## ring is the deliberate gesture that starts the run.
func _move_ring_light(d: Vector2) -> void:
	var ring := float(cfg.start_ring)
	var np := ready_pos + d
	var off := np - sim.start_pos
	if off.length() <= ring or _lock > 0.0 or _bank_timer >= 0.0:
		ready_pos = sim.start_pos + off.limit_length(ring)
		return
	var exit := sim.start_pos + off.normalized() * ring
	if sim.state == "between" and not sim.can_run_again():
		return
	sim.begin_run([exit])
	if sim.state != "running":
		return
	targets.clear()
	targets.append(_clamp_arena(np))
	ready_pos = exit
	Haptics.tick()


func _on_up(p: PointerTracker.Pointer) -> void:
	if _steer.has(p.id) and sim.state == "running":
		var k: int = _steer[p.id]
		if k < targets.size():
			targets[k] = sim.live[k].pos  # the light stops where it is
	_steer.erase(p.id)
	_pending.erase(p.id)


func _reset_input() -> void:
	_steer.clear()
	_pending.clear()
	tracker.cancel_all()


func _clamp_arena(p: Vector2) -> Vector2:
	var a := sim.arena
	return Vector2(clampf(p.x, a.position.x, a.end.x), clampf(p.y, a.position.y, a.end.y))


# --- run / wave events -------------------------------------------------------------

func _after_run() -> void:
	# Fingers still on the screen are consumed: they must lift before the
	# next start gesture (no accidental runs from a resting finger).
	_steer.clear()
	_pending.clear()
	targets.clear()
	_lock = START_LOCK
	if sim.state != "between":
		return
	var lr: Dictionary = sim.last_run
	if lr.leaked == 0:
		_bank_timer = PERFECT_BANK_DELAY
		view.popup(sim.core + Vector2(0, -110), "Perfekt!", UiTheme.GOOD, 44, 1.4)
		audio.play_ui("perfect")
		for c in [EchoView.PAPER, UiTheme.GOOD, EchoView.LIVE_COL]:
			fx.emit_burst(sim.core, 22, c, 120, 420, 1.1, 3.5)
	else:
		view.popup(sim.core + Vector2(150, 10), "%d durch" % lr.leaked, UiTheme.DANGER, 40, 1.8)
	onboarding.run_ended(sim)
	_update_bank_button()


## Onboarding: short labels at the object during a run, everything else as a
## paper note at the next break.
func _on_hint(key: String, text: String) -> void:
	match key:
		"echo":
			if not sim.echoes.is_empty():
				view.light_label(int(sim.echoes[0].id), text, EchoView.echo_color(0), 26, 1.8, 34.0)
		"recharge":
			if not sim.live.is_empty():
				view.light_label(int(sim.live[0].id), text, EchoView.LIVE_COL, 24, 1.5, 40.0)
		_:
			hud.show_hint(text)


func _on_bank_pressed() -> void:
	if state == "play" and sim.state == "between" and _bank_timer < 0.0:
		sim.bank()


func _update_bank_button() -> void:
	var show := state == "play" and sim.state == "between" and _bank_timer < 0.0
	# Very first teaching wave: no banking before the player has seen an echo
	# once, so the lesson "one light is not enough" cannot be skipped by a tap.
	if show and sim.wave_index == 0 and sim.echoes.size() == 1 and not onboarding.seen("echo"):
		show = false
	bank_button.visible = show
	if not show:
		return
	var pts := int(round(sim.last_run.points * sim.multiplier_for(sim.echoes.size())))
	bank_button.text = "Kassieren +%d" % pts  # the cost has its own red label (HUD)
	var vr := get_viewport_rect()
	bank_button.size = Vector2(minf(560.0, vr.size.x - 60.0), 104)
	bank_button.position = Vector2((vr.size.x - bank_button.size.x) * 0.5, vr.size.y - 104 - 56 - SafeArea.bottom(get_viewport()))


func _on_struck(light_id: int, pos: Vector2, hits: int, is_echo: bool) -> void:
	var col := view.light_color(light_id)
	view.strike_flash(pos, col, is_echo, -1 if is_echo else light_id - sim.echoes.size())
	if not is_echo:
		Haptics.tick()
		if hits >= 1:
			# Tiny hit-stop gives the strike weight; scaled by the effects setting.
			_freeze = int(round((2 if hits == 1 else 4) * effects))
		if hits >= 2:
			view.popup(pos + Vector2(0, -46), "Doppelt!", col.lerp(Color.WHITE, 0.5), 30)


func _on_destroyed(e: Dictionary, light_id: int) -> void:
	var col := view.light_color(light_id)
	var type: int = e.spec.type
	view.ghost_destroyed(e.pos, EchoView.enemy_color(type), type == EchoSim.Type.ARMOR)
	fx.emit_burst(e.pos, 26, EchoView.enemy_color(type), 40, 220, 0.7, 3.5)
	fx.emit_burst(e.pos, 14, col, 60, 260, 0.5, 3.0)
	if type == EchoSim.Type.TWIN and e.spec.id < e.spec.twin:
		var partner: Variant = sim._enemy_by_id(e.spec.twin)
		if partner != null:
			view.twin_beam(e.pos, partner.pos, EchoView.enemy_color(type))
	var pts := int(cfg.points[EchoSim.TYPE_KEYS[e.spec.type]])
	view.popup(e.pos + Vector2(0, -34), "+%d" % pts, col.lerp(Color.WHITE, 0.4), 26)
	_shake(2.0)


func _on_leaked(_e: Dictionary) -> void:
	fx.emit_burst(sim.core, 30, UiTheme.DANGER, 60, 240, 0.6, 3.5)
	view.lantern_hit()
	_shake(9.0)
	Haptics.heavy()


func _on_banked(_w: int, pts: int, leaked: int) -> void:
	_bank_timer = -1.0
	# Banked points fly from the lantern to the score and pop up there.
	view.fly_points(sim.core, pts / 25, UiTheme.ACCENT)
	view.popup(Vector2(130, 170 + hud.position.y), "+%d" % pts, UiTheme.ACCENT, 44)
	if leaked > 0:
		view.popup(sim.core + Vector2(0, 104), "−%d %s" % [leaked, "Flamme" if leaked == 1 else "Flammen"], UiTheme.DANGER, 32)
	Haptics.bump()


func _on_game_over(score: int, survived: bool) -> void:
	var save := _save()
	var is_best := false
	if save:
		is_best = save.record_echo_round(score, sim.stats, _round_time, daily, mode)
		earned = Progression.evaluate({
			"score": score, "survived": survived, "flames_left": sim.core_hp,
			"solo_perfect": int(sim.stats.solo_perfect) > 0, "echo_perfect": int(sim.stats.echo_perfect) > 0,
			"daily": daily, "duo": int(sim.stats.duo_runs) > 0,
		}, save.data.stats, save.data.unlocks)
		save.mark_dirty("unlocks")
	state = "results"
	_reset_input()
	_bank_timer = -1.0
	targets.clear()
	audio.round_over(survived)
	round_finished.emit(score, is_best)
	_show_results(score, is_best, survived)


func _rounds_played() -> int:
	var save := _save()
	return int(save.data.stats.rounds_played) if save else 0


func _best(save: SaveStore) -> int:
	if save == null:
		return 0
	return int(save.data.stats.best_fullmoon) if mode == "fullmoon" else int(save.data.stats.best_score)


static func _fmt_mult(m: float) -> String:
	return str(m).replace(".", ",").trim_suffix(",0")


# --- overlays ---------------------------------------------------------------------

func _close_overlay() -> void:
	if _overlay:
		_overlay.queue_free()
		_overlay = null
	if _dim:
		_dim.queue_free()
		_dim = null


func _panel_box() -> VBoxContainer:
	_close_overlay()
	_dim = ColorRect.new()
	_dim.color = Color(0.02, 0.02, 0.06, 0.62)
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_layer.add_child(_dim)
	# A night-paper card in the middle (UiTheme.panel_box via the theme).
	var center := CenterContainer.new()
	center.theme = UiTheme.get_theme()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(center)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(minf(620.0, get_viewport_rect().size.x - 40.0), 0)
	center.add_child(card)
	var o := VBoxContainer.new()
	o.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(o)
	_overlay = center
	return o


func _show_results(score: int, is_best: bool, survived: bool) -> void:
	var save := _save()
	var o := _panel_box()
	o.add_child(UiTheme.label("Morgengrauen!" if survived else "Die Laterne ist erloschen", 50, UiTheme.ACCENT if survived else UiTheme.TEXT, true))
	var score_label := UiTheme.label("0", 96, UiTheme.TEXT, true)
	o.add_child(score_label)
	# The score counts up once the panel is visible (tween dies with the label).
	var count := score_label.create_tween()
	count.tween_interval(1.0)
	count.tween_method(func(v: float): score_label.text = EchoHud.fmt(int(v)), 0.0, float(score), 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if is_best:
		o.add_child(UiTheme.label("Neuer Bestwert!", 36, UiTheme.GOOD, true))
	else:
		o.add_child(UiTheme.label("Bestwert %s" % EchoHud.fmt(_best(save) if save else score), 30, UiTheme.TEXT_DIM))
	var st: Dictionary = sim.stats
	var lines := "%d von %d Wellen · %d perfekt\n%d Lichter · %d s" % [st.waves_banked, sim.waves_per_round(), st.perfect_waves, st.lights, int(_round_time)]
	if survived:
		lines += "\nFlammen am Morgen: %d (+%d)" % [sim.core_hp, sim.dawn_bonus()]
	if daily:
		lines = "Tagesnacht #%d\n" % Config.daily_number() + lines
	elif mode == "fullmoon":
		lines = "Vollmond\n" + lines
	o.add_child(UiTheme.label(lines, 26, UiTheme.TEXT_DIM, true))
	for id in earned:
		var a: Dictionary = Progression.ACHIEVEMENTS[id]
		o.add_child(UiTheme.label("Sternbild: %s" % a.name, 26, UiTheme.ACCENT, true))
	for pid in Progression.papers_for(earned):
		o.add_child(UiTheme.label("Neues Laternenpapier: %s" % Progression.PAPERS[pid].name, 24, UiTheme.GOOD, true))
	var again := UiTheme.primary_button("Nochmal")
	again.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	again.pressed.connect(_on_again)
	o.add_child(again)
	again_button = again
	var menu := UiTheme.button("Menü", Vector2(260, 80))
	menu.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu.pressed.connect(_to_menu)
	o.add_child(menu)
	_overlay.modulate.a = 0.0
	_dim.modulate.a = 0.0
	# Short delay so a finger still on the screen cannot hit "again" by accident.
	again.disabled = true
	var tw := create_tween()
	tw.tween_interval(0.9)
	tw.tween_property(_overlay, "modulate:a", 1.0, 0.25)
	tw.parallel().tween_property(_dim, "modulate:a", 1.0, 0.25)
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
	else:
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")


func pause() -> void:
	if state != "play":
		return
	state = "paused"
	_reset_input()
	audio.set_paused(true)
	var o := _panel_box()
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
	resume.pressed.connect(resume_play)
	restart.pressed.connect(func():
		audio.set_paused(false)
		new_round())
	settings.pressed.connect(func():
		var s := SettingsMenu.new()
		s.closed.connect(_reload_settings)
		ui_layer.add_child(s))
	menu.pressed.connect(func():
		audio.set_paused(false)
		_close_overlay()
		_to_menu())


func resume_play() -> void:
	if state != "paused":
		return
	_close_overlay()
	audio.set_paused(false)
	state = "play"
	# Lights stop where they are; fingers must touch again.
	for k in sim.live.size():
		if k < targets.size():
			targets[k] = sim.live[k].pos


func _reload_settings() -> void:
	var save := _save()
	if save == null:
		return
	effects = float(save.get_setting("effects"))
	sensitivity = float(save.get_setting("sensitivity"))
	second_finger = bool(save.get_setting("second_finger"))
	fx.intensity = 0.4 + 0.6 * effects
	view.effects = effects
	debug_overlay.visible = bool(save.get_setting("touch_debug"))


## Android back: pause during play, resume from pause, menu from results.
func on_back() -> bool:
	match state:
		"play":
			pause()
		"paused":
			resume_play()
		"results":
			_to_menu()
	return true


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT:
			if state == "play" and sim != null and sim.state == "running":
				pause()
			elif state == "play":
				_reset_input()
