## World Sungai Deli — satu map besar, 4 zona dengan gate dinamis.
## Zona: Warung & Hulu → Desa → Kota → Hilir → Epilog.
extends Node2D
class_name WorldSungaiDeli

const TILE: int = 16
const ZONE_WIDTH: int = 60  # tile per zona
const ZONE_HEIGHT: int = 34
const ZONE_ORDER: Array[String] = ["hulu", "desa", "kota", "hilir"]
const ZONE_LABELS: Dictionary = {
	"hulu": "HULU SUNGAI DELI",
	"desa": "DESA SUNGAI DELI",
	"kota": "KOTA MEDAN",
	"hilir": "HILIR SUNGAI DELI",
}

## Target misi tiap zona. Dibaca dari progres nyata, bukan teks statis.
const ZONE_TARGETS: Dictionary = {
	"hulu": {"trees": 5},
	"desa": {"sorted": 10, "talked": 2},
	"kota": {"sorted": 6, "talked": 4},
	"hilir": {"mangroves": 8, "sorted": 10, "talked": 2},
}

const NEXT_ZONE: Dictionary = {
	"hulu": "desa",
	"desa": "kota",
	"kota": "hilir",
	"hilir": "epilog",
}

## Ambang air minimum agar gerbang keluar zona terbuka.
const GATE_THRESHOLDS: Dictionary = {
	"hulu": 40.0,
	"desa": 60.0,
	"kota": 80.0,
	"hilir": 80.0,
}

## Kearifan lokal singkat yang muncul saat memasuki zona.
const ZONE_WISDOM: Dictionary = {
	"hulu": "Pepatah Melayu: hutan di hulu adalah warung air bagi seluruh kampung.",
	"desa": "Gotong royong: pekerjaan berat jadi ringan bila dikerjakan bersama.",
	"kota": "Pantun Melayu Deli: sungai adalah urat nadi kehidupan.",
	"hilir": "Nelayan Deli: laut yang dijaga akan menjaga kita.",
}

# Footprint bangunan (dalam satuan tile) supaya sampah/pohon tidak menimpa atap.
const BUILDING_RECTS: Dictionary = {
	"hulu": [Rect2(4, 9, 6, 4)],
	"desa": [Rect2(5.5, 9, 6, 4), Rect2(27, 9, 6, 4), Rect2(49.5, 10, 6, 4)],
	"kota": [Rect2(5.5, 4.25, 6, 4), Rect2(27, 4.25, 6, 4), Rect2(49.5, 5.25, 6, 4)],
	"hilir": [Rect2(4, 9, 6, 4), Rect2(22, 9, 6, 4), Rect2(49.5, 9, 6, 4)],
}

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var hud: HUD = $HUD
@onready var touch_controls: CanvasLayer = $TouchControls
@onready var pause_menu: CanvasLayer = $PauseMenu

var _current_zone: String = "hulu"
var _dialogue_active: bool = false
var _zone_containers: Dictionary = {}
var _guidance: Node2D = null
var _guidance_accum: float = 0.0
var _show_zone_wisdom: bool = false
var _last_mission_title: String = ""
var _spawn_positions: Dictionary = {
	"hulu": Vector2(9, 15) * TILE,   # halaman depan rumah
	"desa": Vector2(8, 15) * TILE,   # depan warung
	"kota": Vector2(8, 12) * TILE,   # trotoar kota, tidak menimpa NPC pedagang
	"hilir": Vector2(8, 15) * TILE,  # depan warung nelayan
}

# Puzzle drainase kota (bonus, tidak menghalangi gate).
var _lever_sequence: Array[int] = [1, 3, 2]
var _lever_pressed: Array[int] = []
var _drainase_open: bool = false

func _ready() -> void:
	add_to_group("level")
	add_to_group("pause_menu")
	GameState.in_world = true
	GameState.set_meta("pending_trash", [])
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	GameState.river_health_changed.connect(func(_value: float): _refresh_mission())
	GameState.rupiah_changed.connect(func(_value: int): _refresh_mission())
	GameState.quest_started.connect(_on_quest_started)

	_build_zones()
	_spawn_gates()
	_spawn_npcs()
	_spawn_gameplay_objects()
	_setup_camera()
	_setup_hud()
	_create_guidance_arrow()

	if pause_menu:
		pause_menu.connect("opened", _on_pause_opened)
		pause_menu.connect("closed", _on_pause_closed)

	# Lanjutkan di zona terakhir yang disimpan, atau mulai dari hulu.
	var start_zone: String = GameState.world_zone
	if start_zone not in ZONE_ORDER:
		start_zone = "hulu"
	change_zone(start_zone)
	_show_zone_wisdom = true

	# Pastikan cerita utama dan mission card selalu aktif di world
	GameState.quest_progress = 1
	QuestManager.start_main_quest()
	_refresh_mission()

	var has_saved_pos: bool = GameState.saved_player_x >= 0.0 and GameState.saved_player_y >= 0.0
	if has_saved_pos:
		player.global_position = Vector2(GameState.saved_player_x, GameState.saved_player_y)

	if hud:
		hud.show_hint("Joystick / WASD untuk bergerak · Dekati objek & tekan (B/E)", 4.0)

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	_guidance_accum += delta
	if _guidance_accum >= 0.35:
		_guidance_accum = 0.0
		_update_guidance()

