extends Node

func _ready() -> void:
	print("\n=== TESTING CHARACTER BOOK (NPC DISCOVERY & DYNAMIC 3-PHASE VERIFICATION) ===")

	# Pastikan state awal bersih
	GameState.reset()

	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(15):
		await get_tree().process_frame

	var hud = world.hud if "hud" in world else world.get_node_or_null("HUD")
	assert(hud != null, "HUD must exist in world!")

	# 1. Test Book button exists and opens book
	var book_btn: Button = hud.get_node_or_null("SafeMargin/Root/BookBtn") as Button
	assert(book_btn != null, "BookBtn must exist on HUD!")
	var char_book: CharacterBook = hud.get_node_or_null("CharacterBook") as CharacterBook
	assert(char_book != null, "CharacterBook instance must exist!")
	assert(char_book.visible == false, "CharacterBook must be closed initially!")

	book_btn.pressed.emit()
	await get_tree().process_frame
	assert(char_book.visible == true, "CharacterBook must be visible!")

	# --- TEST ITEM 1: INITIAL STATE (BEFORE TALKING TO ANYONE) ---
	print("\n[TEST 1] Verifying Initial State: ALL NPCs locked (silhouette '?' & '???')...")
	# Page 1 (Bu Mira & Pak Hendra - Static)
	char_book.goto_page(1)
	await get_tree().process_frame
	assert(char_book.left_photo.texture.resource_path.get_file() == "unknown_neutral.png", "Bu Mira photo must be question mark initially!")
	assert(char_book.left_name.text == "???", "Bu Mira name must be '???' initially!")
	assert(char_book.left_status.text == "", "Bu Mira status must be empty initially!")
	assert(char_book.left_notes.text == "???", "Bu Mira notes must be '???' initially!")
	assert(char_book.left_note_indicator.visible == false, "Note sub-pagination indicator must be hidden for ???")
	assert(char_book.left_note_btn_next.visible == false, "Note sub-pagination next button must be hidden for ???")

	assert(char_book.right_photo.texture.resource_path.get_file() == "unknown_neutral.png", "Pak Hendra photo must be question mark initially!")
	assert(char_book.right_name.text == "???", "Pak Hendra name must be '???' initially!")
	assert(char_book.right_status.text == "", "Pak Hendra status must be empty initially!")
	assert(char_book.right_notes.text == "???", "Pak Hendra notes must be '???' initially!")

	# Page 6 (Left: Nelayan - Static; Right: Pak Darwis - Dynamic)
	char_book.goto_page(6)
	await get_tree().process_frame
	assert(char_book.left_photo.texture.resource_path.get_file() == "unknown_neutral.png", "Nelayan must be locked initially!")
	assert(char_book.left_name.text == "???", "Nelayan name must be '???' initially!")

	# Dynamic NPC: Pak Darwis must ALSO be locked before MC meets him!
	assert(char_book.right_photo.texture.resource_path.get_file() == "unknown_neutral.png", "Pak Darwis photo MUST be question mark initially before meeting!")
	assert(char_book.right_name.text == "???", "Pak Darwis name MUST be '???' initially before meeting!")
	assert(char_book.right_status.text == "", "Pak Darwis status MUST be empty initially!")
	assert(char_book.right_notes.text == "???", "Pak Darwis notes MUST be '???' initially!")

	# Page 7 (Left: Kak Rina - Dynamic; Right: Bang Jali - Dynamic)
	char_book.goto_page(7)
	await get_tree().process_frame
	assert(char_book.left_photo.texture.resource_path.get_file() == "unknown_neutral.png", "Kak Rina photo MUST be question mark initially!")
	assert(char_book.left_name.text == "???", "Kak Rina name MUST be '???' initially!")
	assert(char_book.left_status.text == "", "Kak Rina status MUST be empty initially!")
	assert(char_book.left_notes.text == "???", "Kak Rina notes MUST be '???' initially!")

	assert(char_book.right_photo.texture.resource_path.get_file() == "unknown_neutral.png", "Bang Jali photo MUST be question mark initially!")
	assert(char_book.right_name.text == "???", "Bang Jali name MUST be '???' initially!")
	assert(char_book.right_status.text == "", "Bang Jali status MUST be empty initially!")
	assert(char_book.right_notes.text == "???", "Bang Jali notes MUST be '???' initially!")
	print("  -> PASS: Seluruh karakter (baik Statis maupun 3 Dinamis) terkunci awal dengan siluet '?' dan nama '???'.")

	# --- TEST ITEM 2: UNLOCKING STATIC NPC AFTER TALKING ---
	print("\n[TEST 2] Verifying Static NPC Unlock after MC speaks with them...")
	# Simulate MC talking to Bu Mira in warung
	world.on_npc_talked("npc_ibu_mc")
	await get_tree().process_frame

	char_book.goto_page(1)
	await get_tree().process_frame
	assert(char_book.left_photo.texture.resource_path.get_file() == "ibu_neutral.png", "Bu Mira photo must now be ibu_neutral.png!")
	assert(char_book.left_name.text == "Bu Mira", "Bu Mira name must now be 'Bu Mira'!")
	assert(char_book.left_status.text == "Penyayang & Ramah", "Bu Mira status must now be 'Penyayang & Ramah'!")
	assert(char_book.left_notes.text.begins_with("Ibu yang membesarkanku"), "Bu Mira notes must now be full text!")
	assert(char_book.left_note_chunks.size() > 1, "Bu Mira note must have pagination chunks!")
	assert(char_book.left_note_btn_next.visible == true, "Next button (>) must now be visible!")

	# Pak Hendra also unlocked via warung conversation
	assert(char_book.right_photo.texture.resource_path.get_file() == "pak_hendra_neutral.png", "Pak Hendra photo must be unlocked!")
	assert(char_book.right_name.text == "Pak Hendra", "Pak Hendra name must be unlocked!")
	assert(char_book.right_status.text == "Tenang & Bijaksana", "Pak Hendra status must be unlocked!")
	print("  -> PASS: Bu Mira dan Pak Hendra berhasil terbuka penuh setelah MC berbicara di warung.")

	# --- TEST ITEM 3: DYNAMIC NPC MET BUT UNRESOLVED (FOTO & NAMA TERBUKA, STATUS & CATATAN MASIH TANDA TANYA) ---
	print("\n[TEST 3] Verifying Dynamic NPC Met but Dilemma Unresolved: Only Photo & Name Open...")
	# MC meets Pak Darwis (talks to him)
	world.on_npc_talked("npc_petani_1")
	await get_tree().process_frame

	char_book.goto_page(6)
	await get_tree().process_frame
	assert(char_book.right_photo.texture.resource_path.get_file() == "pak_darwis_neutral.png", "Pak Darwis photo MUST open upon meeting him!")
	assert(char_book.right_name.text == "Pak Darwis", "Pak Darwis name MUST open upon meeting him!")
	assert(char_book.right_status.text == "", "Pak Darwis status MUST remain empty/question mark before action taken!")
	assert(char_book.right_notes.text == "???", "Pak Darwis notes MUST remain '???' before action taken!")
	print("  -> PASS: Pak Darwis setelah ditemui hanya terbuka foto netral dan nama, status & catatan tetap tanda tanya.")

	# --- TEST ITEM 4: DYNAMIC NPC DECISION (PEDULI / MAU BERUBAH) ---
	print("\n[TEST 4] Verifying Dynamic NPC Decision: Win-Win Solution (Mau Berubah - Hijau)...")
	# Simulate player choosing win-win solution for Pak Darwis
	GameState.record_choice("darwis_peduli", true)
	await get_tree().process_frame

	char_book.goto_page(6)
	await get_tree().process_frame
	assert(char_book.right_photo.texture.resource_path.get_file() == "pak_darwis_happy.png", "Pak Darwis photo must change to happy portrait!")
	assert(char_book.right_name.text == "Pak Darwis", "Pak Darwis name remains Pak Darwis!")
	assert(char_book.right_status.text == "Mau Berubah", "Pak Darwis status must now be 'Mau Berubah'!")
	assert(char_book.right_status.get_theme_color("font_color") == Color(0.15, 0.58, 0.22, 1.0), "Pak Darwis status color must be green!")
	assert(char_book.right_notes.text.contains("Syukurlah Pak Darwis mau mendengarkan"), "Pak Darwis notes must display Fase 2A narrative!")
	print("  -> PASS: Pak Darwis berhasil berubah ke status 'Mau Berubah' (Hijau) dengan foto tersenyum dan catatan narasi.")

	# --- TEST ITEM 5: DYNAMIC NPC MET THEN FAILED DEBATE (MENOLAK / TIDAK SUKA) ---
	print("\n[TEST 5] Verifying Dynamic NPC Met then Failed Debate (Tidak Suka - Merah)...")
	# MC meets Kak Rina
	world.on_npc_talked("npc_ibu_desa")
	await get_tree().process_frame

	char_book.goto_page(7)
	await get_tree().process_frame
	assert(char_book.left_photo.texture.resource_path.get_file() == "kak_rina_neutral.png", "Kak Rina photo MUST open upon meeting!")
	assert(char_book.left_name.text == "Kak Rina", "Kak Rina name MUST open upon meeting!")
	assert(char_book.left_status.text == "", "Kak Rina status MUST remain empty before action taken!")
	assert(char_book.left_notes.text == "???", "Kak Rina notes MUST remain '???' before action taken!")

	# Simulate player failing debate with Kak Rina
	GameState.record_choice("rina_peduli", false)
	await get_tree().process_frame

	char_book.goto_page(7)
	await get_tree().process_frame
	assert(char_book.left_photo.texture.resource_path.get_file() == "kak_rina_sad.png", "Kak Rina photo must change to sad portrait!")
	assert(char_book.left_name.text == "Kak Rina", "Kak Rina name remains Kak Rina!")
	assert(char_book.left_status.text == "Tidak Suka", "Kak Rina status must now be 'Tidak Suka'!")
	assert(char_book.left_status.get_theme_color("font_color") == Color(0.80, 0.22, 0.20, 1.0), "Kak Rina status color must be red!")
	assert(char_book.left_notes.text.contains("Dia benar-benar marah"), "Kak Rina notes must display Fase 2B regret narrative!")
	print("  -> PASS: Kak Rina setelah ditemui terbuka foto & nama, lalu setelah debat gagal berubah ke 'Tidak Suka' (Merah).")

	# --- TEST ITEM 5: UI LAYOUT, CENTERING & LEAF BOUNDS ---
	print("\n[TEST 5] Verifying UI Centering, Status Padding, & Leaf Motif Safety...")
	char_book.goto_page(1)
	await get_tree().process_frame
	var left_name_center := (char_book.left_name.offset_left + char_book.left_name.offset_right) / 2.0
	assert(is_equal_approx(left_name_center, 185.0), "LeftName center must be exactly 185.0!")
	assert(char_book.left_status.offset_left >= 135.0, "LeftStatus offset_left must be >= 135!")
	assert(char_book.left_notes.offset_top >= 115.0, "LeftNotes top must be >= 115!")
	assert(char_book.left_notes.offset_bottom <= 210.0, "LeftNotes bottom must be <= 210!")
	print("  -> PASS: Seluruh tata letak visual rapi dan terisolasi dari motif daun.")

	# Close book
	char_book.btn_close.pressed.emit()
	await get_tree().process_frame
	assert(char_book.visible == false, "CharacterBook should be closed!")
	assert(get_tree().paused == false, "Game unpaused!")

	print("\n=========================================================================")
	print("ALL NPC DISCOVERY & DYNAMIC STATE CHECKS PASSED 100% PERFECTLY!")
	print("=========================================================================")
	get_tree().quit(0)
