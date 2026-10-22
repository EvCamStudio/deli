## SettingsMenu Script
# Panel pengaturan: volume BGM/SFX, ukuran tombol, opacity, getar.
extends Control
class_name SettingsMenu

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var bgm_slider: HSlider = $VBox/BGMRow/BGMSlider
@onready var sfx_slider: HSlider = $VBox/SFXRow/SFXSlider
@onready var touch_size_options: OptionButton = $VBox/TouchSizeRow/TouchSizeOptions
@onready var opacity_slider: HSlider = $VBox/OpacityRow/OpacitySlider
@onready var vibration_check: CheckButton = $VBox/VibrationRow/VibrationCheck
@onready var close_btn: Button = $VBox/CloseBtn

func _ready() -> void:
	# Muat nilai saat ini
	bgm_slider.value = SettingsManager.get_setting("bgm_volume", 0.8)
	sfx_slider.value = SettingsManager.get_setting("sfx_volume", 1.0)
	touch_size_options.selected = SettingsManager.get_setting("touch_size", 1)
	opacity_slider.value = SettingsManager.get_setting("touch_opacity", 0.7)
	vibration_check.button_pressed = SettingsManager.get_setting("vibration", true)

	bgm_slider.value_changed.connect(_on_bgm_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	touch_size_options.item_selected.connect(_on_touch_size_changed)
	opacity_slider.value_changed.connect(_on_opacity_changed)
	vibration_check.toggled.connect(_on_vibration_changed)
	close_btn.pressed.connect(func(): hide())

func _on_bgm_changed(value: float) -> void:
	SettingsManager.set_setting("bgm_volume", value)
	AudioManager.apply_volume()

func _on_sfx_changed(value: float) -> void:
	SettingsManager.set_setting("sfx_volume", value)
	AudioManager.apply_volume()

func _on_touch_size_changed(index: int) -> void:
	SettingsManager.set_setting("touch_size", index)
	# Update touch controls di scene aktif
	get_tree().call_group("touch_controls", "apply_settings")

func _on_opacity_changed(value: float) -> void:
	SettingsManager.set_setting("touch_opacity", value)
	get_tree().call_group("touch_controls", "apply_settings")

func _on_vibration_changed(enabled: bool) -> void:
	SettingsManager.set_setting("vibration", enabled)
