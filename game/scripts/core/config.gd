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
