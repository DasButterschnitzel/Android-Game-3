class_name SmokeTest
extends RefCounted
## Debug builds only (started with `-- --smoke`): loads every important scene
## inside the *exported* build, plays a full NACHHALL round with a bot and a
## short LUNTE round, then quits.
## tools/smoke_exported.sh treats any engine/script error in the log as failure.

const SCENES := [
	"res://scenes/gameplay/echo_game.tscn",
	"res://scenes/gameplay/lunte_game.tscn",
	"res://prototypes/lunte/lunte_proto.tscn",
	"res://prototypes/schwarm/schwarm_proto.tscn",
	"res://prototypes/lab.tscn",
]


static func run(tree: SceneTree) -> void:
	for path in SCENES:
		var scene: PackedScene = load(path)
		if scene == null:
			print("SMOKE FAIL load ", path)
			tree.quit(1)
			return
		var inst := scene.instantiate()
		tree.root.add_child(inst)
		if inst is EchoGame:
			await _play_echo_round(tree, inst)
		elif inst is LunteGame:
			await _play_round(tree, inst)
		else:
			for i in 120:
				await tree.process_frame
		inst.queue_free()
		await tree.process_frame
		print("SMOKE scene ok ", path)
	if not await _check_ads(tree):
		tree.quit(1)
		return
	print("SMOKE OK")
	# Static caches would otherwise be reported as resources leaked at exit.
	UiTheme._cached = null
	ArtKit._glow = null
	ArtKit._atlas = null
	await tree.process_frame
	tree.quit(0)


static func _play_round(tree: SceneTree, g: LunteGame) -> void:
	await tree.process_frame
	var c := g.candle_pos()
	g.sim.grab(0, c)
	g.sim.extend(0, c + Vector2(0, -240))
	g.sim.extend(0, c + Vector2(180, -380))
	g.sim.release(0)
	for i in 1200:
		await tree.physics_frame
		if g.state == "results":
			break
	print("SMOKE round state=%s score=%d" % [g.state, g.sim.score])


## Plays one NACHHALL night with the planning bot by setting the light targets
## (the controller still does the stepping, banking and results).
static func _play_echo_round(tree: SceneTree, g: EchoGame) -> void:
	await tree.process_frame
	var bot := EchoBot.new(g.sim, "early", 520.0)
	for i in 30000:
		await tree.physics_frame
		if g.state == "results":
			break
		var sim := g.sim
		if bot.sim != sim:
			bot = EchoBot.new(sim, "early", 520.0)
		match sim.state:
			"ready", "between":
				if g._bank_timer >= 0.0:
					continue
				if sim.state == "between" and bot.should_bank():
					g._on_bank_pressed()
				else:
					bot.prepare_run()
					sim.begin_run()
					g.targets.clear()
					g.targets.append(sim.live[0].pos)
			"running":
				if not g.targets.is_empty():
					g.targets[0] = sim.live[0].pos + bot.delta()
	print("SMOKE echo round state=%s score=%d waves=%d dawn=%s" % [g.state, g.sim.score, g.sim.stats.waves_banked, str(g.sim.stats.dawn)])


## The ad service in the exported build: the debug placeholders answer
## automatically here; consent is asked, an interstitial passes, nothing blocks.
static func _check_ads(tree: SceneTree) -> bool:
	var ads := tree.root.get_node_or_null("Ads") as AdService
	if ads == null:
		print("SMOKE FAIL ads: no /root/Ads")
		return false
	var save := tree.root.get_node_or_null("Save") as SaveStore
	if save:
		save.set_setting("ads_preview", true)
	print("SMOKE ads adapter=", ads.adapter_name, " enabled=", ads.ads_enabled())
	if ads.adapter_name != "mock":
		return true  # release-like builds: nothing to show
	var mock := ads._adapter as MockAdAdapter
	mock.auto_answer = "denied"
	mock.auto_close = true
	ads.policy.lifetime_rounds = 50
	for i in 10:
		ads.on_round_finished()
	ads._clock += 10000.0
	var shown: bool = await ads.maybe_show_interstitial()
	print("SMOKE ads consent=", ads.consent_status(), " interstitial=", shown)
	return shown and ads.consent_status() == "denied"
