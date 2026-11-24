extends Node

func _ready() -> void:
	print("\n=== STARTING HILIR MANGROVE & SOIL PATCH VERIFICATION ===")
	
	# 1. Load world_sungai_deli
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	assert(world_scene != null, "Failed to load world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	
	for i in range(25): await get_tree().process_frame
	
	# 2. Switch to Hilir
	print("[CHECK 1] Switching to Zone Hilir (Muara)...")
	world.change_zone("hilir", Vector2(100, 300))
	for i in range(25): await get_tree().process_frame
	
	var hilir_container: Node2D = world._zone_containers["hilir"]
	assert(hilir_container != null, "Zone Hilir container missing")
	
	# Find TopdownMap in Hilir
	var topdown_map = null
	for child in hilir_container.get_children():
		if child.has_method("is_in_water"):
			topdown_map = child
			break
	assert(topdown_map != null, "TopdownMap missing in Hilir")
	
	# 3. Verify clean ground tiles with zero missing sources
	print("[CHECK 2] Verifying clean base ground tiles in Hilir...")
	var ground: TileMapLayer = topdown_map.get_node("Ground") as TileMapLayer
	assert(ground != null, "Ground TileMapLayer missing")
	
	# Check cells: mud area (y=18..27) uses source 3, sand area (y>=28) uses source 0
	var mud_coords := [Vector2i(10, 18), Vector2i(15, 20), Vector2i(30, 21), Vector2i(35, 25), Vector2i(25, 27)]
	for c in mud_coords:
		var sid: int = ground.get_cell_source_id(c)
		print("Mud Cell", c, "source id:", sid, "atlas:", ground.get_cell_atlas_coords(c))
		assert(sid == 3, "Mangrove zone cell must use mud source 3!")

	var sand_coords := [Vector2i(35, 29), Vector2i(50, 30)]
	for c in sand_coords:
		var sid: int = ground.get_cell_source_id(c)
		print("Sand Cell", c, "source id:", sid, "atlas:", ground.get_cell_atlas_coords(c))
		assert(sid == 0, "Beach sand cell must remain clean sand source 0!")
	print("  -> PASS: Base ground Hilir memiliki tanah lumpur luas untuk mangrove dan sisa pasir pantai tetap terjaga!")
	
	# 4. Verify TreeSpots in Hilir have kind == 'mangrove' and have SoilBed from Gambar 4
	print("\n[CHECK 3] Verifying Hilir TreeSpots and Gambar 4 SoilBed...")
	var mangrove_spots: Array = []
	for child in hilir_container.get_children():
		if child.is_in_group("tree_spot"):
			mangrove_spots.append(child)
	print("Found", mangrove_spots.size(), "TreeSpots in Hilir")
	assert(mangrove_spots.size() >= 8, "Expected at least 8 mangrove TreeSpots in Hilir")
	
	var first_spot = mangrove_spots[0]
	assert(first_spot.kind == "mangrove", "Spot kind must be 'mangrove'")
	
	var soil_bed = first_spot.get_node_or_null("SoilBed") as Sprite2D
	assert(soil_bed != null, "SoilBed from Gambar 4 must exist on mangrove spot!")
	print("SoilBed texture path:", soil_bed.texture.resource_path, "scale:", soil_bed.scale)
	assert(soil_bed.texture.resource_path.contains("soil_patch_spot"), "SoilBed must use soil_patch_spot texture!")
	
	var seedling_sprite: Sprite2D = first_spot.get_node("Seedling") as Sprite2D
	assert(seedling_sprite != null, "Seedling sprite missing")
	print("Seedling texture path:", seedling_sprite.texture.resource_path)
	
	# Test planting the spot
	print("Planting mangrove spot...")
	first_spot._apply_stage(TreeSpotTopDown.Stage.SEEDLING, false)
	assert(seedling_sprite.visible == true, "Seedling must be visible after planting")
	assert(soil_bed.visible == true, "SoilBed must remain visible under the planted sapling!")
	print("  -> PASS: Titik tanam memiliki alas tanah alami Gambar 4 dan bibit mangrove Gambar 4!")
	
	# 5. Verify mature mangrove trees in Hilir with soil base
	print("\n[CHECK 4] Verifying mature mangrove trees with Gambar 4 soil bases...")
	var mature_mangroves: int = 0
	for child in hilir_container.get_children():
		if child is StaticBody2D:
			for grand in child.get_children():
				if grand is Sprite2D and grand.texture != null:
					var path: String = grand.texture.resource_path
					if path.contains("mangrove_tree_mature"):
						mature_mangroves += 1
						# Check that it has a soil base
						var has_soil := false
						for sibling in child.get_children():
							if sibling is Sprite2D and sibling.texture != null and sibling.texture.resource_path.contains("soil_patch_tree"):
								has_soil = true
								break
						assert(has_soil, "Mature mangrove tree must have a soil_patch_tree base from Gambar 4!")
	print("Total mature mangrove trees found in Hilir:", mature_mangroves)
	assert(mature_mangroves >= 4, "Expected at least 4 mature mangrove trees in Hilir")
	print("  -> PASS: Pohon bakau dewasa tertanam di atas alas tanah alami Gambar 4!")
	
	# 6. Verify organic soil decor patches
	print("\n[CHECK 5] Verifying organic soil decor patches from Gambar 4...")
	var soil_patches: int = 0
	for child in hilir_container.get_children():
		if child is Sprite2D and child.texture != null:
			if child.texture.resource_path.contains("soil_patch_decor"):
				soil_patches += 1
				print("Found soil decor patch at:", child.position, "texture:", child.texture.resource_path.get_file())
	print("Total soil decor patches found:", soil_patches)
	assert(soil_patches >= 5, "Expected at least 5 soil decor patches across the coast")
	print("  -> PASS: Hamparan tanah organik dari Gambar 4 tersebar rapi di pesisir Hilir!")
	
	# 7. Verify coconut trees south of river moved to sand
	print("\n[CHECK 6] Verifying coconut palms moved to beach sand...")
	var south_kelapa: int = 0
	for child in hilir_container.get_children():
		if child is StaticBody2D:
			for grand in child.get_children():
				if grand is Sprite2D and grand.texture != null and grand.texture.resource_path.contains("tree_tall_kelapa"):
					if child.position.y > 200.0:
						south_kelapa += 1
						print("Found south kelapa tree at:", child.position)
						assert(child.position.y >= 450.0, "Coconut palm must be on beach sand (y >= 450), not on mud! Got y=%.1f" % child.position.y)
	assert(south_kelapa >= 4, "Expected 4 coconut palms on beach sand")
	print("  -> PASS: Semua pohon kelapa di selatan telah dipindahkan ke sisa pantai pasir (y >= 450)!")

	# 8. Verify mangrove spots are neatly aligned in rows (4x2 grid)
	print("\n[CHECK 7] Verifying 8 mangrove spots are neatly lined up in rows (like Hulu)...")
	var world_script = load("res://scripts/world_sungai_deli.gd")
	var spots: Array[Vector2i] = world_script.HILIR_MANGROVE_SPOTS
	assert(spots.size() == 8, "Expected exactly 8 mangrove spots!")
	var row1_spots: Array[Vector2i] = []
	var row2_spots: Array[Vector2i] = []
	for s in spots:
		if s.y == 19:
			row1_spots.append(s)
		elif s.y == 21:
			row2_spots.append(s)
		else:
			assert(false, "Spots must be neatly arranged on row 19 and row 21! Got y=%d" % s.y)
	assert(row1_spots.size() == 4, "Row 1 must have 4 spots")
	assert(row2_spots.size() == 4, "Row 2 must have 4 spots")
	for i in range(4):
		assert(row1_spots[i].x == row2_spots[i].x, "Row 1 and Row 2 must have aligned columns!")
	print("  -> PASS: 8 titik tanam mangrove tersusun rapi berjejer dalam 2 baris sejajar (4x2 grid)!")

	print("\n=== ALL HILIR MANGROVE & SOIL VERIFICATIONS PASSED 100% SUCCESSFULLY! ===")
	get_tree().quit(0)
