extends SceneTree
## Renders one scene and saves a screenshot: --script res://tests/capture/shot.gd -- <scene> <out.png> [frames]
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var scene: PackedScene = load(args[0])
	root.add_child(scene.instantiate())
	var frames := int(args[2]) if args.size() > 2 else 5
	for i in frames:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(args[1])
	print("saved ", args[1])
	quit()
