#!/usr/bin/env bash
# Release build for Google Play (Android App Bundle, preset "Android-Release")
# and its verification with bundletool, jarsigner, aapt2 and apksigner.
#
# Signing: the owner's upload key via GODOT_ANDROID_KEYSTORE_RELEASE_PATH /
# _USER / _PASSWORD. Without them, --throwaway creates a temporary key under
# builds/release/ (gitignored) only to prove that the configuration builds and
# verifies. Never upload a bundle signed with the throwaway key.
# Usage: tools/build_release.sh [out.aab] [--throwaway]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(realpath -m "${1:-$ROOT/builds/release/nachhall-release.aab}")"
ANDROID_SDK="${ANDROID_HOME:-/opt/android-sdk}"
BT_DIR="$ANDROID_SDK/build-tools/35.0.1"
[ -x "$BT_DIR/apksigner" ] || BT_DIR="$(ls -d "$ANDROID_SDK"/build-tools/* | sort -V | tail -1)"
# bundletool: an "all" jar via BUNDLETOOL_JAR, else the library jar and its
# dependencies from the Gradle cache (present after any Gradle export).
bt() {
  if [ -n "${BUNDLETOOL_JAR:-}" ]; then java -jar "$BUNDLETOOL_JAR" "$@"; return; fi
  local c="$HOME/.gradle/caches/modules-2/files-2.1" cp
  cp="$(find "$c" -name 'bundletool-*.jar' ! -name '*sources*' | sort -V | tail -1)"
  # Only the newest -jre guava: the -android flavour lacks APIs bundletool calls.
  cp="$cp:$(find "$c"/com.google.guava/guava -name 'guava-*-jre.jar' | sort -V | tail -1)"
  for j in $(find "$c"/com.google.protobuf "$c"/com.google.guava/failureaccess "$c"/com.google.dagger "$c"/javax.inject \
      "$c"/com.google.auto.value "$c"/com.google.errorprone "$c"/org.checkerframework -name '*.jar' ! -name '*sources*' 2>/dev/null | sort -V) \
      $(find "$c" \( -path '*aapt2-proto*' -o -path '*jose4j*' -o -path '*bcprov*' \) -name '*.jar' ! -name '*sources*' 2>/dev/null); do
    cp="$cp:$j"
  done
  java -cp "$cp" com.android.tools.build.bundletool.BundleToolMain "$@"
}
mkdir -p "$(dirname "$OUT")"
if [ -z "${GODOT_ANDROID_KEYSTORE_RELEASE_PATH:-}" ]; then
  if [ "${2:-}" != "--throwaway" ]; then
    echo "Set GODOT_ANDROID_KEYSTORE_RELEASE_PATH/_USER/_PASSWORD (upload key) or pass --throwaway." >&2
    exit 2
  fi
  KS="$(dirname "$OUT")/throwaway-upload.jks"
  [ -f "$KS" ] || keytool -genkeypair -keystore "$KS" -alias throwaway -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass throwaway -keypass throwaway -dname "CN=Throwaway test key, O=NACHHALL build check, C=DE" >/dev/null 2>&1
  export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="$KS" GODOT_ANDROID_KEYSTORE_RELEASE_USER=throwaway \
    GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD=throwaway
fi
LOG="${OUT%.aab}.build.log"
REPORT="${OUT%.aab}.verify.txt"
rm -f "$OUT"
{
  godot --headless --path "$ROOT/game" --import 2>&1 | tail -3
  godot --headless --path "$ROOT/game" --install-android-build-template --export-release "Android-Release" "$OUT" 2>&1 \
    | grep -vE 'ADDING: |JAVA_TOOL_OPTIONS|^\s*$' || true
} > "$LOG" 2>&1
[ -s "$OUT" ] || { echo "BUILD FAILED, see $LOG" >&2; tail -30 "$LOG" >&2; exit 1; }

