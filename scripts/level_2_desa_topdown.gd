## Level 2 Desa — top-down sawah dan kampung.
## Misi: bicara dengan 2 warga dan pilah 10 sampah.
extends TopdownLevelBase

const TRASH_TARGET: int = 10
const NPC_TARGET: int = 2

var _sorted: int = 0
var _gotong_bonus: bool = false

func _ready() -> void:
	level_id = 2
	river_health_target = 55.0
	bgm_key = 2
	super._ready()
	_spawn_entities()

func _set_initial_mission() -> void:
	update_mission("Bicara dengan petani & warga, lalu pilah 10 sampah.")

func _spawn_entities() -> void:
	spawn_npc("npc_petani_1", "petani", Vector2(200, 236))
	spawn_npc("npc_ibu_desa", "ibu", Vector2(520, 236))

	var items: Array = [
		["kulit_pisang", "organik", Vector2(160, 320)],
		["botol_plastik", "plastik", Vector2(300, 300)],
		["baterai_bekas", "b3", Vector2(420, 340)],
		["daun_kering", "organik", Vector2(600, 300)],
		["kantong_kresek", "plastik", Vector2(700, 350)],
		["kaleng_bekas", "b3", Vector2(860, 320)],
		["sisa_sayur", "organik", Vector2(240, 400)],
		["sedotan_plastik", "plastik", Vector2(480, 400)],
		["lampu_bekas", "b3", Vector2(640, 400)],
		["ranting_kering", "organik", Vector2(800, 400)],
	]
	for item in items:
		spawn_trash(str(item[0]), str(item[1]), item[2])

	spawn_bin("organik", Vector2(216, 240))
	spawn_bin("plastik", Vector2(544, 240))
	spawn_bin("b3", Vector2(752, 240))

	spawn_gate(Vector2(912, 264), true, "Jalan ke Kota")

func on_bin_sorted(category: String) -> void:
	_sorted += 1
	super.on_bin_sorted(category)
	_refresh_mission()

func on_npc_talked(npc_key: String) -> void:
	match npc_key:
		"npc_petani_1":
			GameState.unlock_card("card_pertanian_01")
			toast("Kartu Pertanian terbuka!", true)
		"npc_ibu_desa":
			GameState.unlock_card("card_gotong_royong_01")
			toast("Kartu Gotong Royong terbuka!", true)
	_refresh_mission()

func _refresh_mission() -> void:
	if talked_count() >= NPC_TARGET and not _gotong_bonus:
		_gotong_bonus = true
		GameState.add_river_health(5.0)
		GameState.rupiah += 1500
		toast("Warga bergotong royong! +Rp1.500", true)

	if _sorted >= TRASH_TARGET and talked_count() >= NPC_TARGET:
		update_mission("Misi selesai! Menuju gerbang di ujung timur →")
	elif talked_count() < NPC_TARGET:
		update_mission("Bicara warga: %d/%d · Sampah terpilah: %d/%d" % [talked_count(), NPC_TARGET, _sorted, TRASH_TARGET])
	else:
		update_mission("Pilah sampah: %d/%d" % [_sorted, TRASH_TARGET])

func _mission_ready() -> bool:
	return _sorted >= TRASH_TARGET and talked_count() >= NPC_TARGET

func _not_ready_message() -> String:
	if talked_count() < NPC_TARGET:
		return "Bicara dulu dengan petani dan warga desa."
	return "Pilah dulu 10 sampah ke tong yang benar."
