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
	for panel: Control in [SettingsMenu.new(), CreditsPanel.new(), PrivacyPanel.new(), CollectionPanel.new()]:
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
	for panel: Control in [SettingsMenu.new(), CreditsPanel.new(), PrivacyPanel.new(), CollectionPanel.new()]:
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
	var tries: Array = panel.find_children("*", "Button", true, false).filter(func(b): return (b as Button).text == "1 Nacht testen (Werbung)")
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
