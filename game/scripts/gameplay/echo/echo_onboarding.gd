class_name EchoOnboarding
extends RefCounted
## Teaches NACHHALL inside the first rounds: one short hint at the moment it
## matters, each at most once ever (persisted). No tutorial screens.
## The teaching wave itself does the teaching (one light cannot stop both
## ghosts); the hints only name what the player just saw.

signal hint(text: String)

const HINTS := {
	"start": "Zieh irgendwo auf dem Bildschirm – dein Licht folgt deinem Finger.",
	"alone": "Ein Licht schafft nicht beide. Zieh noch einmal – dein Echo hilft mit!",
	"echo": "Dein Echo wiederholt deinen letzten Lauf: Weg und Treffer. Nimm du den anderen!",
	"recharge": "Nach jedem Treffer glüht dein Licht kurz nach.",
	"bank": "Kassieren: Punkte × Multiplikator. Jedes Licht mehr senkt ihn.",
	"leak": "Wer durchkommt, kostet beim Kassieren eine Flamme. Ohne Flammen ist die Nacht vorbei.",
	"twins": "Zwillinge: Triff beide fast gleichzeitig – mit zwei verschiedenen Lichtern.",
	"armor": "Gepanzert: braucht Treffer von zwei verschiedenen Lichtern.",
	"second": "Profi-Tipp: Ein zweiter Finger entzündet ein zweites Licht (kostet wie ein Lauf).",
}

var _save: SaveStore
var _seen: Dictionary
var _rounds := 0


func _init(save: SaveStore) -> void:
	_save = save
	if _save and not _save.data.has("onboarding"):
		_save.data["onboarding"] = {}
	_seen = _save.data.onboarding if _save else {}


func seen(key: String) -> bool:
	return _seen.has(key)


func show(key: String) -> void:
	if _seen.has(key) or not HINTS.has(key):
		return
	_seen[key] = true
	if _save:
		_save.mark_dirty("onboarding")
	hint.emit(HINTS[key])


func round_started(_sim: EchoSim, rounds_played: int) -> void:
	_rounds = rounds_played
	if not seen("start"):
		show("start")
	elif rounds_played >= 3:
		show("second")


func wave_started(sim: EchoSim) -> void:
	match str(sim.wave_def.get("announce", "")):
		"twins":
			show("twins")
		"armor":
			show("armor")


func run_started(sim: EchoSim) -> void:
	if sim.wave_index == 0 and sim.run_index == 1:
		show("echo")


func run_ended(sim: EchoSim) -> void:
	if sim.state != "between":
		return
	if sim.wave_index == 0 and sim.run_index == 0 and sim.last_run.leaked > 0:
		show("alone")
	elif sim.wave_index >= 1 and sim.last_run.leaked > 0:
		if not seen("bank"):
			show("bank")
		else:
			show("leak")


## Per-tick check: the live light touched a ghost while still recharging.
func tick(sim: EchoSim) -> void:
	if seen("recharge") or sim.live.is_empty():
		return
	var l: Dictionary = sim.live[0]
	if sim.is_charged(l):
		return
	for e in sim.enemies:
		if e.alive and (e.pos as Vector2).distance_to(l.pos) <= float(sim.cfg.hit_radius):
			show("recharge")
			return
