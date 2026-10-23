extends TestCase
## NACHHALL game scene through the real touch input pipeline.

var game: EchoGame


func before_each() -> void:
	var save := get_node("/root/Save") as SaveStore
	save.set_setting("second_finger", true)
	save.data["pending_daily"] = false
	game = load("res://scenes/gameplay/echo_game.tscn").instantiate()
	game.seed_override = 21
	add_child(game)
	await frames(2)


func after_each() -> void:
	game.queue_free()
	await frames(2)


## A point well away from every button where a thumb would rest.
func rest_point() -> Vector2:
	return Vector2(360, game.sim.start_pos.y + 120)


## Starts a run with a deliberate pull and lifts the finger.
func start_run_and_release() -> void:
	var p := rest_point()
	touch(0, p, true)
	for i in 5:
		drag(0, p + Vector2(0, -16 * (i + 1)))
	touch(0, p + Vector2(0, -80), false)


func wait_run_end(limit := 900) -> void:
	for i in limit:
		if game.sim.state != "running":
			return
		await physics_frames(1)


func test_jitter_inside_the_ring_does_not_start_a_run() -> void:
	var p := rest_point()
	touch(0, p, true)
	for i in 30:
		drag(0, p + Vector2(sin(i) * 12.0, cos(i * 1.3) * 12.0))
	await physics_frames(3)
	assert_eq(game.sim.state, "ready", "finger jitter keeps the light in its ring")
	touch(0, p, false)


func test_pulling_out_of_the_ring_starts_and_steers_relatively() -> void:
	var p := rest_point()
	touch(0, p, true)
	for i in 5:
		drag(0, p + Vector2(0, -16 * (i + 1)))
	assert_eq(game.sim.state, "running", "pull out of the ring starts the run")
	await physics_frames(20)
	var start: Vector2 = game.sim.live[0].pos
	var finger := p + Vector2(0, -80)
	for i in 10:
		finger += Vector2(10, 0)
		drag(0, finger)
		await physics_frames(1)
	await physics_frames(20)
	var moved: Vector2 = game.sim.live[0].pos - start
	assert_near(moved.x, 100.0 * float(game.cfg.relative_gain), 2.0, "light moved by finger delta x gain")
	assert_near(moved.y, 0.0, 2.0, "no drift")
	touch(0, finger, false)


func test_fast_swipe_lags_but_does_not_drift() -> void:
	start_run_and_release()
	await physics_frames(2)
	var p := rest_point()
	touch(0, p, true)
	var start: Vector2 = game.sim.live[0].pos
	drag(0, p + Vector2(-150, 0))  # one big jump: far beyond one tick of top speed
	await physics_frames(1)
	var after_one: Vector2 = game.sim.live[0].pos
	assert_true(start.distance_to(after_one) <= float(game.cfg.max_light_speed) / 60.0 + 0.01, "speed limit holds")
	await physics_frames(30)
	assert_near(game.sim.live[0].pos.x - start.x, -150.0 * float(game.cfg.relative_gain), 2.0, "catches up with the finger")
	touch(0, p + Vector2(-150, 0), false)


func test_resting_finger_cannot_start_the_next_run() -> void:
	var p := rest_point()
	touch(0, p, true)
	for i in 5:
		drag(0, p + Vector2(0, -16 * (i + 1)))
	await wait_run_end()
	assert_eq(game.sim.state, "between", "run over, finger still down")
	var finger := p + Vector2(0, -80)
	for i in 20:
		finger += Vector2(0, -8)
		drag(0, finger)
		await physics_frames(1)
	assert_eq(game.sim.state, "between", "the old finger is consumed")
	touch(0, finger, false)
	await frames(30)  # start lock
	touch(0, p, true)
	for i in 5:
		drag(0, p + Vector2(0, -16 * (i + 1)))
	assert_eq(game.sim.state, "running", "a fresh deliberate pull starts the next run")
	touch(0, p, false)


func test_first_teaching_wave_cannot_be_banked_before_seeing_an_echo() -> void:
	var save := get_node("/root/Save") as SaveStore
	save.data.onboarding.erase("echo")
	start_run_and_release()
	await wait_run_end()
	await frames(2)
	assert_eq(game.sim.state, "between", "first run over")
	assert_false(game.bank_button.visible, "no bank button: run again with your echo")
	save.data.onboarding["echo"] = true
	await frames(2)
	assert_true(game.bank_button.visible, "after the echo lesson banking is allowed")


