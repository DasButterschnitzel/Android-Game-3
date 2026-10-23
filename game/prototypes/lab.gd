extends Control
## Prototype lab: choose which prototype to play.

## ECHO grew into the main game (NACHHALL); the others are parked here so they
## can be compared on a device under equal conditions (ADR 0002, condition 5).
const PROTOTYPES := [
	["LUNTE (geparkt)", "Produktionsszene mit Grafik und Ton.", "res://scenes/gameplay/lunte_game.tscn"],
	["LUNTE-Prototyp", "Zieh die Zündschnur – der Funke jagt dich.", "res://prototypes/lunte/lunte_proto.tscn"],
	["SCHWARM (geparkt)", "Referenz-Spike, nicht weiterentwickelt.", "res://prototypes/schwarm/schwarm_proto.tscn"],
]


func _ready() -> void:
	add_to_group("back_handler")
	var bg := ColorRect.new()
	bg.color = Color("#0b0d1a")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 28)
	add_child(box)
	var title := Label.new()
	title.text = "Prototyp-Labor"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	box.add_child(title)
	var back := Button.new()
	back.text = "Zurück zum Spiel"
	back.custom_minimum_size = Vector2(600, 90)
	back.add_theme_font_size_override("font_size", 28)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn"))
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
	box.add_child(back)


func on_back() -> bool:
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
	return true
