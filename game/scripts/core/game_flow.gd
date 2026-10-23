class_name GameFlow
extends CanvasLayer
## Scene flow with a short fade (autoload "Flow").
## Keeps transitions in one place so every screen change looks the same and
## input is blocked while fading (no double taps starting two rounds).

signal scene_changed(path: String)

const FADE := 0.18
var _rect: ColorRect
var _busy := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	var save := get_node_or_null("/root/Save") as SaveStore
	if save:  # before the first screen is built
		UiTheme.set_text_scale(float(save.get_setting("text_scale")))
	_rect = ColorRect.new()
	_rect.color = Color(0.03, 0.03, 0.08, 0.0)
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)


func go(path: String) -> void:
	if _busy:
		return
	_busy = true
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw := create_tween()
	tw.tween_property(_rect, "color:a", 1.0, FADE)
	await tw.finished
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	var tw2 := create_tween()
	tw2.tween_property(_rect, "color:a", 0.0, FADE)
	await tw2.finished
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false
	scene_changed.emit(path)


func is_busy() -> bool:
	return _busy


## Debug builds: colour-vision simulation over every screen (0 = off,
## 1 protan, 2 deutan, 3 tritan, 4 greyscale). See docs/art/ART_REVIEW_0.4.md P2-12.
var _cvd: CanvasLayer


func set_cvd_mode(mode: int) -> void:
	if _cvd:
		_cvd.queue_free()
		_cvd = null
	if mode <= 0:
		return
	_cvd = CanvasLayer.new()
	_cvd.layer = 99
	var rect := ColorRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/cvd_debug.gdshader")
	mat.set_shader_parameter("mode", mode)
	rect.material = mat
	_cvd.add_child(rect)
	add_child(_cvd)


## Android back button / gesture (and Escape on desktop). The topmost visible
## node in group "back_handler" whose on_back() returns true consumes it.
## project setting application/config/quit_on_go_back is off, so leaving the
## app is an explicit decision of the main menu, never an accident mid-run.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		handle_back()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		handle_back()


func handle_back() -> bool:
	if _busy:
		return true
	var handlers := get_tree().get_nodes_in_group("back_handler")
	for i in range(handlers.size() - 1, -1, -1):
		var h: Node = handlers[i]
		if h is CanvasItem and not (h as CanvasItem).is_visible_in_tree():
			continue
		if h.has_method("on_back") and h.on_back():
			return true
	return false
