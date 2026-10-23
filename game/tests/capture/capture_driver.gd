extends Node
## Plays a game scene with a bot through the real touch input pipeline so the
## result can be recorded with Godot's movie maker (--write-movie) under Xvfb.
## User args (after --): scene=<path> profile=<cautious|normal|greedy> seed=<int>

var scene_path := "res://scenes/gameplay/echo_game.tscn"
var profile := "normal"
var seed_value := 7
var game: Node
var bot: LunteBot
var echo_bot: EchoBot
var down := false
var wait := 0.0
var finger := Vector2(360, 1000)


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=")
		if kv.size() != 2:
			continue
		match kv[0]:
			"scene": scene_path = kv[1]
			"profile": profile = kv[1]
			"seed": seed_value = int(kv[1])
	game = load(scene_path).instantiate()
	if "seed_override" in game:
		game.seed_override = seed_value
	add_child(game)


func _physics_process(dt: float) -> void:
	if game.sim is EchoSim:
		_drive_echo(dt)
		return
	var sim: FuseSim = game.sim
	if bot == null or bot.sim != sim:
		bot = LunteBot.new(sim, profile, seed_value)
		down = false
		wait = 0.6
	if wait > 0.0:
		wait -= dt
		return
	if sim.over:
		if down:
			_touch(0, sim.fuses[0].head(), false)
			down = false
		if sim.finished == false:
			return
		wait = 2.5
		await get_tree().create_timer(2.0).timeout
		_touch(0, Vector2(360, 600), true)
		_touch(0, Vector2(360, 600), false)
		return
	# In offset mode the fingertip sits below the fuse head.
	var off: Vector2 = game.OFFSET if "control_mode" in game and game.control_mode == "offset" else Vector2.ZERO
	var p := bot.next_position(dt)
	if not down:
		_touch(0, sim.fuses[0].head() - off, true)
		down = true
	_drag(0, p - off)


func _xf(p: Vector2) -> Vector2:
	return get_tree().root.get_final_transform() * p


func _touch(i: int, p: Vector2, pressed: bool) -> void:
	var e := InputEventScreenTouch.new()
	e.index = i
	e.position = _xf(p)
	e.pressed = pressed
	Input.parse_input_event(e)
	Input.flush_buffered_events()


func _drag(i: int, p: Vector2) -> void:
	var e := InputEventScreenDrag.new()
	e.index = i
	e.position = _xf(p)
	Input.parse_input_event(e)
	Input.flush_buffered_events()


## NACHHALL: plan with EchoBot, steer the light with real relative drags,
## start runs with the real start-ring gesture, bank and restart by tapping
## the real buttons.
func _drive_echo(dt: float) -> void:
	var sim: EchoSim = game.sim
	if wait > 0.0:
		wait -= dt
		return
	if echo_bot == null or echo_bot.sim != sim:
		echo_bot = EchoBot.new(sim, profile if profile in ["perfect", "early", "solo", "sector", "chaser"] else "early", 520.0)
	if game.state == "results":
		_release()
		if game.again_button and not game.again_button.disabled:
			wait = 2.0
			_tap(game.again_button.get_global_rect().get_center())
		return
	match sim.state:
		"ready", "between":
			if down:
				_release()
				wait = 0.4
				return
			if game._bank_timer >= 0.0 or game._lock > 0.0:
				return
			if sim.state == "between" and echo_bot.should_bank():
				wait = 0.9
				_tap(game.bank_button.get_global_rect().get_center())
				return
			echo_bot.prepare_run()
			finger = Vector2(360, 1000)  # above the bank button, like a resting thumb
			_touch(0, finger, true)
			down = true
			for k in 4:
				finger += Vector2(0, -16)
				_drag(0, finger)
		"running":
			if not down:
				finger = Vector2(360, 1000)
				_touch(0, finger, true)
				down = true
			finger += echo_bot.delta() / float(game.cfg.relative_gain)
			_drag(0, finger)
			# Keep the finger on the glass: lift and put it down again near the middle.
			if finger.x < 40 or finger.x > 680 or finger.y < 320 or finger.y > 1240:
				_release()


func _release() -> void:
	if down:
		_touch(0, finger, false)
		down = false


func _tap(p: Vector2) -> void:
	_touch(0, p, true)
	_touch(0, p, false)
