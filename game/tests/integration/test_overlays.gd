extends TestCase
## Menus and overlays must cover the whole screen (regression: panels added to
## a running scene kept a zero size and were invisible in 0.2.0 and 0.3.0).

var menu: Control


func before_each() -> void:
	menu = load("res://scenes/menus/main_menu.tscn").instantiate()
	add_child(menu)
	await frames(2)


func after_each() -> void:
	menu.queue_free()
	await frames(2)


func test_menu_overlays_fill_the_screen() -> void:
	var vp := get_viewport().get_visible_rect().size
	assert_game_font(menu, "main menu")
	for panel: Control in [SettingsMenu.new(), CreditsPanel.new(), PrivacyPanel.new(), CollectionPanel.new(), RulesPanel.new(), LicensesPanel.new()]:
		menu.add_child(panel)
		await frames(2)
		assert_vec_near(panel.size, vp, 1.0, "%s covers the screen" % panel.get_script().get_global_name())
		var covered := 0
		for c in panel.get_children():
			if c is ColorRect and (c as ColorRect).size.distance_to(vp) < 1.0:
				covered += 1
		assert_true(covered >= 1, "%s has a full-screen background" % panel.get_script().get_global_name())
		assert_game_font(panel, panel.get_script().get_global_name())
		panel.queue_free()
		await frames(1)


## Immersive full screen: titles and the last buttons stay clear of camera
## cut-outs and the gesture bar on every page (QA review 0.7: settings and
## credits used fixed margins).
func test_panels_respect_the_safe_area() -> void:
	SafeArea.override = Vector4(0, 100, 0, 60)
	var vp := get_viewport().get_visible_rect().size
	for panel: Control in [SettingsMenu.new(), CreditsPanel.new(), PrivacyPanel.new(), CollectionPanel.new(), RulesPanel.new(), LicensesPanel.new()]:
		menu.add_child(panel)
		await frames(2)
		var name: String = panel.get_script().get_global_name()
		var labels := panel.find_children("*", "Label", true, false)
		assert_true(labels.size() > 0, "%s has a title" % name)
		if labels.size() > 0:
			assert_true((labels[0] as Label).get_global_rect().position.y >= 100.0, "%s title below the cut-out" % name)
		for b: Control in panel.find_children("*", "BaseButton", true, false):
			if b.is_visible_in_tree() and not _in_scroll(b):
				assert_true(b.get_global_rect().end.y <= vp.y - 60.0 + 0.5, "%s: %s above the gesture bar" % [name, b.name])
		panel.queue_free()
		await frames(1)
	SafeArea.override = Vector4(-1, -1, -1, -1)


func _in_scroll(c: Node) -> bool:
	var n := c.get_parent()
	while n != null:
		if n is ScrollContainer:
			return true
		n = n.get_parent()
	return false


## Every button, toggle and slider is at least 48 dp tall on a 360 dp phone.
func test_touch_targets_are_at_least_48_dp() -> void:
	var screens: Array[Control] = [menu]
	for panel: Control in [SettingsMenu.new(), CreditsPanel.new(), PrivacyPanel.new(), CollectionPanel.new(), RulesPanel.new(), LicensesPanel.new()]:
		menu.add_child(panel)
		screens.append(panel)
	await frames(3)
	var checked := 0
	for scr in screens:
		var controls: Array = scr.find_children("*", "BaseButton", true, false) + scr.find_children("*", "HSlider", true, false)
		for c: Control in controls:
			if not c.is_visible_in_tree():
				continue
			checked += 1
			assert_true(c.size.y >= UiTheme.TOUCH_MIN - 0.5, "%s / %s '%s' is %d units tall" % [
				scr.name, c.get_class(), str(c.get("text")) if c is Button else "", int(c.size.y)])
	assert_true(checked >= 20, "checked the controls of every screen (%d)" % checked)
	for i in range(1, screens.size()):
		screens[i].queue_free()
	await frames(1)


## "Schrift: groß": every page still fits, nothing leaves the screen and the
## text really is larger.
func test_large_text_keeps_every_screen_usable() -> void:
	UiTheme.set_text_scale(1.2)
	var vp := get_viewport().get_visible_rect().size
	var big := UiTheme.label("x", 30)
	assert_eq(big.get_theme_font_size("font_size"), 36, "labels 20 % larger")
	big.free()
	assert_eq(UiTheme.get_theme().get_font_size("font_size", "Button"), 38, "theme buttons follow at once")
	var m2: Control = load("res://scenes/menus/main_menu.tscn").instantiate()
	add_child(m2)
	await frames(2)
	for panel: Control in [m2, SettingsMenu.new(), CreditsPanel.new(), PrivacyPanel.new(), CollectionPanel.new(), RulesPanel.new()]:
		if panel != m2:
			m2.add_child(panel)
		await frames(2)
		var name := str(panel.get_script().get_global_name())
		for b: Control in panel.find_children("*", "BaseButton", true, false):
			if b.is_visible_in_tree() and not _in_scroll(b):
				assert_true(Rect2(Vector2.ZERO, vp).encloses(b.get_global_rect().grow(-0.5)), "%s: %s on screen" % [name, b.name])
			if b.is_visible_in_tree():
				assert_true(b.size.y >= UiTheme.TOUCH_MIN - 0.5, "%s: %s still 48 dp" % [name, b.name])
		if panel != m2:
			panel.queue_free()
			await frames(1)
	m2.queue_free()
	UiTheme.set_text_scale(1.0)
	await frames(1)


