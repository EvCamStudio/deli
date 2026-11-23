extends Node

func _ready() -> void:
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(15):
		await get_tree().process_frame

	var player: CharacterBody2D = world.player

	# Walk north from reboisasi clearing (y=100) towards forest
	player.global_position = Vector2(760, 100)
	for f in range(30):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final y at x=760 walking north from clearing:", player.global_position.y)

	player.global_position = Vector2(850, 100)
	for f in range(30):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final y at x=850 walking north from clearing:", player.global_position.y)

	get_tree().quit(0)
