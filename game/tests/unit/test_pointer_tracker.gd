extends TestCase
## Multitouch identity and robustness tests for PointerTracker.

var tracker: PointerTracker
var log: Array[String] = []


func before_each() -> void:
	tracker = PointerTracker.new()
	add_child(tracker)
	log.clear()
	tracker.pointer_down.connect(func(p): log.append("down%d" % p.id))
	tracker.pointer_moved.connect(func(p): log.append("move%d" % p.id))
	tracker.pointer_up.connect(func(p): log.append("up%d" % p.id))
	tracker.pointer_cancelled.connect(func(p): log.append("cancel%d" % p.id))


func after_each() -> void:
	tracker.queue_free()


func test_two_fingers_keep_identity() -> void:
	touch(0, Vector2(100, 100), true)
	touch(1, Vector2(500, 900), true)
	drag(0, Vector2(120, 110))
	drag(1, Vector2(480, 880))
	assert_eq(tracker.count(), 2, "two pointers")
	assert_vec_near(tracker.get_pointer(0).pos, Vector2(120, 110), 0.01, "p0 pos")
	assert_vec_near(tracker.get_pointer(1).pos, Vector2(480, 880), 0.01, "p1 pos")
	assert_vec_near(tracker.get_pointer(1).start_pos, Vector2(500, 900), 0.01, "p1 start")
	touch(0, Vector2(120, 110), false)
	assert_eq(tracker.count(), 1, "one left")
	assert_true(tracker.get_pointer(1) != null, "finger 1 still tracked after finger 0 lifted")
	touch(1, Vector2(480, 880), false)
	assert_eq(log, ["down0", "down1", "move0", "move1", "up0", "up1"] as Array[String], "event order")


func test_simultaneous_release() -> void:
	for i in 3:
		touch(i, Vector2(100 + i * 100, 300), true)
	for i in 3:
		touch(i, Vector2(100 + i * 100, 300), false)
	assert_eq(tracker.count(), 0, "all released")
	assert_eq(log.count("up0") + log.count("up1") + log.count("up2"), 3, "three ups")


func test_drag_without_down_is_adopted() -> void:
	drag(3, Vector2(50, 60))
	assert_eq(tracker.count(), 1, "adopted")
	assert_eq(log[0], "down3", "synthesized down")


func test_repeated_down_cancels_stale_pointer() -> void:
	touch(0, Vector2(10, 10), true)
	touch(0, Vector2(400, 400), true)
	assert_eq(tracker.count(), 1, "still one pointer")
	assert_vec_near(tracker.get_pointer(0).start_pos, Vector2(400, 400), 0.01, "fresh pointer")
	assert_true(log.has("cancel0"), "stale one cancelled")


func test_focus_loss_cancels_all() -> void:
	touch(0, Vector2(10, 10), true)
	touch(1, Vector2(20, 20), true)
	tracker.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert_eq(tracker.count(), 0, "cleared")
	assert_true(log.has("cancel0") and log.has("cancel1"), "both cancelled")


func test_max_pointers_is_enforced() -> void:
	for i in 8:
		touch(i, Vector2(i * 10, 0), true)
	assert_eq(tracker.count(), PointerTracker.MAX_POINTERS, "capped")


func test_velocity_points_in_drag_direction() -> void:
	touch(0, Vector2(100, 100), true)
	await frames(2)
	drag(0, Vector2(200, 100))
	assert_true(tracker.get_pointer(0).velocity.x > 0.0, "positive x velocity")
	assert_near(tracker.get_pointer(0).velocity.y, 0.0, 0.001, "no y velocity")
