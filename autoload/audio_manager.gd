## AudioManager Autoload
# Mengelola BGM per level dan SFX.
# Stub: fungsi tersedia, audio nyata ditambahkan di M4.
extends Node

# ─── Node ─────────────────────────────────────────────────────────────────────
var _bgm_player: AudioStreamPlayer = null
var _sfx_player: AudioStreamPlayer = null
var _generated_sfx: Dictionary = {}

# ─── Path Audio (diisi di M4) ─────────────────────────────────────────────────
const BGM_PATHS: Dictionary = {
	"main_menu": "res://assets/audio/bgm/main_menu.ogg",
	1: "res://assets/audio/bgm/level1_hulu.ogg",
	2: "res://assets/audio/bgm/level2_desa.ogg",
	3: "res://assets/audio/bgm/level3_kota.ogg",
	4: "res://assets/audio/bgm/level4_hilir.ogg",
	5: "res://assets/audio/bgm/level5_epilog.ogg",
}

const SFX_PATHS: Dictionary = {
	"jump":         "res://assets/audio/sfx/jump.wav",
	"trash_pickup": "res://assets/audio/sfx/trash_pickup.wav",
	"correct":      "res://assets/audio/sfx/correct.wav",
	"wrong":        "res://assets/audio/sfx/wrong.wav",
	"card_open":    "res://assets/audio/sfx/card_open.wav",
	"level_done":   "res://assets/audio/sfx/level_done.wav",
}

func _ready() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "BGM"
	add_child(_bgm_player)

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "SFX"
	add_child(_sfx_player)

	# Terapkan volume dari SettingsManager
	_apply_volume()

# ─── BGM ──────────────────────────────────────────────────────────────────────

func play_bgm(key: Variant) -> void:
	var path: String = BGM_PATHS.get(key, "")
	if path.is_empty():
		return
	if not ResourceLoader.exists(path):
		return  # Stub: abaikan jika file belum ada
	var stream: AudioStream = load(path)
	if stream == null:
		return
	_bgm_player.stream = stream
	_bgm_player.play()

func stop_bgm() -> void:
	_bgm_player.stop()

# ─── SFX ──────────────────────────────────────────────────────────────────────

func play_sfx(key: String) -> void:
	var stream: AudioStream = null
	var path: String = SFX_PATHS.get(key, "")
	if not path.is_empty() and ResourceLoader.exists(path):
		stream = load(path)
	if stream == null:
		stream = _get_or_build_sfx(key)
	if stream == null:
		return
	_sfx_player.stream = stream
	_sfx_player.play()

func _get_or_build_sfx(key: String) -> AudioStream:
	if _generated_sfx.has(key):
		return _generated_sfx[key]
	var wav: AudioStreamWAV = _build_procedural_sfx(key)
	if wav != null:
		_generated_sfx[key] = wav
	return wav

func _build_procedural_sfx(key: String) -> AudioStreamWAV:
	var mix_rate: int = 22050
	var duration: float = 0.22
	match key:
		"river_sound":
			duration = 0.95
		"level_done":
			duration = 0.45
		"card_open":
			duration = 0.28
		_:
			duration = 0.20

	var sample_count: int = int(duration * mix_rate)
	var data := PackedByteArray()
	data.resize(sample_count * 2)

	for i in range(sample_count):
		var t: float = float(i) / float(mix_rate)
		var sample: float = 0.0
		match key:
			"river_sound":
				# Ketukan kayu sampan ("tok... tok...") diikuti cipratan air sungai.
				var knock1: float = 0.0
				if t < 0.14:
					knock1 = sin(TAU * 185.0 * t) * exp(-t * 28.0) * 0.55
				var knock2: float = 0.0
				if t >= 0.22 and t < 0.38:
					var dt2: float = t - 0.22
					knock2 = sin(TAU * 225.0 * dt2) * exp(-dt2 * 26.0) * 0.65
				var splash: float = 0.0
				if t >= 0.34:
					var dt3: float = t - 0.34
					var n: float = sin(t * 1731.7) * cos(t * 941.3)
					var ripple: float = sin(TAU * (310.0 - dt3 * 120.0) * dt3) * 0.22
					splash = (n * 0.28 + ripple) * exp(-dt3 * 3.8)
				sample = knock1 + knock2 + splash
			"correct":
				var f: float = 523.25 if t < 0.09 else 659.25
				sample = sin(TAU * f * t) * exp(-t * 10.0) * 0.35
			"wrong":
				sample = sin(TAU * 180.0 * t) * exp(-t * 11.0) * 0.35
			"card_open", "level_done":
				var freq: float = 440.0 if t < 0.12 else (554.37 if t < 0.24 else 659.25)
				sample = sin(TAU * freq * t) * exp(-t * 5.0) * 0.32
			_:
				sample = sin(TAU * 420.0 * t) * exp(-t * 14.0) * 0.28

		var pcm: int = clampi(int(round(sample * 32767.0)), -32768, 32767)
		data.encode_s16(i * 2, pcm)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = mix_rate
	wav.stereo = false
	wav.data = data
	return wav

# ─── Volume ───────────────────────────────────────────────────────────────────

func _apply_volume() -> void:
	var bgm_vol: float = SettingsManager.get_setting("bgm_volume", 0.8)
	var sfx_vol: float = SettingsManager.get_setting("sfx_volume", 1.0)
	# AudioServer bus volume (linear to dB)
	var bgm_bus: int = AudioServer.get_bus_index("BGM")
	var sfx_bus: int = AudioServer.get_bus_index("SFX")
	if bgm_bus >= 0:
		AudioServer.set_bus_volume_db(bgm_bus, linear_to_db(bgm_vol))
	if sfx_bus >= 0:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_vol))

func apply_volume() -> void:
	_apply_volume()
