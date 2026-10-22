class_name SparkParticles
extends Node2D
## Lightweight additive particle system drawn in one _draw call.
## Each particle is a textured quad of one shared soft glow texture, which is
## cheaper than polygon circles and gives a natural bloom on GLES3 devices.

const MAX := 900

var _pos := PackedVector2Array()
var _vel := PackedVector2Array()
var _life := PackedFloat32Array()
var _max_life := PackedFloat32Array()
var _size := PackedFloat32Array()
var _col := PackedColorArray()
var _drag := PackedFloat32Array()
var gravity := Vector2(0, 160)
var intensity := 1.0  # global multiplier from the "effects" setting
var _tex: Texture2D


func _ready() -> void:
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = mat
	_tex = ArtKit.glow_texture()


func emit_burst(at: Vector2, count: int, color: Color, speed_min: float, speed_max: float, life: float, size: float, drag := 1.6, spread := TAU, dir := Vector2.UP) -> void:
	count = int(count * intensity)
	for i in count:
		if _pos.size() >= MAX:
			_remove(0)
		var a := randf() * TAU if spread >= TAU else dir.angle() + randf_range(-spread * 0.5, spread * 0.5)
		var sp := randf_range(speed_min, speed_max)
		_pos.append(at)
		_vel.append(Vector2.from_angle(a) * sp)
		var l := life * randf_range(0.6, 1.2)
		_life.append(l)
		_max_life.append(l)
		_size.append(size * randf_range(0.6, 1.3))
		_col.append(color.lerp(Color.WHITE, randf() * 0.35))
		_drag.append(drag)


func emit_trail(at: Vector2, dir: Vector2, color: Color, count := 2) -> void:
	for i in count:
		if _pos.size() >= MAX:
			_remove(0)
		_pos.append(at)
		_vel.append(dir.rotated(randf_range(-0.9, 0.9)) * randf_range(30, 120))
		var l := randf_range(0.2, 0.45)
		_life.append(l)
		_max_life.append(l)
		_size.append(randf_range(1.5, 3.2))
		_col.append(color)
		_drag.append(3.0)


func _remove(i: int) -> void:
	_pos.remove_at(i)
	_vel.remove_at(i)
	_life.remove_at(i)
	_max_life.remove_at(i)
	_size.remove_at(i)
	_col.remove_at(i)
	_drag.remove_at(i)


func clear() -> void:
	for arr in [_pos, _vel, _life, _max_life, _size, _col, _drag]:
		arr.clear()


func _process(delta: float) -> void:
	var i := _pos.size() - 1
	while i >= 0:
		_life[i] -= delta
		if _life[i] <= 0.0:
			_remove(i)
		else:
			_vel[i] = _vel[i] * maxf(0.0, 1.0 - _drag[i] * delta) + gravity * delta
			_pos[i] += _vel[i] * delta
		i -= 1
	queue_redraw()


func _draw() -> void:
	for i in _pos.size():
		var t := _life[i] / _max_life[i]
		var c := _col[i]
		c.a = t
		var s := _size[i] * (0.5 + 0.5 * t) * 2.6
		draw_texture_rect(_tex, Rect2(_pos[i] - Vector2(s, s) * 0.5, Vector2(s, s)), false, c)


func count() -> int:
	return _pos.size()
