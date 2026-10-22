class_name SmokeTest
extends RefCounted
## Debug builds only (started with `-- --smoke`): loads every important scene
## inside the *exported* build, plays a scripted LUNTE round, then quits.
## tools/smoke_exported.sh treats any engine/script error in the log as failure.

const SCENES := [
	"res://scenes/gameplay/lunte_game.tscn",
	"res://prototypes/lunte/lunte_proto.tscn",
	"res://prototypes/echo/echo_proto.tscn",
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
		if inst is LunteGame:
			await _play_round(tree, inst)
		else:
			for i in 120:
				await tree.process_frame
		inst.queue_free()
		await tree.process_frame
		print("SMOKE scene ok ", path)
	print("SMOKE OK")
	# Static caches would otherwise be reported as resources leaked at exit.
	UiTheme._cached = null
	ArtKit._glow = null
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
