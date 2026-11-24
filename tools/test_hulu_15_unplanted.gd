extends Node

func _ready() -> void:
	print("--- HULU 15 UNPLANTED SPOTS VERIFICATION ---")
	GameState.reset()
	GameState.load_game()
	
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	
	for i in range(25):
		await get_tree().process_frame
	
	# Find all tree spots in Hulu
	var spots: Array[Node] = []
	for node in get_tree().get_nodes_in_group("tree_spot"):
		if node is TreeSpotTopDown and node.kind == "tree":
			spots.append(node)
	
	print("Total tree spots found in Hulu:", spots.size())
	assert(spots.size() == 15, "Expected 15 tree spots in Hulu, got %d" % spots.size())
	
	var unplanted_count := 0
	var planted_count := 0
	for i in range(spots.size()):
		var s: TreeSpotTopDown = spots[i]
		if s.is_planted():
			planted_count += 1
			print("Spot %s is PLANTED (Error!)" % s.spot_id)
		else:
			unplanted_count += 1
			assert(s.marker.visible, "Spot marker should be visible!")
			assert(not s.planted_sprite.visible, "Planted tree sprite should NOT be visible!")
			assert(not s.seedling_sprite.visible, "Seedling sprite should NOT be visible!")
	
	print("Unplanted spots (white rings):", unplanted_count)
	print("Planted spots (mature trees):", planted_count)
	assert(unplanted_count == 15, "Expected all 15 spots to be unplanted!")
	assert(planted_count == 0, "Expected 0 mature trees!")
	
	# Position player and camera at Hulu forest spots (46 * 16 = 736, 9 * 16 = 144)
	if world.player:
		world.player.global_position = Vector2(736, 144)
	if world.camera:
		world.camera.global_position = Vector2(736, 144)
		world.camera.reset_smoothing()
	
	for i in range(15):
		await get_tree().process_frame
	
	# Test planting 1 tree spot
	var first_spot: TreeSpotTopDown = spots[0]
	GameState.start_quest("tanam_pohon_hulu", 15)
	first_spot.interact()
	assert(first_spot.is_planted(), "First spot should now be planted!")
	assert(GameState.zone_stat("hulu", "trees") == 1, "Zone progress trees should be 1!")
	print("SUCCESS: All 15 spots in Hulu are unplanted circles! Planting mechanic works 100%!")
	
	get_tree().quit(0)
