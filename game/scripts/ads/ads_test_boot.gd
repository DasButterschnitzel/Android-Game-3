extends Node
## Entry scene of the experimental "Android-AdsTest" export only: its custom
## feature "nachhall_ads" overrides application/run/main_scene (project.godot).
## Installs AdService as /root/Ads (adapter "admob", see data/ads.json), then
## opens the normal main menu. Normal builds never load this scene, so they
## have no ad service at all. See docs/compliance/ADS_TEST_BUILD.md.

const MAIN_MENU := "res://scenes/menus/main_menu.tscn"


func _ready() -> void:
	var root := get_tree().root
	if root.get_node_or_null("Ads") == null:
		var ads := AdService.new()
		ads.name = "Ads"
		root.add_child.call_deferred(ads)
	get_tree().change_scene_to_file.call_deferred(MAIN_MENU)
