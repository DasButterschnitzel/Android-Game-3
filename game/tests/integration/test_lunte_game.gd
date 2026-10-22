extends TestCase
## LUNTE game scene through the real input pipeline.

var game: LunteGame


func before_each() -> void:
	var save := get_node("/root/Save") as SaveStore
	save.set_setting("control_mode", "direct")
	game = load("res://scenes/gameplay/lunte_game.tscn").instantiate()
	game.seed_override = 5
	add_child(game)
	await frames(2)


func after_each() -> void:
	game.queue_free()
	await frames(2)


func test_drawing_from_candle_extends_fuse() -> void:
	var c := game.candle_pos()
	touch(0, c, true)
	for i in 20:
		drag(0, c + Vector2(0, -10 * (i + 1)))
	assert_true(game.sim.fuses[0].size() > 20, "fuse grew (%d points)" % game.sim.fuses[0].size())
	assert_true(game.sim.fuses[0].lit, "lit")
	await physics_frames(2)
	assert_eq(game.state, "playing", "round started")
	touch(0, c + Vector2(0, -200), false)


func test_touch_far_from_head_does_not_draw() -> void:
	touch(0, Vector2(80, 300), true)
	drag(0, Vector2(120, 300))
	assert_eq(game.sim.fuses[0].size(), 1, "no stroke from a random spot")
	touch(0, Vector2(120, 300), false)


func test_pause_freezes_simulation() -> void:
	var c := game.candle_pos()
	touch(0, c, true)
	drag(0, c + Vector2(0, -150))
	await physics_frames(5)
	game.pause()
	var t0 := game.sim.time
	await physics_frames(20)
	assert_eq(game.state, "paused", "paused")
	assert_eq(game.sim.time, t0, "sim time frozen while paused")


func test_round_over_shows_results_and_restart_frees_old_round() -> void:
	var c := game.candle_pos()
	touch(0, c, true)
	drag(0, c + Vector2(0, -60))
	touch(0, c + Vector2(0, -60), false)
	var old: WeakRef = weakref(game.sim)
	# Let the short fuse burn down; the finale and game over follow.
	for i in 900:
		await get_tree().physics_frame
		if game.state == "results":
			break
	assert_eq(game.state, "results", "results shown")
	game.new_round()
	await frames(3)
	assert_eq(game.state, "ready", "new round ready")
	assert_true(old.get_ref() == null, "previous round was freed (no reference cycle)")
