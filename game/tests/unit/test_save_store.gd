extends TestCase
## Persistence: round trip, defaults merge, corruption recovery, atomic writes.

var store: SaveStore
const TEST_PATH := "user://test_save.json"


func before_each() -> void:
	SaveStore.remove_files(TEST_PATH)
	if FileAccess.file_exists(TEST_PATH + ".corrupt"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH + ".corrupt"))
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


## Power loss after the newest write: the file comes back empty. The last good
## copy is used instead of resetting all progress (QA review 0.7).
func test_broken_newest_file_falls_back_to_the_last_good_copy() -> void:
	store.load_from_disk()
	store.data.stats.best_score = 500
	assert_true(store.save_now(), "first save")
	store.data.stats.best_score = 900
	assert_true(store.save_now(), "second save keeps the first as backup")
	var f := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	f.store_string("")  # what a lost write can leave behind
	f.close()
	var other := SaveStore.new()
	other.path = TEST_PATH
	other.load_from_disk()
	assert_eq(other.data.stats.best_score, 500, "progress from the last good copy, not the defaults")
	assert_true(FileAccess.file_exists(TEST_PATH + ".corrupt"), "the broken file is kept for diagnosis")
	other.free()


## A failed write must not block later saves until the app is backgrounded.
func test_a_failed_write_does_not_block_later_saves() -> void:
	store.path = "user://no_such_dir/save.json"  # cannot be written
	store.load_from_disk()
	store.mark_dirty("x")
	await frames(2)
	assert_false(FileAccess.file_exists(store.path), "the write failed")
	store.path = TEST_PATH  # storage is back
	store.record_echo_round(42, {}, 10.0)
	await frames(2)
	assert_true(FileAccess.file_exists(TEST_PATH), "the next change was saved")


## Players of 0.2/0.3 get the Sternbilder their lifetime stats already prove.
func test_old_saves_get_the_sternbilder_their_stats_prove() -> void:
	var f := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({"version": 2, "stats": {"best_score": 1200, "dawns": 2, "rounds_played": 4}}))
	f.close()
	store.load_from_disk()
	assert_true(store.data.unlocks.has("dawn"), "an old dawn counts (opens Vollmond)")
	assert_true(store.data.unlocks.has("score_1000"), "an old best of 1.200 counts")
	assert_false(store.data.unlocks.has("score_1500"), "nothing that was not reached")
	assert_false(store.data.unlocks.has("nights_10"), "4 nights are not 10")


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


func test_history_keeps_the_last_nights() -> void:
	store.load_from_disk()
	for i in SaveStore.HISTORY_SIZE + 5:
		store.record_echo_round(100 + i, {"waves_banked": 3, "dawn": i % 2 == 0}, 60.0, i % 3 == 0, "")
	var h: Array = store.data.history
	assert_eq(h.size(), SaveStore.HISTORY_SIZE, "capped")
	assert_eq(int(h[h.size() - 1].s), 100 + SaveStore.HISTORY_SIZE + 4, "newest last")
	assert_eq(int(h[0].s), 105, "oldest dropped")
	store.save_now()
	var other := SaveStore.new()
	other.path = TEST_PATH
	other.load_from_disk()
	assert_eq((other.data.history as Array).size(), SaveStore.HISTORY_SIZE, "survives a reload")
	assert_eq(HistoryChart.summary(other.data.history).begins_with("Ø der letzten 10:"), true, "summary line")
	other.free()


func test_saves_from_0_4_get_an_empty_history() -> void:
	var f := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({"version": 2, "stats": {"best_score": 700, "rounds_played": 4}}))
	f.close()
	store.load_from_disk()
	assert_eq(store.data.stats.best_score, 700, "progress kept")
	assert_eq((store.data.history as Array).size(), 0, "history starts empty")
