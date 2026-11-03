## Papan pantun Melayu Deli di dekat jembatan.
extends Area2D
class_name PilotPantunBoard

func get_action_label() -> String:
	return "Baca Pantun"

func interact() -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("open_pantun"):
		level.open_pantun()
		return

	var pantun = get_tree().root.find_child("PantunMinigame", true, false)
	if pantun and pantun.has_method("start_minigame"):
		pantun.start_minigame()
	else:
		var p_res = load("res://scenes/minigames/pantun_minigame.tscn")
		if p_res:
			var instance = p_res.instantiate()
			get_tree().root.add_child(instance)
			if instance.has_method("start_minigame"):
				instance.start_minigame()
