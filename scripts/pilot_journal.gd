## PilotJournal — menu pause bergaya buku jurnal.
extends CanvasLayer
class_name PilotJournal

signal opened
signal closed

@onready var overlay: ColorRect = $Overlay
@onready var panel: PanelContainer = $Panel
@onready var stats: Label = $Panel/VBox/Stats
@onready var wisdom: Label = $Panel/VBox/Wisdom
@onready var resume_btn: Button = $Panel/VBox/ResumeBtn
@onready var save_btn: Button = $Panel/VBox/SaveBtn
@onready var menu_btn: Button = $Panel/VBox/MenuBtn
@onready var bgm_slider: HSlider = $Panel/VBox/Settings/BGM/Slider
@onready var sfx_slider: HSlider = $Panel/VBox/Settings/SFX/Slider
@onready var save_hint: Label = $Panel/VBox/SaveHint

const WISDOMS: Array[String] = [
	"Tebang pokok di hulu, keringlah air di hilir.",
	"Berat sama dipikul, ringan sama dijinjing.",
	"Sungai adalah urat nadi kehidupan.",
	"Laut yang dijaga akan menjaga kita.",
	"Air yang jernih lahir dari kebiasaan kecil yang dijaga.",
]

var _wisdom_index: int = 0

func _ready() -> void:
	overlay.hide()
	panel.hide()
	save_hint.hide()
	resume_btn.pressed.connect(close)
	save_btn.pressed.connect(_on_save)
	menu_btn.pressed.connect(_on_menu)
	bgm_slider.value = SettingsManager.get_setting("bgm_volume", 0.8)
	sfx_slider.value = SettingsManager.get_setting("sfx_volume", 1.0)
	bgm_slider.value_changed.connect(_on_bgm_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)

func open() -> void:
	if is_open():
		return
	AudioManager.play_sfx("switch_a", -2.0)
	_refresh()
	overlay.show()
	panel.show()
	get_tree().paused = true
	opened.emit()

func close() -> void:
	AudioManager.play_sfx("switch_b", -2.0)
	overlay.hide()
	panel.hide()
	get_tree().paused = false
	closed.emit()

func is_open() -> bool:
	return panel.visible

func _refresh() -> void:
	if bgm_slider:
		bgm_slider.set_value_no_signal(float(SettingsManager.get_setting("bgm_volume", 0.8)))
	if sfx_slider:
		sfx_slider.set_value_no_signal(float(SettingsManager.get_setting("sfx_volume", 1.0)))
	var zone_text: String = ""
	if GameState.in_world:
		var loc_map: Dictionary = {
			"hulu": "Hulu Sungai Deli",
			"desa": "Desa Suka Maju",
			"kota": "Kota Medan",
			"hilir": "Muara Sungai Deli",
			"epilog": "Tepian Sungai Deli",
		}
		var loc_display: String = loc_map.get(str(GameState.world_zone).to_lower(), GameState.world_zone.capitalize())
		zone_text = "\nLokasi: %s" % loc_display
	stats.text = "Kejernihan %d%%   ·   Hari %d%s" % [
		int(GameState.river_health),
		GameState.day,
		zone_text,
	]
	if wisdom:
		wisdom.text = WISDOMS[_wisdom_index % WISDOMS.size()]
		_wisdom_index += 1

func _on_save() -> void:
	var ok: bool = GameState.save_game()
	if ok:
		save_hint.text = "Progres tersimpan."
		save_hint.add_theme_color_override("font_color", Color(0.2, 0.45, 0.25, 1))
	else:
		save_hint.text = "Gagal menyimpan. Coba lagi."
		save_hint.add_theme_color_override("font_color", Color(0.68, 0.2, 0.2, 1))
	save_hint.show()

func _on_menu() -> void:
	# Simpan juga saat keluar ke menu utama supaya progres setelah tombol
	# simpan terakhir tidak hilang.
	GameState.save_game()
	get_tree().paused = false
	SceneManager.go_to_main_menu()

func _on_bgm_changed(value: float) -> void:
	SettingsManager.set_setting("bgm_volume", value)
	AudioManager.apply_volume()

func _on_sfx_changed(value: float) -> void:
	SettingsManager.set_setting("sfx_volume", value)
	AudioManager.apply_volume()

func _format_number(value: int) -> String:
	var text: String = str(value)
	var out: String = ""
	var count: int = 0
	for i in range(text.length() - 1, -1, -1):
		out = text[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "." + out
	return out

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_open():
			close()
		else:
			open()
		get_viewport().set_input_as_handled()
