## TouchControls Script
# Mengelola tombol sentuh virtual: D-pad kiri, tombol A (lompat), B (aksi).
# Sembunyikan saat dialog aktif; dukung multi-touch via TouchScreenButton.
extends CanvasLayer
class_name TouchControls

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var left_btn: TouchScreenButton = $LeftButtons/LeftBtn
@onready var right_btn: TouchScreenButton = $LeftButtons/RightBtn
@onready var jump_btn: TouchScreenButton = $RightButtons/JumpBtn   # Tombol A
@onready var action_btn: TouchScreenButton = $RightButtons/ActionBtn  # Tombol B
@onready var pause_btn: TouchScreenButton = get_node_or_null("PauseBtn") as TouchScreenButton
@onready var left_buttons: HBoxContainer = $LeftButtons
@onready var right_buttons: HBoxContainer = $RightButtons

# ─── Action Label pada Tombol B ───────────────────────────────────────────────
@onready var action_label_node: Label = $RightButtons/ActionBtn/Label

func _ready() -> void:
	add_to_group("touch_controls")
	apply_settings()

	# Sambungkan sinyal dialog untuk menyembunyikan tombol
	DialogueManager.dialogue_started.connect(_hide_controls)
	DialogueManager.dialogue_finished.connect(_show_controls)

	# Pause button
	if pause_btn:
		pause_btn.pressed.connect(_on_pause_pressed)

## Perbarui label tombol B berdasarkan objek interaktif terdekat.
func set_action_label(label: String) -> void:
	if action_label_node:
		action_label_node.text = label

# ─── Visibilitas ──────────────────────────────────────────────────────────────

func _hide_controls() -> void:
	left_buttons.hide()
	right_buttons.hide()

func _show_controls() -> void:
	left_buttons.show()
	right_buttons.show()

# ─── Pengaturan ───────────────────────────────────────────────────────────────

func apply_settings() -> void:
	var scale_val: float = SettingsManager.get_touch_scale()
	var opacity: float = SettingsManager.get_touch_opacity()

	# Skala seluruh grup tombol
	left_buttons.scale = Vector2(scale_val, scale_val)
	right_buttons.scale = Vector2(scale_val, scale_val)

	# Opacity via modulate
	var mod_color := Color(1, 1, 1, opacity)
	left_buttons.modulate = mod_color
	right_buttons.modulate = mod_color
	if pause_btn:
		pause_btn.modulate = Color(1, 1, 1, opacity * 0.8)

func _on_pause_pressed() -> void:
	get_tree().call_group("pause_menu", "toggle_pause")
