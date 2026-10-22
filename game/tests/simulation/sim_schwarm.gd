extends SceneTree
## Headless simulation of the SCHWARM prototype with bot profiles.
## Usage: godot --headless --path game --script res://tests/simulation/sim_schwarm.gd -- [rounds]

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var rounds := int(args[0]) if args.size() > 0 else 30
	var cfg := Config.load_balance("schwarm")
	var arena := Rect2(10, 130, 700, 1130)
	var summary := {}
	for profile in ["one", "two"]:
		var rows := []
		for r in rounds:
			rows.append(_run_round(cfg, arena, 2000 + r, profile))
		summary[profile] = _aggregate(rows)
	print(JSON.stringify({"rounds": rounds, "results": summary}, "  "))
	quit()


func _run_round(cfg: Dictionary, arena: Rect2, seed_value: int, profile: String) -> Dictionary:
	var sim := SwarmSim.new(cfg, arena, seed_value)
	var bot := SwarmBot.new(sim, profile)
	var dt := 1.0 / 30.0
	var ctx := {"first_bite": -1.0, "first_loss": -1.0}
	sim.plankton_bitten.connect(func(_p):
		if ctx.first_bite < 0.0:
			ctx.first_bite = sim.time)
	sim.fish_eaten.connect(func(_p):
		if ctx.first_loss < 0.0:
			ctx.first_loss = sim.time)
	var held := {}
	while not sim.over and sim.time < 300.0:
		var fingers := bot.next_fingers(dt)
		for id in held.keys():
			if not fingers.has(id):
				sim.clear_attractor(id)
				held.erase(id)
		for id in fingers:
			sim.set_attractor(id, fingers[id])
			held[id] = true
		sim.step(dt)
	return {
		"time": sim.time, "score": sim.score, "max_fish": sim.stats.max_fish,
		"eaten": sim.eaten_total, "collected": sim.collected, "splits": sim.stats.splits,
		"split_share": sim.stats.split_time / maxf(sim.time, 0.01),
		"first_bite": ctx.first_bite, "first_loss": ctx.first_loss,
		"timeout": not sim.over,
	}


func _aggregate(rows: Array) -> Dictionary:
	var out := {}
	for k in ["time", "score", "max_fish", "eaten", "collected", "splits", "split_share", "first_bite", "first_loss"]:
		var vals: Array = rows.map(func(r): return float(r[k]))
		vals.sort()
		var sum := 0.0
		for v in vals:
			sum += v
		out[k] = {"mean": snappedf(sum / vals.size(), 0.01), "p10": vals[int(vals.size() * 0.1)], "median": vals[vals.size() / 2], "p90": vals[int(vals.size() * 0.9)]}
	out["timeouts"] = rows.filter(func(r): return r.timeout).size()
	return out
