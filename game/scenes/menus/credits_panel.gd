class_name CreditsPanel
extends Control
## Credits and the license notices the shipped software must carry
## (Godot MIT notice, Fredoka OFL). Full engine license text is scrollable.


func _ready() -> void:
	add_to_group("back_handler")
	theme = UiTheme.get_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = UiTheme.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 32
	box.offset_right = -32
	box.offset_top = 80
	box.offset_bottom = -40
	add_child(box)
	box.add_child(UiTheme.label("Credits", 48, UiTheme.TEXT, true))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var inner := VBoxContainer.new()
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(inner)
	var text := "Spiel, Grafik und Klänge: eigenständig prozedural erzeugt.\n\n"
	text += "Schrift: Fredoka – Milena Brandão, Hafontia (SIL Open Font License 1.1).\n\n"
	text += "Erstellt mit Godot Engine – godotengine.org\n\n"
	text += Engine.get_license_text()
	var body := UiTheme.label(text, 22, UiTheme.TEXT_DIM)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_child(body)
	var back := UiTheme.primary_button("Zurück")
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(queue_free)
	box.add_child(back)


## Android back closes the panel.
func on_back() -> bool:
	queue_free()
	return true
