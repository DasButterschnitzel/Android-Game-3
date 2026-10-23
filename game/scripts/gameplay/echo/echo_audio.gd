class_name EchoAudio
extends Node
## Maps NACHHALL events to sound. Every light owns one note of D major
## pentatonic (light k keeps its note as an echo), so a defended wave plays as
## a canon and you hear WHEN each echo strikes, even under the thumb:
##   live light  -> clear glass bell (nh_live_k)
##   its echo    -> the same note as a soft, reverberant memory (nh_echo_k)
## A quiet wooden tick each second is the audible run timeline. The game is
## fully playable muted; sound only reinforces what is shown.

const SFX_DIR := "res://assets/audio/sfx"
const VOICES := 6

var sim: EchoSim
var _audio: AudioDirector
var _night: AudioStreamPlayer
var _paused := false
var _charged: Array[bool] = []


func _ready() -> void:
	_audio = get_node_or_null("/root/Audio") as AudioDirector
	if _audio and not _audio.has_sfx("nh_live_0"):
		_audio.register_folder(SFX_DIR)
	_night = AudioStreamPlayer.new()
	_night.bus = AudioDirector.BUS_MUSIC
	var s := load("res://assets/audio/music/night_loop.ogg") as AudioStreamOggVorbis
	if s:
		s = s.duplicate()
		s.loop = true
		_night.stream = s
	_night.volume_db = -8.0
	add_child(_night)


func attach(new_sim: EchoSim) -> void:
	sim = new_sim
	_charged.clear()
	sim.light_struck.connect(_on_struck)
	sim.enemy_destroyed.connect(func(e, _id):
		if e.spec.type == EchoSim.Type.TWIN:
			_play("nh_twin_link", -3.0, 1.0, 0.0, 150)  # once per pair
		else:
			_play("nh_puff_%d" % (int(e.spec.id) % 3), -4.0, 1.0, 0.08, 30))
	sim.enemy_hit.connect(func(e, _id):
		if e.spec.type == EchoSim.Type.ARMOR:
			_play("nh_crack_%d" % (int(e.spec.id) % 2), -3.0, 1.0, 0.05)
		else:
			_play("nh_twin_ping", -4.0, 1.0, 0.0))
	sim.enemy_leaked.connect(func(_e):
		_play("nh_leak", -2.0, 1.0, 0.04, 90)
		_duck(5.0))
	sim.run_started.connect(func(_i):
		_charged.clear()
		_play("nh_run_start", -4.0, 1.0, 0.03))
	sim.wave_started.connect(func(_w): _play("nh_wave_bell", -6.0, 1.0, 0.0))
	sim.wave_banked.connect(_on_banked)
	if _night.stream and not _night.playing and not _paused:
		_night.play()
	_play("nh_wave_bell", -6.0, 1.0, 0.0)


## Called by the game after every sim step: timing track and "ready" tink.
func on_step(s: EchoSim) -> void:
	if s.state != "running":
		return
	var t := s.tick - 1  # the tick that was just simulated
	if t > 0 and t % 60 == 0:
		_play("nh_tick_1" if t < s.run_ticks() - 60 else "nh_tick_0", -2.0, 1.0, 0.0)
	for k in s.live.size():
		var ready := s.is_charged(s.live[k])
		if k >= _charged.size():
			_charged.append(ready)
		elif ready and not _charged[k] and int(s.live[k].last) >= 0:
			_play("nh_ready", 0.0, 1.0, 0.0)
		_charged[k] = ready


func _on_struck(light_id: int, _pos: Vector2, hits: int, is_echo: bool) -> void:
	var k := light_id % VOICES
	if is_echo:
		# An echo flashing at empty air is only a whisper of its note.
		_play("nh_echo_%d" % k, -2.0 if hits > 0 else -14.0, 1.0, 0.0)
	else:
		_play("nh_live_%d" % k, 0.0, 1.0, 0.0)


func _on_banked(_w: int, _pts: int, leaked: int) -> void:
	if leaked > 0:
		_play("nh_flame_out", -2.0, 1.0, 0.0)
		return
	# The notes of every light used in this wave ring out once, low to high.
	var n := clampi(sim.echoes.size() if sim else 1, 1, VOICES)  # echoes are still those of the banked wave
	for k in n:
		var tw := create_tween()
		tw.tween_interval(0.07 * k)
		tw.tween_callback(_play.bind("nh_echo_%d" % k, -8.0, 1.0, 0.0))


func play_ui(what: String) -> void:
	match what:
		"perfect":
			_play("nh_perfect", -3.0, 1.0, 0.0)
		"second":
			_play("nh_second_light", -3.0, 1.0, 0.0)


func round_over(survived: bool) -> void:
	_play("nh_dawn" if survived else "nh_lantern_out", 0.0, 1.0, 0.0)
	_duck(8.0)


func set_paused(on: bool) -> void:
	_paused = on
	if _night.stream:
		_night.stream_paused = on


func _play(name: String, db := 0.0, pitch := 1.0, pitch_var := 0.04, min_interval := 0) -> void:
	if _audio and not _paused:
		_audio.play(name, db, pitch, pitch_var, 1.0, min_interval)


func _duck(db: float) -> void:
	if _audio:
		_audio.duck(db)
