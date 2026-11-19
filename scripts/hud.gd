## HUD Script (Deli Rewind - Integrasi Heiz & Wan)
## Menampilkan:
## - Bar Meter Bencana (0-100, setara 100 - river_health)
## - Sikap 3 NPC (Jali, Rina, Darwis) dengan kotak warna & status
## - Lokasi Zona & Kompas Tujuan
## - Uang (Rp), Misi Aktif, Sampah Dibawa, Toast, & Hint Kearifan Lokal
extends CanvasLayer
class_name HUD

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var river_bar: ProgressBar = $SafeMargin/Root/TopBar/ClarityCard/Row/RiverBar
@onready var river_label: Label = $SafeMargin/Root/TopBar/ClarityCard/Row/RiverLabel
@onready var location_label: Label = get_node_or_null("SafeMargin/Root/TopBar/LocationCard/Label") as Label
@onready var rupiah_label: Label = $SafeMargin/Root/TopBar/MoneyCard/Row/RupiahLabel
@onready var mission_card: PanelContainer = $SafeMargin/Root/MissionCard
@onready var mission_label: Label = $SafeMargin/Root/MissionCard/VBox/MissionLabel
@onready var mission_title: Label = $SafeMargin/Root/MissionCard/VBox/MissionTitle
@onready var carry_label: Label = $SafeMargin/Root/CarryLabel
@onready var toast_panel: PanelContainer = $SafeMargin/Root/Toast
@onready var toast_label: Label = $SafeMargin/Root/Toast/Label
@onready var hint_card: PanelContainer = get_node_or_null("SafeMargin/Root/HintCard") as PanelContainer
@onready var hint_label: Label = get_node_or_null("SafeMargin/Root/HintCard/Label") as Label
@onready var compass_panel: PanelContainer = get_node_or_null("SafeMargin/Root/Compass") as PanelContainer
@onready var compass_label: Label = get_node_or_null("SafeMargin/Root/Compass/Label") as Label
@onready var pause_btn: Button = $SafeMargin/Root/TopBar/PauseBtn
@onready var safe_margin: MarginContainer = $SafeMargin
@onready var root_control: Control = $SafeMargin/Root

# Optional nodes (jika scene memiliki TimeCard / EnergyCard / DebtCard)
@onready var day_label: Label = get_node_or_null("SafeMargin/Root/TopBar/TimeCard/Row/DayLabel") as Label
@onready var energy_label: Label = get_node_or_null("SafeMargin/Root/TopBar/EnergyCard/Row/EnergyLabel") as Label
@onready var debt_label: Label = get_node_or_null("SafeMargin/Root/TopBar/DebtCard/Row/DebtLabel") as Label

# ─── State ────────────────────────────────────────────────────────────────────
var _toast_tween: Tween = null
var _hint_tween: Tween = null
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

const LOCATION_NAMES: Dictionary = {
	1: "HULU SUNGAI DELI",
	2: "DESA SUNGAI DELI",
	3: "KOTA MEDAN",
	4: "HILIR SUNGAI DELI",
	5: "EPILOG",
}

func _ready() -> void:
	_build_bar_styles()
	_build_sikap_panel()

	# Hubungkan sinyal GameState
	if GameState.has_signal("meter_changed"):
		GameState.meter_changed.connect(_on_meter_changed)
	if GameState.has_signal("river_health_changed"):
		GameState.river_health_changed.connect(_on_river_health_changed)
	if GameState.has_signal("sikap_changed"):
		GameState.sikap_changed.connect(_on_sikap_changed)
	if GameState.has_signal("hari_changed"):
		GameState.hari_changed.connect(_on_hari_changed)
	if GameState.has_signal("waktu_changed"):
		GameState.waktu_changed.connect(_on_waktu_changed)
	if GameState.has_signal("energy_changed"):
		GameState.energy_changed.connect(_on_energy_changed)
	if GameState.has_signal("rupiah_changed"):
		GameState.rupiah_changed.connect(_on_rupiah_changed)
	if GameState.has_signal("utang_changed"):
		GameState.utang_changed.connect(_on_utang_changed)

	_apply_safe_area()
	if pause_btn:
		pause_btn.pressed.connect(_on_pause_pressed)

	if toast_panel:
		toast_panel.hide()
	if hint_card:
		hint_card.hide()
	if compass_panel:
		compass_panel.hide()
	hide_mission()
	update_all()
	_update_sikap_visibility()

