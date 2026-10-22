class_name TestCase
extends Node
## Minimal dependency-free test base class.
## Test scripts extend this and define methods named test_*. They may use await.
## Assertions record failures instead of aborting, so one run reports everything.

var failures: Array[String] = []
var current_test := ""


func fail(msg: String) -> void:
	failures.append("%s: %s" % [current_test, msg])


func assert_true(cond: bool, msg := "expected true") -> void:
	if not cond:
		fail(msg)


func assert_false(cond: bool, msg := "expected false") -> void:
	if cond:
		fail(msg)


func assert_eq(a: Variant, b: Variant, msg := "") -> void:
	if a != b:
		fail("%s expected %s == %s" % [msg, str(a), str(b)])


func assert_ne(a: Variant, b: Variant, msg := "") -> void:
	if a == b:
		fail("%s expected %s != %s" % [msg, str(a), str(b)])


func assert_near(a: float, b: float, eps: float, msg := "") -> void:
	if absf(a - b) > eps:
		fail("%s expected %f ≈ %f (±%f)" % [msg, a, b, eps])


func assert_vec_near(a: Vector2, b: Vector2, eps := 0.01, msg := "") -> void:
	if a.distance_to(b) > eps:
		fail("%s expected %s ≈ %s" % [msg, str(a), str(b)])


func assert_between(v: float, lo: float, hi: float, msg := "") -> void:
	if v < lo or v > hi:
		fail("%s expected %f in [%f, %f]" % [msg, v, lo, hi])


## Waits n process frames (for tests that need the scene tree to tick).
func frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


## Waits n physics frames.
func physics_frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


## Helpers to inject touch input through the real input pipeline.
## Positions are given in viewport (game) coordinates and converted to window
## coordinates, because the root viewport applies the stretch transform to input.
func to_window(pos: Vector2) -> Vector2:
	return get_tree().root.get_final_transform() * pos


func touch(index: int, pos: Vector2, pressed: bool) -> void:
	var e := InputEventScreenTouch.new()
	e.index = index
	e.position = to_window(pos)
	e.pressed = pressed
	Input.parse_input_event(e)
	Input.flush_buffered_events()


func drag(index: int, pos: Vector2, rel := Vector2.ZERO) -> void:
	var e := InputEventScreenDrag.new()
	e.index = index
	e.position = to_window(pos)
	e.relative = get_tree().root.get_final_transform().basis_xform(rel)
	Input.parse_input_event(e)
	Input.flush_buffered_events()
