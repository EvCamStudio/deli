extends Node

func _ready() -> void:
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(15):
		await get_tree().process_frame

	var player: CharacterBody2D = world.player

	# Walk south between trees at x=740
	player.global_position = Vector2(740, 2)
	for f in range(30):
		player.velocity = Vector2(0, 160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final y at x=740 walking south:", player.global_position.y)

	# Walk south between trees at x=780
	player.global_position = Vector2(780, 2)
	for f in range(30):
		player.velocity = Vector2(0, 160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final y at x=780 walking south:", player.global_position.y)

	# Walk south between trees at x=820
	player.global_position = Vector2(820, 2)
	for f in range(30):
		player.velocity = Vector2(0, 160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final y at x=820 walking south:", player.global_position.y)

	# Walk south between trees at x=860
	player.global_position = Vector2(860, 2)
	for f in range(30):
		player.velocity = Vector2(0, 160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final y at x=860 walking south:", player.global_position.y)

	get_tree().quit(0)