func _unhandled_input(event: InputEvent) -> void:
	# Hilangkan petunjuk otomatis begitu pemain bergerak atau menyentuh layar
	if hint_card and hint_card.visible:
		if event.is_action_pressed("move_up") or event.is_action_pressed("move_down") or \
		   event.is_action_pressed("move_left") or event.is_action_pressed("move_right") or \
		   event.is_action_pressed("action") or (event is InputEventScreenTouch and event.pressed) or \
		   (event is InputEventScreenDrag):
			hide_hint()

func _process(_delta: float) -> void:
	if get_tree().paused:
		return
	_update_carry()

# ─── Setup ────────────────────────────────────────────────────────────────────

func _build_bar_styles() -> void:
	_bar_danger = _make_bar_style(Color(0.85, 0.28, 0.22))
	_bar_warn = _make_bar_style(Color(0.92, 0.68, 0.20))
	_bar_safe = _make_bar_style(Color(0.24, 0.72, 0.42))
	if river_bar:
		var bar_bg := StyleBoxFlat.new()
		bar_bg.bg_color = Color(0.85, 0.80, 0.70, 0.85)
		bar_bg.set_corner_radius_all(3)
		river_bar.add_theme_stylebox_override("background", bar_bg)

func _make_bar_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(3)
	return style

## Membuat panel indikator Sikap NPC (Jali, Rina, Darwis) dengan kotak warna & teks
func _build_sikap_panel() -> void:
	if _sikap_card != null or root_control == null:
		return
	_sikap_card = PanelContainer.new()
	_sikap_card.name = "SikapCard"
	_sikap_card.layout_mode = 1
	_sikap_card.anchors_preset = Control.PRESET_TOP_RIGHT
	_sikap_card.anchor_left = 1.0
	_sikap_card.anchor_right = 1.0
	_sikap_card.offset_left = -160.0
	_sikap_card.offset_top = 26.0
	_sikap_card.offset_right = 0.0
	_sikap_card.offset_bottom = 44.0

	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.96, 0.93, 0.84, 0.94)
	card_style.border_color = Color(0.48, 0.35, 0.22, 0.85)
	card_style.set_border_width_all(1)
	card_style.set_corner_radius_all(4)
	card_style.content_margin_left = 5
	card_style.content_margin_top = 1
	card_style.content_margin_right = 5
	card_style.content_margin_bottom = 1
	_sikap_card.add_theme_stylebox_override("panel", card_style)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_sikap_card.add_child(row)

	var font: FontFile = load("res://assets/fonts/Nunito.ttf")

	for npc_key in ["jali", "rina", "darwis"]:
		var item_box := HBoxContainer.new()
		item_box.add_theme_constant_override("separation", 3)

		var color_rect := ColorRect.new()
		color_rect.custom_minimum_size = Vector2(7, 7)
		color_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		color_rect.color = Color(0.55, 0.55, 0.55)
		item_box.add_child(color_rect)

		var lbl := Label.new()
		if font:
			lbl.add_theme_font_override("font", font)
		lbl.add_theme_font_size_override("font_size", 9)
		lbl.add_theme_color_override("font_color", Color(0.2, 0.14, 0.1))
		lbl.text = "%s: Acuh" % NPC_DISPLAY_NAMES[npc_key]
		item_box.add_child(lbl)

		row.add_child(item_box)
		_npc_ui[npc_key] = {
			"container": item_box,
			"box": color_rect,
			"label": lbl,
		}

	root_control.add_child(_sikap_card)
	_update_sikap_visibility()

