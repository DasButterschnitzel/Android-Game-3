extends TestCase
## Android lifecycle without a device: the notifications Godot delivers when the
## app goes to the background, comes back or loses focus, sent through the tree.

var game: EchoGame
var save: SaveStore


func before_each() -> void:
	save = get_node("/root/Save") as SaveStore
	save.set_setting("muted", false)
	game = load("res://scenes/gameplay/echo_game.tscn").instantiate()
	game.seed_override = 31
	add_child(game)
	await frames(2)


func after_each() -> void:
	game.queue_free()
	# Back in the foreground for the next test (the audio keeps the app state).
	_send(Node.NOTIFICATION_APPLICATION_RESUMED)
	_send(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	AudioServer.set_bus_mute(0, false)
	await frames(2)


func _send(what: int) -> void:
	get_tree().root.propagate_notification(what)


func _start_run() -> void:
	var p := Vector2(360, game.sim.start_pos.y + 120)
	touch(0, p, true)
	for i in 5:
		drag(0, p + Vector2(0, -16 * (i + 1)))
	touch(0, p + Vector2(0, -80), false)


func test_backgrounding_mid_run_pauses_mutes_and_saves() -> void:
	_start_run()
	await physics_frames(10)
	assert_eq(game.sim.state, "running", "a run is going")
	save.set_setting("sensitivity", 1.3)  # an unsaved change
	_send(Node.NOTIFICATION_APPLICATION_PAUSED)
	await frames(2)
	assert_eq(game.state, "paused", "the night waits in the pause menu")
	assert_true(AudioServer.is_bus_mute(0), "silent in the background")
	var f := FileAccess.open(save.path, FileAccess.READ)
	assert_true(f != null, "save written when backgrounded")
	if f:
		var data = JSON.parse_string(f.get_as_text())
		assert_eq(float(data.settings.sensitivity), 1.3, "including the latest change")
	var tick: int = game.sim.tick
	await physics_frames(20)
	assert_eq(game.sim.tick, tick, "time does not run while away")
	_send(Node.NOTIFICATION_APPLICATION_RESUMED)
	await frames(2)
	assert_false(AudioServer.is_bus_mute(0), "sound back on return")
	assert_eq(game.state, "paused", "but the night stays paused until the player continues")
	save.set_setting("sensitivity", 1.0)


func test_returning_keeps_a_chosen_mute() -> void:
	save.set_setting("muted", true)
	_send(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_send(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	await frames(1)
	assert_true(AudioServer.is_bus_mute(0), "muted in the settings stays muted after returning")
	save.set_setting("muted", false)
	_send(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	await frames(1)
	assert_false(AudioServer.is_bus_mute(0), "unmuted again")


## Android can resume the app behind the lock screen: no sound until the
## window has focus again.
func test_resumed_without_focus_stays_silent() -> void:
	_send(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_send(Node.NOTIFICATION_APPLICATION_PAUSED)
	_send(Node.NOTIFICATION_APPLICATION_RESUMED)
	assert_true(AudioServer.is_bus_mute(0), "resumed but not focused: still silent")
	_send(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	assert_false(AudioServer.is_bus_mute(0), "focused again: sound back")


func test_focus_loss_between_runs_drops_fingers_without_a_pause_menu() -> void:
	var p := Vector2(360, game.sim.start_pos.y + 120)
	touch(0, p, true)  # finger down, then the notification shade comes down
	_send(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await frames(2)
	assert_eq(game.state, "play", "nothing to pause between runs")
	assert_true(game._steer.is_empty(), "the resting finger is forgotten")
	for i in 5:
		drag(0, p + Vector2(0, -16 * (i + 1)))
	await physics_frames(2)
	assert_eq(game.sim.state, "ready", "a stale finger cannot start a run after returning")
	touch(0, p, false)
