## Level 3 Kota Medan — pilot top-down ala Citampi.
extends LevelBase

const NPC_SCENE := preload("res://scenes/world/npc_topdown.tscn")
const TRASH_SCENE := preload("res://scenes/world/trash_topdown.tscn")
const BIN_SCENE := preload("res://scenes/world/bin_topdown.tscn")
const LEVER_SCENE := preload("res://scenes/world/lever_topdown.tscn")
const GATE_SCENE := preload("res://scenes/world/gate_topdown.tscn")
const BOARD_SCENE := preload("res://scenes/world/pantun_board.tscn")

var _lever_sequence: Array[int] = [1, 3, 2]
var _lever_pressed: Array[int] = []
var _gate_open: bool = false
var _pantun_done: bool = false
var _gate: Node = null

func _ready() -> void:
	level_id = 3
	river_health_target = 55.0
	bgm_key = 3
	camera_topdown = true
	auto_advance = false
	super._ready()
	_spawn_entities()

func _set_initial_mission() -> void:
	if hud and hud.has_method("update_mission"):
		hud.update_mission("Bersihkan sampah, pilah ke tong, lalu tarik tuas 1-3-2.")

func _spawn_entities() -> void:
	# NPC — posisi di depan bangunan dan area publik.
	_spawn_npc("npc_pedagang", "pedagang", Vector2(136, 160))
	_spawn_npc("npc_ibu_rumah", "ibu", Vector2(480, 160))
	_spawn_npc("npc_anak_sekolah", "budi", Vector2(320, 184))
	_spawn_npc("npc_tokoh_masyarakat", "pakrt", Vector2(700, 184))

	# Sampah di air dan di bantaran.
	_spawn_trash("kulit_pisang", "organik", Vector2(192, 304))
	_spawn_trash("botol_plastik", "plastik", Vector2(480, 288))
	_spawn_trash("baterai_bekas", "b3", Vector2(608, 320))
	_spawn_trash("kantong_kresek", "plastik", Vector2(736, 272))
	_spawn_trash("daun_kering", "organik", Vector2(256, 224))
	_spawn_trash("kaleng_bekas", "plastik", Vector2(528, 368))

	# Tiga tong pilah di jalur utama.
	_spawn_bin("organik", Vector2(216, 208))
	_spawn_bin("plastik", Vector2(544, 208))
	_spawn_bin("b3", Vector2(752, 208))

	# Tuas drainase.
	_spawn_lever(1, Vector2(816, 224))
	_spawn_lever(2, Vector2(912, 224))
	_spawn_lever(3, Vector2(864, 352))

	# Papan pantun di dekat jembatan.
	var board := BOARD_SCENE.instantiate()
	board.position = Vector2(384, 224)
	add_child(board)

	# Gerbang akhir.
	_gate = GATE_SCENE.instantiate()
	_gate.position = Vector2(928, 160)
	_gate.closed_hint = "Drainase masih tertutup. Tarik tuas 1-3-2."
	add_child(_gate)

func _spawn_npc(dialogue_key: String, sprite_key: String, pos: Vector2) -> void:
	var npc := NPC_SCENE.instantiate()
	npc.position = pos
	npc.npc_key = dialogue_key
	npc.sprite_key = sprite_key
	npc.level_id = 3
	add_child(npc)

func _spawn_trash(trash_id: String, category: String, pos: Vector2) -> void:
	var trash := TRASH_SCENE.instantiate()
	trash.position = pos
	trash.trash_id = trash_id
	trash.category = category
	add_child(trash)

func _spawn_bin(category: String, pos: Vector2) -> void:
	var bin := BIN_SCENE.instantiate()
	bin.position = pos
	bin.bin_category = category
	add_child(bin)

func _spawn_lever(id: int, pos: Vector2) -> void:
	var lever := LEVER_SCENE.instantiate()
	lever.position = pos
	lever.lever_id = id
	add_child(lever)

# ─── Callback gameplay ───────────────────────────────────────────────────────

func on_trash_picked(category: String, _trash_id: String) -> void:
	GameState.rupiah += 500
	toast("Sampah %s dipungut. +Rp500" % category, true)

func on_bin_sorted(_category: String) -> void:
	toast("Sampah terpilah! Sungai membaik.", true)
	if GameState.get_total_trash() >= 4 and hud:
		hud.update_mission("Bagus! Lanjut tarik tuas 1-3-2 di drainase timur.")

func lever_pressed(lever_id: int) -> void:
	_lever_pressed.append(lever_id)
	for i in range(_lever_pressed.size()):
		if _lever_pressed[i] != _lever_sequence[i]:
			_lever_pressed.clear()
			GameState.add_river_health(-2.0)
			_reset_levers()
			toast("Urutan tuas salah! Mulai dari tuas 1.", false)
			return
	if _lever_pressed.size() == _lever_sequence.size():
		_open_gate()
	else:
		if hud:
			hud.update_mission("Tuas benar %d/3. Lanjutkan urutan." % _lever_pressed.size())
		toast("Tuas %d benar." % lever_id, true)

func _reset_levers() -> void:
	for lever in get_tree().get_nodes_in_group("pilot_lever"):
		if lever.has_method("reset_lever"):
			lever.reset_lever()

func _open_gate() -> void:
	if _gate_open:
		return
	_gate_open = true
	GameState.add_river_health(10.0)
	GameState.rupiah += 2500
	GameState.unlock_card("card_drainase_01")
	AudioManager.play_sfx("correct")
	if _gate and _gate.has_method("open"):
		_gate.open()
	toast("Drainase terbuka! +Rp2.500", true)
	if hud:
		hud.update_mission("Gerbang kota terbuka. Selesaikan misi di ujung timur.")

func open_pantun() -> void:
	if _pantun_done:
		toast("Pantun sudah lengkap. Terima kasih, Budi!", true)
		return
	var panel := get_node_or_null("PantunPanel")
	if panel and panel.has_method("start"):
		panel.start()

func on_pantun_completed() -> void:
	if _pantun_done:
		return
	_pantun_done = true
	GameState.add_river_health(8.0)
	GameState.rupiah += 2000
	GameState.unlock_card("card_pantun_01")
	toast("Pantun lengkap! +Rp2.000", true)
	if hud:
		hud.update_mission("Pantun terjaga. Buka drainase dengan tuas 1-3-2.")

func try_complete_level() -> void:
	if not _gate_open:
		toast("Drainase masih tertutup. Tarik tuas 1-3-2.", false)
		return
	if GameState.river_health < river_health_target:
		toast("Kejernihan baru %d%%. Butuh %d%%." % [int(GameState.river_health), int(river_health_target)], false)
		if hud:
			hud.update_mission("Bersihkan lebih banyak sampah (target %d%%)." % int(river_health_target))
		return
	GameState.complete_level(level_id)
