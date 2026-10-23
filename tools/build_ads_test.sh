#!/usr/bin/env bash
# Experimental ads test build (spike for milestone 0.6): exports the preset
# "Android-AdsTest" with Gradle (Google Mobile Ads + UMP through the NachhallAds
# plugin, Google's public TEST ids only) and checks the APK at build level.
# The normal "Android" preset is not affected. See docs/compliance/ADS_TEST_BUILD.md.
# Usage: tools/build_ads_test.sh [output.apk]
# Needs: tools/setup_toolchain.sh, platform android-36, network to Google Maven,
# Maven Central and services.gradle.org (first run downloads Gradle and the SDKs).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(realpath -m "${1:-$ROOT/builds/android/nachhall-adstest-debug.apk}")"
export ANDROID_HOME="${ANDROID_HOME:-/opt/android-sdk}"

# Godot unpacks its Gradle build template to game/android/ (gitignored).
GODOT_EXPORT_ARGS="--install-android-build-template" \
  bash "$ROOT/tools/build_android.sh" "$ROOT/game" "$OUT" debug Android-AdsTest
bash "$ROOT/tools/verify_ads_build.sh" "$OUT"