TMP="$(mktemp -d)"
{
  echo "# Verification of $(basename "$OUT")"
  echo "size_bytes: $(stat -c %s "$OUT")"
  echo "sha256: $(sha256sum "$OUT" | cut -d' ' -f1)"
  echo "signed_with_throwaway_key: $([ "${GODOT_ANDROID_KEYSTORE_RELEASE_USER}" = throwaway ] && echo yes || echo no)"
  echo
  echo "## bundletool validate"
  if bt validate --bundle="$OUT" > "$TMP/validate.txt" 2>&1; then echo "valid"
  else echo "INVALID"; grep -v JAVA_TOOL_OPTIONS "$TMP/validate.txt" | tail -5; fi
  echo
  echo "## manifest (bundletool dump manifest, excerpt)"
  bt dump manifest --bundle="$OUT" 2>/dev/null \
    | grep -E "package=|versionCode|versionName|uses-permission|debuggable|minSdkVersion|targetSdkVersion" | sed 's/^ */  /' || true
  echo
  echo "## jarsigner"
  jarsigner -verify "$OUT" 2>&1 | grep -E "verified|unsigned" | head -2 || true
  echo
  echo "## universal APK built from the bundle"
  bt build-apks --bundle="$OUT" --output="$TMP/u.apks" --mode=universal --aapt2="$BT_DIR/aapt2" \
    --ks="$GODOT_ANDROID_KEYSTORE_RELEASE_PATH" --ks-pass="pass:$GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD" \
    --ks-key-alias="$GODOT_ANDROID_KEYSTORE_RELEASE_USER" --key-pass="pass:$GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD" \
    > "$TMP/build-apks.txt" 2>&1 || { echo "build-apks FAILED"; grep -v JAVA_TOOL_OPTIONS "$TMP/build-apks.txt" | tail -5; }
  unzip -o -q "$TMP/u.apks" universal.apk -d "$TMP" || echo "no universal.apk"
  "$BT_DIR/aapt2" dump badging "$TMP/universal.apk" 2>/dev/null | grep -E "^(package|uses-permission|application-debuggable|native-code)" || true
  echo "debuggable: $("$BT_DIR/aapt2" dump badging "$TMP/universal.apk" 2>/dev/null | grep -c application-debuggable || true)"
  if "$BT_DIR/apksigner" verify "$TMP/universal.apk" > "$TMP/apksigner.txt" 2>&1; then echo "apksigner: ok"
  else echo "apksigner: FAILED"; grep -v JAVA_TOOL_OPTIONS "$TMP/apksigner.txt" | head -5; fi
  echo
  echo "## 16 KB page size (Play: required for Android 15+ targets; 64-bit libraries)"
  unzip -q -o "$OUT" 'base/lib/arm64-v8a/*' -d "$TMP/so" 2>/dev/null || true
  for so in "$TMP"/so/base/lib/arm64-v8a/*.so; do
    [ -f "$so" ] || continue
    ok=ok
    aligns=""
    for a in $(readelf -lW "$so" 2>/dev/null | awk '/^ +LOAD/ {print $NF}'); do
      aligns="$aligns $a"
      [ $((a)) -ge 16384 ] || ok="NOT 16 KB aligned"
    done
    echo "$(basename "$so"): LOAD align$aligns -> $ok"
  done
  echo
  echo "## bundle contents"
  # Godot puts the project files into an install-time asset pack.
  echo "asset files: $(unzip -l "$OUT" | grep -cE ' (base|assetPack[A-Za-z]*)/assets/' || true)"
  echo "debug-only content (tests, prototypes): $(unzip -l "$OUT" | grep -cE ' (base|assetPack[A-Za-z]*)/assets/(tests|prototypes)/' || true)"
  echo "addons packed: $(unzip -l "$OUT" | grep -oE 'assets/addons/[^ ]+' | tr '\n' ' ')"
} > "$REPORT" 2>&1
rm -rf "$TMP"
cat "$REPORT"
