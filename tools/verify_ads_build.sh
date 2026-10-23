#!/usr/bin/env bash
# Build-level checks of the experimental ads test APK, and that the normal APK
# has no ads SDK. Writes a report next to each APK (<apk>.ads-check.txt) and
# fails on the first broken expectation. Nothing here runs the app: whether ads
# work on a device is NOT checked (no device/emulator, see ADS_TEST_BUILD.md).
# Usage: tools/verify_ads_build.sh <adstest.apk> [<default.apk>]
set -euo pipefail
ANDROID_SDK="${ANDROID_HOME:-/opt/android-sdk}"
BT="$ANDROID_SDK/build-tools/35.0.1"
[ -x "$BT/aapt2" ] || BT="$(ls -d "$ANDROID_SDK"/build-tools/* | sort -V | tail -1)"
TEST_APP_ID="ca-app-pub-3940256099942544~3347511713"
TEST_PUBLISHER="ca-app-pub-3940256099942544"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

# Class descriptors of all dex files of an APK, one per line.
dex_classes() {
  local dir
  dir="$(mktemp -d "$WORK/dex.XXXXXX")"
  unzip -q "$1" 'classes*.dex' -d "$dir"
  for f in "$dir"/classes*.dex; do
    "$BT/dexdump" "$f" 2>/dev/null | sed -n "s/^ *Class descriptor *: 'L\(.*\);'/\1/p"
  done
}

report_apk() {  # <apk> <report>
  {
    echo "# $(basename "$1")"
    echo "size_bytes: $(stat -c %s "$1")"
    echo "sha256: $(sha256sum "$1" | cut -d' ' -f1)"
    echo
    echo "## aapt2 dump badging (excerpt)"
    "$BT/aapt2" dump badging "$1" 2>/dev/null | grep -E "^(package|minSdk|targetSdk|application-label:|uses-permission)" || true
    echo
    echo "## manifest meta-data / ad ids (aapt2 dump xmltree)"
    "$BT/aapt2" dump xmltree --file AndroidManifest.xml "$1" 2>/dev/null | awk '
      /E: meta-data/ { m = 1; n = ""; next }
      m && /android:name\(/ { n = substr($0, index($0, ")=") + 2); sub(/ \(Raw:.*$/, "", n); next }
      m && /android:(value|resource)\(/ {
        v = substr($0, index($0, ")=") + 2); sub(/ \(Raw:.*$/, "", v); print "  " n " = " v; m = 0; next }
      m && /E: / { print "  " n; m = 0 }'
    echo
    echo "## dex classes"
    echo "total: $(wc -l < "$WORK/classes.txt")"
    echo "com/google/android/gms/ads/*: $(grep -c '^com/google/android/gms/ads/' "$WORK/classes.txt" || true)"
    echo "com/google/android/ump/*: $(grep -c '^com/google/android/ump/' "$WORK/classes.txt" || true)"
    echo "NachhallAdsPlugin: $(grep -c 'nachhall/ads/NachhallAdsPlugin$' "$WORK/classes.txt" || true)"
    grep -E '^com/google/android/gms/ads/(MobileAds|interstitial/InterstitialAd|AdActivity)$|^com/google/android/ump/UserMessagingPlatform$|NachhallAdsPlugin$' "$WORK/classes.txt" | sed 's/^/  /' || true
    echo
    echo "## assets/project.binary (feature tag, boot scene override)"
    unzip -p "$1" assets/project.binary | strings | grep -E "nachhall_ads|_custom_features|ads_test_boot" | sed 's/^/  /' || true
  } > "$2"
}

check_adstest() {
  local apk="$1" report="${1%.apk}.ads-check.txt" manifest
  dex_classes "$apk" > "$WORK/classes.txt"
  report_apk "$apk" "$report"
  manifest="$("$BT/aapt2" dump xmltree --file AndroidManifest.xml "$apk" 2>/dev/null)"
  "$BT/aapt2" dump permissions "$apk" 2>/dev/null | grep -q "name='android.permission.INTERNET'" || fail "AdsTest: INTERNET permission missing"
  grep -A1 'com.google.android.gms.ads.APPLICATION_ID' <<<"$manifest" | grep -q "\"$TEST_APP_ID\"" \
    || fail "AdsTest: manifest lacks APPLICATION_ID = Google test app id"
  grep -q 'org.godotengine.plugin.v2.NachhallAds' <<<"$manifest" || fail "AdsTest: plugin v2 meta-data missing"
  # Every AdMob id anywhere in the manifest must be Google's test publisher.
  if grep -oE 'ca-app-pub-[0-9]+' <<<"$manifest" | grep -qv "^$TEST_PUBLISHER$"; then
    fail "AdsTest: manifest contains an AdMob id that is not Google's test publisher"
  fi
  grep -q '^com/google/android/gms/ads/MobileAds$' "$WORK/classes.txt" || fail "AdsTest: MobileAds class not in dex"
  grep -q '^com/google/android/gms/ads/interstitial/InterstitialAd$' "$WORK/classes.txt" || fail "AdsTest: InterstitialAd not in dex"
  grep -q '^com/google/android/ump/UserMessagingPlatform$' "$WORK/classes.txt" || fail "AdsTest: UMP not in dex"
  grep -q 'nachhall/ads/NachhallAdsPlugin$' "$WORK/classes.txt" || fail "AdsTest: NachhallAdsPlugin not in dex"
  unzip -p "$apk" assets/project.binary | strings | grep -q "nachhall_ads" || fail "AdsTest: feature tag nachhall_ads not in project.binary"
  echo "OK AdsTest: $apk ($(du -h "$apk" | cut -f1)) -> $report"
}

check_default() {
  local apk="$1" report="${1%.apk}.ads-check.txt" manifest
  dex_classes "$apk" > "$WORK/classes.txt"
  report_apk "$apk" "$report"
  manifest="$("$BT/aapt2" dump xmltree --file AndroidManifest.xml "$apk" 2>/dev/null)"
  if "$BT/aapt2" dump permissions "$apk" 2>/dev/null | grep -q "name='android.permission.INTERNET'"; then
    fail "default: INTERNET permission present"
  fi
  if grep -qE 'ca-app-pub-|com.google.android.gms.ads|NachhallAds' <<<"$manifest"; then
    fail "default: ads entries in the manifest"
  fi
  if grep -qE '^com/google/android/(gms/ads|ump)/|NachhallAdsPlugin$' "$WORK/classes.txt"; then
    fail "default: ads SDK classes in dex"
  fi
  echo "OK default: $apk ($(du -h "$apk" | cut -f1)) has no ads SDK, no INTERNET -> $report"
}

check_adstest "${1:?adstest apk}"
[ -n "${2:-}" ] && check_default "$2"
exit 0
