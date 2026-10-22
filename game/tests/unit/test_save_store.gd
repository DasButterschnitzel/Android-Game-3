extends TestCase
## Persistence: round trip, defaults merge, corruption recovery, atomic writes.

var store: SaveStore
const TEST_PATH := "user://test_save.json"


func before_each() -> void:
	for p in [TEST_PATH, TEST_PATH + ".tmp", TEST_PATH + ".corrupt"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))
	store = SaveStore.new()
	store.path = TEST_PATH


func after_each() -> void:
	store.free()


func test_defaults_when_no_file() -> void:
	store.load_from_disk()
	assert_eq(store.data.stats.best_score, 0, "best 0")
	assert_eq(store.get_setting("control_mode"), "direct", "default control mode")


func test_round_trip() -> void:
	store.load_from_disk()
	store.set_setting("sfx_volume", 0.25)
	assert_true(store.record_round(1234, 40, 5, 77.5), "first round is a best")
	assert_false(store.record_round(1000, 10, 2, 20.0), "lower is not a best")
	assert_true(store.save_now(), "saved")
	var other := SaveStore.new()
	other.path = TEST_PATH
	other.load_from_disk()
	assert_eq(other.data.stats.best_score, 1234, "best persisted")
	assert_eq(other.data.stats.rounds_played, 2, "rounds persisted")
	assert_near(other.get_setting("sfx_volume"), 0.25, 0.0001, "setting persisted")
	other.free()


func test_missing_keys_are_filled_and_unknown_dropped() -> void:
	var f := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({"version": 0, "stats": {"best_score": 77}, "garbage": 1, "settings": {"sfx_volume": "loud"}}))
	f.close()
	store.load_from_disk()
	assert_eq(store.data.stats.best_score, 77, "kept known value")
	assert_eq(store.data.stats.rounds_played, 0, "filled missing key")
	assert_false(store.data.has("garbage"), "dropped unknown key")
	assert_near(store.get_setting("sfx_volume"), 0.9, 0.0001, "wrong type replaced by default")


func test_corrupt_file_is_quarantined() -> void:
	var f := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	f.store_string("{not json")
	f.close()
	store.load_from_disk()
	assert_eq(store.data.stats.best_score, 0, "defaults used")
	assert_true(FileAccess.file_exists(TEST_PATH + ".corrupt"), "corrupt copy kept for diagnosis")


func test_no_temp_file_left_after_save() -> void:
	store.load_from_disk()
	store.save_now()
	assert_true(FileAccess.file_exists(TEST_PATH), "file exists")
	assert_false(FileAccess.file_exists(TEST_PATH + ".tmp"), "temp renamed away")
