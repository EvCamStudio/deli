## HUD Script (Orang 1: Sistem Inti - Ridwan)
# Menampilkan:
# - Bar Meter Bencana (0-100, setara 100 - river_health)
# - Sikap 3 NPC (Jali, Rina, Darwis: Menolak, Acuh, Ragu, Peduli dengan kotak warna + teks)
# - Hari (1-7) & Fase Waktu (Pagi/Siang/Sore/Malam)
# - Uang (Rp), Energi (/100), dan Sisa Utang (Rp)
extends CanvasLayer
class_name HUD

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var river_bar: ProgressBar = $SafeMargin/Root/TopBar/ClarityCard/Row/RiverBar
@onready var river_label: Label = $SafeMargin/Root/TopBar/ClarityCard/Row/RiverLabel
@onready var day_label: Label = $SafeMargin/Root/TopBar/TimeCard/Row/DayLabel
@onready var rupiah_label: Label = $SafeMargin/Root/TopBar/MoneyCard/Row/RupiahLabel
@onready var energy_label: Label = $SafeMargin/Root/TopBar/EnergyCard/Row/EnergyLabel
@onready var debt_label: Label = $SafeMargin/Root/TopBar/DebtCard/Row/DebtLabel
@onready var mission_card: PanelContainer = $SafeMargin/Root/MissionCard
@onready var mission_label: Label = $SafeMargin/Root/MissionCard/VBox/MissionLabel
@onready var carry_label: Label = $SafeMargin/Root/CarryLabel
@onready var toast_panel: PanelContainer = $SafeMargin/Root/Toast
@onready var toast_label: Label = $SafeMargin/Root/Toast/Label
@onready var pause_btn: Button = $SafeMargin/Root/TopBar/PauseBtn
@onready var safe_margin: MarginContainer = $SafeMargin
@onready var root_control: Control = $SafeMargin/Root

# ─── State ────────────────────────────────────────────────────────────────────
var _toast_tween: Tween = null
var _bar_danger: StyleBoxFlat
var _bar_warn: StyleBoxFlat
var _bar_safe: StyleBoxFlat

## Referensi UI Sikap 3 NPC: npc_key -> {box: ColorRect, label: Label}
var _npc_ui: Dictionary = {}
var _sikap_card: PanelContainer = null

const NPC_DISPLAY_NAMES: Dictionary = {
	"jali": "Jali",
	"rina": "Rina",
	"darwis": "Darwis",
}

func _ready() -> void:
	_build_bar_styles()
	_build_sikap_panel()

	# Hubungkan ke sinyal Kontrak Bersama GameState
	GameState.meter_changed.connect(_on_meter_changed)
	GameState.sikap_changed.connect(_on_sikap_changed)
	GameState.hari_changed.connect(_on_hari_changed)
	GameState.waktu_changed.connect(_on_waktu_changed)
	GameState.energy_changed.connect(_on_energy_changed)
	GameState.rupiah_changed.connect(_on_rupiah_changed)
	GameState.utang_changed.connect(_on_utang_changed)

	_apply_safe_area()
	pause_btn.pressed.connect(_on_pause_pressed)
	toast_panel.hide()
	hide_mission()
	update_all()

func _process(_delta: float) -> void:
	if get_tree().paused:
		return
	_update_carry()

# ─── Setup ────────────────────────────────────────────────────────────────────

func _build_bar_styles() -> void:
	# Meter Bencana tinggi = Merah (bahaya banjir), sedang = Kuning, rendah = Hijau/Biru (aman)
	_bar_danger = _make_bar_style(Color(0.78, 0.25, 0.22))
	_bar_warn = _make_bar_style(Color(0.85, 0.64, 0.18))
	_bar_safe = _make_bar_style(Color(0.24, 0.66, 0.42))

func _make_bar_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style

## Membuat panel indikator Sikap 3 NPC (Jali, Rina, Darwis) dengan kotak warna & teks
func _build_sikap_panel() -> void:
	_sikap_card = PanelContainer.new()
	_sikap_card.name = "SikapCard"
	_sikap_card.layout_mode = 1
	_sikap_card.anchors_preset = Control.PRESET_TOP_RIGHT
	_sikap_card.anchor_left = 1.0
	_sikap_card.anchor_right = 1.0
	_sikap_card.offset_left = -268.0
	_sikap_card.offset_top = 34.0
	_sikap_card.offset_right = 0.0
	_sikap_card.offset_bottom = 60.0

	var card_style: StyleBox = $SafeMargin/Root/TopBar/ClarityCard.get_theme_stylebox("panel")
	if card_style:
		_sikap_card.add_theme_stylebox_override("panel", card_style)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_sikap_card.add_child(row)

	for npc_key in ["jali", "rina", "darwis"]:
		var item_box := HBoxContainer.new()
		item_box.add_theme_constant_override("separation", 4)

		var color_rect := ColorRect.new()
		color_rect.custom_minimum_size = Vector2(9, 9)
		color_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		color_rect.color = Color(0.55, 0.55, 0.55)
		item_box.add_child(color_rect)

		var lbl := Label.new()
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.text = "%s: Acuh" % NPC_DISPLAY_NAMES[npc_key]
		item_box.add_child(lbl)

		row.add_child(item_box)
		_npc_ui[npc_key] = {
			"box": color_rect,
			"label": lbl,
		}

	root_control.add_child(_sikap_card)

