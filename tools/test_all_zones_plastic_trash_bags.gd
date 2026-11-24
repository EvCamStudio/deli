extends Node

func _ready() -> void:
	print("\n=== VERIFYING PLASTIC TRASH BAGS ACROSS ALL ZONES & ZERO BIN OVERLAP ===")

	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(25): await get_tree().process_frame

	var bin_positions_by_zone: Dictionary = {
		"hulu": [Vector2(168, 184), Vector2(376, 192), Vector2(560, 192)],
		"desa": [Vector2(520, 392), Vector2(320, 392)],
		"kota": [Vector2(272, 80), Vector2(208, 352), Vector2(400, 208), Vector2(784, 208)],
		"hilir": [Vector2(163.2, 80), Vector2(803.2, 80), Vector2(304, 208)]
	}

	for zone in ["hulu", "desa", "kota", "hilir"]:
		print("\n--- CHECKING ZONE: %s ---" % zone.to_upper())
		world.change_zone(zone, Vector2(100, 200))
		for i in range(25): await get_tree().process_frame

		var container = world._zone_containers[zone]
		var found_bags_black := 0
		var found_bags_color := 0
		var prop_positions: Array[Vector2] = []

		for child in container.get_children():
			var tex_name := ""
			var pos: Vector2 = child.position
			if child is Sprite2D and child.texture != null:
				tex_name = child.texture.resource_path.get_file()
			elif child is StaticBody2D:
				for grand in child.get_children():
					if grand is Sprite2D and grand.texture != null:
						tex_name = grand.texture.resource_path.get_file()
						break
			if tex_name == "prop_trash_bags_black.png":
				found_bags_black += 1
				prop_positions.append(pos)
			elif tex_name == "prop_trash_bags_blue_white.png":
				found_bags_color += 1
				prop_positions.append(pos)

		print("[%s] Found Black Trash Bags: %d, Color (Blue/White) Trash Bags: %d" % [zone, found_bags_black, found_bags_color])
		assert(found_bags_black > 0, "Zone %s must have black trash bags!" % zone)
		assert(found_bags_color > 0, "Zone %s must have blue/white trash bags!" % zone)

		# CRITICAL CHECK: Distance from EVERY sorting bin in this zone must be >= 50px!
		var bins: Array = bin_positions_by_zone[zone]
		for p_pos in prop_positions:
			for b_pos in bins:
				var dist: float = p_pos.distance_to(b_pos)
				assert(dist >= 50.0, "OVERLAP DETECTED in %s! Trash bag at %s is too close to bin at %s (dist=%.1f px, must be >= 50px)!" % [zone, p_pos, b_pos, dist])

		print("  -> PASS: Semua kantong sampah di %s berjarak aman (>= 50px) dari SEMUA tong sampah pilah!" % zone)

	print("\n>>> ALL 4 ZONES VERIFIED: PLASTIC TRASH BAGS INTEGRATED & ZERO BIN OVERLAP! <<<\n")
	get_tree().quit(0)