func _build_zones() -> void:
	# Zona Hulu: Warung + mata air hutan
	var hulu_container := Node2D.new()
	hulu_container.name = "ZoneHulu"
	hulu_container.position = Vector2.ZERO
	var hulu_map := preload("res://scenes/world/topdown_map.tscn").instantiate() as Node2D
	hulu_map.set("theme", "hulu")
	hulu_container.add_child(hulu_map)
	add_child(hulu_container)
	_zone_containers["hulu"] = hulu_container

	# Zona Desa: Kampung sawah
	var desa_container := Node2D.new()
	desa_container.name = "ZoneDesa"
	desa_container.position = Vector2(ZONE_WIDTH * TILE, 0)
	var desa_map := preload("res://scenes/world/topdown_map.tscn").instantiate() as Node2D
	desa_map.set("theme", "desa")
	desa_container.add_child(desa_map)
	desa_container.visible = false
	add_child(desa_container)
	_zone_containers["desa"] = desa_container

	# Zona Kota: Medan urban
	var kota_container := Node2D.new()
	kota_container.name = "ZoneKota"
	kota_container.position = Vector2(ZONE_WIDTH * TILE * 2, 0)
	var kota_map := preload("res://scenes/world/pilot_map.tscn").instantiate() as Node2D
	kota_container.add_child(kota_map)
	kota_container.visible = false
	add_child(kota_container)
	_zone_containers["kota"] = kota_container

	# Zona Hilir: Pesisir mangrove
	var hilir_container := Node2D.new()
	hilir_container.name = "ZoneHilir"
	hilir_container.position = Vector2(ZONE_WIDTH * TILE * 3, 0)
	var hilir_map := preload("res://scenes/world/topdown_map.tscn").instantiate() as Node2D
	hilir_map.set("theme", "hilir")
	hilir_container.add_child(hilir_map)
	hilir_container.visible = false
	add_child(hilir_container)
	_zone_containers["hilir"] = hilir_container

func _spawn_gates() -> void:
	# Gate dari Hulu ke Desa (unlock river_health 40% + misi hulu).
	_create_gate("hulu", Vector2(59, 16) * TILE, "desa", 40.0, "Tanam 5 pohon dan bicara Penjaga Hutan dulu.")

	# Gate dari Desa ke Kota (unlock river_health 60% + misi desa).
	_create_gate("desa", Vector2(59, 16) * TILE, "kota", 60.0, "Pilah 10 sampah dan bicara 2 warga desa dulu.")

	# Gate dari Kota ke Hilir (unlock river_health 80% + misi kota).
	# Jalan kota ada di y=10–11, jadi gate diletakkan di jalan (bukan di sungai).
	_create_gate("kota", Vector2(59, 11) * TILE, "hilir", 80.0, "Pilah 6 sampah dan bicara 4 warga kota dulu.")

	# Gate akhir Hilir → Epilog.
	_create_gate("hilir", Vector2(59, 16) * TILE, "epilog", 80.0, "Tanam 8 mangrove, pilah 10 sampah, dan bicara 2 warga pesisir.")

func _create_gate(zone: String, pos: Vector2, target: String, threshold: float, hint: String) -> void:
	var gate_scene := preload("res://scenes/world/gate_topdown.tscn")
	var gate := gate_scene.instantiate() as Area2D
	gate.position = pos
	gate.set_script(load("res://scripts/zone_gate.gd"))
	gate.set("target_zone", target)
	gate.set("source_zone", zone)
	gate.set("river_health_threshold", threshold)
	gate.set("closed_hint", hint)
	_zone_containers[zone].add_child(gate)

func _spawn_npcs() -> void:
	# Hulu: Bu Mira di depan warung + penjaga hutan + Datuk Sampan di tepi sungai.
	_create_npc("hulu", "npc_ibu_mc", "ibu", Vector2(7, 15) * TILE, 1, "h1_warung")
	_create_npc("hulu", "npc_penjaga_hutan", "penjaga_hutan", Vector2(45, 14) * TILE, 1)
	_create_npc("hulu", "npc_datuk", "penjaga_hutan", Vector2(22, 15) * TILE, 1, "h1_datuk")

	# Desa: Pak Darwis di bale bambu, Kak Rina penjual gorengan, pemuka desa.
	_create_npc("desa", "npc_petani_1", "petani", Vector2(10, 15) * TILE, 2, "h6_darwis")
	_create_npc("desa", "npc_ibu_desa", "ibu", Vector2(53, 16) * TILE, 2, "h4_rina")
	_create_npc("desa", "npc_pemuka_desa", "pakrt", Vector2(35, 15) * TILE, 2)

	# Kota: Bang Jali di depan gang, ibu rumah, anak sekolah, tokoh masyarakat.
	_create_npc("kota", "npc_pedagang", "pedagang", Vector2(8, 10) * TILE, 3, "h2_jali")
	_create_npc("kota", "npc_ibu_rumah", "ibu", Vector2(30, 10) * TILE, 3)
	_create_npc("kota", "npc_anak_sekolah", "budi", Vector2(50, 13) * TILE, 3)
	_create_npc("kota", "npc_tokoh_masyarakat", "pakrt", Vector2(52, 9) * TILE, 3)

	# Hilir: Nelayan, penjaga sungai.
	_create_npc("hilir", "npc_nelayan", "nelayan", Vector2(13, 15) * TILE, 4)
	_create_npc("hilir", "npc_penjaga_sungai", "pakrt", Vector2(50, 15) * TILE, 4)

func _create_npc(zone: String, dialogue_key: String, sprite_key: String, pos: Vector2, npc_level: int, custom_dialog_id: String = "") -> void:
	var npc_scene := preload("res://scenes/world/npc_topdown.tscn")
	var npc := npc_scene.instantiate()
	npc.position = pos
	npc.set("npc_key", dialogue_key)
	npc.set("sprite_key", sprite_key)
	npc.set("level_id", npc_level)
	if not custom_dialog_id.is_empty():
		npc.set("dialog_id", custom_dialog_id)
	npc.add_to_group("world_npc")
	npc.talked.connect(on_npc_talked)
	_zone_containers[zone].add_child(npc)
	# Jangan tampilkan tanda seru untuk NPC yang sudah diajak bicara di sesi sebelumnya.
	var talked_keys: Array = GameState.zone_progress.get(zone, {}).get("talked_keys", [])
	if dialogue_key in talked_keys and npc.has_method("show_exclaim"):
		npc.show_exclaim(false)

