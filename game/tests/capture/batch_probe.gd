extends Node2D
## Which canvas draw commands batch in the GL Compatibility renderer?
## Draws 50 items of one kind per measurement and prints the draw calls.

var mode := ""
var tex: Texture2D
var tex2: Texture2D
var font: Font = preload("res://assets/fonts/Fredoka-Bold.ttf")


func _ready() -> void:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	tex = ImageTexture.create_from_image(img)
	var modes := ["none", "line3", "line3_aa", "multiline3", "mlc_aa", "tex_rect", "primitive3", "quad4", "string", "polyline_aa", "triangle_array"]
	var img2 := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img2.fill(Color.WHITE)
	tex2 = ImageTexture.create_from_image(img2)
	for m in modes:
		mode = m
		queue_redraw()
		for i in 4:
			await RenderingServer.frame_post_draw
		print("BATCH %s | calls %d | prims %d | objects %d" % [m, RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME), RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME), RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME)])
	get_tree().quit()


func _mlc(i: int, aa: bool, w: float) -> void:
	draw_multiline_colors(PackedVector2Array([Vector2(20 + i * 12, 200), Vector2(26 + i * 12, 240), Vector2(26 + i * 12, 240), Vector2(30 + i * 12, 260)]), PackedColorArray([Color.RED, Color.BLUE]), w, aa)


func _tri(i: int) -> void:
	draw_primitive(PackedVector2Array([Vector2(20 + i * 12, 100), Vector2(28 + i * 12, 100), Vector2(24 + i * 12, 110)]), PackedColorArray([Color.RED, Color.RED, Color.RED]), PackedVector2Array())


