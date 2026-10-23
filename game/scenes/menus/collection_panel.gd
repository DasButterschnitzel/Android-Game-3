class_name CollectionPanel
extends Control
## "Sternbilder": statistics, achievements and the lantern papers they unlock.
## Purely cosmetic rewards; nothing here changes how strong the player is.

signal closed


func _save() -> SaveStore:
	return get_node_or_null("/root/Save") as SaveStore


func _ready() -> void:
	add_to_group("back_handler")
	theme = UiTheme.get_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()


func _build() -> void:
	var bg := ColorRect.new()
	bg.color = UiTheme.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var outer := VBoxContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.offset_left = 32
	outer.offset_right = -32
	outer.offset_top = 70 + SafeArea.top(get_viewport())
	outer.offset_bottom = -40 - SafeArea.bottom(get_viewport())
	add_child(outer)
	outer.add_child(UiTheme.label("Sternbilder", 52, UiTheme.TEXT, true))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(box)
	var save := _save()
	var stats: Dictionary = save.data.stats if save else SaveStore.defaults().stats
	var unlocks: Dictionary = save.data.unlocks if save else {}
	box.add_child(_section("Statistik"))
	box.add_child(_stats_text(stats, save))
	box.add_child(_section("Laternenpapier"))
	box.add_child(_papers(unlocks, save))
	box.add_child(_section("Sternbilder (%d/%d)" % [_count_earned(unlocks), Progression.ACHIEVEMENTS.size()]))
	for id in Progression.ACHIEVEMENTS:
		box.add_child(_achievement(id, unlocks.has(id)))
	var back := UiTheme.primary_button("Zurück")
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(_close)
	outer.add_child(back)


func _count_earned(unlocks: Dictionary) -> int:
	var n := 0
	for id in Progression.ACHIEVEMENTS:
		if unlocks.has(id):
			n += 1
	return n


func _section(text: String) -> Label:
	var l := UiTheme.label(text, 32, UiTheme.ACCENT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	return l


func _stats_text(s: Dictionary, save: SaveStore) -> Label:
	var minutes := int(float(s.play_seconds) / 60.0)
	var lines := "Bestwert: %s\nVollmond-Bestwert: %s\nNächte: %d · Morgengrauen: %d\nPerfekte Wellen: %d · Lichter: %d\nSpielzeit: %d min" % [
		EchoHud.fmt(int(s.best_score)), EchoHud.fmt(int(s.best_fullmoon)), int(s.rounds_played), int(s.dawns),
		int(s.perfect_waves), int(s.lights), minutes]
	if save and save.data.daily.date == Time.get_date_string_from_system() and int(save.data.daily.played) > 0:
		lines += "\nTagesnacht heute: %s" % EchoHud.fmt(int(save.data.daily.best))
	var l := UiTheme.label(lines, 26, UiTheme.TEXT_DIM)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	return l


func _papers(unlocks: Dictionary, save: SaveStore) -> Control:
	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 14)
	row.add_theme_constant_override("v_separation", 14)
	var current := str(save.get_setting("lantern_paper")) if save else "classic"
	for id in Progression.PAPERS:
		var p: Dictionary = Progression.PAPERS[id]
		var open := Progression.paper_unlocked(id, unlocks)
		var need: String = Progression.ACHIEVEMENTS[p.unlock].name if p.unlock != "" else ""
		var b := UiTheme.button(p.name if open else "(%s)" % need, Vector2(196, 88))
		b.add_theme_font_size_override("font_size", 24 if open else 20)
		b.disabled = not open
		if open:
			b.icon = _swatch(p.paper, p.rib)
		if id == current:
			b.add_theme_stylebox_override("normal", UiTheme._box(Color(p.paper, 0.35), 22))
		b.tooltip_text = "" if open else "Freischalten: " + Progression.ACHIEVEMENTS[p.unlock].text
		var pid: String = id
		b.pressed.connect(func():
			if save:
				save.set_setting("lantern_paper", pid)
			_rebuild())
		row.add_child(b)
	return row


func _swatch(paper: Color, rib: Color) -> Texture2D:
	var img := Image.create(28, 34, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in 34:
		for x in 28:
			var dx := (x - 13.5) / 13.5
			var dy := (y - 16.5) / 16.5
			if dx * dx + dy * dy <= 1.0:
				img.set_pixel(x, y, rib if absf(dx) > 0.82 or int(x) % 9 == 4 else paper)
	return ImageTexture.create_from_image(img)


func _achievement(id: String, earned: bool) -> Control:
	var a: Dictionary = Progression.ACHIEVEMENTS[id]
	var row := HBoxContainer.new()
	var star := Control.new()
	star.custom_minimum_size = Vector2(40, 40)
	star.draw.connect(func(): _draw_star(star, earned))
	row.add_child(star)
	var l := UiTheme.label("%s\n%s" % [a.name, a.text], 24, UiTheme.TEXT if earned else UiTheme.TEXT_DIM)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	return row


## The font has no star glyph, so stars are drawn: filled = earned.
static func _draw_star(c: Control, filled: bool) -> void:
	var center := c.size * 0.5
	var pts := PackedVector2Array()
	for i in 10:
		var r := 16.0 if i % 2 == 0 else 7.0
		var ang := -PI * 0.5 + PI * i / 5.0
		pts.append(center + Vector2(cos(ang), sin(ang)) * r)
	if filled:
		c.draw_colored_polygon(pts, UiTheme.ACCENT)
	else:
		c.draw_polyline(pts + PackedVector2Array([pts[0]]), Color(UiTheme.TEXT_DIM, 0.6), 2.0, true)


func _rebuild() -> void:
	for ch in get_children():
		ch.queue_free()
	_build.call_deferred()


func _close() -> void:
	closed.emit()
	queue_free()


func on_back() -> bool:
	_close()
	return true
