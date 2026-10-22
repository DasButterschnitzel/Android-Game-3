class_name TouchDebugOverlay
extends Control
## Optional on-screen visualisation of every tracked pointer (id, path, velocity).
## Toggled from the settings menu; used during playtests to diagnose touch issues.

@export var tracker_path: NodePath
var _tracker: PointerTracker
var _trails: Dictionary = {}  # id -> PackedVector2Array
var _events: Array[String] = []

const TRAIL_LEN := 40
const COLORS := [Color("#ff5d5d"), Color("#5dd1ff"), Color("#ffd95d"), Color("#7dff8a"), Color("#d77dff")]


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_tracker = get_node_or_null(tracker_path)
	if _tracker:
		_tracker.pointer_down.connect(func(p): _log("down #%d" % p.id))
		_tracker.pointer_up.connect(func(p): _log("up #%d" % p.id); _trails.erase(p.id))
		_tracker.pointer_cancelled.connect(func(p): _log("CANCEL #%d" % p.id); _trails.erase(p.id))


func _log(s: String) -> void:
	_events.push_front("%6.2f %s" % [Time.get_ticks_msec() / 1000.0, s])
	if _events.size() > 8:
		_events.pop_back()


func _process(_delta: float) -> void:
	if not visible or _tracker == null:
		return
	for p in _tracker.pointers.values():
		var t: PackedVector2Array = _trails.get(p.id, PackedVector2Array())
		t.append(p.pos)
		if t.size() > TRAIL_LEN:
			t = t.slice(t.size() - TRAIL_LEN)
		_trails[p.id] = t
	queue_redraw()


func _draw() -> void:
	if _tracker == null:
		return
	var font := ThemeDB.fallback_font
	for p in _tracker.pointers.values():
		var c: Color = COLORS[p.id % COLORS.size()]
		var t: PackedVector2Array = _trails.get(p.id, PackedVector2Array())
		if t.size() > 1:
			draw_polyline(t, Color(c, 0.5), 3.0, true)
		draw_arc(p.pos, 46.0, 0, TAU, 32, c, 3.0, true)
		draw_line(p.pos, p.pos + p.velocity * 0.05, c, 2.0, true)
		draw_string(font, p.pos + Vector2(52, -40), "#%d  %.0f px/s" % [p.id, p.velocity.length()], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, c)
	var y := 140.0
	draw_string(font, Vector2(16, y - 26), "touches: %d" % _tracker.count(), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
	for e in _events:
		draw_string(font, Vector2(16, y), e, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1, 1, 1, 0.8))
		y += 24
