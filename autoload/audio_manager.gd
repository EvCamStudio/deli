## AudioManager Autoload
# Mengelola BGM per level dan SFX.
# Stub: fungsi tersedia, audio nyata ditambahkan di M4.
extends Node

# ─── Node ─────────────────────────────────────────────────────────────────────
var _bgm_player: AudioStreamPlayer = null
var _sfx_player: AudioStreamPlayer = null

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
	var path: String = SFX_PATHS.get(key, "")
	if path.is_empty():
		return
	if not ResourceLoader.exists(path):
		return  # Stub: abaikan jika file belum ada
	var stream: AudioStream = load(path)
	if stream == null:
		return
	_sfx_player.stream = stream
	_sfx_player.play()

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
