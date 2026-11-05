## Level 4 Hilir — top-down pesisir dan muara.
## Misi: tanam 8 mangrove, pilah 8 sampah, dan bicara dengan 2 warga.
extends TopdownLevelBase

const MANGROVE_TARGET: int = 8
const TRASH_TARGET: int = 8
const NPC_TARGET: int = 2

var _sorted: int = 0
var _mangroves: int = 0

func _ready() -> void:
	level_id = 4
	river_health_target = 85.0
	bgm_key = 4
	super._ready()
	_spawn_entities()

func _set_initial_mission() -> void:
	update_mission("Tanam 8 mangrove dan bersihkan pesisir.")

func _spawn_entities() -> void:
	spawn_npc("npc_nelayan", "nelayan", Vector2(200, 236))
	spawn_npc("npc_penjaga_sungai", "pakrt", Vector2(680, 236))

	for pos in [
		Vector2(200, 424), Vector2(320, 440), Vector2(480, 424), Vector2(600, 440),
		Vector2(680, 424), Vector2(800, 440), Vector2(880, 416), Vector2(940, 440),
	]:
		spawn_tree_spot("mangrove", pos)

	var items: Array = [
		["kulit_pisang", "organik", Vector2(160, 320)],
		["botol_plastik", "plastik", Vector2(300, 340)],
		["baterai_bekas", "b3", Vector2(440, 320)],
		["daun_kering", "organik", Vector2(600, 340)],
		["kantong_kresek", "plastik", Vector2(700, 300)],
		["kaleng_bekas", "plastik", Vector2(860, 340)],
		["sisa_sayur", "organik", Vector2(260, 408)],
		["sedotan_plastik", "plastik", Vector2(640, 408)],
	]
	for item in items:
		spawn_trash(str(item[0]), str(item[1]), item[2])

	spawn_bin("organik", Vector2(360, 240))
	spawn_bin("plastik", Vector2(500, 240))
	spawn_bin("b3", Vector2(640, 240))
	spawn_gate(Vector2(912, 264), true, "Jalan ke Epilog")

func on_tree_planted(kind: String) -> void:
	if kind != "mangrove":
		return
	_mangroves += 1
	if _mangroves >= MANGROVE_TARGET:
		GameState.unlock_card("card_mangrove_01")
		GameState.rupiah += 2000
		toast("Mangrove lengkap! +Rp2.000", true)
	_refresh_mission()

func on_bin_sorted(category: String) -> void:
	_sorted += 1
	super.on_bin_sorted(category)
	_refresh_mission()

func on_npc_talked(npc_key: String) -> void:
	if npc_key == "npc_nelayan":
		GameState.unlock_card("card_nelayan_01")
		toast("Kartu Nelayan terbuka!", true)
	_refresh_mission()

func _refresh_mission() -> void:
	var mangrove_done: bool = _mangroves >= MANGROVE_TARGET
	var trash_done: bool = _sorted >= TRASH_TARGET
	var talk_done: bool = talked_count() >= NPC_TARGET
	if mangrove_done and trash_done and talk_done:
		update_mission("Pesisir pulih! Menuju gerbang di ujung timur.")
	else:
		update_mission("Mangrove: %d/%d · Sampah: %d/%d · Warga: %d/%d" % [
			_mangroves, MANGROVE_TARGET, _sorted, TRASH_TARGET, talked_count(), NPC_TARGET,
		])

func _mission_ready() -> bool:
	return _mangroves >= MANGROVE_TARGET and _sorted >= TRASH_TARGET and talked_count() >= NPC_TARGET

func _not_ready_message() -> String:
	if _mangroves < MANGROVE_TARGET:
		return "Tanam dulu 8 mangrove di tepian pantai."
	if _sorted < TRASH_TARGET:
		return "Pilah dulu 8 sampah ke tong yang benar."
	return "Bicara dulu dengan nelayan dan penjaga sungai."
