## MainMenu Script
# Menu utama: Mulai, Lanjut, Pilih Level, Koleksi Kartu, Pengaturan, Keluar.
extends Control

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var title_label: Label = $VBox/TitleLabel
@onready var subtitle_label: Label = $VBox/SubtitleLabel
@onready var start_btn: Button = $VBox/Buttons/StartBtn
@onready var continue_btn: Button = $VBox/Buttons/ContinueBtn
@onready var level_select_btn: Button = get_node_or_null("VBox/Buttons/LevelSelectBtn") as Button
@onready var cards_btn: Button = $VBox/Buttons/CardsBtn
@onready var settings_btn: Button = $VBox/Buttons/SettingsBtn
@onready var quit_btn: Button = $VBox/Buttons/QuitBtn

@onready var settings_panel: Control = $SettingsPanel
@onready var level_select_panel: Control = get_node_or_null("LevelSelectPanel") as Control
@onready var card_popup: CanvasLayer = get_node_or_null("KnowledgeCardPopup") as CanvasLayer
@onready var river_anim: AnimationPlayer = get_node_or_null("Background/RiverAnimPlayer") as AnimationPlayer
@onready var status_label: Label = get_node_or_null("VBox/StatusLabel") as Label

func _ready() -> void:
	AudioManager.play_bgm("main_menu")
	if settings_panel:
		settings_panel.hide()
	if level_select_panel:
		level_select_panel.hide()
	if status_label:
		status_label.hide()

	# Cek save game
	if continue_btn:
		continue_btn.disabled = not GameState.has_save()

	if start_btn:
		start_btn.pressed.connect(_on_start)
	if continue_btn:
		continue_btn.pressed.connect(_on_continue)
	if level_select_btn:
		level_select_btn.pressed.connect(_on_level_select)
	if cards_btn:
		cards_btn.pressed.connect(_on_cards)
	if settings_btn:
		settings_btn.pressed.connect(_on_settings)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit)

	_setup_level_select_buttons()

	if river_anim and river_anim.has_animation("idle_river"):
		river_anim.play("idle_river")

func _setup_level_select_buttons() -> void:
	if not level_select_panel:
		return
	var l1 := get_node_or_null("LevelSelectPanel/Panel/VBox/L1Btn") as Button
	var l2 := get_node_or_null("LevelSelectPanel/Panel/VBox/L2Btn") as Button
	var l3 := get_node_or_null("LevelSelectPanel/Panel/VBox/L3Btn") as Button
	var l4 := get_node_or_null("LevelSelectPanel/Panel/VBox/L4Btn") as Button
	var l5 := get_node_or_null("LevelSelectPanel/Panel/VBox/L5Btn") as Button
	var close_btn := get_node_or_null("LevelSelectPanel/Panel/VBox/CloseSelectBtn") as Button

	if l1: l1.pressed.connect(func(): _start_world_chapter("hulu"))
	if l2: l2.pressed.connect(func(): _start_world_chapter("desa"))
	if l3: l3.pressed.connect(func(): _start_world_chapter("kota"))
	if l4: l4.pressed.connect(func(): _start_world_chapter("hilir"))
	if l5: l5.pressed.connect(_start_epilog_preview)
	if close_btn: close_btn.pressed.connect(func(): level_select_panel.hide())

# ─── Tombol ───────────────────────────────────────────────────────────────────

func _on_start() -> void:
	# Mulai permainan baru: reset state lalu jalankan intro dramatis
	# (Bab 1 Jakarta input nama → Bab 2 PHK → Bab 3 Reunion Medan)
	GameState.reset()
	SceneManager.go_to_intro()

## "Pilih Bab" masuk ke world pada zona yang dipilih, dengan progres awal
## yang masuk akal supaya pemain bisa langsung mencoba gameplay zona itu.
func _start_world_chapter(zone: String) -> void:
	GameState.prepare_world_chapter(zone)
	if level_select_panel:
		level_select_panel.hide()
	SceneManager.go_to_world()

func _start_epilog_preview() -> void:
	GameState.prepare_epilog_preview()
	if level_select_panel:
		level_select_panel.hide()
	SceneManager.change_scene("res://scenes/levels/level_5_epilog.tscn")

func _on_continue() -> void:
	if GameState.load_game():
		if GameState.world_completed:
			SceneManager.change_scene("res://scenes/levels/level_5_epilog.tscn")
		else:
			var target_scene: String = GameState.saved_scene if "saved_scene" in GameState else ""
			if not target_scene.is_empty() and ResourceLoader.exists(target_scene) and not target_scene.contains("level_"):
				SceneManager.change_scene(target_scene)
			else:
				GameState.in_world = true
				SceneManager.go_to_world()
	else:
		_show_status("Save tidak bisa dimuat. Silakan mulai perjalanan baru.")
		if continue_btn:
			continue_btn.disabled = true

func _show_status(text: String) -> void:
	if status_label:
		status_label.text = text
		status_label.show()
	else:
		title_label.text = text

func _on_level_select() -> void:
	if level_select_panel:
		level_select_panel.show()

func _on_cards() -> void:
	if card_popup and card_popup.has_method("open_collection"):
		card_popup.open_collection()

func _on_settings() -> void:
	if settings_panel:
		settings_panel.show()

func _on_quit() -> void:
	get_tree().quit()

# ─── Back Button ──────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if level_select_panel and level_select_panel.visible:
			level_select_panel.hide()
			get_viewport().set_input_as_handled()
		elif settings_panel and settings_panel.visible:
			settings_panel.hide()
			get_viewport().set_input_as_handled()
