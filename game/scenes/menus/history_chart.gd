class_name HistoryChart
extends Control
## The last nights as bars, newest on the right: height = score, warm with a
## small sun on top = dawn reached (shape as well as colour), dim = lantern
## out; under a bar a dot marks a daily night, a ring a Vollmond night (its own
## mode, so it may top the dashed line, the normal best score). Progress made
## visible, no streak to keep.

const LEGEND := "Sonne: Morgengrauen · Punkt: Tagesnacht · Ring: Vollmond · Linie: Bestwert"

const SHOWN := 15

var nights: Array = []
var best := 0


func _init(history: Array = [], best_score := 0) -> void:
	nights = history.slice(maxi(0, history.size() - SHOWN))
	best = best_score
	custom_minimum_size = Vector2(0, 150)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	if nights.is_empty():
		return
	var top := maxi(best, 1)
	for n in nights:
		top = maxi(top, int(n.get("s", 0)))
	var w := size.x
	var h := size.y - 24.0
	var hb := h - 16.0  # room for the dawn sun above the highest bar
	var slot := w / SHOWN
	var bw := slot * 0.62
	for i in nights.size():
		var n: Dictionary = nights[i]
		var x := w - (nights.size() - i) * slot + (slot - bw) * 0.5
		var bh := maxf(4.0, hb * float(n.get("s", 0)) / top)
		var dawn := bool(n.get("d", false))
		draw_rect(Rect2(x, h - bh, bw, bh), UiTheme.ACCENT if dawn else Color(UiTheme.TEXT_DIM, 0.55))
		if dawn:
			draw_circle(Vector2(x + bw * 0.5, h - bh - 8.0), 5.0, UiTheme.PAPER)
		if str(n.get("m", "")) == "fullmoon":
			draw_arc(Vector2(x + bw * 0.5, h + 12), 5.0, 0.0, TAU, 16, UiTheme.TEXT, 2.0)
		elif bool(n.get("q", false)):
			draw_circle(Vector2(x + bw * 0.5, h + 12), 4.0, UiTheme.TEXT_DIM)
	draw_line(Vector2(0, h), Vector2(w, h), Color(1, 1, 1, 0.15), 2.0)
	if best > 0:
		var by := h - hb * float(best) / top
		draw_dashed_line(Vector2(0, by), Vector2(w, by), Color(UiTheme.GOOD, 0.7), 2.0, 8.0)


## "Ø der letzten 10: 1.234 · Morgengrauen 4 von 10" (or a hint before the first night).
static func summary(history: Array) -> String:
	if history.is_empty():
		return "Noch keine Nacht gespielt."
	var last := history.slice(maxi(0, history.size() - 10))
	var total := 0
	var dawns := 0
	for n in last:
		total += int(n.get("s", 0))
		if bool(n.get("d", false)):
			dawns += 1
	return "Ø der letzten %d: %s · Morgengrauen %d von %d" % [last.size(), EchoHud.fmt(total / last.size()), dawns, last.size()]
