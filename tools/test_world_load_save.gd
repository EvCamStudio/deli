extends Node

func _ready() -> void:
	print("\n=== TESTING FULL WORLD LOAD WITH SAVE ===")
	GameState.load_game()
	print("Loaded save! Zone: ", GameState.saved_zone, " Pos: ", GameState.saved_player_x, GameState.saved_player_y)
	var err = get_tree().change_scene_to_file("res://scenes/world/world_sungai_deli.tscn")
	print("change_scene_to_file returned: ", err)

