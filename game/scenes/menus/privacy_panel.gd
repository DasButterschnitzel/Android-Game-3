class_name PrivacyPanel
extends Control
## In-app privacy information. The text mirrors docs/compliance/PRIVACY_POLICY.md;
## the authoritative version must be hosted at a public URL before release.

const TEXT := """Dieses Spiel funktioniert vollständig offline und ohne Konto.

Gespeichert wird nur lokal auf deinem Gerät: Einstellungen, Bestwerte und Freischaltungen. Diese Daten verlassen dein Gerät nicht.

Werbung: Diese Version enthält keine Werbung und hat keine Internet-Berechtigung. Eine spätere Version kann Werbung eines Werbenetzwerks anzeigen; dann wirst du vorher um deine Einwilligung gebeten (z. B. für personalisierte Werbung) und kannst sie hier jederzeit ändern.

Keine Käufe, keine Echtgeld-Währung, keine Energie-Sperren."""


func _ready() -> void:
	theme = UiTheme.get_theme()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = UiTheme.BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 40
	box.offset_right = -40
	box.offset_top = 90
	box.offset_bottom = -60
	add_child(box)
	box.add_child(UiTheme.label("Datenschutz", 48, UiTheme.TEXT, true))
	var body := UiTheme.label(TEXT, 28, UiTheme.TEXT_DIM)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(body)
	var ads := get_node_or_null("/root/Ads")
	if ads and ads.has_method("show_consent_form"):  # only when an ad service exists
		var consent := UiTheme.button("Werbe-Einwilligung ändern")
		consent.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		consent.pressed.connect(func(): ads.show_consent_form())
		box.add_child(consent)
	var back := UiTheme.primary_button("Zurück")
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(queue_free)
	box.add_child(back)