## Menyesuaikan tampilan sikap agar hanya muncul untuk NPC yang relevan di zona saat ini
func _update_sikap_visibility() -> void:
	if _sikap_card == null:
		return
	var zone: String = ""
	if "in_world" in GameState and GameState.in_world and "world_zone" in GameState:
		zone = str(GameState.world_zone).to_lower()
	elif "current_level" in GameState:
		match GameState.current_level:
			1: zone = "hulu"
			2: zone = "desa"
			3: zone = "kota"
			4: zone = "hilir"
			_: zone = ""

	# Di Hulu, Hilir, atau Epilog, warga desa/kota (Jali, Rina, Darwis) tidak ada.
	# Sembunyikan panel sikap agar UI tetap bersih dan tidak menyemak.
	if zone == "hulu" or zone == "hilir" or zone == "epilog" or zone.is_empty():
		_sikap_card.hide()
		return

	_sikap_card.show()
	if zone == "desa":
		if "jali" in _npc_ui: _npc_ui["jali"]["container"].hide()
		if "rina" in _npc_ui: _npc_ui["rina"]["container"].show()
		if "darwis" in _npc_ui: _npc_ui["darwis"]["container"].show()
	elif zone == "kota":
		if "jali" in _npc_ui: _npc_ui["jali"]["container"].show()
		if "rina" in _npc_ui: _npc_ui["rina"]["container"].hide()
		if "darwis" in _npc_ui: _npc_ui["darwis"]["container"].hide()

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
	var m_val: float = GameState.meter_bencana if "meter_bencana" in GameState else (100.0 - GameState.river_health)
	_on_meter_changed(m_val)
	_on_energy_changed(GameState.energi if "energi" in GameState else GameState.energy)
	_on_rupiah_changed(GameState.rupiah)
	_on_utang_changed(GameState.utang if "utang" in GameState else GameState.debt_amount)
	_update_time()
	_update_all_sikap()
	_update_carry()
	_update_location()

func _update_location() -> void:
	if not location_label:
		return
	if "in_world" in GameState and GameState.in_world and "world_zone" in GameState:
		set_location(GameState.world_zone.capitalize() + " Deli")
	else:
		var zone_name: String = LOCATION_NAMES.get(GameState.current_level, "")
		if not zone_name.is_empty():
			location_label.text = zone_name
	_update_sikap_visibility()

## Dipakai world map saat berpindah zona.
func set_location(zone_name: String) -> void:
	if location_label:
		location_label.text = zone_name
	_update_sikap_visibility()

func _on_river_health_changed(value: float) -> void:
	_on_meter_changed(100.0 - value)

func _on_meter_changed(meter_val: float) -> void:
	if not river_bar:
		return
	river_bar.value = meter_val
	if river_label:
		river_label.text = "Bencana %d%%" % int(round(meter_val))
	if meter_val <= 35.0:
		river_bar.add_theme_stylebox_override("fill", _bar_safe)
	elif meter_val <= 65.0:
		river_bar.add_theme_stylebox_override("fill", _bar_warn)
	else:
		river_bar.add_theme_stylebox_override("fill", _bar_danger)

func _update_all_sikap() -> void:
	for npc_key in ["jali", "rina", "darwis"]:
		var val: int = GameState.get_sikap(npc_key) if GameState.has_method("get_sikap") else 0
		_on_sikap_changed(npc_key, val)

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
	if energy_label:
		energy_label.text = "%d/100" % int(round(value))

func _on_rupiah_changed(value: int) -> void:
	if rupiah_label:
		rupiah_label.text = "Rp %s" % _format_short(value)

func _on_utang_changed(value: int) -> void:
	if debt_label:
		debt_label.text = "Utang %s" % _format_short(value)

func _on_hari_changed(_new_day: int) -> void:
	_update_time()

func _on_waktu_changed(_new_waktu: String) -> void:
	_update_time()

func _update_time() -> void:
	if day_label:
		var h: int = GameState.hari if "hari" in GameState else GameState.day
		var w: String = (GameState.waktu if "waktu" in GameState else "pagi").capitalize()
		day_label.text = "Hari %d/7 · %s" % [h, w]

