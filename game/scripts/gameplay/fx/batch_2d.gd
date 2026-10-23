class_name Batch2D
extends RefCounted
## Batch-friendly drawing for the GL Compatibility renderer. Measured with
## tests/capture/batch_probe.gd (Godot 4.7): every draw_circle,
## draw_colored_polygon and draw_polyline is its own draw call (an
## anti-aliased polyline three), whereas lines and multilines of any width,
## four-point primitives and rects of one texture merge into a single call.
## So a layer collects its fills here and submits them as one triangle array
## (one call); outlines go out as multiline segments, dots and glows as rects
## of one atlas texture (ArtKit.atlas()).

var points := PackedVector2Array()
var colors := PackedColorArray()
var indices := PackedInt32Array()

static var _unit_rings := {}  # sides -> closed unit circle as line segments
static var _unit_circles := {}  # sides -> unit circle points
static var _fans := {}  # Vector2i(rim points, base) -> fan indices


func is_empty() -> bool:
	return indices.is_empty()


## Polygon in which every rim point sees `center` (circles, blobs, ellipses) as a fan.
func fan(center: Vector2, rim: PackedVector2Array, color: Color) -> void:
	var base := points.size()
	var n := rim.size()
	points.append(center)
	points.append_array(rim)
	var c := PackedColorArray()
	c.resize(n + 1)
	c.fill(color)
	colors.append_array(c)
	indices.append_array(_fan_indices(n, base))


func disc(center: Vector2, r: float, color: Color, sides := 16) -> void:
	fan(center, Transform2D(0.0, Vector2(r, r), 0.0, center) * unit_circle(sides), color)


## Triangle; a quad is two of them.
func tri(a: Vector2, b: Vector2, c: Vector2, color: Color) -> void:
	var base := points.size()
	points.append(a)
	points.append(b)
	points.append(c)
	for i in 3:
		colors.append(color)
		indices.append(base + i)


func quad(a: Vector2, b: Vector2, c: Vector2, d: Vector2, color: Color) -> void:
	tri(a, b, c, color)
	tri(a, c, d, color)


## Straight band of the given width (non-anti-aliased line inside a fill batch);
## `cap` extends both ends so joints of a polyline have no notches.
func band(a: Vector2, b: Vector2, width: float, color: Color, cap := 0.0) -> void:
	var dir := (b - a).normalized()
	var n := Vector2(-dir.y, dir.x) * width * 0.5
	a -= dir * cap
	b += dir * cap
	quad(a + n, b + n, b - n, a - n, color)


## Submits everything collected as one triangle array (one draw call) and clears.
func flush(ci: CanvasItem) -> void:
	if not indices.is_empty():
		RenderingServer.canvas_item_add_triangle_array(ci.get_canvas_item(), indices, points, colors)
	points.clear()
	colors.clear()
	indices.clear()


## Filled circle from four-point primitives: it stays inside a line batch (no
## extra draw call) but is not anti-aliased, so only for small or soft dots.
static func prim_disc(ci: CanvasItem, center: Vector2, r: float, color: Color, sides := 12) -> void:
	var pts := Transform2D(0.0, Vector2(r, r), 0.0, center) * unit_circle(sides)
	var cols := PackedColorArray([color, color, color, color])
	var i := 0
	while i < sides:
		ci.draw_primitive(PackedVector2Array([center, pts[i], pts[(i + 1) % sides], pts[(i + 2) % sides]]), cols, PackedVector2Array())
		i += 2


static func _fan_indices(n: int, base: int) -> PackedInt32Array:
	var key := Vector2i(n, base)
	if _fans.has(key):
		return _fans[key]
	var idx := PackedInt32Array()
	for i in n:
		idx.append(base)
		idx.append(base + 1 + i)
		idx.append(base + 1 + (i + 1) % n)
	if _fans.size() < 4096:
		_fans[key] = idx
	return idx


static func unit_circle(sides: int) -> PackedVector2Array:
	if not _unit_circles.has(sides):
		var pts := PackedVector2Array()
		for i in sides:
			pts.append(Vector2.from_angle(TAU * i / sides))
		_unit_circles[sides] = pts
	return _unit_circles[sides]


# --- line segments for draw_multiline / draw_multiline_colors ---------------------

## Full circle outline as segments. Opaque strokes use a cached unit ring
## (one transform in C++); translucent ones pass `trim`: anti-aliased segments
## overlap at their joints and would show brighter beads, so each segment is
## shortened by `trim` px at both ends (0.5 px looks seamless, see batch_visual.gd).
static func ring(center: Vector2, r: float, sides := 32, trim := 0.0) -> PackedVector2Array:
	if trim > 0.0:
		return arc(center, r, 0.0, TAU, sides, trim)
	if not _unit_rings.has(sides):
		var segs := PackedVector2Array()
		var pts := unit_circle(sides)
		for i in sides:
			segs.append(pts[i])
			segs.append(pts[(i + 1) % sides])
		_unit_rings[sides] = segs
	return Transform2D(0.0, Vector2(r, r), 0.0, center) * (_unit_rings[sides] as PackedVector2Array)


static func arc(center: Vector2, r: float, from: float, to: float, sides := 24, trim := 0.0) -> PackedVector2Array:
	var segs := PackedVector2Array()
	var d := trim / maxf(r, 0.001) * signf(to - from)
	var step := (to - from) / sides
	for i in sides:
		var a := from + step * i
		segs.append(center + Vector2.from_angle(a + d) * r)
		segs.append(center + Vector2.from_angle(a + step - d) * r)
	return segs


## Polyline as segments; `closed` joins the last point to the first, `trim`
## as for ring() (translucent strokes).
static func path(pts: PackedVector2Array, closed := false, trim := 0.0) -> PackedVector2Array:
	var segs := PackedVector2Array()
	var n := pts.size()
	for i in (n if closed and n > 2 else n - 1):
		var a := pts[i]
		var b := pts[(i + 1) % n]
		if trim > 0.0:
			var d := (b - a).normalized() * trim
			a += d
			b -= d
		segs.append(a)
		segs.append(b)
	return segs


## Dashed straight line (dash and gap in px, `phase` shifts the pattern).
static func dashes(a: Vector2, b: Vector2, dash: float, gap: float, phase := 0.0) -> PackedVector2Array:
	var segs := PackedVector2Array()
	var len := a.distance_to(b)
	if len <= 0.0:
		return segs
	var dir := (b - a) / len
	var s := phase
	while s < len:
		segs.append(a + dir * maxf(s, 0.0))
		segs.append(a + dir * minf(s + dash, len))
		s += dash + gap
	return segs
