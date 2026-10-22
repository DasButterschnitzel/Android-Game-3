extends Control
## Prototype lab: choose which prototype to play.

const PROTOTYPES := [
	["LUNTE", "Zieh die Zündschnur – der Funke jagt dich.", "res://prototypes/lunte/lunte_proto.tscn"],
	["SCHWARM", "Führe einen Schwarm – zwei Finger teilen ihn.", "res://prototypes/schwarm/schwarm_proto.tscn"],
]


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#0b0d1a")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 28)
	add_child(box)
	var title := Label.new()
	title.text = "Prototyp-Labor"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	box.add_child(title)
	for p in PROTOTYPES:
		var b := Button.new()
		b.text = "%s\n%s" % [p[0], p[1]]
		b.custom_minimum_size = Vector2(600, 150)
		b.add_theme_font_size_override("font_size", 30)
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		b.disabled = not ResourceLoader.exists(p[2])
		var path: String = p[2]
		b.pressed.connect(func(): get_tree().change_scene_to_file(path))
		box.add_child(b)
