extends Node

func _ready():
	var world_scene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	for i in range(15): await get_tree().process_frame
	world.change_zone("hilir", Vector2(100, 300))
	for i in range(15): await get_tree().process_frame
	var hilir_container = world._zone_containers["hilir"]
	var topdown_map = null
	for child in hilir_container.get_children():
		if child.has_method("is_in_water"):
			topdown_map = child
			break
	var ground = topdown_map.get_node("Ground") as TileMapLayer
	var water = topdown_map.get_node("Water") as TileMapLayer
	print("=== HILIR TILES (x=10, y=14..25) ===")
	for y in range(14, 26):
		var w_sid = water.get_cell_source_id(Vector2i(10, y))
		var g_sid = ground.get_cell_source_id(Vector2i(10, y))
		var g_atlas = ground.get_cell_atlas_coords(Vector2i(10, y))
		print("y=", y, " water=", w_sid, " ground_sid=", g_sid, " ground_atlas=", g_atlas)
	get_tree().quit(0)
