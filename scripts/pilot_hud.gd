## PilotHUD — HUD Utama Deli Rewind (Dokumen Utama)
## Menampilkan Meter Bencana (0..100), Hari (1..7), Uang, Utang, Energi (⚡),
## Sikap 3 Warga (Jali, Rina, Darwis), dan dialog konfirmasi tidur.
extends CanvasLayer
class_name PilotHUD

@onready var river_bar: ProgressBar = $SafeMargin/Root/TopBar/ClarityCard/Row/RiverBar
@onready var river_label: Label = $SafeMargin/Root/TopBar/ClarityCard/Row/RiverLabel
@onready var time_label: Label = $SafeMargin/Root/TopBar/TimeCard/Row/TimeLabel
@onready var money_label: Label = $SafeMargin/Root/TopBar/MoneyCard/Row/MoneyLabel
@onready var mission_label: Label = $SafeMargin/Root/MissionCard/VBox/MissionLabel
@onready var carry_label: Label = $SafeMargin/Root/CarryLabel
@onready var toast: PanelContainer = $SafeMargin/Root/Toast
@onready var toast_label: Label = $SafeMargin/Root/Toast/Label
@onready var pause_btn: Button = $SafeMargin/Root/TopBar/PauseBtn
@onready var completion: Control = $Completion

var _toast_tween: Tween = null
var _low_style := StyleBoxFlat.new()
var _ok_style := StyleBoxFlat.new()

func _ready() -> void:
	add_to_group("hud")
	completion.hide()
	toast.hide()

	if pause_btn:
		pause_btn.pressed.connect(_on_pause_pressed)

	GameState.meter_changed.connect(_on_meter_changed)
	GameState.river_health_changed.connect(_on_river_health_changed)
	GameState.energi_changed.connect(_on_energi_changed)
	GameState.rupiah_changed.connect(_on_rupiah_changed)
	GameState.utang_changed.connect(_on_utang_changed)
	GameState.hari_berganti.connect(_on_hari_berganti)
	GameState.npc_sikap_changed.connect(_on_npc_sikap_changed)
	GameState.h1_fase_changed.connect(func(_f): _update_mission_by_day())

	_low_style.bg_color = Color(0.85, 0.35, 0.25)
	_ok_style.bg_color = Color(0.25, 0.65, 0.45)

	_update_all_displays()

func _process(_delta: float) -> void:
	# Sinkronisasi status misi dan label
	_update_mission_by_day()

func _update_all_displays() -> void:
	_on_meter_changed(GameState.meter_bencana)
	_update_money()
	_update_time()

func _on_meter_changed(meter_val: float) -> void:
	if river_bar:
		river_bar.value = meter_val
		# Warna: merah jika meter > 60 (bahaya), hijau jika meter <= 40 (aman)
		river_bar.add_theme_stylebox_override("fill", _low_style if meter_val > 50.0 else _ok_style)
	if river_label:
		river_label.text = "Meter Bencana: %d/100" % int(meter_val)

func _on_river_health_changed(_val: float) -> void:
	pass

func _on_energi_changed(_val: float) -> void:
	_update_time()

func _on_rupiah_changed(_val: int) -> void:
	_update_money()

func _on_utang_changed(_val: int) -> void:
	_update_money()

func _on_hari_berganti(_hari_baru: int) -> void:
	_update_time()
	show_toast("🌅 HARI %d DIMULAI! Energi pulih penuh ⚡ 100" % _hari_baru)

func _on_npc_sikap_changed(_npc: String, _nilai: int) -> void:
	_update_mission_by_day()

func _update_money() -> void:
	if money_label:
		money_label.text = "💰 Rp %s │ 🏠 Utang: Rp %s" % [
			_format_number(GameState.rupiah),
			_format_number(GameState.utang)
		]

func _update_time() -> void:
	if time_label:
		time_label.text = "📅 Hari %d / 7 │ ⚡ %d/100" % [
			GameState.hari,
			int(GameState.energi)
		]

func _update_mission_by_day() -> void:
	if not mission_label:
		return
	mission_label.text = GameState.get_current_objective()

func tampilkan_konfirmasi_tidur() -> void:
	var dialog_teks := "Apakah kamu ingin tidur di kasur warung?\n(Hari akan berganti, energi pulih penuh ⚡100, dan sampah malam dievaluasi)."
	# Tampilkan via dialogue manager
	var confirm_node := [
		{
			"id": "start",
			"speaker": "Kasur Warung",
			"emosi": "neutral",
			"teks": dialog_teks,
			"pilihan": [
				{
					"tipe": "A",
					"teks": "Ya, tidur sekarang (Ganti Hari)",
					"next": "tidur"
				},
				{
					"tipe": "B",
					"teks": "Belum, aku masih ingin beraktivitas",
					"next": "end"
				}
			]
		},
		{
			"id": "tidur",
			"speaker": "MC",
			"emosi": "neutral",
			"teks": "Selamat malam. Besok kita lanjutkan perjuangan menjaga sungai.",
			"next": "end"
		}
	]
	DialogueManager.dialog_selesai.connect(_on_tidur_dialog_selesai, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(confirm_node)

func _on_tidur_dialog_selesai(_id: String) -> void:
	GameState.tidur_ganti_hari()

func _format_number(value: int) -> String:
	var s: String = str(value)
	var out: String = ""
	var count: int = 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "." + out
	return out

func show_toast(text: String, good: bool = true) -> void:
	if not toast or not toast_label:
		return
	toast.show()
	toast_label.text = text
	if _toast_tween:
		_toast_tween.kill()
	toast.modulate.a = 0.0
	_toast_tween = create_tween()
	_toast_tween.tween_property(toast, "modulate:a", 1.0, 0.18)
	_toast_tween.tween_interval(2.6)
	_toast_tween.tween_property(toast, "modulate:a", 0.0, 0.35)
	_toast_tween.tween_callback(func(): toast.hide())

func _on_pause_pressed() -> void:
	get_tree().call_group("level", "open_pause_menu")
