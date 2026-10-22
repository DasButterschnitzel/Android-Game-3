extends SceneTree
## Headless balancing simulation for LUNTE.
## Usage: godot --headless --path game --script res://tests/simulation/sim_lunte.gd -- [rounds] [overrides_json]
## Prints a JSON summary per bot profile. Simulated bots are NOT human playtests.

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var rounds := int(args[0]) if args.size() > 0 else 40
	var overrides: Dictionary = JSON.parse_string(args[1]) if args.size() > 1 else {}
	var cfg := Config.with_overrides(Config.load_balance("lunte"), overrides)
	var arena := Rect2(10, 130, 700, 1130)
	var summary := {}
	for profile in ["cautious", "normal", "greedy"]:
		var rows := []
		for r in rounds:
			rows.append(_run_round(cfg, arena, 1000 + r, profile))
		summary[profile] = _aggregate(rows)
	print(JSON.stringify({"rounds": rounds, "overrides": overrides, "results": summary}, "  "))
	quit()


func _run_round(cfg: Dictionary, arena: Rect2, seed_value: int, profile: String) -> Dictionary:
	var sim := FuseSim.new(cfg, arena, seed_value)
	var candle := Vector2(arena.get_center().x, arena.end.y - 70)
	sim.start(candle)
	sim.grab(0, candle)
	var bot := LunteBot.new(sim, profile, seed_value)
	var dt := 1.0 / 30.0
	var heat_time := [0.0, 0.0, 0.0, 0.0]
	# Lambdas capture locals by value, so mutable round state lives in a dictionary.
	var ctx := {"first_ignite": -1.0, "last_blast": -100.0, "last_junction": -100.0}
	sim.firework_ignited.connect(func(_fw, _p, _h, _c):
		if ctx.first_ignite < 0.0:
			ctx.first_ignite = sim.time)
	sim.fuse_ignited_by_blast.connect(func(_p): ctx.last_blast = sim.time)
	sim.junction_created.connect(func(_p): ctx.last_junction = sim.time)
	var frames := 0
	while not sim.over and sim.time < 300.0:
		sim.extend(0, bot.next_position(dt))
		sim.step(dt)
		if sim.time > cfg.spark_delay:
			heat_time[sim.heat_level()] += dt
		frames += 1
	var death := "timeout"
	if sim.over:
		# Attribute the catch to a blast or a self-crossing if one happened shortly before.
		if sim.time - ctx.last_blast < 3.0:
			death = "blast"
		elif sim.time - ctx.last_junction < 6.0:
			death = "junction"
		else:
			death = "chase"
	return {
		"time": sim.time, "score": sim.score, "ignitions": sim.ignitions,
		"best_chain": sim.best_chain, "threaded": sim.stats.threaded, "fizzled": sim.stats.fizzled,
		"junctions": sim.stats.junctions, "blast_hits": sim.stats.blast_fuse_hits,
		"first_ignite": ctx.first_ignite, "death": death,
		"heat3_share": heat_time[3] / maxf(sim.time, 0.01),
		"final_speed": sim.speed(),
	}


func _aggregate(rows: Array) -> Dictionary:
	var keys := ["time", "score", "ignitions", "best_chain", "threaded", "fizzled", "junctions", "blast_hits", "first_ignite", "heat3_share", "final_speed"]
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
	return out
