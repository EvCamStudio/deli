extends Node

func _ready() -> void:
	print("\n=== TESTING HULU FOREST BOUNDARIES AND CAPTURING VIEWS ===")
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	
	for i in range(15):
		await get_tree().process_frame
		
	var player: CharacterBody2D = world.player
	var camera = world.camera
	
	# Test 1: Verify player cannot walk through gap between houses into north forest
	print("[TEST 1] Testing gap between MC house (x=112) and Red house (x=272)...")
	player.global_position = Vector2(188, 170)
	for f in range(30):
		player.velocity = Vector2(0, -150)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final position after trying to walk north through gap:", player.global_position)
	assert(player.global_position.y >= 105.0, "Player must NOT be able to walk north into forest through gap! Got y=%f" % player.global_position.y)
	print("  -> PASSED: Player blocked at y=%.1f >= 105.0" % player.global_position.y)

	# Test 2: Verify player cannot walk north behind MC house
	print("[TEST 2] Testing north of MC house (x=60)...")
	player.global_position = Vector2(50, 150)
	for f in range(30):
		player.velocity = Vector2(0, -150)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final position after trying to walk north west of MC house:", player.global_position)
	assert(player.global_position.y >= 105.0, "Player must NOT be able to walk north of MC house! Got y=%f" % player.global_position.y)
	print("  -> PASSED: Player blocked at y=%.1f >= 105.0" % player.global_position.y)

	# Test 3: Verify player cannot walk south into south forest
	print("[TEST 3] Testing south forest barrier (x=150, trying to walk south)...")
	player.global_position = Vector2(150, 320)
	for f in range(30):
		player.velocity = Vector2(0, 150)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final position after trying to walk south into forest:", player.global_position)
	assert(player.global_position.y <= 360.0, "Player must NOT be able to enter south forest! Got y=%f" % player.global_position.y)
	print("  -> PASSED: Player blocked at y=%.1f <= 360.0" % player.global_position.y)

	# Test 4: Verify player CAN walk freely along the path to the bridge
	print("[TEST 4] Testing path to bridge (x=150 to x=420 along y=240)...")
	player.global_position = Vector2(150, 240)
	for f in range(40):
		player.velocity = Vector2(150, 0)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final position along path to bridge:", player.global_position)
	assert(player.global_position.x > 220.0, "Player must be able to walk along the main road to the bridge! Got x=%f" % player.global_position.x)
	print("  -> PASSED: Player walks freely along main road to bridge (x=%.1f)" % player.global_position.x)

	# Capture 1: Houses and dense northern forest behind them
	player.global_position = Vector2(188, 180)
	if camera:
		camera.global_position = Vector2(192, 130)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("tools/capture_hulu_houses_and_north_forest.png")
	print("Saved tools/capture_hulu_houses_and_north_forest.png")

	# Capture 2: Padang rumput selatan and dense southern forest wall
	player.global_position = Vector2(188, 300)
	if camera:
		camera.global_position = Vector2(192, 360)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("tools/capture_hulu_south_forest.png")
	print("Saved tools/capture_hulu_south_forest.png")

	# Capture 3: East Hulu reboisasi area
	player.global_position = Vector2(720, 176)
	if camera:
		camera.global_position = Vector2(740, 150)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img3 = get_viewport().get_texture().get_image()
	img3.save_png("tools/capture_hulu_reboisasi_east.png")
	print("Saved tools/capture_hulu_reboisasi_east.png")

	print("\n=== ALL HULU FOREST TESTS AND CAPTURES COMPLETED SUCCESSFULLY ===")
	get_tree().quit(0)