func _spawn_gameplay_objects() -> void:
	# Hulu — tutorial alam: pohon + pilah sampah dasar.
	_spawn_zone_trash("hulu", 16, ["organik", "plastik"])
	_spawn_zone_bins("hulu", ["organik", "plastik"])
	_spawn_zone_tree_spots("hulu", 6, "tree")

	# Desa — pilah sampah + gotong royong.
	_spawn_zone_trash("desa", 16, ["organik", "plastik", "b3"])
	_spawn_zone_bins("desa", ["organik", "plastik", "b3"])
	_spawn_zone_tree_spots("desa", 4, "tree")

	# Kota — sampah 3 kategori + puzzle drainase.
	_spawn_zone_trash("kota", 20, ["organik", "plastik", "b3"])
	_spawn_zone_bins("kota", ["organik", "plastik", "b3"])
	_spawn_kota_levers()

	# Hilir — mangrove + sampah pesisir.
	_spawn_zone_trash("hilir", 16, ["organik", "plastik", "b3"])
	_spawn_zone_bins("hilir", ["organik", "plastik", "b3"])
	_spawn_hilir_mangroves()

	_spawn_pantun_boards()

func _spawn_zone_trash(zone: String, count: int, categories: Array) -> void:
	var trash_scene := preload("res://scenes/world/trash_topdown.tscn")
	# Saat melanjutkan save, jangan munculkan lagi sampah yang sudah dipilah.
	var already_sorted: int = GameState.zone_stat(zone, "sorted")
	for i in range(count):
		var tid: String = "%s_trash_%d" % [zone, i]
		if tid in GameState.picked_trash_ids or i < already_sorted:
			continue
		var x: int = 4 + (i * 73 + 17) % (ZONE_WIDTH - 8)
		var y: int = 4 + (i * 37 + 11) % (ZONE_HEIGHT - 8)
		if y >= 15 and y <= 18:
			y += 6
		var tile := _find_spawn_tile(zone, Vector2i(x, y))
		if tile.x < 0:
			continue
		var trash := trash_scene.instantiate()
		trash.position = Vector2(tile) * TILE
		trash.set("trash_id", tid)
		trash.set("category", categories[i % categories.size()])
		trash.add_to_group("world_trash")
		_zone_containers[zone].add_child(trash)

## Cari tile terdekat yang bukan air, bukan bangunan, dan masih di dalam peta.
func _find_spawn_tile(zone: String, base: Vector2i) -> Vector2i:
	var offsets: Array[Vector2i] = [
		Vector2i(0, 0),
		Vector2i(0, 2), Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, -2),
		Vector2i(3, 0), Vector2i(0, 3), Vector2i(-3, 0), Vector2i(0, -3),
		Vector2i(2, 2), Vector2i(-2, 2), Vector2i(2, -2), Vector2i(-2, -2),
		Vector2i(4, 0), Vector2i(0, 4), Vector2i(-4, 0), Vector2i(0, -4),
	]
	for offset in offsets:
		var tile: Vector2i = base + offset
		if _is_valid_spawn_tile(zone, tile):
			return tile
	return Vector2i(-1, -1)

func _is_valid_spawn_tile(zone: String, tile: Vector2i) -> bool:
	if tile.x < 2 or tile.x >= ZONE_WIDTH - 2 or tile.y < 2 or tile.y >= ZONE_HEIGHT - 2:
		return false
	if _zone_in_water(zone, Vector2(tile) * TILE):
		return false
	if _blocked_by_building(zone, Rect2(Vector2(tile) - Vector2(1, 1), Vector2(2, 2))):
		return false
	return true

## Mangrove ditanam di garis pantai hilir, bukan di tengah daratan.
func _spawn_hilir_mangroves() -> void:
	var tree_scene := preload("res://scenes/world/tree_spot_topdown.tscn")
	var spots: Array[Vector2i] = [
		Vector2i(6, 26), Vector2i(12, 26), Vector2i(18, 26), Vector2i(24, 26),
		Vector2i(30, 26), Vector2i(36, 26), Vector2i(40, 26), Vector2i(52, 26),
	]
	var already: int = GameState.zone_stat("hilir", "mangroves")
	for idx in range(spots.size()):
		var tile: Vector2i = spots[idx]
		if not _is_valid_spawn_tile("hilir", tile):
			continue
		var spot := tree_scene.instantiate()
		spot.position = Vector2(tile) * TILE
		spot.set("kind", "mangrove")
		_zone_containers["hilir"].add_child(spot)
		# Pulihkan visual mangrove yang sudah ditanam dari save.
		if idx < already:
			spot.call("mark_planted")

func _blocked_by_building(zone: String, rect: Rect2) -> bool:
	for building in BUILDING_RECTS.get(zone, []):
		var b: Rect2 = building
		if rect.intersects(b):
			return true
	return false

## Ambil node peta zona (TopdownMap) untuk validasi air.
func _zone_map(zone: String) -> Node:
	var container: Node = _zone_containers.get(zone)
	if container == null:
		return null
	for child in container.get_children():
		if child.has_method("is_in_water"):
			return child
	return null

func _zone_in_water(zone: String, pos: Vector2) -> bool:
	var map := _zone_map(zone)
	if map == null:
		return false
	return bool(map.call("is_in_water", pos))

func _spawn_zone_bins(zone: String, categories: Array) -> void:
	var bin_scene := preload("res://scenes/world/bin_topdown.tscn")
	# Di kota sungai lebih lebar, jadi tong diletakkan di trotoar (bukan di air).
	var y_tiles: int = 13 if zone == "kota" else 20
	var quest_by_zone: Dictionary = {
		"desa": "pilah_desa",
		"kota": "pilah_sampah_kota",
		"hilir": "pilah_hilir",
	}
	for i in range(categories.size()):
		var bin := bin_scene.instantiate()
		var x: int = 10 + i * 15
		bin.position = Vector2(x, y_tiles) * TILE
		bin.set("bin_category", categories[i])
		bin.set("required_quest", quest_by_zone.get(zone, ""))
		bin.add_to_group("world_bin")
		_zone_containers[zone].add_child(bin)

