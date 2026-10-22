extends TestCase
## The ECHO prototype maps relative finger motion to the light exactly once.

var game: Node


func before_each() -> void:
	game = load("res://prototypes/echo/echo_proto.tscn").instantiate()
	game.seed_override = 11
	add_child(game)
	await frames(2)


func after_each() -> void:
	game.queue_free()
	await frames(1)


func test_drag_starts_run_and_moves_light_relatively() -> void:
	var sim: EchoSim = game.sim
	assert_eq(sim.state, "ready", "waiting for a drag")
	touch(0, Vector2(360, 1000), true)
	for i in 4:
		drag(0, Vector2(360, 1000 - 6 * (i + 1)))
	assert_eq(sim.state, "running", "drag started the run")
	await physics_frames(2)
	var start: Vector2 = sim.live_pos[0]
	var finger := Vector2(360, 976)
	for i in 10:
		finger += Vector2(10, 0)
		drag(0, finger)
		await physics_frames(1)
	await physics_frames(2)
	var moved: Vector2 = sim.live_pos[0] - start
	var expected := 100.0 * float(game.cfg.relative_gain)
	assert_near(moved.x, expected, 2.0, "x moved by finger delta x gain")
	assert_near(moved.y, 0.0, 2.0, "no vertical drift")
	touch(0, finger, false)
