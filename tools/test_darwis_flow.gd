extends Node

var total_checks := 0
var passed_checks := 0
var failed_checks := 0

func _check(condition: bool, msg: String) -> void:
	total_checks += 1
	if condition:
		passed_checks += 1
		print("  [PASS] ", msg)
	else:
		failed_checks += 1
		printerr("  [FAIL] ", msg)

func _ready() -> void:
	print("\n=== TESTING PAK DARWIS DIALOGUE & CHOICE PERSISTENCE ===")
	call_deferred("_run_tests")

func _advance_dialog(chosen_idx: int = 0) -> void:
	var safety: int = 0
	while DialogueManager.is_active() and safety < 100:
		safety += 1
		var node: Dictionary = DialogueManager._current_node
		var choices: Array = node.get("choices", [])
		if choices.is_empty():
			choices = node.get("pilihan", [])
		var idx_to_use: int = 0
		if not choices.is_empty():
			idx_to_use = chosen_idx
			# if chosen_idx out of bounds or requires locked flag, fallback to next valid
			if idx_to_use >= choices.size() or (choices[idx_to_use].has("requires_flag") and not bool(GameState.choices.get(str(choices[idx_to_use]["requires_flag"]), false))):
				for i in range(choices.size()):
					var c: Dictionary = choices[i]
					var req := str(c.get("requires_flag", ""))
					if not req.is_empty() and not bool(GameState.choices.get(req, false)):
						continue
					idx_to_use = i
					break
		DialogueManager.advance(idx_to_use)
		await get_tree().create_timer(0.02).timeout
	await get_tree().create_timer(0.05).timeout

