extends Node

func _ready() -> void:
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(15):
		await get_tree().process_frame

	var player: CharacterBody2D = world.player
	var camera: Camera2D = player.get_node("Camera2D")

	# Capture 1: Gambar 1 User (Batas Depan Kanopi Timur)
	# Player jalan ke selatan dari atas sampai mentok dinding transparan
	player.global_position = Vector2(760, 2)
	for f in range(30):
		player.velocity = Vector2(0, 160)
		player.move_and_slide()
		await get_tree().physics_frame
	camera.align()
	camera.reset_smoothing()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("tools/verified_forest_front.png")
	print("Saved verified_forest_front.png (Gambar 1)")

	# Capture 2: Gambar 2 User (Batas Kanan Dekat Pohon Kelapa)
	# Player jalan ke barat dari sisi kanan sampai mentok dinding transparan
	player.global_position = Vector2(945, 60)
	for f in range(30):
		player.velocity = Vector2(-160, 0)
		player.move_and_slide()
		await get_tree().physics_frame
	camera.align()
	camera.reset_smoothing()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("tools/verified_forest_right.png")
	print("Saved verified_forest_right.png (Gambar 2)")

	get_tree().quit(0)
