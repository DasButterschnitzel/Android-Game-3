class_name ArtKit
extends RefCounted
## Procedural art helpers for the "paper night" look: soft glow sprite,
## cut-paper rooftop silhouettes and two-tone paper shading for fireworks.
## Everything is generated at runtime: no image assets, tiny APK footprint.

static var _glow: Texture2D


## Radial soft dot used for additive glows and sparks (one texture, many quads).
static func glow_texture() -> Texture2D:
	if _glow:
		return _glow
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	g.add_point(0.25, Color(1, 1, 1, 0.65))
	g.add_point(0.6, Color(1, 1, 1, 0.12))
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = 64
	t.height = 64
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	_glow = t
	return t


## Cut-paper skyline: returns polygons (one per layer, back to front).
## Deterministic for a seed so every round has its own little town.
static func skyline(width: float, base_y: float, seed_value: int, layers := 3) -> Array[PackedVector2Array]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var out: Array[PackedVector2Array] = []
	for layer in layers:
		var pts := PackedVector2Array()
		var x := -20.0
		var top := base_y - 40.0 - (layers - layer) * 36.0
		pts.append(Vector2(x, base_y + 400))
		while x < width + 20:
			var w := rng.randf_range(48, 120)
			var h := rng.randf_range(20, 110) * (0.6 + 0.2 * (layers - layer))
			var y := top - h
			pts.append(Vector2(x, y))
			# Roof shape: flat, pitched or with a small chimney.
			match rng.randi_range(0, 2):
				0:
					pts.append(Vector2(x + w, y))
				1:
					pts.append(Vector2(x + w * 0.5, y - rng.randf_range(16, 34)))
					pts.append(Vector2(x + w, y))
				_:
					pts.append(Vector2(x + w * 0.62, y))
					pts.append(Vector2(x + w * 0.62, y - 18))
					pts.append(Vector2(x + w * 0.74, y - 18))
					pts.append(Vector2(x + w * 0.74, y))
					pts.append(Vector2(x + w, y))
			x += w
			pts.append(Vector2(x, y))
		pts.append(Vector2(x, base_y + 400))
		out.append(_dedupe(pts))
	return out


static func _dedupe(pts: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		if out.is_empty() or out[out.size() - 1].distance_to(p) > 0.5:
			out.append(p)
	return out


## Lit windows for a skyline layer (positions), sparse and deterministic.
static func windows(poly: PackedVector2Array, seed_value: int, density := 0.25) -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var out := PackedVector2Array()
	for i in range(1, poly.size() - 2):
		var a := poly[i]
		var b := poly[i + 1]
		if absf(a.y - b.y) < 0.5 and b.x - a.x > 30:
			for k in int((b.x - a.x) / 26):
				if rng.randf() < density:
					out.append(Vector2(a.x + 14 + k * 26, a.y + rng.randf_range(22, 70)))
	return out
