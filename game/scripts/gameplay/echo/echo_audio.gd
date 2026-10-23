class_name EchoAudio
extends Node
## Maps NACHHALL events to sound. Every light owns one note of a pentatonic
## scale, so a wave defended by several echoes plays as a canon: you hear when
## each echo strikes, which makes timing audible even under the thumb.
## The game is fully playable muted; sound only reinforces what is shown.

const SFX_DIR := "res://assets/audio/sfx"
## Note index (note_0..note_9, rising pentatonic) for light ids 0..5 and live.
const LIGHT_NOTES := [2, 4, 6, 3, 5, 7]

var sim: EchoSim
var _audio: AudioDirector
var _night: AudioStreamPlayer
var _paused := false


func _ready() -> void:
	_audio = get_node_or_null("/root/Audio") as AudioDirector
	if _audio and not _audio.has_sfx("note_0"):
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
	sim.light_struck.connect(_on_struck)
	sim.enemy_destroyed.connect(func(e, _id):
		_play("burst_%d" % (int(e.spec.id) % 3), -9.0, 1.15, 0.06, 40))
	sim.enemy_hit.connect(func(e, _id):
		_play("thread_%d" % (int(e.spec.id) % 3), -4.0, 1.0, 0.04))
	sim.enemy_leaked.connect(func(_e):
		_play("caught", -3.0, 1.0, 0.03, 120)
		_duck(6.0))
	sim.run_started.connect(func(_i): _play("ui_tap", -6.0, 1.2, 0.0))
	if _night.stream and not _night.playing and not _paused:
		_night.play()


func _on_struck(light_id: int, _pos: Vector2, hits: int, is_echo: bool) -> void:
	var note: int = LIGHT_NOTES[light_id % LIGHT_NOTES.size()]
	if not is_echo:
		note = mini(note + 2, 9)  # the live light sings on top of its echoes
	var db := -4.0 if hits > 0 else -16.0  # an echo striking empty air is only a whisper
	_play("note_%d" % note, db, 1.0, 0.0)


func play_ui(what: String) -> void:
	match what:
		"bank":
			_play("loop_closed", -5.0, 1.0, 0.0)
		"perfect":
			_play("short_circuit", -8.0, 1.1, 0.0)
		"second":
			_play("flare", -6.0, 1.2, 0.02)


func round_over(survived: bool) -> void:
	if survived:
		_play("dawn", -2.0, 1.0, 0.0)
	else:
		_play("caught", 0.0, 0.8, 0.0)
		_duck(10.0)


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
