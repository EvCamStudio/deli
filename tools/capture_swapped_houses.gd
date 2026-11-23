extends Node

func _ready() -> void:
	print("\n=== CAPTURING SWAPPED HOUSES AND REBOISASI ===")
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(15):
		await get_tree().process_frame

	var player = world.player
	var camera = world.camera

	# 1. Capture Hulu: MC house + house_cabin_blue at (272, 160)
	player.global_position = Vector2(240, 180)
	if camera:
		camera.global_position = Vector2(240, 150)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw

	var img_hulu = get_viewport().get_texture().get_image()
	img_hulu.save_png("tools/capture_hulu_swapped_cabin.png")
	print("Saved View 1: tools/capture_hulu_swapped_cabin.png")

	# 2. Capture Desa: house_cozy_red at (660, 160)
	world.change_zone("desa", Vector2(660, 200))
	for i in range(10):
		await get_tree().process_frame

	player.global_position = Vector2(660, 200)
	if camera:
		camera.global_position = Vector2(660, 160)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw

	var img_desa = get_viewport().get_texture().get_image()
	img_desa.save_png("tools/capture_desa_swapped_red.png")
	print("Saved View 2: tools/capture_desa_swapped_red.png")

	# 3. Capture Hulu Reboisasi 10 spots
	world.change_zone("hulu", Vector2(736, 140))
	for i in range(10):
		await get_tree().process_frame

	player.global_position = Vector2(736, 140)
	if camera:
		camera.global_position = Vector2(736, 140)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw

	var img_rebo = get_viewport().get_texture().get_image()
	img_rebo.save_png("tools/capture_hulu_reboisasi_10spots.png")
	print("Saved View 3: tools/capture_hulu_reboisasi_10spots.png")

	print("All captures completed successfully!")
	get_tree().quit(0)

