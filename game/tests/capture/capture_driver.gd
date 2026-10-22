extends Node
## Plays a prototype with a bot through the real touch input pipeline so the
## result can be recorded with Godot's movie maker (--write-movie) under Xvfb.
## User args (after --): scene=<path> profile=<cautious|normal|greedy> seed=<int>

var scene_path := "res://prototypes/lunte/lunte_proto.tscn"
var profile := "normal"
var seed_value := 7
var game: Node
var bot: LunteBot
var down := false
var wait := 0.0


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
		wait = 2.5
		await get_tree().create_timer(2.0).timeout
		_touch(0, Vector2(360, 600), true)
		_touch(0, Vector2(360, 600), false)
		return
	var p := bot.next_position(dt)
	if not down:
		_touch(0, sim.fuses[0].head(), true)
		down = true
	_drag(0, p)


func _xf(p: Vector2) -> Vector2:
	return get_tree().root.get_final_transform() * p


func _touch(i: int, p: Vector2, pressed: bool) -> void:
	var e := InputEventScreenTouch.new()
	e.index = i
	e.position = _xf(p)
	e.pressed = pressed
	Input.parse_input_event(e)


func _drag(i: int, p: Vector2) -> void:
	var e := InputEventScreenDrag.new()
	e.index = i
	e.position = _xf(p)
	Input.parse_input_event(e)
