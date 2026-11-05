## HUD Script
# HUD ringkas untuk gameplay: kejernihan sungai, lokasi, rupiah,
# misi aktif, sampah yang dibawa, dan notifikasi singkat.
extends CanvasLayer
class_name HUD

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var river_bar: ProgressBar = $SafeMargin/Root/TopBar/ClarityCard/Row/RiverBar
@onready var river_label: Label = $SafeMargin/Root/TopBar/ClarityCard/Row/RiverLabel
@onready var location_label: Label = $SafeMargin/Root/TopBar/LocationCard/Label
@onready var rupiah_label: Label = $SafeMargin/Root/TopBar/MoneyCard/Row/RupiahLabel
@onready var mission_card: PanelContainer = $SafeMargin/Root/MissionCard
@onready var mission_label: Label = $SafeMargin/Root/MissionCard/VBox/MissionLabel
@onready var carry_label: Label = $SafeMargin/Root/CarryLabel
@onready var toast_panel: PanelContainer = $SafeMargin/Root/Toast
@onready var toast_label: Label = $SafeMargin/Root/Toast/Label
@onready var pause_btn: Button = $SafeMargin/Root/TopBar/PauseBtn
@onready var safe_margin: MarginContainer = $SafeMargin

# ─── State ────────────────────────────────────────────────────────────────────
var _toast_tween: Tween = null
var _clock_accum: float = 0.0
var _bar_low: StyleBoxFlat
var _bar_mid: StyleBoxFlat
var _bar_ok: StyleBoxFlat

const LOCATION_NAMES: Dictionary = {
	1: "HULU SUNGAI DELI",
	2: "DESA SUNGAI DELI",
	3: "KOTA MEDAN",
	4: "HILIR SUNGAI DELI",
	5: "EPILOG",
}

func _ready() -> void:
	_build_bar_styles()
	GameState.river_health_changed.connect(_on_river_health_changed)
	GameState.rupiah_changed.connect(_on_rupiah_changed)

	_apply_safe_area()
	pause_btn.pressed.connect(_on_pause_pressed)
	toast_panel.hide()
	hide_mission()
	update_all()

func _process(delta: float) -> void:
	if get_tree().paused:
		return

	_clock_accum += delta
	if _clock_accum >= 2.0:
		_clock_accum = 0.0
		GameState.minutes += 1
		if GameState.minutes >= 24 * 60:
			GameState.minutes = 6 * 60
			GameState.day += 1

	_update_carry()

# ─── Setup ────────────────────────────────────────────────────────────────────

func _build_bar_styles() -> void:
	_bar_low = _make_bar_style(Color(0.78, 0.38, 0.31))
	_bar_mid = _make_bar_style(Color(0.82, 0.66, 0.22))
	_bar_ok = _make_bar_style(Color(0.24, 0.63, 0.74))

func _make_bar_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style

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
	_on_river_health_changed(GameState.river_health)
	_on_rupiah_changed(GameState.rupiah)
	_update_carry()
	_update_location()

func _update_location() -> void:
	var zone_name: String = LOCATION_NAMES.get(GameState.current_level, "")
	if not zone_name.is_empty():
		location_label.text = zone_name

## Dipakai world map saat berpindah zona.
func set_location(zone_name: String) -> void:
	location_label.text = zone_name

func _on_river_health_changed(value: float) -> void:
	river_bar.value = value
	river_label.text = "%d%%" % int(round(value))
	if value >= 70.0:
		river_bar.add_theme_stylebox_override("fill", _bar_ok)
	elif value >= 40.0:
		river_bar.add_theme_stylebox_override("fill", _bar_mid)
	else:
		river_bar.add_theme_stylebox_override("fill", _bar_low)

func _on_rupiah_changed(value: int) -> void:
	rupiah_label.text = "Rp %s" % _format_short(value)

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