func _draw() -> void:
	match mode:
		"mlc_aa":
			for i in 50: _mlc(i, true, 3.0)
		"mlc_and_line":
			for i in 50:
				_mlc(i, false, 3.0)
				draw_line(Vector2(20 + i * 12, 300), Vector2(26 + i * 12, 340), Color.RED, 3.0)
		"mlc_aa_and_line":
			for i in 50:
				_mlc(i, true, 3.0)
				draw_line(Vector2(20 + i * 12, 300), Vector2(26 + i * 12, 340), Color.RED, 3.0, true)
		"tri_array_and_mlc":
			for i in 50:
				var b := 0
				RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), PackedInt32Array([0, 1, 2]), PackedVector2Array([Vector2(20 + i * 12, 100), Vector2(28 + i * 12, 100), Vector2(24 + i * 12, 110)]), PackedColorArray([Color.RED, Color.RED, Color.RED]))
				_mlc(i, true, 3.0)
		"two_tri_arrays":
			for i in 50:
				RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), PackedInt32Array([0, 1, 2]), PackedVector2Array([Vector2(20 + i * 12, 100), Vector2(28 + i * 12, 100), Vector2(24 + i * 12, 110)]), PackedColorArray([Color.RED, Color.RED, Color.RED]))
		"polygon_and_mlc":
			for i in 50:
				draw_colored_polygon(PackedVector2Array([Vector2(20 + i * 12, 100), Vector2(28 + i * 12, 100), Vector2(24 + i * 12, 110)]), Color.RED)
				_mlc(i, true, 3.0)
		"mlc_widths":
			for i in 50: _mlc(i, true, 2.0 + i % 3)
		"line_tri_mix":
			for i in 50:
				draw_line(Vector2(20 + i * 12, 200), Vector2(26 + i * 12, 240), Color.RED, 3.0)
				_tri(i)
		"line_quad_mix":
			for i in 50:
				draw_line(Vector2(20 + i * 12, 200), Vector2(26 + i * 12, 240), Color.RED, 3.0)
				draw_primitive(PackedVector2Array([Vector2(20 + i * 12, 100), Vector2(28 + i * 12, 100), Vector2(28 + i * 12, 110), Vector2(20 + i * 12, 110)]), PackedColorArray([Color.RED, Color.RED, Color.RED, Color.RED]), PackedVector2Array())
		"line_aa_mix":
			for i in 50:
				draw_line(Vector2(20 + i * 12, 200), Vector2(26 + i * 12, 240), Color.RED, 3.0, true)
				draw_line(Vector2(20 + i * 12, 300), Vector2(26 + i * 12, 340), Color.RED, 3.0, false)
		"two_textures":
			for i in 50:
				draw_texture_rect(tex, Rect2(20 + i * 12, 100, 8, 8), false, Color.RED)
				draw_texture_rect(tex2, Rect2(20 + i * 12, 120, 8, 8), false, Color.RED)
		"rect_and_line":
			for i in 50:
				draw_rect(Rect2(20 + i * 12, 100, 8, 8), Color.BLUE)
				draw_line(Vector2(20 + i * 12, 200), Vector2(26 + i * 12, 240), Color.RED, 3.0)
		"string_sizes":
			for i in 50: draw_string(font, Vector2(20 + (i % 10) * 60, 100 + (i / 10) * 30), str(i), HORIZONTAL_ALIGNMENT_LEFT, -1, 24 if i % 2 == 0 else 30, Color.WHITE)
		"string_and_texrect":
			for i in 50:
				draw_string(font, Vector2(20 + (i % 10) * 60, 100 + (i / 10) * 30), str(i), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
				draw_texture_rect(tex, Rect2(20 + i * 12, 400, 8, 8), false, Color.RED)
		"tri_and_texrect":
			for i in 50:
				_tri(i)
				draw_texture_rect(tex, Rect2(20 + i * 12, 400, 8, 8), false, Color.RED)
		"line_and_texrect":
			for i in 50:
				draw_line(Vector2(20 + i * 12, 200), Vector2(26 + i * 12, 240), Color.RED, 3.0)
				draw_texture_rect(tex, Rect2(20 + i * 12, 400, 8, 8), false, Color.RED)
		"quad4":
			for i in 50:
				draw_primitive(PackedVector2Array([Vector2(20 + i * 12, 100), Vector2(28 + i * 12, 100), Vector2(28 + i * 12, 110), Vector2(20 + i * 12, 110)]), PackedColorArray([Color.RED, Color.RED, Color.RED, Color.RED]), PackedVector2Array())
		"string_outline":
			for i in 50:
				draw_string_outline(font, Vector2(20 + (i % 10) * 60, 100 + (i / 10) * 30), str(i), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, 6, Color.BLACK)
				draw_string(font, Vector2(20 + (i % 10) * 60, 100 + (i / 10) * 30), str(i), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
		"line_alpha":
			for i in 50: draw_line(Vector2(20 + i * 12, 200), Vector2(26 + i * 12, 240), Color(1, 0, 0, i / 50.0), 2.0 + i % 3)
		"circle":
			for i in 50: draw_circle(Vector2(20 + i * 12, 100), 5, Color.RED)
		"tex_rect":
			for i in 50: draw_texture_rect(tex, Rect2(20 + i * 12, 100, 8, 8), false, Color.RED)
		"tex_rect_rot":
			for i in 50:
				draw_set_transform(Vector2(20 + i * 12, 100), i * 0.3)
				draw_texture_rect(tex, Rect2(-4, -4, 8, 8), false, Color.RED)
			draw_set_transform(Vector2.ZERO)
		"line3":
			for i in 50: draw_line(Vector2(20 + i * 12, 100), Vector2(26 + i * 12, 140), Color.RED, 3.0)
		"line3_aa":
			for i in 50: draw_line(Vector2(20 + i * 12, 100), Vector2(26 + i * 12, 140), Color.RED, 3.0, true)
		"multiline3":
			var pts := PackedVector2Array()
			for i in 50:
				pts.append(Vector2(20 + i * 12, 100)); pts.append(Vector2(26 + i * 12, 140))
			draw_multiline(pts, Color.RED, 3.0)
		"rect":
			for i in 50: draw_rect(Rect2(20 + i * 12, 100, 8, 8), Color.RED)
		"tex_and_rect":
			for i in 50:
				draw_texture_rect(tex, Rect2(20 + i * 12, 100, 8, 8), false, Color.RED)
				draw_rect(Rect2(20 + i * 12, 120, 8, 8), Color.BLUE)
		"string":
			for i in 50: draw_string(font, Vector2(20 + (i % 10) * 60, 100 + (i / 10) * 30), str(i), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
		"polyline":
			for i in 50: draw_polyline(PackedVector2Array([Vector2(20 + i * 12, 100), Vector2(26 + i * 12, 140), Vector2(20 + i * 12, 160)]), Color.RED, 3.0)
		"polyline_aa":
			for i in 50: draw_polyline(PackedVector2Array([Vector2(20 + i * 12, 100), Vector2(26 + i * 12, 140), Vector2(20 + i * 12, 160)]), Color.RED, 3.0, true)
		"triangle_array":
			var pts := PackedVector2Array()
			var cols := PackedColorArray()
			var idx := PackedInt32Array()
			for i in 50:
				var b := pts.size()
				pts.append_array([Vector2(20 + i * 12, 100), Vector2(28 + i * 12, 100), Vector2(24 + i * 12, 110)])
				cols.append_array([Color.RED, Color.RED, Color.BLUE])
				idx.append_array([b, b + 1, b + 2])
			RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), idx, pts, cols)
		"tex_region":
			for i in 50: draw_texture_rect_region(tex, Rect2(20 + i * 12, 100, 8, 8), Rect2(i % 4 * 8, 0, 8, 8), Color.RED)
		"colored_polygon":
			for i in 50: draw_colored_polygon(PackedVector2Array([Vector2(20 + i * 12, 100), Vector2(28 + i * 12, 100), Vector2(24 + i * 12, 110)]), Color.RED)
		"primitive3":
			for i in 50: draw_primitive(PackedVector2Array([Vector2(20 + i * 12, 100), Vector2(28 + i * 12, 100), Vector2(24 + i * 12, 110)]), PackedColorArray([Color.RED, Color.RED, Color.RED]), PackedVector2Array())
