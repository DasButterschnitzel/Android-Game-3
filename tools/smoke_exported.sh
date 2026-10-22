#!/usr/bin/env bash
# Export a Linux debug build (same packing as Android) and run the in-game smoke
# test in it. Fails on any engine/script error in the exported build.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT:-godot}"
OUT="$ROOT/builds/linux"
mkdir -p "$OUT"
"$GODOT" --headless --path "$ROOT/game" --export-debug "LinuxSmoke" "$OUT/pocket.x86_64" > "$OUT/export.log" 2>&1
LOG="$OUT/smoke.log"
timeout 300 "$OUT/pocket.x86_64" --headless -- --smoke > "$LOG" 2>&1 || true
if grep -qE "SCRIPT ERROR|^ERROR" "$LOG" || ! grep -q "SMOKE OK" "$LOG"; then
  echo "SMOKE FAILED"; grep -E "SMOKE|ERROR" "$LOG" | head -20; exit 1
fi
grep "SMOKE" "$LOG"
