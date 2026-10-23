extends Node
## Store screenshots (Play: 9:16, 1080x1920): main menu, a mid-run frame with
## echoes, the dawn results card and the Sternbilder page. Bot-played, debug
## lab button hidden. Usage (Xvfb):
## godot --path game --rendering-driver opengl3 --resolution 1080x1920 res://tests/capture/store_shots.tscn -- <out_dir> save=store_shots.json fresh_save

var out := ""
var bot: EchoBot


func _ready() -> void:
	out = OS.get_cmdline_user_args()[0]
	var save := get_node("/root/Save") as SaveStore
	save.set_setting("ads_preview", false)
	save.data.stats.best_score = 1470
	save.data.stats.rounds_played = 12
	save.data.unlocks = {"dawn": true, "first_echo": true, "solo_wave": true, "nights_10": true}
	save.data.history = []
	for s in [820, 1150, 640, 1330, 1470, 990, 1210]:
		save.data.history.append({"s": s, "w": 5 if s > 1000 else 4, "d": s > 1000, "m": "", "q": s == 1210})
	save.data.onboarding = {"start": true, "alone": true, "echo": true, "echo_note": true, "recharge": true,
		"recharge_note": true, "bank": true, "leak": true, "twins": true, "armor": true, "chain": true, "second": true}
	# 1 main menu
	var menu: Control = load("res://scenes/menus/main_menu.tscn").instantiate()
	add_child(menu)
	for b in menu.find_children("*", "Button", true, false):
		if (b as Button).text.contains("Labor"):
			(b as Button).visible = false
	await _wait(90)
	await _shot("1_menu")
	menu.queue_free()
	# 2 mid-run frame with echoes, 3 results
	var game: EchoGame = load("res://scenes/gameplay/echo_game.tscn").instantiate()
	game.seed_override = 11
	add_child(game)
	await get_tree().process_frame
	var took_run := false
	for i in 60 * 400:
		await get_tree().physics_frame
		var sim := game.sim
		if not took_run and sim.wave_index >= 3 and sim.echoes.size() >= 2 and sim.state == "running" and sim.tick >= 170:
			game.set_physics_process(false)
			await _shot("2_play")
			game.set_physics_process(true)
			took_run = true
		if game.state == "results":
			break
		_drive(game)
	await _wait(150)
	await _shot("3_results")
	game.queue_free()
	await get_tree().process_frame
	# 4 Sternbilder
	var menu2: Control = load("res://scenes/menus/main_menu.tscn").instantiate()
	add_child(menu2)
	menu2.add_child(CollectionPanel.new())
	await _wait(10)
	await _shot("4_sternbilder")
	get_tree().quit()


func _drive(game: EchoGame) -> void:
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


func _wait(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func _shot(name: String) -> void:
	for i in 4:
		await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out, name])
