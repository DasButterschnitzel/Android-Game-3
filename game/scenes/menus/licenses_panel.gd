class_name LicensesPanel
extends Control
## Third-party notices of the Godot Engine inside the app (FreeType, Mbed TLS,
## HarfBuzz, ...): every component with its copyright lines and license, then
## the full license texts, in English as published. Several of these licenses
## require the notice to ship with the app; the credits page links here.
## The texts (about 80 KB) are added a few per frame so opening stays smooth.

const PER_FRAME := 4

var _box: VBoxContainer
var _pending: Array[Array] = []  # [text, size, color] still to add


func _ready() -> void:
	add_to_group("back_handler")
	theme = UiTheme.get_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = UiTheme.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var outer := VBoxContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.offset_left = 32
	outer.offset_right = -32
	outer.offset_top = 80 + SafeArea.top(get_viewport())
	outer.offset_bottom = -40 - SafeArea.bottom(get_viewport())
	add_child(outer)
	outer.add_child(UiTheme.label("Lizenzen", 48, UiTheme.TEXT, true))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	_box = VBoxContainer.new()
	_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_box)
	var back := UiTheme.primary_button("Zurück")
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(queue_free)
	outer.add_child(back)
	_pending = entries()


## Everything the page shows, in order: [text, font size, colour].
static func entries() -> Array[Array]:
	var out: Array[Array] = []
	out.append(["Die Godot Engine enthält Bestandteile Dritter. Ihre Urheber- und Lizenzhinweise (englische Originaltexte):", 24, UiTheme.TEXT_DIM])
	out.append([Engine.get_license_text(), 20, UiTheme.TEXT_DIM])
	for c in Engine.get_copyright_info():
		var lines := PackedStringArray()
		for part in c.parts:
			for who in part.copyright:
				lines.append("© " + str(who))
			lines.append("License: " + str(part.license))
		out.append(["%s\n%s" % [c.name, "\n".join(lines)], 20, UiTheme.TEXT_DIM])
	var texts := Engine.get_license_info()
	var names := texts.keys()
	names.sort()
	for n in names:
		out.append([str(n), 26, UiTheme.ACCENT])
		out.append([str(texts[n]), 18, UiTheme.TEXT_DIM])
	return out


func _process(_delta: float) -> void:
	for i in PER_FRAME:
		if _pending.is_empty():
			set_process(false)
			return
		var e: Array = _pending.pop_front()
		var l := UiTheme.label(e[0], e[1], e[2])
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_box.add_child(l)


## True once every notice is on the page.
func complete() -> bool:
	return _pending.is_empty()


## Android back closes the page.
func on_back() -> bool:
	queue_free()
	return true
