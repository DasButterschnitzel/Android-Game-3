class_name SaveStore
extends Node
## Local, offline persistence (autoload "Save").
##
## One JSON document in user:// with a schema version. Writes are atomic
## (write temp file, then rename) so a kill during saving never corrupts the
## previous state; the previous file is kept as <path>.bak, the last good copy
## if the newest one comes back broken (e.g. a power loss before the storage
## flushed it; GDScript cannot fsync). A corrupt file is moved aside, then the
## backup or the defaults are used.

signal changed(key: String)

const SCHEMA_VERSION := 2
const DEFAULT_PATH := "user://save.json"
const HISTORY_SIZE := 30  # nights kept for the chart on the Sternbilder page

var path := DEFAULT_PATH
var data: Dictionary = {}
var _dirty := false
var _flush_scheduled := false


static func defaults() -> Dictionary:
	return {
		"version": SCHEMA_VERSION,
		"settings": {
			"master_volume": 0.9,
			"music_volume": 0.6,
			"sfx_volume": 0.9,
			"muted": false,
			"haptics": true,
			"effects": 1.0,  # 1.0 full, 0.5 reduced, 0.0 minimal (no shake, flashes, shockwaves or flicker)
			"touch_debug": false,
			"control_mode": "direct",  # LUNTE lab only: "direct", "offset" or "relative"
			"second_finger": true,  # a second finger lights a second light
			"sensitivity": 1.0,  # relative control gain factor: 0.75 low, 1.0 normal, 1.3 high
			"lantern_paper": "classic",  # cosmetic, see Progression.PAPERS
			"ads_preview": true,  # debug builds: show the marked ad placeholders
		},
		"stats": {
			"best_score": 0,
			"rounds_played": 0,
			"dawns": 0,
			"waves_banked": 0,
			"perfect_waves": 0,
			"lights": 0,
			"play_seconds": 0.0,
			"best_fullmoon": 0,  # best score in the "Vollmond" mode
		},
		"daily": {
			"date": "",  # YYYY-MM-DD of the last daily night played
			"best": 0,  # best score of that night
			"played": 0,  # rounds of that night
		},
		"lab": {
			"lunte_best": 0,  # parked prototype, debug lab only
		},
		"unlocks": {},
		"history": [],  # last nights, newest last: {s: score, w: waves banked, d: dawn, m: mode, q: daily}
		"onboarding": {},  # hint key -> true once shown
		"paper_trial": "",  # locked lantern paper lent for the next night (rewarded ad)
		"pending_daily": false,
		"pending_mode": "",  # "" normal night, "fullmoon"
		"ads": {
			"consent": "unknown",  # unknown | granted | denied | not_required
			"last_interstitial_unix": 0,  # wall clock of the last interstitial (time cap across restarts)
		},
	}


func _ready() -> void:
	# Debug builds: tests, captures and smoke runs can use their own save file
	# (user arg save=<file name>) so they never touch a player's progress.
	if OS.is_debug_build():
		var args := OS.get_cmdline_user_args()
		for a in args:
			if a.begins_with("save="):
				path = "user://" + a.substr(5).get_file()
		if "fresh_save" in args and path != DEFAULT_PATH:
			remove_files(path)
	load_from_disk()


## Deletes a save file with its temp and backup copies (tests, fresh runs).
static func remove_files(file: String) -> void:
	for f in [file, file + ".tmp", file + ".bak"]:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(f))


func load_from_disk() -> void:
	data = defaults()
	var loaded: Variant = _read_json(path)
	if loaded == null and FileAccess.file_exists(path):
		_quarantine_corrupt()
	if loaded == null:
		loaded = _read_json(path + ".bak")
		if loaded != null:
			push_warning("SaveStore: %s unreadable, using the last good copy" % path)
	if loaded == null:
		return
	data = _merge(defaults(), _migrate(loaded))
	data.version = SCHEMA_VERSION
	Progression.backfill(data.stats, data.unlocks)


## The document in a file, or null if it is missing or not a JSON object.
static func _read_json(file: String) -> Variant:
	if not FileAccess.file_exists(file):
		return null
	var f := FileAccess.open(file, FileAccess.READ)
	if f == null:
		return null
	var json := JSON.new()
	var err := json.parse(f.get_as_text())
	f.close()
	if err != OK or typeof(json.data) != TYPE_DICTIONARY:
		return null
	return json.data


