class_name SafeArea
extends RefCounted
## Insets of the display's safe area (camera cut-outs, rounded corners, gesture
## bar) converted to viewport units, so HUD and buttons stay clear of them in
## immersive full screen. Returns zero insets on desktop or when unknown.

## Debug/test override in viewport units: Vector4(left, top, right, bottom).
static var override := Vector4(-1, -1, -1, -1)


static func insets(vp: Viewport) -> Vector4:
	if override.x >= 0.0:
		return override
	var win := DisplayServer.window_get_size()
	var safe := DisplayServer.get_display_safe_area()
	if win.x <= 0 or win.y <= 0 or safe.size.x <= 0 or safe.size.y <= 0:
		return Vector4.ZERO
	var vis := vp.get_visible_rect().size
	var sx := vis.x / win.x
	var sy := vis.y / win.y
	return Vector4(
		maxf(0.0, safe.position.x * sx),
		maxf(0.0, safe.position.y * sy),
		maxf(0.0, (win.x - safe.end.x) * sx),
		maxf(0.0, (win.y - safe.end.y) * sy))


static func top(vp: Viewport) -> float:
	return insets(vp).y


static func bottom(vp: Viewport) -> float:
	return insets(vp).w
