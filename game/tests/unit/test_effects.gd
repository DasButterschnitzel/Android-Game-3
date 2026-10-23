extends TestCase
## "Effekte: minimal" really is calm: no shake-like kicks, no flashes, no
## shockwaves, no flicker; strike rings stay as dim feedback (QA review 0.7).


func _view(effects: float) -> EchoView:
	var v := EchoView.new()
	v.effects = effects
	return v


func test_minimal_turns_flashes_shockwaves_and_kicks_off() -> void:
	var v := _view(0.0)
	v.flash_enemy(7)
	assert_true(v._enemy_flash.is_empty(), "no white flash on a hit ghost")
	v.lantern_hit()
	assert_eq(v._lantern_hit, 0.0, "no red lantern flash")
	assert_eq(v._sway_v, 0.0, "no sway kick")
	v.shockwave(Vector2(100, 100), Color.WHITE, 200.0)
	assert_true(v.waves_fx.is_empty(), "no shockwave")
	v.strike_flash(Vector2(100, 100), Color.WHITE, false)
	assert_eq(v.flashes.size(), 1, "the strike ring stays: it is feedback")
	v.free()


func test_full_and_reduced_keep_the_effects_scaled() -> void:
	var full := _view(1.0)
	var half := _view(0.5)
	for v in [full, half]:
		v.flash_enemy(7)
		v.lantern_hit()
		v.shockwave(Vector2(100, 100), Color.WHITE, 200.0)
		assert_eq(v.waves_fx.size(), 1, "shockwave at %.1f" % v.effects)
	assert_true(half._enemy_flash[7] < full._enemy_flash[7], "reduced: weaker hit flash")
	assert_true(half._lantern_hit < full._lantern_hit, "reduced: weaker lantern flash")
	full.free()
	half.free()


func test_flame_warning_never_flickers_fast() -> void:
	var calm := _view(0.0)
	assert_eq(calm.risk_mix(0.0), calm.risk_mix(0.37), "minimal: a steady colour, no flicker")
	for e in [1.0, 0.5]:
		var v := _view(e)
		var peaks := 0
		var prev := v.risk_mix(0.0)
		var rising := true
		for i in range(1, 600):
			var x := v.risk_mix(i / 600.0)  # one second
			if rising and x < prev:
				peaks += 1
			rising = x >= prev
			prev = x
		assert_true(peaks <= 2, "at most 2 pulses per second at %.1f (got %d)" % [e, peaks])
		v.free()
	calm.free()
