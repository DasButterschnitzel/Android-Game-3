class_name Progression
extends RefCounted
## Achievements ("Sternbilder") and purely cosmetic unlocks (lantern papers),
## earned by playing well, never bought and never needed to win.
## Evaluated once per finished night from its result and the lifetime stats.

## id -> {name, text (earned), goal (still open)}
const ACHIEVEMENTS := {
	"first_echo": {"name": "Erstes Echo", "text": "Eine Welle mit Hilfe eines Echos perfekt verteidigt.", "goal": "Verteidige eine Welle mit Hilfe eines Echos perfekt."},
	"dawn": {"name": "Morgengrauen", "text": "Eine Nacht überstanden.", "goal": "Halte die Laterne bis zum Morgengrauen am Leben."},
	"dawn_full": {"name": "Alle Flammen", "text": "Das Morgengrauen mit allen drei Flammen erreicht.", "goal": "Erreiche das Morgengrauen mit allen drei Flammen."},
	"solo_wave": {"name": "Allein", "text": "Eine Welle mit nur einem Licht perfekt verteidigt.", "goal": "Verteidige eine Welle mit nur einem Licht perfekt."},
	"score_1000": {"name": "Tausend", "text": "1.000 Punkte in einer Nacht.", "goal": "Erreiche 1.000 Punkte in einer Nacht."},
	"score_1500": {"name": "Leuchtfeuer", "text": "1.500 Punkte in einer Nacht.", "goal": "Erreiche 1.500 Punkte in einer Nacht."},
	"perfect_25": {"name": "Ruhige Hand", "text": "25 perfekte Wellen insgesamt.", "goal": "Verteidige insgesamt 25 Wellen perfekt."},
	"nights_10": {"name": "Nachtwache", "text": "10 Nächte gespielt.", "goal": "Spiele 10 Nächte."},
	"daily": {"name": "Tagesnacht", "text": "Eine Tagesnacht gespielt.", "goal": "Spiele eine Tagesnacht."},
	"duo": {"name": "Zwei Hände", "text": "Mit einem zweiten Finger ein zweites Licht entzündet.", "goal": "Entzünde mit einem zweiten Finger ein zweites Licht."},
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


## The closest open Sternbild as a concrete next goal for the results card:
## a counted one ("18/25 perfekte Wellen") once it is at least half done,
## otherwise the first open one-time goal, otherwise the best counted one.
## {} when everything is unlocked.
static func next_goal(stats: Dictionary, unlocks: Dictionary) -> Dictionary:
	var best := int(stats.get("best_score", 0))
	var counted := {
		"perfect_25": [int(stats.get("perfect_waves", 0)), 25, "perfekte Wellen"],
		"nights_10": [int(stats.get("rounds_played", 0)), 10, "Nächte"],
		"score_1000": [best, 1000, "Punkte (Bestwert)"],
		"score_1500": [best, 1500, "Punkte (Bestwert)"],
	}
	var top := ""
	var top_p := -1.0
	for id in counted:
		if unlocks.has(id):
			continue
		var p := float(counted[id][0]) / float(counted[id][1])
		if p > top_p:
			top_p = p
			top = id
	var counted_goal := func(id: String) -> Dictionary:
		var c: Array = counted[id]
		return {"id": id, "name": ACHIEVEMENTS[id].name,
			"hint": "%s / %s %s" % [EchoHud.fmt(mini(int(c[0]), int(c[1]))), EchoHud.fmt(int(c[1])), c[2]]}
	if top != "" and top_p >= 0.5:
		return counted_goal.call(top)
	for id in ["first_echo", "solo_wave", "dawn", "duo", "daily", "dawn_full"]:
		if not unlocks.has(id):
			return {"id": id, "name": ACHIEVEMENTS[id].name, "hint": ACHIEVEMENTS[id].goal}
	if top != "":
		return counted_goal.call(top)
	return {}


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
