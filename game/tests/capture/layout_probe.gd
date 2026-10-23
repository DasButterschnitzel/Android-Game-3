extends SceneTree
## Layout probe (written during the 0.7 QA review): opens one screen, lists the
## rects of its buttons, sliders and labels, flags controls that are off screen,
## overlap or are smaller than UiTheme.TOUCH_MIN, and saves a screenshot.
## Usage (Xvfb, see tools/layout_check.sh):
##   godot --path game --rendering-driver opengl3 --resolution WxH --script res://tests/capture/layout_probe.gd \
##     -- <screen> <out_dir> [safe_top=N] [text=1.2] [daily] save=layout_probe.json fresh_save
## Screens: menu settings collection credits licenses privacy rules game pause between results results_many

var screen := "menu"
var outdir := "/tmp"
var problems := 0


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	if a.size() > 0:
		screen = a[0]
	if a.size() > 1:
		outdir = a[1]
	_go.call_deferred()


func _go() -> void:
	var args := OS.get_cmdline_user_args()
	var save := root.get_node_or_null("Save") as SaveStore
	if save:
		save.data.onboarding["echo"] = true
		save.data.onboarding["start"] = true
		save.data.stats.best_score = 1234
		save.data.stats.rounds_played = 7
		save.data.unlocks["dawn"] = true
		save.data["pending_daily"] = "daily" in args
	for x in args:
		if x.begins_with("safe_top="):
			SafeArea.override = Vector4(0, float(x.substr(9)), 0, 0)
		if x.begins_with("text="):
			UiTheme.set_text_scale(float(x.substr(5)))
			if save:
				save.set_setting("text_scale", float(x.substr(5)))
	await process_frame
	var vr := root.get_visible_rect()
	print("SCREEN=", screen, " window=", DisplayServer.window_get_size(), " visible=", vr.size)
	var subject: Node
	match screen:
		"menu":
			subject = load("res://scenes/menus/main_menu.tscn").instantiate()
			root.add_child(subject)
		"settings", "collection", "credits", "licenses", "privacy", "rules":
			var menu = load("res://scenes/menus/main_menu.tscn").instantiate()
			root.add_child(menu)
			await process_frame
			match screen:
				"settings": subject = SettingsMenu.new()
				"collection": subject = CollectionPanel.new()
				"credits": subject = CreditsPanel.new()
				"privacy": subject = PrivacyPanel.new()
				"rules": subject = RulesPanel.new()
				"licenses": subject = LicensesPanel.new()
			menu.add_child(subject)
			if subject is LicensesPanel:
				for i in 240:  # its texts are added a few per frame
					if (subject as LicensesPanel).complete():
						break
					await process_frame
		"results_many":
			var g2: EchoGame = load("res://scenes/gameplay/echo_game.tscn").instantiate()
			g2.seed_override = 5
			root.add_child(g2)
			subject = g2
			for i in 3:
				await process_frame
			g2.sim.stats.waves_banked = 5
			g2.sim.stats.perfect_waves = 4
			g2.sim.stats.lights = 9
			var ids: Array[String] = []
			for id in Progression.ACHIEVEMENTS:
				ids.append(id)
				save.data.unlocks[id] = true
			g2.earned = ids
			g2.state = "results"
			g2._show_results(1800, true, true)
			for i in 80:
				await process_frame
			var card: Control = g2._overlay.get_child(0)
			print("CARD rect=", card.get_global_rect(), " viewport=", vr.size)
			if not vr.encloses(card.get_global_rect()):
				print("  OFFSCREEN: results card")
				problems += 1
		"game", "pause", "results", "between":
			var g: EchoGame = load("res://scenes/gameplay/echo_game.tscn").instantiate()
			g.seed_override = 5
			root.add_child(g)
			subject = g
			for i in 3:
				await process_frame
			if screen == "pause":
				g.pause()
			elif screen == "between":
				g.sim.begin_run()
				while g.sim.state == "running":
					g.sim.step([])
				g._after_run()
				g.onboarding._seen["echo"] = true
			elif screen == "results":
				g.sim.core_hp = 1
				g.sim.begin_run()
				while g.sim.state == "running":
					g.sim.step([])
				g.sim.bank()
				for i in 80:
					await process_frame
	for i in 6:
		await process_frame
	_report(subject, vr)
	await process_frame
	var img := root.get_texture().get_image()
	if img:
		var p := outdir.path_join("%s_%dx%d.png" % [screen, int(vr.size.x), int(vr.size.y)])
		img.save_png(p)
		print("shot: ", p, " ", img.get_size())
	print("PROBLEMS=", problems)
	quit(1 if problems > 0 else 0)


func _report(subject: Node, vr: Rect2) -> void:
	var rects: Array = []
	for c in subject.find_children("*", "Control", true, false):
		var ctl := c as Control
		if not ctl.is_visible_in_tree():
			continue
		var r := ctl.get_global_rect()
		var kind := ctl.get_class()
		var text := ""
		if ctl is Button:
			text = (ctl as Button).text.replace("\n", " | ")
		elif ctl is Label:
			text = (ctl as Label).text.left(40).replace("\n", " | ")
		elif ctl is BaseButton or ctl is Slider:
			text = "<%s>" % kind
		else:
			continue
		# Clip by scroll container ancestors.
		var clip := Rect2(vr)
		var n: Node = ctl.get_parent()
		var in_scroll := false
		while n != null:
			if n is ScrollContainer:
				clip = clip.intersection((n as Control).get_global_rect())
				in_scroll = true
			n = n.get_parent()
		var off := not vr.encloses(r.grow(-0.5))
		var interactive := ctl is BaseButton or ctl is Slider
		var flag := ""
		if off and not in_scroll:
			flag += " OFFSCREEN"
			problems += 1
		if off and in_scroll and not clip.intersects(r):
			flag += " (scrolled out)"
		if interactive and r.size.y < UiTheme.TOUCH_MIN - 0.5:
			flag += " SMALL(h=%d)" % int(r.size.y)
			problems += 1
		print("  %-12s %-42s pos=(%4d,%4d) size=(%4d,%4d)%s" % [kind, '"' + text + '"', int(r.position.x), int(r.position.y), int(r.size.x), int(r.size.y), flag])
		if interactive and not in_scroll:
			rects.append([text, r])
	for i in rects.size():
		for j in range(i + 1, rects.size()):
			if (rects[i][1] as Rect2).intersects(rects[j][1] as Rect2):
				print("  OVERLAP: ", rects[i][0], " <-> ", rects[j][0])
				problems += 1
