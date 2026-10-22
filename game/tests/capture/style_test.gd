extends Node2D
## Renders a static "paper night" style board for art review (not part of the game).

func _ready() -> void:
	var sky := ColorRect.new()
	sky.size = get_viewport_rect().size
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/night_sky.gdshader")
	mat.set_shader_parameter("dawn", 0.15)
	mat.set_shader_parameter("screen_px", get_viewport_rect().size)
	sky.material = mat
	sky.show_behind_parent = true
	add_child(sky)


func _draw() -> void:
	var vr := get_viewport_rect()
	var layers := ArtKit.skyline(vr.size.x, vr.size.y - 90, 7, 3)
	var tones := [Color("#1d1940"), Color("#151233"), Color("#0c0a22")]
	for i in layers.size():
		draw_colored_polygon(layers[i], tones[i])
		for w in ArtKit.windows(layers[i], 11 + i, 0.18):
			draw_rect(Rect2(w, Vector2(7, 10)), Color(1, 0.8, 0.45, 0.55 - i * 0.12))
	var glow := ArtKit.glow_texture()
	# A fuse: unburnt glowing part and fading ash.
	var pts := PackedVector2Array()
	for i in 60:
		pts.append(Vector2(120 + i * 8, 760 + sin(i * 0.12) * 60))
	draw_polyline(pts.slice(0, 25), Color(0.25, 0.22, 0.3, 0.8), 3.0, true)
	for p in pts.slice(25):
		draw_texture_rect(glow, Rect2(p - Vector2(14, 14), Vector2(28, 28)), false, Color(1, 0.6, 0.2, 0.18))
	draw_polyline(pts.slice(24), Color("#ffc15e"), 4.5, true)
	var spark := pts[25]
	draw_texture_rect(glow, Rect2(spark - Vector2(40, 40), Vector2(80, 80)), false, Color(1, 0.7, 0.3, 0.8))
	draw_circle(spark, 5, Color.WHITE)
	var t := 0.0
	FireworkArt.draw(self, FuseSim.Kind.FOUNTAIN, Vector2(200, 520), 30, Vector2.UP, 1.0, t)
	FireworkArt.draw(self, FuseSim.Kind.ROCKET, Vector2(380, 470), 30, Vector2(1, -0.4), 1.0, t)
	FireworkArt.draw(self, FuseSim.Kind.BANGER, Vector2(540, 560), 30, Vector2.UP, 1.0, t)
	FireworkArt.draw(self, FuseSim.Kind.SPLITTER, Vector2(300, 640), 30, Vector2.UP, 1.0, t)
	# A burst of additive sparks.
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for i in 90:
		var a := rng.randf() * TAU
		var d := rng.randf_range(10, 120)
		var c := Color("#3fd9c0").lerp(Color.WHITE, rng.randf() * 0.5)
		var p := Vector2(470, 300) + Vector2.from_angle(a) * d
		draw_texture_rect(glow, Rect2(p - Vector2(6, 6), Vector2(12, 12)), false, Color(c, 0.9))
	var font := UiTheme.FONT_BOLD
	draw_string(font, Vector2(24, 64), "1.240", HORIZONTAL_ALIGNMENT_LEFT, -1, 56, UiTheme.TEXT)
	draw_string(font, Vector2(24, 104), "Kette ×3   Hitze ×1,5", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, UiTheme.ACCENT)
