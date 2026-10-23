#!/usr/bin/env bash
# Soak test: many nights in the real game scene with a bot (headless, fixed
# 60 fps). Fails on any engine/script error or if node/object/resource counts
# grow over the session. A bot, not a human (device plan E2 stays open).
# Usage: tools/soak.sh [nights=30]
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$(mktemp)"
timeout 3000 godot --headless --fixed-fps 60 --path "$ROOT/game" --script res://tests/simulation/soak_echo.gd -- "${1:-30}" > "$LOG" 2>&1
grep -E "^SOAK" "$LOG"
ERRORS=$(grep -E "SCRIPT ERROR|^ERROR:" "$LOG" | grep -vE "resources still in use at exit|ObjectDB instances" || true)
if [ -n "$ERRORS" ]; then
  echo "SOAK FAIL errors:"; echo "$ERRORS" | sort | uniq -c | head -20; exit 1
fi
grep -q "^SOAK OK" "$LOG" || { echo "SOAK FAIL (see counts above)"; exit 1; }
