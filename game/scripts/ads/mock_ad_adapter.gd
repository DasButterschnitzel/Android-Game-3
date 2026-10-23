class_name MockAdAdapter
extends AdAdapter
## Offline stand-in for an ad network, used in debug builds and tests.
## It shows clearly marked placeholders (never real ads, no network) so the
## complete flow can be seen and tested: consent question, full-screen ad
## at a natural break, close button that unlocks after a short delay.

var close_after := 2.0
var reward_after := 3.0  # seconds before the rewarded placeholder pays out
## Tests: answer/close automatically instead of waiting for a tap.
var auto_answer := ""  # "", "granted" or "denied"
var auto_close := false
var auto_reward := ""  # "", "earned" or "cancel" (not watched to the end)

signal _answered(status: String)
signal _closed

var _layer: CanvasLayer


func configure(config: Dictionary) -> void:
	close_after = float(config.get("mock_close_after", close_after))
	reward_after = float(config.get("mock_reward_after", reward_after))


func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 90
	add_child(_layer)


func request_consent(force := false) -> String:
	if auto_answer != "":
		return auto_answer
	var panel := _panel()
	panel.add_child(UiTheme.label("Werbung & Datenschutz", 44, UiTheme.TEXT, true))
	var text := "TEST-ABLAUF: Diese Version zeigt keine echte Werbung.\n\nIn der fertigen App fragt hier ein Einwilligungs-Dialog des Werbepartners, ob personalisierte Werbung gezeigt werden darf. Ohne Zustimmung gibt es nur allgemeine Werbung. Du kannst das jederzeit ändern: Einstellungen, dann „Datenschutz & Werbung“ und „Werbe-Einwilligung ändern“."
	if force:
		text = "TEST-ABLAUF: Einwilligung ändern.\n\n" + text.get_slice("\n\n", 1)
	var body := UiTheme.label(text, 26, UiTheme.TEXT_DIM, true)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(body)
	var yes := UiTheme.primary_button("Zustimmen")
	yes.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	yes.pressed.connect(func(): _answered.emit("granted"))
	panel.add_child(yes)
	var no := UiTheme.button("Ablehnen")
	no.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	no.pressed.connect(func(): _answered.emit("denied"))
	panel.add_child(no)
	var status: String = await _answered
	_clear()
	return status


func show_interstitial(personalized: bool) -> bool:
	if auto_close:
		return true
	var panel := _panel()
	panel.add_child(UiTheme.label("TESTANZEIGE", 54, UiTheme.ACCENT, true))
	var kind := "personalisiert" if personalized else "nicht personalisiert"
	var info := UiTheme.label("Platzhalter für eine Vollbild-Werbung (%s).\nKeine echte Werbung, keine Netzwerkverbindung." % kind, 26, UiTheme.TEXT_DIM, true)
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(info)
	var close := UiTheme.button("Schließen")
	close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close.disabled = true
	close.pressed.connect(func(): _closed.emit())
	panel.add_child(close)
	var tw := close.create_tween()
	tw.tween_interval(close_after)
	tw.tween_callback(func(): close.disabled = false)
	await _closed
	_clear()
	return true


func supports_rewarded() -> bool:
	return true


## Placeholder for a rewarded ad: the reward needs the full countdown,
## "Abbrechen" ends it at once without reward.
func show_rewarded(personalized: bool) -> bool:
	if auto_reward != "":
		return auto_reward == "earned"
	var panel := _panel()
	panel.add_child(UiTheme.label("TESTANZEIGE · Belohnung", 50, UiTheme.ACCENT, true))
	var kind := "personalisiert" if personalized else "nicht personalisiert"
	var info := UiTheme.label("Platzhalter für eine Werbung mit Belohnung (%s).\nKeine echte Werbung, keine Netzwerkverbindung." % kind, 26, UiTheme.TEXT_DIM, true)
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(info)
	var count := UiTheme.label("", 30, UiTheme.TEXT, true)
	panel.add_child(count)
	var done := UiTheme.primary_button("Belohnung abholen")
	done.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	done.disabled = true
	done.pressed.connect(func(): _answered.emit("earned"))
	panel.add_child(done)
	var cancel := UiTheme.button("Abbrechen")
	cancel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cancel.pressed.connect(func(): _answered.emit("cancel"))
	panel.add_child(cancel)
	var tw := count.create_tween()
	for i in range(int(ceil(reward_after)), 0, -1):
		tw.tween_callback(func(): count.text = "noch %d s" % i)
		tw.tween_interval(1.0)
	tw.tween_callback(func():
		count.text = ""
		done.disabled = false)
	var result: String = await _answered
	_clear()
	return result == "earned"


func _panel() -> VBoxContainer:
	_clear()
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.06, 0.94)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_layer.add_child(dim)
	var box := VBoxContainer.new()
	box.theme = UiTheme.get_theme()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.offset_left = 48
	box.offset_right = -48
	_layer.add_child(box)
	return box


func _clear() -> void:
	for c in _layer.get_children():
		c.queue_free()
