class_name RulesPanel
extends Control
## "So geht's": the rules to read at leisure (the game itself teaches by doing;
## some players prefer reading). Ghost types are shown with the real symbols.

const SECTIONS := [
	["Ziel", "Halte die Papierlaterne bis zum Morgengrauen am Leben. Schatten laufen auf sie zu – wer durchkommt, kostet beim Kassieren eine Flamme. Ohne Flammen ist die Nacht vorbei."],
	["Steuerung", "Zieh dein Licht aus dem Startring. Es folgt deinem Fingerweg, egal wo du ziehst. Berührt es geladen einen Schatten, schlägt es zu – und trifft alle Schatten in seiner Nähe."],
	["Nachglühen", "Nach einem Schlag glüht dein Licht 1 Sekunde nach (Ring), dann trifft es wieder."],
	["Echos", "Ein Lauf dauert höchstens 8 Sekunden. Danach wird er zum Echo, das Weg und Schläge genau wiederholt, während du den nächsten Lauf machst. Nummerierte Ringe zeigen, wo und wann ein Echo zuschlägt."],
	["Kassieren", "Punkte × Multiplikator: ×6 mit einem Licht, weniger mit jedem weiteren. Du entscheidest nach jedem Lauf: kassieren oder mit einem Licht mehr noch einmal. Bei 6 Lichtern wird automatisch kassiert."],
]
const TYPES := [
	[EchoSim.Type.NORMAL, "Normal: ein Treffer genügt."],
	[EchoSim.Type.TWIN, "Zwillinge: beide fast gleichzeitig treffen – mit zwei verschiedenen Lichtern."],
	[EchoSim.Type.ARMOR, "Gepanzert: braucht Treffer von zwei verschiedenen Lichtern."],
]
const MORE := [
	["Formationen", "Ketten (ein Schlag zwischen zwei Gliedern trifft beide), Zangen (von beiden Seiten zugleich), Regen (alle von oben)."],
	["Zweiter Finger", "Ein zweiter Finger entzündet im Lauf ein zweites Licht – schneller, aber es zählt wie ein weiterer Lauf."],
	["Mehr Nächte", "Tagesnacht: für alle gleich, jeden Tag neu. Vollmond: schwerer, nach dem ersten Morgengrauen. Sternbilder schalten Laternenpapiere frei – nur Aussehen, nie Spielstärke."],
]


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
	box.add_child(UiTheme.label("So geht's", 48, UiTheme.TEXT, true))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var inner := VBoxContainer.new()
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(inner)
	for s in SECTIONS:
		_section(inner, s[0], s[1])
	inner.add_child(_heading("Schatten"))
	for t in TYPES:
		var row := HBoxContainer.new()
		var icon := _TypeIcon.new()
		icon.type = t[0]
		row.add_child(icon)
		var l := _text(t[1])
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		inner.add_child(row)
	for s in MORE:
		_section(inner, s[0], s[1])
	var back := UiTheme.primary_button("Zurück")
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(queue_free)
	box.add_child(back)


func _section(parent: Control, title: String, body: String) -> void:
	parent.add_child(_heading(title))
	parent.add_child(_text(body))


func _heading(t: String) -> Label:
	var l := UiTheme.label(t, 30, UiTheme.ACCENT, true)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	return l


func _text(t: String) -> Label:
	var l := UiTheme.label(t, 24, UiTheme.TEXT_DIM)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	return l


## Android back closes the panel.
func on_back() -> bool:
	queue_free()
	return true


## The ghost type symbol as on the field edge and in the timeline.
class _TypeIcon extends Control:
	var type := 0

	func _init() -> void:
		custom_minimum_size = Vector2(56, 48)

	func _draw() -> void:
		EchoView.draw_type_symbol(self, size * 0.5, type, 26.0, -PI * 0.5)  # as in the timeline
