class_name AdMobAdapter
extends AdAdapter
## Placeholder for the Google AdMob backend (Android plugin + UMP consent).
##
## Not active: integrating it needs a Gradle Android build with a third-party
## AdMob plugin and, for real ads, an AdMob account of the owner. Until then
## is_available() is false and AdService falls back to "no ads". The intended
## wiring (test ad unit IDs from data/ads.json only) is documented in
## docs/compliance/ADS_AND_CONSENT.md.

func is_available() -> bool:
	return false  # no plugin bridge yet (see above); AdService then shows no ads
