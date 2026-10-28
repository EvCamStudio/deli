## NPC Script
# NPC generik yang memulai dialog saat pemain berinteraksi.
# Dialog dimuat dari JSON sesuai level dan npc_key.
extends CharacterBody2D
class_name NPC

signal talked(npc_key: String)

# ─── Export ───────────────────────────────────────────────────────────────────
@export var npc_key: String = "npc_pedagang"   # Kunci di file JSON level
@export var level_id: int = 3                  # Level tempat NPC ini berada

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var sprite: CanvasItem = get_node_or_null("AnimatedSprite2D") as CanvasItem
@onready var exclaim: Label = get_node_or_null("ExclaimLabel") as Label

# ─── State ────────────────────────────────────────────────────────────────────
var _dialogue_data: Array = []
var _has_talked: bool = false
var _in_dialogue: bool = false

func _ready() -> void:
	if exclaim:
		exclaim.hide()
	_load_dialogue()
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)

func _load_dialogue() -> void:
	var all_dialogues: Dictionary = DialogueManager.load_dialogue_file(level_id)
	if all_dialogues.has(npc_key):
		_dialogue_data = all_dialogues[npc_key]

func get_action_label() -> String:
	if _dialogue_data.is_empty():
		return ""
	return "Bicara"

func interact() -> void:
	if _dialogue_data.is_empty():
		return
	_in_dialogue = true
	DialogueManager.start_dialogue(_dialogue_data)

func show_exclaim(visible_state: bool) -> void:
	exclaim.visible = visible_state

func _on_dialogue_finished() -> void:
	if not _in_dialogue:
		return
	_in_dialogue = false
	_has_talked = true
	exclaim.hide()
	talked.emit(npc_key)
