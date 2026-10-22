#!/usr/bin/env bash
# Record a bot-played session of a scene under Xvfb (software OpenGL) and encode it.
# Usage: tools/capture.sh <out_dir> <seconds> [scene=res://...] [profile=normal] [seed=7]
set -euo pipefail
OUT="$(readlink -f "${1:?out dir}")"; SECS="${2:-30}"; shift 2 || true
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FPS=30
mkdir -p "$OUT/frames"
rm -f "$OUT"/frames/*.png
xvfb-run -a -s "-screen 0 720x1280x24" godot --path "$ROOT/game" --rendering-driver opengl3 \
  --resolution 720x1280 --fixed-fps $FPS --write-movie "$OUT/frames/f.png" \
  --quit-after $((SECS * FPS)) res://tests/capture/capture.tscn -- "$@" > "$OUT/capture.log" 2>&1 || true
N=$(ls "$OUT"/frames/*.png 2>/dev/null | wc -l)
echo "frames: $N"
[ "$N" -gt 0 ] || { tail -20 "$OUT/capture.log"; exit 1; }
ffmpeg -y -loglevel error -framerate $FPS -i "$OUT/frames/f%08d.png" -vf "scale=540:-2" -c:v libx264 -pix_fmt yuv420p -crf 26 "$OUT/gameplay.mp4"
echo "video: $OUT/gameplay.mp4 ($(du -h "$OUT/gameplay.mp4" | cut -f1))"
