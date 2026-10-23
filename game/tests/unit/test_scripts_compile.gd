extends TestCase
## Every game script must load without parse or compile errors, including
## scripts no other test touches (menus, views, prototypes).

const ROOTS := ["res://scripts", "res://scenes", "res://prototypes"]
const ErrorLogger := preload("res://tests/error_logger.gd")


func test_all_scripts_compile() -> void:
	var files: Array[String] = []
	for r in ROOTS:
		_collect(r, files)
	assert_true(files.size() > 20, "found the game scripts (%d)" % files.size())
	for f in files:
		var s := load(f) as GDScript
		assert_true(s != null and s.can_instantiate(), "%s compiles" % f)


func _collect(dir: String, out: Array[String]) -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	for f in d.get_files():
		if f.ends_with(".gd"):
			out.append(dir.path_join(f))
	for sub in d.get_directories():
		_collect(dir.path_join(sub), out)
