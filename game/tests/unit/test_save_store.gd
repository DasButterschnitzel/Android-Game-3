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
	var st := {"waves_banked": 5, "perfect_waves": 3, "lights": 11, "dawn": true}
	assert_true(store.record_echo_round(1234, st, 77.5), "first round is a best")
	assert_false(store.record_echo_round(1000, st, 20.0), "lower is not a best")
	assert_true(store.save_now(), "saved")
	var other := SaveStore.new()
	other.path = TEST_PATH
	other.load_from_disk()
	assert_eq(other.data.stats.best_score, 1234, "best persisted")
	assert_eq(other.data.stats.rounds_played, 2, "rounds persisted")
	assert_eq(other.data.stats.dawns, 2, "dawns counted")
	assert_eq(other.data.stats.lights, 22, "lights summed")
	assert_near(other.get_setting("sfx_volume"), 0.25, 0.0001, "setting persisted")
	other.free()


func test_missing_keys_are_filled_and_unknown_dropped() -> void:
	var f := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({"version": 2, "stats": {"best_score": 77}, "garbage": 1, "settings": {"sfx_volume": "loud"}}))
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


func test_v1_prototype_stats_are_not_carried_over() -> void:
	var f := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({"version": 1, "stats": {"best_score": 5000, "rounds_played": 9}, "settings": {"muted": true}}))
	f.close()
	store.load_from_disk()
	assert_eq(store.data.stats.best_score, 0, "LUNTE-era best score dropped")
	assert_true(store.get_setting("muted"), "settings kept")
	assert_eq(store.data.version, SaveStore.SCHEMA_VERSION, "upgraded")


func test_daily_best_is_kept_per_day() -> void:
	store.load_from_disk()
	store.record_echo_round(300, {}, 60.0, true)
	store.record_echo_round(200, {}, 60.0, true)
	assert_eq(store.data.daily.best, 300, "best of the day")
	assert_eq(store.data.daily.played, 2, "rounds of the day")
	assert_eq(store.data.daily.date, Time.get_date_string_from_system(), "today")
