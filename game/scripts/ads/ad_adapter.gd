class_name AdAdapter
extends Node
## Backend interface for AdService. Implementations must never block the game:
## every call resolves (await) even without network, SDK or fill.


func configure(_config: Dictionary) -> void:
	pass


func is_available() -> bool:
	return true


## Returns "granted", "denied" or "not_required"; "unknown" if no decision was
## possible now (e.g. offline), so AdService asks again at a later break.
## force: show the form even if a decision exists (privacy options).
func request_consent(_force := false) -> String:
	return "not_required"


## Shows a full-screen ad if one is ready; returns true if it was shown.
func show_interstitial(_personalized: bool) -> bool:
	return false
