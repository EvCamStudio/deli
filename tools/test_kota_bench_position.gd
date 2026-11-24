extends Node

func _ready() -> void:
	print("\n=== VERIFYING BENCH POSITIONS IN KOTA MEDAN & HILIR ===")

	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(25):
		await get_tree().process_frame

	world.change_zone("kota", Vector2(560, 205))
	for i in range(25):
		await get_tree().process_frame

	var kota_container = world._zone_containers["kota"]
	var kota_origin: Vector2 = kota_container.global_position

	# Check bench nodes in kota
	var found_benches: Array[Vector2] = []
	for child in kota_container.get_children():
		if child is StaticBody2D:
			for grand in child.get_children():
				if grand is Sprite2D and grand.texture != null and grand.texture.resource_path.ends_with("bench.png"):
					found_benches.append(child.position)

	print("Found benches in Kota Medan:", found_benches)
	# Check the 2 benches on the sidewalk near road (around x: 600..660)
	var sidewalk_benches: Array[Vector2] = []
	for pos in found_benches:
		if pos.x >= 600.0 and pos.x <= 660.0:
			sidewalk_benches.append(pos)

	print("Sidewalk benches near road:", sidewalk_benches)
	assert(sidewalk_benches.size() == 2, "Must find exactly 2 sidewalk benches near road in Kota Medan!")
	for b in sidewalk_benches:
		assert(b.y >= 204.0, "Bench Y (%.2f) must be >= 204.0 (safely moved back from road curb y=192/194)!" % b.y)
		assert(b.y <= 210.0, "Bench Y (%.2f) must leave walking room on sidewalk before canal (y=224)!" % b.y)
		var top_of_sprite: float = b.y - 12.0
		var margin_from_curb: float = top_of_sprite - 192.0
		print("  -> Bench at (%.1f, %.1f): top of backrest is at y=%.1f (margin from road curb = +%.1f px)" % [b.x, b.y, top_of_sprite, margin_from_curb])
		assert(margin_from_curb >= 1.0, "Bench backrest must be completely behind the road curb line!")

	# Check player walkability along sidewalk in front of benches (y = 216)
	var player = world.player
	player.global_position = kota_origin + Vector2(560, 216)
	var initial_x = player.global_position.x
	for step in range(80):
		player.velocity = Vector2(160, 0)
		player.move_and_slide()
		await get_tree().physics_frame

	var walked_dist = player.global_position.x - initial_x
	print("Player walked eastward on sidewalk in front of benches: %.1f px (final X: %.1f)" % [walked_dist, player.global_position.x - kota_origin.x])
	assert(walked_dist > 130.0, "Player must be able to freely walk along the sidewalk past both benches! Walked: %.1f" % walked_dist)

	print("\n>>> ALL BENCH POSITION CHECKS PASSED SUCCESSFULLY! <<<\n")
	get_tree().quit(0)
