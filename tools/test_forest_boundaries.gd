extends Node

func _ready() -> void:
	print("\n=== TESTING FOREST COLLISION BARRIERS (FRONT & RIGHT) ===")
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(15):
		await get_tree().process_frame

	var player: CharacterBody2D = world.player

	# TEST 1: Dari y=2 jalan ke selatan masuk ke hutan
	player.global_position = Vector2(760, 2)
	for f in range(30):
		player.velocity = Vector2(0, 160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final y starting from y=2 walking south:", player.global_position.y)

	# TEST 2: Dari x=940, y=60 jalan ke barat (ke kiri)
	player.global_position = Vector2(940, 60)
	for f in range(30):
		player.velocity = Vector2(-160, 0)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final x starting from x=940, y=60 walking west:", player.global_position.x)

	# TEST 3: Dari x=940, y=100 jalan ke barat (ke kiri)
	player.global_position = Vector2(940, 100)
	for f in range(30):
		player.velocity = Vector2(-160, 0)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final x starting from x=940, y=100 walking west:", player.global_position.x)

	# TEST 4: Dari x=940, y=140 jalan ke barat (ke kiri)
	player.global_position = Vector2(940, 140)
	for f in range(30):
		player.velocity = Vector2(-160, 0)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final x starting from x=940, y=140 walking west:", player.global_position.x)

	get_tree().quit(0)
