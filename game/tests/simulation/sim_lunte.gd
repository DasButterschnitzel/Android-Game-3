extends SceneTree
## Headless balancing simulation for LUNTE with decoupled bot profiles and an
## automatic check of the acceptance criteria B1-B4 (docs/decisions/0001).
## Usage: godot --headless --path game --script res://tests/simulation/sim_lunte.gd -- [rounds] [overrides_json]
## Simulated bots are NOT human playtests.

const PROFILES := ["g2.2_s300", "g1.3_s300", "g0.75_s300", "g1.3_s230", "g1.3_s400"]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var rounds := int(args[0]) if args.size() > 0 else 40
	var overrides: Dictionary = JSON.parse_string(args[1]) if args.size() > 1 else {}
	var cfg := Config.with_overrides(Config.load_balance("lunte"), overrides)
	var arena := Rect2(10, 130, 700, 1130)
	var summary := {}
	for profile in PROFILES:
		var rows := []
		for r in rounds:
			rows.append(_run_round(cfg, arena, 1000 + r, profile))
		summary[profile] = _aggregate(rows)
	var checks := _acceptance(summary)
	print(JSON.stringify({"rounds": rounds, "overrides": overrides, "results": summary, "acceptance": checks}, "  "))
	quit()


func _run_round(cfg: Dictionary, arena: Rect2, seed_value: int, profile: String) -> Dictionary:
	var sim := FuseSim.new(cfg, arena, seed_value)
	var candle := Vector2(arena.get_center().x, arena.position.y + arena.size.y * 0.62)
	sim.start(candle)
	sim.grab(0, candle)
	var bot := LunteBot.new(sim, profile, seed_value)
	var dt := 1.0 / 30.0
	var heat_time := [0.0, 0.0, 0.0, 0.0]
	# Lambdas capture locals by value, so mutable round state lives in a dictionary.
	var ctx := {"first_ignite": -1.0, "last_blast": -100.0, "last_junction": -100.0, "last_dry": -100.0}
	sim.firework_ignited.connect(func(_fw, _p, _h, _c):
		if ctx.first_ignite < 0.0:
			ctx.first_ignite = sim.time)
	sim.fuse_ignited_by_blast.connect(func(_p): ctx.last_blast = sim.time)
	sim.junction_created.connect(func(_p): ctx.last_junction = sim.time)
	sim.spool_empty.connect(func(): ctx.last_dry = sim.time)
	while not sim.over and sim.time < 400.0:
		sim.extend(0, bot.next_position(dt))
		sim.step(dt)
		if sim.time > cfg.spark_delay:
			heat_time[sim.heat_level()] += dt
	var death := "timeout"
	if sim.survived_dawn:
		death = "dawn"
	elif sim.over:
		if sim.time - ctx.last_blast < 3.0:
			death = "blast"
		elif sim.time - ctx.last_junction < 6.0:
			death = "junction"
		elif sim.time - ctx.last_dry < 8.0:
			death = "spool"
		else:
			death = "chase"
	return {
		"time": sim.time, "score": sim.score, "ignitions": sim.ignitions,
		"best_chain": sim.best_chain, "threaded": sim.stats.threaded, "fizzled": sim.stats.fizzled,
		"junctions": sim.stats.junctions, "blast_hits": sim.stats.blast_fuse_hits,
		"first_ignite": ctx.first_ignite, "death": death,
		"heat3_share": heat_time[3] / maxf(sim.time, 0.01),
		"final_speed": sim.base_speed(), "drawn_px": sim.stats.drawn_px,
	}


func _aggregate(rows: Array) -> Dictionary:
	var keys := ["time", "score", "ignitions", "best_chain", "threaded", "fizzled", "junctions", "blast_hits", "first_ignite", "heat3_share", "final_speed", "drawn_px"]
	var out := {}
	for k in keys:
		var vals: Array = rows.map(func(r): return float(r[k]))
		vals.sort()
		var sum := 0.0
		for v in vals:
			sum += v
		out[k] = {"mean": snappedf(sum / vals.size(), 0.01), "p10": vals[int(vals.size() * 0.1)], "median": vals[vals.size() / 2], "p90": vals[int(vals.size() * 0.9)]}
	var deaths := {}
	for r in rows:
		deaths[r.death] = deaths.get(r.death, 0) + 1
	out["deaths"] = deaths
	out["n"] = rows.size()
	return out


func _acceptance(s: Dictionary) -> Dictionary:
	var cautious: float = s["g2.2_s300"].time.median
	var greedy: float = s["g0.75_s300"].time.median
	var slow: float = s["g1.3_s230"].score.median
	var fast: float = s["g1.3_s400"].score.median
	var blast := 0
	var total := 0
	var min_t := INF
	var max_t := 0.0
	for p in s:
		blast += int(s[p].deaths.get("blast", 0))
		# ADR 0001 B3 is a share of *deaths*: rounds that reached dawn are not deaths.
		total += int(s[p].n) - int(s[p].deaths.get("dawn", 0)) - int(s[p].deaths.get("timeout", 0))
		min_t = minf(min_t, s[p].time.median)
		max_t = maxf(max_t, s[p].time.median)
	return {
		"B1_greed_costs": {"greedy_vs_cautious_time": snappedf(greedy / cautious, 0.001), "pass": greedy <= cautious * 0.85},
		"B2_motor_not_dominant": {"score_ratio_400_vs_230": snappedf(fast / maxf(slow, 1.0), 0.001), "pass": fast <= slow * 1.6},
		"B3_blast_deaths": {"share_of_deaths": snappedf(float(blast) / maxf(total, 1.0), 0.001), "pass": float(blast) / maxf(total, 1.0) < 0.15},
		"B4_round_length": {"median_min": min_t, "median_max": max_t, "pass": min_t >= 45.0 and max_t <= 150.0},
	}
