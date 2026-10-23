extends Control
## Main menu: the night scene keeps playing behind the menu (a bot defends the
## lantern with its echoes), title, best score, play, daily night, settings,
## credits. Debug builds also show the prototype lab.

const GAME_SCENE := "res://scenes/gameplay/echo_game.tscn"

var _t := 0.0
var _logo: Control
var _view: EchoView
var _demo: EchoSim
var _bot: EchoBot


func _save() -> SaveStore:
	return get_node_or_null("/root/Save") as SaveStore


func _ready() -> void:
	if OS.is_debug_build() and "--smoke" in OS.get_cmdline_user_args():
		set_process(false)
		SmokeTest.run.call_deferred(get_tree())
		return
	add_to_group("back_handler")
	theme = UiTheme.get_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var world := Node2D.new()
	add_child(world)
	_view = EchoView.new()
	world.add_child(_view)
	_new_demo()
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.07, 0.45)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.offset_top = 120
	add_child(box)
	_logo = Control.new()
	_logo.custom_minimum_size = Vector2(0, 220)
	_logo.draw.connect(_draw_logo)
	box.add_child(_logo)
	box.add_child(UiTheme.label("Jeder Lauf wird ein Echo, das mit dir kämpft.", 27, UiTheme.TEXT_DIM, true))
	var save := _save()
	var best: int = save.data.stats.best_score if save else 0
	if best > 0:
		box.add_child(UiTheme.label("Bestwert %s" % EchoHud.fmt(best), 30, UiTheme.ACCENT, true))
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 24)
	box.add_child(spacer)
	var play := UiTheme.primary_button("Spielen")
	play.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	play.pressed.connect(func(): _start(false, ""))
	box.add_child(play)
	var daily := UiTheme.button(_daily_text())
	daily.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	daily.pressed.connect(func(): _start(true, ""))
	box.add_child(daily)
	# Harder mode, unlocked by surviving one night (a goal, not a purchase).
	var moon_open: bool = save != null and save.data.unlocks.has("dawn")
	var moon := UiTheme.button("Vollmond" if moon_open else "Vollmond · nach dem ersten Morgengrauen")
	moon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	moon.disabled = not moon_open
	if not moon_open:
		moon.add_theme_font_size_override("font_size", 22)
	moon.pressed.connect(func(): _start(false, "fullmoon"))
	box.add_child(moon)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(row)
	var collection := UiTheme.button("Sternbilder", Vector2(230, 80))
	collection.pressed.connect(func(): add_child(CollectionPanel.new()))
	row.add_child(collection)
	var settings := UiTheme.button("Einstellungen", Vector2(230, 80))
	settings.pressed.connect(func(): add_child(SettingsMenu.new()))
	row.add_child(settings)
	var credits := UiTheme.button("Credits", Vector2(170, 80))
	credits.pressed.connect(func(): add_child(CreditsPanel.new()))
	row.add_child(credits)
	if OS.is_debug_build():
		var lab := UiTheme.button("Prototyp-Labor (Debug)", Vector2(360, 64))
		lab.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		lab.add_theme_font_size_override("font_size", 22)
		lab.pressed.connect(func(): _go("res://prototypes/lab.tscn"))
		box.add_child(lab)


func _daily_text() -> String:
	var save := _save()
	if save and save.data.daily.date == Time.get_date_string_from_system() and int(save.data.daily.played) > 0:
		return "Tagesnacht · heute %s" % EchoHud.fmt(int(save.data.daily.best))
	return "Tagesnacht"


func _new_demo() -> void:
	var vr := get_viewport_rect()
	var w := minf(700.0, vr.size.x - 20.0)
	var arena := Rect2((vr.size.x - w) * 0.5, 150.0 + maxf(0.0, (vr.size.y - 1280.0) * 0.5), w, 1110.0)
	var cfg := Config.load_balance("echo")
	_demo = EchoSim.new(cfg, arena, int(Time.get_unix_time_from_system()) / 600)
	_bot = EchoBot.new(_demo, "perfect", 520.0)
	_view.setup(_demo, int(Time.get_unix_time_from_system()) / 86400)


func _start(daily: bool, mode: String) -> void:
	var save := _save()
	if save:
		save.data["pending_daily"] = daily
		save.data["pending_mode"] = mode
	_go(GAME_SCENE)


func _go(path: String) -> void:
	var flow := get_node_or_null("/root/Flow")
	if flow:
		flow.go(path)
	else:
		get_tree().change_scene_to_file(path)


func _physics_process(_delta: float) -> void:
	if _demo == null:
		return
	# Attract mode: the bot plays on behind the menu.
	match _demo.state:
		"ready", "between":
			if _demo.state == "between" and _bot.should_bank():
				_demo.bank()
			if _demo.state in ["ready", "between"]:
				_bot.prepare_run()
				_demo.begin_run()
		"running":
			_demo.step([_bot.delta()])
		"over":
			_new_demo()


func _process(delta: float) -> void:
	_t += delta
	if _logo:
		_logo.queue_redraw()


## Logo: "NACHHALL" with echo rings spreading from a small lantern.
func _draw_logo() -> void:
	var w := _logo.size.x
	var font: Font = UiTheme.FONT_BOLD
	var title := "NACHHALL"
	var fs := 112
	var tw := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var base := Vector2((w - tw) * 0.5, 190)
	var lantern := Vector2(w * 0.5, 52)
	for k in 3:
		var ph := fmod(_t * 0.45 + k / 3.0, 1.0)
		_logo.draw_arc(lantern, 18.0 + ph * 120.0, 0, TAU, 48, Color(EchoView.ECHO_COLS[k], 0.5 * (1.0 - ph)), 3.0, true)
	var g := ArtKit.glow_texture()
	_logo.draw_texture_rect(g, Rect2(lantern - Vector2(70, 70), Vector2(140, 140)), false, Color(1, 0.65, 0.3, 0.7))
	_logo.draw_colored_polygon(_ellipse(lantern, 20, 24), EchoView.PAPER)
	_logo.draw_rect(Rect2(lantern + Vector2(-11, -28), Vector2(22, 5)), Color("#3a2b3f"))
	_logo.draw_rect(Rect2(lantern + Vector2(-9, 23), Vector2(18, 4)), Color("#3a2b3f"))
	_logo.draw_string_outline(font, base, title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 14, Color(0.03, 0.03, 0.09, 0.9))
	_logo.draw_string(font, base, title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiTheme.TEXT)


func _ellipse(c: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 24:
		var a := TAU * i / 24.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


## Android back on the main menu leaves the app (overlays above it close first).
func on_back() -> bool:
	get_tree().quit()
	return true