func test_bank_button_banks_without_moving_the_light() -> void:
	(get_node("/root/Save") as SaveStore).data.onboarding["echo"] = true
	start_run_and_release()
	await wait_run_end()
	await frames(2)
	assert_eq(game.sim.state, "between", "run over")
	assert_true(game.sim.last_run.leaked > 0, "idle run let ghosts through")
	assert_true(game.bank_button.visible, "bank button shown")
	var ring_light := game.ready_pos
	var c := game.bank_button.get_global_rect().get_center()
	touch(0, c, true)
	touch(0, c, false)
	await frames(2)
	assert_eq(game.sim.wave_index, 1, "banked: next wave")
	assert_vec_near(game.ready_pos, ring_light, 1.0, "tapping the button does not move the light")


func test_second_finger_needs_a_deliberate_drag() -> void:
	var p := rest_point()
	touch(0, p, true)
	for i in 5:
		drag(0, p + Vector2(0, -16 * (i + 1)))
	assert_eq(game.sim.live.size(), 1, "one light")
	var q := Vector2(150, 900)
	touch(1, q, true)
	drag(1, q + Vector2(15, 0))
	await physics_frames(1)
	assert_eq(game.sim.live.size(), 1, "a resting or brushing second finger does nothing")
	for i in 4:
		drag(1, q + Vector2(15 + 10 * (i + 1), 0))
	await physics_frames(1)
	assert_eq(game.sim.live.size(), 2, "a deliberate drag lights a second light")
	assert_eq(game.sim.multiplier(), float(game.cfg.light_multipliers[1]), "costs like a second run")
	touch(1, q, false)
	touch(0, p, false)


## Re-gripping with the other thumb mid-run (put B down, then lift A) hands the
## light over: no unwanted second light, no frozen light (QA review 0.7).
func test_thumb_hand_over_keeps_one_light() -> void:
	var p := rest_point()
	touch(0, p, true)
	for i in 5:
		drag(0, p + Vector2(0, -16 * (i + 1)))
	assert_eq(game.sim.state, "running", "run started")
	var mult := game.sim.multiplier()
	var q := Vector2(200, 950)
	touch(1, q, true)
	touch(0, p + Vector2(0, -80), false)
	await physics_frames(2)
	var start: Vector2 = game.sim.live[0].pos
	var finger := q
	for i in 8:
		finger += Vector2(10, 0)
		drag(1, finger)
		await physics_frames(1)
	await physics_frames(20)
	assert_eq(game.sim.live.size(), 1, "no second light from the hand-over")
	assert_eq(game.sim.multiplier(), mult, "multiplier untouched")
	assert_near((game.sim.live[0].pos - start).x, 80.0 * float(game.cfg.relative_gain), 3.0, "the other thumb steers the light")
	touch(1, finger, false)


func test_thumb_hand_over_also_works_without_the_second_finger_setting() -> void:
	game.second_finger = false
	var p := rest_point()
	touch(0, p, true)
	for i in 5:
		drag(0, p + Vector2(0, -16 * (i + 1)))
	var q := Vector2(200, 950)
	touch(1, q, true)
	touch(0, p + Vector2(0, -80), false)
	await physics_frames(2)
	var start: Vector2 = game.sim.live[0].pos
	for i in 8:
		drag(1, q + Vector2(10 * (i + 1), 0))
		await physics_frames(1)
	await physics_frames(20)
	assert_true((game.sim.live[0].pos - start).length() > 20.0, "the light follows the other thumb instead of freezing")
	touch(1, q, false)


func test_never_more_than_two_live_lights() -> void:
	var p := rest_point()
	touch(0, p, true)
	for i in 5:
		drag(0, p + Vector2(0, -16 * (i + 1)))
	var a := Vector2(150, 900)
	var b := Vector2(560, 900)
	touch(1, a, true)
	touch(2, b, true)  # both down before either drags
	for i in 6:
		drag(1, a + Vector2(10 * (i + 1), 0))
		drag(2, b + Vector2(-10 * (i + 1), 0))
	await physics_frames(2)
	assert_eq(game.sim.live.size(), 2, "a third finger cannot light a third light")
	assert_eq(game.sim.multiplier(), float(game.cfg.light_multipliers[1]), "costs like two lights only")
	for i in 3:
		touch(i, Vector2(300, 900), false)


