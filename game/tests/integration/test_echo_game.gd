extends TestCase
## NACHHALL game scene through the real touch input pipeline.

var game: EchoGame


func before_each() -> void:
	var save := get_node("/root/Save") as SaveStore
	save.set_setting("second_finger", true)
	save.data["pending_daily"] = false
	game = load("res://scenes/gameplay/echo_game.tscn").instantiate()
	game.seed_override = 21
	add_child(game)
	await frames(2)


func after_each() -> void:
	game.queue_free()
	await frames(2)


## A point well away from every button where a thumb would rest.
func rest_point() -> Vector2:
	return Vector2(360, game.sim.start_pos.y + 120)


## Starts a run with a deliberate pull and lifts the finger.
func start_run_and_release() -> void:
	var p := rest_point()
	touch(0, p, true)
	for i in 5:
		drag(0, p + Vector2(0, -16 * (i + 1)))
	touch(0, p + Vector2(0, -80), false)


func wait_run_end(limit := 900) -> void:
	for i in limit:
		if game.sim.state != "running":
			return
		await physics_frames(1)


func test_jitter_inside_the_ring_does_not_start_a_run() -> void:
	var p := rest_point()
	touch(0, p, true)
	for i in 30:
		drag(0, p + Vector2(sin(i) * 12.0, cos(i * 1.3) * 12.0))
	await physics_frames(3)
	assert_eq(game.sim.state, "ready", "finger jitter keeps the light in its ring")
	touch(0, p, false)


func test_pulling_out_of_the_ring_starts_and_steers_relatively() -> void:
	var p := rest_point()
	touch(0, p, true)
	for i in 5:
		drag(0, p + Vector2(0, -16 * (i + 1)))
	assert_eq(game.sim.state, "running", "pull out of the ring starts the run")
	await physics_frames(20)
	var start: Vector2 = game.sim.live[0].pos
	var finger := p + Vector2(0, -80)
	for i in 10:
		finger += Vector2(10, 0)
		drag(0, finger)
		await physics_frames(1)
	await physics_frames(20)
	var moved: Vector2 = game.sim.live[0].pos - start
	assert_near(moved.x, 100.0 * float(game.cfg.relative_gain), 2.0, "light moved by finger delta x gain")
	assert_near(moved.y, 0.0, 2.0, "no drift")
	touch(0, finger, false)


func test_fast_swipe_lags_but_does_not_drift() -> void:
	start_run_and_release()
	await physics_frames(2)
	var p := rest_point()
	touch(0, p, true)
	var start: Vector2 = game.sim.live[0].pos
	drag(0, p + Vector2(-150, 0))  # one big jump: far beyond one tick of top speed
	await physics_frames(1)
	var after_one: Vector2 = game.sim.live[0].pos
	assert_true(start.distance_to(after_one) <= float(game.cfg.max_light_speed) / 60.0 + 0.01, "speed limit holds")
	await physics_frames(30)
	assert_near(game.sim.live[0].pos.x - start.x, -150.0 * float(game.cfg.relative_gain), 2.0, "catches up with the finger")
	touch(0, p + Vector2(-150, 0), false)


func test_resting_finger_cannot_start_the_next_run() -> void:
	var p := rest_point()
	touch(0, p, true)
	for i in 5:
		drag(0, p + Vector2(0, -16 * (i + 1)))
	await wait_run_end()
	assert_eq(game.sim.state, "between", "run over, finger still down")
	var finger := p + Vector2(0, -80)
	for i in 20:
		finger += Vector2(0, -8)
		drag(0, finger)
		await physics_frames(1)
	assert_eq(game.sim.state, "between", "the old finger is consumed")
	touch(0, finger, false)
	await frames(30)  # start lock
	touch(0, p, true)
	for i in 5:
		drag(0, p + Vector2(0, -16 * (i + 1)))
	assert_eq(game.sim.state, "running", "a fresh deliberate pull starts the next run")
	touch(0, p, false)


func test_first_teaching_wave_cannot_be_banked_before_seeing_an_echo() -> void:
	var save := get_node("/root/Save") as SaveStore
	save.data.onboarding.erase("echo")
	start_run_and_release()
	await wait_run_end()
	await frames(2)
	assert_eq(game.sim.state, "between", "first run over")
	assert_false(game.bank_button.visible, "no bank button: run again with your echo")
	save.data.onboarding["echo"] = true
	await frames(2)
	assert_true(game.bank_button.visible, "after the echo lesson banking is allowed")


