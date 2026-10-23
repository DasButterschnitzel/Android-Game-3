class_name AdAdapter
extends Node
## Backend interface for AdService. Implementations must never block the game:
## every call resolves (await) even without network, SDK or fill.

## The backend learned the current consent state by itself (e.g. Google's UMP
## update at app start): "granted", "denied", "not_required", or "unknown" when
## a decision is needed again. AdService stores it.
signal consent_info_changed(status: String)


func configure(_config: Dictionary) -> void:
	pass


func is_available() -> bool:
	return true


## Called by AdService once ads are switched on (master switch and, in debug
## builds, the tester toggle); a backend that talks to a network starts here,
## never before. Safe to call more than once.
func start() -> void:
	pass


## Returns "granted", "denied" or "not_required"; "unknown" if no decision was
## possible now (e.g. offline), so AdService asks again at a later break.
## force: show the form even if a decision exists (privacy options).
func request_consent(_force := false) -> String:
	return "not_required"


## True when the player needs a way to change the decision (privacy options).
func privacy_options_required() -> bool:
	return false


## Shows a full-screen ad if one is ready; returns true if it was shown.
func show_interstitial(_personalized: bool) -> bool:
	return false


func supports_rewarded() -> bool:
	return false


## Player-initiated rewarded ad; true only if it was watched to the end.
func show_rewarded(_personalized: bool) -> bool:
	return false