func test_text_size_setting_rebuilds_the_settings_page() -> void:
	var save := get_node("/root/Save") as SaveStore
	save.set_setting("text_scale", 1.0)
	var s := SettingsMenu.new()
	menu.add_child(s)
	await frames(2)
	var row: Button = s.find_children("*", "Button", true, false).filter(func(b): return (b as Button).text.begins_with("Schrift"))[0]
	assert_eq(row.text, "Schrift: normal", "starts normal")
	row.pressed.emit()
	await frames(3)
	assert_eq(float(save.get_setting("text_scale")), 1.2, "stored")
	assert_eq(UiTheme.text_scale, 1.2, "applied")
	var title: Label = s.find_children("*", "Label", true, false)[0]
	assert_eq(title.get_theme_font_size("font_size"), UiTheme.fs(52), "the page was rebuilt with the larger text")
	var rows := s.find_children("*", "Button", true, false).filter(func(b): return (b as Button).text.begins_with("Schrift") and not (b as Button).is_queued_for_deletion())
	assert_eq((rows[-1] as Button).text, "Schrift: groß", "row shows the new size")
	save.set_setting("text_scale", 1.0)
	UiTheme.set_text_scale(1.0)
	s.queue_free()


## The engine's third-party notices (FreeType, Mbed TLS, ...) ship inside the
## app: several of their licenses require it.
func test_credits_lead_to_the_engine_licenses() -> void:
	var c := CreditsPanel.new()
	menu.add_child(c)
	await frames(2)
	var btn: Button = c.find_children("*", "Button", true, false).filter(func(b): return (b as Button).text.begins_with("Lizenzen"))[0]
	btn.pressed.emit()
	await frames(2)
	var page := c.find_children("*", "LicensesPanel", true, false)
	assert_eq(page.size(), 1, "the licenses page opens")
	var lp := page[0] as LicensesPanel
	for i in 200:
		if lp.complete():
			break
		await frames(1)
	assert_true(lp.complete(), "every notice added")
	var text := "\n".join(PackedStringArray(lp.find_children("*", "Label", true, false).map(func(l): return (l as Label).text)))
	for needle in ["The FreeType Project", "Mbed TLS", "HarfBuzz", "Copyright (c) 2014-present Godot Engine contributors"]:
		assert_true(text.contains(needle), "contains %s" % needle)
	assert_true(text.length() > 50000, "the full license texts (%d characters)" % text.length())
	assert_eq(LicensesPanel.reflow("Permission is\n  granted\n\n\nTHE SOFTWARE\r\nIS"), "Permission is granted\n\nTHE SOFTWARE IS",
		"hard-wrapped lines joined per paragraph")
	c.queue_free()


func test_settings_and_credits_show_the_version() -> void:
	var want := "Version %s" % str(ProjectSettings.get_setting("application/config/version"))
	assert_true(Config.version_text().begins_with(want), "version from the project settings")
	assert_true(Config.version_text().ends_with("Test-Build"), "tests run a debug build")
	for panel: Control in [SettingsMenu.new(), CreditsPanel.new()]:
		menu.add_child(panel)
		await frames(2)
		var texts: Array = panel.find_children("*", "Label", true, false).map(func(l): return (l as Label).text)
		assert_true(texts.any(func(t): return str(t).contains(want)), "%s shows the version" % panel.get_script().get_global_name())
		panel.queue_free()
		await frames(1)


func test_settings_buttons_are_reachable() -> void:
	var s := SettingsMenu.new()
	menu.add_child(s)
	await frames(3)
	var buttons := s.find_children("*", "BaseButton", true, false)
	assert_true(buttons.size() >= 6, "settings has its controls (%d)" % buttons.size())
	var vp := Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size)
	var visible := 0
	for b: Control in buttons:
		var r := b.get_global_rect()
		if not vp.intersects(r) or r.size.y <= 40.0:
			continue
		# A clipping scroll container must actually show the control.
		var clip: Node = b.get_parent()
		while clip != null and not (clip is ScrollContainer):
			clip = clip.get_parent()
		if clip == null or (clip as Control).get_global_rect().intersects(r):
			visible += 1
	assert_true(visible >= 4, "several settings controls are on screen with a touch-size height (%d)" % visible)
	s.queue_free()


