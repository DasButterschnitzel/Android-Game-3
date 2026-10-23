class_name SaveStore
extends Node
## Local, offline persistence (autoload "Save").
##
## One JSON document in user:// with a schema version. Writes are atomic
## (write temp file, then rename) so a kill during saving never corrupts the
## previous state. A corrupt file is moved aside and defaults are used.

signal changed(key: String)

const SCHEMA_VERSION := 2
const DEFAULT_PATH := "user://save.json"

var path := DEFAULT_PATH
var data: Dictionary = {}
var _dirty := false


static func defaults() -> Dictionary:
	return {
		"version": SCHEMA_VERSION,
		"settings": {
			"master_volume": 0.9,
			"music_volume": 0.6,
			"sfx_volume": 0.9,
			"muted": false,
			"haptics": true,
			"effects": 1.0,  # 1.0 full, 0.5 reduced, 0.0 minimal (shake/flash off)
			"touch_debug": false,
			"control_mode": "direct",  # LUNTE lab only: "direct", "offset" or "relative"
			"left_handed": false,
			"second_finger": true,  # a second finger lights a second light
			"sensitivity": 1.0,  # relative control gain factor: 0.75 low, 1.0 normal, 1.3 high
		},
		"stats": {
			"best_score": 0,
			"rounds_played": 0,
			"dawns": 0,
			"waves_banked": 0,
			"perfect_waves": 0,
			"lights": 0,
			"play_seconds": 0.0,
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
		"onboarding": {},  # hint key -> true once shown
		"pending_daily": false,
		"ads": {
			"consent": "unknown",  # unknown | granted | denied | not_required
			"rounds_since_interstitial": 0,
			"last_interstitial_unix": 0,
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
		if "fresh_save" in args and path != DEFAULT_PATH and FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	load_from_disk()


func load_from_disk() -> void:
	data = defaults()
	if not FileAccess.file_exists(path):
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return
	var json := JSON.new()
	var err := json.parse(f.get_as_text())
	f.close()
	if err != OK or typeof(json.data) != TYPE_DICTIONARY:
		_quarantine_corrupt()
		return
	data = _merge(defaults(), _migrate(json.data))
	data.version = SCHEMA_VERSION


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
		push_error("SaveStore: cannot write %s" % tmp)
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	var err := DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), ProjectSettings.globalize_path(path))
	_dirty = err != OK
	return err == OK


## Marks data dirty; flushed at the end of the frame (coalesces many writes).
func mark_dirty(key := "") -> void:
	changed.emit(key)
	if not _dirty:
		_dirty = true
		_flush_deferred.call_deferred()


func _flush_deferred() -> void:
	if _dirty:
		save_now()


func get_setting(key: String) -> Variant:
	return data.settings.get(key)


func set_setting(key: String, value: Variant) -> void:
	data.settings[key] = value
	mark_dirty("settings/" + key)


## Records a finished NACHHALL round; returns true if it is a new best score.
## Daily nights also keep their own best for the day.
func record_echo_round(score: int, round_stats: Dictionary, duration: float, daily := false) -> bool:
	var s: Dictionary = data.stats
	s.rounds_played += 1
	s.waves_banked += int(round_stats.get("waves_banked", 0))
	s.perfect_waves += int(round_stats.get("perfect_waves", 0))
	s.lights += int(round_stats.get("lights", 0))
	s.play_seconds += duration
	if round_stats.get("dawn", false):
		s.dawns += 1
	var is_best: bool = score > s.best_score
	if is_best:
		s.best_score = score
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
