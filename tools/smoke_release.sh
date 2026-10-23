#!/usr/bin/env bash
# Smoke test of a RELEASE export (OS.is_debug_build() == false): exports a
# temporary copy of the project whose main scene runs SmokeTest (the in-game
# smoke test is otherwise reachable only in debug builds), plays a full night
# with the bot and checks every scene, with release code paths (no debug
# features, no ad backend). Fails on any engine/script error. The repository
# itself is not changed.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT:-godot}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/game" "$WORK/out" "$WORK/data"
tar -C "$ROOT/game" --exclude=./android --exclude=./tests --exclude=./.godot -cf - . | tar -C "$WORK/game" -xf -
cat > "$WORK/game/release_smoke.gd" <<'GD'
extends Node
func _ready() -> void:
	print("RELEASE debug_build=", OS.is_debug_build())
	SmokeTest.run.call_deferred(get_tree())
GD
printf '[gd_scene format=3]\n\n[ext_resource type="Script" path="res://release_smoke.gd" id="1"]\n\n[node name="ReleaseSmoke" type="Node"]\nscript = ExtResource("1")\n' > "$WORK/game/release_smoke.tscn"
sed -i 's|^run/main_scene=.*|run/main_scene="res://release_smoke.tscn"|' "$WORK/game/project.godot"
"$GODOT" --headless --path "$WORK/game" --import > "$WORK/import.log" 2>&1 || true
"$GODOT" --headless --path "$WORK/game" --export-release "LinuxSmoke" "$WORK/out/nachhall.x86_64" > "$WORK/export.log" 2>&1 \
  || { echo "RELEASE SMOKE: export failed"; tail -20 "$WORK/export.log"; exit 1; }
LOG="$ROOT/builds/linux/release_smoke.log"
mkdir -p "$(dirname "$LOG")"
XDG_DATA_HOME="$WORK/data" timeout 300 "$WORK/out/nachhall.x86_64" --headless --fixed-fps 60 > "$LOG" 2>&1 || true
ERRORS="$(grep -E "SCRIPT ERROR|^ERROR" "$LOG" | grep -v "resources still in use at exit" || true)"
if [ -n "$ERRORS" ] || ! grep -q "SMOKE OK" "$LOG" || ! grep -q "RELEASE debug_build=false" "$LOG"; then
  echo "RELEASE SMOKE FAILED"; echo "$ERRORS" | head -20; grep -E "RELEASE|SMOKE" "$LOG" | head -20; exit 1
fi
grep -E "RELEASE|SMOKE" "$LOG"
