## PauseMenu Script
# Menu pause: Lanjut, Koleksi Kartu, Pengaturan, Menu Utama.
# Dibuka via tombol pause di HUD atau tombol Back Android.
extends CanvasLayer
class_name PauseMenu

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var panel: PanelContainer = $Panel
@onready var resume_btn: Button = $Panel/VBox/ResumeBtn
@onready var cards_btn: Button = $Panel/VBox/CardsBtn
@onready var settings_btn: Button = $Panel/VBox/SettingsBtn
@onready var main_menu_btn: Button = $Panel/VBox/MainMenuBtn
@onready var settings_panel: Control = $SettingsPanel

# ─── Signal ───────────────────────────────────────────────────────────────────
signal resumed

func _ready() -> void:
	panel.hide()
	settings_panel.hide()
	resume_btn.pressed.connect(_on_resume)
	cards_btn.pressed.connect(_on_cards)
	settings_btn.pressed.connect(_on_settings)
	main_menu_btn.pressed.connect(_on_main_menu)

# ─── Buka / Tutup ─────────────────────────────────────────────────────────────

func open() -> void:
	panel.show()
	get_tree().paused = true

func close() -> void:
	panel.hide()
	settings_panel.hide()
	get_tree().paused = false
	resumed.emit()

func is_open() -> bool:
	return panel.visible

# ─── Tombol ───────────────────────────────────────────────────────────────────

func _on_resume() -> void:
	close()

func _on_cards() -> void:
	# Cari KnowledgeCardPopup di scene
	var popup := get_tree().get_first_node_in_group("knowledge_card_popup")
	if popup and popup.has_method("open_collection"):
		popup.open_collection()

func _on_settings() -> void:
	settings_panel.show()

func _on_main_menu() -> void:
	get_tree().paused = false
	SceneManager.go_to_main_menu()

# ─── Tombol Back Android ──────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_open():
			close()
		else:
			open()
		get_viewport().set_input_as_handled()
