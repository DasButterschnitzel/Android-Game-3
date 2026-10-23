@tool
extends EditorExportPlugin
## Adds the NachhallAds Android plugin (Google Mobile Ads + UMP) to Android
## exports whose preset lists the custom feature "nachhall_ads" (preset
## "Android-AdsTest", Gradle build). Every other export, including the normal
## "Android" preset, gets nothing from here: no AAR, no SDK, no manifest entry.
## Only Google's public TEST app id is ever written; see
## docs/compliance/ADS_TEST_BUILD.md.

const FEATURE := "nachhall_ads"
const CONFIG_PATH := "res://data/ads.json"
## Google's public sample publisher id; any other id is refused.
const TEST_PUBLISHER := "ca-app-pub-3940256099942544"
## Keep in sync with android_plugins/nachhall_ads/build.gradle.
const DEPENDENCIES := [
	"com.google.android.gms:play-services-ads:25.5.0",
	"com.google.android.ump:user-messaging-platform:4.0.0",
]


func _get_name() -> String:
	return "NachhallAds"


func _supports_platform(platform: EditorExportPlatform) -> bool:
	return platform is EditorExportPlatformAndroid


func _get_android_libraries(_platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
	if not _enabled():
		return PackedStringArray()
	var kind := "debug" if debug else "release"
	print("NachhallAds: adding Android plugin %s AAR, %s, Google TEST app id" % [kind, ", ".join(DEPENDENCIES)])
	return PackedStringArray(["nachhall_ads/bin/%s/NachhallAds-%s.aar" % [kind, kind]])


func _get_android_dependencies(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
	return PackedStringArray(DEPENDENCIES) if _enabled() else PackedStringArray()


func _get_android_manifest_application_element_contents(_platform: EditorExportPlatform, _debug: bool) -> String:
	if not _enabled():
		return ""
	return "<meta-data android:name=\"com.google.android.gms.ads.APPLICATION_ID\" android:value=\"%s\" />" % test_app_id()


## True only while exporting a preset with the custom feature "nachhall_ads"
## and only if data/ads.json holds Google's public test app id.
func _enabled() -> bool:
	var preset := get_export_preset()
	if preset == null:
		return false
	var features := Array(preset.get_custom_features().split(",")).map(func(f: String) -> String: return f.strip_edges())
	if not features.has(FEATURE):
		return false
	if test_app_id() == "":
		push_error("NachhallAds: %s admob_test_ids.app_id is not Google's public test app id; ads SDK NOT added." % CONFIG_PATH)
		return false
	return true


## Google's public test app id from data/ads.json, or "" if it is anything else.
static func test_app_id() -> String:
	var data = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if typeof(data) != TYPE_DICTIONARY or typeof(data.get("admob_test_ids")) != TYPE_DICTIONARY:
		return ""
	var app_id := str(data.admob_test_ids.get("app_id", ""))
	return app_id if app_id.begins_with(TEST_PUBLISHER + "~") else ""
