extends Node

func _ready() -> void:
	print("--- TEST FLOOD CUTSCENE FULL START ---")
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	assert(world_scene != null, "World scene must load")
	var world = world_scene.instantiate()
	add_child(world)

	await get_tree().create_timer(1.0).timeout

	# 1. Posisikan MC di dekat bantaran sungai Hulu agar terlihat jelas
	world.change_zone("hulu", Vector2(320, 260))
	await get_tree().create_timer(0.5).timeout

	if world.player:
		world.player.global_position = Vector2(320, 260)
	if world.camera:
		world.camera.global_position = Vector2(320, 260)
		world.camera.reset_smoothing()

	for i in range(10): await get_tree().process_frame

	# 2. Trigger Sinematik Banjir Bandang
	print("Triggering play_catastrophic_flood_cutscene()...")
	world.play_catastrophic_flood_cutscene()

	# --- Tangkap Frame 1: Alarm & Gemuruh (Air mulai meluap) ---
	await get_tree().create_timer(0.8).timeout
	for i in range(5): await get_tree().process_frame
	_save_screenshot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_flood_stage1_warning.png")
	print("Captured Stage 1: Warning & Alarm")

	# --- Tangkap Frame 2: Air Meluap Menenggelamkan Bantaran & Puing Hanyut ---
	await get_tree().create_timer(2.0).timeout
	for i in range(5): await get_tree().process_frame
	_save_screenshot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_flood_stage2_water_rising.png")
	print("Captured Stage 2: Water Rising & Debris Floating")

	# --- Tangkap Frame 3: Seluruh Map Tenggelam ---
	await get_tree().create_timer(2.4).timeout
	for i in range(5): await get_tree().process_frame
	_save_screenshot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_flood_stage3_map_submerged.png")
	print("Captured Stage 3: Full Map Submerged")

	# --- Tangkap Frame 4: Submersion Pekat & Transisi Gelap ---
	await get_tree().create_timer(2.2).timeout
	for i in range(5): await get_tree().process_frame
	_save_screenshot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_flood_stage4_dark_transition.png")
	print("Captured Stage 4: Dark Transition")

	print("--- TEST FLOOD CUTSCENE FULL PASS ---")
	get_tree().quit(0)

func _save_screenshot(path: String) -> void:
	var img = get_viewport().get_texture().get_image()
	if img:
		img.save_png(path)

