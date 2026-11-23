extends Node

func _ready() -> void:
	print("\n=== TESTING LOCATION BANNER ACROSS ALL MAPS/ZONES ===")
	
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world: WorldSungaiDeli = world_scene.instantiate() as WorldSungaiDeli
	add_child(world)
	
	for i in range(10):
		await get_tree().process_frame
		
	var hud = world.hud
	assert(hud != null, "HUD must exist in World")
	var location_label: Label = hud.get_node_or_null("SafeMargin/Root/TopBar/LocationCard/Label") as Label
	assert(location_label != null, "LocationCard Label must exist")
	
	# TEST 1: Hulu
	print("\n[TEST 1: Zone Hulu]")
	world.change_zone("hulu", Vector2(-1, -1), false)
	await get_tree().process_frame
	await get_tree().process_frame
	print("Location text: ", location_label.text)
	assert(location_label.text == "HULU SUNGAI DELI", "Expected 'HULU SUNGAI DELI', got: %s" % location_label.text)
	print("PASS: Hulu shows 'HULU SUNGAI DELI'")
	await _capture("tools/capture_banner_hulu.png")
	
	# TEST 2: Desa
	print("\n[TEST 2: Zone Desa]")
	world.change_zone("desa", Vector2(-1, -1), false)
	await get_tree().process_frame
	await get_tree().process_frame
	print("Location text: ", location_label.text)
	assert(location_label.text == "DESA SUKA MAJU", "Expected 'DESA SUKA MAJU', got: %s" % location_label.text)
	print("PASS: Desa shows 'DESA SUKA MAJU'")
	await _capture("tools/capture_banner_desa.png")
	
	# TEST 3: Kota
	print("\n[TEST 3: Zone Kota]")
	world.change_zone("kota", Vector2(-1, -1), false)
	await get_tree().process_frame
	await get_tree().process_frame
	print("Location text: ", location_label.text)
	assert(location_label.text == "KOTA MEDAN", "Expected 'KOTA MEDAN', got: %s" % location_label.text)
	print("PASS: Kota shows 'KOTA MEDAN'")
	await _capture("tools/capture_banner_kota.png")
	
	# TEST 4: Hilir
	print("\n[TEST 4: Zone Hilir]")
	world.change_zone("hilir", Vector2(-1, -1), false)
	await get_tree().process_frame
	await get_tree().process_frame
	print("Location text: ", location_label.text)
	assert(location_label.text == "MUARA SUNGAI DELI", "Expected 'MUARA SUNGAI DELI', got: %s" % location_label.text)
	print("PASS: Hilir shows 'MUARA SUNGAI DELI'")
	await _capture("tools/capture_banner_hilir.png")
	
	# TEST 5: Verify update_all() does NOT overwrite with "Kota Deli"
	print("\n[TEST 5: Calling update_all in Kota]")
	world.change_zone("kota", Vector2(-1, -1), false)
	await get_tree().process_frame
	hud.update_all()
	await get_tree().process_frame
	print("Location text after update_all: ", location_label.text)
	assert(location_label.text == "KOTA MEDAN", "Expected 'KOTA MEDAN' after update_all, got: %s" % location_label.text)
	print("PASS: update_all preserves 'KOTA MEDAN'")
	
	print("\n===========================================")
	print("ALL LOCATION BANNER TESTS PASSED PERFECTLY!")
	print("===========================================")
	get_tree().quit(0)

func _capture(path: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Saved capture: ", path)