func test_pause_freezes_the_run() -> void:
	start_run_and_release()
	await physics_frames(5)
	game.pause()
	var t0 := game.sim.tick
	await physics_frames(20)
	assert_eq(game.state, "paused", "paused")
	assert_eq(game.sim.tick, t0, "run frozen while paused")
	game.resume_play()
	await physics_frames(5)
	assert_true(game.sim.tick > t0, "runs again after resume")


func test_lost_night_shows_results_and_restarts() -> void:
	(get_node("/root/Save") as SaveStore).data.onboarding["echo"] = true
	game.sim.core_hp = 1
	start_run_and_release()
	await wait_run_end()
	await frames(2)
	var c := game.bank_button.get_global_rect().get_center()
	touch(0, c, true)
	touch(0, c, false)
	await frames(2)
	assert_eq(game.state, "results", "night over")
	assert_true(game.again_button != null and game.again_button.disabled, "restart briefly locked")
	var texts: Array = game.ui_layer.find_children("*", "Label", true, false).map(func(l): return (l as Label).text)
	assert_true(texts.any(func(t): return str(t).begins_with("Nächstes Sternbild: ")), "a next goal on the results card")
	var old: WeakRef = weakref(game.sim)
	await get_tree().create_timer(1.4).timeout
	assert_false(game.again_button.disabled, "restart unlocked")
	var a := game.again_button.get_global_rect().get_center()
	touch(0, a, true)
	touch(0, a, false)
	await frames(3)
	assert_eq(game.state, "play", "new round")
	assert_eq(game.sim.state, "ready", "fresh night")
	assert_eq(old.get_ref(), null, "old round freed")


func test_android_back_pauses_and_resumes() -> void:
	var flow := get_node("/root/Flow") as GameFlow
	start_run_and_release()
	await physics_frames(3)
	assert_true(flow.handle_back(), "back is handled, the app does not quit mid-run")
	assert_eq(game.state, "paused", "back pauses a running night")
	flow.handle_back()
	assert_eq(game.state, "play", "back again resumes")


func test_hud_and_buttons_respect_the_safe_area() -> void:
	SafeArea.override = Vector4(0, 60, 0, 40)
	game.new_round()
	await frames(3)
	assert_near(game.hud.position.y, 60.0, 0.01, "HUD below the camera cut-out")
	assert_true(game.sim.arena.position.y >= 210.0, "field below HUD and cut-out")
	(get_node("/root/Save") as SaveStore).data.onboarding["echo"] = true
	start_run_and_release()
	await wait_run_end()
	await frames(2)
	var r := game.bank_button.get_global_rect()
	assert_true(r.end.y <= game.get_viewport_rect().size.y - 40.0, "bank button above the gesture bar")
	SafeArea.override = Vector4(-1, -1, -1, -1)


func test_teaching_notes_wait_for_the_break() -> void:
	(get_node("/root/Save") as SaveStore).data.onboarding["echo"] = true
	start_run_and_release()
	await physics_frames(3)
	game.hud.show_hint("Testhinweis")
	await frames(3)
	assert_eq(game.hud.note_text(), "", "no teaching text during a run")
	await wait_run_end()
	await frames(20)
	assert_eq(game.hud.note_text(), "Testhinweis", "shown at the next break")


func test_newest_note_replaces_an_outdated_one() -> void:
	(get_node("/root/Save") as SaveStore).data.onboarding["echo"] = true
	game.hud.show_hint("Alt")
	await frames(5)
	assert_eq(game.hud.note_text(), "Alt", "shown before the first run")
	start_run_and_release()  # the player starts quickly, before reading it
	await physics_frames(3)
	game.hud.show_hint("Neu")
	await wait_run_end()
	await frames(20)
	assert_eq(game.hud.note_text(), "Neu", "the newer note wins at the next break")



func test_buttons_and_cards_use_the_game_font() -> void:
	game.bank_button.text = "Kassieren +10"  # bank button lives on a CanvasLayer
	assert_game_font(game, "game scene")
	game.pause()
	await frames(2)
	assert_game_font(game, "pause card")
	game.resume_play()


