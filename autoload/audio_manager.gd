## AudioManager Autoload
# Mengelola BGM per level dan SFX (termasuk 6 suara UI bawaan di res://assets/ui/Sounds/).
extends Node

# ─── Node & Pool ──────────────────────────────────────────────────────────────
const SFX_POOL_SIZE: int = 6

var _bgm_player: AudioStreamPlayer = null
var _sfx_player: AudioStreamPlayer = null
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_pool_idx: int = 0
var _stream_cache: Dictionary = {}
var _generated_sfx: Dictionary = {}
var _tap_toggle: bool = false
var _last_blip_msec: int = 0

# ─── Path Audio ───────────────────────────────────────────────────────────────
const BGM_PATHS: Dictionary = {
	"main_menu": "res://assets/audio/bgm/main_menu.wav",
	"intro":     "res://assets/audio/bgm/level1_hulu.wav",
	1:           "res://assets/audio/bgm/level1_hulu.wav",
	2:           "res://assets/audio/bgm/level2_desa.wav",
	3:           "res://assets/audio/bgm/level3_kota.wav",
	4:           "res://assets/audio/bgm/level4_hilir.wav",
	5:           "res://assets/audio/bgm/level5_epilog.wav",
	"hulu":      "res://assets/audio/bgm/level1_hulu.wav",
	"desa":      "res://assets/audio/bgm/level2_desa.wav",
	"kota":      "res://assets/audio/bgm/level3_kota.wav",
	"hilir":      "res://assets/audio/bgm/level4_hilir.wav",
	"epilog":     "res://assets/audio/bgm/level5_epilog.wav",
	"epilog_bad": "res://assets/audio/bgm/level5_epilog_bad.wav",
}

const SFX_PATHS: Dictionary = {
	# 6 Suara UI yang sudah ada di res://assets/ui/Sounds/
	"click":        "res://assets/ui/Sounds/click-a.ogg",
	"click_a":      "res://assets/ui/Sounds/click-a.ogg",
	"click_b":      "res://assets/ui/Sounds/click-b.ogg",
	"switch":       "res://assets/ui/Sounds/switch-a.ogg",
	"switch_a":     "res://assets/ui/Sounds/switch-a.ogg",
	"switch_b":     "res://assets/ui/Sounds/switch-b.ogg",
	"tap":          "res://assets/ui/Sounds/tap-a.ogg",
	"tap_a":        "res://assets/ui/Sounds/tap-a.ogg",
	"tap_b":        "res://assets/ui/Sounds/tap-b.ogg",
	# SFX Gameplay & Sistem Inti di res://assets/audio/sfx/
	"trash_pickup":   "res://assets/audio/sfx/trash_pickup.wav",
	"correct":        "res://assets/audio/sfx/correct.wav",
	"wrong":          "res://assets/audio/sfx/wrong.wav",
	"plant":          "res://assets/audio/sfx/plant.wav",
	"lever":          "res://assets/audio/sfx/lever.wav",
	"card_open":      "res://assets/audio/sfx/card_open.wav",
	"level_done":     "res://assets/audio/sfx/level_done.wav",
	"footstep_land":  "res://assets/audio/sfx/footstep_land.wav",
	"footstep_water": "res://assets/audio/sfx/footstep_water.wav",
	"coin":           "res://assets/audio/sfx/coin.wav",
	"rain_thunder":   "res://assets/audio/sfx/rain_thunder.wav",
	"gate_open":      "res://assets/audio/sfx/gate_open.wav",
}

func _ready() -> void:
	# Tetap aktif saat game sedang pause (menu jurnal, kartu edukasi, popup utang)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_audio_buses()

	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "BGM"
	add_child(_bgm_player)

	for i in range(SFX_POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_pool.append(p)
	_sfx_player = _sfx_pool[0]

	# Terapkan volume dari SettingsManager
	_apply_volume()
	call_deferred("_apply_volume")

	# Otomatis pasang suara klik/switch ke seluruh tombol UI yang ada & yang baru muncul
	get_tree().node_added.connect(_on_node_added)
	_connect_existing_buttons(get_tree().root)

func _ensure_audio_buses() -> void:
	if AudioServer.get_bus_index("BGM") == -1:
		var idx: int = AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, "BGM")
		AudioServer.set_bus_send(idx, "Master")
	if AudioServer.get_bus_index("SFX") == -1:
		var idx: int = AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, "SFX")
		AudioServer.set_bus_send(idx, "Master")

