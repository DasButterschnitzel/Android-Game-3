class_name UiTheme
extends RefCounted
## Builds the game's UI Theme in code (no binary .tres to merge): Fredoka font,
## rounded buttons with generous touch targets (>= 48 dp), readable sizes.

const FONT_MEDIUM := preload("res://assets/fonts/Fredoka-Medium.ttf")
const FONT_BOLD := preload("res://assets/fonts/Fredoka-Bold.ttf")

## Palette shared by menus and HUD (night sky + ember accents).
const BG := Color("#0d1028")
const PANEL := Color("#171b3d")
const PANEL_LIGHT := Color("#232a5c")
const TEXT := Color("#f6f1e7")
const TEXT_DIM := Color("#a9a7c4")
const ACCENT := Color("#ffb347")
const ACCENT_DARK := Color("#d9822b")
const DANGER := Color("#ff5d5d")
const GOOD := Color("#7ce0b0")

static var _cached: Theme


static func get_theme() -> Theme:
	if _cached:
		return _cached
	var t := Theme.new()
	t.default_font = FONT_MEDIUM
	t.default_font_size = 30
	t.set_color("font_color", "Label", TEXT)
	for kind in ["Button"]:
		t.set_stylebox("normal", kind, _box(PANEL_LIGHT, 22))
		t.set_stylebox("hover", kind, _box(PANEL_LIGHT.lightened(0.08), 22))
		t.set_stylebox("pressed", kind, _box(PANEL_LIGHT.darkened(0.15), 22))
		t.set_stylebox("disabled", kind, _box(PANEL.darkened(0.2), 22))
		t.set_stylebox("focus", kind, StyleBoxEmpty.new())
		t.set_color("font_color", kind, TEXT)
		t.set_color("font_pressed_color", kind, TEXT)
		t.set_color("font_hover_color", kind, TEXT)
		t.set_color("font_disabled_color", kind, TEXT_DIM)
		t.set_font("font", kind, FONT_BOLD)
		t.set_font_size("font_size", kind, 32)
	t.set_stylebox("panel", "PanelContainer", _box(PANEL, 28, 28))
	t.set_stylebox("grabber_area", "HSlider", _box(ACCENT, 6, 0, 10))
	t.set_stylebox("grabber_area_highlight", "HSlider", _box(ACCENT, 6, 0, 10))
	t.set_stylebox("slider", "HSlider", _box(PANEL_LIGHT, 6, 0, 10))
	t.set_constant("separation", "VBoxContainer", 18)
	t.set_constant("separation", "HBoxContainer", 16)
	t.set_font("font", "CheckButton", FONT_MEDIUM)
	t.set_font_size("font_size", "CheckButton", 28)
	t.set_color("font_color", "CheckButton", TEXT)
	t.set_color("font_pressed_color", "CheckButton", TEXT)
	t.set_color("font_hover_color", "CheckButton", TEXT)
	t.set_color("font_hover_pressed_color", "CheckButton", TEXT)
	_cached = t
	return t


## Big primary call-to-action button (play / again).
static func primary_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(420, 112)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_stylebox_override("normal", _box(ACCENT, 30))
	b.add_theme_stylebox_override("hover", _box(ACCENT.lightened(0.1), 30))
	b.add_theme_stylebox_override("pressed", _box(ACCENT_DARK, 30))
	b.add_theme_color_override("font_color", BG)
	b.add_theme_color_override("font_pressed_color", BG)
	b.add_theme_color_override("font_hover_color", BG)
	b.add_theme_font_size_override("font_size", 44)
	return b


static func button(text: String, min_size := Vector2(360, 88)) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	b.focus_mode = Control.FOCUS_NONE
	return b


static func label(text: String, size := 30, color := TEXT, bold := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if bold:
		l.add_theme_font_override("font", FONT_BOLD)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func _box(c: Color, radius: int, pad := 18, pad_v := -1) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = c
	s.set_corner_radius_all(radius)
	s.content_margin_left = pad
	s.content_margin_right = pad
	s.content_margin_top = pad if pad_v < 0 else pad_v
	s.content_margin_bottom = pad if pad_v < 0 else pad_v
	return s
