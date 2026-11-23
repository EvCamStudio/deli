extends Node

func _ready() -> void:
	print("\n=== TESTING FLORA & BUSH SOLID COLLISION ===")
	
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	
	for i in range(10):
		await get_tree().process_frame
		
	var zone_hulu: Node2D = world.get_node_or_null("ZoneHulu") as Node2D
	assert(zone_hulu != null, "ZoneHulu must exist")
	
	# Find flora bodies
	var flora_bodies: Array = []
	for child in zone_hulu.get_children():
		if child is StaticBody2D:
			for sub in child.get_children():
				if sub is Sprite2D and sub.texture:
					var p: String = sub.texture.resource_path
					if "bush_" in p or "flora_" in p or "prop_" in p:
						flora_bodies.append(child)
						break
						
	print("Found %d flora/bush StaticBody2D instances in ZoneHulu!" % flora_bodies.size())
	assert(flora_bodies.size() > 0, "Flora bodies must be created as StaticBody2D!")
	
	# Verify each flora body has collision shape and correct layer
	for body in flora_bodies:
		assert(body.collision_layer == 1, "Flora must have collision_layer = 1")
		var has_col := false
		for sub in body.get_children():
			if sub is CollisionShape2D and sub.shape != null:
				has_col = true
				break
		assert(has_col, "Flora StaticBody2D must have a CollisionShape2D!")
		
	print("PASS: All flora instances have valid StaticBody2D and CollisionShape2D on layer 1.")
	
	# TEST 2: Move player towards bush at (195, 185)
	# Bush at (195, 185) is bush_flowering_white.png (the exact one from user screenshot)
	var player = world.player
	player.global_position = Vector2(195, 160) # Place player right above the bush
	await get_tree().process_frame
	
	# Try moving downward (into the bush) for several frames
	for i in range(30):
		player.velocity = Vector2(0, 100)
		player.move_and_slide()
		await get_tree().physics_frame
		
	print("Player position after attempting to walk through bush: ", player.global_position)
	# Since bush is at y=185 with collision height ~10px, player feet should be blocked around y <= 180
	assert(player.global_position.y < 185.0, "Player must NOT pass through the bush!")
	print("PASS: Player collision physically stopped player from walking through bush! (y=%f < 185)" % player.global_position.y)
	
	# Capture in-game screenshot showing player blocked cleanly by the bush
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png("tools/capture_bush_collision.png")
	print("Saved capture: tools/capture_bush_collision.png")
	
	print("\n===========================================")
	print("ALL FLORA COLLISION TESTS PASSED PERFECTLY!")
	print("===========================================")
	get_tree().quit(0)

