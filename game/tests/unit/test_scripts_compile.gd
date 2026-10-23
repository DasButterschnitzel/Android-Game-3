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


## Every non-ASCII character used in a string literal of the game must exist in
## the bundled font (missing glyphs render as empty boxes on devices).
func test_ui_text_glyphs_exist_in_font() -> void:
	var fonts: Array[FontFile] = [load("res://assets/fonts/Fredoka-Medium.ttf"), load("res://assets/fonts/Fredoka-Bold.ttf")]
	var files: Array[String] = []
	for r in ["res://scripts", "res://scenes"]:
		_collect(r, files)
	var missing := {}
	var quote := RegEx.create_from_string("\"([^\"\\\\]|\\\\.)*\"")
	for f in files:
		var text := FileAccess.get_file_as_string(f)
		for line in text.split("\n"):
			if line.strip_edges().begins_with("#"):
				continue  # comments are not shown to players
			for m in quote.search_all(line):
				var lit := m.get_string()
				for i in lit.length():
					var code := lit.unicode_at(i)
					if code < 128:
						continue
					for font in fonts:
						if not font.has_char(code):
							missing["%s in %s" % [lit[i], f.get_file()]] = true
	assert_eq(missing.keys(), [], "glyphs missing from Fredoka")
