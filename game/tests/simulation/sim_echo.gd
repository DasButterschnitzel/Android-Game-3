extends SceneTree
## Headless simulation of the ECHO prototype with four bot strategies and an
## automatic check of acceptance criteria E1/E2 (docs/decisions/0001).
## Usage: godot --headless --path game --script res://tests/simulation/sim_echo.gd -- [rounds]

const STRATEGIES := ["solo", "perfect", "early", "sector"]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var rounds := int(args[0]) if args.size() > 0 else 30
	var cfg := Config.load_balance("echo")
	var arena := Rect2(10, 130, 700, 1130)
	var summary := {}
	for strat in STRATEGIES:
		var rows := []
		for r in rounds:
			rows.append(_run_round(cfg, arena, 3000 + r, strat))
		summary[strat] = _aggregate(rows)
	print(JSON.stringify({"rounds": rounds, "results": summary, "acceptance": _acceptance(summary)}, "  "))
	quit()


func _run_round(cfg: Dictionary, arena: Rect2, seed_value: int, strat: String) -> Dictionary:
	var sim := EchoSim.new(cfg, arena, seed_value)
	var bot := EchoBot.new(sim, strat)
	var ticks := 0
	var guard := 0
	while sim.state != "over" and guard < 100:
		guard += 1
		bot.prepare_run()
		sim.begin_run()
		while sim.state == "running":
			sim.step([bot.delta()])
			ticks += 1
		if sim.state == "between":
			if bot.should_bank():
				sim.bank()
			else:
				sim.next_run()
	return {
		"score": sim.score, "waves": sim.stats.waves_banked, "perfect": sim.stats.perfect_waves,
		"runs": sim.stats.runs, "leaks": sim.stats.leaks, "play_seconds": ticks * EchoSim.DT,
		"runs_per_wave": float(sim.stats.runs) / maxf(sim.stats.waves_banked, 1.0),
	}


func _aggregate(rows: Array) -> Dictionary:
	var out := {}
	for k in ["score", "waves", "perfect", "runs", "leaks", "play_seconds", "runs_per_wave"]:
		var vals: Array = rows.map(func(r): return float(r[k]))
		vals.sort()
		var sum := 0.0
		for v in vals:
			sum += v
		out[k] = {"mean": snappedf(sum / vals.size(), 0.01), "p10": vals[int(vals.size() * 0.1)], "median": vals[vals.size() / 2], "p90": vals[int(vals.size() * 0.9)]}
	return out


func _acceptance(s: Dictionary) -> Dictionary:
	var best := 0.0
	for k in s:
		best = maxf(best, s[k].score.median)
	var near_best := []
	for k in s:
		if s[k].score.median >= best * 0.8:
			near_best.append(k)
	var planner := maxf(s["perfect"].score.median, s["early"].score.median)
	return {
		"E1_echoes_needed": {"solo_vs_planner": snappedf(s["solo"].score.median / maxf(planner, 1.0), 0.001), "pass": s["solo"].score.median <= planner * 0.4},
		"E2_no_single_recipe": {"strategies_within_80pct": near_best, "pass": near_best.size() >= 2},
	}