func _spawn_zone_tree_spots(zone: String, count: int, kind: String) -> void:
	var tree_scene := preload("res://scenes/world/tree_spot_topdown.tscn")
	for i in range(count):
		var x: int = 8 + (i * 61 + 23) % (ZONE_WIDTH - 16)
		var y: int = 6 + (i * 43 + 31) % 8
		# Jangan sampai pohon tumbuh menembus atap bangunan atau di air.
		var base := Vector2i(x, y)
		var candidates: Array[Vector2i] = [
			base,
			base + Vector2i(3, 0), base + Vector2i(-3, 0),
			base + Vector2i(0, 3), base + Vector2i(0, -3),
			base + Vector2i(3, 3), base + Vector2i(-3, -3),
			base + Vector2i(5, 0), base + Vector2i(-5, 0),
			base + Vector2i(0, 5), base + Vector2i(0, -5),
			base + Vector2i(6, 2), base + Vector2i(-6, -2),
		]
		var chosen := Vector2i(-1, -1)
		for candidate in candidates:
			if candidate.x < 1 or candidate.x >= ZONE_WIDTH - 1:
				continue
			if candidate.y < 1 or candidate.y >= ZONE_HEIGHT - 1:
				continue
			var world_pos := Vector2(candidate) * TILE
			if _zone_in_water(zone, world_pos):
				continue
			if _blocked_by_building(zone, Rect2(Vector2(candidate) - Vector2(1, 3), Vector2(2, 3))):
				continue
			chosen = candidate
			break
		if chosen.x < 0:
			continue
		var spot := tree_scene.instantiate()
		spot.position = Vector2(chosen) * TILE
		spot.set("kind", kind)
		spot.set("spot_id", "%s_tree_%d" % [zone, i])
		_zone_containers[zone].add_child(spot)
		if zone == "hulu" and kind == "tree" and i < GameState.zone_stat("hulu", "trees"):
			spot.call("mark_planted")

func _spawn_kota_levers() -> void:
	var lever_scene := preload("res://scenes/world/lever_topdown.tscn")
	var data: Array = [
		[1, Vector2(50, 10.5)],
		[2, Vector2(56, 10.5)],
		[3, Vector2(53, 13)],
	]
	for item in data:
		var lever := lever_scene.instantiate()
		lever.position = Vector2(item[1]) * TILE
		lever.set("lever_id", int(item[0]))
		_zone_containers["kota"].add_child(lever)

func _spawn_pantun_boards() -> void:
	var board_scene := preload("res://scenes/world/pantun_board.tscn")
	# Jauhkan papan pantun dari tong sampah agar label tidak bertumpuk.
	var positions: Dictionary = {
		"hulu": Vector2(17, 18) * TILE,
		"desa": Vector2(17, 18) * TILE,
		"kota": Vector2(50, 14) * TILE,
		"hilir": Vector2(17, 18) * TILE,
	}
	for zone in positions:
		var board := board_scene.instantiate()
		board.position = positions[zone]
		_zone_containers[zone].add_child(board)

func _spawn_zone_levers(zone: String) -> void:
	var lever_scene := preload("res://scenes/world/lever_topdown.tscn")
	var positions: Array[Vector2] = [
		Vector2(42, 13) * TILE,
		Vector2(48, 13) * TILE,
		Vector2(45, 21) * TILE,
	]
	for i in range(3):
		var lever := lever_scene.instantiate()
		lever.position = positions[i]
		lever.set("lever_id", i + 1)
		_zone_containers[zone].add_child(lever)

func _setup_camera() -> void:
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = ZONE_WIDTH * TILE
	camera.limit_bottom = ZONE_HEIGHT * TILE

func _setup_hud() -> void:
	if hud:
		hud.update_all()

# ─── Perpindahan zona ────────────────────────────────────────────────────────

func get_current_zone() -> String:
	return _current_zone

func change_zone(zone: String) -> void:
	if zone == "epilog":
		finish_journey()
		return
	if zone not in _zone_containers:
		return

	# Hide all zones
	for z in _zone_containers.values():
		z.visible = false

	# Show target zone
	_zone_containers[zone].visible = true
	_current_zone = zone
	GameState.world_zone = zone
	GameState.unlock_zone(zone)

	# Move player to spawn position
	if zone in _spawn_positions:
		player.global_position = _zone_containers[zone].global_position + _spawn_positions[zone]

	# Update kamera & label lokasi
	var zone_offset: int = ZONE_ORDER.find(zone)
	camera.limit_left = zone_offset * ZONE_WIDTH * TILE
	camera.limit_right = (zone_offset + 1) * ZONE_WIDTH * TILE
	if hud and hud.has_method("set_location"):
		hud.set_location(ZONE_LABELS.get(zone, zone.capitalize()))

	# Toast + kearifan lokal zona. Kearifan muncul setelah toast agar tidak
	# bertumpuk dengan panel bawah.
	toast("Memasuki zona: %s" % zone.capitalize(), true)
	if _show_zone_wisdom:
		_show_zone_wisdom_delayed(zone)

	_refresh_mission()
	_refresh_gates()
	_update_guidance()
	GameState.save_game()

func _show_zone_wisdom_delayed(zone: String) -> void:
	await get_tree().create_timer(1.8).timeout
	if _current_zone != zone or get_tree().paused:
		return
	if hud and hud.has_method("show_hint"):
		hud.show_hint(ZONE_WISDOM.get(zone, ""), 5.0)

func toast(text: String, is_good: bool = true) -> void:
	if hud:
		hud.show_toast(text, is_good)

# ─── Progres & misi ──────────────────────────────────────────────────────────

func zone_target(zone: String, key: String) -> int:
	return int(ZONE_TARGETS.get(zone, {}).get(key, 0))

func is_zone_cleared(zone: String) -> bool:
	var targets: Dictionary = ZONE_TARGETS.get(zone, {})
	for key in targets:
		if GameState.zone_stat(zone, key) < int(targets[key]):
			return false
	return true

func can_finish_journey() -> bool:
	return is_zone_cleared("hilir") and GameState.river_health >= 80.0

