## Papan pantun Melayu Deli di dekat jembatan.
extends Area2D
class_name PilotPantunBoard

func get_action_label() -> String:
	return "Baca Pantun"

func interact() -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("open_pantun"):
		level.open_pantun()
