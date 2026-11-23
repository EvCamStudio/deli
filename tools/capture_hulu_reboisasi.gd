extends Node

func _ready() -> void:
	print("\n=== CAPTURING HULU REBOISASI CLEARING & 10 SPOTS ===")
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(15):
		await get_tree().process_frame

	var player = world.player
	var camera = world.camera

	# Position MC in the middle of the 10 tree planting spots in the hill clearing
	# Hill clearing is x = 46 * 16 = 736, y = 8 * 16 = 128
	player.global_position = Vector2(736, 136)
	if camera:
		camera.global_position = Vector2(736, 140)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw

	var img = get_viewport().get_texture().get_image()
	img.save_png("tools/capture_hulu_reboisasi_neat10.png")
	print("Saved View: tools/capture_hulu_reboisasi_neat10.png")

	# Also check view from the dirt road to verify NO circles on the road
	player.global_position = Vector2(720, 230)
	if camera:
		camera.global_position = Vector2(720, 230)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw

	var img_road = get_viewport().get_texture().get_image()
	img_road.save_png("tools/capture_hulu_road_clean.png")
	print("Saved View: tools/capture_hulu_road_clean.png")

	get_tree().quit(0)

