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
	shade.color = Color(0.02, 0.02, 0.07, 0.3)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var top_inset := SafeArea.top(get_viewport())
	var bottom_inset := SafeArea.bottom(get_viewport())
	# Top: title. Middle: the live night scene (the lantern is the logo).
	# Bottom: actions within thumb reach.
	var top := VBoxContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_top = 70 + top_inset
	add_child(top)
	_logo = Control.new()
	_logo.custom_minimum_size = Vector2(0, 150)
	_logo.draw.connect(_draw_logo)
	top.add_child(_logo)
	top.add_child(UiTheme.label("Jeder Lauf wird ein Echo, das mit dir kämpft.", 27, UiTheme.TEXT_DIM, true))
	var save := _save()
	var best: int = save.data.stats.best_score if save else 0
	if best > 0:
		top.add_child(UiTheme.label("Bestwert %s" % EchoHud.fmt(best), 30, UiTheme.ACCENT, true))
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	box.offset_bottom = -48 - bottom_inset
	add_child(box)
	var play := UiTheme.primary_button("Spielen")
	play.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	play.pressed.connect(func(): _start(false, ""))
	box.add_child(play)
	var daily := UiTheme.button(_daily_text())
	daily.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if daily.text.length() > 24:
		daily.add_theme_font_size_override("font_size", 26)
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
	var title := "Tagesnacht #%d · %s" % [Config.daily_number(), EchoHud.FORMATION_TITLES[Config.daily_feature()]]
	if save and save.data.daily.date == Time.get_date_string_from_system() and int(save.data.daily.played) > 0:
		return "%s · heute %s" % [title, EchoHud.fmt(int(save.data.daily.best))]
	return title


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


## Logo: "NACHHALL" whose letters breathe with a faint echo copy; the real
## lantern of the night scene below is the emblem.
func _draw_logo() -> void:
	var w := _logo.size.x
	var font: Font = UiTheme.FONT_BOLD
	var title := "NACHHALL"
	var fs := 112
	var tw := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var base := Vector2((w - tw) * 0.5, 120)
	for k in 3:
		var ph := fmod(_t * 0.35 + k / 3.0, 1.0)
		var c: Color = EchoView.ECHO_COLS[k]
		_logo.draw_string(font, base + Vector2(0, -ph * 26.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(c, 0.22 * (1.0 - ph)))
	_logo.draw_string_outline(font, base, title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 14, Color(0.03, 0.03, 0.09, 0.9))
	_logo.draw_string(font, base, title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiTheme.TEXT)


## Android back on the main menu leaves the app (overlays above it close first).
func on_back() -> bool:
	get_tree().quit()
	return true
