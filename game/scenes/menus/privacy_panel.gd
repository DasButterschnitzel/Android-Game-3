class_name PrivacyPanel
extends Control
## In-app privacy information. The text mirrors docs/compliance/PRIVACY_POLICY.md;
## the authoritative version must be hosted at a public URL before release.

const BASE := """Dieses Spiel funktioniert vollständig offline und ohne Konto.

Gespeichert wird nur lokal auf deinem Gerät: Einstellungen, Bestwerte und Freischaltungen. Diese Daten verlassen dein Gerät nicht."""

const ADS_NONE := """Werbung: Diese Version zeigt keine Werbung und hat keine Internet-Berechtigung."""

const ADS_MOCK := """Werbung (Testversion): An einigen Pausen erscheinen deutlich markierte Werbe-PLATZHALTER. Es wird keine echte Werbung geladen und nichts gesendet; die Version hat keine Internet-Berechtigung. Die Einwilligungsfrage nach der zweiten Nacht ist ebenfalls nur ein Test-Ablauf."""

const ADS_ADMOB := """Werbung (Werbetest-Version): Diese Version lädt TESTANZEIGEN von Google AdMob über das Internet. Dabei verarbeitet Google Daten wie die Werbe-ID, IP-Adresse und Geräteinformationen. Schon beim Start fragt die Einwilligungsplattform von Google (UMP) ab, ob für dein Land eine Einwilligung nötig ist; den Dialog dazu zeigt das Spiel nach einer beendeten Nacht. Ohne Zustimmung gibt es nur nicht personalisierte oder eingeschränkte Anzeigen. Das Spiel selbst bleibt offline spielbar."""

const ADS_ADMOB_OFF := """Die Testanzeigen sind gerade ausgeschaltet; dann wird nichts geladen."""

const FOOTER := """Keine Käufe, keine Echtgeld-Währung, keine Energie-Sperren."""

const APP_INFO_PATH := "res://data/app.json"


## Owner-provided release info (data/app.json): privacy policy URL and contact.
static func app_info(path := APP_INFO_PATH) -> Dictionary:
	var data = JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else null
	if typeof(data) != TYPE_DICTIONARY:
		return {"privacy_policy_url": "", "contact_email": ""}
	return {"privacy_policy_url": str(data.get("privacy_policy_url", "")).strip_edges(),
		"contact_email": str(data.get("contact_email", "")).strip_edges()}


## adapter: the active backend; active false: ads are switched off right now.
static func text_for(adapter: String, active := true) -> String:
	var ads: String = {"mock": ADS_MOCK, "admob": ADS_ADMOB}.get(adapter, ADS_NONE)
	if adapter == "admob" and not active:
		ads += " " + ADS_ADMOB_OFF
	return "\n\n".join([BASE, ads, FOOTER])


func _ready() -> void:
	add_to_group("back_handler")
	theme = UiTheme.get_theme()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = UiTheme.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 40
	box.offset_right = -40
	box.offset_top = 90 + SafeArea.top(get_viewport())
	box.offset_bottom = -60 - SafeArea.bottom(get_viewport())
	add_child(box)
	box.add_child(UiTheme.label("Datenschutz", 48, UiTheme.TEXT, true))
	var ads := get_node_or_null("/root/Ads")
	var active: bool = ads != null and ads.has_method("ads_enabled") and ads.ads_enabled()
	var adapter: String = ads.adapter_name if active else "none"
	if OS.has_feature(AdService.ADS_TEST_FEATURE):
		adapter = "admob"  # this APK contains the SDK and INTERNET even while ads are off
	var body := UiTheme.label(text_for(adapter, active), 26, UiTheme.TEXT_DIM)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(body)
	var info := app_info()
	if info.contact_email != "":
		box.add_child(UiTheme.label("Kontakt: " + info.contact_email, 24, UiTheme.TEXT_DIM))
	if info.privacy_policy_url.begins_with("https://"):
		var policy := UiTheme.button("Vollständige Datenschutzerklärung")
		policy.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var url: String = info.privacy_policy_url
		policy.pressed.connect(func(): OS.shell_open(url))  # opens the browser; the app itself needs no INTERNET
		box.add_child(policy)
	if active and ads.privacy_options_available():  # Google: only where it is required
		var consent := UiTheme.button("Werbe-Einwilligung ändern")
		consent.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		consent.pressed.connect(func(): ads.show_consent_form())
		box.add_child(consent)
	var back := UiTheme.primary_button("Zurück")
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(queue_free)
	box.add_child(back)


## Android back closes the panel.
func on_back() -> bool:
	queue_free()
	return true
