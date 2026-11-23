extends Node

func _ready() -> void:
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(15):
		await get_tree().process_frame

	var player: CharacterBody2D = world.player

	# Add the proposed new collider for testing:
	var body := StaticBody2D.new()
	body.position = Vector2(926, 120)
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := RectangleShape2D.new()
	shape.size = Vector2(16, 180)
	var col := CollisionShape2D.new()
	col.shape = shape
	body.add_child(col)
	world.add_child(body)

	await get_tree().physics_frame
	await get_tree().physics_frame

	# Test 1: Dari x=945, y=60 (Gambar 2 User) jalan ke barat (kiri) menuju pohon kelapa
	player.global_position = Vector2(945, 60)
	for f in range(30):
		player.velocity = Vector2(-160, 0)
		player.move_and_slide()
		await get_tree().physics_frame
	print("TEST 1: Player final x at y=60 walking west:", player.global_position.x)

	# Test 2: Dari x=945, y=100 jalan ke barat (kiri)
	player.global_position = Vector2(945, 100)
	for f in range(30):
		player.velocity = Vector2(-160, 0)
		player.move_and_slide()
		await get_tree().physics_frame
	print("TEST 2: Player final x at y=100 walking west:", player.global_position.x)

	# Test 3: Dari x=945, y=140 jalan ke barat (kiri)
	player.global_position = Vector2(945, 140)
	for f in range(30):
		player.velocity = Vector2(-160, 0)
		player.move_and_slide()
		await get_tree().physics_frame
	print("TEST 3: Player final x at y=140 walking west:", player.global_position.x)

	# Test 4: Dari x=945, y=180 jalan ke barat (kiri)
	player.global_position = Vector2(945, 180)
	for f in range(30):
		player.velocity = Vector2(-160, 0)
		player.move_and_slide()
		await get_tree().physics_frame
	print("TEST 4: Player final x at y=180 walking west:", player.global_position.x)

	# Test 5: Gambar 1 User: Dari y=2, x=760 jalan ke selatan (bawah) menuju kanopi
	player.global_position = Vector2(760, 2)
	for f in range(30):
		player.velocity = Vector2(0, 160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("TEST 5: Player final y at x=760 walking south:", player.global_position.y)

	get_tree().quit(0)
