extends SceneTree
## Headless simulation of NACHHALL with bot strategies and automatic checks.
## Bots are not humans (perfect information, no hesitation, exact speed).
## Usage: godot --headless --path game --script res://tests/simulation/sim_echo.gd -- [rounds] [seed_base] [speed] [json overrides]
## Criteria (docs/playtests/ECHO_SIM.md):
##   E1 solo (no echoes) <= 40 % of the best planner (median score)
##   E2 at least two strategies >= 80 % of the best (weak, see report)
##   C1 reactive chaser <= 50 % of the best planner (planning beats reaction)
##   T1 the teaching wave leaks for a single light in every seed
##   T2 planners destroy >= 80 % of twin pairs in banked runs
##   L1 planner median round length 60..180 s (2 s decision time per break)

const STRATEGIES := ["solo", "perfect", "early", "sector", "chaser"]
const DECISION_SECONDS := 2.0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var rounds := int(args[0]) if args.size() > 0 else 30
	var seed_base := int(args[1]) if args.size() > 1 else 3000
	var speed := float(args[2]) if args.size() > 2 else 600.0
	var cfg := Config.load_balance("echo")
	if args.size() > 3:
		cfg = Config.with_overrides(cfg, JSON.parse_string(args[3]))
	var arena := Rect2(10, 150, 700, 1110)
	var summary := {}
	var extra := {}
	for strat in STRATEGIES:
		var rows := []
		for r in rounds:
			rows.append(_run_round(cfg, arena, seed_base + r, strat, speed))
		summary[strat] = _aggregate(rows)
		extra[strat] = {
			"teach_leaked_share": snappedf(rows.filter(func(x): return x.teach_leaked_first_run).size() / float(rows.size()), 0.001),
			"twin_kill_share": snappedf(_sum(rows, "twins_killed") / maxf(_sum(rows, "twins_banked"), 1.0), 0.001),
			"dawn_share": snappedf(rows.filter(func(x): return x.dawn).size() / float(rows.size()), 0.001),
		}
	print(JSON.stringify({"rounds": rounds, "seed_base": seed_base, "speed": speed, "results": summary,
		"extra": extra, "acceptance": _acceptance(summary, extra)}, "  "))
	quit()


func _run_round(cfg: Dictionary, arena: Rect2, seed_value: int, strat: String, speed: float) -> Dictionary:
	var sim := EchoSim.new(cfg, arena, seed_value)
	var bot := EchoBot.new(sim, strat, speed)
	var ticks := 0
	var breaks := 0
	var guard := 0
	var teach_leaked := false
	var ctx := {"twins_banked": 0, "twins_killed": 0, "sim": sim}
	# Count twins of every banked run (also the automatic bank at max lights).
	var on_bank := func(_w, _p, _l):
		for e in ctx.sim.enemies:
			if e.spec.type == EchoSim.Type.TWIN:
				ctx.twins_banked += 1
				if not e.leaked:
					ctx.twins_killed += 1
	sim.wave_banked.connect(on_bank)
	while sim.state != "over" and guard < 200:
		guard += 1
		var wave_before := sim.wave_index
		bot.prepare_run()
		sim.begin_run()
		while sim.state == "running":
			sim.step([bot.delta()])
			ticks += 1
		if wave_before == 0 and sim.run_index == 0 and sim.last_run.leaked > 0:
			teach_leaked = true
		if sim.state == "between":
			breaks += 1
			if bot.should_bank():
				sim.bank()
	sim.wave_banked.disconnect(on_bank)  # break the sim <-> lambda cycle
	ctx.erase("sim")
	return {
		"score": sim.score, "waves": sim.stats.waves_banked, "perfect": sim.stats.perfect_waves,
		"runs": sim.stats.runs, "leaks": sim.stats.leaks, "lights": sim.stats.lights,
		"round_seconds": ticks * EchoSim.DT + breaks * DECISION_SECONDS,
		"runs_per_wave": float(sim.stats.runs) / maxf(sim.stats.waves_banked, 1.0),
		"teach_leaked_first_run": teach_leaked, "twins_banked": ctx.twins_banked, "twins_killed": ctx.twins_killed,
		"dawn": sim.stats.dawn,
	}


func _sum(rows: Array, key: String) -> float:
	var s := 0.0
	for r in rows:
		s += float(r[key])
	return s


func _aggregate(rows: Array) -> Dictionary:
	var out := {}
	for k in ["score", "waves", "perfect", "runs", "leaks", "lights", "round_seconds", "runs_per_wave"]:
		var vals: Array = rows.map(func(r): return float(r[k]))
		vals.sort()
		var sum := 0.0
		for v in vals:
			sum += v
		out[k] = {"mean": snappedf(sum / vals.size(), 0.01), "p10": snappedf(vals[int(vals.size() * 0.1)], 0.01),
			"median": snappedf(vals[vals.size() / 2], 0.01), "p90": snappedf(vals[int(vals.size() * 0.9)], 0.01)}
	return out


func _acceptance(s: Dictionary, x: Dictionary) -> Dictionary:
	var best := 0.0
	for k in s:
		best = maxf(best, s[k].score.median)
	var near_best := []
	for k in s:
		if s[k].score.median >= best * 0.8:
			near_best.append(k)
	var planner := maxf(s["perfect"].score.median, s["early"].score.median)
	var length := minf(s["perfect"].round_seconds.median, s["early"].round_seconds.median)
	var length_hi := maxf(s["perfect"].round_seconds.median, s["early"].round_seconds.median)
	var twin := minf(x["perfect"].twin_kill_share, x["early"].twin_kill_share)
	return {
		"E1_echoes_needed": {"solo_vs_planner": snappedf(s["solo"].score.median / maxf(planner, 1.0), 0.001), "pass": s["solo"].score.median <= planner * 0.4},
		"E2_no_single_recipe": {"strategies_within_80pct": near_best, "pass": near_best.size() >= 2},
		"C1_planning_beats_reaction": {"chaser_vs_planner": snappedf(s["chaser"].score.median / maxf(planner, 1.0), 0.001), "pass": s["chaser"].score.median <= planner * 0.5},
		"T1_teaching_wave_leaks_alone": {"solo_share": x["solo"].teach_leaked_share, "pass": x["solo"].teach_leaked_share >= 1.0},
		"T2_twins_learnable": {"planner_twin_kill_share": twin, "pass": twin >= 0.8},
		"L1_round_length": {"planner_median_s": [length, length_hi], "pass": length >= 60.0 and length_hi <= 180.0},
	}
