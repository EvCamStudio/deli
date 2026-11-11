## NPC Script
# NPC generik yang memulai dialog saat pemain berinteraksi.
# Dialog dimuat dari JSON sesuai level dan npc_key atau dialog_id khusus.
extends CharacterBody2D
class_name NPC

signal talked(npc_key: String)

# ─── Export ───────────────────────────────────────────────────────────────────
@export var npc_key: String = "npc_pedagang"   # Kunci di file JSON level
@export var level_id: int = 3                  # Level tempat NPC ini berada
@export var dialog_id: String = ""             # ID file khusus di data/dialog/

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
	# 1. Cek dialog_id khusus dari data/dialog/
	var target_id := dialog_id
	if target_id.is_empty():
		match npc_key:
			"npc_ibu_mc", "npc_pak_hendra": target_id = "h1_warung"
			"npc_datuk": target_id = "h1_datuk"

	if not target_id.is_empty():
		var path := "res://data/dialog/%s.json" % target_id
		if FileAccess.file_exists(path):
			var file := FileAccess.open(path, FileAccess.READ)
			if file:
				var json := JSON.new()
				if json.parse(file.get_as_text()) == OK:
					var data = json.get_data()
					if data is Array:
						_dialogue_data = data
						return
					elif data is Dictionary and data.has("dialog"):
						_dialogue_data = data["dialog"]
						return

	# 2. Muat dari file level JSON biasa
	var all_dialogues: Dictionary = DialogueManager.load_dialogue_file(level_id)
	if all_dialogues.has(npc_key):
		_dialogue_data = all_dialogues[npc_key]

func get_action_label() -> String:
	if _dialogue_data.is_empty():
		return ""
	return "Bicara"

func has_talked() -> bool:
	return _has_talked

func interact() -> void:
	if _dialogue_data.is_empty():
		return
	_in_dialogue = true
	DialogueManager.start_dialogue(_dialogue_data, npc_key)

func show_exclaim(visible_state: bool) -> void:
	if exclaim:
		exclaim.visible = visible_state

func _on_dialogue_finished() -> void:
	if not _in_dialogue:
		return
	_in_dialogue = false
	_has_talked = true
	if exclaim:
		exclaim.hide()
	talked.emit(npc_key)
