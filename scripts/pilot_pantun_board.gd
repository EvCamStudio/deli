## Papan pantun Melayu Deli di dekat jalan/jembatan.
extends Area2D
class_name PilotPantunBoard

@export var pantun_id: String = ""

func _ready() -> void:
	add_to_group("pantun_board")

func get_action_label() -> String:
	return "Baca Pantun"

func interact() -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("open_pantun_board"):
		level.open_pantun_board(pantun_id)
	elif level and level.has_method("open_pantun"):
		level.open_pantun()
