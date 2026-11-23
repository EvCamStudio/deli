extends Node

func _ready() -> void:
	print("\n=== TESTING ALL 6 USER BOUNDARY & REALISM FIXES ===")
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(15):
		await get_tree().process_frame

	var player: CharacterBody2D = world.player

	# ─── TEST 1 (Gambar 1): Dinding kanan hutan utara (x=335) ───
	print("\n[TEST 1] Testing transparent wall at east boundary of north forest clearing (Gambar 1)...")
	# Dari jalur tepian sungai (x=355, y=60) mencoba jalan ke kiri (barat) masuk ke hutan belakang rumah
	player.global_position = Vector2(355, 60)
	for f in range(30):
		player.velocity = Vector2(-160, 0)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final x trying to enter north forest from riverbank:", player.global_position.x)
	assert(player.global_position.x >= 335.0, "Player must NOT enter north forest clearing from riverbank! Got x=%f" % player.global_position.x)
	print("  -> PASS: Dinding transparan kanan hutan utara bekerja sempurna (x=%.1f >= 335.0)" % player.global_position.x)

	# ─── TEST 2: Teras rumah tetangga sebelah MC (house_cabin_blue) ───
	print("\n[TEST 2] Testing realistic porch walk at house_cabin_blue next to MC...")
	player.global_position = Vector2(272, 180)
	for f in range(30):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final y at house porch:", player.global_position.y)
	assert(player.global_position.y <= 165.0, "Player should be able to step onto porch steps! Got y=%f" % player.global_position.y)
	assert(player.global_position.y >= 158.0, "Player MUST NOT penetrate house door/wall! Got y=%f" % player.global_position.y)
	print("  -> PASS: Pemain berhenti realistis di depan pintu/teras rumah tetangga tanpa tembus (y=%.1f)" % player.global_position.y)

	# ─── TEST 3 (Gambar 3): Rumput sela rumah di bawah Tempat Sampah ───
	print("\n[TEST 3] Testing walking across grass towards bush between houses (Gambar 3)...")
	# Di sela rumah x=188, pemain jalan dari y=160 ke utara.
	player.global_position = Vector2(188, 160)
	for f in range(30):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final y between houses at bush/grass:", player.global_position.y)
	assert(player.global_position.y <= 136.0, "Player must walk past empty grass and reach the actual bush! Got y=%f" % player.global_position.y)
	assert(player.global_position.y >= 120.0, "Player must be stopped by the bush flora! Got y=%f" % player.global_position.y)
	print("  -> PASS: Pemain tidak lagi macet di rumput kosong, berjalan mulus sampai semak (y=%.1f)" % player.global_position.y)

	# ─── TEST 4 (Gambar 1 & 2 user): Teras rumah MC (house_mc) ───
	print("\n[TEST 4A] Testing MC stopped at porch railing of house_mc without huge gap (Gambar 1)...")
	# Posisi rumah MC: Vector2(112, 160). Di sisi kiri teras (x=92) ada pagar teras kayu (railing).
	# Pemain terhenti pas di depan pagar tanpa jarak kosong terlalu jauh (y=166..169).
	player.global_position = Vector2(92, 180)
	for f in range(30):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final y at house_mc porch railing:", player.global_position.y)
	assert(player.global_position.y >= 166.0, "Player MUST NOT penetrate wooden porch railing! Got y=%f" % player.global_position.y)
	assert(player.global_position.y <= 169.0, "Player must NOT stop too far from porch railing! Got y=%f" % player.global_position.y)
	print("  -> PASS: Pemain berhenti pas di depan pagar teras kayu tanpa jarak jauh (y=%.1f)" % player.global_position.y)

	print("\n[TEST 4B] Testing MC stepping onto open entrance of house_mc without penetrating door (Gambar 2)...")
	# Di sisi kanan teras (x=118) adalah pintu masuk terbuka di bawah panah kuning.
	# Pemain menapak teras sampai depan pintu tanpa tembus ke dinding/atap (y=161..164).
	player.global_position = Vector2(118, 180)
	for f in range(30):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final y at house_mc open entrance:", player.global_position.y)
	assert(player.global_position.y <= 164.0, "Player should be able to step onto MC porch deck! Got y=%f" % player.global_position.y)
	assert(player.global_position.y >= 161.0, "Player MUST NOT penetrate MC door/wall! Got y=%f" % player.global_position.y)
	print("  -> PASS: Pemain menapak teras depan pintu rumah MC tanpa tembus dinding (y=%.1f)" % player.global_position.y)

	print("\n[TEST 4C] Testing MC stopped realistically at left wall of house_mc...")
	# Di sisi kiri rumah MC (x=68) ada dinding kayu dan pondasi batu.
	# Pemain berhenti di depan tembok secara realistis tanpa tembus dinding (y=161..164).
	player.global_position = Vector2(68, 180)
	for f in range(30):
		player.velocity = Vector2(0, -160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final y at house_mc left wall:", player.global_position.y)
	assert(player.global_position.y <= 164.0, "Player should stop realistically at left wall! Got y=%f" % player.global_position.y)
	assert(player.global_position.y >= 161.0, "Player MUST NOT penetrate wall! Got y=%f" % player.global_position.y)
	print("  -> PASS: Pemain berhenti realistis di tembok kiri rumah MC (y=%.1f)" % player.global_position.y)

	# ─── TEST 5 (Gambar 5): Batas rimba selatan dari tepian sungai ───
	print("\n[TEST 5] Testing west boundary of southern forest (Gambar 5)...")
	# Di tepian sungai x=355, y=380, pemain mencoba jalan ke kiri (barat) masuk ke hutan rimba
	player.global_position = Vector2(355, 380)
	for f in range(30):
		player.velocity = Vector2(-160, 0)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final x trying to enter southern forest:", player.global_position.x)
	assert(player.global_position.x >= 342.0, "Player must NOT enter deep southern forest! Got x=%f" % player.global_position.x)
	print("  -> PASS: Batas posisi berdiri MC di Gambar 5 terkunci rapi oleh dinding transparan (x=%.1f >= 342.0)" % player.global_position.x)

	# ─── TEST 6 (Gambar 6): Batas atas kanopi hutan utara barat ───
	print("\n[TEST 6] Testing top boundary of northern forest canopies (Gambar 6)...")
	# Di atas hutan utara x=165, y=10, pemain mencoba jalan ke bawah (selatan) masuk ke kanopi
	player.global_position = Vector2(165, 10)
	for f in range(30):
		player.velocity = Vector2(0, 160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final y trying to enter north tree canopies from above:", player.global_position.y)
	assert(player.global_position.y <= 22.0, "Player must NOT walk into tree canopies from above! Got y=%f" % player.global_position.y)
	print("  -> PASS: Batas posisi berdiri MC di Gambar 6 terkunci rapi oleh dinding transparan (y=%.1f <= 22.0)" % player.global_position.y)

	# ─── TEST 7 (Gambar 1 User Terbaru): Batas Atas/Depan Hutan Kawasan Reboisasi Timur ───
	print("\n[TEST 7] Testing top boundary of eastern forest reboisasi (Gambar 1 user)...")
	# Dari atas batas x=760, y=2 jalan ke selatan masuk ke kanopi
	player.global_position = Vector2(760, 2)
	for f in range(30):
		player.velocity = Vector2(0, 160)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final y trying to enter eastern forest canopies:", player.global_position.y)
	assert(player.global_position.y <= 26.0, "Player must stop at top boundary of eastern forest! Got y=%f" % player.global_position.y)
	print("  -> PASS: Batas berdiri MC di Gambar 1 terkunci rapi (y=%.1f <= 26.0)" % player.global_position.y)

	# ─── TEST 8 (Gambar 2 User Terbaru): Batas Kanan Hutan Kawasan Reboisasi Timur dekat Pohon Kelapa ───
	print("\n[TEST 8] Testing right boundary of eastern forest near palm tree (Gambar 2 user)...")
	# Dari sisi kanan x=945, y=60 jalan ke barat (kiri) menuju pohon kelapa
	player.global_position = Vector2(945, 60)
	for f in range(30):
		player.velocity = Vector2(-160, 0)
		player.move_and_slide()
		await get_tree().physics_frame
	print("Player final x trying to enter eastern forest from right:", player.global_position.x)
	assert(player.global_position.x >= 930.0, "Player must NOT enter forest past palm tree! Got x=%f" % player.global_position.x)
	print("  -> PASS: Dinding transparan batas kanan dekat pohon kelapa di Gambar 2 terkunci rapi (x=%.1f >= 930.0)" % player.global_position.x)

	print("\n=======================================================")
	print("RESULT: ALL 8 BOUNDARY & REALISM TESTS PASSED PERFECTLY!")
	print("=======================================================")
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0)