func _refresh_mission() -> void:
	if hud == null:
		return
	if GameState.quest_progress == 0:
		GameState.quest_progress = 1

	var zone: String = _current_zone
	var lines: Array[String] = []
	var title: String = ""
	var cleared: bool = is_zone_cleared(zone)
	var river_pct: int = int(round(GameState.river_health))
	var talked_keys: Array = GameState.zone_progress.get(zone, {}).get("talked_keys", [])

	match zone:
		"hulu":
			var talked_ibu: bool = "npc_ibu_mc" in talked_keys
			var talked_datuk: bool = "npc_datuk" in talked_keys
			var talked_penjaga: bool = "npc_penjaga_hutan" in talked_keys
			var trees: int = mini(GameState.zone_stat("hulu", "trees"), 5)

			if not talked_ibu:
				title = "HULU SUNGAI DELI"
				lines = [
					"Periksa kondisi warung Mak & Bapak."
				]
			elif not talked_datuk:
				title = "BANTARAN HULU"
				lines = [
					"Selidiki luapan air di bantaran sungai."
				]
			elif not talked_penjaga and trees == 0:
				title = "MATA AIR HUTAN"
				lines = [
					"Susuri jalan setapak ke hutan hulu."
				]
			elif not cleared or river_pct < 40:
				title = "PENGHIJAUAN HULU"
				lines = [
					"Tanam bibit pohon: %d/5" % trees,
					"Pilah sampah ke tong (Air: %d%% / 40%%)" % river_pct
				]
			else:
				title = "HULU PULIH"
				lines = [
					"Lanjutkan ke Gerbang Desa di timur."
				]

		"desa":
			var sorted: int = mini(GameState.zone_stat("desa", "sorted"), 10)
			var talked_darwis: bool = "npc_petani_1" in talked_keys
			var talked_rina: bool = "npc_ibu_desa" in talked_keys

			if not talked_darwis:
				title = "KEBUN DESA"
				lines = [
					"Bicara dengan Pak Darwis di kebun sayur."
				]
			elif not talked_rina:
				title = "WARGA BANTARAN"
				lines = [
					"Ajak bicara Bu Rina di persimpangan jalan."
				]
			elif sorted < 10 or river_pct < 60:
				title = "GOTONG ROYONG DESA"
				lines = [
					"Pilah 10 sampah desa: %d/10" % sorted,
					"Pulihkan air sungai (%d%% / 60%%)" % river_pct
				]
			else:
				title = "DESA BERSIH"
				lines = [
					"Masuk ke Gerbang Kota Medan di timur."
				]

		"kota":
			var sorted: int = mini(GameState.zone_stat("kota", "sorted"), 6)
			var talked_count: int = mini(GameState.zone_talked_count("kota"), 4)
			var talked_jali: bool = "npc_pedagang" in talked_keys

			if not talked_jali:
				title = "BANTARAN KOTA"
				lines = [
					"Sapa Jali di mulut gang pemukiman."
				]
			elif not _drainase_open:
				title = "DRAINASE KOTA"
				lines = [
					"Buka drainase bawah jembatan (1 → 3 → 2)."
				]
			elif talked_count < 4:
				title = "SUARA WARGA KOTA"
				lines = [
					"Dengarkan keluhan warga bantaran (%d/4)." % talked_count
				]
			elif sorted < 6 or river_pct < 75:
				title = "PENATAAN KOTA"
				lines = [
					"Pilah 6 sampah kota: %d/6" % sorted,
					"Pulihkan air sungai (%d%% / 75%%)" % river_pct
				]
			else:
				title = "KOTA TERTATA"
				lines = [
					"Lanjutkan ke Gerbang Hilir di muara."
				]

		"hilir":
			var mangroves: int = mini(GameState.zone_stat("hilir", "mangroves"), 8)
			var sorted: int = mini(GameState.zone_stat("hilir", "sorted"), 10)
			var talked_nelayan: bool = "npc_nelayan" in talked_keys
			var talked_penjaga: bool = "npc_penjaga_sungai" in talked_keys

			if not talked_nelayan:
				title = "MUARA DELI"
				lines = [
					"Dekati perahu nelayan di pesisir pantai."
				]
			elif mangroves < 8:
				title = "BENTENG BAKAU"
				lines = [
					"Tanam bibit mangrove di pesisir: %d/8" % mangroves
				]
			elif not talked_penjaga:
				title = "POS MUARA"
				lines = [
					"Temui petugas di pos pemantau muara."
				]
			elif sorted < 10 or river_pct < 80:
				title = "PEMULIHAN MUARA"
				lines = [
					"Pilah sampah pesisir (%d/10) & pantun muara." % sorted,
					"Pulihkan air muara (%d%% / 80%%)" % river_pct
				]
			else:
				title = "SUNGAI DELI PULIH"
				lines = [
					"Masuk ke Gerbang Epilog."
				]

	var text: String = title
	for line in lines:
		text += "\n" + line

	# Beri notifikasi toast bila langkah misi baru saja berganti
	if _last_mission_title != "" and _last_mission_title != title and not _dialogue_active:
		toast("Misi Baru: %s" % title, true)
	_last_mission_title = title

	hud.update_mission(text)

func _refresh_gates() -> void:
	get_tree().call_group("zone_gate", "refresh_gate_state")

func _on_quest_started(_quest_id: String) -> void:
	_refresh_mission()
	_refresh_gates()
	GameState.save_game()

# ─── Callback gameplay ───────────────────────────────────────────────────────

func on_trash_picked(category: String, trash_id: String) -> void:
	if not trash_id.is_empty() and trash_id not in GameState.picked_trash_ids:
		GameState.picked_trash_ids.append(trash_id)
	GameState.rupiah += 500
	toast("Sampah %s dipungut. +Rp500" % category, true)
	_update_guidance()
	GameState.save_game()

