extends SceneTree
## Headless test runner.
## Usage: godot --headless --path game --script res://tests/run_tests.gd [-- filter]
## Runs every test_* method of every script in tests/unit and tests/integration.
## Exit code 0 = all passed, 1 = failures.

const DIRS := ["res://tests/unit", "res://tests/integration"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var filter := ""
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		filter = args[0]
	var total := 0
	var failed := 0
	var lines: Array[String] = []
	var t0 := Time.get_ticks_msec()
	for dir in DIRS:
		for file in _list(dir):
			if filter != "" and not file.contains(filter):
				continue
			var script: GDScript = load(file)
			if script == null:
				lines.append("LOAD ERROR %s" % file)
				failed += 1
				continue
			var methods: Array[String] = []
			for m in script.get_script_method_list():
				if m.name.begins_with("test_") and not methods.has(m.name):
					methods.append(m.name)
			for m in methods:
				var inst: TestCase = script.new()
				root.add_child(inst)
				inst.current_test = "%s::%s" % [file.get_file(), m]
				if inst.has_method("before_each"):
					await inst.call("before_each")
				await inst.call(m)
				if inst.has_method("after_each"):
					await inst.call("after_each")
				total += 1
				if inst.failures.is_empty():
					lines.append("  ok   %s" % inst.current_test)
				else:
					failed += 1
					lines.append("  FAIL %s" % inst.current_test)
					for f in inst.failures:
						lines.append("       - %s" % f)
				inst.queue_free()
				await process_frame
	for l in lines:
		print(l)
	print("\n%d tests, %d failed (%.1fs)" % [total, failed, (Time.get_ticks_msec() - t0) / 1000.0])
	quit(1 if failed > 0 else 0)


func _list(dir: String) -> Array[String]:
	var out: Array[String] = []
	var d := DirAccess.open(dir)
	if d == null:
		return out
	for f in d.get_files():
		if f.ends_with(".gd") and f.begins_with("test_"):
			out.append(dir.path_join(f))
	out.sort()
	return out
