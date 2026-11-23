extends Node

func _ready() -> void:
	print("\n=== TESTING RIVERBANK PASSABILITY & FOREST BOUNDARIES ===")
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	
	for i in range(15):
		await get_tree().process_frame
		
	var player: CharacterBody2D = world.player
	var camera = world.camera

	# Test 1: Verify walking south along the riverbank path (x=360, y=40 down to y=200)
	print("[TEST 1] Testing riverbank walking south past the previous bush spot (x=360, y=40 -> y=200)...")
	player.global_position = Vector2(360, 40)
	for f in range(60):
		player.velocity = Vector2(0, 160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final position after walking south on riverbank:", player.global_position)
	assert(player.global_position.y >= 180.0, "Player must be able to walk south along the riverbank! Got y=%f" % player.global_position.y)
	print("  -> PASSED: Player walked freely south along the riverbank (y=%.1f >= 180.0)" % player.global_position.y)

	# Test 2: Verify walking north along riverbank from y=200 up to y=40
	print("[TEST 2] Testing riverbank walking north (x=360, y=200 -> y=40)...")
	player.global_position = Vector2(360, 200)
	for f in range(60):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final position after walking north on riverbank:", player.global_position)
	assert(player.global_position.y <= 50.0, "Player must be able to walk north along the riverbank! Got y=%f" % player.global_position.y)
	print("  -> PASSED: Player walked freely north along the riverbank (y=%.1f <= 50.0)" % player.global_position.y)

	# Test 3: Verify walking south along riverbank down to y=380 (riverbank trash area)
	print("[TEST 3] Testing riverbank walking south towards southern riverbank (x=370, y=260 -> y=380)...")
	player.global_position = Vector2(370, 260)
	for f in range(50):
		player.velocity = Vector2(0, 160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final position after walking south towards riverbank trash:", player.global_position)
	assert(player.global_position.y >= 350.0, "Player must be able to walk south along the riverbank! Got y=%f" % player.global_position.y)
	print("  -> PASSED: Player walked freely south along the riverbank (y=%.1f >= 350.0)" % player.global_position.y)

	# Test 4: Verify north forest remains blocked behind houses
	print("[TEST 4] Testing north of MC house (x=50, y=150 trying to walk north)...")
	player.global_position = Vector2(50, 150)
	for f in range(30):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final position north of MC house:", player.global_position)
	assert(player.global_position.y >= 105.0, "Player must NOT enter north forest! Got y=%f" % player.global_position.y)
	print("  -> PASSED: North forest remains protected (y=%.1f >= 105.0)" % player.global_position.y)

	# Test 5: Verify player cannot enter deep forest from riverbank (x=360, y=50 trying to walk west)
	print("[TEST 5] Testing walking west from riverbank into deep forest (x=360, y=50 trying to walk west)...")
	player.global_position = Vector2(360, 50)
	for f in range(30):
		player.velocity = Vector2(-160, 0)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final position after trying to walk west into deep forest:", player.global_position)
	assert(player.global_position.x >= 335.0, "Player must NOT enter deep forest from riverbank! Got x=%f" % player.global_position.x)
	print("  -> PASSED: Deep forest protected by barrier (x=%.1f >= 335.0)" % player.global_position.x)

	# Capture: The exact view from user image
	if DisplayServer.get_name() != "headless":
		player.global_position = Vector2(360, 120)
		if camera:
			camera.global_position = Vector2(360, 140)
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img = get_viewport().get_texture().get_image()
		img.save_png("tools/capture_riverbank_cleared.png")
		print("Saved tools/capture_riverbank_cleared.png")

	print("\n=== ALL RIVERBANK AND FOREST TESTS COMPLETED SUCCESSFULLY ===")
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0)