func _apply_safe_area() -> void:
	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	if screen_size.x > 0 and screen_size.y > 0:
		var scale_x: float = 640.0 / float(screen_size.x)
		var scale_y: float = 360.0 / float(screen_size.y)
		safe_margin.add_theme_constant_override("margin_left", 12 + int(safe_area.position.x * scale_x))
		safe_margin.add_theme_constant_override("margin_top", 10 + int(safe_area.position.y * scale_y))
		safe_margin.add_theme_constant_override("margin_right", 12 + int((screen_size.x - safe_area.end.x) * scale_x))
		safe_margin.add_theme_constant_override("margin_bottom", 10 + int((screen_size.y - safe_area.end.y) * scale_y))

# ─── Update tampilan ──────────────────────────────────────────────────────────

func update_all() -> void:
	_on_meter_changed(GameState.meter_bencana)
	_on_energy_changed(GameState.energi)
	_on_rupiah_changed(GameState.uang)
	_on_utang_changed(GameState.utang)
	_update_time()
	_update_all_sikap()
	_update_carry()

func _on_meter_changed(meter_val: float) -> void:
	river_bar.value = meter_val
	river_label.text = "Bencana %d%%" % int(round(meter_val))
	if meter_val <= 35.0:
		river_bar.add_theme_stylebox_override("fill", _bar_safe)
	elif meter_val <= 65.0:
		river_bar.add_theme_stylebox_override("fill", _bar_warn)
	else:
		river_bar.add_theme_stylebox_override("fill", _bar_danger)

func _update_all_sikap() -> void:
	for npc_key in ["jali", "rina", "darwis"]:
		_on_sikap_changed(npc_key, GameState.get_sikap(npc_key))

func _on_sikap_changed(npc: String, nilai: int) -> void:
	var key: String = npc.to_lower()
	if key not in _npc_ui:
		return
	var entry: Dictionary = _npc_ui[key]
	var box: ColorRect = entry["box"]
	var lbl: Label = entry["label"]
	var display_name: String = NPC_DISPLAY_NAMES.get(key, key.capitalize())

	var status_text: String = "Acuh"
	var status_color := Color(0.55, 0.55, 0.55)  # 0: Acuh (Abu-abu)
	match nilai:
		GameState.SIKAP_MENOLAK:
			status_text = "Menolak"
			status_color = Color(0.80, 0.22, 0.20)  # -1: Merah
		GameState.SIKAP_ACUH:
			status_text = "Acuh"
			status_color = Color(0.55, 0.55, 0.55)  # 0: Abu-abu
		GameState.SIKAP_RAGU:
			status_text = "Ragu"
			status_color = Color(0.86, 0.62, 0.14)  # 1: Kuning/Oranye
		GameState.SIKAP_PEDULI:
			status_text = "Peduli"
			status_color = Color(0.22, 0.68, 0.36)  # 2: Hijau

	box.color = status_color
	lbl.text = "%s: %s" % [display_name, status_text]

func _on_energy_changed(value: float) -> void:
	energy_label.text = "%d/100" % int(round(value))

func _on_rupiah_changed(value: int) -> void:
	rupiah_label.text = "Rp %s" % _format_short(value)

func _on_utang_changed(value: int) -> void:
	debt_label.text = "Utang %s" % _format_short(value)

func _on_hari_changed(_new_day: int) -> void:
	_update_time()

func _on_waktu_changed(_new_waktu: String) -> void:
	_update_time()

func _update_time() -> void:
	day_label.text = "Hari %d/7 · %s" % [GameState.hari, GameState.waktu.capitalize()]

func _update_carry() -> void:
	var pending: Array = GameState.get_meta("pending_trash", [])
	if pending.is_empty():
		carry_label.hide()
	else:
		var first: Dictionary = pending[0]
		var cat: String = str(first.get("category", "")).capitalize()
		carry_label.text = "Dibawa: %d (%s)" % [pending.size(), cat]
		carry_label.show()

# ─── Misi ─────────────────────────────────────────────────────────────────────

func update_mission(text: String) -> void:
	mission_label.text = text
	mission_card.show()

func show_mission() -> void:
	mission_card.show()

func hide_mission() -> void:
	mission_card.hide()

# ─── Toast ────────────────────────────────────────────────────────────────────

func show_toast(text: String, good: bool = true) -> void:
	toast_panel.show()
	toast_label.text = text
	toast_label.add_theme_color_override(
		"font_color",
		Color(0.18, 0.35, 0.22) if good else Color(0.55, 0.18, 0.14)
	)
	if _toast_tween:
		_toast_tween.kill()
	toast_panel.modulate.a = 0.0
	_toast_tween = create_tween()
	_toast_tween.tween_property(toast_panel, "modulate:a", 1.0, 0.18)
	_toast_tween.tween_interval(2.2)
	_toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.35)
	_toast_tween.tween_callback(func(): toast_panel.hide())

func hide_toast() -> void:
	if _toast_tween:
		_toast_tween.kill()
	toast_panel.hide()

# ─── Utility ──────────────────────────────────────────────────────────────────

func _format_short(amount: int) -> String:
	if amount >= 1_000_000:
		return "%.1fjt" % (amount / 1_000_000.0)
	if amount >= 1_000:
		return "%drb" % (amount / 1_000)
	return str(amount)

func _on_pause_pressed() -> void:
	get_tree().call_group("level", "open_pause_menu")
