extends Node

func _ready() -> void:
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	
	await get_tree().create_timer(1.0).timeout
	world.change_zone("hilir", Vector2(700, 320))
	await get_tree().create_timer(1.5).timeout
	
	var hilir_container = world._zone_containers["hilir"]
	var hilir_origin: Vector2 = hilir_container.global_position
	
	var player = world.player
	var camera = world.camera
	
	# Capture 1: View of expanded mud terrain where MC was standing in Image 11
	if player != null:
		player.global_position = hilir_origin + Vector2(490, 420)
	if camera != null:
		camera.global_position = hilir_origin + Vector2(490, 400)
		camera.reset_smoothing()
	for i in range(25): await get_tree().process_frame
	
	var img1 = get_viewport().get_texture().get_image()
	if img1 != null:
		var path1 = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_hilir_expanded_mud_mc_view.png"
		img1.save_png(path1)
		print("Saved capture_hilir_expanded_mud_mc_view.png")
	
	# Capture 2: View of coconut palms on remaining southern beach sand
	if player != null:
		player.global_position = hilir_origin + Vector2(600, 465)
	if camera != null:
		camera.global_position = hilir_origin + Vector2(600, 440)
		camera.reset_smoothing()
	for i in range(25): await get_tree().process_frame
	
	var img2 = get_viewport().get_texture().get_image()
	if img2 != null:
		var path2 = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_hilir_sand_palms.png"
		img2.save_png(path2)
		print("Saved capture_hilir_sand_palms.png")

	# Capture 3: Neat 4x2 planting plot and expanded mangrove surroundings
	if player != null:
		player.global_position = hilir_origin + Vector2(400, 304)
	if camera != null:
		camera.global_position = hilir_origin + Vector2(480, 340)
		camera.reset_smoothing()
	for i in range(25): await get_tree().process_frame
	
	var img3 = get_viewport().get_texture().get_image()
	if img3 != null:
		var path3 = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_hilir_neat_spots.png"
		img3.save_png(path3)
		print("Saved capture_hilir_neat_spots.png")
	
	get_tree().quit(0)
