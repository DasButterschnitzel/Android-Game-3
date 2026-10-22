extends Node
## Plays a prototype with a bot through the real touch input pipeline so the
## result can be recorded with Godot's movie maker (--write-movie) under Xvfb.
## User args (after --): scene=<path> profile=<cautious|normal|greedy> seed=<int>

var scene_path := "res://prototypes/lunte/lunte_proto.tscn"
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


## ECHO: plan with EchoBot, steer the light with real relative drags, bank by
## tapping the actual button.
func _drive_echo(_dt: float) -> void:
	var sim: EchoSim = game.sim
	if wait > 0.0:
		wait -= _dt
		return
	if echo_bot == null or echo_bot.sim != sim:
		echo_bot = EchoBot.new(sim, profile if profile in ["perfect", "early", "solo", "sector"] else "early", 380.0)
	match sim.state:
		"over":
			if down:
				_touch(0, finger, false)
				down = false
			wait = 2.5
			_touch(0, Vector2(360, 700), true)
			_touch(0, Vector2(360, 700), false)
		"between":
			if down:
				_touch(0, finger, false)
				down = false
			wait = 1.2
			if echo_bot.should_bank():
				var c: Vector2 = game.bank_button.get_global_rect().get_center()
				_touch(0, c, true)
				_touch(0, c, false)
			else:
				_start_drag()
		"ready":
			echo_bot.prepare_run()
			_start_drag()
		"running":
			if not down:
				_start_drag()
			var d := echo_bot.delta() / float(game.cfg.relative_gain)
			finger += d
			_drag(0, finger)


func _start_drag() -> void:
	if not down:
		finger = Vector2(360, 1000)
		_touch(0, finger, true)
		down = true
	for k in 3:
		finger += Vector2(0, -6)
		_drag(0, finger)
