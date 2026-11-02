## Level 1 Hulu — top-down hutan dan mata air.
## Misi: tanam 5 pohon di titik tanam, lalu menuju gerbang desa.
extends TopdownLevelBase

const TREES_TARGET: int = 5

var _trees: int = 0

func _ready() -> void:
	level_id = 1
	river_health_target = 40.0
	bgm_key = 1
	super._ready()
	_spawn_entities()

func _set_initial_mission() -> void:
	update_mission("Tanam 5 pohon di titik tanam hutan.")

func _spawn_entities() -> void:
	spawn_npc("npc_penjaga_hutan", "penjaga_hutan", Vector2(168, 244))

	for pos in [
		Vector2(160, 320), Vector2(352, 312), Vector2(400, 192),
		Vector2(592, 240), Vector2(704, 312),
	]:
		spawn_tree_spot("tree", pos)

	spawn_gate(Vector2(912, 264), true, "Jalan ke Desa")

func on_tree_planted(_kind: String) -> void:
	_trees += 1
	if _trees >= TREES_TARGET:
		GameState.unlock_card("card_hutan_01")
		GameState.rupiah += 1000
		update_mission("Pohon selesai! Menuju gerbang di ujung timur →")
		toast("Hutan kembali rimbun! +Rp1.000", true)
	else:
		update_mission("Tanam pohon: %d/%d" % [_trees, TREES_TARGET])

func on_npc_talked(npc_key: String) -> void:
	if npc_key == "npc_penjaga_hutan":
		GameState.unlock_card("card_sungai_deli_01")
		toast("Kartu Sungai Deli terbuka!", true)
		if _trees < TREES_TARGET:
			update_mission("Tanam pohon: %d/%d" % [_trees, TREES_TARGET])

func _mission_ready() -> bool:
	return _trees >= TREES_TARGET

func _not_ready_message() -> String:
	return "Tanam dulu 5 pohon di titik tanam."
