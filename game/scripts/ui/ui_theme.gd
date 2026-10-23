class_name UiTheme
extends RefCounted
## Builds the game's UI Theme in code (no binary .tres to merge): Fredoka font,
## rounded buttons with generous touch targets (>= 48 dp), readable sizes.

## Smallest touch target in viewport units: 48 dp on a 360 dp wide phone, where
## the 720 units of the viewport are 360 dp (bigger phones and tablets: more).
const TOUCH_MIN := 96.0

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
## "Lantern paper" UI (docs/art/ART_REVIEW_0.4.md, P1-9): only actions glow
## like the lantern (orange); information sits on dark night paper; cards have
## a darker lower edge (paper thickness) that flattens when pressed.
const PAPER := Color("#ffd58a")
const ACTION_EDGE := Color("#b8621c")
const ACTION_GLOW := Color(1.0, 0.604, 0.235, 0.35)
const INK := Color("#2a1426")
const SECONDARY := Color("#1c1f45")
const SECONDARY_EDGE := Color("#0e1030")

static var _cached: Theme
## Player setting "Schrift" (1.0 normal, 1.2 groß): scales menu, card and note
## text; the in-run HUD keeps its fixed layout.
static var text_scale := 1.0


## A font size scaled by the text setting.
static func fs(size: int) -> int:
	return int(round(size * text_scale))


## Applies the text setting; controls built from the theme follow at once,
## everything else when it is built next.
static func set_text_scale(s: float) -> void:
	text_scale = clampf(s, 1.0, 1.5)
	if _cached:
		_apply_sizes(_cached)


static func _apply_sizes(t: Theme) -> void:
	t.default_font_size = fs(30)
	t.set_font_size("font_size", "Button", fs(32))
	t.set_font_size("font_size", "CheckButton", fs(28))


static func get_theme() -> Theme:
	if _cached:
		return _cached
	var t := Theme.new()
	t.default_font = FONT_MEDIUM
	t.set_color("font_color", "Label", TEXT)
	for kind in ["Button"]:
		# Secondary actions: dark "night paper" with paper thickness.
		t.set_stylebox("normal", kind, _paper(SECONDARY, SECONDARY_EDGE, 20, 5))
		t.set_stylebox("hover", kind, _paper(SECONDARY.lightened(0.08), SECONDARY_EDGE, 20, 5))
		t.set_stylebox("pressed", kind, _paper(SECONDARY.darkened(0.12), SECONDARY_EDGE, 20, 2, true))
		t.set_stylebox("disabled", kind, _paper(SECONDARY.darkened(0.3), SECONDARY_EDGE, 20, 3))
		t.set_stylebox("focus", kind, StyleBoxEmpty.new())
		t.set_color("font_color", kind, TEXT)
		t.set_color("font_pressed_color", kind, TEXT)
		t.set_color("font_hover_color", kind, TEXT)
		t.set_color("font_disabled_color", kind, TEXT_DIM)
		t.set_font("font", kind, FONT_BOLD)
	t.set_stylebox("panel", "PanelContainer", panel_box())
	t.set_stylebox("grabber_area", "HSlider", _box(ACCENT, 6, 0, 10))
	t.set_stylebox("grabber_area_highlight", "HSlider", _box(ACCENT, 6, 0, 10))
	t.set_stylebox("slider", "HSlider", _box(PANEL_LIGHT, 6, 0, 10))
	t.set_constant("separation", "VBoxContainer", 18)
	t.set_constant("separation", "HBoxContainer", 16)
	t.set_font("font", "CheckButton", FONT_MEDIUM)
	t.set_color("font_color", "CheckButton", TEXT)
	t.set_color("font_pressed_color", "CheckButton", TEXT)
	t.set_color("font_hover_color", "CheckButton", TEXT)
	t.set_color("font_hover_pressed_color", "CheckButton", TEXT)
	_apply_sizes(t)
	_cached = t
	return t


## Big primary call-to-action button (play / again).
static func primary_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(420, 112)
	b.focus_mode = Control.FOCUS_NONE
	var normal := _paper(ACCENT, ACTION_EDGE, 26, 6)
	normal.shadow_color = ACTION_GLOW
	normal.shadow_size = 18
	b.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = ACCENT.lightened(0.08)
	b.add_theme_stylebox_override("hover", hover)
	var pressed := _paper(Color("#f0a03a"), ACTION_EDGE, 26, 2, true)
	pressed.shadow_color = ACTION_GLOW
	pressed.shadow_size = 12
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("disabled", _paper(Color("#4a3d3a"), Color("#2e2524"), 26, 3))
	b.add_theme_color_override("font_color", INK)
	b.add_theme_color_override("font_pressed_color", INK)
	b.add_theme_color_override("font_hover_color", INK)
	b.add_theme_color_override("font_disabled_color", TEXT_DIM)
	# Own font override: the game puts this button on a CanvasLayer, where no theme is inherited.
	b.add_theme_font_override("font", FONT_BOLD)
	b.add_theme_font_size_override("font_size", fs(42))
	return b


static func button(text: String, min_size := Vector2(360, TOUCH_MIN)) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(min_size.x, maxf(min_size.y, TOUCH_MIN))
	b.focus_mode = Control.FOCUS_NONE
	return b


static func label(text: String, size := 30, color := TEXT, bold := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", fs(size))
	l.add_theme_color_override("font_color", color)
	if bold:
		l.add_theme_font_override("font", FONT_BOLD)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


## Card for pause/results: night paper whose edge catches the lantern light.
static func panel_box() -> StyleBoxFlat:
	var card := _box(Color("#141735", 0.95), 28, 32)
	card.border_color = Color(PAPER, 0.3)
	card.set_border_width_all(2)
	card.shadow_color = Color(0, 0, 0, 0.45)
	card.shadow_size = 28
	card.shadow_offset = Vector2(0, 10)
	return card


## Paper card: flat colour with a thicker, darker lower edge. pressed: the edge
## is thin and the content sits lower, as if the card was pushed down.
static func _paper(c: Color, edge: Color, radius: int, edge_w: int, pressed := false) -> StyleBoxFlat:
	var s := _box(c, radius)
	s.border_color = edge
	s.border_width_bottom = edge_w
	s.content_margin_top = 18 + (6 if pressed else 0)
	s.content_margin_bottom = 18 - (6 if pressed else 0) + edge_w - 2
	s.anti_aliasing = true
	return s


static func _box(c: Color, radius: int, pad := 18, pad_v := -1) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = c
	s.set_corner_radius_all(radius)
	s.content_margin_left = pad
	s.content_margin_right = pad
	s.content_margin_top = pad if pad_v < 0 else pad_v
	s.content_margin_bottom = pad if pad_v < 0 else pad_v
	return s
