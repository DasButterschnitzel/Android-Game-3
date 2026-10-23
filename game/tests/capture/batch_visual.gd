extends Node2D
## Renders the batch helpers large for a visual check (fan triangulation of
## four-point primitives, multiline joints at low alpha, atlas discs).

func _ready() -> void:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var out := "user://batch_visual.png"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("out="):
			out = a.substr(4)
	get_viewport().get_texture().get_image().save_png(out)
	get_tree().quit()


func _shrink(segs: PackedVector2Array, by: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in range(0, segs.size(), 2):
		var d := (segs[i + 1] - segs[i]).normalized() * by
		out.append(segs[i] + d)
		out.append(segs[i + 1] - d)
	return out


func _draw() -> void:
	draw_rect(Rect2(0, 0, 720, 1280), Color("#141735"))
	var c := Color(1, 1, 1, 0.35)
	# row 1: AA multiline | non-AA multiline | draw_arc AA (reference)
	draw_multiline(Batch2D.ring(Vector2(120, 140), 90, 24), c, 6.0, true)
	draw_multiline(Batch2D.ring(Vector2(360, 140), 90, 24), c, 6.0, false)
	draw_arc(Vector2(600, 140), 90, 0, TAU, 24, c, 6.0, true)
	# row 2: AA multiline shrunk 0.5 / 1.0 / 1.5 px per end
	for k in 3:
		draw_multiline(_shrink(Batch2D.ring(Vector2(120 + k * 240, 380), 90, 24), 0.5 + 0.5 * k), c, 6.0, true)
	# row 3: thin rings w3, alpha 0.5: AA | non-AA | arc
	var c2 := Color(0.65, 0.94, 1.0, 0.5)
	draw_multiline(Batch2D.ring(Vector2(120, 620), 20, 24), c2, 3.0, true)
	draw_multiline(Batch2D.ring(Vector2(360, 620), 20, 24), c2, 3.0, false)
	draw_arc(Vector2(600, 620), 20, 0, TAU, 24, c2, 3.0, true)
	# row 4: trails w8 gradient: AA multiline_colors | non-AA | polyline_colors AA (reference)
	for k in 3:
		var tr := PackedVector2Array()
		var cols := PackedColorArray()
		var pc := PackedColorArray()
		for i in 12:
			tr.append(Vector2(30 + k * 230 + i * 17, 800 + sin(i * 0.6) * 40))
			pc.append(Color(1, 0.8, 0.5, 0.5 * float(i) / 11.0))
		for i in 11:
			cols.append(Color(1, 0.8, 0.5, 0.5 * float(i + 1) / 11.0))
		if k == 0:
			draw_multiline_colors(Batch2D.path(tr), cols, 8.0, true)
		elif k == 1:
			draw_multiline_colors(Batch2D.path(tr), cols, 8.0, false)
		else:
			draw_polyline_colors(tr, pc, 8.0, true)
	# row 5: small dashed start ring arcs (w3, alpha 0.6): AA multiline | non-AA | draw_arc
	for k in 3:
		var segs := PackedVector2Array()
		for i in 16:
			var a0 := TAU * i / 16.0
			if k < 2:
				segs.append_array(Batch2D.arc(Vector2(120 + k * 240, 1050), 56, a0, a0 + TAU / 16 * 0.55, 6))
			else:
				draw_arc(Vector2(600, 1050), 56, a0, a0 + TAU / 16 * 0.55, 6, Color(1, 0.95, 0.72, 0.6), 3.0, true)
		if k < 2:
			draw_multiline(segs, Color(1, 0.95, 0.72, 0.6), 3.0, k == 0)