func _connect_existing_buttons(root: Node) -> void:
	if root == null:
		return
	_on_node_added(root)
	for child in root.get_children():
		_connect_existing_buttons(child)

func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		var btn := node as BaseButton
		# Abaikan area tap dialog/intro & ActionButton karena memakai tap_b tersendiri
		if btn.name in ["TapArea", "TapAdvanceBtn", "ActionButton"]:
			return
		if not btn.has_meta("_audio_hooked"):
			btn.set_meta("_audio_hooked", true)
			if btn is CheckButton or btn is CheckBox or btn is OptionButton:
				btn.pressed.connect(func(): play_sfx("switch_a"))
			else:
				btn.pressed.connect(func(): play_sfx("click_a"))

func _get_stream(path: String) -> AudioStream:
	if path.is_empty():
		return null
	if _stream_cache.has(path):
		return _stream_cache[path]
	var s: AudioStream = null
	if path.ends_with(".wav") and FileAccess.file_exists(path):
		s = AudioStreamWAV.load_from_file(ProjectSettings.globalize_path(path))
	if s == null and ResourceLoader.exists(path):
		s = load(path)
	if s != null:
		_stream_cache[path] = s
	return s

# ─── BGM ──────────────────────────────────────────────────────────────────────

func play_bgm(key: Variant) -> void:
	_apply_volume()
	var path: String = BGM_PATHS.get(key, "")
	var stream: AudioStream = _get_stream(path)
	if stream == null:
		_bgm_player.stop()
		_bgm_player.stream = null
		return
	if stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(round(wav.get_length() * float(wav.mix_rate)))
	if _bgm_player.playing and _bgm_player.stream == stream:
		return
	_bgm_player.stream = stream
	_bgm_player.volume_db = -3.0
	_bgm_player.play()

func stop_bgm() -> void:
	_bgm_player.stop()

# ─── SFX ──────────────────────────────────────────────────────────────────────

func play_sfx(key: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	_apply_volume()
	var path: String = SFX_PATHS.get(key, "")
	var stream: AudioStream = _get_stream(path)
	if stream == null:
		stream = _get_or_build_sfx(key)
	if stream == null:
		return
	var player: AudioStreamPlayer = _get_free_sfx_player()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()

## Efek ketikan lembut (memakai tap-a.ogg) untuk typewriter dialog & intro
func play_typewriter_blip() -> void:
	var now: int = Time.get_ticks_msec()
	if now - _last_blip_msec < 55:
		return
	_last_blip_msec = now
	play_sfx("tap_a", -7.0, randf_range(0.95, 1.06))

func _get_free_sfx_player() -> AudioStreamPlayer:
	for p in _sfx_pool:
		if not p.playing:
			return p
	var p: AudioStreamPlayer = _sfx_pool[_sfx_pool_idx]
	_sfx_pool_idx = (_sfx_pool_idx + 1) % _sfx_pool.size()
	return p

func _get_or_build_sfx(key: String) -> AudioStream:
	if _generated_sfx.has(key):
		return _generated_sfx[key]
	var wav: AudioStreamWAV = _build_procedural_sfx(key)
	if wav != null:
		_generated_sfx[key] = wav
	return wav

func _build_procedural_sfx(key: String) -> AudioStreamWAV:
	if key != "river_sound":
		return null
	var mix_rate: int = 22050
	var duration: float = 0.95
	var sample_count: int = int(duration * mix_rate)
	var data := PackedByteArray()
	data.resize(sample_count * 2)

	for i in range(sample_count):
		var t: float = float(i) / float(mix_rate)
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
		var sample: float = knock1 + knock2 + splash
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
	var bgm_bus: int = AudioServer.get_bus_index("BGM")
	var sfx_bus: int = AudioServer.get_bus_index("SFX")
	if bgm_bus >= 0:
		AudioServer.set_bus_volume_db(bgm_bus, linear_to_db(maxf(0.0001, bgm_vol)))
		AudioServer.set_bus_mute(bgm_bus, bgm_vol <= 0.001)
	if sfx_bus >= 0:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(maxf(0.0001, sfx_vol)))
		AudioServer.set_bus_mute(sfx_bus, sfx_vol <= 0.001)

func apply_volume() -> void:
	_apply_volume()
