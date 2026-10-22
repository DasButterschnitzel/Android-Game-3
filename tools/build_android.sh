#!/usr/bin/env bash
# Export a Godot project to a signed Android APK and verify the result.
# Usage: tools/build_android.sh <project_dir> <output.apk> [debug|release] [preset]
# Writes <output>.build.log (full log) and <output>.verify.txt (aapt2 + apksigner report).
set -euo pipefail

PROJECT_DIR="$(realpath -e "${1:?project dir}")"
# -m: the output directory may not exist yet (e.g. fresh CI checkout).
OUT="$(realpath -m "${2:?output apk}")"
MODE="${3:-debug}"
PRESET="${4:-Android}"
ANDROID_SDK="${ANDROID_HOME:-/opt/android-sdk}"
GODOT="${GODOT:-godot}"

BT_DIR="$(ls -d "$ANDROID_SDK"/build-tools/* | sort -V | tail -1)"
mkdir -p "$(dirname "$OUT")"
LOG="${OUT%.apk}.build.log"
VERIFY="${OUT%.apk}.verify.txt"
rm -f "$OUT" "$OUT.idsig"

{
  echo "# Build $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "project: $PROJECT_DIR"
  echo "mode: $MODE  preset: $PRESET"
  echo "godot: $("$GODOT" --version)"
  echo "git: $(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo n/a)"
  echo
  echo "## import"
  "$GODOT" --headless --path "$PROJECT_DIR" --import 2>&1 | grep -vE '^\s*$' | tail -20 || true
  echo
  echo "## export"
  "$GODOT" --headless --path "$PROJECT_DIR" "--export-$MODE" "$PRESET" "$OUT" 2>&1 \
    | grep -vE 'ADDING: |JAVA_TOOL_OPTIONS|^\s*$' || true
} > "$LOG" 2>&1

if [ ! -s "$OUT" ]; then
  echo "BUILD FAILED: $OUT was not produced. See $LOG" >&2
  tail -30 "$LOG" >&2
  exit 1
fi

{
  echo "# Verification of $(basename "$OUT")"
  echo "size_bytes: $(stat -c %s "$OUT")"
  echo "sha256: $(sha256sum "$OUT" | cut -d' ' -f1)"
  echo
  echo "## aapt2 dump badging"
  "$BT_DIR/aapt2" dump badging "$OUT" 2>/dev/null \
    | grep -E "^(package|minSdk|targetSdk|application-label:|application:|uses-permission|native-code|uses-gl-es|launchable)" || true
  echo
  echo "## permissions"
  "$BT_DIR/aapt2" dump permissions "$OUT" 2>/dev/null || true
  echo
  echo "## apksigner verify"
  "$BT_DIR/apksigner" verify --print-certs "$OUT" 2>&1 | grep -v JAVA_TOOL_OPTIONS
  echo
  echo "## native libs"
  unzip -l "$OUT" | grep -E '\.so$' || true
} > "$VERIFY" 2>&1

if ! grep -q "Signer #1" "$VERIFY"; then
  echo "VERIFY FAILED: signature check did not pass. See $VERIFY" >&2
  exit 1
fi
echo "OK: $OUT ($(du -h "$OUT" | cut -f1))"
grep -E "^(package|minSdk|targetSdk)" "$VERIFY"
