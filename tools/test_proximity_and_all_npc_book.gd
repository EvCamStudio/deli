extends Node

func _ready() -> void:
	print("\n=== TESTING PROXIMITY DIALOGUES & CHARACTER BOOK UNLOCK ===")
	GameState.reset()

	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(15):
		await get_tree().process_frame

	var hud = world.hud if "hud" in world else world.get_node_or_null("HUD")
	assert(hud != null, "HUD must exist!")
	var char_book: CharacterBook = hud.get_node_or_null("CharacterBook") as CharacterBook
	assert(char_book != null, "CharacterBook instance must exist!")

	# Initial check: Datuk should NOT be talked yet
	assert(not GameState.has_talked_to_npc("datuk"), "Datuk must not be talked initially")

	# Test 1: Simulating Dialogue h1_datuk completing via _on_dialog_selesai
	print("\n[TEST 1] Triggering _on_dialog_selesai('h1_datuk')...")
	world._on_dialog_selesai("h1_datuk")
	await get_tree().process_frame
	assert(GameState.has_talked_to_npc("datuk"), "Datuk must be unlocked after h1_datuk completes!")
	assert("npc_datuk" in GameState.zone_progress["hulu"]["talked_keys"], "npc_datuk must be recorded in hulu talked_keys")
	assert(GameState.has_card("card_kearifan_02"), "Datuk card_kearifan_02 must be unlocked!")

	# Check CharacterBook page 2 left (Datuk)
	char_book.open_book(2)
	await get_tree().process_frame
	assert(char_book.left_name.text == "Datuk Sampan", "Datuk name must be Datuk Sampan!")
	assert(char_book.left_status.text == "Roh Penjaga Sungai", "Datuk status must be Roh Penjaga Sungai!")
	assert(char_book.left_photo.texture.resource_path.get_file() == "datuk_neutral.png", "Datuk photo must be datuk_neutral.png!")
	print("  -> PASS: Datuk Sampan unlocked in Character Book and cards!")

	# Test 2: Simulating Dialogue h1_toko_jaya completing (Pak Darwis & Koh Jaya)
	print("\n[TEST 2] Triggering _on_dialog_selesai('h1_toko_jaya')...")
	world._on_dialog_selesai("h1_toko_jaya")
	await get_tree().process_frame
	assert(GameState.has_talked_to_npc("darwis"), "Darwis must be unlocked after h1_toko_jaya completes!")
	assert(GameState.has_talked_to_npc("pemilik_toko"), "Koh Jaya must be unlocked after h1_toko_jaya completes!")
	
	# Check Koh Jaya on page 3
	char_book.goto_page(3)
	await get_tree().process_frame
	assert(char_book.left_name.text == "Koh Jaya", "Koh Jaya name must be Koh Jaya!")
	assert(char_book.left_status.text == "Kooperatif & Ramah", "Koh Jaya status must be Kooperatif & Ramah!")

	# Check Darwis on page 6 (Dynamic: since choices had no peduli/solusi, it recorded menolak/sad)
	char_book.goto_page(6)
	await get_tree().process_frame
	assert(char_book.right_name.text == "Pak Darwis", "Darwis name must be Pak Darwis!")
	assert(char_book.right_photo.texture.resource_path.get_file() in ["pak_darwis_sad.png", "pak_darwis_neutral.png"], "Darwis photo must be unlocked (sad or neutral)!")
	print("  -> PASS: Pak Darwis and Koh Jaya unlocked in Character Book!")

	# Test 3: Simulating Proximity Dialogues for Kak Rina (h4_rina) and Bang Jali (h2_jali)
	print("\n[TEST 3] Triggering _on_dialog_selesai('h4_rina') and ('h2_jali')...")
	world._on_dialog_selesai("h4_rina")
	world._on_dialog_selesai("h2_jali")
	await get_tree().process_frame
	assert(GameState.has_talked_to_npc("rina"), "Kak Rina must be unlocked!")
	assert(GameState.has_talked_to_npc("jali"), "Bang Jali must be unlocked!")

	# Check Kak Rina & Bang Jali on page 7
	char_book.goto_page(7)
	await get_tree().process_frame
	assert(char_book.left_name.text == "Kak Rina", "Kak Rina name must be Kak Rina!")
	assert(char_book.right_name.text == "Bang Jali", "Bang Jali name must be Bang Jali!")
	print("  -> PASS: Kak Rina and Bang Jali unlocked in Character Book!")

	# Test 4: Simulating other story NPCs
	print("\n[TEST 4] Triggering dialogues for Penjaga Hutan, Pemuka Desa, Pak RT, Ibu Rumah, Budi, Penjaga Sungai, Pak Nelayan...")
	world._on_dialog_selesai("h1_penjaga_hutan")
	world._on_dialog_selesai("h2_pemuka_desa")
	world._on_dialog_selesai("h3_pak_rt")
	world._on_dialog_selesai("h3_ibu_rumah")
	world._on_dialog_selesai("h3_budi")
	world._on_dialog_selesai("h7_penjaga_sungai")
	world._on_dialog_selesai("h7_nelayan")
	await get_tree().process_frame

	for k in ["penjaga_hutan", "pemuka_desa", "pak_rt", "ibu_rumah", "budi", "penjaga_sungai", "nelayan"]:
		assert(GameState.has_talked_to_npc(k), "NPC '%s' must be unlocked in GameState!" % k)
	print("  -> PASS: All story NPCs unlocked in GameState!")

	# Test 5: RETROACTIVE FALLBACK TEST
	print("\n[TEST 5] Testing Retroactive Fallback in has_talked_to_npc without talked_characters dictionary...")
	GameState.talked_characters.clear()
	for z in GameState.zone_progress.keys():
		GameState.zone_progress[z]["talked_keys"] = []
	# Now talked_characters and talked_keys are completely empty!
	# Verify that story choices make has_talked_to_npc still return true:
	GameState.choices["datuk_bencana_revealed"] = true
	GameState.choices["budi_done"] = true
	GameState.choices["has_rt_cart_approval"] = true
	GameState.choices["penjaga_hutan_selesai"] = true
	GameState.choices["darwis_done"] = true
	GameState.choices["rina_done"] = true
	GameState.choices["jali_done"] = true
	GameState.choices["has_jeriken_and_info"] = true
	GameState.choices["ibu_rumah_done"] = true
	GameState.choices["penjaga_sungai_done"] = true
	GameState.choices["nelayan_selesai"] = true

	assert(GameState.has_talked_to_npc("datuk"), "Datuk must be true via story fallback!")
	assert(GameState.has_talked_to_npc("budi"), "Budi must be true via story fallback!")
	assert(GameState.has_talked_to_npc("pak_rt"), "Pak RT must be true via story fallback!")
	assert(GameState.has_talked_to_npc("penjaga_hutan"), "Penjaga Hutan must be true via story fallback!")
	assert(GameState.has_talked_to_npc("darwis"), "Darwis must be true via story fallback!")
	assert(GameState.has_talked_to_npc("rina"), "Kak Rina must be true via story fallback!")
	assert(GameState.has_talked_to_npc("jali"), "Bang Jali must be true via story fallback!")
	assert(GameState.has_talked_to_npc("pemuka_desa"), "Pemuka Desa must be true via story fallback!")
	assert(GameState.has_talked_to_npc("ibu_rumah"), "Ibu Rumah must be true via story fallback!")
	assert(GameState.has_talked_to_npc("penjaga_sungai"), "Penjaga Sungai must be true via story fallback!")
	assert(GameState.has_talked_to_npc("nelayan"), "Pak Nelayan must be true via story fallback!")
	print("  -> PASS: Retroactive story fallback works 100% reliably!")

	# Capture screenshot of Page 2 (Datuk & Penjaga Hutan)
	char_book.goto_page(2)
	await get_tree().process_frame
	await get_tree().process_frame
	var img = get_viewport().get_texture().get_image()
	img.save_png("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_char_book_datuk_unlocked.png")
	print("Screenshot saved to capture_char_book_datuk_unlocked.png")

	# Capture screenshot of Page 7 (Kak Rina & Bang Jali)
	char_book.goto_page(7)
	await get_tree().process_frame
	await get_tree().process_frame
	var img7 = get_viewport().get_texture().get_image()
	img7.save_png("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/capture_char_book_rina_jali_unlocked.png")
	print("Screenshot saved to capture_char_book_rina_jali_unlocked.png")

	print("\n=========================================================================")
	print("ALL PROXIMITY DIALOGUES & CHARACTER BOOK TESTS PASSED 100%!")
	print("=========================================================================")
	get_tree().quit(0)
