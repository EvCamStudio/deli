## Story Flow Verification Script
extends Node

var _pass: int = 0
var _fail: int = 0

func _check(cond: bool, msg: String) -> void:
	if cond:
		print("PASS: %s" % msg)
		_pass += 1
	else:
		push_error("FAIL: %s" % msg)
		_fail += 1

func _advance_dialog(choice_idx: int = 0) -> void:
	var safety: int = 0
	while DialogueManager.is_active() and safety < 100:
		safety += 1
		var node: Dictionary = DialogueManager._current_node
		var choices: Array = node.get("choices", [])
		if choices.is_empty():
			choices = node.get("pilihan", [])
		var chosen_idx: int = choice_idx
		if not choices.is_empty():
			for i in range(choices.size()):
				var c: Dictionary = choices[i]
				var req := str(c.get("requires_flag", ""))
				if not req.is_empty() and not bool(GameState.choices.get(req, false)):
					continue
				chosen_idx = i
				break
		DialogueManager.advance(chosen_idx)
		await get_tree().create_timer(0.05).timeout
	await get_tree().create_timer(0.3).timeout

func _ready() -> void:
	print("\n--- STARTING FULL STORY FLOW & MECHANICS VERIFICATION ---")
	call_deferred("_run_test")

func _run_test() -> void:
	GameState.reset()
	GameState.player_name = "Rian"
	GameState.choices["hulu_story_step"] = ""

	var world_scene := preload("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	get_tree().root.add_child(world)
	await get_tree().create_timer(0.3).timeout

	# 1. Talk to Bu Mira at warung (h1_warung)
	print("Step 1: Talking to Bu Mira at warung...")
	var ibu: Node = null
	for n in get_tree().get_nodes_in_group("world_npc"):
		if str(n.get("npc_key")) == "npc_ibu_mc":
			ibu = n
			break
	
	_check(ibu != null, "Bu Mira found at warung")
	if ibu:
		ibu.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	# 2. Verify cutscene TwoDaysCutscene (Time skip layar hitam)
	var cutscene = world.find_child("TwoDaysCutscene", true, false)
	_check(cutscene != null, "TwoDaysCutscene (Layar Hitam Waktu) is ACTIVE after h1_warung")

	# Finish black screen cutscene (Fade to world)
	world.advance_cutscene() # finish typewriter
	await get_tree().create_timer(0.1).timeout
	world.advance_cutscene() # trigger fade & complete
	await get_tree().create_timer(0.6).timeout

	# 3. Verify in-game narration box (Kotak Narasi Biasa)
	_check(DialogueManager.is_active(), "Kotak Narasi (h1_narasi_2hari) started in game world")
	await _advance_dialog(0)

	var step: String = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "butuh_pesan_kasur", "Step transitioned to butuh_pesan_kasur")

	# 4. Talk to Bu Mira for mattress quest (h1_warung_kasur)
	print("Step 4: Talking to Bu Mira for h1_warung_kasur...")
	if ibu:
		ibu.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "menuju_toko_jaya", "Step transitioned to menuju_toko_jaya")

	# 5. Move towards bridge
	print("Step 5: Moving player to bridge trigger...")
	world.player.global_position = Vector2(27.0, 16.5) * 16.0
	world._check_story_proximity()
	await get_tree().create_timer(0.2).timeout

	_check(DialogueManager.is_active(), "Bridge voice dialogue (h1_jembatan_suara) started")
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "cari_suara_jembatan", "Step transitioned to cari_suara_jembatan")

	# 6. Step onto bridge -> Datuk appears
	print("Step 6: Moving onto bridge -> Datuk appears...")
	world.player.global_position = Vector2(29.0, 16.5) * 16.0
	world._check_story_proximity()
	await get_tree().create_timer(0.2).timeout

	_check(DialogueManager.is_active(), "Datuk dialogue (h1_datuk) started")

	var datuk_npc: Node2D = null
	for n in get_tree().get_nodes_in_group("world_npc"):
		if str(n.get("npc_key")) == "npc_datuk":
			datuk_npc = n
			break
	_check(datuk_npc != null and datuk_npc.visible, "Datuk Sampan is visible on bridge")

	# Finish Datuk dialogue
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "bersihkan_sungai", "Step transitioned to bersihkan_sungai")
	_check(datuk_npc != null and not datuk_npc.visible, "Datuk Sampan disappeared after conversation")

	# 7. Verify riverbank trash spawned & pickup count
	var trash_nodes: Array = []
	for t in get_tree().get_nodes_in_group("world_trash"):
		if t is Node2D and t.is_inside_tree() and t.visible:
			trash_nodes.append(t)
	_check(trash_nodes.size() >= 5, "Riverbank trash spawned along Hulu riverbank (%d items)" % trash_nodes.size())

	# Pick up 2 trash items and verify counter
	world.on_trash_picked("plastik", "hulu_river_trash_0")
	world.on_trash_picked("organik", "hulu_river_trash_1")
	var cleaned_count: int = world._get_hulu_riverbank_trash_cleaned_count()
	_check(cleaned_count == 2, "Riverbank trash cleaned count updated to 2/5 on pickup")

	# Pick up remaining 3 trash items -> triggers h1_selesai_sungai!
	world.on_trash_picked("plastik", "hulu_river_trash_2")
	world.on_trash_picked("organik", "hulu_river_trash_3")
	world.on_trash_picked("plastik", "hulu_river_trash_4")
	await get_tree().create_timer(0.3).timeout

	_check(DialogueManager.is_active(), "Post-cleanup dialogue (h1_selesai_sungai) started automatically on 5/5")
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "tanam_pohon_hulu", "Step transitioned to tanam_pohon_hulu (Penjaga Hutan)")

	# 8. Penjaga Hutan mission (5 trees)
	var penjaga: Node = null
	for n in get_tree().get_nodes_in_group("world_npc"):
		if str(n.get("npc_key")) == "npc_penjaga_hutan":
			penjaga = n
			break
	_check(penjaga != null and penjaga.is_interactable_now(), "Penjaga Hutan is interactable")
	if penjaga:
		penjaga.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "menanam_pohon_hulu", "Step transitioned to menanam_pohon_hulu")

	# Plant 5 trees
	for i in range(5):
		world.on_tree_planted("tree")
	await get_tree().create_timer(0.3).timeout
	_check(penjaga.is_interactable_now(), "Penjaga Hutan is interactable after 5 trees planted")

	if penjaga:
		penjaga.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "ke_toko_jaya", "Step transitioned to ke_toko_jaya")
	_check(not penjaga.is_interactable_now(), "Penjaga Hutan is NOT interactable once finished")

	# 9. Move to Desa at Toko Jaya
	print("Step 9: Entering Desa at Toko Jaya...")
	world.change_zone("desa")
	await get_tree().create_timer(0.3).timeout

	world.player.global_position = world._zone_containers["desa"].global_position + Vector2(11.0, 15.0) * 16.0
	world._check_story_proximity()
	await get_tree().create_timer(0.2).timeout

	_check(DialogueManager.is_active(), "Toko Jaya confrontation (h1_toko_jaya) started")
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "pantun_kasur_darwis", "Step transitioned to pantun_kasur_darwis after Pak Darwis")

	# Find Desa Pantun Board
	var desa_board: Node = null
	for b in get_tree().get_nodes_in_group("pantun_board"):
		if b is Node2D and b.get_parent() == world._zone_containers["desa"]:
			desa_board = b
			break

	_check(world.get_guidance_target() == desa_board, "Guidance arrow points to Desa Pantun Board for Pak Darwis")
	if desa_board:
		desa_board.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	_check(bool(GameState.choices.get("unlock_solusi_darwis", false)) == true, "Pak Darwis pantun solution UNLOCKED!")

	# Now talk to Pak Darwis with unlocked solution
	var darwis_npc: Node = null
	var toko_npc: Node = null
	for n in get_tree().get_nodes_in_group("world_npc"):
		if str(n.get("npc_key")) == "npc_petani_1":
			darwis_npc = n
		elif str(n.get("npc_key")) == "npc_pemilik_toko":
			toko_npc = n

	_check(darwis_npc != null and darwis_npc.is_interactable_now(), "Pak Darwis is interactable for solution")
	if darwis_npc:
		darwis_npc.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "pulang_istirahat", "Step transitioned to pulang_istirahat after Toko Jaya")
	_check(not darwis_npc.is_interactable_now(), "Pak Darwis is NOT interactable after talk")
	_check(not toko_npc.is_interactable_now(), "Pemilik Toko is NOT interactable after talk")

	# 10. Return to Hulu home -> 1 Hari Kemudian cutscene
	print("Step 10: Returning to Hulu home...")
	world.change_zone("hulu")
	await get_tree().create_timer(0.3).timeout
	world.player.global_position = Vector2(8.0, 15.0) * 16.0
	world._check_story_proximity()
	await get_tree().create_timer(0.2).timeout

	var day_cutscene = world.find_child("TwoDaysCutscene", true, false)
	_check(day_cutscene != null, "Time-skip cutscene (1 Hari Kemudian) triggered on return home")
	world.advance_cutscene()
	await get_tree().create_timer(0.1).timeout
	world.advance_cutscene()
	await get_tree().create_timer(0.2).timeout

	_check(DialogueManager.is_active(), "Morning internal monolog (h2_narasi_pagi) started")
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "pesan_gorengan", "Step transitioned to pesan_gorengan")

	# Talk to Ibu to get gorengan quest
	if ibu:
		ibu.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "ke_warung_rina", "Step transitioned to ke_warung_rina")

	# 11. Go to Desa, talk to Kak Rina
	print("Step 11: Visiting Kak Rina at Desa...")
	world.change_zone("desa")
	await get_tree().create_timer(0.3).timeout

	var rina_npc: Node = null
	for n in get_tree().get_nodes_in_group("world_npc"):
		if str(n.get("npc_key")) == "npc_ibu_desa":
			rina_npc = n
			break
	_check(rina_npc != null and rina_npc.is_interactable_now(), "Kak Rina is interactable")
	if rina_npc:
		rina_npc.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "pantun_jelantah_rina", "Step transitioned to pantun_jelantah_rina after Kak Rina")
	_check(world.get_guidance_target() == desa_board, "Guidance arrow points to Desa Pantun Board for Kak Rina")

	# Solve Kak Rina pantun at Desa Pantun Board
	if desa_board:
		desa_board.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	_check(bool(GameState.choices.get("unlock_solusi_rina", false)) == true, "Kak Rina pantun solution UNLOCKED!")
	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "cari_solusi_jelantah", "Step transitioned to cari_solusi_jelantah after pantun")

	# 12. Talk to Pemuka Desa
	var pemuka_npc: Node = null
	for n in get_tree().get_nodes_in_group("world_npc"):
		if str(n.get("npc_key")) == "npc_pemuka_desa":
			pemuka_npc = n
			break
	_check(not world.can_gate_open("desa", "kota"), "Gate to Kota is LOCKED during cari_solusi_jelantah")
	_check(world.get_guidance_target() == pemuka_npc, "Guidance arrow points to Pemuka Desa")
	_check(pemuka_npc != null and pemuka_npc.is_interactable_now(), "Pemuka Desa is interactable")
	if pemuka_npc:
		pemuka_npc.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "serahkan_jeriken_rina", "Step transitioned to serahkan_jeriken_rina")
	_check(not pemuka_npc.is_interactable_now(), "Pemuka Desa is NOT interactable once finished")

	# 13. Deliver Jeriken to Kak Rina
	if rina_npc:
		rina_npc.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "antar_gorengan", "Step transitioned to antar_gorengan")
	_check(GameState.choices.get("rina_peduli") == true, "Kak Rina peduli flag is TRUE")
	_check(not rina_npc.is_interactable_now(), "Kak Rina is NOT interactable after completing mission")

	# 14. Return to Hulu, deliver gorengan to Ibu
	world.change_zone("hulu")
	await get_tree().create_timer(0.3).timeout
	if ibu:
		ibu.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "ke_kota_medan", "Step transitioned to ke_kota_medan")

	# 15. Transition to Kota Medan
	_check(world.can_gate_open("desa", "kota"), "Gate to Kota is UNLOCKED after delivering gorengan")
	world.change_zone("kota")
	await get_tree().create_timer(0.3).timeout

	# Check levers spawned in Kota
	var levers: Array[Node] = get_tree().get_nodes_in_group("pilot_lever")
	_check(levers.size() == 3, "Exactly 3 drainage levers spawned in Kota Medan")

	# Find Kota Pantun Board
	var kota_board: Node = null
	for b in get_tree().get_nodes_in_group("pantun_board"):
		if b is Node2D and b.get_parent() == world._zone_containers["kota"]:
			kota_board = b
			break

	# Check Bang Jali
	var jali_npc: Node = null
	var rt_npc: Node = null
	var ibu_kota: Node = null
	var budi_npc: Node = null
	for n in get_tree().get_nodes_in_group("world_npc"):
		match str(n.get("npc_key")):
			"npc_pedagang": jali_npc = n
			"npc_tokoh_masyarakat": rt_npc = n
			"npc_ibu_rumah": ibu_kota = n
			"npc_anak_sekolah": budi_npc = n

	_check(jali_npc != null and jali_npc.is_interactable_now(), "Bang Jali is interactable in Kota")
	if jali_npc:
		jali_npc.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "pantun_gang_jali", "Step transitioned to pantun_gang_jali after talking to Bang Jali")
	_check(world.get_guidance_target() == kota_board, "Guidance arrow points to Kota Pantun Board for Bang Jali")

	# Solve Bang Jali pantun at Kota Pantun Board
	if kota_board:
		kota_board.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	_check(bool(GameState.choices.get("unlock_solusi_jali", false)) == true, "Bang Jali pantun solution UNLOCKED!")
	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "cari_solusi_rt", "Step transitioned to cari_solusi_rt after pantun")

	# 16. Talk to Pak RT
	_check(world.get_guidance_target() == rt_npc, "Guidance arrow points to Pak RT")
	_check(rt_npc != null and rt_npc.is_interactable_now(), "Pak RT is interactable")
	if rt_npc:
		rt_npc.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "serahkan_gerobak_jali", "Step transitioned to serahkan_gerobak_jali after Pak RT")

	# 17. Return to Bang Jali
	if jali_npc:
		jali_npc.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "periksa_saluran_kota", "Step transitioned to periksa_saluran_kota after Bang Jali agreement")

	# 18. Talk to Ibu Rumah Tangga
	_check(ibu_kota != null and ibu_kota.is_interactable_now(), "Ibu Rumah Tangga is interactable")
	if ibu_kota:
		ibu_kota.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "pintu_air_dan_b3", "Step transitioned to pintu_air_dan_b3 after Ibu Rumah Tangga")

	# Find Kota Pantun Board again for Pintu Air
	for b in get_tree().get_nodes_in_group("pantun_board"):
		if b is Node2D and b.get_parent() == world._zone_containers["kota"]:
			kota_board = b
			break

	_check(world.get_guidance_target() == kota_board, "Guidance arrow points to Kota Pantun Board before reading")

	# Levers cannot be pulled before solving pantun cipher
	var l1: Node = null
	var l2: Node = null
	var l3: Node = null
	for l in levers:
		match int(l.get("lever_id")):
			1: l1 = l
			2: l2 = l
			3: l3 = l

	if l1:
		l1.interact()
	_check(bool(GameState.choices.get("pintu_air_terbuka", false)) == false, "Levers locked before solving Pantun")

	# 19. Read and solve Pantun at Zebra Cross
	if kota_board:
		kota_board.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	_check(bool(GameState.choices.get("sandi_tuas_terbuka", false)) == true, "Pantun cipher solved successfully!")

	# 20. Now pull Levers in sequence 1 -> 3 -> 2
	_check(world.get_guidance_target() == l1, "Guidance arrow points to Lever 1 (Depan)")
	if l1:
		l1.interact()
	_check(world.get_guidance_target() == l3, "Guidance arrow points to Lever 3 (Belakang)")
	if l3:
		l3.interact()
	_check(world.get_guidance_target() == l2, "Guidance arrow points to Lever 2 (Tengah)")
	if l2:
		l2.interact()

	_check(bool(GameState.choices.get("pintu_air_terbuka", false)) == true, "Pintu air is OPEN!")
	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "tanya_budi", "Step transitioned to tanya_budi after drainage levers opened")

	# 20. Talk to Budi (Anak Sekolah)
	_check(world.get_guidance_target() == budi_npc, "Guidance arrow points to Budi")
	_check(budi_npc != null and budi_npc.is_interactable_now(), "Budi is interactable")
	if budi_npc:
		budi_npc.interact()
	await get_tree().create_timer(0.2).timeout
	await _advance_dialog(0)

	step = str(GameState.choices.get("hulu_story_step", ""))
	_check(step == "ke_hilir_muara", "Step transitioned to ke_hilir_muara after Budi explains pantun")
	_check(world.can_gate_open("kota", "hilir"), "Gate to Hilir is UNLOCKED!")

	print("\n===============================")
	print("TEST RESULT: %d PASS, %d FAIL" % [_pass, _fail])
	print("===============================\n")

	if _fail == 0:
		get_tree().quit(0)
	else:
		get_tree().quit(1)
