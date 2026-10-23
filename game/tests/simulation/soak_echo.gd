extends SceneTree
## Soak test: plays many nights in the real game scene (bot through the game's
## own run/bank paths, effects and audio on) and checks that nothing piles up:
## node, object and resource counts at the start of each night must stay flat.
## A bot, not a human; it stands in for "play for 10+ minutes" (device plan E2).
## Usage: godot --headless --path game --script res://tests/simulation/soak_echo.gd -- [nights]

var game: EchoGame
var bot: EchoBot
var nights := 30
var samples: Array = []


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		nights = int(args[0])
	await process_frame
	var save := root.get_node("/root/Save") as SaveStore
	save.path = "user://soak_save.json"
	save.data = SaveStore.defaults()
	save.set_setting("ads_preview", false)
	game = load("res://scenes/gameplay/echo_game.tscn").instantiate()
	game.seed_override = 900
	root.add_child(game)
	var played := 0
	var last_sim: EchoSim = null
	var frames := 0
	while played < nights and frames < nights * 60 * 400:
		frames += 1
		await physics_frame
		if game.state == "results":
			played += 1
			await process_frame
			_sample(played)
			game.again_button.disabled = false
			game._on_again()
			await process_frame
			continue
		_drive()
	_report()
	quit()


func _drive() -> void:
	var sim := game.sim
	if bot == null or bot.sim != sim:
		bot = EchoBot.new(sim, "early", 600.0)
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


func _sample(night: int) -> void:
	samples.append({
		"night": night,
		"nodes": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		"objects": int(Performance.get_monitor(Performance.OBJECT_COUNT)),
		"resources": int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)),
		"orphans": int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)),
		"mem_mb": snappedf(Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0, 0.1),
	})


func _report() -> void:
	print("SOAK nights=%d" % samples.size())
	for s in samples:
		if s.night <= 3 or s.night % 5 == 0:
			print("SOAK night %d nodes %d objects %d resources %d orphans %d mem %.1f MB" % [s.night, s.nodes, s.objects, s.resources, s.orphans, s.mem_mb])
	if samples.size() < 6:
		print("SOAK FAIL too few nights")
		return
	# Compare the steady state (after warm-up) with the end.
	var a: Dictionary = samples[3]
	var b: Dictionary = samples[samples.size() - 1]
	var ok := true
	for k in ["nodes", "objects", "resources", "orphans"]:
		var grow: int = int(b[k]) - int(a[k])
		var limit := 50 if k == "objects" else 10
		print("SOAK %s night %d -> %d: %+d (limit %d)" % [k, a.night, b.night, grow, limit])
		if grow > limit:
			ok = false
	print("SOAK %s" % ("OK" if ok else "FAIL growth"))
