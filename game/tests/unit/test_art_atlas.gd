extends TestCase
## The sprite atlas (tools/art/make_atlas.py) must match ArtKit.ATLAS_CELLS:
## every cell inside the image, shapes where the table says, empty borders
## (no bleeding into neighbours under linear filtering).

var img: Image


func before_each() -> void:
	img = (ArtKit.atlas() as Texture2D).get_image()
	if img.is_compressed():
		img.decompress()


func _alpha(cell: String, offset: Vector2) -> float:
	var r: Rect2 = ArtKit.ATLAS_CELLS[cell][0]
	var p := r.get_center() + offset
	return img.get_pixelv(Vector2i(int(floor(p.x)), int(floor(p.y)))).a


func test_cells_lie_inside_the_image() -> void:
	var bounds := Rect2(Vector2.ZERO, img.get_size())
	for name in ArtKit.ATLAS_CELLS:
		var r: Rect2 = ArtKit.ATLAS_CELLS[name][0]
		assert_true(bounds.encloses(r), "%s inside %s" % [name, str(bounds)])


func test_cell_borders_are_empty() -> void:
	for name in ArtKit.ATLAS_CELLS:
		if name == "glow":
			continue  # the glow fades to zero only at its rim
		var r: Rect2 = ArtKit.ATLAS_CELLS[name][0]
		var worst := 0.0
		for x in range(int(r.position.x), int(r.end.x)):
			worst = maxf(worst, img.get_pixel(x, int(r.position.y)).a)
			worst = maxf(worst, img.get_pixel(x, int(r.end.y) - 1).a)
		for y in range(int(r.position.y), int(r.end.y)):
			worst = maxf(worst, img.get_pixel(int(r.position.x), y).a)
			worst = maxf(worst, img.get_pixel(int(r.end.x) - 1, y).a)
		assert_true(worst < 0.02, "%s border alpha %.3f" % [name, worst])


func test_discs_and_rings_sit_at_their_reference_radius() -> void:
	for name in ["disc64", "disc32", "disc16"]:
		var r: float = ArtKit.ATLAS_CELLS[name][1]
		assert_true(_alpha(name, Vector2.ZERO) > 0.99, "%s filled at the centre" % name)
		assert_true(_alpha(name, Vector2(r - 1.5, 0)) > 0.9, "%s filled just inside r" % name)
		assert_true(_alpha(name, Vector2(r + 1.5, 0)) < 0.1, "%s empty just outside r" % name)
	for name in ["slot", "track", "hitring", "guide"]:
		var r: float = ArtKit.ATLAS_CELLS[name][1]
		assert_true(_alpha(name, Vector2(r, 0.5)) > 0.5, "%s ring at its radius" % name)
		assert_true(_alpha(name, Vector2.ZERO) < 0.02, "%s empty in the middle" % name)
	# Dashes and plates: a gap after each segment.
	assert_true(_alpha("dashring", Vector2.from_angle(TAU / 16 * 0.25) * 60.0) > 0.5, "dash")
	assert_true(_alpha("dashring", Vector2.from_angle(TAU / 16 * 0.8) * 60.0) < 0.1, "gap between dashes")
	assert_true(_alpha("plates", Vector2.from_angle(TAU / 6 * 0.4) * 32.0) > 0.5, "plate")
	assert_true(_alpha("plates", Vector2.from_angle(TAU / 6 * 0.9) * 32.0) < 0.1, "gap between plates")
	assert_true(_alpha("plates3", Vector2.from_angle(TAU / 6 * 0.4) * 32.0) < 0.1, "first plate knocked off")
	assert_true(_alpha("plates3", Vector2.from_angle(TAU / 6 * 1.4) * 32.0) > 0.5, "second plate still there")


func test_symbols_have_a_light_fill_and_an_ink_outline() -> void:
	for name in ["tri", "square", "diamond"]:
		var centre := img.get_pixelv(Vector2i((ArtKit.ATLAS_CELLS[name][0] as Rect2).get_center()))
		assert_true(centre.a > 0.99 and centre.get_luminance() > 0.9, "%s: white fill (tinted when drawn)" % name)
	var edge := img.get_pixelv(Vector2i((ArtKit.ATLAS_CELLS["square"][0] as Rect2).get_center() + Vector2(11, 0)))
	assert_true(edge.a > 0.9 and edge.get_luminance() < 0.15, "square: ink outline at its edge")
