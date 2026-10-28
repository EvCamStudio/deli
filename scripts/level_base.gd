## LevelBase Script
# Base script untuk semua scene level.
# Mengelola: init, checkpoint, pause menu, level selesai.
extends Node2D
class_name LevelBase

# ─── Export ───────────────────────────────────────────────────────────────────
@export var level_id: int = 1
@export var river_health_target: float = 40.0
@export var bgm_key: Variant = 1  # Key untuk AudioManager
@export var camera_topdown: bool = false
@export var auto_advance: bool = true

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var hud: CanvasLayer = get_node_or_null("HUD") as CanvasLayer
@onready var dialogue_box: CanvasLayer = get_node_or_null("DialogueBox") as CanvasLayer
@onready var touch_controls: CanvasLayer = get_node_or_null("TouchControls") as CanvasLayer
@onready var pause_menu: CanvasLayer = get_node_or_null("PauseMenu") as CanvasLayer
@onready var card_popup: Node = get_node_or_null("KnowledgeCardPopup")
@onready var camera: Camera2D = get_node_or_null("Camera2D") as Camera2D

var _player: Node2D = null

func _ready() -> void:
	add_to_group("level")
	add_to_group("pause_menu")

	_player = get_node_or_null("Player") as Node2D

	AudioManager.play_bgm(bgm_key)

	# Sambungkan sinyal GameState
	GameState.level_completed.connect(_on_level_completed)

	# Inisialisasi meta inventaris
	GameState.set_meta("pending_trash", [])

	# Sembunyikan kontrol sentuh saat berdialog agar layar tidak penuh.
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)

	# Update misi HUD
	_set_initial_mission()

func _process(_delta: float) -> void:
	if camera and _player:
		if camera_topdown:
			camera.global_position = _player.global_position + Vector2(0, -12)
		else:
			camera.global_position.x = _player.global_position.x
			camera.global_position.y = 135.0

func _set_initial_mission() -> void:
	# Override di subclass atau tetapkan lewat inspector
	pass

func _on_dialogue_started() -> void:
	set_touch_controls_visible(false)

func _on_dialogue_finished() -> void:
	set_touch_controls_visible(true)

## Dipakai juga oleh panel pantun dan layar selesai.
func set_touch_controls_visible(state: bool) -> void:
	if touch_controls:
		touch_controls.visible = state

## Dipanggil dari HUD pause button atau Back
func open_pause_menu() -> void:
	if pause_menu and pause_menu.has_method("open"):
		pause_menu.open()

func toggle_pause() -> void:
	if pause_menu:
		if pause_menu.is_open():
			pause_menu.close()
		else:
			pause_menu.open()

## Tampilkan pesan singkat di HUD baru (fallback: mission text).
func toast(text: String, good: bool = true) -> void:
	if hud and hud.has_method("show_toast"):
		hud.show_toast(text, good)
	elif hud and hud.has_method("update_mission"):
		hud.update_mission(text)

## Dipanggil oleh LevelGate saat pemain mencapai gerbang akhir.
func try_complete_level() -> void:
	if GameState.river_health >= river_health_target:
		GameState.complete_level(level_id)
	else:
		# Tampilkan pesan "sungai belum cukup bersih"
		if hud and hud.has_method("update_mission"):
			hud.update_mission("Bersihkan lebih banyak sampah dulu!")

func _on_level_completed(completed_id: int) -> void:
	if completed_id == level_id:
		AudioManager.play_sfx("level_done")
		if not auto_advance:
			return
		# Tunggu sebentar lalu pindah ke level berikutnya
		await get_tree().create_timer(1.5).timeout
		if level_id < 5:
			SceneManager.change_level(level_id + 1)
		else:
			SceneManager.change_scene("res://scenes/levels/level_5_epilog.tscn")
