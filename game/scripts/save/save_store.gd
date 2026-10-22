class_name SaveStore
extends Node
## Local, offline persistence (autoload "Save").
##
## One JSON document in user:// with a schema version. Writes are atomic
## (write temp file, then rename) so a kill during saving never corrupts the
## previous state. A corrupt file is moved aside and defaults are used.

signal changed(key: String)

const SCHEMA_VERSION := 1
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
			"control_mode": "direct",  # "direct" (finger = fuse head) or "relative" (trackpad)
			"left_handed": false,
		},
		"stats": {
			"best_score": 0,
			"rounds_played": 0,
			"total_ignitions": 0,
			"best_chain": 0,
			"longest_round": 0.0,
			"dawns": 0,
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
	data = _merge(defaults(), json.data)
	data.version = SCHEMA_VERSION


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


## Records a finished round; returns true if it is a new best score.
func record_round(score: int, ignitions: int, best_chain: int, duration: float) -> bool:
	var s: Dictionary = data.stats
	s.rounds_played += 1
	s.total_ignitions += ignitions
	s.best_chain = maxi(s.best_chain, best_chain)
	s.longest_round = maxf(s.longest_round, duration)
	var is_best: bool = score > s.best_score
	if is_best:
		s.best_score = score
	mark_dirty("stats")
	return is_best


func _notification(what: int) -> void:
	# Persist immediately when the app is backgrounded or closed.
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _dirty:
			save_now()