func test_echo_label_rides_with_the_echo() -> void:
	(get_node("/root/Save") as SaveStore).data.onboarding.erase("echo")
	var p := rest_point()
	touch(0, p, true)
	for i in 30:  # a run that travels, so its echo travels too
		p += Vector2(-6, -10)
		drag(0, p)
		await physics_frames(1)
	touch(0, p, false)
	await wait_run_end()
	for i in 200:  # past the start lock
		if game._lock <= 0.0:
			break
		await frames(1)
	start_run_and_release()
	assert_eq(game.sim.run_index, 1, "second run started")
	await physics_frames(40)
	var label: Dictionary = {}
	for pop in game.view.popups:
		if pop.text == "Dein Echo":
			label = pop
	assert_false(label.is_empty(), "the first echo is named")
	if label.is_empty():
		return
	var path: PackedVector2Array = game.sim.echoes[0].path
	var echo_now: Vector2 = path[mini(game.sim.tick, path.size() - 1)]
	assert_true(echo_now.distance_to(path[0]) > 20.0, "the echo has moved away from its start")
	assert_vec_near(label.pos as Vector2, echo_now - Vector2(0, 34), 1.0, "label sits on the echo, not where it started")


func test_a_new_note_fades_in() -> void:
	game.hud.show_hint("Erster Zettel")
	await frames(1)
	assert_true(game.hud._note.modulate.a < 0.5, "first frame of a note is faded (its text is laid out first)")
	await frames(30)
	assert_near(game.hud._note.modulate.a, 1.0, 0.01, "fully visible after the fade")


func test_first_night_is_familiar_and_the_daily_night_has_its_formation() -> void:
	var save := get_node("/root/Save") as SaveStore
	var played: int = save.data.stats.rounds_played
	save.data.stats.rounds_played = 0
	game.new_round()
	assert_true(bool(game.cfg.first_night), "a new player's first night: scattered waves only")
	save.data.stats.rounds_played = 3
	game.new_round()
	assert_false(bool(game.cfg.first_night), "afterwards formations vary")
	save.data.stats.rounds_played = played
	game.queue_free()
	await frames(2)
	save.data["pending_daily"] = true
	game = load("res://scenes/gameplay/echo_game.tscn").instantiate()
	add_child(game)
	await frames(2)
	assert_eq(str(game.cfg.get("formation_feature", "")), Config.daily_feature(), "daily night features today's formation")
	assert_false(bool(game.cfg.first_night), "the daily night is the same for everyone")
	save.data["pending_daily"] = false


func test_unread_notes_come_back_and_situational_ones_expire() -> void:
	(get_node("/root/Save") as SaveStore).data.onboarding["echo"] = true
	game.hud.show_hint("So startest du", 0.0, true)
	game.hud.show_hint("Wissen A")
	await frames(3)
	assert_eq(game.hud._note_text, "Wissen A", "newest first")
	start_run_and_release()  # quickly, nothing read
	await physics_frames(3)
	game.hud.show_hint("Wissen B")
	await wait_run_end()
	await frames(10)
	assert_eq(game.hud.note_text(), "Wissen B", "the newest note at the next break")
	await get_tree().create_timer(1.3).timeout  # read
	await frames(10)
	assert_eq(game.hud.note_text(), "Wissen A", "the unread older note follows, not lost")
	await get_tree().create_timer(1.3).timeout
	await frames(10)
	assert_eq(game.hud.note_text(), "Wissen A", "a read note may stay until the next run")
	assert_true(game.hud._queued.is_empty(), "the situational note expired with the run")


class SpyAdapter extends AdAdapter:
	var interstitials := 0
	func request_consent(_force := false) -> String:
		return "denied"
	func show_interstitial(_personalized: bool) -> bool:
		interstitials += 1
		return true