func on_bin_sorted(category: String) -> void:
	var zone: String = _current_zone
	GameState.add_zone_stat(zone, "sorted")
	var target: int = zone_target(zone, "sorted")
	var count: int = GameState.zone_stat(zone, "sorted")
	if target > 0 and count == target:
		GameState.rupiah += 1000
		match zone:
			"desa": GameState.unlock_card("card_pertanian_01")
			"kota": GameState.unlock_card("card_plastik_01")
			"hilir": GameState.unlock_card("card_pesisir_01")
	toast("Sampah %s terpilah. Sungai membaik." % category, true)
	_refresh_mission()
	_refresh_gates()
	GameState.save_game()

func on_tree_planted(kind: String) -> void:
	var label: String = "Mangrove" if kind == "mangrove" else "Pohon"
	if kind == "mangrove" and _current_zone == "hilir":
		GameState.add_zone_stat("hilir", "mangroves")
		var count: int = GameState.zone_stat("hilir", "mangroves")
		if count == 8:
			GameState.rupiah += 2000
			GameState.unlock_card("card_mangrove_01")
			toast("Mangrove lengkap! Pesisir terlindungi. +Rp2.000", true)
		else:
			toast("Mangrove ditanam! (%d/8) +Rp2.000" % mini(count, 8), true)
	elif kind == "tree" and _current_zone == "hulu":
		GameState.add_zone_stat("hulu", "trees")
		var count: int = GameState.zone_stat("hulu", "trees")
		if count == 5:
			GameState.rupiah += 1000
			GameState.unlock_card("card_hutan_01")
			GameState.unlock_card("card_sungai_deli_01")
			toast("Hutan kembali rimbun! +Rp1.000", true)
		else:
			toast("Pohon ditanam! (%d/5) +Rp500" % mini(count, 5), true)
	else:
		toast("%s ditanam. Sungai membaik." % label, true)
	_refresh_mission()
	_refresh_gates()
	GameState.save_game()

func on_npc_talked(npc_key: String) -> void:
	var zone: String = _current_zone
	var is_new: bool = GameState.mark_zone_talked(zone, npc_key)
	if not is_new:
		return

	match npc_key:
		"npc_ibu_mc":
			pass
		"npc_datuk":
			GameState.unlock_card("card_kearifan_02")
		"npc_penjaga_hutan":
			if not GameState.has_quest("tanam_pohon_hulu"):
				GameState.start_quest("tanam_pohon_hulu", 5)
				QuestManager.trigger_npc_quest("tanam_pohon_hulu", "Tanam 5 pohon di Hulu", 5)
			GameState.unlock_card("card_hutan_01")
		"npc_pemuka_desa":
			GameState.unlock_card("card_adat_01")
		"npc_petani_1", "npc_ibu_desa":
			if not GameState.has_quest("pilah_desa"):
				GameState.start_quest("pilah_desa", 10)
				QuestManager.trigger_npc_quest("pilah_desa", "Pilah 10 sampah desa", 10)
			if npc_key == "npc_petani_1":
				GameState.unlock_card("card_pertanian_01")
			else:
				GameState.unlock_card("card_gotong_royong_01")
		"npc_pedagang":
			if not GameState.has_quest("pilah_sampah_kota"):
				GameState.start_quest("pilah_sampah_kota", 6)
				QuestManager.trigger_npc_quest("pilah_sampah_kota", "Pilah 6 sampah kota", 6)
			GameState.unlock_card("card_plastik_01")
		"npc_ibu_rumah":
			GameState.unlock_card("card_b3_01")
		"npc_anak_sekolah":
			GameState.unlock_card("card_pantun_01")
		"npc_tokoh_masyarakat":
			GameState.unlock_card("card_drainase_01")
		"npc_nelayan":
			if not GameState.has_quest("tanam_mangrove"):
				GameState.start_quest("tanam_mangrove", 8)
				QuestManager.trigger_npc_quest("tanam_mangrove", "Tanam 8 mangrove di pesisir", 8)
			GameState.unlock_card("card_nelayan_01")
		"npc_penjaga_sungai":
			if not GameState.has_quest("pilah_hilir"):
				GameState.start_quest("pilah_hilir", 10)
				QuestManager.trigger_npc_quest("pilah_hilir", "Pilah 10 sampah pesisir", 10)
			GameState.unlock_card("card_pesisir_01")

	var target: int = zone_target(zone, "talked")
	var count: int = GameState.zone_talked_count(zone)
	if target > 0 and count == target:
		GameState.rupiah += 1500
		toast("Semua warga zona ini sudah bicara. +Rp1.500", true)

	_refresh_mission()
	_refresh_gates()
	_update_guidance()
	GameState.save_game()

# ─── Puzzle drainase kota (bonus) ────────────────────────────────────────────

func lever_pressed(lever_id: int) -> void:
	if _drainase_open:
		return
	_lever_pressed.append(lever_id)
	for i in range(_lever_pressed.size()):
		if _lever_pressed[i] != _lever_sequence[i]:
			_lever_pressed.clear()
			_reset_levers()
			GameState.ubah_meter(2.0)
			toast("Urutan tuas salah! Mulai dari tuas 1 (urutan: 1-3-2).", false)
			_refresh_mission()
			return
	if _lever_pressed.size() == _lever_sequence.size():
		_open_drainase()
	else:
		toast("Tuas %d benar (%d/3). Lanjut tuas berikutnya." % [lever_id, _lever_pressed.size()], true)
		_refresh_mission()

func _reset_levers() -> void:
	for lever in get_tree().get_nodes_in_group("pilot_lever"):
		if lever.has_method("reset_lever"):
			lever.reset_lever()

func _open_drainase() -> void:
	if _drainase_open:
		return
	_drainase_open = true
	GameState.add_river_health(10.0)
	GameState.rupiah += 2500
	GameState.unlock_card("card_drainase_01")
	AudioManager.play_sfx("correct")
	toast("Drainase terbuka! Aliran lancar. +Rp2.500", true)
	if GameState.hari == 7:
		GameState.selesaikan_puzzle_pintu_air()
	_refresh_mission()
	_refresh_gates()
	GameState.save_game()

func is_drainase_open() -> bool:
	return _drainase_open

# ─── Pantun Melayu Deli ──────────────────────────────────────────────────────

