#!/usr/bin/env bash
# Layout check of every screen at phone and tablet resolutions (Xvfb, software
# OpenGL): reports controls that are off screen, overlap or are smaller than
# 48 dp (UiTheme.TOUCH_MIN), and saves one screenshot per screen and size.
# Usage: tools/layout_check.sh [out_dir] [extra probe args, e.g. safe_top=100]
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(realpath -m "${1:-$ROOT/builds/layout}")"; shift || true
mkdir -p "$OUT"
FAIL=0
for res in 720x1280 1080x2400 480x854 1536x2048; do
  for screen in menu settings collection credits licenses privacy rules game pause between results results_many; do
    LOG="$OUT/${screen}_${res}.log"
    xvfb-run -a -s "-screen 0 ${res}x24" godot --path "$ROOT/game" --rendering-driver opengl3 --resolution "$res" \
      --script res://tests/capture/layout_probe.gd -- "$screen" "$OUT" "$@" save=layout_probe.json fresh_save > "$LOG" 2>&1
    if grep -qE "OFFSCREEN|SMALL|OVERLAP|SCRIPT ERROR" "$LOG" || ! grep -q "^PROBLEMS=0" "$LOG"; then
      FAIL=1
      echo "== $screen $res"
      grep -E "OFFSCREEN|SMALL|OVERLAP|SCRIPT ERROR|PROBLEMS" "$LOG" | head -12
    fi
  done
done
[ "$FAIL" = 0 ] && echo "layout OK: no control off screen, overlapping or under 48 dp ($OUT)"
exit $FAIL
