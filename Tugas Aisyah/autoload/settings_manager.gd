## SettingsManager Autoload
# Mengelola pengaturan: volume, ukuran tombol sentuh, getar.
# Simpan dan muat dari user://settings.cfg
extends Node

const SETTINGS_PATH: String = "user://settings.cfg"

# ─── Default ──────────────────────────────────────────────────────────────────
const DEFAULTS: Dictionary = {
	"bgm_volume":      0.8,
	"sfx_volume":      1.0,
	"touch_size":      1,    # 0=kecil, 1=sedang, 2=besar
	"touch_opacity":   0.7,
	"vibration":       true,
}

var _settings: Dictionary = {}

func _ready() -> void:
	_settings = DEFAULTS.duplicate()
	load_settings()

# ─── Getter / Setter ──────────────────────────────────────────────────────────

func get_setting(key: String, default_val: Variant = null) -> Variant:
	if _settings.has(key):
		return _settings[key]
	return default_val

func set_setting(key: String, value: Variant) -> void:
	_settings[key] = value
	save_settings()

# ─── Persistensi ──────────────────────────────────────────────────────────────

func save_settings() -> void:
	var cfg := ConfigFile.new()
	for key in _settings:
		cfg.set_value("settings", key, _settings[key])
	cfg.save(SETTINGS_PATH)

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return  # Pakai default jika belum ada file
	for key in DEFAULTS:
		if cfg.has_section_key("settings", key):
			_settings[key] = cfg.get_value("settings", key)

# ─── Ukuran Tombol Sentuh ─────────────────────────────────────────────────────

## Kembalikan skala tombol sentuh (0.8 / 1.0 / 1.25) berdasarkan pengaturan.
func get_touch_scale() -> float:
	match _settings.get("touch_size", 1):
		0: return 0.8
		2: return 1.25
		_: return 1.0

func get_touch_opacity() -> float:
	return _settings.get("touch_opacity", 0.7)

# ─── Getar (Vibration) ────────────────────────────────────────────────────────

func vibrate(duration_ms: int = 50) -> void:
	if _settings.get("vibration", true):
		Input.vibrate_handheld(duration_ms)
