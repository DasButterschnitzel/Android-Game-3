class_name AdPolicy
extends RefCounted
## Pure decision logic for interstitial frequency (no SDK, fully testable).
##
## Conservative defaults from the brief: never in the first rounds of a
## session, at most one interstitial per N finished rounds, never more often
## than every few minutes, never mid-round, never on app resume, and never
## when ads are disabled (debug switch) or consent is pending.

var min_rounds_before_first := 3
var rounds_between := 4
var min_seconds_between := 180.0
var min_lifetime_rounds := 5  # brand-new players get their first nights ad-free
var enabled := true
var lifetime_rounds := 0  # finished nights ever (from the save), set by the caller
## Wall-clock time (unix seconds) of the last interstitial, from the save, so the
## time cap also holds after an app restart; 0 = none yet.
var last_shown_unix := 0.0

var _rounds_since_last := 0
var _rounds_this_session := 0
var _last_shown_at := -1.0e9  # seconds (monotonic clock supplied by caller)


func configure(cfg: Dictionary) -> void:
	min_rounds_before_first = int(cfg.get("min_rounds_before_first", min_rounds_before_first))
	rounds_between = int(cfg.get("rounds_between", rounds_between))
	min_seconds_between = float(cfg.get("min_seconds_between", min_seconds_between))
	min_lifetime_rounds = int(cfg.get("min_lifetime_rounds", min_lifetime_rounds))
	enabled = bool(cfg.get("interstitials_enabled", enabled))


## Call once per finished round (game over / dawn), not on restarts or quits.
func on_round_finished() -> void:
	_rounds_since_last += 1
	_rounds_this_session += 1
	lifetime_rounds += 1


## Natural break check, e.g. when the player leaves the results screen.
## consent_ready: the consent flow has completed (granted or not).
## now_unix: wall clock for the cap across restarts (< 0: not checked; a clock
## set back before the last ad cannot be judged, the in-session cap still holds).
func should_show_interstitial(now_sec: float, consent_ready: bool, now_unix := -1.0) -> bool:
	if not enabled or not consent_ready:
		return false
	if lifetime_rounds < min_lifetime_rounds:
		return false
	if _rounds_this_session < min_rounds_before_first:
		return false
	if _rounds_since_last < rounds_between:
		return false
	if now_sec - _last_shown_at < min_seconds_between:
		return false
	if now_unix >= 0.0 and last_shown_unix > 0.0:
		var since := now_unix - last_shown_unix
		if since >= 0.0 and since < min_seconds_between:
			return false
	return true


func on_interstitial_shown(now_sec: float, now_unix := -1.0) -> void:
	_rounds_since_last = 0
	_last_shown_at = now_sec
	if now_unix >= 0.0:
		last_shown_unix = now_unix


## Ratio of rounds with an ad in a steady stream of rounds of given length
## (used to document the worst-case ad load).
func worst_case_ads_per_hour(round_seconds: float) -> float:
	var by_rounds := 3600.0 / (round_seconds * rounds_between)
	var by_time := 3600.0 / min_seconds_between
	return minf(by_rounds, by_time)
