## PilotJournal — menu pause bergaya buku jurnal.
extends CanvasLayer
class_name PilotJournal

@onready var overlay: ColorRect = $Overlay
@onready var panel: PanelContainer = $Panel
@onready var stats: Label = $Panel/VBox/Stats
@onready var resume_btn: Button = $Panel/VBox/ResumeBtn
@onready var save_btn: Button = $Panel/VBox/SaveBtn
@onready var menu_btn: Button = $Panel/VBox/MenuBtn
@onready var bgm_slider: HSlider = $Panel/VBox/Settings/BGM/Slider
@onready var sfx_slider: HSlider = $Panel/VBox/Settings/SFX/Slider
@onready var save_hint: Label = $Panel/VBox/SaveHint

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
	_refresh()
	overlay.show()
	panel.show()
	get_tree().paused = true

func close() -> void:
	overlay.hide()
	panel.hide()
	get_tree().paused = false

func is_open() -> bool:
	return panel.visible

func _refresh() -> void:
	stats.text = "Kejernihan %d%%   ·   Rp %s   ·   Hari %d" % [
		int(GameState.river_health),
		_format_number(GameState.rupiah),
		GameState.day,
	]

func _on_save() -> void:
	GameState.save_game()
	save_hint.text = "Progres tersimpan."
	save_hint.show()

func _on_menu() -> void:
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
