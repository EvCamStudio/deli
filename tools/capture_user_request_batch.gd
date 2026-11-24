extends Node

func _ready() -> void:
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	await get_tree().create_timer(1.0).timeout

	var player = world.player
	var camera = world.camera

	# 1. HILIR: Walkway clean of stump / obstacle (Image 1 fix)
	world.change_zone("hilir", Vector2(345, 410))
	await get_tree().create_timer(1.2).timeout
	var hilir_origin: Vector2 = world._zone_containers["hilir"].global_position
	if player: player.global_position = hilir_origin + Vector2(345, 410)
	if camera:
		camera.global_position = hilir_origin + Vector2(345, 410)
		camera.reset_smoothing()
	for i in range(25): await get_tree().process_frame
	var img1 = get_viewport().get_texture().get_image()
	if img1:
		img1.save_png("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_hilir_bridge_walkway_clean.png")
		print("Saved capture_hilir_bridge_walkway_clean.png")

	# 2. HULU: Deforested south forest view near MC house (Image 2 fix)
	world.change_zone("hulu", Vector2(200, 240))
	await get_tree().create_timer(1.2).timeout
	var hulu_origin: Vector2 = world._zone_containers["hulu"].global_position
	if player: player.global_position = hulu_origin + Vector2(200, 240)
	if camera:
		camera.global_position = hulu_origin + Vector2(200, 290)
		camera.reset_smoothing()
	for i in range(25): await get_tree().process_frame
	var img2 = get_viewport().get_texture().get_image()
	if img2:
		img2.save_png("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_hulu_house_deforested.png")
		print("Saved capture_hulu_house_deforested.png")

	# 3. HULU: Mangrove mud patches replacing dirt mounds (Image 3 fix)
	if player: player.global_position = hulu_origin + Vector2(700, 260)
	if camera:
		camera.global_position = hulu_origin + Vector2(700, 275)
		camera.reset_smoothing()
	for i in range(25): await get_tree().process_frame
	var img3 = get_viewport().get_texture().get_image()
	if img3:
		img3.save_png("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_hulu_mud_patches.png")
		print("Saved capture_hulu_mud_patches.png")

	# 4. KOTA: Barrier removed near Tuas 1 (Image 4 fix)
	world.change_zone("kota", Vector2(832, 208))
	await get_tree().create_timer(1.2).timeout
	var kota_origin: Vector2 = world._zone_containers["kota"].global_position
	if player: player.global_position = kota_origin + Vector2(800, 208)
	if camera:
		camera.global_position = kota_origin + Vector2(830, 195)
		camera.reset_smoothing()
	for i in range(25): await get_tree().process_frame
	var img4 = get_viewport().get_texture().get_image()
	if img4:
		img4.save_png("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_kota_lever_clean.png")
		print("Saved capture_kota_lever_clean.png")

	get_tree().quit(0)

