class_name EchoOnboarding
extends RefCounted
## Teaches NACHHALL inside the first rounds: one short hint at the moment it
## matters, each at most once ever (persisted). No tutorial screens.
## Keys "echo" and "recharge" are short labels shown at the object during a
## run; their "_note" partners explain the same thing at the next break.
## The teaching wave itself does the teaching (one light cannot stop both
## ghosts); the hints only name what the player just saw.

signal hint(key: String, text: String)

const HINTS := {
	"start": "Zieh irgendwo auf dem Bildschirm – dein Licht folgt deinem Finger.",
	"alone": "Ein Licht schafft nicht beide. Zieh noch einmal – dein Echo hilft mit!",
	"echo": "Dein Echo",
	"recharge": "lädt …",
	"echo_note": "Dein Echo wiederholt deinen letzten Lauf: Weg und Treffer. Nimm du den anderen!",
	"recharge_note": "Nach jedem Treffer glüht dein Licht 1 Sekunde nach – dann trifft es wieder.",
	"bank": "Kassieren: Punkte × Multiplikator. Jedes Licht mehr senkt ihn.",
	"leak": "Wer durchkommt, kostet beim Kassieren eine Flamme. Ohne Flammen ist die Nacht vorbei.",
	"twins": "Zwillinge: Triff beide fast gleichzeitig – mit zwei verschiedenen Lichtern.",
	"armor": "Gepanzert: braucht Treffer von zwei verschiedenen Lichtern.",
	"chain": "Kette: Ein Schlag trifft alle Schatten in seiner Nähe. Führ dein Licht zwischen zwei Glieder – dann fallen beide.",
	"second": "Profi-Tipp: Ein zweiter Finger entzündet ein zweites Licht (kostet wie ein Lauf).",
}

var _save: SaveStore
var _seen: Dictionary
var _rounds := 0
## The "second finger = second light" setting; its tip only makes sense when on.
var second_finger := true


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
	hint.emit(key, HINTS[key])


func round_started(_sim: EchoSim, rounds_played: int) -> void:
	_rounds = rounds_played
	if not seen("start"):
		show("start")
	elif rounds_played >= 3 and second_finger:
		show("second")


func wave_started(sim: EchoSim) -> void:
	match str(sim.wave_def.get("announce", "")):
		"twins":
			show("twins")
		"armor":
			show("armor")
		_:
			if sim.wave_formation == "kette":
				show("chain")


func run_started(sim: EchoSim) -> void:
	if sim.wave_index == 0 and sim.run_index == 1:
		show("echo")
		show("echo_note")


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
			show("recharge_note")
			return
