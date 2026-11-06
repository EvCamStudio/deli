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
	_refresh_mission()

func _spawn_entities() -> void:
	spawn_npc("npc_petani_1", "petani", Vector2(136, 236))
	spawn_npc("npc_ibu_desa", "ibu", Vector2(480, 236))

	# Sampah dikelompokkan dekat tong masing-masing (maks. 10 tile).
	var items: Array = [
		["kulit_pisang", "organik", Vector2(160, 320)],
		["daun_kering", "organik", Vector2(240, 344)],
		["sisa_sayur", "organik", Vector2(304, 320)],
		["ranting_kering", "organik", Vector2(192, 384)],
		["sampah_organik", "organik", Vector2(136, 360)],
		["kertas_kotor", "plastik", Vector2(560, 320)],
		["kardus_sobek", "plastik", Vector2(608, 344)],
		["sampah_kecil", "plastik", Vector2(688, 320)],
		["sampah_lain", "plastik", Vector2(560, 400)],
		["sampah_akhir", "plastik", Vector2(720, 360)],
	]
	for item in items:
		spawn_trash(str(item[0]), str(item[1]), item[2])

	spawn_bin("organik", Vector2(240, 272), "pilah_desa", "Bicara dulu dengan Pak Tani di depan warung.")
	spawn_bin("plastik", Vector2(640, 272), "pilah_desa", "Bicara dulu dengan Pak Tani di depan warung.")
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

	if not GameState.has_quest("pilah_desa"):
		update_mission_lines("Bersihkan Desa", [
			"Bicara Pak Tani dulu",
			"Lokasi: depan warung",
		])
	elif _sorted >= TRASH_TARGET and talked_count() >= NPC_TARGET:
		update_mission_lines("Bersihkan Desa", [
			"Warga: %d/%d" % [talked_count(), NPC_TARGET],
			"Sampah: %d/%d" % [_sorted, TRASH_TARGET],
			"Menuju gerbang di ujung timur",
		])
	else:
		update_mission_lines("Bersihkan Desa", [
			"Warga: %d/%d" % [talked_count(), NPC_TARGET],
			"Sampah: %d/%d" % [_sorted, TRASH_TARGET],
			"Lokasi: jalan utama desa",
		])

func _mission_ready() -> bool:
	return _sorted >= TRASH_TARGET and talked_count() >= NPC_TARGET

func _not_ready_message() -> String:
	if talked_count() < NPC_TARGET:
		return "Bicara dulu dengan petani dan warga desa."
	return "Pilah dulu 10 sampah ke tong yang benar."
