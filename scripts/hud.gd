## HUD Script
# Menampilkan bar Kejernihan Sungai, penghitung sampah/pohon,
# indikator misi, dan tombol pause. Mengikuti safe area Android.
extends CanvasLayer
class_name HUD

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var river_bar: ProgressBar = $SafeMargin/TopBar/RiverBar
@onready var river_label: Label = $SafeMargin/TopBar/RiverLabel
@onready var trash_label: Label = $SafeMargin/TopBar/TrashLabel
@onready var mission_label: Label = $SafeMargin/TopBar/MissionLabel
@onready var pause_btn: Button = $SafeMargin/TopBar/PauseBtn
@onready var safe_margin: MarginContainer = $SafeMargin

func _ready() -> void:
	# Sambungkan sinyal GameState
	GameState.river_health_changed.connect(_on_river_health_changed)

	# Terapkan safe area agar tidak tertutup notch
	_apply_safe_area()

	# Inisialisasi tampilan
	_on_river_health_changed(GameState.river_health)
	_update_counters()

	pause_btn.pressed.connect(_on_pause_pressed)

func _apply_safe_area() -> void:
	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	# Hitung margin proporsional relatif terhadap viewport
	if screen_size.x > 0 and screen_size.y > 0:
		var scale_x: float = 480.0 / float(screen_size.x)
		var scale_y: float = 270.0 / float(screen_size.y)
		safe_margin.add_theme_constant_override("margin_left", int(safe_area.position.x * scale_x))
		safe_margin.add_theme_constant_override("margin_top", int(safe_area.position.y * scale_y))
		safe_margin.add_theme_constant_override("margin_right", int((screen_size.x - safe_area.end.x) * scale_x))
		safe_margin.add_theme_constant_override("margin_bottom", int((screen_size.y - safe_area.end.y) * scale_y))

func _on_river_health_changed(new_value: float) -> void:
	river_bar.value = new_value
	river_label.text = "Kejernihan: %d%%" % int(new_value)
	# Ubah warna bar sesuai kesehatan
	var style := river_bar.get_theme_stylebox("fill", "ProgressBar")
	if style is StyleBoxFlat:
		if new_value >= 70:
			(style as StyleBoxFlat).bg_color = Color(0.2, 0.8, 0.6)
		elif new_value >= 40:
			(style as StyleBoxFlat).bg_color = Color(0.8, 0.7, 0.2)
		else:
			(style as StyleBoxFlat).bg_color = Color(0.7, 0.3, 0.2)

func _update_counters() -> void:
	var total_trash: int = GameState.get_total_trash()
	trash_label.text = "Sampah: %d" % total_trash

func update_mission(text: String) -> void:
	mission_label.text = text

func _on_pause_pressed() -> void:
	# Kirim sinyal ke level scene untuk membuka pause menu
	get_tree().call_group("level", "open_pause_menu")

func _process(_delta: float) -> void:
	_update_counters()
