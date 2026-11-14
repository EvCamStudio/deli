extends Node

var _failures: int = 0

func _check(ok: bool, msg: String) -> void:
	if ok:
		print("PASS: " + msg)
	else:
		_failures += 1
		printerr("FAIL: " + msg)

func _ready() -> void:
	await get_tree().process_frame
	print("--- TESTING AUDIO INTEGRATION ---")
	_check(AudioManager != null, "AudioManager harus ada")
	
	# Test BGM loading
	for key in AudioManager.BGM_PATHS.keys():
		var path: String = AudioManager.BGM_PATHS[key]
		var exists: bool = ResourceLoader.exists(path)
		_check(exists, "BGM path ditemukan: %s -> %s" % [str(key), path])
		if exists:
			var stream = load(path)
			_check(stream is AudioStreamWAV, "Stream BGM adalah AudioStreamWAV: " + str(key))

	# Test SFX loading
	for key in AudioManager.SFX_PATHS.keys():
		var path: String = AudioManager.SFX_PATHS[key]
		var exists: bool = ResourceLoader.exists(path)
		_check(exists, "SFX path ditemukan: %s -> %s" % [key, path])
		if exists:
			var stream = load(path)
			_check(stream is AudioStream, "Stream SFX adalah AudioStream: " + key)

	# Test procedural river_sound
	var river_sfx = AudioManager._get_or_build_sfx("river_sound")
	_check(river_sfx != null, "river_sound procedural berhasil disintesis")

	# Test pool playback
	AudioManager.play_bgm("hulu")
	AudioManager.play_sfx("footstep_land")
	AudioManager.play_sfx("footstep_water")
	AudioManager.play_sfx("coin")
	AudioManager.play_typewriter_blip()
	_check(true, "Playback pool & BGM sukses tanpa crash")

	print("RESULT: ", "PASS" if _failures == 0 else "FAIL", " (%d failures)" % _failures)
	get_tree().quit(0 if _failures == 0 else 1)
