## MapBase Script — Fondasi untuk 4 Peta Deli Rewind (Dokumen Utama)
## Mengatur kamera, alur harian, deteksi ujian hujan, dan interaksi peta.
extends Node2D
class_name MapBase

@export var map_name: String = "Peta"
@export var music_track: int = 1

@onready var player: CharacterBody2D = get_node_or_null("Player") as CharacterBody2D
@onready var camera: Camera2D = get_node_or_null("Camera2D") as Camera2D
@onready var hud: CanvasLayer = get_node_or_null("HUD") as CanvasLayer
@onready var dialogue_box: CanvasLayer = get_node_or_null("DialogueBox") as CanvasLayer
@onready var touch_controls: CanvasLayer = get_node_or_null("TouchControls") as CanvasLayer

func _ready() -> void:
	add_to_group("level")
	add_to_group("map")
	if AudioManager:
		AudioManager.play_bgm(music_track)

	# Setup DialogueBox
	if dialogue_box and DialogueManager:
		DialogueManager.register_dialogue_box(dialogue_box)

	# Setup Camera smooth follow
	if camera and player:
		camera.position = player.position

	_setup_day_and_events()

func _process(_delta: float) -> void:
	if camera and player:
		camera.position = player.position

func _setup_day_and_events() -> void:
	# Cek apakah ada ujian hujan yang harus dipicu
	var cur_day: int = GameState.hari
	if cur_day == 3 and not GameState.ujian1_selesai and map_name == "Warung":
		# Tunggu sebentar lalu picu Ujian 1
		get_tree().create_timer(1.0).timeout.connect(func():
			DialogueManager.mulai("ujian1")
			GameState.ujian1_selesai = true
		)
	elif cur_day == 5 and not GameState.ujian2_selesai and map_name == "Warung":
		get_tree().create_timer(1.0).timeout.connect(func():
			DialogueManager.mulai("ujian2")
			GameState.ujian2_selesai = true
		)

func open_pause_menu() -> void:
	var pause_menu := get_node_or_null("PauseMenu")
	if pause_menu and pause_menu.has_method("open_journal"):
		pause_menu.open_journal()
	elif pause_menu and pause_menu.has_method("open_pause"):
		pause_menu.open_pause()

func set_touch_controls_visible(state: bool) -> void:
	if touch_controls:
		touch_controls.visible = state