func open_pantun() -> void:
	if GameState.pantun_completed:
		toast("Pantun sudah lengkap. Terima kasih, Datuk!", true)
		return
	var panel := get_node_or_null("PantunPanel")
	if panel and panel.has_method("start"):
		panel.start()

func on_pantun_completed() -> void:
	if GameState.pantun_completed:
		return
	GameState.pantun_completed = true
	GameState.add_river_health(8.0)
	GameState.rupiah += 2000
	GameState.unlock_card("card_pantun_01")
	toast("Pantun Melayu Deli lengkap! +Rp2.000", true)
	_refresh_mission()
	GameState.save_game()

# ─── Selesai perjalanan ──────────────────────────────────────────────────────

func finish_journey() -> void:
	if not can_finish_journey():
		toast("Selesaikan dulu misi pesisir: 8 mangrove, 10 sampah, 2 warga.", false)
		return
	if GameState.world_completed:
		return
	for level in [1, 2, 3, 4]:
		if level not in GameState.levels_completed:
			GameState.levels_completed.append(level)
	GameState.world_completed = true
	GameState.in_world = false
	GameState.current_level = 5
	GameState.save_game()
	AudioManager.play_sfx("level_done")
	toast("Perjalanan hulu ke hilir selesai!", true)
	await get_tree().create_timer(1.4).timeout
	SceneManager.change_scene("res://scenes/levels/level_5_epilog.tscn")

func try_complete_level() -> void:
	if _current_zone == "hilir":
		finish_journey()
	else:
		toast("Selesaikan misi zona ini dulu.", false)

# ─── Guidance (panah kuning) ─────────────────────────────────────────────────

func _create_guidance_arrow() -> void:
	_guidance = Node2D.new()
	_guidance.name = "GuidanceArrow"
	_guidance.z_index = 100
	_guidance.set_script(load("res://scripts/guidance_arrow.gd"))
	add_child(_guidance)

func _update_guidance() -> void:
	if _guidance == null:
		return
	if _dialogue_active or get_tree().paused:
		_guidance.call("set_target", null)
		if hud and hud.has_method("hide_objective"):
			hud.hide_objective()
		return
	var target: Node2D = get_guidance_target()
	_guidance.call("set_target", target)
	_update_compass(target)

## Kompas arah membantu saat target berada di luar layar.
func _update_compass(target: Node2D) -> void:
	if hud == null or not hud.has_method("set_objective"):
		return
	if target == null:
		hud.hide_objective()
		return
	var delta: Vector2 = target.global_position - player.global_position
	var distance_tiles: int = int(round(delta.length() / TILE))
	# Hanya tampilkan petunjuk teks kompas jika target jauh (> 10 petak)
	# Jika dekat, pemain sudah dituntun panah melingkar dan target terlihat di layar.
	if distance_tiles <= 10:
		hud.hide_objective()
		return
	var direction: String = ""
	if abs(delta.x) >= abs(delta.y):
		direction = "→" if delta.x >= 0.0 else "←"
	else:
		direction = "↓" if delta.y >= 0.0 else "↑"
	hud.set_objective(direction, distance_tiles, _target_label(target))

func _target_label(target: Node2D) -> String:
	if target is NPC:
		return "Warga"
	if target is PilotBin:
		return "Tong"
	if target is TrashItem:
		return "Sampah"
	if target is TreeSpotTopDown:
		return "Titik tanam"
	if target is ZoneGate:
		return "Gerbang"
	if target is PilotLever:
		return "Tuas"
	if target is PilotPantunBoard:
		return "Papan pantun"
	return "Tujuan"

func get_guidance_target() -> Node2D:
	# 1) NPC pembuka misi selalu didahulukan supaya alur cerita jelas.
	var intro_npc := _zone_intro_npc()
	if intro_npc != null:
		return intro_npc

	# 2) Saat membawa sampah, arahkan ke tong yang sesuai kategori.
	var pending: Array = GameState.get_meta("pending_trash", [])
	if not pending.is_empty():
		var first: Dictionary = pending[0]
		var category: String = str(first.get("category", ""))
		var bin := _nearest_bin(category)
		if bin != null:
			return bin
		return _nearest_in_group("world_bin")

	# 3) Objek misi berikutnya di zona aktif.
	match _current_zone:
		"hulu":
			if GameState.zone_stat("hulu", "trees") < 5:
				return _nearest_unplanted("tree")
			return _exit_target("desa")
		"desa":
			if GameState.zone_stat("desa", "sorted") < 10 or GameState.river_health < 60.0:
				return _nearest_trash_or_bin()
			return _exit_target("kota")
		"kota":
			if not _drainase_open:
				return _nearest_unpressed_lever()
			if GameState.zone_talked_count("kota") < 4:
				return _nearest_untalked_npc()
			if GameState.zone_stat("kota", "sorted") < 6 or GameState.river_health < 75.0:
				return _nearest_trash_or_bin()
			return _exit_target("hilir")
		"hilir":
			if GameState.zone_stat("hilir", "mangroves") < 8:
				return _nearest_unplanted("mangrove")
			if GameState.zone_stat("hilir", "sorted") < 10 or GameState.river_health < 80.0:
				return _nearest_trash_or_bin()
			return _exit_target("epilog")
	return null

## Jika misi zona selesai tetapi air belum cukup, arahkan ke sampah/tong
## supaya pemain tidak menunggu di gerbang yang masih terkunci.
func _exit_target(next_zone: String) -> Node2D:
	var threshold: float = float(GATE_THRESHOLDS.get(_current_zone, 0.0))
	if GameState.river_health < threshold:
		var improver := _nearest_trash_or_bin()
		if improver != null:
			return improver
	return _gate_to(next_zone)

