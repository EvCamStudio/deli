## Uji alur progresi end-to-end tanpa input pemain.
## Memastikan target misi, gate, threshold air, dan save/load konsisten.
extends Node

var _fail: int = 0
var _pass: int = 0

func _ready() -> void:
	call_deferred("_run")

func _check(condition: bool, label: String) -> void:
	if condition:
		_pass += 1
		print("PASS  ", label)
	else:
		_fail += 1
		print("FAIL  ", label)

func _frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _gate_for(world: Node, target: String) -> Node:
	for gate in get_tree().get_nodes_in_group("zone_gate"):
		if str(gate.get("target_zone")) == target:
			return gate
	return null

func _bins_in(world: Node, zone: String) -> Array:
	var out: Array = []
	var container := world.get_node_or_null("Zone" + zone.capitalize())
	if container == null:
		return out
	for child in container.get_children():
		if child.is_in_group("world_bin"):
			out.append(child)
	return out

func _sort_with_bin(world: Node, zone: String, count: int) -> void:
	var bins: Array = _bins_in(world, zone)
	if bins.is_empty():
		return
	for i in range(count):
		var bin: Node = bins[i % bins.size()]
		var cat: String = str(bin.get("bin_category"))
		GameState.set_meta("pending_trash", [{"category": cat, "trash_id": "test_%d" % i}])
		bin.call("interact")

func _tree_spots(world: Node, zone: String, kind: String) -> Array:
	var out: Array = []
	var container := world.get_node_or_null("Zone" + zone.capitalize())
	if container == null:
		return out
	for child in container.get_children():
		if child.is_in_group("tree_spot") and str(child.get("kind")) == kind:
			out.append(child)
	return out

func _run() -> void:
	GameState.reset()
	GameState.quest_progress = 1
	QuestManager.start_main_quest()

	var world: Node = load("res://scenes/world/world_sungai_deli.tscn").instantiate()
	get_tree().root.add_child(world)
	await _frames(10)

	# ── HULU ────────────────────────────────────────────────────────────────
	GameState.start_quest("tanam_pohon_hulu", 5)
	var hulu_trees: Array = _tree_spots(world, "hulu", "tree")
	_check(hulu_trees.size() >= 5, "Hulu punya minimal 5 titik tanam (ada %d)" % hulu_trees.size())
	for spot in hulu_trees:
		spot.call("interact")
		await _frames(1)
	_check(GameState.zone_stat("hulu", "trees") >= 5, "Hulu: 5 pohon tercatat")
	_check(GameState.river_health >= 40.0, "Hulu: air >= 40%% (%.1f)" % GameState.river_health)
	_check(world.call("is_zone_cleared", "hulu"), "Hulu: misi selesai")
	await _frames(2)
	var gate_desa: Node = _gate_for(world, "desa")
	_check(gate_desa != null and bool(gate_desa.call("is_open")), "Hulu: gerbang desa terbuka")

	# ── DESA ────────────────────────────────────────────────────────────────
	world.call("change_zone", "desa")
	GameState.start_quest("pilah_desa", 10)
	_sort_with_bin(world, "desa", 10)
	world.call("on_npc_talked", "npc_petani_1")
	world.call("on_npc_talked", "npc_ibu_desa")
	await _frames(2)
	_check(GameState.zone_stat("desa", "sorted") >= 10, "Desa: 10 sampah dipilah")
	_check(GameState.zone_talked_count("desa") >= 2, "Desa: 2 warga diajak bicara")
	_check(world.call("is_zone_cleared", "desa"), "Desa: misi selesai")
	var gate_kota: Node = _gate_for(world, "kota")
	_check(gate_kota != null and bool(gate_kota.call("is_open")), "Desa: gerbang kota terbuka")

	# ── KOTA ────────────────────────────────────────────────────────────────
	world.call("change_zone", "kota")
	GameState.start_quest("pilah_sampah_kota", 6)
	_sort_with_bin(world, "kota", 6)
	world.call("on_npc_talked", "npc_pedagang")
	world.call("on_npc_talked", "npc_ibu_rumah")
	world.call("on_npc_talked", "npc_anak_sekolah")
	world.call("on_npc_talked", "npc_tokoh_masyarakat")
	await _frames(2)
	_check(GameState.zone_stat("kota", "sorted") >= 6, "Kota: 6 sampah dipilah")
	_check(GameState.zone_talked_count("kota") >= 4, "Kota: 4 warga diajak bicara")
	_check(world.call("is_zone_cleared", "kota"), "Kota: misi selesai")
	var gate_hilir: Node = _gate_for(world, "hilir")
	_check(gate_hilir != null and bool(gate_hilir.call("is_open")), "Kota: gerbang hilir terbuka")

	# ── HILIR ───────────────────────────────────────────────────────────────
	world.call("change_zone", "hilir")
	GameState.start_quest("tanam_mangrove", 8)
	var mangroves: Array = _tree_spots(world, "hilir", "mangrove")
	_check(mangroves.size() >= 8, "Hilir punya minimal 8 titik mangrove (ada %d)" % mangroves.size())
	for spot in mangroves:
		spot.call("interact")
		await _frames(1)
	GameState.start_quest("pilah_hilir", 10)
	_sort_with_bin(world, "hilir", 10)
	world.call("on_npc_talked", "npc_nelayan")
	world.call("on_npc_talked", "npc_penjaga_sungai")
	await _frames(2)
	_check(GameState.zone_stat("hilir", "mangroves") >= 8, "Hilir: 8 mangrove ditanam")
	_check(GameState.zone_stat("hilir", "sorted") >= 10, "Hilir: 10 sampah dipilah")
	_check(GameState.zone_talked_count("hilir") >= 2, "Hilir: 2 warga diajak bicara")
	_check(world.call("is_zone_cleared", "hilir"), "Hilir: misi selesai")
	_check(GameState.river_health >= 80.0, "Hilir: air >= 80%% (%.1f)" % GameState.river_health)
	_check(world.call("can_finish_journey"), "Hilir: perjalanan bisa diselesaikan")

	# ── Gate tidak menutup kembali ──────────────────────────────────────────
	GameState.river_health = 0.0
	gate_desa.call("refresh_gate_state")
	_check(bool(gate_desa.call("is_open")), "Gate yang sudah terbuka tidak menutup lagi")
	GameState.river_health = 100.0

	# ── Save / load ─────────────────────────────────────────────────────────
	var saved_zone: String = GameState.world_zone
	var saved_hilir_sorted: int = GameState.zone_stat("hilir", "sorted")
	var saved_mangrove: int = GameState.zone_stat("hilir", "mangroves")
	GameState.save_game()
	GameState.zone_progress = {}
	GameState.world_zone = "hulu"
	GameState.river_health = 0.0
	var loaded: bool = GameState.load_game()
	_check(loaded, "Save game bisa dimuat")
	_check(GameState.world_zone == saved_zone, "Save/load: zona terakhir pulih (%s)" % GameState.world_zone)
	_check(GameState.zone_stat("hilir", "sorted") == saved_hilir_sorted, "Save/load: progres sampah hilir pulih")
	_check(GameState.zone_stat("hilir", "mangroves") == saved_mangrove, "Save/load: progres mangrove pulih")
	_check(GameState.river_health >= 80.0, "Save/load: kesehatan sungai pulih")

	GameState.delete_save()
	print("RESULT: %d PASS, %d FAIL" % [_pass, _fail])
	get_tree().quit(1 if _fail > 0 else 0)
