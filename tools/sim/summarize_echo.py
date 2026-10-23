#!/usr/bin/env python3
"""Compact table from the JSON printed by tests/simulation/sim_echo.gd (reads stdin)."""
import json, sys
raw = sys.stdin.read()
data = json.loads(raw[raw.index('{'):raw.rindex('}') + 1])
res, extra = data["results"], data["extra"]
print(f"rounds {data['rounds']}  seeds from {data['seed_base']}  bot speed {data['speed']} px/s")
print(f"{'strategy':8} {'score':>6} {'p10':>6} {'p90':>6} {'waves':>5} {'leaks':>5} {'runs/w':>6} {'lights':>6} {'round s':>7} {'dawn':>5} {'twins':>5}")
for k, r in res.items():
    x = extra[k]
    print(f"{k:8} {r['score']['median']:6.0f} {r['score']['p10']:6.0f} {r['score']['p90']:6.0f} {r['waves']['median']:5.0f} "
          f"{r['leaks']['median']:5.0f} {r['runs_per_wave']['median']:6.2f} {r['lights']['median']:6.0f} "
          f"{r['round_seconds']['median']:7.1f} {x['dawn_share']:5.2f} {x['twin_kill_share']:5.2f}")
for k, v in data["acceptance"].items():
    print(f"{'PASS' if v['pass'] else 'FAIL'} {k}: " + ", ".join(f"{a}={b}" for a, b in v.items() if a != 'pass'))
