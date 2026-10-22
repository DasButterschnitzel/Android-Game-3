class_name FireworkArt
extends RefCounted
## Draws the paper-craft fireworks of LUNTE onto any CanvasItem.
## Two-tone shading (lit left, shaded right) plus an offset drop shadow give a
## small diorama depth without textures. Sizes are relative to the hit radius
## so visuals and gameplay always agree.

const PAPER := Color("#f6efe0")
const SHADOW := Color(0.0, 0.0, 0.05, 0.35)
const SHADOW_OFFSET := Vector2(5, 7)

const COLORS := {
	FuseSim.Kind.FOUNTAIN: Color("#3fd9c0"),
	FuseSim.Kind.ROCKET: Color("#ff5cbc"),
	FuseSim.Kind.BANGER: Color("#ff6b4a"),
	FuseSim.Kind.SPLITTER: Color("#a98bff"),
}


static func color_of(kind: int) -> Color:
	return COLORS.get(kind, Color.WHITE)


static func draw(ci: CanvasItem, kind: int, pos: Vector2, r: float, dir: Vector2, alpha := 1.0, wobble := 0.0) -> void:
	match kind:
		FuseSim.Kind.FOUNTAIN:
			_fountain(ci, pos, r, alpha, wobble)
		FuseSim.Kind.ROCKET:
			_rocket(ci, pos, r, dir, alpha)
		FuseSim.Kind.BANGER:
			_banger(ci, pos, r, alpha, wobble)
		FuseSim.Kind.SPLITTER:
			_splitter(ci, pos, r, alpha, wobble)


static func _two_tone(ci: CanvasItem, poly: PackedVector2Array, c: Color, alpha: float, center: Vector2) -> void:
	ci.draw_colored_polygon(_offset(poly, SHADOW_OFFSET), Color(SHADOW, SHADOW.a * alpha))
	ci.draw_colored_polygon(poly, Color(c, alpha))
	# Shade the right half: exact intersection with the half-plane x >= center.x.
	var half := PackedVector2Array([center + Vector2(0, -999), center + Vector2(999, -999), center + Vector2(999, 999), center + Vector2(0, 999)])
	for part in Geometry2D.intersect_polygons(poly, half):
		if part.size() >= 3:
			ci.draw_colored_polygon(part, Color(c.darkened(0.28), alpha))


static func _offset(poly: PackedVector2Array, off: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(p + off)
	return out


static func _fountain(ci: CanvasItem, p: Vector2, r: float, a: float, wobble: float) -> void:
	var c := color_of(FuseSim.Kind.FOUNTAIN)
	var h := r * 1.7
	var top_w := r * 0.45
	var bot_w := r * 1.05
	var base := p + Vector2(0, h * 0.45)
	var body := PackedVector2Array([
		base + Vector2(-bot_w, 0), base + Vector2(bot_w, 0),
		base + Vector2(top_w, -h), base + Vector2(-top_w, -h)])
	_two_tone(ci, body, c, a, p)
	# Paper stripes.
	for k in 2:
		var y := -h * (0.3 + 0.32 * k)
		var w := lerpf(bot_w, top_w, 0.3 + 0.32 * k)
		ci.draw_line(base + Vector2(-w, y), base + Vector2(w, y), Color(PAPER, 0.85 * a), r * 0.16)
	# Little paper cap + wick.
	ci.draw_circle(base + Vector2(0, -h), top_w * 0.9, Color(PAPER, a))
	ci.draw_line(base + Vector2(0, -h), base + Vector2(sin(wobble) * 3.0, -h - r * 0.45), Color(0.2, 0.15, 0.1, a), 2.0)


static func _rocket(ci: CanvasItem, p: Vector2, r: float, dir: Vector2, a: float) -> void:
	var c := color_of(FuseSim.Kind.ROCKET)
	var d := dir.normalized()
	var n := d.orthogonal()
	var len := r * 1.9
	var w := r * 0.42
	var tail := p - d * len * 0.5
	var nose := p + d * len * 0.5
	var body := PackedVector2Array([tail + n * w, nose + n * w * 0.9, nose + d * r * 0.55, nose - n * w * 0.9, tail - n * w])
	ci.draw_colored_polygon(_offset(body, SHADOW_OFFSET), Color(SHADOW, SHADOW.a * a))
	ci.draw_colored_polygon(body, Color(c, a))
	# Shaded lower half: along the axis from tail to tip, back along the lower edge.
	ci.draw_colored_polygon(PackedVector2Array([tail, nose + d * r * 0.55, nose - n * w * 0.9, tail - n * w]), Color(c.darkened(0.28), a))
	# Fins and a paper band.
	ci.draw_colored_polygon(PackedVector2Array([tail + n * w, tail + n * w * 2.0 - d * r * 0.3, tail + d * r * 0.4 + n * w]), Color(PAPER, a))
	ci.draw_colored_polygon(PackedVector2Array([tail - n * w, tail - n * w * 2.0 - d * r * 0.3, tail + d * r * 0.4 - n * w]), Color(PAPER.darkened(0.15), a))
	ci.draw_line(p - n * w * 0.95, p + n * w * 0.95, Color(PAPER, 0.9 * a), r * 0.18)
	# Stick (shows the flight direction clearly).
	ci.draw_line(tail, tail - d * r * 1.1, Color(0.55, 0.42, 0.28, a), 3.0)


static func _banger(ci: CanvasItem, p: Vector2, r: float, a: float, wobble: float) -> void:
	var c := color_of(FuseSim.Kind.BANGER)
	ci.draw_circle(p + SHADOW_OFFSET, r * 0.95, Color(SHADOW, SHADOW.a * a))
	ci.draw_circle(p, r * 0.95, Color(c, a))
	ci.draw_circle(p + Vector2(r * 0.28, r * 0.12), r * 0.7, Color(c.darkened(0.25), a))
	ci.draw_circle(p - Vector2(r * 0.3, r * 0.3), r * 0.22, Color(1, 1, 1, 0.35 * a))
	ci.draw_arc(p, r * 0.62, -0.4, 1.9, 16, Color(PAPER, 0.8 * a), r * 0.14)
	ci.draw_line(p + Vector2(0, -r * 0.95), p + Vector2(r * 0.25 + sin(wobble) * 3.0, -r * 1.45), Color(0.2, 0.15, 0.1, a), 2.0)


static func _splitter(ci: CanvasItem, p: Vector2, r: float, a: float, wobble: float) -> void:
	var c := color_of(FuseSim.Kind.SPLITTER)
	var pts := PackedVector2Array()
	for i in 10:
		var ang := -PI / 2 + i * TAU / 10 + wobble * 0.05
		pts.append(p + Vector2.from_angle(ang) * (r if i % 2 == 0 else r * 0.48))
	_two_tone(ci, pts, c, a, p)
	ci.draw_circle(p, r * 0.22, Color(PAPER, a))
