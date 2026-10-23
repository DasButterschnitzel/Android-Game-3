#!/usr/bin/env bash
# Build the NachhallAds Android plugin (AAR, debug + release) and copy both into
# the Godot addon (game/addons/nachhall_ads/bin/). Experimental ads test build only,
# see docs/compliance/ADS_TEST_BUILD.md.
# Needs JDK 17+, the Android SDK with platform android-36 and network access to
# Google Maven, Maven Central and services.gradle.org (Gradle wrapper 8.11.1).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN="$ROOT/android_plugins/nachhall_ads"
BIN="$ROOT/game/addons/nachhall_ads/bin"
export ANDROID_HOME="${ANDROID_HOME:-/opt/android-sdk}"

(cd "$PLUGIN" && ./gradlew --no-daemon --console=plain clean assembleDebug assembleRelease)
mkdir -p "$BIN/debug" "$BIN/release"
cp "$PLUGIN/build/outputs/aar/NachhallAds-debug.aar" "$BIN/debug/"
cp "$PLUGIN/build/outputs/aar/NachhallAds-release.aar" "$BIN/release/"
ls -l "$BIN"/debug/*.aar "$BIN"/release/*.aar
