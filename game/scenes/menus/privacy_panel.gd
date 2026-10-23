class_name PrivacyPanel
extends Control
## In-app privacy information. The text mirrors docs/compliance/PRIVACY_POLICY.md;
## the authoritative version must be hosted at a public URL before release.

const BASE := """Dieses Spiel funktioniert vollständig offline und ohne Konto.

Gespeichert wird nur lokal auf deinem Gerät: Einstellungen, Bestwerte und Freischaltungen. Diese Daten verlassen dein Gerät nicht."""

const ADS_NONE := """Werbung: Diese Version zeigt keine Werbung und hat keine Internet-Berechtigung."""

const ADS_MOCK := """Werbung (Testversion): An einigen Pausen erscheinen deutlich markierte Werbe-PLATZHALTER. Es wird keine echte Werbung geladen und nichts gesendet; die Version hat keine Internet-Berechtigung. Die Einwilligungsfrage nach der zweiten Nacht ist ebenfalls nur ein Test-Ablauf."""

const ADS_ADMOB := """Werbung (Werbetest-Version): Diese Version lädt TESTANZEIGEN von Google AdMob über das Internet. Dabei verarbeitet Google Daten wie die Werbe-ID, IP-Adresse und Geräteinformationen. Vorher fragt dich ein Einwilligungsdialog von Google (UMP); ohne Zustimmung gibt es nur nicht personalisierte Anzeigen. Das Spiel selbst bleibt offline spielbar."""

const FOOTER := """Keine Käufe, keine Echtgeld-Währung, keine Energie-Sperren."""


static func text_for(adapter: String) -> String:
	var ads: String = {"mock": ADS_MOCK, "admob": ADS_ADMOB}.get(adapter, ADS_NONE)
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
	var adapter: String = ads.adapter_name if ads and ads.has_method("ads_enabled") and ads.ads_enabled() else "none"
	var body := UiTheme.label(text_for(adapter), 26, UiTheme.TEXT_DIM)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(body)
	if adapter != "none":  # only when ads can appear at all
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