func _zone_intro_npc() -> Node2D:
	match _current_zone:
		"hulu":
			var talked_hulu: Array = GameState.zone_progress.get("hulu", {}).get("talked_keys", [])
			if "npc_ibu_mc" not in talked_hulu:
				return _npc_by_key("npc_ibu_mc")
			if "npc_datuk" not in talked_hulu:
				return _npc_by_key("npc_datuk")
			if "npc_penjaga_hutan" not in talked_hulu and GameState.zone_stat("hulu", "trees") < 5:
				return _npc_by_key("npc_penjaga_hutan")
		"desa":
			var talked_desa: Array = GameState.zone_progress.get("desa", {}).get("talked_keys", [])
			if "npc_petani_1" not in talked_desa:
				return _npc_by_key("npc_petani_1")
			if "npc_ibu_desa" not in talked_desa:
				return _npc_by_key("npc_ibu_desa")
		"kota":
			var talked_kota: Array = GameState.zone_progress.get("kota", {}).get("talked_keys", [])
			if "npc_pedagang" not in talked_kota:
				return _npc_by_key("npc_pedagang")
		"hilir":
			var talked_hilir: Array = GameState.zone_progress.get("hilir", {}).get("talked_keys", [])
			if "npc_nelayan" not in talked_hilir:
				return _npc_by_key("npc_nelayan")
			if GameState.zone_stat("hilir", "mangroves") < 8:
				return null
			if "npc_penjaga_sungai" not in talked_hilir:
				return _npc_by_key("npc_penjaga_sungai")
	return null

func _npc_by_key(key: String) -> Node2D:
	for npc in get_tree().get_nodes_in_group("world_npc"):
		if npc is Node2D and npc.is_visible_in_tree() and str(npc.get("npc_key")) == key:
			return npc
	return null

func _nearest_in_group(group: String) -> Node2D:
	var best: Node2D = null
	var best_dist: float = INF
	for node in get_tree().get_nodes_in_group(group):
		if not (node is Node2D) or not node.is_visible_in_tree():
			continue
		var dist: float = player.global_position.distance_squared_to((node as Node2D).global_position)
		if dist < best_dist:
			best_dist = dist
			best = node
	return best

func _nearest_bin(category: String) -> Node2D:
	var best: Node2D = null
	var best_dist: float = INF
	for node in get_tree().get_nodes_in_group("world_bin"):
		if not (node is Node2D) or not node.is_visible_in_tree():
			continue
		if str(node.get("bin_category")) != category:
			continue
		var dist: float = player.global_position.distance_squared_to((node as Node2D).global_position)
		if dist < best_dist:
			best_dist = dist
			best = node
	return best

func _nearest_trash_or_bin() -> Node2D:
	# Saat belum membawa sampah, arahkan ke sampah terdekat (bukan ke tong kosong).
	var trash := _nearest_in_group("world_trash")
	if trash != null:
		return trash
	return _nearest_in_group("world_bin")

func _nearest_unplanted(kind: String) -> Node2D:
	var best: Node2D = null
	var best_dist: float = INF
	for node in get_tree().get_nodes_in_group("tree_spot"):
		if not (node is Node2D) or not node.is_visible_in_tree():
			continue
		if str(node.get("kind")) != kind:
			continue
		if node.has_method("is_planted") and bool(node.call("is_planted")):
			continue
		var dist: float = player.global_position.distance_squared_to((node as Node2D).global_position)
		if dist < best_dist:
			best_dist = dist
			best = node
	return best

func _nearest_untalked_npc() -> Node2D:
	var best: Node2D = null
	var best_dist: float = INF
	var talked_keys: Array = GameState.zone_progress.get(_current_zone, {}).get("talked_keys", [])
	for node in get_tree().get_nodes_in_group("world_npc"):
		if not (node is Node2D) or not node.is_visible_in_tree():
			continue
		if str(node.get("npc_key")) in talked_keys:
			continue
		if node.has_method("has_talked") and bool(node.call("has_talked")):
			continue
		var dist: float = player.global_position.distance_squared_to((node as Node2D).global_position)
		if dist < best_dist:
			best_dist = dist
			best = node
	return best

func _nearest_unpressed_lever() -> Node2D:
	var best: Node2D = null
	var best_dist: float = INF
	for node in get_tree().get_nodes_in_group("pilot_lever"):
		if not (node is Node2D) or not node.is_visible_in_tree():
			continue
		if node.has_method("is_pressed") and bool(node.call("is_pressed")):
			continue
		var dist: float = player.global_position.distance_squared_to((node as Node2D).global_position)
		if dist < best_dist:
			best_dist = dist
			best = node
	return best

func _gate_to(target: String) -> Node2D:
	for gate in get_tree().get_nodes_in_group("zone_gate"):
		if not (gate is Node2D) or not gate.is_visible_in_tree():
			continue
		if gate.has_method("get_target_zone") and str(gate.call("get_target_zone")) == target:
			return gate
	return null


# ─── Kontrol & pause ─────────────────────────────────────────────────────────

func _on_dialogue_started() -> void:
	_dialogue_active = true
	if hud:
		hud.hide_toast()
		if hud.has_method("hide_hint"):
			hud.hide_hint()
		if hud.has_method("hide_mission"):
			hud.hide_mission()
	set_touch_controls_visible(false)
	_update_guidance()

func _on_dialogue_finished() -> void:
	_dialogue_active = false
	set_touch_controls_visible(true)
	_refresh_mission()
	_refresh_gates()
	_update_guidance()

func _on_pause_opened() -> void:
	if hud:
		hud.hide_toast()
		if hud.has_method("hide_hint"):
			hud.hide_hint()
		hud.visible = false
	set_touch_controls_visible(false)
	_update_guidance()

func _on_pause_closed() -> void:
	if hud:
		hud.visible = true
	set_touch_controls_visible(not _dialogue_active)
	_update_guidance()

func set_touch_controls_visible(state: bool) -> void:
	if touch_controls:
		touch_controls.visible = state

func open_pause_menu() -> void:
	if pause_menu and pause_menu.has_method("open"):
		pause_menu.open()

func toggle_pause() -> void:
	if pause_menu and pause_menu.has_method("is_open"):
		if pause_menu.is_open():
			pause_menu.close()
		else:
			pause_menu.open()
