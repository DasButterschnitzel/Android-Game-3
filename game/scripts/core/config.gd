class_name Config
extends RefCounted
## Loads balancing JSON from res://data/balance. Values stay data-driven so
## simulations can sweep them without code changes.

static func load_balance(name: String) -> Dictionary:
	var path := "res://data/balance/%s.json" % name
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Config: cannot open %s" % path)
		return {}
	var data = JSON.parse_string(f.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Config: invalid JSON in %s" % path)
		return {}
	return data


## Returns a copy of base with overrides applied (for parameter sweeps).
static func with_overrides(base: Dictionary, overrides: Dictionary) -> Dictionary:
	var out := base.duplicate(true)
	for k in overrides:
		out[k] = overrides[k]
	return out


## Balance of a game mode: the base file with modes/<mode> applied on top
## ("" or an unknown mode returns the base unchanged).
static func load_mode(name: String, mode: String) -> Dictionary:
	var base := load_balance(name)
	var modes: Dictionary = base.get("modes", {})
	if mode == "" or not modes.has(mode):
		return base
	var over: Dictionary = modes[mode].duplicate(true)
	over.erase("_comment")
	return with_overrides(base, over)


## Number of today's daily night (#1 = 2026-10-22, the day NACHHALL was born).
static func daily_number() -> int:
	var epoch := Time.get_unix_time_from_datetime_string("2026-10-22T00:00:00")
	var today := Time.get_unix_time_from_datetime_string(Time.get_date_string_from_system() + "T00:00:00")
	return int((today - epoch) / 86400) + 1
