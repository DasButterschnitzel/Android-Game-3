extends Node
## Draw calls per layer of one frozen mid-run frame (wave 4, two echoes):
## draws the scene once complete and then each EchoView layer alone.
## Usage: xvfb-run godot --path game --rendering-driver opengl3 --resolution 720x1280 res://tests/capture/draw_breakdown.tscn

var game: EchoGame
var bot: EchoBot


func _ready() -> void:
	game = load("res://scenes/gameplay/echo_game.tscn").instantiate()
	game.seed_override = 11
	add_child(game)
	await get_tree().process_frame
	while not (game.sim.wave_index >= 3 and game.sim.echoes.size() >= 2 and game.sim.state == "running" and game.sim.tick >= 150):
		_drive()
		await get_tree().physics_frame
	game.set_physics_process(false)  # freeze the run
	for a in OS.get_cmdline_user_args():
		if a.begins_with("shot="):  # screenshot of the complete frozen frame
			EchoView.only_layers = PackedStringArray()
			for i in 4:
				await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(a.substr(5))
	var rows := []
	rows.append(["all", await _measure([], true, true)])
	rows.append(["(sky only)", await _measure(["-"], false, false)])
	rows.append(["hud", await _measure(["-"], true, false)])
	rows.append(["particles", await _measure(["-"], false, true)])
	for layer in EchoView.LAYERS:
		rows.append([layer, await _measure([layer], false, false)])
	var base: Vector3i = rows[1][1]
	print("DRAW layer | draw calls | primitives | objects | calls minus sky-only")
	for r in rows:
		var v: Vector3i = r[1]
		print("DRAW %s | %d | %d | %d | %d" % [r[0], v.x, v.y, v.z, v.x - base.x])
	get_tree().quit()


func _measure(layers: Array, hud: bool, fx: bool) -> Vector3i:
	EchoView.only_layers = PackedStringArray(layers)
	game.hud.visible = hud
	game.bank_button.visible = false
	game.fx.visible = fx
	game.view.queue_redraw()
	for i in 4:
		await RenderingServer.frame_post_draw
	return Vector3i(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME))


func _drive() -> void:
	var sim := game.sim
	if bot == null or bot.sim != sim:
		bot = EchoBot.new(sim, "perfect", 600.0)
	match sim.state:
		"ready", "between":
			if game._bank_timer >= 0.0:
				return
			if sim.state == "between" and bot.should_bank():
				game._on_bank_pressed()
			else:
				bot.prepare_run()
				sim.begin_run()
				game.targets.clear()
				game.targets.append(sim.live[0].pos)
		"running":
			if not game.targets.is_empty():
				game.targets[0] = sim.live[0].pos + bot.delta()
