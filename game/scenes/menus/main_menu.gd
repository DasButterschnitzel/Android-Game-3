extends Control
## Main menu: animated logo (a fuse burning under the title), best score,
## play, daily night (same seed for everyone today), settings, credits.

const GAME_SCENE := "res://scenes/gameplay/lunte_game.tscn"

var _t := 0.0
var _logo: Control
var _view: LunteView


func _save() -> SaveStore:
	return get_node_or_null("/root/Save") as SaveStore


func _ready() -> void:
	if OS.is_debug_build() and "--smoke" in OS.get_cmdline_user_args():
		set_process(false)
		SmokeTest.run.call_deferred(get_tree())
		return
	theme = UiTheme.get_theme()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var world := Node2D.new()
	add_child(world)
	_view = LunteView.new()
	world.add_child(_view)
	_view.setup(null, int(Time.get_unix_time_from_system()) / 86400)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.offset_bottom = -180
	add_child(box)
	_logo = Control.new()
	_logo.custom_minimum_size = Vector2(0, 230)
	_logo.draw.connect(_draw_logo)
	box.add_child(_logo)
	box.add_child(UiTheme.label("Zieh die Zündschnur. Der Funke jagt dich.", 28, UiTheme.TEXT_DIM))
	var save := _save()
	var best: int = save.data.stats.best_score if save else 0
	if best > 0:
		box.add_child(UiTheme.label("Bestwert %s" % LunteHud._fmt(best), 30, UiTheme.ACCENT))
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	box.add_child(spacer)
	var play := UiTheme.primary_button("Spielen")
	play.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	play.pressed.connect(func(): _start(false))
	box.add_child(play)
	var daily := UiTheme.button("Tagesnacht")
	daily.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	daily.pressed.connect(func(): _start(true))
	box.add_child(daily)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(row)
	var settings := UiTheme.button("Einstellungen", Vector2(260, 80))
	settings.pressed.connect(func(): add_child(SettingsMenu.new()))
	row.add_child(settings)
	var credits := UiTheme.button("Credits", Vector2(200, 80))
	credits.pressed.connect(func(): add_child(CreditsPanel.new()))
	row.add_child(credits)
	if OS.is_debug_build():
		var lab := UiTheme.button("Prototyp-Labor (Debug)", Vector2(360, 64))
		lab.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		lab.add_theme_font_size_override("font_size", 22)
		lab.pressed.connect(func(): _go("res://prototypes/lab.tscn"))
		box.add_child(lab)


func _start(daily: bool) -> void:
	var save := _save()
	if save:
		save.data["pending_daily"] = daily
	_go(GAME_SCENE)


func _go(path: String) -> void:
	var flow := get_node_or_null("/root/Flow")
	if flow:
		flow.go(path)
	else:
		get_tree().change_scene_to_file(path)


func _process(delta: float) -> void:
	_t += delta
	if _logo:
		_logo.queue_redraw()


## Logo: "LUNTE" in bold, a fuse underline with a spark running along it.
func _draw_logo() -> void:
	var w := _logo.size.x
	var font: Font = UiTheme.FONT_BOLD
	var title := "LUNTE"
	var fs := 150
	var tw := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var base := Vector2((w - tw) * 0.5, 150)
	_logo.draw_string_outline(font, base, title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 14, Color(0.03, 0.03, 0.09, 0.9))
	_logo.draw_string(font, base, title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiTheme.TEXT)
	var pts := PackedVector2Array()
	for i in 41:
		var x := lerpf(base.x, base.x + tw, i / 40.0)
		pts.append(Vector2(x, 190 + sin(i * 0.5 + 0.8) * 7.0))
	var k := fmod(_t * 0.35, 1.3)  # spark progress, with a pause at the end
	var burnt := clampi(int(k * 40.0), 0, 40)
	if burnt > 0:
		_logo.draw_polyline(pts.slice(0, burnt + 1), Color(0.3, 0.27, 0.36, 0.8), 3.0, true)
	if burnt < 40:
		_logo.draw_polyline(pts.slice(burnt), UiTheme.ACCENT, 5.0, true)
		var sp := pts[burnt]
		var g := ArtKit.glow_texture()
		_logo.draw_texture_rect(g, Rect2(sp - Vector2(36, 36), Vector2(72, 72)), false, Color(1, 0.6, 0.2, 0.8))
		_logo.draw_circle(sp, 4.0, Color.WHITE)