func _update_carry() -> void:
	if not carry_label:
		return
	var pending: Array = GameState.get_meta("pending_trash", [])
	if pending.is_empty():
		carry_label.hide()
	else:
		var count: int = pending.size()
		if count >= 5:
			carry_label.text = "Kantong Sampah: 5/5 (Penuh - Buang ke Tong!)"
			carry_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.2, 1.0))
		else:
			carry_label.text = "Kantong Sampah: %d/5" % count
			carry_label.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82, 1.0))
		carry_label.show()

# ─── Misi ─────────────────────────────────────────────────────────────────────

func update_mission(text: String) -> void:
	if not mission_card or not mission_label or not mission_title:
		return
	var lines: PackedStringArray = text.split("\n")
	if lines.size() > 1:
		mission_title.text = "◆ " + lines[0].to_upper()
		mission_label.text = "\n".join(lines.slice(1))
	else:
		mission_title.text = "◆ MISI AKTIF"
		mission_label.text = text
	mission_card.reset_size()
	mission_card.show()

func show_mission() -> void:
	if mission_card:
		mission_card.show()

func hide_mission() -> void:
	if mission_card:
		mission_card.hide()

# ─── Toast ────────────────────────────────────────────────────────────────────

func show_toast(text: String, good: bool = true) -> void:
	if not toast_panel or not toast_label:
		return
	toast_panel.show()
	toast_label.text = text
	toast_label.add_theme_color_override(
		"font_color",
		Color(0.18, 0.45, 0.22) if good else Color(0.70, 0.20, 0.15)
	)
	if _toast_tween:
		_toast_tween.kill()
	toast_panel.modulate.a = 0.0
	_toast_tween = create_tween()
	_toast_tween.tween_property(toast_panel, "modulate:a", 1.0, 0.18)
	var hold: float = 2.0 + maxf(0.0, float(text.length() - 34) * 0.03)
	_toast_tween.tween_interval(hold)
	_toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.3)
	_toast_tween.tween_callback(func(): toast_panel.hide())

func hide_toast() -> void:
	if _toast_tween:
		_toast_tween.kill()
	if toast_panel:
		toast_panel.hide()

# ─── Hint card (onboarding & kearifan lokal) ──────────────────────────────────

## Tampilkan kartu petunjuk di atas toast. `seconds` <= 0 berarti tetap tampil.
func show_hint(text: String, seconds: float = 4.0) -> void:
	if not hint_card or not hint_label:
		return
	if text.strip_edges().is_empty():
		hide_hint()
		return
	hint_label.text = text
	hint_label.add_theme_color_override("font_color", Color(0.2, 0.14, 0.1))
	hint_card.show()
	if _hint_tween:
		_hint_tween.kill()
	hint_card.modulate.a = 0.0
	_hint_tween = create_tween()
	_hint_tween.tween_property(hint_card, "modulate:a", 1.0, 0.2)
	if seconds > 0.0:
		_hint_tween.tween_interval(seconds)
		_hint_tween.tween_property(hint_card, "modulate:a", 0.0, 0.3)
		_hint_tween.tween_callback(func(): hint_card.hide())

func hide_hint() -> void:
	if _hint_tween:
		_hint_tween.kill()
	if hint_card:
		hint_card.hide()

# ─── Kompas tujuan (untuk target di luar layar) ───────────────────────────────

## Arahkan pemain ke target: arah panah + jarak (misal "← 15m").
func set_objective(direction: String, distance_tiles: int, _target_name: String = "") -> void:
	if not compass_panel or not compass_label:
		return
	if direction.is_empty():
		compass_panel.hide()
		return
	compass_label.text = "%s %dm" % [direction, distance_tiles]
	compass_panel.show()

func hide_objective() -> void:
	if compass_panel:
		compass_panel.hide()

# ─── Utility ──────────────────────────────────────────────────────────────────

func _format_short(amount: int) -> String:
	if amount >= 1_000_000:
		return "%.1fjt" % (amount / 1_000_000.0)
	if amount >= 1_000:
		return "%drb" % (amount / 1_000)
	return str(amount)

func _on_pause_pressed() -> void:
	get_tree().call_group("level", "open_pause_menu")