func test_bank_button_banks_without_moving_the_light() -> void:
	(get_node("/root/Save") as SaveStore).data.onboarding["echo"] = true
	start_run_and_release()
	await wait_run_end()
	await frames(2)
	assert_eq(game.sim.state, "between", "run over")
	assert_true(game.sim.last_run.leaked > 0, "idle run let ghosts through")
	assert_true(game.bank_button.visible, "bank button shown")
	var ring_light := game.ready_pos
	var c := game.bank_button.get_global_rect().get_center()
	touch(0, c, true)
	touch(0, c, false)
	await frames(2)
	assert_eq(game.sim.wave_index, 1, "banked: next wave")
	assert_vec_near(game.ready_pos, ring_light, 1.0, "tapping the button does not move the light")


func test_second_finger_needs_a_deliberate_drag() -> void:
	var p := rest_point()
	touch(0, p, true)
	for i in 5:
		drag(0, p + Vector2(0, -16 * (i + 1)))
	assert_eq(game.sim.live.size(), 1, "one light")
	var q := Vector2(150, 900)
	touch(1, q, true)
	drag(1, q + Vector2(15, 0))
	await physics_frames(1)
	assert_eq(game.sim.live.size(), 1, "a resting or brushing second finger does nothing")
	for i in 4:
		drag(1, q + Vector2(15 + 10 * (i + 1), 0))
	await physics_frames(1)
	assert_eq(game.sim.live.size(), 2, "a deliberate drag lights a second light")
	assert_eq(game.sim.multiplier(), float(game.cfg.light_multipliers[1]), "costs like a second run")
	touch(1, q, false)
	touch(0, p, false)


func test_pause_freezes_the_run() -> void:
	start_run_and_release()
	await physics_frames(5)
	game.pause()
	var t0 := game.sim.tick
	await physics_frames(20)
	assert_eq(game.state, "paused", "paused")
	assert_eq(game.sim.tick, t0, "run frozen while paused")
	game.resume_play()
	await physics_frames(5)
	assert_true(game.sim.tick > t0, "runs again after resume")


func test_lost_night_shows_results_and_restarts() -> void:
	(get_node("/root/Save") as SaveStore).data.onboarding["echo"] = true
	game.sim.core_hp = 1
	start_run_and_release()
	await wait_run_end()
	await frames(2)
	var c := game.bank_button.get_global_rect().get_center()
	touch(0, c, true)
	touch(0, c, false)
	await frames(2)
	assert_eq(game.state, "results", "night over")
	assert_true(game.again_button != null and game.again_button.disabled, "restart briefly locked")
	var old: WeakRef = weakref(game.sim)
	await get_tree().create_timer(1.4).timeout
	assert_false(game.again_button.disabled, "restart unlocked")
	var a := game.again_button.get_global_rect().get_center()
	touch(0, a, true)
	touch(0, a, false)
	await frames(3)
	assert_eq(game.state, "play", "new round")
	assert_eq(game.sim.state, "ready", "fresh night")
	assert_eq(old.get_ref(), null, "old round freed")


func test_android_back_pauses_and_resumes() -> void:
	var flow := get_node("/root/Flow") as GameFlow
	start_run_and_release()
	await physics_frames(3)
	assert_true(flow.handle_back(), "back is handled, the app does not quit mid-run")
	assert_eq(game.state, "paused", "back pauses a running night")
	flow.handle_back()
	assert_eq(game.state, "play", "back again resumes")


func test_hud_and_buttons_respect_the_safe_area() -> void:
	SafeArea.override = Vector4(0, 60, 0, 40)
	game.new_round()
	await frames(3)
	assert_near(game.hud.position.y, 60.0, 0.01, "HUD below the camera cut-out")
	assert_true(game.sim.arena.position.y >= 210.0, "field below HUD and cut-out")
	(get_node("/root/Save") as SaveStore).data.onboarding["echo"] = true
	start_run_and_release()
	await wait_run_end()
	await frames(2)
	var r := game.bank_button.get_global_rect()
	assert_true(r.end.y <= game.get_viewport_rect().size.y - 40.0, "bank button above the gesture bar")
	SafeArea.override = Vector4(-1, -1, -1, -1)
