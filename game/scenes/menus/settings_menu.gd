class_name SettingsMenu
extends Control
## Settings overlay: audio volumes, mute, haptics, effect intensity, second
## finger, touch debug, privacy (plus the LUNTE lab control mode in debug
## builds). Every change is saved immediately.

signal closed

const CONTROL_MODES := ["direct", "offset", "relative"]
const CONTROL_NAMES := {"direct": "LUNTE-Labor: direkt", "offset": "LUNTE-Labor: Versatz", "relative": "LUNTE-Labor: relativ"}


func _ready() -> void:
	add_to_group("back_handler")
	theme = UiTheme.get_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(UiTheme.BG, 0.96)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 32
	scroll.offset_right = -32
	scroll.offset_top = 80
	scroll.offset_bottom = -40
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(box)
	box.add_child(UiTheme.label("Einstellungen", 52, UiTheme.TEXT, true))
	box.add_child(_slider("Gesamtlautstärke", "master_volume"))
	box.add_child(_slider("Musik", "music_volume"))
	box.add_child(_slider("Effekte", "sfx_volume"))
	box.add_child(_toggle("Stumm", "muted"))
	box.add_child(_toggle("Vibration", "haptics"))
	box.add_child(_effects_row())
	box.add_child(_sensitivity_row())
	box.add_child(_toggle("Zweiter Finger = zweites Licht", "second_finger"))
	box.add_child(_toggle("Touch-Anzeige (Test)", "touch_debug"))
	if OS.is_debug_build():
		box.add_child(_control_row())  # only the parked LUNTE lab scene uses it
		box.add_child(_cvd_row())
	var privacy := UiTheme.button("Datenschutz & Werbung")
	privacy.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	privacy.pressed.connect(_show_privacy)
	box.add_child(privacy)
	var back := UiTheme.primary_button("Fertig")
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(func():
		closed.emit()
		queue_free())
	box.add_child(back)


func _save() -> SaveStore:
	return get_node("/root/Save") as SaveStore


func _slider(text: String, key: String) -> Control:
	var col := VBoxContainer.new()
	col.add_child(UiTheme.label(text, 28, UiTheme.TEXT_DIM))
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.custom_minimum_size = Vector2(0, 56)
	s.value = float(_save().get_setting(key))
	s.value_changed.connect(func(v):
		_save().set_setting(key, v)
		_audio_changed())
	col.add_child(s)
	return col


func _toggle(text: String, key: String) -> Control:
	var c := CheckButton.new()
	c.text = text
	c.custom_minimum_size = Vector2(0, 72)
	c.button_pressed = bool(_save().get_setting(key))
	c.toggled.connect(func(on):
		_save().set_setting(key, on)
		if key == "haptics":
			Haptics.enabled = on
		_audio_changed())
	return c


func _effects_row() -> Control:
	var b := UiTheme.button("")
	var names := {1.0: "Effekte: voll", 0.5: "Effekte: reduziert", 0.0: "Effekte: minimal"}
	var cur := float(_save().get_setting("effects"))
	b.text = names.get(cur, "Effekte: voll")
	b.size_flags_horizontal = Control.SIZE_FILL
	b.pressed.connect(func():
		var order := [1.0, 0.5, 0.0]
		var v := float(_save().get_setting("effects"))
		var nxt: float = order[(order.find(v) + 1) % order.size()]
		_save().set_setting("effects", nxt)
		b.text = names[nxt])
	return b


## How far the light moves per finger movement (bigger phones may want "hoch").
func _sensitivity_row() -> Control:
	var b := UiTheme.button("")
	var names := {0.75: "Empfindlichkeit: niedrig", 1.0: "Empfindlichkeit: normal", 1.3: "Empfindlichkeit: hoch"}
	var cur := float(_save().get_setting("sensitivity"))
	b.text = names.get(cur, "Empfindlichkeit: normal")
	b.size_flags_horizontal = Control.SIZE_FILL
	b.pressed.connect(func():
		var order := [0.75, 1.0, 1.3]
		var v := float(_save().get_setting("sensitivity"))
		var idx := order.find(v)
		var nxt: float = order[(idx + 1) % order.size()] if idx >= 0 else 1.0
		_save().set_setting("sensitivity", nxt)
		b.text = names[nxt])
	return b


func _control_row() -> Control:
	var b := UiTheme.button("")
	var cur: String = _save().get_setting("control_mode")
	b.text = "Steuerung: " + CONTROL_NAMES.get(cur, cur)
	b.size_flags_horizontal = Control.SIZE_FILL
	b.pressed.connect(func():
		var v: String = _save().get_setting("control_mode")
		var nxt: String = CONTROL_MODES[(CONTROL_MODES.find(v) + 1) % CONTROL_MODES.size()]
		_save().set_setting("control_mode", nxt)
		b.text = "Steuerung: " + CONTROL_NAMES[nxt])
	return b


## Debug: simulate colour vision deficiencies (not saved; resets on restart).
func _cvd_row() -> Control:
	var names := ["Farbsicht-Test: aus", "Farbsicht-Test: Protan", "Farbsicht-Test: Deutan", "Farbsicht-Test: Tritan", "Farbsicht-Test: Grau"]
	var b := UiTheme.button(names[0])
	b.size_flags_horizontal = Control.SIZE_FILL
	b.set_meta("mode", 0)
	b.pressed.connect(func():
		var m: int = (int(b.get_meta("mode")) + 1) % names.size()
		b.set_meta("mode", m)
		b.text = names[m]
		var flow := get_node_or_null("/root/Flow")
		if flow:
			flow.set_cvd_mode(m))
	return b


func _audio_changed() -> void:
	var audio := get_node_or_null("/root/Audio")
	if audio:
		audio.apply_settings()


func _show_privacy() -> void:
	var p := PrivacyPanel.new()
	add_child(p)


## Android back closes the settings like "Fertig".
func on_back() -> bool:
	closed.emit()
	queue_free()
	return true