func test_every_screen_answers_the_back_button() -> void:
	assert_true(menu.is_in_group("back_handler") and menu.has_method("on_back"), "main menu handles back (leaves the app)")
	for panel: Control in [SettingsMenu.new(), CreditsPanel.new(), PrivacyPanel.new(), CollectionPanel.new(), RulesPanel.new(), LicensesPanel.new()]:
		menu.add_child(panel)
		await frames(1)
		var name: String = panel.get_script().get_global_name()
		assert_true(panel.is_in_group("back_handler") and panel.has_method("on_back"), "%s closes on back" % name)
		var flow := get_node("/root/Flow") as GameFlow
		assert_true(flow.handle_back(), "handled")
		await frames(1)
		assert_false(is_instance_valid(panel), "%s closed" % name)


func test_sternbilder_page_shows_the_last_nights() -> void:
	var save := get_node("/root/Save") as SaveStore
	var before: Array = (save.data.history as Array).duplicate(true)
	save.data.history = [{"s": 800, "w": 4, "d": false, "m": "", "q": false}, {"s": 1250, "w": 5, "d": true, "m": "", "q": true}]
	var panel := CollectionPanel.new()
	menu.add_child(panel)
	await frames(2)
	var charts := panel.find_children("*", "HistoryChart", true, false)
	assert_eq(charts.size(), 1, "history chart on the page")
	if charts.size() == 1:
		assert_eq((charts[0] as HistoryChart).nights.size(), 2, "with the recorded nights")
		assert_true((charts[0] as Control).size.x > 300.0, "laid out across the page")
	var texts: Array = panel.find_children("*", "Label", true, false).map(func(l): return (l as Label).text)
	assert_true(texts.has("Ø der letzten 2: 1.025 · Morgengrauen 1 von 2"), "summary line")
	panel.queue_free()
	save.data.history = before


func test_privacy_page_matches_the_ad_backend() -> void:
	var save := get_node("/root/Save") as SaveStore
	save.set_setting("ads_preview", true)
	var panel := PrivacyPanel.new()
	menu.add_child(panel)
	await frames(2)
	var texts: Array = panel.find_children("*", "Label", true, false).map(func(l): return (l as Label).text)
	assert_true(texts.any(func(t): return str(t).contains("PLATZHALTER")), "debug build: says the ads are placeholders")
	var buttons: Array = panel.find_children("*", "Button", true, false).map(func(b): return (b as Button).text)
	assert_true(buttons.has("Werbe-Einwilligung ändern"), "consent can be changed")
	panel.queue_free()
	save.set_setting("ads_preview", false)
	await frames(1)
	panel = PrivacyPanel.new()
	menu.add_child(panel)
	await frames(2)
	buttons = panel.find_children("*", "Button", true, false).map(func(b): return (b as Button).text)
	assert_false(buttons.has("Werbe-Einwilligung ändern"), "no ads -> no consent button")
	assert_true(PrivacyPanel.text_for("admob").contains("TESTANZEIGEN von Google AdMob"), "ads test build names Google")
	panel.queue_free()


func test_privacy_link_and_contact_come_from_the_owner_config() -> void:
	var shipped := PrivacyPanel.app_info()
	assert_eq(shipped.privacy_policy_url, "", "no URL invented: the owner fills data/app.json")
	var tmp := "user://test_app_info.json"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	f.store_string(JSON.stringify({"privacy_policy_url": " https://example.org/datenschutz ", "contact_email": "hallo@example.org"}))
	f.close()
	var info := PrivacyPanel.app_info(tmp)
	assert_eq(info.privacy_policy_url, "https://example.org/datenschutz", "read and trimmed")
	assert_eq(info.contact_email, "hallo@example.org", "contact read")
	assert_eq(PrivacyPanel.app_info("user://missing.json").contact_email, "", "missing file: nothing shown")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(tmp))


func test_a_locked_paper_can_be_worn_for_one_night_after_a_rewarded_ad() -> void:
	var save := get_node("/root/Save") as SaveStore
	var ads := get_node("/root/Ads") as AdService
	save.set_setting("ads_preview", true)
	save.data["paper_trial"] = ""
	var unlocks: Dictionary = (save.data.unlocks as Dictionary).duplicate()
	save.data.unlocks = {}
	var mock := ads._adapter as MockAdAdapter
	mock.auto_answer = "granted"
	mock.auto_reward = "earned"
	var panel := CollectionPanel.new()
	menu.add_child(panel)
	await frames(2)
	var tries: Array = panel.find_children("*", "Button", true, false).filter(func(b): return (b as Button).text == "1 Nacht testen\n(Werbung)")
	assert_true(tries.size() >= 1, "locked papers offer a one-night trial")
	if tries.size() >= 1:
		(tries[0] as Button).pressed.emit()
		await frames(3)
		assert_true(str(save.data.paper_trial) != "", "after the ad the paper is lent for the next night")
	panel.queue_free()
	mock.auto_answer = ""
	mock.auto_reward = ""
	save.data.unlocks = unlocks
	save.data.ads.consent = "unknown"
	save.data["paper_trial"] = ""
	save.set_setting("ads_preview", false)
