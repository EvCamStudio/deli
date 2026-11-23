extends Node

func _ready() -> void:
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	for i in range(25):
		await get_tree().process_frame
	var player: CharacterBody2D = world.player
	var camera: Camera2D = world.camera

	# 1. MC at wooden porch railing (x=92) - must be stopped in front of railing!
	player.global_position = Vector2(92, 180)
	camera.global_position = Vector2(92, 160)
	camera.reset_smoothing()
	for f in range(30):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	camera.global_position = player.global_position
	camera.reset_smoothing()
	for i in range(10): await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("tools/capture_railing_blocked.png")
	print("Pos at railing:", player.global_position)

	# 2. MC at open entrance deck (x=118) - steps onto porch deck to door!
	player.global_position = Vector2(118, 180)
	camera.global_position = Vector2(118, 160)
	camera.reset_smoothing()
	for f in range(30):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	camera.global_position = player.global_position
	camera.reset_smoothing()
	for i in range(10): await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("tools/capture_entrance_stepped.png")
	print("Pos at entrance:", player.global_position)

	# 3. MC at left wall (x=68) - stopped at stone foundation wall!
	player.global_position = Vector2(68, 180)
	camera.global_position = Vector2(68, 160)
	camera.reset_smoothing()
	for f in range(30):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	camera.global_position = player.global_position
	camera.reset_smoothing()
	for i in range(10): await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("tools/capture_wall_stopped.png")
	print("Pos at left wall:", player.global_position)

	# 4. MC at red house porch stairs (x=272)
	player.global_position = Vector2(272, 180)
	camera.global_position = Vector2(272, 160)
	camera.reset_smoothing()
	for f in range(30):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	camera.global_position = player.global_position
	camera.reset_smoothing()
	for i in range(10): await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("tools/capture_red_porch.png")
	print("Pos at red porch:", player.global_position)

	print("ALL CAPTURES COMPLETED")
	get_tree().quit(0)