## Upgrades older documents before merging.
## v1 -> v2: stats belonged to the LUNTE prototype; they are not carried over.
static func _migrate(loaded: Dictionary) -> Dictionary:
	var v := int(loaded.get("version", 1))
	if v < 2:
		loaded.erase("stats")
		loaded.erase("onboarding")
	return loaded


## Deep-merges loaded values over defaults so new keys appear after updates
## and unknown/obsolete keys are dropped.
static func _merge(base: Dictionary, loaded: Dictionary) -> Dictionary:
	var out := base.duplicate(true)
	for k in base:
		if not loaded.has(k):
			continue
		if typeof(base[k]) == TYPE_DICTIONARY and typeof(loaded[k]) == TYPE_DICTIONARY:
			if base[k].is_empty():
				out[k] = loaded[k].duplicate(true)  # open-ended maps (e.g. unlocks)
			else:
				out[k] = _merge(base[k], loaded[k])
		elif typeof(base[k]) == typeof(loaded[k]) or (_is_num(base[k]) and _is_num(loaded[k])):
			out[k] = loaded[k]
	return out


static func _is_num(v: Variant) -> bool:
	return typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT


func _quarantine_corrupt() -> void:
	var bad := path + ".corrupt"
	DirAccess.rename_absolute(ProjectSettings.globalize_path(path), ProjectSettings.globalize_path(bad))
	push_warning("SaveStore: corrupt save moved to %s, using defaults" % bad)


func save_now() -> bool:
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("SaveStore: cannot write %s (retried with the next change)" % tmp)
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	var real := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(path):
		DirAccess.rename_absolute(real, real + ".bak")  # the last good copy
	var err := DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), real)
	_dirty = err != OK
	return err == OK


## Marks data dirty; flushed at the end of the frame (coalesces many writes).
## After a failed write the next change schedules a new attempt.
func mark_dirty(key := "") -> void:
	changed.emit(key)
	_dirty = true
	if not _flush_scheduled:
		_flush_scheduled = true
		_flush_deferred.call_deferred()


func _flush_deferred() -> void:
	_flush_scheduled = false
	if _dirty:
		save_now()


func get_setting(key: String) -> Variant:
	return data.settings.get(key)


func set_setting(key: String, value: Variant) -> void:
	data.settings[key] = value
	mark_dirty("settings/" + key)


## Records a finished NACHHALL round; returns true if it is a new best score.
## Daily nights also keep their own best for the day.
func record_echo_round(score: int, round_stats: Dictionary, duration: float, daily := false, mode := "") -> bool:
	var s: Dictionary = data.stats
	s.rounds_played += 1
	s.waves_banked += int(round_stats.get("waves_banked", 0))
	s.perfect_waves += int(round_stats.get("perfect_waves", 0))
	s.lights += int(round_stats.get("lights", 0))
	s.play_seconds += duration
	if round_stats.get("dawn", false):
		s.dawns += 1
	var is_best := false
	if mode == "fullmoon":
		is_best = score > int(s.best_fullmoon)
		if is_best:
			s.best_fullmoon = score
	else:
		is_best = score > s.best_score
		if is_best:
			s.best_score = score
	var h: Array = data.history
	h.append({"s": score, "w": int(round_stats.get("waves_banked", 0)), "d": bool(round_stats.get("dawn", false)),
		"m": mode, "q": daily})
	while h.size() > HISTORY_SIZE:
		h.pop_front()
	if daily:
		var today := Time.get_date_string_from_system()
		var d: Dictionary = data.daily
		if d.date != today:
			d.date = today
			d.best = 0
			d.played = 0
		d.played += 1
		d.best = maxi(d.best, score)
	mark_dirty("stats")
	return is_best


## LUNTE (parked prototype in the debug lab) keeps a separate best score.
func record_lunte_round(score: int) -> bool:
	var is_best: bool = score > int(data.lab.lunte_best)
	if is_best:
		data.lab.lunte_best = score
		mark_dirty("lab")
	return is_best


func _notification(what: int) -> void:
	# Persist immediately when the app is backgrounded or closed.
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _dirty:
			save_now()
