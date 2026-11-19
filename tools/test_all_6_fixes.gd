extends Node

func _ready() -> void:
	GameState.player_name = "Yura"
	var world_scene := preload("res://scenes/world/world_sungai_deli.tscn")
	var world: WorldSungaiDeli = world_scene.instantiate()
	add_child(world)
	_run(world)

func _run(world: WorldSungaiDeli) -> void:
	for i in range(25):
		await get_tree().process_frame

	print("\n=== STARTING VERIFICATION OF ALL 6 FIXES ===")
	var pass_count: int = 0
	var fail_count: int = 0

	# -------------------------------------------------------------
	# TEST 5: Mamak Dialogue Portrait
	# -------------------------------------------------------------
	var diag = world.get_node_or_null("DialogueBox")
	if diag and diag.has_method("_update_portrait"):
		diag._update_portrait({"speaker": "Mamak", "emotion": "neutral"})
		var tex: Texture2D = diag.portrait.texture
		if tex and "ibu" in tex.resource_path:
			print("PASS [Fix 5]: 'Mamak' speaker loads ibu portrait (%s)" % tex.resource_path)
			pass_count += 1
		else:
			print("FAIL [Fix 5]: 'Mamak' loaded unexpected texture: %s" % (tex.resource_path if tex else "null"))
			fail_count += 1
	else:
		print("FAIL [Fix 5]: DialogueBox not found")
		fail_count += 1

	# -------------------------------------------------------------
	# TEST 6: Map 1 (Hulu) Pantun Board tile hole fixed
	# -------------------------------------------------------------
	world.change_zone("hulu")
	for i in range(15):
		await get_tree().process_frame
	var hulu = world._zone_containers["hulu"]
	var hulu_map: TopdownMap = null
	for c in hulu.get_children():
		if c is TopdownMap: hulu_map = c; break
	if hulu_map:
		var c17_13 = hulu_map.ground.get_cell_atlas_coords(Vector2i(17, 13))
		if c17_13 != Vector2i(7, 3):
			print("PASS [Fix 6]: Tile (17, 13) in Hulu no longer has the hole cutout (atlas=%s)" % str(c17_13))
			pass_count += 1
		else:
			print("FAIL [Fix 6]: Tile (17, 13) still has broken atlas coords (7, 3)")
			fail_count += 1

	# -------------------------------------------------------------
	# TEST 4: Map 2 (Desa) Warung Barokah NOT a trash bin
	# -------------------------------------------------------------
	world.change_zone("desa")
	for i in range(15):
		await get_tree().process_frame
	var desa = world._zone_containers["desa"]
	# Move player in front of Warung Barokah at (430, 390)
	world.player.global_position = desa.global_position + Vector2(430, 390)
	for i in range(15):
		await get_tree().process_frame
	var inter = world.player._interactable
	if inter == null or not (inter is PilotBin):
		print("PASS [Fix 4]: Warung Barokah is clean, NOT interactable as trash bin (interactable=%s)" % str(inter))
		pass_count += 1
	else:
		print("FAIL [Fix 4]: Warung Barokah still has trash bin interactable: %s" % str(inter))
		fail_count += 1

	# -------------------------------------------------------------
	# TEST 3: Map 3 (Kota) Tuas 3 accessible in open plaza
	# -------------------------------------------------------------
	world.change_zone("kota")
	for i in range(15):
		await get_tree().process_frame
	world.player.global_position = kota_origin_pos(world) + Vector2(864, 396)
	for i in range(15):
		await get_tree().process_frame
	var lever_inter = world.player._interactable
	if lever_inter and lever_inter is Area2D and lever_inter.get("lever_id") == 3:
		print("PASS [Fix 3]: Tuas 3 in Kota plaza is fully accessible & interactable ([%s])" % lever_inter.get_action_label())
		pass_count += 1
	else:
		print("FAIL [Fix 3]: Tuas 3 interactable failed, got: %s" % str(lever_inter))
		fail_count += 1

	# -------------------------------------------------------------
	# TEST 2: Map 4 (Hilir) Trash mission with colored bins (target 6)
	# -------------------------------------------------------------
	world.change_zone("hilir")
	for i in range(15):
		await get_tree().process_frame
	var hilir_target: int = world.zone_target("hilir", "sorted")
	if hilir_target == 6:
		print("PASS [Fix 2]: Hilir sorted trash target synchronized to 6")
		pass_count += 1
	else:
		print("FAIL [Fix 2]: Hilir target expected 6, got %d" % hilir_target)
		fail_count += 1

	var hilir = world._zone_containers["hilir"]
	var bins = []
	for b in get_tree().get_nodes_in_group("world_bin"):
		if b.get_parent() == hilir:
			bins.append(b)
	print("Found %d bins in Hilir" % bins.size())
	var has_org = false; var has_plas = false; var has_b3 = false
	for b in bins:
		if b.bin_category == "organik": has_org = true
		elif b.bin_category in ["plastik", "anorganik"]: has_plas = true
		elif b.bin_category == "b3": has_b3 = true
	if has_org and has_plas and has_b3:
		print("PASS [Fix 2]: Hilir contains all 3 distinct colored bins: Organik, Plastik, B3")
		pass_count += 1
	else:
		print("FAIL [Fix 2]: Missing colored bins in Hilir (org:%s plas:%s b3:%s)" % [has_org, has_plas, has_b3])
		fail_count += 1

	# -------------------------------------------------------------
	# TEST 1: Map 4 (Hilir) Pak Nelayan interactable after 8 mangroves
	# -------------------------------------------------------------
	GameState.record_choice("hulu_story_step", "selesai_mangrove")
	GameState.add_zone_stat("hilir", "mangroves", 8)
	GameState.record_choice("nelayan_selesai", false)
	world._sync_hulu_story_state()
	world._refresh_mission()
	world._update_guidance()

	var nelayan_npc = world._npc_by_key("npc_nelayan")
	if nelayan_npc and nelayan_npc.has_method("is_interactable_now"):
		var can_talk: bool = nelayan_npc.is_interactable_now()
		if can_talk:
			print("PASS [Fix 1]: Pak Nelayan is_interactable_now() is TRUE on step selesai_mangrove with 8 mangroves")
			pass_count += 1
		else:
			print("FAIL [Fix 1]: Pak Nelayan is_interactable_now() returned FALSE")
			fail_count += 1

		# Walk player right to Pak Nelayan
		world.player.global_position = nelayan_npc.global_position + Vector2(0, 16)
		for i in range(15):
			await get_tree().process_frame
		var n_inter = world.player._interactable
		if n_inter == nelayan_npc:
			print("PASS [Fix 1]: Player is interacting with Pak Nelayan! Action label: [%s]" % n_inter.get_action_label())
			pass_count += 1
		else:
			print("FAIL [Fix 1]: Player interactable is not Pak Nelayan, got: %s" % str(n_inter))
			fail_count += 1

	# Save screenshot of player talking to Pak Nelayan
	var base_dir := "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8"
	var img: Image = get_viewport().get_texture().get_image()
	if img:
		img.save_png(base_dir + "/verify_nelayan_interaction_fixed.png")
		print("Saved verify_nelayan_interaction_fixed.png")

	print("\n==========================================")
	print("ALL FIXES VERIFICATION: %d PASS, %d FAIL" % [pass_count, fail_count])
	print("==========================================\n")
	get_tree().quit()

func kota_origin_pos(world) -> Vector2:
	return world._zone_containers["kota"].global_position
