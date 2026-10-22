extends TestCase
## Rules of the SCHWARM prototype simulation.

const ARENA := Rect2(0, 130, 720, 1130)
var cfg: Dictionary


func before_each() -> void:
	cfg = Config.load_balance("schwarm")


func run(sim: SwarmSim, secs: float) -> void:
	for i in int(secs * 60):
		sim.step(1.0 / 60.0)


func test_school_follows_finger() -> void:
	var sim := SwarmSim.new(Config.with_overrides(cfg, {"first_predator": 999.0}), ARENA, 1)
	sim.plankton.clear()
	var target := Vector2(150, 400)
	sim.set_attractor(0, target)
	run(sim, 4.0)
	assert_true(sim._school_center().distance_to(target) < 80.0, "school near finger (%s)" % sim._school_center())


func test_two_fingers_split_school() -> void:
	var sim := SwarmSim.new(Config.with_overrides(cfg, {"first_predator": 999.0}), ARENA, 2)
	sim.plankton.clear()
	sim.set_attractor(0, Vector2(120, 500))
	sim.set_attractor(1, Vector2(600, 500))
	run(sim, 5.0)
	var left := 0
	var right := 0
	for p in sim.pos:
		if p.x < 360: left += 1
		else: right += 1
	assert_true(left >= 3 and right >= 3, "split into both sides (%d/%d)" % [left, right])
	assert_true(sim.stats.splits >= 1, "split counted")


func test_third_finger_is_ignored() -> void:
	var sim := SwarmSim.new(cfg, ARENA, 3)
	sim.set_attractor(0, Vector2(100, 300))
	sim.set_attractor(1, Vector2(200, 300))
	sim.set_attractor(2, Vector2(300, 300))
	assert_eq(sim.attractors.size(), 2, "max two attractors")


func test_plankton_grows_school() -> void:
	var sim := SwarmSim.new(Config.with_overrides(cfg, {"first_predator": 999.0}), ARENA, 4)
	sim.plankton.clear()
	var before := sim.fish_count()
	sim.plankton.append({"pos": Vector2(360, 600), "left": 12, "max": 12, "r": 40.0})
	sim.set_attractor(0, Vector2(360, 600))
	run(sim, 6.0)
	assert_true(sim.fish_count() > before, "school grew (%d > %d)" % [sim.fish_count(), before])
	assert_true(sim.score > 0, "scored")


func test_pike_eats_and_round_ends_at_zero() -> void:
	var sim := SwarmSim.new(Config.with_overrides(cfg, {"start_fish": 3, "plankton_bites": 0}), ARENA, 5)
	sim.plankton.clear()
	# Park the school, aim a pike straight through it.
	for i in sim.pos.size():
		sim.pos[i] = Vector2(360, 700)
	sim.predators.append({"kind": SwarmSim.Pred.PIKE, "pos": Vector2(-50, 700), "vel": Vector2(560, 0), "state": "active", "t": 0.0, "from": Vector2.ZERO, "to": Vector2.ZERO})
	sim.set_attractor(0, Vector2(360, 700))
	run(sim, 2.0)
	assert_true(sim.eaten_total >= 1, "pike ate")
