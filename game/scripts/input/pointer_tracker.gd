class_name PointerTracker
extends Node
## Tracks every active touch pointer with its own identity and state.
##
## Gameplay never reads raw input events; it listens to these signals instead.
## This keeps multitouch handling in one tested place:
## - each finger keeps its id from down to up,
## - missed "down" events (finger already on screen) are recovered,
## - focus loss / app pause cancels every pointer so nothing stays "stuck";
##   a cancelled finger stays ignored until it is lifted (no stray drags after returning).
## On desktop, project setting emulate_touch_from_mouse turns the mouse into pointer 0.

signal pointer_down(p: Pointer)
signal pointer_moved(p: Pointer)
signal pointer_up(p: Pointer)
signal pointer_cancelled(p: Pointer)

const MAX_POINTERS := 5
const VELOCITY_SMOOTHING := 0.35

class Pointer:
	var id: int
	var start_pos: Vector2
	var pos: Vector2
	var prev_pos: Vector2
	var velocity := Vector2.ZERO
	var down_msec: int
	var last_move_msec: int
	var travelled := 0.0
	## Gameplay system that owns this pointer (e.g. the fuse it draws); null = free.
	var owner_tag: Variant = null

	func age_sec() -> float:
		return (Time.get_ticks_msec() - down_msec) / 1000.0

var pointers: Dictionary = {}  # id -> Pointer
var enabled := true
var _cancelled_ids := {}  # ids cancelled while down: their drags are ignored until a new touch


func _input(event: InputEvent) -> void:
	if not enabled:
		return
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)


func _handle_touch(e: InputEventScreenTouch) -> void:
	_cancelled_ids.erase(e.index)  # lifted or touching anew: the finger counts again
	if e.pressed:
		if pointers.has(e.index):
			# Missed release (can happen after focus changes): close the stale one first.
			_cancel(pointers[e.index])
		if pointers.size() >= MAX_POINTERS:
			return
		_create(e.index, e.position)
	else:
		var p: Pointer = pointers.get(e.index)
		if p == null:
			return
		_update_pos(p, e.position)
		pointers.erase(e.index)
		if e.canceled:
			pointer_cancelled.emit(p)
		else:
			pointer_up.emit(p)


func _handle_drag(e: InputEventScreenDrag) -> void:
	var p: Pointer = pointers.get(e.index)
	if p == null:
		if _cancelled_ids.has(e.index):
			return  # cancelled by focus loss or pause: must lift first
		# Finger was already down when we started listening: adopt it.
		if pointers.size() >= MAX_POINTERS:
			return
		p = _create(e.index, e.position)
	_update_pos(p, e.position)
	pointer_moved.emit(p)


func _create(id: int, pos: Vector2) -> Pointer:
	var p := Pointer.new()
	p.id = id
	p.start_pos = pos
	p.pos = pos
	p.prev_pos = pos
	p.down_msec = Time.get_ticks_msec()
	p.last_move_msec = p.down_msec
	pointers[id] = p
	pointer_down.emit(p)
	return p


func _update_pos(p: Pointer, pos: Vector2) -> void:
	var now := Time.get_ticks_msec()
	var dt := maxf((now - p.last_move_msec) / 1000.0, 0.001)
	var inst := (pos - p.pos) / dt
	p.velocity = p.velocity.lerp(inst, VELOCITY_SMOOTHING)
	p.travelled += pos.distance_to(p.pos)
	p.prev_pos = p.pos
	p.pos = pos
	p.last_move_msec = now


func _cancel(p: Pointer) -> void:
	pointers.erase(p.id)
	pointer_cancelled.emit(p)


## Cancels every active pointer (used on pause, focus loss, scene change).
func cancel_all() -> void:
	for p in pointers.values().duplicate():
		_cancelled_ids[p.id] = true
		_cancel(p)


func count() -> int:
	return pointers.size()


func get_pointer(id: int) -> Pointer:
	return pointers.get(id)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED, \
		NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			cancel_all()
