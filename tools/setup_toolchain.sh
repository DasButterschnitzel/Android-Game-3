#!/usr/bin/env bash
# Reproducible toolchain setup for building the Android APK on Linux x86_64.
# Installs: Godot editor + export templates (pinned), Android SDK packages,
# a debug keystore and the Godot editor settings that point at them.
# Idempotent: re-running skips everything that is already present.
set -euo pipefail

GODOT_VERSION="${GODOT_VERSION:-4.7.2}"
GODOT_FLAVOR="${GODOT_FLAVOR:-stable}"
TOOLS_DIR="${TOOLS_DIR:-/opt/pocket-toolchain}"
ANDROID_SDK="${ANDROID_HOME:-/opt/android-sdk}"
JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")}"
CMDLINE_TOOLS_ZIP="commandlinetools-linux-16111833_latest.zip"   # cmdline-tools 23.0
BUILD_TOOLS="35.0.1"
PLATFORM="android-35"

GODOT_DL="https://downloads.godotengine.org/?version=${GODOT_VERSION}&flavor=${GODOT_FLAVOR}"
TEMPLATE_DIR="$HOME/.local/share/godot/export_templates/${GODOT_VERSION}.${GODOT_FLAVOR}"
GODOT_BIN="$TOOLS_DIR/Godot_v${GODOT_VERSION}-${GODOT_FLAVOR}_linux.x86_64"

mkdir -p "$TOOLS_DIR"

# Large downloads over flaky networks (CI saw "HTTP/2 stream was not closed
# cleanly"): retry with a clean file each time, falling back to HTTP/1.1.
fetch() {
  local out="$1" url="$2" i
  for i in 1 2 3 4 5; do
    rm -f "$out"
    if curl -fsSL --retry 3 --retry-all-errors --retry-delay 5 -o "$out" "$url"; then
      return 0
    fi
    rm -f "$out"
    if curl -fsSL --http1.1 --retry 3 --retry-all-errors --retry-delay 5 -o "$out" "$url"; then
      return 0
    fi
    echo "download failed (attempt $i), retrying in $((i * 10)) s: $url" >&2
    sleep $((i * 10))
  done
  return 1
}

echo "== Godot ${GODOT_VERSION}-${GODOT_FLAVOR}"
if [ ! -x "$GODOT_BIN" ]; then
  fetch "$TOOLS_DIR/godot.zip" "${GODOT_DL}&slug=linux.x86_64.zip"
  unzip -q -o "$TOOLS_DIR/godot.zip" -d "$TOOLS_DIR"
  rm -f "$TOOLS_DIR/godot.zip"
fi
ln -sf "$GODOT_BIN" /usr/local/bin/godot 2>/dev/null || true
"$GODOT_BIN" --version

echo "== Export templates"
if [ ! -f "$TEMPLATE_DIR/android_debug.apk" ]; then
  mkdir -p "$TEMPLATE_DIR"
  fetch "$TOOLS_DIR/templates.tpz" "${GODOT_DL}&slug=export_templates.tpz"
  unzip -q -o "$TOOLS_DIR/templates.tpz" -d "$TOOLS_DIR/tpl"
  # Keep only what this project needs (Android, Linux x86_64 for tests, Web for previews).
  for f in android_debug.apk android_release.apk android_source.zip version.txt icudt_godot.dat \
           linux_debug.x86_64 linux_release.x86_64 web_nothreads_debug.zip web_nothreads_release.zip; do
    [ -f "$TOOLS_DIR/tpl/templates/$f" ] && mv "$TOOLS_DIR/tpl/templates/$f" "$TEMPLATE_DIR/"
  done
  rm -rf "$TOOLS_DIR/tpl" "$TOOLS_DIR/templates.tpz"
fi
ls "$TEMPLATE_DIR"

echo "== Android SDK ($ANDROID_SDK)"
if [ ! -x "$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager" ]; then
  mkdir -p "$ANDROID_SDK/cmdline-tools"
  fetch "$TOOLS_DIR/cmdtools.zip" "https://dl.google.com/android/repository/$CMDLINE_TOOLS_ZIP"
  unzip -q -o "$TOOLS_DIR/cmdtools.zip" -d "$TOOLS_DIR/cmdtmp"
  rm -rf "$ANDROID_SDK/cmdline-tools/latest"
  mv "$TOOLS_DIR/cmdtmp/cmdline-tools" "$ANDROID_SDK/cmdline-tools/latest"
  rm -rf "$TOOLS_DIR/cmdtmp" "$TOOLS_DIR/cmdtools.zip"
fi
SDKM="$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager"
if [ ! -x "$ANDROID_SDK/build-tools/$BUILD_TOOLS/apksigner" ] || [ ! -d "$ANDROID_SDK/platforms/$PLATFORM" ]; then
  yes | "$SDKM" --sdk_root="$ANDROID_SDK" --licenses >/dev/null 2>&1 || true
  "$SDKM" --sdk_root="$ANDROID_SDK" "platform-tools" "build-tools;$BUILD_TOOLS" "platforms;$PLATFORM"
fi
# Optional (WITH_GRADLE=1): Gradle builds such as the experimental preset
# "Android-AdsTest" (tools/build_ads_test.sh) compile against android-36, the
# compileSdk of the Godot 4.7.2 Gradle build template.
if [ "${WITH_GRADLE:-0}" = "1" ] && [ ! -d "$ANDROID_SDK/platforms/android-36" ]; then
  yes | "$SDKM" --sdk_root="$ANDROID_SDK" --licenses >/dev/null 2>&1 || true
  "$SDKM" --sdk_root="$ANDROID_SDK" "platforms;android-36"
fi

echo "== Debug keystore"
KEYSTORE="$HOME/.android/debug.keystore"
if [ ! -f "$KEYSTORE" ]; then
  mkdir -p "$HOME/.android"
  keytool -genkeypair -keystore "$KEYSTORE" -storepass android -alias androiddebugkey \
    -keypass android -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=Android Debug,O=Android,C=US"
fi

echo "== Godot editor settings"
SETTINGS_DIR="$HOME/.config/godot"
MAJOR_MINOR="$(echo "$GODOT_VERSION" | cut -d. -f1-2)"
SETTINGS="$SETTINGS_DIR/editor_settings-${MAJOR_MINOR}.tres"
if [ ! -f "$SETTINGS" ]; then
  tmpproj="$(mktemp -d)"
  printf 'config_version=5\n' > "$tmpproj/project.godot"
  "$GODOT_BIN" --headless --editor --quit --path "$tmpproj" >/dev/null 2>&1 || true
  rm -rf "$tmpproj"
fi
python3 - "$SETTINGS" "$JAVA_HOME" "$ANDROID_SDK" "$KEYSTORE" <<'EOF'
import sys
path, java, sdk, ks = sys.argv[1:5]
wanted = {
    "export/android/java_sdk_path": java,
    "export/android/android_sdk_path": sdk,
    "export/android/debug_keystore": ks,
    "export/android/debug_keystore_user": "androiddebugkey",
    "export/android/debug_keystore_pass": "android",
}
lines = open(path).read().rstrip("\n").split("\n")
lines = [l for l in lines if l.split(" = ")[0] not in wanted]
lines += [f'{k} = "{v}"' for k, v in wanted.items()]
open(path, "w").write("\n".join(lines) + "\n")
print("editor settings updated:", path)
EOF
echo "Toolchain ready."
