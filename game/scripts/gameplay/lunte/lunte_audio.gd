class_name LunteAudio
extends Node
## Maps LUNTE simulation events to sound and haptics.
## - The fuse crackle gets louder and higher as the spark closes in: the gap
##   is audible even when the hand covers the screen.
## - Ignitions play ascending pentatonic bells along a chain (chains = melody).
## - A heat music layer fades in with heat; the night pad is the bed.
## The game is fully playable muted; sound only reinforces what is shown.

const SFX_DIR := "res://assets/audio/sfx"
const NOTES := 10

var sim: FuseSim
var _audio: AudioDirector
var _fuse_loop: AudioStreamPlayer
var _draw_loop: AudioStreamPlayer
var _night: AudioStreamPlayer
var _heat: AudioStreamPlayer
var _draw_speed := 0.0
var _heat_mix := 0.0
var _last_heat := 1


func _ready() -> void:
	_audio = get_node_or_null("/root/Audio") as AudioDirector
	if _audio and not _audio.has_sfx("note_0"):
		_audio.register_folder(SFX_DIR)
	_fuse_loop = _loop_player("fuse_loop")
	_draw_loop = _loop_player("draw_loop")
	_night = _music_player("res://assets/audio/music/night_loop.ogg")
	_heat = _music_player("res://assets/audio/music/heat_loop.ogg")


func _loop_player(name: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = AudioDirector.BUS_SFX
	var s := load("%s/%s.wav" % [SFX_DIR, name]) as AudioStreamWAV
	if s:
		s = s.duplicate()
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		s.loop_begin = 0
		s.loop_end = int(s.get_length() * s.mix_rate) - 1
		p.stream = s
	p.volume_db = -80.0
	add_child(p)
	return p


func _music_player(path: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = AudioDirector.BUS_MUSIC
	var s := load(path) as AudioStreamOggVorbis
	if s:
		s = s.duplicate()
		s.loop = true
		p.stream = s
	p.volume_db = -80.0
	add_child(p)
	return p


func attach(new_sim: FuseSim) -> void:
	sim = new_sim
	sim.firework_threaded.connect(func(_fw):
		_play("thread_%d" % randi_range(0, 2), -4.0)
		Haptics.tick(0.2))
	sim.firework_ignited.connect(_on_ignited)
	sim.rocket_launched.connect(func(_fw, _a, _b): _play("rocket", -6.0, 1.0, 0.06))
	sim.blast.connect(func(_p, _r):
		_play("banger_%d" % randi_range(0, 1), -2.0)
		_duck(5.0)
		Haptics.bump(0.7))
	sim.fire_jumped.connect(func(_a, _b): _play("flare", -6.0, 1.0, 0.08, 120))
	sim.loop_closed.connect(func(_id, n):
		if n > 0:
			_play("loop_closed", -4.0))
	sim.short_circuit.connect(func(_p, _n):
		_play("short_circuit", -2.0)
		Haptics.bump(0.6))
	sim.spool_empty.connect(func(): _play("spool_low", -6.0))
	sim.head_caught.connect(func(_f, _p):
		_play("caught", 0.0, 1.0, 0.02)
		_duck(8.0)
		Haptics.heavy())
	sim.dawn.connect(func(): _play("dawn", -2.0, 1.0, 0.0))
	if not _night.playing:
		_night.play()
		_heat.play()


func _on_ignited(fw: FuseSim.Firework, _pts: int, heat: int, chain: int) -> void:
	# Chains climb the scale; heat lifts the starting note.
	var idx := clampi((chain - 1) + (heat - 1) * 2, 0, NOTES - 1)
	_play("note_%d" % idx, -5.0, 1.0, 0.0)
	if fw.kind != FuseSim.Kind.BANGER:
		_play("burst_%d" % randi_range(0, 2), -6.0)


func _play(name: String, db := 0.0, pitch := 1.0, pitch_var := 0.04, min_interval := 0) -> void:
	if _audio:
		_audio.play(name, db, pitch, pitch_var, 1.0, min_interval)


func _duck(db: float) -> void:
	if _audio:
		_audio.duck(db)


## Per-frame continuous audio. drawing_speed: px/s of the finger(s) drawing.
func update(delta: float, drawing_speed: float, running: bool) -> void:
	if sim == null:
		return
	var has_spark := running and sim.sparks.size() > 0 and not sim.over
	# Fuse crackle: gap 3 s -> quiet/low, gap 0 -> loud/high.
	var gap := clampf(sim.gap_time(), 0.0, 3.0) if sim.gap_time() != INF else 3.0
	var closeness := 1.0 - gap / 3.0
	var target_db := lerpf(-26.0, -6.0, closeness) if has_spark else -80.0
	_fade(_fuse_loop, target_db, delta, 10.0)
	_fuse_loop.pitch_scale = lerpf(0.85, 1.35, closeness)
	# Paper scratch follows drawing speed.
	_draw_speed = lerpf(_draw_speed, drawing_speed, clampf(delta * 10.0, 0.0, 1.0))
	var draw_db := lerpf(-40.0, -12.0, clampf(_draw_speed / 600.0, 0.0, 1.0)) if running and _draw_speed > 20.0 else -80.0
	_fade(_draw_loop, draw_db, delta, 12.0)
	# Music: night bed always, heat layer by heat level.
	var heat := sim.heat_level() if has_spark else 1
	if heat == 3 and _last_heat < 3:
		Haptics.tick(0.35)
	_last_heat = heat
	_heat_mix = lerpf(_heat_mix, float(heat - 1) / 2.0, clampf(delta * 2.0, 0.0, 1.0))
	_fade(_night, -6.0, delta, 2.0)
	_fade(_heat, lerpf(-40.0, -4.0, _heat_mix) if running else -80.0, delta, 3.0)


func _fade(p: AudioStreamPlayer, target_db: float, delta: float, rate: float) -> void:
	if p.stream == null:
		return
	if target_db <= -79.0 and p.volume_db <= -79.0:
		if p.playing and p != _night and p != _heat:
			p.stop()
		return
	if not p.playing:
		p.play()
	p.volume_db = lerpf(p.volume_db, target_db, clampf(delta * rate, 0.0, 1.0))


func stop_all() -> void:
	for p in [_fuse_loop, _draw_loop, _heat]:
		p.volume_db = -80.0
