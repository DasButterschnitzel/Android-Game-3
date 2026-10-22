class_name Haptics
extends RefCounted
## Short vibration feedback, respecting the player's setting.
## Android needs the VIBRATE permission for Input.vibrate_handheld; it is a
## normal (install-time, no prompt) permission and declared in the export preset.

static var enabled := true


static func tick(strength := 0.3) -> void:
	_vibrate(12, strength)


static func bump(strength := 0.6) -> void:
	_vibrate(28, strength)


static func heavy() -> void:
	_vibrate(60, 1.0)


static func _vibrate(ms: int, amplitude: float) -> void:
	if not enabled or not OS.has_feature("mobile"):
		return
	Input.vibrate_handheld(ms, clampf(amplitude, 0.0, 1.0))