func _run_tests() -> void:
	# -------------------------------------------------------------
	# SCENARIO 1: Pemain Memilih [B] (Cari Solusi) -> Pantun -> [A]
	# -------------------------------------------------------------
	print("\n--- TEST SCENARIO 1: Pilihan B (Cari Solusi) -> Pantun -> Pilihan A (Solusi) ---")
	GameState.reset()
	GameState.choices["hulu_story_step"] = "ke_toko_jaya"
	
	var world_scene := preload("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	get_tree().root.add_child(world)
	await get_tree().create_timer(0.2).timeout
	world.change_zone("desa")
	await get_tree().create_timer(0.2).timeout
	
	var darwis: Node = null
	for n in get_tree().get_nodes_in_group("world_npc"):
		if str(n.get("npc_key")) == "npc_petani_1":
			darwis = n
			break
	
	_check(darwis != null, "Pak Darwis found in Desa")
	_check(darwis.is_interactable_now(), "Pak Darwis is interactable initially")
	_check(darwis.get_target_dialog_id() == "h1_toko_jaya", "Initial dialogue is h1_toko_jaya")
	
	# Interaksi 1: Memilih Opsi B (index 1 pada datuk_dorong_solusi)
	darwis.interact()
	await get_tree().create_timer(0.05).timeout
	_check(DialogueManager.is_active(), "Dialogue h1_toko_jaya started")
	
	# Advance dialog with choice index 1 (Option B: Tunggu di sini sebentar ya, Pak!)
	await _advance_dialog(1)
	
	_check(not DialogueManager.is_active(), "Dialogue finished after choosing B")
	_check(bool(GameState.choices.get("mencari_solusi_darwis", false)) == true, "Flag mencari_solusi_darwis recorded TRUE")
	_check(str(GameState.choices.get("hulu_story_step", "")) == "pantun_kasur_darwis", "Story step is now pantun_kasur_darwis")
	_check(bool(GameState.choices.get("darwis_done", false)) == false, "darwis_done is FALSE (user can come back with solution)")
	
	# Cek interaksi perantara (sebelum pantun selesai): dialog harus h1_darwis_menunggu, TIDAK mengulang curhat 10 baris!
	world._sync_hulu_story_state()
	_check(darwis.get_target_dialog_id() == "h1_darwis_menunggu", "Dialogue during pantun search is h1_darwis_menunggu (no repeating intro)")
	
	# Selesaikan Papan Pantun
	var desa_board: Node = null
	for b in get_tree().get_nodes_in_group("pantun_board"):
		if b is Node2D and b.get_parent() == world._zone_containers["desa"]:
			desa_board = b
			break
	_check(desa_board != null, "Desa Pantun Board found")
	if desa_board:
		desa_board.interact()
	await get_tree().create_timer(0.05).timeout
	await _advance_dialog(0)
	
	_check(bool(GameState.choices.get("unlock_solusi_darwis", false)) == true, "unlock_solusi_darwis is TRUE after pantun")
	_check(str(GameState.choices.get("hulu_story_step", "")) == "ke_toko_jaya", "Step returned to ke_toko_jaya")
	
	# Kembali ke Pak Darwis setelah pantun: dialog harus h6_darwis (resolution)
	world._sync_hulu_story_state()
	_check(darwis.get_target_dialog_id() == "h6_darwis", "Dialogue after pantun is h6_darwis (direct resolution)")
	_check(darwis.is_interactable_now(), "Pak Darwis is interactable to receive solution")
	
	darwis.interact()
	await get_tree().create_timer(0.05).timeout
	_check(DialogueManager.is_active(), "Resolution dialogue h6_darwis started")
	await _advance_dialog(0) # Pilih [A]
	
	_check(bool(GameState.choices.get("darwis_peduli", false)) == true, "darwis_peduli is TRUE")
	_check(bool(GameState.choices.get("darwis_done", false)) == true, "darwis_done is TRUE")
	_check(str(GameState.choices.get("hulu_story_step", "")) == "pulang_istirahat", "Step advanced to pulang_istirahat")
	_check(not darwis.is_interactable_now(), "Pak Darwis is NO LONGER interactable after completion")
	
	world.queue_free()
	await get_tree().create_timer(0.2).timeout
	
	# -------------------------------------------------------------
	# SCENARIO 2: Pemain Memilih [C] (Lain kali bawa ke TPA saja)
	# Keputusan FINAL: Gagal, darwis_done = true, tidak bisa diubah!
	# -------------------------------------------------------------
	print("\n--- TEST SCENARIO 2: Pilihan C (Gagal) -> Keputusan FINAL & Tidak Bisa Diubah ---")
	GameState.reset()
	GameState.choices["hulu_story_step"] = "ke_toko_jaya"
	
	world = world_scene.instantiate()
	get_tree().root.add_child(world)
	await get_tree().create_timer(0.2).timeout
	world.change_zone("desa")
	await get_tree().create_timer(0.2).timeout
	
	darwis = null
	for n in get_tree().get_nodes_in_group("world_npc"):
		if str(n.get("npc_key")) == "npc_petani_1":
			darwis = n
			break
	
	darwis.interact()
	await get_tree().create_timer(0.05).timeout
	# Pilih index 2 (Option C: Lain kali Bapak paksakan bawa ke TPA saja...)
	await _advance_dialog(2)
	
	_check(bool(GameState.choices.get("darwis_peduli", false)) == false, "darwis_peduli is FALSE (Option C chosen)")
	_check(bool(GameState.choices.get("darwis_menolak", false)) == true, "darwis_menolak is TRUE")
	_check(bool(GameState.choices.get("darwis_done", false)) == true, "darwis_done is TRUE (FINAL!)")
	_check(str(GameState.choices.get("hulu_story_step", "")) == "pulang_istirahat", "Step advanced to pulang_istirahat directly (NOT looped back to pantun!)")
	_check(not darwis.is_interactable_now(), "Pak Darwis is NO LONGER interactable (jawaban C tidak bisa diubah lagi)")
	_check(GameState.get_sikap("darwis") == GameState.SIKAP_MENOLAK, "Darwis sikap is MENOLAK")
	
	world.queue_free()
	await get_tree().create_timer(0.2).timeout
	
	# -------------------------------------------------------------
	# SCENARIO 3: Pemain Memilih [D] (Keras Kepala / Lapor Lurah)
	# Keputusan FINAL: Gagal, darwis_done = true, tidak bisa diubah!
	# -------------------------------------------------------------
	print("\n--- TEST SCENARIO 3: Pilihan D (Gagal) -> Keputusan FINAL & Tidak Bisa Diubah ---")
	GameState.reset()
	GameState.choices["hulu_story_step"] = "ke_toko_jaya"
	
	world = world_scene.instantiate()
	get_tree().root.add_child(world)
	await get_tree().create_timer(0.2).timeout
	world.change_zone("desa")
	await get_tree().create_timer(0.2).timeout
	
	darwis = null
	for n in get_tree().get_nodes_in_group("world_npc"):
		if str(n.get("npc_key")) == "npc_petani_1":
			darwis = n
			break
	
	darwis.interact()
	await get_tree().create_timer(0.05).timeout
	# Pilih index 3 (Option D: Orang tua zaman sekarang memang keras kepala!)
	await _advance_dialog(3)
	
	_check(bool(GameState.choices.get("darwis_peduli", false)) == false, "darwis_peduli is FALSE (Option D chosen)")
	_check(bool(GameState.choices.get("darwis_menolak", false)) == true, "darwis_menolak is TRUE")
	_check(bool(GameState.choices.get("darwis_done", false)) == true, "darwis_done is TRUE (FINAL!)")
	_check(str(GameState.choices.get("hulu_story_step", "")) == "pulang_istirahat", "Step advanced to pulang_istirahat directly (NOT looped back to pantun!)")
	_check(not darwis.is_interactable_now(), "Pak Darwis is NO LONGER interactable (jawaban D tidak bisa diubah lagi)")
	_check(GameState.get_sikap("darwis") == GameState.SIKAP_MENOLAK, "Darwis sikap is MENOLAK")
	
	world.queue_free()
	
	print("\n=======================================================")
	print("TOTAL CHECKS: %d | PASSED: %d | FAILED: %d" % [total_checks, passed_checks, failed_checks])
	if failed_checks == 0:
		print("SUCCESS: ALL PAK DARWIS TESTS PASSED PERFECTLY!")
	else:
		printerr("FAILURE: %d CHECKS FAILED!" % failed_checks)
	print("=======================================================\n")
	get_tree().quit(0 if failed_checks == 0 else 1)
