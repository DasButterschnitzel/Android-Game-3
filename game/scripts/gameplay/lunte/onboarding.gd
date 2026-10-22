class_name Onboarding
extends RefCounted
## Teaches LUNTE inside the first rounds, one short hint at the moment it
## matters, each hint at most once ever (persisted). No tutorial screens.

signal hint(text: String)

const HINTS := {
	"thread": "Aufgefädelt! Der Funke zündet es, wenn er dort ankommt.",
	"rocket": "Raketen fliegen in Pfeilrichtung und zünden alles auf ihrem Weg.",
	"banger": "Böller: Führe deine Lunte nicht noch einmal durch ihren roten Kreis.",
	"heat": "Nah am Funken zählt mehr – aber dann faucht er auf und springt.",
	"spool": "Die Lunte wird knapp. Jede Zündung gibt dir Lunte zurück.",
	"loop": "Tipp: Umkreise Feuerwerk mit deiner Lunte – Kurzschluss!",
	"dawn": "Halte bis zum Morgengrauen durch: Dann zündet alles zum vollen Wert.",
}

var _save: SaveStore
var _seen: Dictionary


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


var _sim: FuseSim  # current round (lambdas use this instead of capturing the sim)


## Watches a running round and fires hints when their topic first appears.
## Note: lambdas must not capture the sim they are connected to (that would be
## a reference cycle keeping every finished round alive).
func watch(sim: FuseSim, rounds_played: int) -> void:
	_sim = sim
	sim.firework_threaded.connect(func(_fw): show("thread"))
	sim.firework_spawned.connect(func(fw):
		if fw.kind == FuseSim.Kind.BANGER:
			show("banger")
		elif fw.kind == FuseSim.Kind.ROCKET and _sim and _sim.time > 2.0:
			show("rocket"))
	if rounds_played >= 3 and not seen("loop"):
		sim.fuse_started.connect(func(_id): show("loop"))


## Per-frame checks for state-based hints.
func tick(sim: FuseSim) -> void:
	if sim.sparks.size() > 0 and not sim.over:
		if sim.heat_level() >= 2 and sim.time > 6.0:
			show("heat")
		if sim.spool < 500.0 and sim.time > 5.0:
			show("spool")
		if sim.night_progress() > 0.5:
			show("dawn")
