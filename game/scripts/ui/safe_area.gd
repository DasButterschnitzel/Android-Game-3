class_name SafeArea
extends RefCounted
## Insets of the display's safe area (camera cut-outs, rounded corners, gesture
## bar) converted to viewport units, so HUD and buttons stay clear of them in
## immersive full screen. Returns zero insets on desktop or when unknown.

## Debug/test override in viewport units: Vector4(left, top, right, bottom).
static var override := Vector4(-1, -1, -1, -1)

## The HUD asks every frame; on Android each display query is a JNI round trip,
## so the result is reused for a second (cut-outs do not move in portrait).
const REFRESH_MS := 1000
static var _cached := Vector4.ZERO
static var _cached_vis := Vector2(-1, -1)
static var _cached_at := -REFRESH_MS


static func insets(vp: Viewport) -> Vector4:
	if override.x >= 0.0:
		return override
	var vis := vp.get_visible_rect().size
	var now := Time.get_ticks_msec()
	if vis == _cached_vis and now - _cached_at < REFRESH_MS:
		return _cached
	_cached_vis = vis
	_cached_at = now
	_cached = Vector4.ZERO
	var win := DisplayServer.window_get_size()
	var safe := DisplayServer.get_display_safe_area()
	if win.x <= 0 or win.y <= 0 or safe.size.x <= 0 or safe.size.y <= 0:
		return _cached
	var sx := vis.x / win.x
	var sy := vis.y / win.y
	_cached = Vector4(
		maxf(0.0, safe.position.x * sx),
		maxf(0.0, safe.position.y * sy),
		maxf(0.0, (win.x - safe.end.x) * sx),
		maxf(0.0, (win.y - safe.end.y) * sy))
	return _cached


static func top(vp: Viewport) -> float:
	return insets(vp).y


static func bottom(vp: Viewport) -> float:
	return insets(vp).w
