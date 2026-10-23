class_name Progression
extends RefCounted
## Achievements ("Sternbilder") and purely cosmetic unlocks (lantern papers),
## earned by playing well, never bought and never needed to win.
## Evaluated once per finished night from its result and the lifetime stats.

## id -> {name, text, test}
const ACHIEVEMENTS := {
	"first_echo": {"name": "Erstes Echo", "text": "Eine Welle mit Hilfe eines Echos perfekt verteidigt."},
	"dawn": {"name": "Morgengrauen", "text": "Eine Nacht überstanden."},
	"dawn_full": {"name": "Alle Flammen", "text": "Das Morgengrauen mit allen drei Flammen erreicht."},
	"solo_wave": {"name": "Allein", "text": "Eine Welle mit nur einem Licht perfekt verteidigt."},
	"score_1000": {"name": "Tausend", "text": "1.000 Punkte in einer Nacht."},
	"score_1500": {"name": "Leuchtfeuer", "text": "1.500 Punkte in einer Nacht."},
	"perfect_25": {"name": "Ruhige Hand", "text": "25 perfekte Wellen insgesamt."},
	"nights_10": {"name": "Nachtwache", "text": "10 Nächte gespielt."},
	"daily": {"name": "Tagesnacht", "text": "Eine Tagesnacht gespielt."},
	"duo": {"name": "Zwei Hände", "text": "Mit einem zweiten Finger ein zweites Licht entzündet."},
}

## Lantern papers: id -> {name, paper, rib, unlock (achievement id or "" = always)}
const PAPERS := {
	"classic": {"name": "Klassisch", "paper": Color("#ffd58a"), "rib": Color("#e0a656"), "unlock": ""},
	"blossom": {"name": "Kirschblüte", "paper": Color("#ffc2d6"), "rib": Color("#e58aa9"), "unlock": "dawn"},
	"midnight": {"name": "Mitternacht", "paper": Color("#9fd2ff"), "rib": Color("#5f95d6"), "unlock": "perfect_25"},
	"gold": {"name": "Gold", "paper": Color("#ffe58a"), "rib": Color("#d4a72c"), "unlock": "score_1500"},
	"ink": {"name": "Tusche", "paper": Color("#e9e4f2"), "rib": Color("#2b2440"), "unlock": "dawn_full"},
}


## Evaluates a finished night. round: {score, survived, flames_left, perfect_waves,
## solo_perfect, echo_perfect, daily, duo}. stats: lifetime stats after recording.
## Returns the ids of achievements unlocked by this night (also stored in unlocks).
static func evaluate(round: Dictionary, stats: Dictionary, unlocks: Dictionary) -> Array[String]:
	var earned: Array[String] = []
	var check := func(id: String, cond: bool) -> void:
		if cond and not unlocks.has(id):
			unlocks[id] = true
			earned.append(id)
	check.call("first_echo", bool(round.get("echo_perfect", false)))
	check.call("dawn", bool(round.get("survived", false)))
	check.call("dawn_full", bool(round.get("survived", false)) and int(round.get("flames_left", 0)) >= 3)
	check.call("solo_wave", bool(round.get("solo_perfect", false)))
	check.call("score_1000", int(round.get("score", 0)) >= 1000)
	check.call("score_1500", int(round.get("score", 0)) >= 1500)
	check.call("perfect_25", int(stats.get("perfect_waves", 0)) >= 25)
	check.call("nights_10", int(stats.get("rounds_played", 0)) >= 10)
	check.call("daily", bool(round.get("daily", false)))
	check.call("duo", bool(round.get("duo", false)))
	return earned


static func paper_unlocked(id: String, unlocks: Dictionary) -> bool:
	if not PAPERS.has(id):
		return false
	var need: String = PAPERS[id].unlock
	return need == "" or unlocks.has(need)


## Papers whose unlock is part of `earned` (for the results screen).
static func papers_for(earned: Array[String]) -> Array[String]:
	var out: Array[String] = []
	for id in PAPERS:
		if earned.has(PAPERS[id].unlock):
			out.append(id)
	return out
