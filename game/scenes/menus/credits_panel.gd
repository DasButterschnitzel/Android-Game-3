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
	box.offset_top = 80 + SafeArea.top(get_viewport())
	box.offset_bottom = -40 - SafeArea.bottom(get_viewport())
	add_child(box)
	box.add_child(UiTheme.label("Credits", 48, UiTheme.TEXT, true))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var inner := VBoxContainer.new()
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(inner)
	var text := "NACHHALL – %s\n\n" % Config.version_text()
	text += "Spiel, Grafik und Klänge: eigenständig prozedural erzeugt.\n\n"
	text += "Schrift: Fredoka – Milena Brandão, Hafontia (SIL Open Font License 1.1).\n\n"
	text += "Erstellt mit Godot Engine – godotengine.org\n\n"
	text += Engine.get_license_text()
	var body := UiTheme.label(text, 22, UiTheme.TEXT_DIM)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_child(body)
	# Notices of the engine's third-party parts (FreeType, Mbed TLS, ...).
	var licenses := UiTheme.button("Lizenzen der Engine-Bestandteile")
	licenses.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	licenses.pressed.connect(func(): add_child(LicensesPanel.new()))
	inner.add_child(licenses)
	var back := UiTheme.primary_button("Zurück")
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(queue_free)
	box.add_child(back)


## Android back closes the panel.
func on_back() -> bool:
	queue_free()
	return true
