extends Node

func _ready() -> void:
	print("\n=== TESTING 6 USER REQUESTS IMPLEMENTATION ===")

	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(15):
		await get_tree().process_frame

	var hud = world.hud if "hud" in world else world.get_node_or_null("HUD")
	assert(hud != null, "HUD must exist!")

	# ─── TEST 1: Animasi Jalan Dihapus pada Perpindahan Hari ───
	print("\n[TEST 1] Testing Day Transition Cutscene (No Walking MC)...")
	world.play_two_days_later_cutscene()
	await get_tree().process_frame
	var cutscene = world.get_node_or_null("TwoDaysCutscene")
	assert(cutscene != null, "Cutscene canvas layer should exist!")
	var walker = cutscene.find_child("WalkingHolder", true, false)
	assert(walker == null, "Day transition cutscene MUST NOT contain walking MC animation! Found: %s" % str(walker))
	print("  -> PASS: Animasi jalan berhasil dihapus pada perpindahan hari (teks saja).")

	# Close cutscene
	world.advance_cutscene()
	await get_tree().process_frame
	await get_tree().process_frame

	# ─── TEST 2 & 3: Pohon Ditanam & Pemandangan Pohon Ditebang ───
	print("\n[TEST 2 & 3] Testing Felled Trees & Planting Spots in Hill and South...")
	assert(world.HULU_FOREST_SPOTS.size() == 10, "HULU_FOREST_SPOTS must have exactly 10 spots! Got %d" % world.HULU_FOREST_SPOTS.size())
	assert(world.ZONE_TARGETS["hulu"]["trees"] == 10, "ZONE_TARGETS['hulu']['trees'] must be 10! Got %d" % world.ZONE_TARGETS["hulu"]["trees"])
	for spot in world.HULU_FOREST_SPOTS:
		assert(spot.y <= 11, "Tree spot %s is at y=%d, encroaching or on the dirt road (y>=13)!" % [str(spot), spot.y])
		assert(spot.x >= 40 and spot.x <= 52, "Tree spot %s is outside hill clearing!" % str(spot))
	print("  -> PASS: Tepat 10 titik penanaman pohon tertata rapi di bukit reboisasi (bebas dari jalan raya).")

	# Check tree stumps in world
	var stump_count: int = 0
	var log_count: int = 0
	var zone_hulu = world.get_node_or_null("ZoneHulu")
	if zone_hulu:
		for child in zone_hulu.get_children():
			if child is StaticBody2D:
				for grand in child.get_children():
					if grand is Sprite2D and grand.texture:
						var p = grand.texture.resource_path
						if "prop_stump_tree" in p:
							stump_count += 1
						elif "prop_log_wood" in p:
							log_count += 1
	print("Found %d stumps and %d cut logs across Hulu map." % [stump_count, log_count])
	assert(stump_count >= 5, "Should have plenty of tree stumps (>=5)! Got %d" % stump_count)
	assert(log_count >= 4, "Should have plenty of cut logs (>=4)! Got %d" % log_count)
	print("  -> PASS: Pemandangan pohon ditebang (tunggul & kayu gelondongan) tersebar lebat di bukit dan selatan.")

	# ─── TEST 4: Sampah Pinggir Sungai Rapi (Tidak Menumpuk/Berantakan) ───
	print("\n[TEST 4] Testing Tidy Riverbank Trash Distribution...")
	world._spawn_hulu_riverbank_trash()
	await get_tree().process_frame
	var hulu_river_trash: Array = []
	var zone_hulu_node = world.get_node_or_null("ZoneHulu")
	if zone_hulu_node:
		for child in zone_hulu_node.get_children():
			if child.is_in_group("world_trash") and str(child.get("trash_id")).begins_with("hulu_river_trash"):
				hulu_river_trash.append(child)
	print("Total spawned riverbank trash in hulu: ", hulu_river_trash.size())
	assert(hulu_river_trash.size() == 10, "Riverbank trash count should be 10, got %d" % hulu_river_trash.size())
	# Check distances between trash items - none should be overlapping (< 35px)
	for i in range(hulu_river_trash.size()):
		for j in range(i + 1, hulu_river_trash.size()):
			var dist = hulu_river_trash[i].global_position.distance_to(hulu_river_trash[j].global_position)
			assert(dist >= 35.0, "Trash items %d and %d are too close! Distance: %.1f px" % [i, j, dist])
	print("  -> PASS: Sampah tersebar rapi dengan jarak lega (>35px), tidak ada tumpukan berantakan.")

	# ─── TEST 5: Kotak Misi Terbuka di Awal ───
	print("\n[TEST 5] Testing Mission Card Opens by Default...")
	hud.update_mission("BERSIHKAN SUNGAI\nPungut sampah di pinggiran sungai.")
	await get_tree().process_frame
	var mission_card: Control = hud.get_node_or_null("SafeMargin/Root/MissionCard") as Control
	var mission_toggle_btn: Button = hud.get_node_or_null("SafeMargin/Root/MissionToggleBtn") as Button
	assert(mission_card != null and mission_toggle_btn != null, "Mission card and button must exist!")
	assert(mission_card.visible == true, "MissionCard MUST BE VISIBLE (OPEN) BY DEFAULT!")
	print("  -> PASS: Kotak misi langsung muncul terbuka di awal (visible=true).")

	# Test player toggle close
	hud._on_mission_toggle_pressed()
	assert(mission_card.visible == false, "Player should be able to toggle close mission card!")
	hud._on_mission_toggle_pressed()
	assert(mission_card.visible == true, "Player should be able to toggle open mission card!")
	print("  -> PASS: Player dapat menutup/membuka secara opsional via tombol toggle.")

	# ─── TEST 6: Indikator Bencana 55% dan Berkurang saat Bersihkan Sampah ───
	print("\n[TEST 6] Testing Disaster Meter Starts at 55% and Decreases on Trash Cleaning...")
	GameState.record_choice("hulu_story_step", "cari_suara_jembatan")
	world._sync_hulu_story_state()
	# Trigger Datuk dialogue completion
	world._on_dialog_selesai("h1_datuk")
	await get_tree().process_frame
	print("Meter bencana after Datuk task:", GameState.meter_bencana)
	assert(abs(GameState.meter_bencana - 55.0) < 0.1, "Meter bencana should be 55%%! Got %f" % GameState.meter_bencana)
	print("  -> PASS: Meter bencana tepat 55% saat Datuk memberikan tugas membersihkan sungai.")

	# Clean trash
	var initial_meter = GameState.meter_bencana
	world.on_trash_picked("plastik", "test_trash_1")
	await get_tree().process_frame
	print("Meter bencana after picking 1 trash:", GameState.meter_bencana)
	assert(GameState.meter_bencana < initial_meter, "Meter bencana should decrease after picking trash! Was %f, now %f" % [initial_meter, GameState.meter_bencana])
	world.on_bin_sorted("plastik")
	await get_tree().process_frame
	print("Meter bencana after sorting 1 trash:", GameState.meter_bencana)
	assert(GameState.meter_bencana < initial_meter - 2.0, "Meter bencana should further decrease after sorting! Now %f" % GameState.meter_bencana)
	print("  -> PASS: Meter bencana sedikit berkurang secara bertahap saat sampah dibersihkan.")

	print("\n=======================================================")
	print("ALL 6 USER REQUEST TESTS PASSED 100% PERFECTLY!")
	print("=======================================================")
	get_tree().quit(0)
