## PilotHUD — HUD bergaya jurnal ala Citampi untuk vertical slice.
extends CanvasLayer
class_name PilotHUD

@onready var river_bar: ProgressBar = $SafeMargin/Root/TopBar/ClarityCard/Row/RiverBar
@onready var river_label: Label = $SafeMargin/Root/TopBar/ClarityCard/Row/RiverLabel

@onready var money_label: Label = $SafeMargin/Root/TopBar/MoneyCard/Row/MoneyLabel
@onready var mission_label: Label = $SafeMargin/Root/MissionCard/VBox/MissionLabel
@onready var carry_label: Label = $SafeMargin/Root/CarryLabel
@onready var toast: PanelContainer = $SafeMargin/Root/Toast
@onready var toast_label: Label = $SafeMargin/Root/Toast/Label
@onready var pause_btn: Button = $SafeMargin/Root/TopBar/PauseBtn
@onready var completion: Control = $Completion
@onready var completion_title: Label = $Completion/Panel/VBox/Title
@onready var completion_text: RichTextLabel = $Completion/Panel/VBox/Text
@onready var continue_btn: Button = $Completion/Panel/VBox/ContinueBtn

const COMPLETION_INFO: Dictionary = {
	1: {
		"title": "BAB 1 SELESAI!",
		"text": "[center]Hutan hulu kembali hijau. Lima pohon baru menahan air hujan dan menjaga mata air Sungai Deli.[/center]",
		"button": "Lanjut ke Desa",
		"next_level": 2,
	},
	2: {
		"title": "BAB 2 SELESAI!",
		"text": "[center]Warga desa kembali gotong royong. Sampah terpilah dan sungai mulai jernih.[/center]",
		"button": "Lanjut ke Kota",
		"next_level": 3,
	},
	3: {
		"title": "BAB 3 SELESAI!",
		"text": "[center]Bantaran Kota Medan mulai bersih. Drainase terbuka, sampah terpilah, dan pantun Budi terjaga.[/center]",
		"button": "Lanjut ke Hilir",
		"next_level": 4,
	},
	4: {
		"title": "BAB 4 SELESAI!",
		"text": "[center]Pesisir kembali terlindungi. Mangrove ditanam, sampah dipilah, dan muara sungai mulai pulih.[/center]",
		"button": "Lanjut ke Epilog",
		"next_level": 5,
	},
}

var _toast_tween: Tween = null
var _clock_accum: float = 0.0
var _next_level: int = 0
var _low_style := StyleBoxFlat.new()
var _ok_style := StyleBoxFlat.new()

func _ready() -> void:
	completion.hide()
	toast.hide()
	pause_btn.pressed.connect(_on_pause_pressed)
	GameState.river_health_changed.connect(_on_river_health_changed)
	GameState.level_completed.connect(_on_level_completed)

	_low_style.bg_color = Color(0.78, 0.38, 0.31)
	_low_style.corner_radius_top_left = 4
	_low_style.corner_radius_top_right = 4
	_low_style.corner_radius_bottom_left = 4
	_low_style.corner_radius_bottom_right = 4
	_ok_style.bg_color = Color(0.24, 0.63, 0.74)
	_ok_style.corner_radius_top_left = 4
	_ok_style.corner_radius_top_right = 4
	_ok_style.corner_radius_bottom_left = 4
	_ok_style.corner_radius_bottom_right = 4

	_on_river_health_changed(GameState.river_health)
	_update_money()
	_update_carry()

	var cont_btn := continue_btn
	var menu_btn := completion.get_node_or_null("Panel/VBox/MenuBtn") as Button
	if cont_btn:
		cont_btn.pressed.connect(_on_continue)
	if menu_btn:
		menu_btn.pressed.connect(_on_menu)

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	_clock_accum += delta
	if _clock_accum >= 2.0:
		_clock_accum = 0.0
		GameState.minutes += 1
		if GameState.minutes >= 60 * 24:
			GameState.minutes = 6 * 60
			GameState.day += 1
	_update_money()
	_update_carry()

func _on_river_health_changed(value: float) -> void:
	river_bar.value = value
	river_label.text = "%d%%" % int(value)
	river_bar.add_theme_stylebox_override("fill", _ok_style if value >= 55.0 else _low_style)

func update_mission(text: String) -> void:
	mission_label.text = text

func _update_money() -> void:
	money_label.text = "Rp %s" % _format_number(GameState.rupiah)

func _update_carry() -> void:
	var pending: Array = GameState.get_meta("pending_trash", [])
	carry_label.text = "Dibawa: %d sampah" % pending.size()
	carry_label.visible = not pending.is_empty()

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

func show_toast(text: String, good: bool = true) -> void:
	toast.show()
	toast_label.text = text
	toast_label.add_theme_color_override("font_color", Color(0.18, 0.35, 0.22) if good else Color(0.55, 0.18, 0.14))
	if _toast_tween:
		_toast_tween.kill()
	toast.modulate.a = 0.0
	_toast_tween = create_tween()
	_toast_tween.tween_property(toast, "modulate:a", 1.0, 0.18)
	_toast_tween.tween_interval(2.2)
	_toast_tween.tween_property(toast, "modulate:a", 0.0, 0.35)
	_toast_tween.tween_callback(func(): toast.hide())

func _on_pause_pressed() -> void:
	get_tree().call_group("level", "open_pause_menu")

func _on_level_completed(level_id: int) -> void:
	if not COMPLETION_INFO.has(level_id):
		return
	var info: Dictionary = COMPLETION_INFO[level_id]
	_next_level = int(info.get("next_level", 0))
	completion_title.text = str(info.get("title", "BAB SELESAI!"))
	completion_text.text = str(info.get("text", ""))
	continue_btn.text = str(info.get("button", "Lanjut"))
	var level := get_tree().get_first_node_in_group("level")
	if level:
		var card_popup := level.get_node_or_null("KnowledgeCardPopup")
		if card_popup and card_popup.has_method("close_all"):
			card_popup.close_all()
		if level.has_method("set_touch_controls_visible"):
			level.set_touch_controls_visible(false)
	completion.show()
	get_tree().paused = true

func _on_continue() -> void:
	get_tree().paused = false
	if _next_level >= 1 and _next_level <= 5:
		SceneManager.change_level(_next_level)
	else:
		SceneManager.go_to_main_menu()

func _on_menu() -> void:
	get_tree().paused = false
	SceneManager.go_to_main_menu()
