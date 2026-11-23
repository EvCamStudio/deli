extends Node

func _ready() -> void:
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	for i in range(20):
		await get_tree().process_frame
	var player: CharacterBody2D = world.player
	var camera: Camera2D = world.camera

	# 1. MC at house_cozy_red porch
	player.global_position = Vector2(295, 185)
	camera.reset_smoothing()
	for f in range(30):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	camera.reset_smoothing()
	for i in range(10): await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("tools/capture_porch_red.png")

	# 2. MC at house_mc porch
	player.global_position = Vector2(112, 185)
	camera.reset_smoothing()
	for f in range(30):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	camera.reset_smoothing()
	for i in range(10): await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("tools/capture_porch_mc.png")

	# 3. MC at bush between houses
	player.global_position = Vector2(188, 160)
	camera.reset_smoothing()
	for f in range(30):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	camera.reset_smoothing()
	for i in range(10): await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("tools/capture_bush_yard.png")

	print("CAPTURES DONE WITH PLAYER")
	get_tree().quit(0)
