extends Node
## Hardware-independent render metrics while a bot plays (run under Xvfb with
## the GL Compatibility renderer): draw calls, primitives and objects per frame,
## script time per frame. Frame times under llvmpipe are NOT phone numbers.
## Usage: xvfb-run godot --path game --rendering-driver opengl3 --fixed-fps 60 res://tests/capture/perf_probe.tscn -- seed=11

var game: EchoGame
var samples: Array = []
var frame := 0
var echo_bot: EchoBot


func _ready() -> void:
	game = load("res://scenes/gameplay/echo_game.tscn").instantiate()
	game.seed_override = 11
	add_child(game)


func _physics_process(_dt: float) -> void:
	var sim := game.sim
	if echo_bot == null or echo_bot.sim != sim:
		echo_bot = EchoBot.new(sim, "perfect", 600.0)
	match sim.state:
		"ready", "between":
			if game._bank_timer >= 0.0:
				return
			if sim.state == "between" and echo_bot.should_bank():
				game._on_bank_pressed()
			else:
				echo_bot.prepare_run()
				sim.begin_run()
				game.targets.clear()
				game.targets.append(sim.live[0].pos)
		"running":
			if not game.targets.is_empty():
				game.targets[0] = sim.live[0].pos + echo_bot.delta()


func _process(_dt: float) -> void:
	frame += 1
	if frame < 30:
		return
	var rs := RenderingServer
	samples.append({
		"draw_calls": rs.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		"primitives": rs.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
		"objects": rs.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
		"process_ms": Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		"view_draw_ms": EchoView.draw_usec / 1000.0,
		"echoes": game.sim.echoes.size(),
		"state": game.sim.state,
	})
	if game.state == "results" or frame > 60 * 120:
		_report()


func _report() -> void:
	var by_echoes := {}
	for s in samples:
		if s.state != "running":
			continue
		var k: int = s.echoes
		if not by_echoes.has(k):
			by_echoes[k] = []
		by_echoes[k].append(s)
	print("PERF echoes | frames | draw calls p50/max | primitives p50/max | objects max | frame ms p50/max | EchoView._draw ms p50/max")
	for k in by_echoes.keys():
		var rows: Array = by_echoes[k]
		print("PERF %d | %d | %s | %s | %d | %s | %s" % [k, rows.size(), _pm(rows, "draw_calls"), _pm(rows, "primitives"), _mx(rows, "objects"), _pm(rows, "process_ms"), _pm(rows, "view_draw_ms", 2)])
	get_tree().quit()


func _pm(rows: Array, key: String, digits := 1) -> String:
	var v: Array = rows.map(func(r): return float(r[key]))
	v.sort()
	var f := "%%.%df/%%.%df" % [digits, digits]
	return f % [v[v.size() / 2], v[v.size() - 1]]


func _mx(rows: Array, key: String) -> int:
	var m := 0
	for r in rows:
		m = maxi(m, int(r[key]))
	return m
