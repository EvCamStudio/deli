extends Node

func _ready() -> void:
	print("--- CAPTURING USER FIXES SCREENSHOTS ---")
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(25): await get_tree().process_frame

	world.change_zone("hulu", Vector2(112, 160))
	for i in range(25): await get_tree().process_frame

	var player = world.player
	var camera = world.camera
	var hulu_origin: Vector2 = world._zone_containers["hulu"].global_position

	# Capture 1: Bridge Area (Image 1 fix: awkward mound removed)
	player.global_position = hulu_origin + Vector2(535, 300)
	camera.global_position = hulu_origin + Vector2(535, 300)
	camera.reset_smoothing()
	for i in range(12): await get_tree().process_frame
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_bridge_clean.png")
	print("Saved capture_bridge_clean.png")

	# Capture 2: South Hulu Felled Trees (Image 2 fix: MC stepping ON top of mound, organic scatter)
	player.global_position = hulu_origin + Vector2(610, 270) # Standing right on top of mound
	camera.global_position = hulu_origin + Vector2(740, 300)
	camera.reset_smoothing()
	for i in range(12): await get_tree().process_frame
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_south_felled_mounds.png")
	print("Saved capture_south_felled_mounds.png")

	# Capture 3: Upper Hill Reboisasi Area (mounds near felled trees & planting spots)
	player.global_position = hulu_origin + Vector2(744, 130)
	camera.global_position = hulu_origin + Vector2(744, 130)
	camera.reset_smoothing()
	for i in range(12): await get_tree().process_frame
	var img3 = get_viewport().get_texture().get_image()
	img3.save_png("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_reboisasi_mounds.png")
	print("Saved capture_reboisasi_mounds.png")

	get_tree().quit(0)