func test_ads_only_at_the_natural_break_after_a_night() -> void:
	var save := get_node("/root/Save") as SaveStore
	var ads := get_node("/root/Ads") as AdService
	var spy := SpyAdapter.new()
	var old_adapter: AdAdapter = ads._adapter
	ads._adapter = spy
	save.set_setting("ads_preview", true)
	save.data.ads.consent = "denied"
	ads.policy.lifetime_rounds = 50
	for i in 10:
		ads.policy.on_round_finished()
	ads._clock += 10000.0
	# Leaving a night from the pause menu: no ad.
	game.pause()
	await frames(2)
	game._to_menu(false)
	await frames(2)
	assert_eq(spy.interstitials, 0, "never when a night is abandoned")
	game.queue_free()
	await frames(2)
	game = load("res://scenes/gameplay/echo_game.tscn").instantiate()
	add_child(game)
	await frames(2)
	# A finished night -> "Nochmal": the capped interstitial may appear first.
	game.state = "results"
	game._on_again()
	await frames(3)
	assert_eq(spy.interstitials, 1, "one interstitial at the natural break")
	assert_eq(game.state, "play", "then the next night starts")
	ads._adapter = old_adapter
	save.set_setting("ads_preview", false)
	spy.free()


func test_a_lent_paper_is_worn_for_exactly_one_night() -> void:
	var save := get_node("/root/Save") as SaveStore
	save.data["paper_trial"] = "gold"
	game.new_round()
	assert_eq(game.view._paper, Progression.PAPERS["gold"].paper, "the lent paper lights this night")
	game.sim.core_hp = 1
	game.sim.state = "between"
	game.sim.last_run = {"destroyed": 0, "leaked": 1, "points": 0}
	game.sim.bank()  # the night ends
	await frames(2)
	assert_eq(str(save.data.paper_trial), "", "and is returned afterwards")
	game.new_round()
	assert_ne(game.view._paper, Progression.PAPERS["gold"].paper, "next night: the own paper again")


func test_a_lent_paper_is_used_up_by_an_abandoned_night_too() -> void:
	var save := get_node("/root/Save") as SaveStore
	save.data["paper_trial"] = "gold"
	game.new_round()
	assert_eq(game.view._paper, Progression.PAPERS["gold"].paper, "worn this night")
	assert_eq(str(save.data.paper_trial), "", "the loan is used up when the night starts")
	game.pause()
	game.new_round()  # "Neu starten" from the pause menu
	assert_ne(game.view._paper, Progression.PAPERS["gold"].paper, "a restart does not get it again")


## A strong first night can unlock almost everything at once: the card, with
## both buttons, must still fit a 16:9 screen (QA review 0.7).
func test_results_card_fits_even_when_a_night_unlocks_a_lot() -> void:
	await _card_with_everything(1.0)


func test_results_card_fits_with_large_text_too() -> void:
	await _card_with_everything(1.2)


func _card_with_everything(text_scale: float) -> void:
	UiTheme.set_text_scale(text_scale)
	game.daily = true
	var all: Array[String] = []
	for id in Progression.ACHIEVEMENTS:
		all.append(id)
	game.earned = all
	game._show_results(1550, true, true)
	await frames(3)
	var vp := Rect2(Vector2.ZERO, game.get_viewport_rect().size)
	var card := game._overlay.get_child(0) as Control
	assert_true(vp.encloses(card.get_global_rect()), "card %s inside the screen %s" % [card.get_global_rect(), vp])
	assert_true(vp.encloses(game.again_button.get_global_rect()), "Nochmal on screen")
	var texts: Array = card.find_children("*", "Label", true, false).map(func(l): return (l as Label).text)
	assert_true(texts.any(func(t): return str(t).begins_with("Neue Sternbilder: ")), "listed in one line")
	UiTheme.set_text_scale(1.0)


func test_results_card_closed_early_leaves_no_dangling_timer() -> void:
	(get_node("/root/Save") as SaveStore).data.onboarding["echo"] = true
	game.sim.core_hp = 1
	start_run_and_release()
	await wait_run_end()
	await frames(2)
	game._on_bank_pressed()
	await frames(2)
	assert_eq(game.state, "results", "night over")
	var menu_buttons: Array = game.ui_layer.find_children("*", "Button", true, false).filter(func(b): return (b as Button).text == "Menü")
	assert_true(menu_buttons.size() == 1 and (menu_buttons[0] as Button).disabled, "menu locked while the card is still invisible")
	game._on_again()  # closed before the unlock (e.g. a bot or a future shortcut)
	await get_tree().create_timer(1.3).timeout
	assert_eq(game.state, "play", "next night runs; the old card's timer died with the card")
