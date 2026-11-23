extends SceneTree

func _init() -> void:
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	root.add_child(world)
	
	for i in range(15):
		await process_frame
		
	var space = world.get_world_2d().direct_space_state
	for test_y in [112.0, 114.0, 116.0, 118.0, 120.0, 125.0, 130.0]:
		var params = PhysicsPointQueryParameters2D.new()
		params.position = Vector2(370, test_y)
		params.collide_with_bodies = true
		params.collide_with_areas = true
		var results = space.intersect_point(params, 32)
		print("Results at (370, %f): %d" % [test_y, results.size()])
		for r in results:
			var c = r["collider"]
			print("  Collider: ", c.name, " Class: ", c.get_class(), " Parent: ", c.get_parent().name, " at: ", c.global_position)
			if c is StaticBody2D:
				for ch in c.get_children():
					if ch is CollisionShape2D:
						print("    Shape: ", ch.shape, " pos: ", ch.position)
					elif ch is CollisionPolygon2D:
						print("    Poly: ", ch.polygon)

	# Also check what x coordinates around 360..390 are blocked at y=114..120
	for test_x in [350.0, 355.0, 360.0, 365.0, 370.0, 375.0, 380.0, 385.0]:
		var params = PhysicsPointQueryParameters2D.new()
		params.position = Vector2(test_x, 116)
		params.collide_with_bodies = true
		var results = space.intersect_point(params, 16)
		if results.size() > 0:
			print("Blocked at x=%f, y=116 by %s (%s)" % [test_x, results[0]["collider"].name, results[0]["collider"].get_parent().name])
		else:
			print("FREE at x=%f, y=116" % test_x)
			
	quit(0)

