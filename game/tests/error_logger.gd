extends Logger
## Counts engine/script errors so the test runner can fail a test that
## crashed half-way (GDScript has no exceptions; a failing call just returns).

var _mutex := Mutex.new()
var errors: Array[String] = []


func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
	_mutex.lock()
	errors.append("[%s] %s:%d %s %s %s" % [["ERROR", "WARNING", "SCRIPT", "SHADER"][clampi(error_type, 0, 3)], file.get_file(), line, function, code, rationale])
	_mutex.unlock()


func _log_message(_message: String, _error: bool) -> void:
	pass


func take() -> Array[String]:
	_mutex.lock()
	var out := errors.duplicate()
	errors.clear()
	_mutex.unlock()
	return out
