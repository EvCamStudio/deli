extends Node

func _ready() -> void:
	print("\n=== VERIFYING REMOVAL OF 7 ITEMS REQUESTED BY USER ===")
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(25): await get_tree().process_frame

	# 1. CHECK KOTA MEDAN
	print("\n[CHECK 1] Verifying Kota Medan removals...")
	world.change_zone("kota", Vector2(560, 205))
	for i in range(25): await get_tree().process_frame

	var kota = world._zone_containers["kota"]
	var kota_props: Array[Dictionary] = []
	var kota_trees: int = 0

	for child in kota.get_children():
		if child is StaticBody2D:
			for grand in child.get_children():
				if grand is Sprite2D and grand.texture != null:
					var p: String = grand.texture.resource_path
					if p.contains("prop_") or p.contains("tree_"):
						kota_props.append({"path": p.get_file(), "pos": child.position})
					if p.contains("tree_"):
						kota_trees += 1

	print("Found props in Kota Medan:", kota_props)

	# Verify Image 1 items gone: (50, 114) and (200, 114)
	for item in kota_props:
		if item["path"] == "prop_trash_bags_blue_white.png" and item["pos"].is_equal_approx(Vector2(50, 114)):
			assert(false, "Image 1 prop_trash_bags_blue_white at (50, 114) must be removed!")
		if item["path"] == "prop_trash_bags_black.png" and item["pos"].is_equal_approx(Vector2(200, 114)):
			assert(false, "Image 1 prop_trash_bags_black at (200, 114) must be removed!")

	# Verify Image 3 & 4 trees gone from Kota Medan
	print("Kota Medan trees count:", kota_trees)
	assert(kota_trees == 0, "All trees in Kota Medan (Image 3 & 4) must be removed!")

	# Verify Image 5 wheelie bins gone: (460, 194) and (475, 194)
	for item in kota_props:
		if item["path"] == "prop_wheelie_bin_green.png":
			assert(false, "Image 5 wheelie bin green must be removed!")
		if item["path"] == "prop_wheelie_bin_blue.png":
			assert(false, "Image 5 wheelie bin blue must be removed!")

	print("  -> PASS: Semua item di Kota Medan (Gambar 1, 3, 4, 5) terhapus bersih!")

	# 2. CHECK HULU
	print("\n[CHECK 2] Verifying Hulu removals...")
	world.change_zone("hulu", Vector2(112, 160))
	for i in range(25): await get_tree().process_frame

	var hulu = world._zone_containers["hulu"]
	var hulu_props: Array[Dictionary] = []

	for child in hulu.get_children():
		if child is StaticBody2D:
			for grand in child.get_children():
				if grand is Sprite2D and grand.texture != null:
					var p: String = grand.texture.resource_path
					if p.contains("prop_trash_bags"):
						hulu_props.append({"path": p.get_file(), "pos": child.position})

	print("Found trash bag props in Hulu:", hulu_props)

	# Verify Image 2: (45, 175)
	for item in hulu_props:
		if item["pos"].is_equal_approx(Vector2(45, 175)):
			assert(false, "Image 2 trash bags at MC porch (45, 175) must be removed!")

	# Verify Image 6: (635, 290)
	for item in hulu_props:
		if item["pos"].is_equal_approx(Vector2(635, 290)):
			assert(false, "Image 6 trash bags at south meadow (635, 290) must be removed!")

	# Verify Image 7: (290, 235)
	for item in hulu_props:
		if item["pos"].is_equal_approx(Vector2(290, 235)):
			assert(false, "Image 7 trash bags at Papan Pantun / bridge path (290, 235) must be removed!")

	print("  -> PASS: Semua sampah di Hulu (Gambar 2, 6, 7) terhapus bersih!")

	# 3. VERIFY ESSENTIAL GAMEPLAY IS INTACT
	print("\n[CHECK 3] Verifying core gameplay objects are intact...")
	# Verify Papan Pantun exists
	var pantun_boards = get_tree().get_nodes_in_group("pantun_board")
	print("Pantun boards count:", pantun_boards.size())
	assert(pantun_boards.size() >= 5, "Pantun boards must not be deleted!")

	# Verify NPCs exist
	var npcs = get_tree().get_nodes_in_group("world_npc")
	print("World NPCs count:", npcs.size())
	assert(npcs.size() >= 8, "NPCs must not be deleted!")

	# Verify Bins exist
	var bins = get_tree().get_nodes_in_group("world_bin")
	print("World Bins count:", bins.size())
	assert(bins.size() >= 8, "Bins must not be deleted!")

	print("  -> PASS: Seluruh elemen gameplay, NPC, dan papan pantun tetap utuh dan aman!")

	print("\n>>> ALL 7 USER REMOVAL REQUESTS VERIFIED 100% SUCCESSFULLY! <<<\n")
	get_tree().quit(0)
