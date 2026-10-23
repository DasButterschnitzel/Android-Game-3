class_name AudioDirector
extends Node
## Central audio (autoload "Audio").
##
## - Creates the bus layout Master > Music, SFX at runtime (no binary bus file).
## - Applies volumes/mute from the save store.
## - Plays SFX from a small voice pool with per-play pitch/volume variation so
##   repeated events never sound identical (avoids repetition fatigue).
## - Ducks music briefly for big events and pauses everything when the app is
##   backgrounded (Android audio focus is handled by the engine; we stop output).

const POOL_SIZE := 16
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

var _pool: Array[AudioStreamPlayer] = []
var _next := 0
var _streams: Dictionary = {}  # name -> AudioStream
var _last_played: Dictionary = {}  # name -> msec, for rate limiting
var _music: AudioStreamPlayer
var _duck := 0.0
var _app_paused := false  # in the background (Android onPause)
var _app_focused := true  # the window has focus (not behind the lock screen or a dialog)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_buses()
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = BUS_SFX
		add_child(p)
		_pool.append(p)
	_music = AudioStreamPlayer.new()
	_music.bus = BUS_MUSIC
	add_child(_music)
	apply_settings()


func _ensure_buses() -> void:
	for bus in [BUS_MUSIC, BUS_SFX]:
		if AudioServer.get_bus_index(bus) == -1:
			AudioServer.add_bus()
			var idx := AudioServer.bus_count - 1
			AudioServer.set_bus_name(idx, bus)
			AudioServer.set_bus_send(idx, "Master")
	# Gentle limiter on master keeps stacked explosions from clipping.
	var master := AudioServer.get_bus_index("Master")
	if AudioServer.get_bus_effect_count(master) == 0:
		var lim := AudioEffectHardLimiter.new()
		lim.ceiling_db = -1.0
		AudioServer.add_bus_effect(master, lim)


## Re-reads volumes from the save store (call after changing settings).
func apply_settings() -> void:
	var save := _save()
	if save == null:
		return
	var muted: bool = save.get_setting("muted")
	_set_bus_linear("Master", 0.0 if muted else float(save.get_setting("master_volume")))
	_set_bus_linear(BUS_MUSIC, float(save.get_setting("music_volume")))
	_set_bus_linear(BUS_SFX, float(save.get_setting("sfx_volume")))


func _set_bus_linear(bus: String, v: float) -> void:
	var idx := AudioServer.get_bus_index(bus)
	if idx < 0:
		return
	AudioServer.set_bus_mute(idx, v <= 0.001)
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(v, 0.0001)))


func _save() -> SaveStore:
	return get_node_or_null("/root/Save") as SaveStore


func register(sfx_name: String, stream: AudioStream) -> void:
	_streams[sfx_name] = stream


## Loads every .wav/.ogg in a folder; file name (without extension) becomes the key.
func register_folder(dir_path: String) -> int:
	var n := 0
	var d := DirAccess.open(dir_path)
	if d == null:
		return 0
	for f in d.get_files():
		var file := f.trim_suffix(".import")  # exported builds list imported names
		if file.get_extension() in ["wav", "ogg"] and not _streams.has(file.get_basename()):
			var s = load(dir_path.path_join(file))
			if s:
				_streams[file.get_basename()] = s
				n += 1
	return n


func has_sfx(sfx_name: String) -> bool:
	return _streams.has(sfx_name)


## Plays a registered sound. pitch_var/vol_var randomize each instance.
## min_interval_ms rate-limits very frequent events (e.g. crackles).
func play(sfx_name: String, volume_db := 0.0, pitch := 1.0, pitch_var := 0.04, vol_var := 1.5, min_interval_ms := 0) -> void:
	var s: AudioStream = _streams.get(sfx_name)
	if s == null:
		return
	if min_interval_ms > 0:
		var now := Time.get_ticks_msec()
		if now - int(_last_played.get(sfx_name, -100000)) < min_interval_ms:
			return
		_last_played[sfx_name] = now
	var p := _pool[_next]
	_next = (_next + 1) % POOL_SIZE
	p.stream = s
	p.pitch_scale = maxf(0.05, pitch * (1.0 + randf_range(-pitch_var, pitch_var)))
	p.volume_db = volume_db + randf_range(-vol_var, vol_var)
	p.play()


func play_music(stream: AudioStream, volume_db := -6.0) -> void:
	if _music.stream == stream and _music.playing:
		return
	_music.stream = stream
	_music.volume_db = volume_db
	_music.play()


func stop_music() -> void:
	_music.stop()


## Briefly lowers the music bus (e.g. on a big explosion or game over).
func duck(amount_db := 6.0) -> void:
	_duck = maxf(_duck, amount_db)


func _process(delta: float) -> void:
	if _duck > 0.0:
		_duck = maxf(_duck - delta * 12.0, 0.0)
	var idx := AudioServer.get_bus_index(BUS_MUSIC)
	if idx >= 0:
		var save := _save()
		var base := float(save.get_setting("music_volume")) if save else 0.6
		AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(base, 0.0001)) - _duck)


## Silent while the app is in the background or has no focus (also when Android
## resumes it behind the lock screen); otherwise the player's own mute decides.
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED:
			_app_paused = true
		NOTIFICATION_APPLICATION_RESUMED:
			_app_paused = false
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			_app_focused = false
		NOTIFICATION_APPLICATION_FOCUS_IN:
			_app_focused = true
		_:
			return
	var save := _save()
	AudioServer.set_bus_mute(0, _app_paused or not _app_focused or (save != null and bool(save.get_setting("muted"))))
