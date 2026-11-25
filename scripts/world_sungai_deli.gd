## World Sungai Deli — satu map besar, 4 zona dengan gate dinamis.
## Zona: Warung & Hulu → Desa → Kota → Hilir → Epilog.
extends Node2D
class_name WorldSungaiDeli

const TILE: int = 16
const ZONE_WIDTH: int = 60  # tile per zona
const ZONE_HEIGHT: int = 32
const ZONE_ORDER: Array[String] = ["hulu", "desa", "kota", "hilir"]
const ZONE_LABELS: Dictionary = {
	"hulu": "HULU SUNGAI DELI",
	"desa": "DESA SUKA MAJU",
	"kota": "KOTA MEDAN",
	"hilir": "MUARA SUNGAI DELI",
	"epilog": "TEPIAN SUNGAI DELI",
}

## Target misi tiap zona. Dibaca dari progres nyata, bukan teks statis.
const ZONE_TARGETS: Dictionary = {
	"hulu": {"trees": 15, "sorted": 15},
	"desa": {"sorted": 16, "talked": 2},
	"kota": {"sorted": 20, "talked": 4},
	"hilir": {"mangroves": 12, "sorted": 16, "talked": 2},
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

# Footprint bangunan (dalam satuan tile) supaya sampah/pohon tidak menimpa atap atau halaman depan pintu.
const BUILDING_RECTS: Dictionary = {
	"hulu": [
		Rect2(3.5, 5.0, 7.0, 5.5),   # house_mc.png (x: 112, y: 160)
		Rect2(13.6, 5.0, 7.0, 5.5),  # house_cabin_blue.png (x: 272, y: 160)
	],
	"desa": [
		Rect2(7.0, 4.0, 9.0, 11.0),  # warung_toko_jaya.png + halaman depan bebas sampah (x: 180, y: 160)
		Rect2(18.0, 5.0, 7.0, 5.5),  # house_cottage_orange.png (x: 340, y: 160)
		Rect2(28.0, 5.0, 7.0, 5.5),  # building_kantor_desa.png (x: 500, y: 160)
		Rect2(38.0, 5.0, 7.0, 5.5),  # house_cozy_red.png (x: 660, y: 160)
		Rect2(48.0, 5.0, 7.0, 5.5),  # building_mesjid_desa.png (x: 820, y: 160)
		Rect2(4.0, 18.0, 6.0, 6.0),  # warung_madura.png (x: 110, y: 368)
		Rect2(14.0, 18.0, 6.0, 6.0), # house_brick.png (x: 270, y: 368)
		Rect2(25.5, 17.5, 6.5, 6.0), # warung_sayur_fresh.png (x: 460, y: 364)
		Rect2(37.5, 18.0, 6.5, 6.0), # warung_bu_sri.png (x: 650, y: 368)
		Rect2(50.0, 18.0, 7.0, 6.0), # house_modern_2story.png (x: 850, y: 368)
	],
	"kota": [
		Rect2(2.2, 0.5, 6.2, 4.0),  # building_apartment.png (y=60)
		Rect2(10.6, 0.5, 5.7, 4.0),  # building_office_glass.png (y=60)
		Rect2(24.5, 0.5, 6.0, 4.0),  # building_corporate_tower.png (y=60)
		Rect2(35.3, 0.5, 5.7, 4.0),  # building_helipad_tower.png (y=60)
		Rect2(48.0, 0.5, 5.8, 4.0),  # building_condo_terrace.png (y=60)
		Rect2(54.2, 0.5, 5.9, 4.0),  # building_brick_complex.png (y=60)
		Rect2(5.0, 19.0, 7.5, 4.0),  # market_sayur.png (y=350)
		Rect2(24.5, 19.0, 6.5, 4.0),  # building_minimarket.png (y=350)
		Rect2(35.8, 19.0, 6.1, 4.0),  # market_kelontong.png (y=350)
		Rect2(50.0, 19.0, 6.3, 4.0),  # market_sembako.png (y=350)
	],
	"hilir": [
		Rect2(4.5, 0.8, 5.0, 3.5),  # house_coastal.png (y=64)
		Rect2(12.6, 0.8, 6.8, 3.5),  # house_suburban_blue.png (y=64)
		Rect2(23.2, 0.8, 5.5, 3.5),  # house_courtyard.png (y=64)
		Rect2(32.6, 0.8, 6.8, 3.5),  # house_suburban_lshape.png (y=64)
		Rect2(42.3, 0.8, 7.4, 3.5),  # market_ikan.png (y=68)
		Rect2(51.8, 0.8, 6.5, 3.5),  # house_suburban_canopy.png (y=64)
	],
}

# Titik tanam pohon Hulu dikelompokkan di satu kawasan hutan khusus di sisi timur
# (tepat di belakang Penjaga Hutan), bukan tersebar di pekarangan atau kampung/desa.
const HULU_FOREST_SPOTS: Array[Vector2i] = [
	Vector2i(42, 7), Vector2i(44, 7), Vector2i(46, 7), Vector2i(48, 7), Vector2i(50, 7),
	Vector2i(42, 9), Vector2i(44, 9), Vector2i(46, 9), Vector2i(48, 9), Vector2i(50, 9),
	Vector2i(42, 11), Vector2i(44, 11), Vector2i(46, 11), Vector2i(48, 11), Vector2i(50, 11),
]

# Titik tanam bibit mangrove Hilir ditata rapi berjejer dalam 3 baris sejajar (4x3 grid = 12 titik)
# di kawasan pembibitan pesisir (di samping Pak Nelayan & jembatan muara),
# rapi dan berjejer seperti kawasan reboisasi hutan di map pertama (Hulu).
const HILIR_MANGROVE_SPOTS: Array[Vector2i] = [
	Vector2i(25, 19), Vector2i(29, 19), Vector2i(33, 19), Vector2i(37, 19),
	Vector2i(25, 21), Vector2i(29, 21), Vector2i(33, 21), Vector2i(37, 21),
	Vector2i(25, 23), Vector2i(29, 23), Vector2i(33, 23), Vector2i(37, 23),
]

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
var _hulu_riverbank_spot: Area2D = null
var _hulu_sampan: Sprite2D = null
var _last_zone_switch_ms: int = -1000
var _is_cutscene_active: bool = false
var _cutscene_advance_cb: Callable = Callable()
var _flood_cutscene: CanvasLayer = null
var _flood_triggered: bool = false
var _bridge_talk_spot: Node2D = null
var _trash_spawned_hulu_river: bool = false
var _has_triggered_bridge_voice: bool = false
var _has_triggered_datuk_bridge: bool = false
var _has_triggered_toko_jaya: bool = false
var _has_triggered_home_day: bool = false
var _has_triggered_warung_rina: bool = false
var _has_triggered_kota_gang: bool = false
var _lever_sequence: Array[int] = [1, 3, 2]
var _lever_pressed: Array[int] = []
var _last_solved_pantun_id: String = ""
var _spawn_positions: Dictionary = {
	"hulu": Vector2(9, 15) * TILE,   # halaman depan rumah
	"desa": Vector2(8, 15) * TILE,   # depan warung
	"kota": Vector2(8, 9.5) * TILE,  # trotoar kota, tidak menimpa NPC pedagang
	"hilir": Vector2(8, 9.5) * TILE, # trotoar jalan utama nelayan
}

func _ready() -> void:
	add_to_group("level")
	add_to_group("pause_menu")
	GameState.in_world = true
	GameState.set_meta("pending_trash", [])
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	DialogueManager.dialog_selesai.connect(_on_dialog_selesai)
	GameState.river_health_changed.connect(func(_value: float): _refresh_mission())
	GameState.meter_changed.connect(_on_meter_changed)
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
		start_zone = GameState.saved_zone
	if start_zone not in ZONE_ORDER:
		start_zone = "hulu"
	var saved_pos := Vector2(GameState.saved_player_x, GameState.saved_player_y)
	var has_saved_pos: bool = saved_pos.x >= 0.0 and saved_pos.y >= 0.0 \
		and GameState.saved_zone == start_zone
	# Jangan simpan dulu: change_zone() memindahkan pemain ke spawn zona dan bisa
	# menimpa posisi terakhir yang baru dimuat dari save.
	change_zone(start_zone, Vector2(-1, -1), false)
	_show_zone_wisdom = true

	# Pastikan cerita utama dan mission card selalu aktif di world
	GameState.quest_progress = 1
	QuestManager.start_main_quest()
	_sync_hulu_story_state()
	_refresh_mission()
	_update_guidance()

	if has_saved_pos:
		player.global_position = saved_pos
		if camera.has_method("reset_smoothing"):
			camera.reset_smoothing()

	# Simpan lagi setelah posisi dipulihkan supaya sesi berikutnya melanjutkan
	# tepat di tempat pemain berhenti.
	GameState.save_game()

	if hud:
		hud.show_hint("Gunakan Joystick untuk bergerak · Dekati warga/objek & ketuk tombol Aksi", 4.0)

func _unhandled_input(event: InputEvent) -> void:
	if _is_cutscene_active and _cutscene_advance_cb.is_valid():
		if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode in [KEY_SPACE, KEY_ENTER]):
			get_viewport().set_input_as_handled()
			_cutscene_advance_cb.call()

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	_check_story_proximity()
	_guidance_accum += delta
	if _guidance_accum >= 0.35:
		_guidance_accum = 0.0
		_update_guidance()

func _create_zone_container(container_name: String, zone_x: float, map_scene: PackedScene, theme_name: String = "", visible_by_default: bool = false) -> Node2D:
	var container := Node2D.new()
	container.name = container_name
	container.y_sort_enabled = true
	container.position = Vector2(zone_x, 0)
	container.visible = visible_by_default
	var map_node := map_scene.instantiate() as Node2D
	if not theme_name.is_empty():
		map_node.set("theme", theme_name)
	container.add_child(map_node)
	add_child(container)
	return container


func _build_zones() -> void:
	var topdown_scene: PackedScene = preload("res://scenes/world/topdown_map.tscn")
	var pilot_scene: PackedScene = preload("res://scenes/world/pilot_map.tscn")
	_zone_containers["hulu"] = _create_zone_container("ZoneHulu", 0.0, topdown_scene, "hulu", true)
	_zone_containers["desa"] = _create_zone_container("ZoneDesa", ZONE_WIDTH * TILE, topdown_scene, "desa")
	_zone_containers["kota"] = _create_zone_container("ZoneKota", ZONE_WIDTH * TILE * 2, pilot_scene)
	_zone_containers["hilir"] = _create_zone_container("ZoneHilir", ZONE_WIDTH * TILE * 3, topdown_scene, "hilir")

func _spawn_gates() -> void:
	# Akses antar-map (Hulu ↔ Desa ↔ Kota ↔ Hilir) terbuka bebas dua arah tanpa kunci misi.
	_create_gate("hulu", Vector2(59, 15.5) * TILE, "desa", 0.0, "", false, Vector2(4, 15.5) * TILE)
	_create_gate("desa", Vector2(1, 15.5) * TILE, "hulu", 0.0, "", false, Vector2(56, 15.5) * TILE)
	_create_gate("desa", Vector2(59, 15.5) * TILE, "kota", 0.0, "", false, Vector2(4, 9.5) * TILE)
	_create_gate("kota", Vector2(1, 9.5) * TILE, "desa", 0.0, "", false, Vector2(56, 15.5) * TILE)
	_create_gate("kota", Vector2(59, 9.5) * TILE, "hilir", 0.0, "", false, Vector2(4, 9.5) * TILE)
	_create_gate("hilir", Vector2(1, 9.5) * TILE, "kota", 0.0, "", false, Vector2(56, 9.5) * TILE)

	# Gate akhir Hilir → Epilog (tamat perjalanan).
	_create_gate("hilir", Vector2(59, 9.5) * TILE, "epilog", 80.0, "Tanam 12 mangrove, pilah 10 sampah, dan bicara 2 warga pesisir.", true)

func _create_gate(zone: String, pos: Vector2, target: String, threshold: float, hint: String, require_mission: bool = false, entry_pos: Vector2 = Vector2(-1, -1)) -> void:
	var gate_scene := preload("res://scenes/world/gate_topdown.tscn")
	var gate := gate_scene.instantiate() as Area2D
	gate.position = pos
	gate.set_script(load("res://scripts/zone_gate.gd"))
	gate.set("target_zone", target)
	gate.set("source_zone", zone)
	gate.set("river_health_threshold", threshold)
	gate.set("closed_hint", hint)
	gate.set("require_mission_to_open", require_mission)
	gate.set("entry_position", entry_pos)
	_zone_containers[zone].add_child(gate)

func _spawn_npcs() -> void:
	# Hulu: Pak Hendra & Bu Mira tepat di teras depan Warung/Rumah MC + Penjaga Hutan di hutan timur + Datuk Sampan di jembatan.
	_create_npc("hulu", "npc_pak_hendra", "bapak", Vector2(5.5, 11.8) * TILE, 1, "h1_warung")
	_create_npc("hulu", "npc_ibu_mc", "ibu", Vector2(7.5, 11.8) * TILE, 1, "h1_warung")
	_create_npc("hulu", "npc_penjaga_hutan", "penjaga_hutan", Vector2(45, 11) * TILE, 1)
	_create_npc("hulu", "npc_datuk", "datuk", Vector2(29.5, 15.5) * TILE, 1, "h1_datuk")
	_spawn_hulu_sampan()
	_spawn_hulu_riverbank_spot()

	_bridge_talk_spot = Node2D.new()
	_bridge_talk_spot.name = "BridgeTalkSpot"
	_bridge_talk_spot.position = Vector2(28.5, 15.5) * TILE
	_zone_containers["hulu"].add_child(_bridge_talk_spot)

	# Desa: Pak Darwis & Pemilik Toko Jaya tepat di depan teras Toko Jaya (utara),
	# Kak Rina tepat di depan Warung Gorengan (warung_bu_sri selatan), Pemuka Desa di depan rumah besar tengah.
	_create_npc("desa", "npc_petani_1", "petani", Vector2(10.5, 11.8) * TILE, 2, "h1_toko_jaya")
	_create_npc("desa", "npc_pemilik_toko", "pemilik_toko", Vector2(12.2, 11.5) * TILE, 2, "h1_toko_jaya")
	_create_npc("desa", "npc_ibu_desa", "kak_rina", Vector2(40.5, 24.0) * TILE, 2, "h4_rina")
	_create_npc("desa", "npc_pemuka_desa", "pemuka_desa", Vector2(30.5, 11.8) * TILE, 2)

	# Kota: Bang Jali tepat di tepi sungai/kanal barat (hendak membuang sampah ke sungai), Ibu Rumah Tangga di dekat saluran drainase kanal tengah,
	# Budi di dekat papan pantun alun-alun timur, Pak RT di depan gedung perumahan timur.
	_create_npc("kota", "npc_pedagang", "pedagang", Vector2(10.5, 12.8) * TILE, 3, "h2_jali")
	_create_npc("kota", "npc_ibu_rumah", "ibu_rumah", Vector2(31.5, 12.5) * TILE, 3)
	_create_npc("kota", "npc_anak_sekolah", "budi", Vector2(40.5, 12.8) * TILE, 3)
	_create_npc("kota", "npc_tokoh_masyarakat", "pakrt", Vector2(51.0, 5.2) * TILE, 3)

	# Hilir: Penjaga Sungai di dekat pangkal jembatan muara, Pak Nelayan di pesisir pantai selatan dekat area tanam mangrove.
	_create_npc("hilir", "npc_nelayan", "nelayan", Vector2(21.0, 21.5) * TILE, 4)
	_create_npc("hilir", "npc_penjaga_sungai", "penjaga_sungai", Vector2(23.5, 12.5) * TILE, 4)

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
	# Untuk warung hulu, cukup satu tanda seru (Bu Mira) agar tidak bertumpuk di depan rumah.
	var talked_keys: Array = GameState.zone_progress.get(zone, {}).get("talked_keys", [])
	if (dialogue_key in talked_keys or dialogue_key == "npc_pak_hendra") and npc.has_method("show_exclaim"):
		npc.show_exclaim(false)

func _spawn_hulu_riverbank_spot() -> void:
	var spot_script: Script = preload("res://scripts/riverbank_spot.gd")
	_hulu_riverbank_spot = spot_script.new() as Area2D
	_hulu_riverbank_spot.name = "HuluRiverbankTrigger"
	_hulu_riverbank_spot.position = Vector2(26.5, 14.5) * TILE
	_hulu_riverbank_spot.investigated.connect(_on_hulu_riverbank_investigated)
	_zone_containers["hulu"].add_child(_hulu_riverbank_spot)

func _spawn_hulu_sampan() -> void:
	_hulu_sampan = Sprite2D.new()
	_hulu_sampan.name = "HuluSampan"
	_hulu_sampan.texture = _build_sampan_texture()
	_hulu_sampan.position = Vector2(28.8, 10.5) * TILE
	_hulu_sampan.z_index = -1
	_zone_containers["hulu"].add_child(_hulu_sampan)
	var bob := _hulu_sampan.create_tween().set_loops()
	bob.tween_property(_hulu_sampan, "position:y", _hulu_sampan.position.y - 1.5, 1.1).set_trans(Tween.TRANS_SINE)
	bob.tween_property(_hulu_sampan, "position:y", _hulu_sampan.position.y + 1.0, 1.1).set_trans(Tween.TRANS_SINE)

func _build_sampan_texture() -> ImageTexture:
	var w: int = 26
	var h: int = 12
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var outline := Color(0.23, 0.15, 0.09, 1.0)
	var hull := Color(0.49, 0.30, 0.17, 1.0)
	var deck := Color(0.68, 0.45, 0.25, 1.0)
	var wake := Color(0.76, 0.68, 0.52, 0.78)
	for y in range(2, 9):
		var inset: int = absi(y - 5) * 2
		for x in range(inset, w - inset):
			var edge: bool = (x == inset or x == w - inset - 1 or y == 2 or y == 8)
			if edge:
				img.set_pixel(x, y, outline)
			elif x in [9, 10, 16, 17]:
				img.set_pixel(x, y, deck)
			else:
				img.set_pixel(x, y, hull)
	for x in range(4, w - 4, 3):
		img.set_pixel(x, 10, wake)
		img.set_pixel(x + 1, 10, wake)
	return ImageTexture.create_from_image(img)

func _has_hulu_sound_triggered() -> bool:
	var talked_hulu: Array = GameState.zone_progress.get("hulu", {}).get("talked_keys", [])
	return bool(GameState.choices.get("hulu_sound_heard", false)) or ("npc_datuk" in talked_hulu)

func _sync_hulu_story_state() -> void:
	var step: String = str(GameState.choices.get("hulu_story_step", ""))
	var talked_hulu: Array = GameState.zone_progress.get("hulu", {}).get("talked_keys", [])
	var talked_desa: Array = GameState.zone_progress.get("desa", {}).get("talked_keys", [])
	var talked_kota: Array = GameState.zone_progress.get("kota", {}).get("talked_keys", [])
	var talked_hilir: Array = GameState.zone_progress.get("hilir", {}).get("talked_keys", [])

	# Parameter bencana masih 0% di awal sebelum bertemu Datuk Sampan
	if step in ["", "butuh_pesan_kasur", "menuju_toko_jaya", "cari_suara_jembatan"] and not bool(GameState.choices.get("datuk_bencana_revealed", false)):
		GameState.meter_bencana = 0.0
	elif not bool(GameState.choices.get("datuk_bencana_revealed", false)):
		GameState.record_choice("datuk_bencana_revealed", true)
		if GameState.meter_bencana <= 0.0:
			GameState.meter_bencana = 70.0

	# Jika step cerita baru belum dimulai, pastikan warung siap untuk percakapan pembuka
	if step.is_empty() and "npc_ibu_mc" in talked_hulu:
		talked_hulu.erase("npc_ibu_mc")

	# Pemulihan otomatis jika step pernah tertahan di tanya_budi padahal Budi sudah diajak bicara
	if step == "tanya_budi" and bool(GameState.choices.get("budi_done", false)):
		GameState.record_choice("hulu_story_step", "ke_hilir_muara")
		step = "ke_hilir_muara"

	for npc in get_tree().get_nodes_in_group("world_npc"):
		var key := str(npc.get("npc_key"))
		if key == "npc_ibu_mc" or key == "npc_pak_hendra":
			if step == "butuh_pesan_kasur":
				if npc.has_method("set_dialog_id"):
					npc.set_dialog_id("h1_warung_kasur")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(key == "npc_ibu_mc")
			elif step == "pesan_gorengan":
				if npc.has_method("set_dialog_id"):
					npc.set_dialog_id("h2_warung_gorengan")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(key == "npc_ibu_mc")
			elif step == "antar_gorengan":
				if npc.has_method("set_dialog_id"):
					npc.set_dialog_id("h2_warung_gorengan_selesai")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(key == "npc_ibu_mc")
			elif step.is_empty():
				if npc.has_method("set_dialog_id"):
					npc.set_dialog_id("h1_warung")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(key == "npc_ibu_mc" and ("npc_ibu_mc" not in talked_hulu))
			else:
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(false)
		elif key == "npc_datuk":
			var show_datuk: bool = (step == "cari_suara_jembatan")
			npc.visible = show_datuk
			npc.position = Vector2(29.5, 16.0) * TILE
			var col := npc.get_node_or_null("CollisionShape2D") as CollisionShape2D
			if col:
				col.set_deferred("disabled", not show_datuk)
			if npc.has_method("show_exclaim"):
				npc.show_exclaim(show_datuk)
		elif key == "npc_penjaga_hutan":
			var trees: int = GameState.zone_stat("hulu", "trees")
			var hutan_done: bool = bool(GameState.choices.get("penjaga_hutan_selesai", false))
			if step == "tanam_pohon_hulu":
				if npc.has_method("set_dialog_id"):
					npc.set_dialog_id("h1_penjaga_hutan")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(true)
			elif step == "menanam_pohon_hulu" and trees >= 15 and not hutan_done:
				if npc.has_method("set_dialog_id"):
					npc.set_dialog_id("h1_penjaga_hutan_selesai")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(true)
			else:
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(false)
		elif key == "npc_petani_1":
			var darwis_done: bool = bool(GameState.choices.get("darwis_done", false))
			if step == "ke_toko_jaya" and not darwis_done:
				if npc.has_method("set_dialog_id"):
					if bool(GameState.choices.get("unlock_solusi_darwis", false)):
						npc.set_dialog_id("h6_darwis")
					elif bool(GameState.choices.get("mencari_solusi_darwis", false)):
						npc.set_dialog_id("h1_darwis_menunggu")
					else:
						npc.set_dialog_id("h1_toko_jaya")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(true)
			elif step == "pantun_kasur_darwis" and not darwis_done:
				if npc.has_method("set_dialog_id"):
					npc.set_dialog_id("h1_darwis_menunggu")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(false)
			else:
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(false)
		elif key == "npc_pemilik_toko":
			if npc.has_method("show_exclaim"):
				npc.show_exclaim(false)
		elif key == "npc_ibu_desa": # Kak Rina
			var rina_done: bool = bool(GameState.choices.get("rina_done", false))
			if step in ["ke_warung_rina", "pantun_jelantah_rina"] and not rina_done:
				if npc.has_method("set_dialog_id"):
					npc.set_dialog_id("h4_rina")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(true)
			elif step == "serahkan_jeriken_rina":
				if npc.has_method("set_dialog_id"):
					npc.set_dialog_id("h5_rina")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(true)
			else:
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(false)
		elif key == "npc_pemuka_desa":
			var has_info: bool = bool(GameState.choices.get("has_jeriken_and_info", false))
			if step == "cari_solusi_jelantah" and not has_info:
				if npc.has_method("set_dialog_id"):
					npc.set_dialog_id("h2_pemuka_desa")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(true)
			else:
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(false)
		elif key == "npc_pedagang": # Bang Jali
			var jali_done: bool = bool(GameState.choices.get("jali_done", false))
			if step in ["ke_kota_medan", "kota_gang_sempit", "pantun_gang_jali"] and not jali_done:
				if npc.has_method("set_dialog_id"):
					npc.set_dialog_id("h2_jali")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(true)
			elif step == "serahkan_gerobak_jali":
				if npc.has_method("set_dialog_id"):
					npc.set_dialog_id("h3_jali")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(true)
			else:
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(false)
		elif key == "npc_tokoh_masyarakat": # Pak RT
			var has_approval: bool = bool(GameState.choices.get("has_rt_cart_approval", false))
			if step == "cari_solusi_rt" and not has_approval:
				if npc.has_method("set_dialog_id"):
					npc.set_dialog_id("h3_pak_rt")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(true)
			else:
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(false)
		elif key == "npc_ibu_rumah":
			if step in ["periksa_saluran_kota", "pintu_air_dan_b3"] and "npc_ibu_rumah" not in talked_kota:
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(true)
			else:
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(false)
		elif key == "npc_anak_sekolah":
			var budi_done: bool = bool(GameState.choices.get("budi_done", false))
			if step in ["tanya_budi", "ke_hilir_muara"] and not budi_done:
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(true)
			else:
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(false)
		elif key == "npc_penjaga_sungai":
			if step in ["ke_hilir_muara", "pos_penjaga_muara", "pilah_sampah_muara"] and not bool(GameState.choices.get("penjaga_sungai_done", false)):
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(true)
			else:
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(false)
		elif key == "npc_nelayan":
			var mangroves: int = GameState.zone_stat("hilir", "mangroves")
			var trash_done: bool = GameState.zone_stat("hilir", "sorted") >= zone_target("hilir", "sorted")
			var pantun_done: bool = bool(GameState.choices.get("pantun_muara_selesai", false))
			var nelayan_done: bool = bool(GameState.choices.get("nelayan_selesai", false))
			if step == "temui_pak_nelayan" and trash_done and pantun_done and not bool(GameState.choices.get("nelayan_awal_done", false)):
				if npc.has_method("set_dialog_id"):
					npc.set_dialog_id("h7_nelayan")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(true)
			elif (step in ["tanam_mangrove_muara", "selesai_mangrove"]) and trash_done and pantun_done and mangroves >= 12 and not nelayan_done:
				if npc.has_method("set_dialog_id"):
					npc.set_dialog_id("h7_nelayan_selesai")
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(true)
			else:
				if npc.has_method("show_exclaim"):
					npc.show_exclaim(false)

	if is_instance_valid(_hulu_riverbank_spot):
		_hulu_riverbank_spot.visible = false
		_hulu_riverbank_spot.monitoring = false
		_hulu_riverbank_spot.monitorable = false

	if is_instance_valid(_hulu_sampan):
		_hulu_sampan.visible = true

	# Sampah bantaran sungai Hulu selalu dimunculkan dari awal cerita
	_spawn_hulu_riverbank_trash()

func _build_walking_shadow_mc(walk_dir: String = "right", travel_duration: float = 0.65) -> Control:
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(200, 92)
	holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Halo cahaya lembut di tengah layar agar siluet dan karakter terlihat kontras & hidup
	var halo_img := Image.create(140, 44, false, Image.FORMAT_RGBA8)
	for y in range(44):
		for x in range(140):
			var nx: float = (float(x) - 69.5) / 68.0
			var ny: float = (float(y) - 21.5) / 20.0
			var d: float = nx * nx + ny * ny
			if d < 1.0:
				var a: float = pow(1.0 - d, 1.6) * 0.22
				halo_img.set_pixel(x, y, Color(0.92, 0.78, 0.52, a))
	var halo_sprite := Sprite2D.new()
	halo_sprite.texture = ImageTexture.create_from_image(halo_img)
	halo_sprite.position = Vector2(100, 58)
	holder.add_child(halo_sprite)

	# Garis pijakan tanah pixel-art tipis di bawah kaki MC
	var track_line := ColorRect.new()
	track_line.color = Color(0.55, 0.45, 0.32, 0.35)
	track_line.position = Vector2(36, 66)
	track_line.size = Vector2(128, 2)
	track_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(track_line)

	var tex: Texture2D = load("res://assets/sprites/characters/player.png")
	if tex != null:
		var frames := SpriteFrames.new()
		frames.remove_animation("default")
		var fw: float = tex.get_width() / 4.0
		var fh: float = tex.get_height() / 4.0
		var row: int = 1 if walk_dir == "left" else 2
		frames.add_animation("walk")
		frames.set_animation_loop("walk", true)
		frames.set_animation_speed("walk", 8.5)
		for col in [1, 2, 3, 0]:
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(col * fw, row * fh, fw, fh)
			frames.add_frame("walk", atlas)

		var start_x: float = 122.0 if walk_dir == "left" else 78.0
		var end_x: float = 78.0 if walk_dir == "left" else 122.0

		var walker_node := Node2D.new()
		walker_node.position = Vector2(start_x, 42)
		holder.add_child(walker_node)

		# Bayangan pijakan oval di bawah kaki MC
		var sh_img := Image.create(24, 8, false, Image.FORMAT_RGBA8)
		for y in range(8):
			for x in range(24):
				var nx: float = (float(x) - 11.5) / 11.0
				var ny: float = (float(y) - 3.5) / 3.5
				if nx * nx + ny * ny < 1.0:
					sh_img.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.55))
		var foot_shadow := Sprite2D.new()
		foot_shadow.texture = ImageTexture.create_from_image(sh_img)
		foot_shadow.position = Vector2(0, 23)
		walker_node.add_child(foot_shadow)

		# Rim glow keemasan tipis di tepi karakter
		var rim_sprite := AnimatedSprite2D.new()
		rim_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		rim_sprite.sprite_frames = frames
		rim_sprite.scale = Vector2(1.58, 1.58)
		rim_sprite.modulate = Color(0.95, 0.80, 0.52, 0.42)
		rim_sprite.play("walk")
		walker_node.add_child(rim_sprite)

		# Sprite MC dengan tone siluet malam hangat (tetap terlihat detail rambut & bajunya dengan jelas)
		var mc_sprite := AnimatedSprite2D.new()
		mc_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		mc_sprite.sprite_frames = frames
		mc_sprite.scale = Vector2(1.5, 1.5)
		mc_sprite.modulate = Color(0.72, 0.76, 0.86, 1.0)
		mc_sprite.play("walk")
		walker_node.add_child(mc_sprite)

		# Animasi MC benar-benar melangkah maju di atas garis pijakan selama loading
		var walk_tw := holder.create_tween()
		walk_tw.tween_property(walker_node, "position:x", end_x, maxf(0.45, travel_duration)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	return holder

func play_time_skip_cutscene(slide_text: String, next_dialog_id: String = "", auto_close_delay: float = -1.0, walk_dir: String = "right") -> void:
	if _is_cutscene_active:
		return
	_is_cutscene_active = true

	if is_instance_valid(player):
		player.velocity = Vector2.ZERO
		if player.has_method("set_physics_process"):
			player.set_physics_process(false)

	var cl := CanvasLayer.new()
	cl.layer = 150
	cl.name = "TwoDaysCutscene"
	add_child(cl)

	var root_ctrl := Control.new()
	root_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_ctrl.mouse_filter = Control.MOUSE_FILTER_STOP
	cl.add_child(root_ctrl)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.06, 0.08, 1.0)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_ctrl.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_ctrl.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(520, 200)
	vbox.add_theme_constant_override("separation", 10)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(vbox)

	var is_pure_loading: bool = slide_text.strip_edges().is_empty()
	var dur: float = 0.55 if auto_close_delay > 0.0 else 1.1

	# Karakter MC berjalan melintasi pijakan HANYA pada perpindahan map / loading antar-zona,
	# BUKAN pada perpindahan hari (perpindahan hari tampil hening & bersih dengan teks saja).
	if is_pure_loading:
		var mc_shadow := _build_walking_shadow_mc(walk_dir, dur + (auto_close_delay if auto_close_delay > 0.0 else 0.4))
		vbox.add_child(mc_shadow)

	var pixel_font: Font = load("res://assets/fonts/PixelifySans.ttf") if ResourceLoader.exists("res://assets/fonts/PixelifySans.ttf") else null

	# Bar loading pixel-art ramping + tulisan LOADING...
	var load_box := VBoxContainer.new()
	load_box.add_theme_constant_override("separation", 6)
	load_box.alignment = BoxContainer.ALIGNMENT_CENTER
	load_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(load_box)

	var progress := ProgressBar.new()
	progress.custom_minimum_size = Vector2(140, 7)
	progress.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	progress.min_value = 0.0
	progress.max_value = 100.0
	progress.value = 0.0
	progress.show_percentage = false
	var sb_bg := StyleBoxFlat.new()
	sb_bg.bg_color = Color(0.16, 0.18, 0.24, 0.95)
	sb_bg.border_width_left = 1
	sb_bg.border_width_top = 1
	sb_bg.border_width_right = 1
	sb_bg.border_width_bottom = 1
	sb_bg.border_color = Color(0.45, 0.38, 0.26, 0.85)
	sb_bg.set_corner_radius_all(3)
	var sb_fill := StyleBoxFlat.new()
	sb_fill.bg_color = Color(0.92, 0.74, 0.38, 0.95)
	sb_fill.set_corner_radius_all(2)
	progress.add_theme_stylebox_override("background", sb_bg)
	progress.add_theme_stylebox_override("fill", sb_fill)
	load_box.add_child(progress)

	var loading_lbl := Label.new()
	loading_lbl.text = "LOADING..."
	loading_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_lbl.add_theme_color_override("font_color", Color(0.86, 0.78, 0.62, 0.92))
	loading_lbl.add_theme_font_size_override("font_size", 11)
	if pixel_font:
		loading_lbl.add_theme_font_override("font", pixel_font)
	load_box.add_child(loading_lbl)
	load_box.visible = is_pure_loading

	var title_label := RichTextLabel.new()
	title_label.bbcode_enabled = true
	title_label.fit_content = true
	title_label.scroll_active = false
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	title_label.custom_minimum_size = Vector2(500, 48)
	title_label.add_theme_color_override("default_color", Color(0.90, 0.88, 0.82, 0.96))
	title_label.add_theme_font_size_override("normal_font_size", 15)
	title_label.add_theme_font_size_override("bold_font_size", 16)
	if pixel_font:
		title_label.add_theme_font_override("normal_font", pixel_font)
		title_label.add_theme_font_override("bold_font", pixel_font)
		title_label.add_theme_font_override("italics_font", pixel_font)
	vbox.add_child(title_label)

	var next_hint_lbl := Label.new()
	next_hint_lbl.text = "Next ▶"
	next_hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	next_hint_lbl.add_theme_color_override("font_color", Color(0.75, 0.68, 0.55, 0.85))
	next_hint_lbl.add_theme_font_size_override("font_size", 11)
	if pixel_font:
		next_hint_lbl.add_theme_font_override("font", pixel_font)
	next_hint_lbl.visible = (not is_pure_loading) and (auto_close_delay <= 0.0)
	next_hint_lbl.modulate.a = 0.0
	vbox.add_child(next_hint_lbl)

	var input_btn := Button.new()
	input_btn.name = "CutsceneInputBtn"
	input_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	input_btn.flat = true
	input_btn.focus_mode = Control.FOCUS_NONE
	root_ctrl.add_child(input_btn)

	var state := {
		"is_typing": false,
		"tween": null,
		"is_closing": false
	}

	var finish_cutscene: Callable
	finish_cutscene = func():
		if state.is_closing:
			return
		if state.is_typing:
			if state.tween and is_instance_valid(state.tween):
				state.tween.kill()
			state.is_typing = false
			title_label.visible_ratio = 1.0
			progress.value = 100.0
			next_hint_lbl.modulate.a = 1.0
			AudioManager.play_sfx("tap_b")
			return

		state.is_closing = true
		_cutscene_advance_cb = Callable()
		_is_cutscene_active = false
		AudioManager.play_sfx("tap_b")
		if is_instance_valid(player) and player.has_method("set_physics_process"):
			player.set_physics_process(true)
		var fade := cl.create_tween()
		fade.tween_property(root_ctrl, "modulate:a", 0.0, 0.22)
		fade.tween_callback(func():
			if is_instance_valid(cl):
				cl.queue_free()
		)
		if not next_dialog_id.is_empty():
			DialogueManager.mulai(next_dialog_id)

	_cutscene_advance_cb = finish_cutscene

	title_label.visible = not is_pure_loading
	title_label.text = slide_text
	title_label.visible_ratio = 0.0
	state.is_typing = true
	var tw0 := cl.create_tween()
	state.tween = tw0
	tw0.tween_property(title_label, "visible_ratio", 1.0, dur)
	tw0.parallel().tween_property(progress, "value", 100.0, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw0.tween_callback(func():
		state.is_typing = false
		next_hint_lbl.modulate.a = 1.0
		if auto_close_delay > 0.0:
			var tw_close := cl.create_tween()
			tw_close.tween_interval(auto_close_delay)
			tw_close.tween_callback(func():
				if not state.is_closing:
					finish_cutscene.call()
			)
	)

	input_btn.pressed.connect(func(): finish_cutscene.call())

func play_zone_loading_transition(_zone: String, walk_dir: String = "right") -> void:
	play_time_skip_cutscene("", "", 0.35, walk_dir)

func play_two_days_later_cutscene() -> void:
	play_time_skip_cutscene("[center][b][font_size=22]2 hari kemudian.[/font_size][/b][/center]", "h1_narasi_2hari")

func advance_cutscene() -> void:
	if _is_cutscene_active and _cutscene_advance_cb.is_valid():
		_cutscene_advance_cb.call()

func _check_story_proximity() -> void:
	if _dialogue_active or DialogueManager.is_active() or _is_cutscene_active:
		return
	if not is_instance_valid(player):
		return

	var step: String = str(GameState.choices.get("hulu_story_step", ""))

	if _current_zone == "hulu":
		var player_tile: Vector2 = player.global_position / float(TILE)

		# Step 1: Menuju jembatan untuk pertama kali -> Suara Datuk tanpa wujud
		if step == "menuju_toko_jaya" and not _has_triggered_bridge_voice:
			if player_tile.x >= 25.0 and player_tile.x <= 28.5 and abs(player_tile.y - 15.0) <= 3.0:
				_has_triggered_bridge_voice = true
				player.velocity = Vector2.ZERO
				DialogueManager.mulai("h1_jembatan_suara")
				return

		# Step 2: MC mencari suara lalu melangkah ke jembatan -> Datuk menampakkan diri
		if step == "cari_suara_jembatan" and not _has_triggered_datuk_bridge:
			if player_tile.x >= 28.0 and player_tile.x <= 31.0 and abs(player_tile.y - 15.0) <= 3.0:
				_has_triggered_datuk_bridge = true
				player.velocity = Vector2.ZERO
				_sync_hulu_story_state()
				DialogueManager.mulai("h1_datuk")
				return

		# Step 4: Kembali pulang dari Toko Jaya untuk istirahat -> Cutscene 1 Hari Kemudian
		if step == "pulang_istirahat" and not _has_triggered_home_day:
			if player_tile.distance_to(Vector2(7.0, 12.5)) <= 4.2:
				_has_triggered_home_day = true
				player.velocity = Vector2.ZERO
				play_time_skip_cutscene("[center][b][font_size=22]1 Hari Kemudian...[/font_size][/b][/center]", "h2_narasi_pagi")
				return

	elif _current_zone == "desa":
		var local_tile: Vector2 = (player.global_position - _zone_containers["desa"].global_position) / float(TILE)

		# Step 3: Di Toko Jaya (Desa), mendapati Pak Darwis membeli kasur baru & mengaku menghanyutkan kasur lama
		if step == "ke_toko_jaya" and not _has_triggered_toko_jaya:
			if local_tile.distance_to(Vector2(11.2, 12.2)) <= 3.5:
				_has_triggered_toko_jaya = true
				player.velocity = Vector2.ZERO
				DialogueManager.mulai("h1_toko_jaya")
				return

		# Step 5: Menghampiri warung Kak Rina (di deret warung selatan Desa) untuk membeli gorengan
		if step == "ke_warung_rina" and not _has_triggered_warung_rina:
			if local_tile.distance_to(Vector2(40.5, 24.0)) <= 3.5:
				_has_triggered_warung_rina = true
				player.velocity = Vector2.ZERO
				DialogueManager.mulai("h4_rina")
				return

	elif _current_zone == "kota":
		var local_tile: Vector2 = (player.global_position - _zone_containers["kota"].global_position) / float(TILE)

		# Step 6: Menghampiri Bang Jali di tepi sungai/kanal kota
		if step == "kota_gang_sempit" and not _has_triggered_kota_gang:
			if local_tile.distance_to(Vector2(10.5, 12.8)) <= 3.5:
				_has_triggered_kota_gang = true
				player.velocity = Vector2.ZERO
				DialogueManager.mulai("h2_jali")
				return

func _spawn_hulu_riverbank_trash() -> void:
	if _trash_spawned_hulu_river:
		return
	_trash_spawned_hulu_river = true
	var trash_scene := preload("res://scenes/world/trash_topdown.tscn")
	var river_spots: Array[Vector2] = [
		# Bantaran barat sungai hulu (7 titik tersebar rapi di sepanjang tepi air):
		Vector2(23.5, 6.0),   # Tepi pasir utara dekat mata air
		Vector2(23.5, 8.5),   # Bantaran pasir utara atas
		Vector2(23.8, 11.5),  # Bantaran pasir utara tengah
		Vector2(23.5, 14.5),  # Sisi barat dekat jembatan
		Vector2(23.8, 17.5),  # Bantaran pasir selatan bawah jembatan
		Vector2(23.8, 20.5),  # Bantaran pasir selatan bawah
		Vector2(24.0, 23.5),  # Ujung pasir barat daya

		# Bantaran timur sungai hulu (8 titik tersebar rapi di sepanjang tepi air):
		Vector2(35.5, 6.5),   # Tepi pasir utara seberang jembatan
		Vector2(36.0, 9.5),   # Tepi air timur atas
		Vector2(36.0, 12.0),  # Tepi air timur tengah
		Vector2(35.5, 15.0),  # Tepi jembatan timur
		Vector2(36.0, 18.0),  # Tepi air timur bawah jembatan
		Vector2(36.5, 21.0),  # Tepi pasir tenggara
		Vector2(37.5, 23.5),  # Tikungan pasir tenggara
		Vector2(38.0, 26.0),  # Ujung pasir selatan timur
	]
	var cats: Array[String] = ["plastik", "organik", "plastik", "b3", "organik", "plastik"]
	for i in range(river_spots.size()):
		var tid: String = "hulu_river_trash_%d" % i
		if tid in GameState.picked_trash_ids:
			continue
		var trash := trash_scene.instantiate()
		trash.position = (river_spots[i] + Vector2(0.5, 0.5)) * TILE
		trash.set("trash_id", tid)
		trash.set("category", cats[i % cats.size()])
		trash.add_to_group("world_trash")
		_zone_containers["hulu"].add_child(trash)

func _get_hulu_riverbank_trash_cleaned_count() -> int:
	var count: int = 0
	for i in range(15):
		var tid: String = "hulu_river_trash_%d" % i
		if tid in GameState.picked_trash_ids:
			count += 1
	var sorted: int = GameState.zone_stat("hulu", "sorted")
	return maxi(count, sorted)

func _trigger_selesai_sungai() -> void:
	if _dialogue_active or DialogueManager.is_active():
		return
	DialogueManager.mulai("h1_selesai_sungai")

func _on_meter_changed(new_val: float) -> void:
	_refresh_mission()
	if new_val >= 100.0 and not _is_cutscene_active and not _flood_triggered:
		_flood_triggered = true
		call_deferred("play_catastrophic_flood_cutscene")

func play_catastrophic_flood_cutscene() -> void:
	if _flood_cutscene == null:
		var scn: PackedScene = load("res://scenes/world/flood_cutscene.tscn")
		if scn:
			_flood_cutscene = scn.instantiate() as CanvasLayer
			add_child(_flood_cutscene)
	if _flood_cutscene:
		_is_cutscene_active = true
		if hud:
			hud.visible = false
		if touch_controls:
			touch_controls.visible = false
		_flood_cutscene.start_flood(camera, player)

func _trigger_final_ending() -> void:
	if _dialogue_active or DialogueManager.is_active():
		return
	for level in [1, 2, 3, 4]:
		if level not in GameState.levels_completed:
			GameState.levels_completed.append(level)
	GameState.world_completed = true
	GameState.in_world = false
	GameState.current_level = 5
	var kode: String = GameState.hitung_kode_ending()
	GameState.ending_terakhir = kode
	GameState.save_game()
	if kode == "D" and not _flood_triggered:
		_flood_triggered = true
		play_catastrophic_flood_cutscene()
	else:
		GameState.tentukan_ending(true)

func _on_hulu_riverbank_investigated() -> void:
	pass

func _on_dialog_selesai(id_dialog: String) -> void:
	match id_dialog:
		"h1_warung":
			on_npc_talked("npc_ibu_mc")
			play_two_days_later_cutscene()
		"h1_narasi_2hari":
			GameState.record_choice("hulu_story_step", "butuh_pesan_kasur")
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
			toast("Bicara lagi dengan Mak di warung.", true)
		"h1_warung_kasur":
			on_npc_talked("npc_ibu_mc")
			GameState.record_choice("hulu_story_step", "menuju_toko_jaya")
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			# Muncul otomatis 1 KALI saja di sini setelah bicara dengan Mak dan disuruh beli kasur
			if not bool(GameState.choices.get("mission_first_auto_opened", false)):
				GameState.record_choice("mission_first_auto_opened", true)
				if hud and hud.has_method("show_mission"):
					hud.show_mission()
			GameState.save_game()
			toast("Tujuan: Toko Jaya di desa sebelah untuk memesan kasur baru.", true)
		"h1_jembatan_suara":
			GameState.record_choice("hulu_story_step", "cari_suara_jembatan")
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
			toast("Suara siapa itu tadi? Cari di sekitar jembatan!", true)
		"h1_datuk":
			on_npc_talked("npc_datuk")
			GameState.record_choice("datuk_bencana_revealed", true)
			GameState.meter_bencana = 70.0
			GameState.record_choice("hulu_story_step", "bersihkan_sungai")
			_sync_hulu_story_state()
			_spawn_hulu_riverbank_trash()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
			toast("Datuk Sampan memperingatkan: Ancaman bencana sungai melonjak ke 70%! Bersihkan sampah di pinggiran sungai.", true)
			var sorted: int = GameState.zone_stat("hulu", "sorted")
			var cleaned: int = _get_hulu_riverbank_trash_cleaned_count()
			var carry_cnt: int = GameState.get_pending_trash_count() if GameState.has_method("get_pending_trash_count") else GameState.get_meta("pending_trash", []).size()
			if sorted >= 5 or (carry_cnt == 0 and cleaned >= 5):
				call_deferred("_trigger_selesai_sungai")
		"h1_selesai_sungai":
			on_npc_talked("npc_datuk")
			GameState.record_choice("hulu_story_step", "tanam_pohon_hulu")
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
			toast("Temui Penjaga Hutan di bukit hulu untuk reboisasi.", true)
		"h1_penjaga_hutan":
			on_npc_talked("npc_penjaga_hutan")
			GameState.record_choice("hulu_story_step", "menanam_pohon_hulu")
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
			toast("Tanam 15 bibit pohon hutan di titik-titik bertanda!", true)
		"h1_penjaga_hutan_selesai":
			on_npc_talked("npc_penjaga_hutan")
			GameState.record_choice("penjaga_hutan_selesai", true)
			GameState.record_choice("hulu_story_step", "ke_toko_jaya")
			_sync_hulu_story_state()
			_refresh_mission()
			_refresh_gates()
			_update_guidance()
			GameState.save_game()
			toast("Hutan kembali rimbun! Lanjutkan ke Toko Jaya di Desa.", true)
		"h1_toko_jaya", "h6_darwis":
			on_npc_talked("npc_petani_1")
			on_npc_talked("npc_pemilik_toko")
			if bool(GameState.choices.get("darwis_peduli", false)):
				GameState.record_choice("darwis_done", true)
				GameState.record_choice("pemilik_toko_done", true)
				GameState.record_choice("hulu_story_step", "pulang_istirahat")
				toast("Pak Darwis paham! Kembali ke warung hulu untuk beristirahat.", true)
			elif bool(GameState.choices.get("mencari_solusi_darwis", false)) and not bool(GameState.choices.get("unlock_solusi_darwis", false)):
				GameState.record_choice("hulu_story_step", "pantun_kasur_darwis")
				toast("Periksa Papan Pantun di dekat Toko Jaya untuk mencari jalan keluar.", true)
			else:
				# Pilihan C atau D: Gagal dan final! Tidak bisa diubah atau diulang lagi.
				GameState.record_choice("darwis_done", true)
				GameState.record_choice("pemilik_toko_done", true)
				GameState.record_choice("darwis_peduli", false)
				GameState.record_choice("darwis_menolak", true)
				GameState.record_choice("hulu_story_step", "pulang_istirahat")
				toast("Pak Darwis menolak saranmu. Urusan kasur selesai, kembali ke warung hulu.", false)
			_sync_hulu_story_state()
			_refresh_mission()
			_refresh_gates()
			_update_guidance()
			GameState.save_game()
		"h1_darwis_menunggu":
			on_npc_talked("npc_petani_1")
			on_npc_talked("npc_pemilik_toko")
			_update_guidance()
		"h1_pantun_darwis":
			_complete_pantun_step("h1_pantun_darwis", true)
		"h2_narasi_pagi":
			GameState.record_choice("hulu_story_step", "pesan_gorengan")
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
			toast("Bicara dengan Ibu di warung.", true)
		"h2_warung_gorengan":
			on_npc_talked("npc_ibu_mc")
			GameState.record_choice("hulu_story_step", "ke_warung_rina")
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
			toast("Beli gorengan di warung Kak Rina di Desa.", true)
		"h4_rina":
			on_npc_talked("npc_ibu_desa")
			if bool(GameState.choices.get("mencari_solusi_rina", false)):
				if bool(GameState.choices.get("unlock_solusi_rina", false)):
					GameState.record_choice("hulu_story_step", "cari_solusi_jelantah")
					toast("Inspirasi sudah didapat! Temui Pemuka Desa untuk meminta jeriken.", true)
				else:
					GameState.record_choice("hulu_story_step", "pantun_jelantah_rina")
					toast("Periksa Papan Pantun Desa untuk mencari solusi minyak jelantah.", true)
			else:
				GameState.record_choice("rina_done", true)
				GameState.record_choice("hulu_story_step", "antar_gorengan")
				toast("Kak Rina menolak. Antar gorengan ke Ibu di rumah.", false)
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
		"h2_pantun_rina":
			_complete_pantun_step("h2_pantun_rina", true)
		"h2_pemuka_desa":
			on_npc_talked("npc_pemuka_desa")
			GameState.record_choice("has_jeriken_and_info", true)
			GameState.record_choice("pemuka_desa_done", true)
			GameState.record_choice("hulu_story_step", "serahkan_jeriken_rina")
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
			toast("Dapat Jeriken Kosong & Info Biodiesel! Antar ke Kak Rina.", true)
		"h5_rina":
			on_npc_talked("npc_ibu_desa")
			GameState.record_choice("rina_done", true)
			GameState.record_choice("h5_rina_done", true)
			GameState.record_choice("hulu_story_step", "antar_gorengan")
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
			toast("Kak Rina peduli! Antar gorengan ke Ibu di warung.", true)
		"h2_warung_gorengan_selesai":
			on_npc_talked("npc_ibu_mc")
			GameState.record_choice("hulu_story_step", "ke_kota_medan")
			_sync_hulu_story_state()
			_refresh_mission()
			_refresh_gates()
			_update_guidance()
			GameState.save_game()
			toast("Gorengan diantar! Pergi ke Kota Medan melalui gerbang timur Desa.", true)
		"h2_jali":
			on_npc_talked("npc_pedagang")
			if bool(GameState.choices.get("mencari_solusi_jali", false)):
				if bool(GameState.choices.get("unlock_solusi_jali", false)):
					GameState.record_choice("hulu_story_step", "cari_solusi_rt")
					toast("Inspirasi sudah didapat! Temui Pak RT untuk fasilitas gerobak roda.", true)
				else:
					GameState.record_choice("hulu_story_step", "pantun_gang_jali")
					toast("Periksa Papan Pantun di dekat zebra cross jalan raya.", true)
			else:
				GameState.record_choice("jali_done", true)
				GameState.record_choice("hulu_story_step", "periksa_saluran_kota")
				toast("Bang Jali menolak. Periksa saluran air dan pintu air kota.", false)
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
		"h3_pantun_jali":
			_complete_pantun_step("h3_pantun_jali", true)
		"h3_pak_rt":
			on_npc_talked("npc_tokoh_masyarakat")
			GameState.record_choice("has_rt_cart_approval", true)
			GameState.record_choice("pak_rt_done", true)
			GameState.record_choice("hulu_story_step", "serahkan_gerobak_jali")
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
			toast("Dapat Bahan Gerobak Roda RT! Serahkan ke Bang Jali.", true)
		"h3_jali":
			on_npc_talked("npc_pedagang")
			GameState.record_choice("jali_done", true)
			GameState.record_choice("h3_jali_done", true)
			GameState.record_choice("hulu_story_step", "periksa_saluran_kota")
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
			toast("Bang Jali peduli! Periksa saluran air dan pintu air kota.", true)
		"h3_ibu_rumah":
			on_npc_talked("npc_ibu_rumah")
			GameState.record_choice("ibu_rumah_done", true)
			GameState.record_choice("hulu_story_step", "pintu_air_dan_b3")
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
			toast("Periksa Papan Pantun di dekat zebra cross untuk memecahkan sandi tuas!", true)
		"h3_pantun_kota":
			GameState.record_choice("sandi_tuas_terbuka", true)
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
			toast("Sandi terpecahkan: Urutan Tuas 1 -> Tuas 3 -> Tuas 2!", true)
		"h3_budi", "h3_budi_selesai":
			on_npc_talked("npc_anak_sekolah")
			GameState.record_choice("budi_done", true)
			GameState.record_choice("hulu_story_step", "ke_hilir_muara")
			_sync_hulu_story_state()
			_refresh_mission()
			_refresh_gates()
			_update_guidance()
			GameState.save_game()
			toast("Aturan pantun dipahami! Lanjutkan ke Muara Hilir.", true)
		"h7_penjaga_sungai":
			on_npc_talked("npc_penjaga_sungai")
			GameState.record_choice("penjaga_sungai_done", true)
			if GameState.zone_stat("hilir", "sorted") >= zone_target("hilir", "sorted"):
				if bool(GameState.choices.get("pantun_muara_selesai", false)):
					GameState.record_choice("hulu_story_step", "temui_pak_nelayan")
					toast("Sampah pesisir & pantun sudah tuntas! Temui Pak Nelayan di pesisir pantai.", true)
				else:
					GameState.record_choice("hulu_story_step", "papan_pantun_muara")
					toast("Semua sampah pesisir sudah bersih! Periksa Papan Pantun di muara.", true)
			else:
				GameState.record_choice("hulu_story_step", "pilah_sampah_muara")
				toast("Bersihkan seluruh sampah pesisir muara ke tempat sampah!", true)
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
		"h7_pantun":
			_complete_pantun_step("h7_pantun", true)
		"pantun_selesai":
			_complete_pantun_step(_last_solved_pantun_id, false)
		"h7_nelayan":
			on_npc_talked("npc_nelayan")
			GameState.record_choice("nelayan_awal_done", true)
			GameState.record_choice("hulu_story_step", "tanam_mangrove_muara")
			_sync_hulu_story_state()
			_refresh_mission()
			_update_guidance()
			GameState.save_game()
			toast("Tanam 12 bibit bakau (mangrove) di pesisir pantai!", true)
		"h7_nelayan_selesai":
			on_npc_talked("npc_nelayan")
			GameState.record_choice("nelayan_selesai", true)
			GameState.record_choice("hulu_story_step", "selesai_perjalanan")

			# Batas waktu pengutipan sampah: cek seluruh sampah di 4 zona yang belum dibersihkan
			var total_remaining_trash: int = 0
			for z in ["hulu", "desa", "kota", "hilir"]:
				var t: int = zone_target(z, "sorted")
				var d: int = mini(GameState.zone_stat(z, "sorted"), t)
				total_remaining_trash += maxi(0, t - d)
			if total_remaining_trash > 0:
				GameState.meter_bencana = clampf(GameState.meter_bencana + 20.0, 5.0, 100.0)
				toast("Misi membersihkan gagal! %d sampah belum dibersihkan — Bahaya naik +20%%!" % total_remaining_trash, false)
			else:
				toast("12 Mangrove & seluruh sampah tuntas! Menentukan hasil akhir...", true)

			_sync_hulu_story_state()
			_refresh_mission()
			_refresh_gates()
			_update_guidance()
			GameState.save_game()
			if total_remaining_trash > 0 and GameState.meter_bencana < 100.0:
				get_tree().create_timer(1.6).timeout.connect(_trigger_final_ending)
			else:
				call_deferred("_trigger_final_ending")
		"h1_river_sound":
			toast("Suara misterius terdengar! Cari asal suaranya di tepi sungai utara.", true)

func _spawn_gameplay_objects() -> void:
	# Hulu — tutorial alam: reboisasi di kawasan hutan + 3 kategori sampah (muncul dari awal cerita).
	_spawn_hulu_riverbank_trash()
	_spawn_zone_bins("hulu")
	_spawn_fixed_spots("hulu", HULU_FOREST_SPOTS, "tree", "trees", "hulu_tree")

	# Desa — gotong royong warga.
	_spawn_zone_trash("desa", 16, ["organik", "plastik", "b3"])
	_spawn_zone_bins("desa")

	# Kota — aspirasi warga perkotaan.
	_spawn_zone_trash("kota", 20, ["organik", "plastik", "b3"])
	_spawn_zone_bins("kota")
	_spawn_kota_levers()

	# Hilir — mangrove pesisir muara.
	_spawn_zone_trash("hilir", 16, ["organik", "plastik", "b3"])
	_spawn_zone_bins("hilir")
	_spawn_fixed_spots("hilir", HILIR_MANGROVE_SPOTS, "mangrove", "mangroves", "hilir_mangrove")

	_spawn_pantun_boards()

func _get_riverbank_trash_spots(zone: String) -> Array[Vector2i]:
	var spots: Array[Vector2i] = []
	match zone:
		"desa":
			# Bantaran pasir utara sungai selatan (row 25) terbentang di sepanjang peta (x=40 dikosongkan di depan warung Kak Rina, x=55 dikosongkan di depan rumah modern)
			for x in [4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34, 37, 43, 46, 49, 52]:
				spots.append(Vector2i(x, 25))
		"kota":
			# Bantaran tanggul beton utara (row 13) dan selatan (row 17) kanal kota (x=11 & x=32 dikosongkan untuk Bang Jali & Ibu Rumah Tangga, x=41 & x=50 dikosongkan untuk Budi & Papan Pantun)
			for x in [5, 8, 14, 17, 26, 29, 35, 38, 44, 47, 53, 56]:
				spots.append(Vector2i(x, 13))
				spots.append(Vector2i(x, 17))
		"hilir":
			# Bantaran utara (row 13) dekat perkampungan nelayan
			# Kawasan pembibitan & bantaran lumpur selatan (y >= 17) bebas dari sampah
			for x in [4, 8, 12, 16, 42, 46, 50, 54]:
				spots.append(Vector2i(x, 13))
	return spots

func _spawn_zone_trash(zone: String, count: int, categories: Array) -> void:
	var trash_scene := preload("res://scenes/world/trash_topdown.tscn")
	# Saat melanjutkan save, jangan munculkan lagi sampah yang sudah dipilah.
	var already_sorted: int = GameState.zone_stat(zone, "sorted")
	var river_spots := _get_riverbank_trash_spots(zone)
	var max_items: int = maxi(count, river_spots.size())

	for i in range(max_items):
		var tid: String = "%s_trash_%d" % [zone, i]
		if tid in GameState.picked_trash_ids or i < already_sorted:
			continue
		var target_tile: Vector2i
		if i < river_spots.size():
			target_tile = river_spots[i]
		else:
			var x: int = 4 + (i * 73 + 17) % (ZONE_WIDTH - 8)
			var max_y: int = 12 if zone == "hilir" else (ZONE_HEIGHT - 8)
			var y: int = 4 + (i * 37 + 11) % max_y
			target_tile = Vector2i(x, y)

		var tile := _find_spawn_tile(zone, target_tile)
		if tile.x < 0:
			continue
		var trash := trash_scene.instantiate()
		trash.position = (Vector2(tile) + Vector2(0.5, 0.6)) * TILE
		trash.set("trash_id", tid)
		trash.set("category", categories[i % categories.size()])
		trash.add_to_group("world_trash")
		_zone_containers[zone].add_child(trash)

## Cari tile terdekat yang bukan air, bukan bangunan, dan masih di dalam peta.
func _find_spawn_tile(zone: String, base: Vector2i) -> Vector2i:
	var offsets: Array[Vector2i] = [
		Vector2i(0, 0),
		Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1),
		Vector2i(0, 2), Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, -2),
		Vector2i(3, 0), Vector2i(0, 3), Vector2i(-3, 0), Vector2i(0, -3),
		Vector2i(2, 2), Vector2i(-2, 2), Vector2i(2, -2), Vector2i(-2, -2),
		Vector2i(4, 0), Vector2i(0, 4), Vector2i(-4, 0), Vector2i(0, -4),
	]
	for offset in offsets:
		var tile: Vector2i = base + offset
		if zone == "hilir" and tile.y >= 17:
			continue
		if _is_valid_spawn_tile(zone, tile) and not _near_planting_spot(zone, tile):
			return tile
	return Vector2i(-1, -1)

func _near_planting_spot(zone: String, tile: Vector2i) -> bool:
	if zone != "hulu" and zone != "hilir":
		return false
	var list: Array[Vector2i] = HULU_FOREST_SPOTS if zone == "hulu" else HILIR_MANGROVE_SPOTS
	for spot in list:
		if abs(tile.x - spot.x) <= 1 and abs(tile.y - spot.y) <= 1:
			return true
	return false

func _is_valid_spawn_tile(zone: String, tile: Vector2i) -> bool:
	if tile.x < 2 or tile.x >= ZONE_WIDTH - 2 or tile.y < 2 or tile.y >= ZONE_HEIGHT - 2:
		return false
	if _zone_in_water(zone, (Vector2(tile) + Vector2(0.5, 0.5)) * TILE):
		return false
	if _blocked_by_building(zone, Rect2(Vector2(tile) - Vector2(1, 1), Vector2(2, 2))):
		return false
	return true

## Memunculkan titik tanam di daftar koordinat tetap (satu kawasan hutan Hulu / tepi pantai Hilir).
func _spawn_fixed_spots(zone: String, spots: Array[Vector2i], kind: String, _stat_key: String, id_prefix: String) -> void:
	var tree_scene := preload("res://scenes/world/tree_spot_topdown.tscn")
	for idx in range(spots.size()):
		var tile: Vector2i = spots[idx]
		if not _is_valid_spawn_tile(zone, tile):
			continue
		var spot := tree_scene.instantiate()
		spot.position = (Vector2(tile) + Vector2(0.5, 0.5)) * TILE
		spot.set("kind", kind)
		spot.set("spot_id", "%s_%d" % [id_prefix, idx])
		_zone_containers[zone].add_child(spot)

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

func _spawn_zone_bins(zone: String, _categories: Array = []) -> void:
	var bin_scene := preload("res://scenes/world/bin_topdown.tscn")
	# Koordinat tong sampah umum yang diletakkan rapi di samping bangunan/warung/pasar,
	# sehingga tidak pernah menghalangi jalan utama, trotoar, jembatan, atau gerbang zona.
	var positions_by_zone: Dictionary = {
		"hulu": [
			Vector2(10.5, 11.5), # Nempel sejajar dinding kanan Rumah/Warung MC (y=176px)
			Vector2(23.5, 12.0), # Sisi barat jembatan Hulu tepat di tepi sungai
			Vector2(35.0, 12.0), # Sisi timur jembatan Hulu tepat di tepi sungai
		],
		"desa": [
			Vector2(32.5, 24.5), # Di tepi jalan kampung selatan (bebas dari badan Warung Barokah)
			Vector2(20.0, 24.5), # Di bantaran sungai selatan Desa dekat jalan setapak
		],
		"kota": [
			Vector2(17.0, 5.0),  # Nempel sejajar garis dinding Gedung Office utara (y=60px)
			Vector2(13.0, 22.0), # Nempel sejajar dinding kanan Pasar Sayur Bang Jali di plaza selatan (y=350px)
			Vector2(25.0, 13.0), # Di tepi tanggul kanal dekat jembatan barat
			Vector2(65.0, 13.0), # Di tepi tanggul kanal timur (ujung kanal)
		],
		"hilir": [
			{"pos": Vector2(10.2, 5.0), "cat": "organik"},  # Rumah Pesisir barat (Tong Hijau Organik)
			{"pos": Vector2(50.2, 5.0), "cat": "plastik"},  # Pasar Ikan (Tong Kuning Anorganik)
			{"pos": Vector2(19.0, 13.0), "cat": "b3"},       # Pangkal jembatan kayu pesisir (Tong Merah B3)
		],
	}
	var quest_by_zone: Dictionary = {
		"desa": "pilah_desa",
		"kota": "pilah_sampah_kota",
		"hilir": "pilah_hilir",
	}
	var coords: Array = positions_by_zone.get(zone, [])
	for entry in coords:
		var bin := bin_scene.instantiate()
		var pos: Vector2 = Vector2.ZERO
		var cat: String = "umum"
		if entry is Dictionary:
			pos = entry.get("pos", Vector2.ZERO)
			cat = str(entry.get("cat", "umum"))
		elif entry is Vector2:
			pos = entry
		bin.position = pos * TILE
		bin.set("bin_category", cat)
		bin.set("required_quest", quest_by_zone.get(zone, ""))
		bin.add_to_group("world_bin")
		_zone_containers[zone].add_child(bin)

func _spawn_pantun_boards() -> void:
	var board_scene := preload("res://scenes/world/pantun_board.tscn")
	# 4 Papan Pantun tersebar di Desa & Kota untuk memecahkan dilema lingkungan,
	# ditambah 1 papan pantun ujian akhir di Muara Hilir (total 5 papan):
	var board_configs: Array[Dictionary] = [
		{"zone": "hulu", "pos": Vector2(19.5, 11.8) * TILE, "dialog": ""},
		{"zone": "desa", "pos": Vector2(16.0, 13.5) * TILE, "dialog": "h1_pantun_darwis"}, # Papan Kasur Darwis (Toko Jaya)
		{"zone": "desa", "pos": Vector2(37.0, 23.0) * TILE, "dialog": "h2_pantun_rina"},   # Papan Jelantah Rina (Warung)
		{"zone": "kota", "pos": Vector2(14.0, 12.8) * TILE, "dialog": "h3_pantun_jali"},   # Papan Gang Jali (Mulut Gang)
		{"zone": "kota", "pos": Vector2(50.0, 12.5) * TILE, "dialog": "h3_pantun_kota"},   # Papan Sandi Pintu Air (Kanal)
		{"zone": "hilir", "pos": Vector2(18.0, 12.5) * TILE, "dialog": "h7_pantun"},      # Papan Pantun Ujian Muara
	]
	for cfg in board_configs:
		var board := board_scene.instantiate()
		board.position = cfg["pos"]
		board.set("pantun_id", cfg["dialog"])
		_zone_containers[cfg["zone"]].add_child(board)

func _spawn_kota_levers() -> void:
	var lever_scene := preload("res://scenes/world/lever_topdown.tscn")
	var positions: Array[Vector2] = [
		Vector2(52, 13),   # Tuas 1 (Depan - tepi utara kanal timur)
		Vector2(57, 13),   # Tuas 2 (Tengah)
		Vector2(54, 24.0), # Tuas 3 (Belakang - plaza pejalan kaki selatan, di depan toko sembako terbuka & bebas halangan)
	]
	var labels: Array[String] = [
		"Tuas 1 (Depan)",
		"Tuas 2 (Tengah)",
		"Tuas 3 (Belakang)"
	]
	var is_open: bool = bool(GameState.choices.get("pintu_air_terbuka", false))
	for i in range(positions.size()):
		var lever := lever_scene.instantiate() as Area2D
		lever.position = positions[i] * TILE
		lever.set("lever_id", i + 1)
		lever.set("custom_label", labels[i])
		_zone_containers["kota"].add_child(lever)
		if is_open:
			lever.set("_pressed", true)
			var spr = lever.get_node_or_null("Sprite2D") as Sprite2D
			if spr:
				spr.texture = load("res://assets/sprites/props/lever_on.png")

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

func can_use_zone_gate() -> bool:
	return Time.get_ticks_msec() - _last_zone_switch_ms >= 350

func change_zone(zone: String, custom_local_pos: Vector2 = Vector2(-1, -1), save_state: bool = true) -> void:
	if zone == "epilog":
		finish_journey()
		return
	if zone not in _zone_containers:
		return

	# Hide all zones
	for z in _zone_containers.values():
		z.visible = false

	var prev_idx: int = ZONE_ORDER.find(_current_zone)
	var next_idx: int = ZONE_ORDER.find(zone)
	var walk_dir: String = "left" if (prev_idx > next_idx and prev_idx >= 0 and next_idx >= 0) else "right"

	# Show target zone
	_zone_containers[zone].visible = true
	_current_zone = zone
	_last_zone_switch_ms = Time.get_ticks_msec()
	GameState.world_zone = zone
	GameState.unlock_zone(zone)
	AudioManager.play_bgm(zone)

	# Move player to requested entry point (east/west gate) or default zone spawn
	if custom_local_pos.x >= 0.0 and custom_local_pos.y >= 0.0:
		player.global_position = _zone_containers[zone].global_position + custom_local_pos
	elif zone in _spawn_positions:
		player.global_position = _zone_containers[zone].global_position + _spawn_positions[zone]

	# Update kamera & label lokasi
	var zone_offset: int = ZONE_ORDER.find(zone)
	if zone_offset >= 0:
		GameState.current_level = zone_offset + 1
	camera.limit_left = zone_offset * ZONE_WIDTH * TILE
	camera.limit_right = (zone_offset + 1) * ZONE_WIDTH * TILE
	if camera.has_method("reset_smoothing"):
		camera.reset_smoothing()
	if hud and hud.has_method("set_location"):
		hud.set_location(ZONE_LABELS.get(zone, zone.capitalize()))

	# Toast + kearifan lokal zona. Kearifan muncul setelah toast agar tidak
	# bertumpuk dengan panel bawah.
	toast("Memasuki: %s" % ZONE_LABELS.get(zone, zone.capitalize()), true)
	if _show_zone_wisdom:
		_show_zone_wisdom_delayed(zone)

	if zone == "kota":
		var step_k: String = str(GameState.choices.get("hulu_story_step", ""))
		if step_k == "ke_kota_medan":
			GameState.record_choice("hulu_story_step", "kota_gang_sempit")
	elif zone == "hilir":
		var step_h: String = str(GameState.choices.get("hulu_story_step", ""))
		if step_h in ["ke_hilir_muara", "tanya_budi"]:
			GameState.record_choice("hulu_story_step", "pos_penjaga_muara")

	if _show_zone_wisdom:
		call_deferred("play_zone_loading_transition", zone, walk_dir)

	_sync_hulu_story_state()
	_refresh_mission()
	_refresh_gates()
	_update_guidance()
	if save_state:
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
		# Jika sampah sedang dibersihkan sementara (belum dibuat ulang), jangan gembok misi karena ketiadaan sampah di map
		if key == "sorted" and get_tree().get_nodes_in_group("world_trash").is_empty():
			continue
		if GameState.zone_stat(zone, key) < int(targets[key]):
			return false
	return true

func can_finish_journey() -> bool:
	return is_zone_cleared("hilir") and GameState.river_health >= 80.0

func can_gate_open(source_zone: String, target_zone: String) -> bool:
	var step: String = str(GameState.choices.get("hulu_story_step", ""))

	# Gerbang Hulu -> Desa (Timur Hulu)
	if source_zone == "hulu" and target_zone == "desa":
		var allowed := [
			"ke_toko_jaya", "pantun_kasur_darwis", "pulang_istirahat", "pesan_gorengan", "ke_warung_rina",
			"pantun_jelantah_rina", "cari_solusi_jelantah", "serahkan_jeriken_rina", "antar_gorengan",
			"ke_kota_medan", "kota_gang_sempit", "pantun_gang_jali", "cari_solusi_rt", "serahkan_gerobak_jali",
			"periksa_saluran_kota", "pintu_air_dan_b3", "tanya_budi", "ke_hilir_muara",
			"pos_penjaga_muara", "pilah_sampah_muara", "temui_pak_nelayan", "tanam_mangrove_muara",
			"selesai_mangrove", "papan_pantun_muara"
		]
		return step in allowed

	# Gerbang Desa -> Kota (Timur Desa)
	if source_zone == "desa" and target_zone == "kota":
		var allowed := [
			"ke_kota_medan", "kota_gang_sempit", "pantun_gang_jali", "cari_solusi_rt", "serahkan_gerobak_jali",
			"periksa_saluran_kota", "pintu_air_dan_b3", "tanya_budi", "ke_hilir_muara",
			"pos_penjaga_muara", "pilah_sampah_muara", "temui_pak_nelayan", "tanam_mangrove_muara",
			"selesai_mangrove", "papan_pantun_muara"
		]
		return step in allowed

	# Gerbang Kota -> Hilir (Timur Kota)
	if source_zone == "kota" and target_zone == "hilir":
		var allowed := [
			"ke_hilir_muara", "pos_penjaga_muara", "pilah_sampah_muara", "temui_pak_nelayan",
			"tanam_mangrove_muara", "selesai_mangrove", "papan_pantun_muara"
		]
		return step in allowed

	# Gerbang Hilir -> Epilog
	if source_zone == "hilir" and target_zone == "epilog":
		return can_finish_journey()

	# Gerbang ke arah barat / kembali (backtracking) selalu terbuka bebas
	return true

func get_gate_closed_hint(source_zone: String, target_zone: String) -> String:
	if source_zone == "hulu" and target_zone == "desa":
		return "Selesaikan dulu urusan di Hulu."
	if source_zone == "desa" and target_zone == "kota":
		return "Selesaikan dulu urusan di Desa Suka Maju."
	if source_zone == "kota" and target_zone == "hilir":
		return "Selesaikan dulu urusan di Kota Medan."
	if source_zone == "hilir" and target_zone == "epilog":
		return "Selesaikan dulu misi di Muara Hilir."
	return "Gerbang belum terbuka."

func _refresh_mission() -> void:
	if hud == null:
		return
	if GameState.quest_progress == 0:
		GameState.quest_progress = 1

	var zone: String = _current_zone
	var lines: Array[String] = []
	var title: String = ""

	match zone:
		"hulu":
			var step: String = str(GameState.choices.get("hulu_story_step", ""))
			var trees: int = mini(GameState.zone_stat("hulu", "trees"), 15)
			var sorted: int = mini(GameState.zone_stat("hulu", "sorted"), 15)
			var trash_line: String = "- Bersihkan seluruh sampah bantaran: %d/15" % sorted if sorted < 15 else "- Sampah bantaran hulu bersih (15/15)"

			if step.is_empty() or step == "butuh_pesan_kasur":
				title = "WARUNG HULU"
				lines = ["- Bicara dengan Mak dan Bapak di warung."]
			elif step == "menuju_toko_jaya":
				title = "MENUJU DESA"
				lines = ["- Pergi ke Toko Jaya di seberang jembatan."]
			elif step == "cari_suara_jembatan":
				title = "JEMBATAN SUNGAI"
				lines = ["- Periksa suara misterius di sekitar jembatan."]
			elif step == "bersihkan_sungai":
				title = "PINGGIRAN SUNGAI"
				if sorted < 5:
					lines = [
						"- Kumpulkan & buang 5 sampah ke tong: %d/5" % sorted,
						trash_line
					]
				else:
					lines = [
						"- Bicara lagi dengan Datuk Sampan di jembatan.",
						trash_line
					]
			elif step == "tanam_pohon_hulu":
				title = "BUKIT HULU"
				lines = [
					"- Temui Penjaga Hutan di perbukitan hulu.",
					trash_line
				]
			elif step == "menanam_pohon_hulu":
				title = "REBOISASI HULU"
				var tree_line: String = "- Tanam bibit di petak reboisasi: %d/15" % trees if trees < 15 else "- Reboisasi lengkap (15/15)! Temui Penjaga Hutan."
				lines = [
					tree_line,
					trash_line
				]
			elif step == "ke_toko_jaya":
				title = "MENUJU DESA"
				lines = [
					"- Lanjutkan ke Toko Jaya di Desa Suka Maju.",
					trash_line
				]
			elif step == "pulang_istirahat":
				title = "PULANG KE RUMAH"
				lines = [
					"- Kembali ke warung hulu untuk beristirahat.",
					trash_line
				]
			elif step == "pesan_gorengan":
				title = "WARUNG HULU"
				lines = [
					"- Bicara dengan Mak di warung.",
					trash_line
				]
			elif step in ["ke_warung_rina", "cari_solusi_jelantah", "serahkan_jeriken_rina"]:
				title = "DESA SUKA MAJU"
				lines = [
					"- Lanjutkan urusan di Desa Suka Maju.",
					trash_line
				]
			elif step == "antar_gorengan":
				title = "ANTAR GORENGAN"
				lines = [
					"- Antar gorengan dari Mak ke warga desa.",
					trash_line
				]
			elif step in ["ke_kota_medan", "kota_gang_sempit", "cari_solusi_rt", "serahkan_gerobak_jali", "periksa_saluran_kota", "pintu_air_dan_b3", "tanya_budi"]:
				title = "MENUJU KOTA"
				lines = [
					"- Lanjutkan ke Kota Medan melalui gerbang timur.",
					trash_line
				]
			else:
				title = "HULU PULIH"
				lines = [
					"- Lanjutkan perjalanan melalui jembatan ke Desa.",
					trash_line
				]

		"desa":
			var step_desa: String = str(GameState.choices.get("hulu_story_step", ""))
			var sorted_desa: int = mini(GameState.zone_stat("desa", "sorted"), 16)
			var trash_line_desa: String = "- Pilah sampah di Desa Suka Maju: %d/16" % sorted_desa if sorted_desa < 16 else "- Sampah Desa Suka Maju bersih (16/16)"

			if step_desa in ["pulang_istirahat", "pesan_gorengan", "antar_gorengan"]:
				title = "WARUNG HULU"
				lines = [
					"- Kembali ke warung Mak di Hulu.",
					trash_line_desa
				]
			elif step_desa == "ke_toko_jaya":
				if bool(GameState.choices.get("unlock_solusi_darwis", false)):
					title = "KASUR PAK DARWIS"
					lines = [
						"- Bicara kembali dengan Pak Darwis di Toko Jaya.",
						trash_line_desa
					]
				else:
					title = "TOKO JAYA"
					lines = [
						"- Bicara dengan orang di depan Toko Jaya.",
						trash_line_desa
					]
			elif step_desa == "pantun_kasur_darwis":
				title = "PAPAN PANTUN"
				lines = [
					"- Cari petunjuk solusi di Papan Pantun Toko Jaya.",
					trash_line_desa
				]
			elif step_desa == "ke_warung_rina":
				title = "WARUNG GORENGAN"
				lines = [
					"- Temui Kak Rina di Desa Suka Maju.",
					trash_line_desa
				]
			elif step_desa == "pantun_jelantah_rina":
				title = "PAPAN PANTUN"
				lines = [
					"- Cari petunjuk solusi di Papan Pantun Desa.",
					trash_line_desa
				]
			elif step_desa == "cari_solusi_jelantah":
				title = "PEMUKA DESA"
				lines = [
					"- Temui Pemuka Desa di balai desa.",
					trash_line_desa
				]
			elif step_desa == "serahkan_jeriken_rina":
				title = "WARUNG GORENGAN"
				lines = [
					"- Kembalikan jeriken jelantah ke Kak Rina.",
					trash_line_desa
				]
			elif step_desa in ["ke_kota_medan", "kota_gang_sempit", "pantun_gang_jali", "cari_solusi_rt", "serahkan_gerobak_jali", "periksa_saluran_kota", "pintu_air_dan_b3", "tanya_budi"]:
				title = "MENUJU KOTA"
				lines = [
					"- Pergi ke Kota Medan melalui gerbang timur.",
					trash_line_desa
				]
			elif step_desa.is_empty() or step_desa in ["butuh_pesan_kasur", "menuju_toko_jaya", "cari_suara_jembatan", "bersihkan_sungai", "tanam_pohon_hulu", "menanam_pohon_hulu"]:
				title = "HULU SUNGAI DELI"
				lines = [
					"- Kembali ke Hulu melalui jembatan barat.",
					trash_line_desa
				]
			else:
				title = "DESA SUKA MAJU"
				lines = [
					"- Jelajahi Desa Suka Maju.",
					trash_line_desa
				]

		"kota":
			var step_kota: String = str(GameState.choices.get("hulu_story_step", ""))
			var sorted_kota: int = mini(GameState.zone_stat("kota", "sorted"), 20)
			var trash_line_kota: String = "- Pilah sampah di Kota Medan: %d/20" % sorted_kota if sorted_kota < 20 else "- Sampah Kota Medan bersih (20/20)"

			if step_kota in ["ke_toko_jaya", "pantun_kasur_darwis", "pulang_istirahat", "pesan_gorengan", "ke_warung_rina", "pantun_jelantah_rina", "cari_solusi_jelantah", "serahkan_jeriken_rina", "antar_gorengan"]:
				title = "DESA SUKA MAJU"
				lines = [
					"- Kembali ke Desa Suka Maju melalui gerbang barat.",
					trash_line_kota
				]
			elif step_kota in ["ke_kota_medan", "kota_gang_sempit"]:
				title = "GANG SEMPIT"
				lines = [
					"- Periksa warga di mulut gang sempit.",
					trash_line_kota
				]
			elif step_kota == "pantun_gang_jali":
				title = "PAPAN PANTUN"
				lines = [
					"- Cari petunjuk solusi di Papan Pantun zebra cross.",
					trash_line_kota
				]
			elif step_kota == "cari_solusi_rt":
				title = "TEMUI PAK RT"
				lines = [
					"- Temui Pak RT di balai kota Medan.",
					trash_line_kota
				]
			elif step_kota == "serahkan_gerobak_jali":
				title = "GANG SEMPIT"
				lines = [
					"- Bicara kembali dengan Bang Jali di mulut gang.",
					trash_line_kota
				]
			elif step_kota == "periksa_saluran_kota":
				title = "SALURAN KOTA"
				lines = [
					"- Periksa warga di dekat saluran air.",
					trash_line_kota
				]
			elif step_kota == "pintu_air_dan_b3":
				if not bool(GameState.choices.get("sandi_tuas_terbuka", false)):
					title = "PAPAN PANTUN"
					lines = [
						"- Cari sandi urutan tuas di Papan Pantun kanal.",
						trash_line_kota
					]
				else:
					title = "PINTU AIR"
					lines = [
						"- Buka 3 tuas kanal (urutan 1-3-2): %d/3" % _lever_pressed.size(),
						trash_line_kota
					]
			elif step_kota == "tanya_budi":
				title = "ANAK SEKOLAH"
				lines = [
					"- Bicara dengan Budi di trotoar kota.",
					trash_line_kota
				]
			elif step_kota in ["ke_hilir_muara", "pos_penjaga_muara", "pilah_sampah_muara", "papan_pantun_muara", "temui_pak_nelayan", "tanam_mangrove_muara", "selesai_mangrove"]:
				title = "MENUJU HILIR"
				lines = [
					"- Lanjutkan ke Muara Hilir melalui gerbang timur.",
					trash_line_kota
				]
			else:
				title = "KOTA MEDAN"
				lines = [
					"- Jelajahi Kota Medan.",
					trash_line_kota
				]

		"hilir":
			var step_hilir: String = str(GameState.choices.get("hulu_story_step", ""))
			var mangroves: int = mini(GameState.zone_stat("hilir", "mangroves"), 12)
			var sorted_hilir: int = mini(GameState.zone_stat("hilir", "sorted"), 16)
			var trash_line_hilir: String = "- Bersihkan sampah pesisir: %d/16" % sorted_hilir if sorted_hilir < 16 else "- Sampah pesisir muara bersih (16/16)"

			if step_hilir in ["ke_toko_jaya", "pulang_istirahat", "pesan_gorengan", "ke_warung_rina", "cari_solusi_jelantah", "serahkan_jeriken_rina", "antar_gorengan", "ke_kota_medan", "kota_gang_sempit", "cari_solusi_rt", "serahkan_gerobak_jali", "periksa_saluran_kota", "pintu_air_dan_b3", "tanya_budi"]:
				title = "KOTA MEDAN"
				lines = [
					"- Kembali ke Kota Medan melalui gerbang barat.",
					trash_line_hilir
				]
			elif step_hilir in ["ke_hilir_muara", "pos_penjaga_muara"]:
				title = "POS PENJAGA"
				lines = [
					"- Bicara dengan Penjaga Sungai di pos muara.",
					trash_line_hilir
				]
			elif step_hilir == "pilah_sampah_muara":
				title = "PILAH PESISIR"
				lines = [
					"- Pilah sampah pesisir muara ke tong sampah.",
					trash_line_hilir
				]
			elif step_hilir == "temui_pak_nelayan":
				title = "PAK NELAYAN"
				lines = [
					"- Temui Pak Nelayan di pesisir pantai.",
					trash_line_hilir
				]
			elif step_hilir == "tanam_mangrove_muara":
				title = "REBOISASI PESISIR"
				var mangrove_line: String = "- Tanam bibit bakau di pesisir: %d/12" % mangroves if mangroves < 12 else "- Bakau lengkap (12/12)! Temui Pak Nelayan."
				lines = [
					mangrove_line,
					trash_line_hilir
				]
			elif step_hilir == "selesai_mangrove":
				title = "PAK NELAYAN"
				lines = [
					"- Bicara kembali dengan Pak Nelayan di pesisir.",
					trash_line_hilir
				]
			elif step_hilir == "papan_pantun_muara":
				title = "PANTUN DELI"
				lines = [
					"- Bicara dengan Datuk Sampan di muara.",
					trash_line_hilir
				]
			else:
				title = "MUARA BELAWAN"
				lines = [
					"- Dengarkan petuah terakhir Datuk Sampan.",
					trash_line_hilir
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
	var carry_cnt: int = GameState.get_pending_trash_count() if GameState.has_method("get_pending_trash_count") else GameState.get_meta("pending_trash", []).size()
	if carry_cnt > 0:
		toast("Sampah %s dipungut (%d/5 di kantong)." % [category, carry_cnt], true)
	else:
		toast("Sampah %s dipungut." % category, true)

	if _current_zone == "hulu" and GameState.choices.get("hulu_story_step") == "bersihkan_sungai":
		var cleaned: int = _get_hulu_riverbank_trash_cleaned_count()
		var sorted: int = GameState.zone_stat("hulu", "sorted")
		if carry_cnt == 0 and (cleaned >= 5 or sorted >= 5):
			call_deferred("_trigger_selesai_sungai")

	_refresh_mission()
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
			"hulu": GameState.unlock_card("card_kearifan_01")
			"desa": GameState.unlock_card("card_pertanian_01")
			"kota": GameState.unlock_card("card_plastik_01")
			"hilir": GameState.unlock_card("card_pesisir_01")
	toast("Sampah %s terpilah. Sungai membaik." % category, true)

	# 5 sampah pertama di Hulu mengurangi total 15% (-3% per sampah); sampah sisanya perlahan (-0.2% / -0.15%)
	var delta_meter: float = 0.0
	if zone == "hulu" and count <= 5:
		delta_meter = 3.0
	else:
		delta_meter = 0.2 if zone in ["hulu", "desa"] else 0.15
	GameState.meter_bencana = maxf(5.0, GameState.meter_bencana - delta_meter)

	if zone == "hulu" and GameState.choices.get("hulu_story_step") == "bersihkan_sungai":
		var sorted: int = GameState.zone_stat("hulu", "sorted")
		if sorted >= 5:
			call_deferred("_trigger_selesai_sungai")
	elif zone == "hilir" and GameState.choices.get("hulu_story_step") == "pilah_sampah_muara":
		if count >= zone_target("hilir", "sorted"):
			GameState.record_choice("hulu_story_step", "papan_pantun_muara")
			toast("Semua sampah pesisir bersih! Periksa Papan Pantun di muara.", true)

	_refresh_mission()
	_refresh_gates()
	GameState.save_game()

func on_tree_planted(kind: String) -> void:
	var label: String = "Bibit mangrove" if kind == "mangrove" else "Bibit pohon"
	if kind == "mangrove" and _current_zone == "hilir":
		GameState.add_zone_stat("hilir", "mangroves")
		var count: int = GameState.zone_stat("hilir", "mangroves")
		if count >= 12:
			GameState.unlock_card("card_mangrove_01")
			GameState.meter_bencana = maxf(5.0, GameState.meter_bencana - 20.0)
			toast("12 Mangrove lengkap! Pesisir terlindungi (Bencana -20%).", true)
			GameState.record_choice("hulu_story_step", "selesai_mangrove")
			_sync_hulu_story_state()
		else:
			toast("Bibit mangrove ditanam! (%d/12)" % count, true)
	elif kind == "tree" and _current_zone == "hulu":
		GameState.add_zone_stat("hulu", "trees")
		var count: int = GameState.zone_stat("hulu", "trees")
		if count >= 15:
			GameState.unlock_card("card_hutan_01")
			GameState.unlock_card("card_sungai_deli_01")
			GameState.meter_bencana = maxf(5.0, GameState.meter_bencana - 20.0)
			toast("Semua 15 pohon tertanam! Hutan pulih (Bencana -20%).", true)
			_sync_hulu_story_state()
		else:
			toast("Bibit pohon ditanam! (%d/15)" % count, true)
	else:
		toast("%s ditanam. Sungai membaik." % label, true)
	_refresh_mission()
	_refresh_gates()
	GameState.save_game()

func lever_pressed(lever_id: int) -> void:
	if bool(GameState.choices.get("pintu_air_terbuka", false)):
		toast("Pintu air sudah terbuka dan mengalir lancar!", true)
		return
	if not bool(GameState.choices.get("sandi_tuas_terbuka", false)):
		_reset_kota_levers()
		SettingsManager.vibrate(100)
		toast("Bahaya! Urutan tuas belum diketahui. Cek Papan Pantun di dekat zebra cross!", false)
		return
	_lever_pressed.append(lever_id)
	for i in range(_lever_pressed.size()):
		if _lever_pressed[i] != _lever_sequence[i]:
			_lever_pressed.clear()
			GameState.add_river_health(-2.0)
			_reset_kota_levers()
			SettingsManager.vibrate(140)
			toast("Urutan tuas salah! Air meluap sedikit. Mulai lagi dari tuas 1.", false)
			_refresh_mission()
			_update_guidance()
			return
	if _lever_pressed.size() == _lever_sequence.size():
		GameState.record_choice("pintu_air_terbuka", true)
		GameState.meter_bencana = maxf(5.0, GameState.meter_bencana - 5.0)
		GameState.unlock_card("card_drainase_01")
		AudioManager.play_sfx("correct")
		SettingsManager.vibrate(120)
		toast("Drainase pintu air terbuka! Aliran lancar.", true)
		GameState.record_choice("hulu_story_step", "tanya_budi")
		_sync_hulu_story_state()
		_refresh_mission()
		_update_guidance()
		GameState.save_game()
	else:
		SettingsManager.vibrate(55)
		toast("Tuas %d aktif. Lanjutkan urutan berikutnya!" % lever_id, true)
		_refresh_mission()
		_update_guidance()

func _reset_kota_levers() -> void:
	for lever in get_tree().get_nodes_in_group("pilot_lever"):
		if lever.has_method("reset_lever"):
			lever.reset_lever()

func on_npc_talked(npc_key: String) -> void:
	var npc_to_zone := {
		"npc_ibu_mc": "hulu",
		"npc_pak_hendra": "hulu",
		"npc_datuk": "hulu",
		"npc_penjaga_hutan": "hulu",
		"npc_petani_1": "desa",
		"npc_darwis": "desa",
		"npc_pemilik_toko": "desa",
		"npc_ibu_desa": "desa",
		"npc_rina": "desa",
		"npc_pemuka_desa": "desa",
		"npc_pedagang": "kota",
		"npc_jali": "kota",
		"npc_tokoh_masyarakat": "kota",
		"npc_pak_rt": "kota",
		"npc_ibu_rumah": "kota",
		"npc_anak_sekolah": "kota",
		"npc_budi": "kota",
		"npc_penjaga_sungai": "hilir",
		"npc_nelayan": "hilir",
	}
	var zone: String = npc_to_zone.get(npc_key, _current_zone)
	# Pak Hendra dan Bu Mira memakai dialog warung hulu yang sama.
	var effective_key: String = "npc_ibu_mc" if (zone == "hulu" and npc_key == "npc_pak_hendra") else npc_key
	GameState.mark_character_talked(npc_key)
	if effective_key == "npc_ibu_mc":
		GameState.mark_character_talked("ibu_mc")
		GameState.mark_character_talked("bapak")
	var is_new: bool = GameState.mark_zone_talked(zone, effective_key)
	if effective_key == "npc_ibu_mc":
		for npc in get_tree().get_nodes_in_group("world_npc"):
			var k: String = str(npc.get("npc_key"))
			if (k == "npc_ibu_mc" or k == "npc_pak_hendra") and npc.has_method("show_exclaim"):
				npc.show_exclaim(false)
	if not is_new:
		return

	match effective_key:
		"npc_ibu_mc":
			var step_ibu: String = str(GameState.choices.get("hulu_story_step", ""))
			if step_ibu.is_empty() and not _is_cutscene_active:
				call_deferred("play_two_days_later_cutscene")
		"npc_datuk":
			GameState.unlock_card("card_kearifan_02")
		"npc_penjaga_hutan":
			if not GameState.has_quest("tanam_pohon_hulu"):
				GameState.start_quest("tanam_pohon_hulu", 15)
				QuestManager.trigger_npc_quest("tanam_pohon_hulu", "Tanam 15 pohon di Hulu", 15)
			GameState.unlock_card("card_hutan_01")
		"npc_pemuka_desa":
			GameState.unlock_card("card_adat_01")
		"npc_petani_1", "npc_ibu_desa":
			if not GameState.has_quest("pilah_desa"):
				GameState.start_quest("pilah_desa", 10)
				QuestManager.trigger_npc_quest("pilah_desa", "Pilah 10 sampah desa", 10)
			if effective_key == "npc_petani_1":
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
				GameState.start_quest("tanam_mangrove", 12)
				QuestManager.trigger_npc_quest("tanam_mangrove", "Tanam 12 mangrove di pesisir", 12)
			GameState.unlock_card("card_nelayan_01")
		"npc_penjaga_sungai":
			if not GameState.has_quest("pilah_hilir"):
				GameState.start_quest("pilah_hilir", 16)
				QuestManager.trigger_npc_quest("pilah_hilir", "Bersihkan 16 sampah pesisir muara", 16)
			GameState.unlock_card("card_pesisir_01")

	var target: int = zone_target(zone, "talked")
	var count: int = GameState.zone_talked_count(zone)
	if target > 0 and count == target:
		toast("Semua warga zona ini sudah bicara.", true)

	_sync_hulu_story_state()
	_refresh_mission()
	_refresh_gates()
	_update_guidance()
	GameState.save_game()

# ─── Pantun Melayu Deli ──────────────────────────────────────────────────────

func _is_pantun_solved(board_dialog_id: String) -> bool:
	match board_dialog_id:
		"h1_pantun_darwis":
			return bool(GameState.choices.get("unlock_solusi_darwis", false)) or bool(GameState.choices.get("darwis_done", false))
		"h2_pantun_rina":
			return bool(GameState.choices.get("unlock_solusi_rina", false)) or bool(GameState.choices.get("rina_done", false))
		"h3_pantun_jali":
			return bool(GameState.choices.get("unlock_solusi_jali", false)) or bool(GameState.choices.get("jali_done", false))
		"h3_pantun_kota":
			return bool(GameState.choices.get("sandi_tuas_terbuka", false)) or bool(GameState.choices.get("pintu_air_terbuka", false))
		"h7_pantun":
			return bool(GameState.choices.get("pantun_muara_selesai", false)) or GameState.pantun_completed or bool(GameState.choices.get("nelayan_selesai", false))
		_:
			return false

func _complete_pantun_step(board_id: String, from_quiz: bool) -> void:
	var step := str(GameState.choices.get("hulu_story_step", ""))
	var changed: bool = false
	match board_id:
		"h1_pantun_darwis":
			GameState.record_choice("unlock_solusi_darwis", true)
			if not bool(GameState.choices.get("darwis_done", false)) and step in ["", "ke_toko_jaya", "pantun_kasur_darwis"]:
				if step == "pantun_kasur_darwis" or from_quiz:
					GameState.record_choice("hulu_story_step", "ke_toko_jaya")
					changed = true
			if from_quiz or changed:
				toast("Inspirasi didapat! Bicara kembali dengan Pak Darwis di Toko Jaya.", true)
		"h2_pantun_rina":
			GameState.record_choice("unlock_solusi_rina", true)
			if not bool(GameState.choices.get("rina_done", false)) and step in ["ke_warung_rina", "pantun_jelantah_rina"]:
				if step == "pantun_jelantah_rina" or from_quiz:
					GameState.record_choice("hulu_story_step", "cari_solusi_jelantah")
					changed = true
			if from_quiz or changed:
				toast("Inspirasi didapat! Temui Pemuka Desa untuk meminta jeriken.", true)
		"h3_pantun_jali":
			GameState.record_choice("unlock_solusi_jali", true)
			if not bool(GameState.choices.get("jali_done", false)) and step in ["ke_kota_medan", "kota_gang_sempit", "pantun_gang_jali"]:
				if step == "pantun_gang_jali" or from_quiz:
					GameState.record_choice("hulu_story_step", "cari_solusi_rt")
					changed = true
			if from_quiz or changed:
				toast("Inspirasi didapat! Temui Pak RT untuk fasilitas gerobak roda.", true)
		"h3_pantun_kota":
			GameState.record_choice("sandi_tuas_terbuka", true)
			changed = true
			if from_quiz:
				toast("Sandi terpecahkan: Urutan Tuas 1 -> Tuas 3 -> Tuas 2!", true)
		"h7_pantun":
			GameState.record_choice("pantun_muara_selesai", true)
			var hilir_trash_done: bool = GameState.zone_stat("hilir", "sorted") >= zone_target("hilir", "sorted")
			if hilir_trash_done and (step in ["papan_pantun_muara", "pilah_sampah_muara"] or from_quiz):
				GameState.record_choice("hulu_story_step", "temui_pak_nelayan")
				changed = true
				toast("Pantun selesai dipulihkan! Temui Pak Nelayan di pesisir.", true)
			elif not hilir_trash_done:
				toast("Pantun selesai! Sekarang tuntaskan membersihkan sampah pesisir muara.", true)
	if from_quiz or changed:
		_sync_hulu_story_state()
		_refresh_mission()
		_update_guidance()
		GameState.save_game()

func _show_solved_pantun(board_dialog_id: String) -> void:
	_last_solved_pantun_id = board_dialog_id
	var text: String = ""
	match board_dialog_id:
		"h1_pantun_darwis":
			text = "Pohon rumbia tumbuh di hulu,\nDitebang orang diambil sagu.\nKasur yang berat cincanglah dulu,\nDijual kiloan tak bikin ragu.\n\n(Solusi: Busa kasur dipotong kecil lalu dijual kiloan ke pengepul)"
		"h2_pantun_rina":
			text = "Pergi ke pasar membeli santan,\nSinggah sebentar membawa nampan.\nMinyak jelantah jangan di selokan,\nDi Bank Sampah jeriken disiapkan.\n\n(Solusi: Minyak jelantah ditampung di jeriken untuk Bank Sampah)"
		"h3_pantun_jali":
			text = "Pasang pelita di malam gulita,\nCahaya terang sampai ke pekan.\nJika gang sempit truk tak muat kita,\nGerobak beroda mari gilirkan.\n\n(Solusi: Sediakan gerobak roda komunal bergilir untuk gang sempit)"
		"h3_pantun_kota":
			text = "Pergi berlayar ke Pulau Satu,\nSinggah berlabuh di Tanjung Tiga.\nBuka pintu air jangan keliru,\nTarikan ke-Dua penutupnya juga.\n\n(Sandi Pintu Air: Urutan tuas 1 -> tuas 3 -> tuas 2)"
		"h7_pantun":
			text = "Anak Melayu menjala ikan,\nSinggah berteduh di pohon jati.\nSungai Deli pusaka kehidupan,\nMari dijaga sepenuh hati.\n\n(Petuah Datuk: Menjaga kelestarian Sungai Deli bersama-sama)"
		_:
			text = "Pohon rumbia tumbuh di hulu,\nAirnya jernih mengalir tenang.\nJaga sungai seperti dahulu,\nAnak cucu hidupnya senang.\n\n(Kearifan Deli: Sungai bersih, kehidupan lestari)"

	DialogueManager.start_dialogue([
		{
			"id": "start",
			"speaker": "Papan Pantun",
			"emosi": "happy",
			"teks": text,
			"next": "end"
		}
	], "papan_pantun", "pantun_selesai")

func open_pantun_board(board_dialog_id: String = "") -> void:
	if board_dialog_id == "h7_pantun":
		if not bool(GameState.choices.get("penjaga_sungai_done", false)):
			toast("Bicara dulu dengan Penjaga Sungai di dekat pangkal jembatan muara!", false)
			return
		var sorted_hilir: int = GameState.zone_stat("hilir", "sorted")
		var target_hilir: int = zone_target("hilir", "sorted")
		if sorted_hilir < target_hilir:
			toast("Bersihkan dulu sampah pesisir muara (%d/%d) sebelum membuka Papan Pantun Tua!" % [sorted_hilir, target_hilir], false)
			return
	if not board_dialog_id.is_empty():
		if _is_pantun_solved(board_dialog_id):
			_show_solved_pantun(board_dialog_id)
			return
		DialogueManager.mulai(board_dialog_id)
		return
	if _current_zone == "hulu":
		_show_solved_pantun("")
		return
	open_pantun()

func open_pantun() -> void:
	var step := str(GameState.choices.get("hulu_story_step", ""))
	if _current_zone == "desa":
		if (step in ["ke_toko_jaya", "pantun_kasur_darwis"]) and not bool(GameState.choices.get("unlock_solusi_darwis", false)):
			DialogueManager.mulai("h1_pantun_darwis")
			return
		elif (step in ["ke_warung_rina", "pantun_jelantah_rina"]) and not bool(GameState.choices.get("unlock_solusi_rina", false)):
			DialogueManager.mulai("h2_pantun_rina")
			return
		else:
			if _is_pantun_solved("h1_pantun_darwis"):
				_show_solved_pantun("h1_pantun_darwis")
			else:
				_show_solved_pantun("h2_pantun_rina")
			return
	elif _current_zone == "kota":
		if (step in ["ke_kota_medan", "kota_gang_sempit", "pantun_gang_jali"]) and not bool(GameState.choices.get("unlock_solusi_jali", false)):
			DialogueManager.mulai("h3_pantun_jali")
			return
		elif step == "pintu_air_dan_b3":
			if bool(GameState.choices.get("sandi_tuas_terbuka", false)):
				_show_solved_pantun("h3_pantun_kota")
				return
			DialogueManager.mulai("h3_pantun_kota")
			return
		else:
			if _is_pantun_solved("h3_pantun_kota"):
				_show_solved_pantun("h3_pantun_kota")
			else:
				_show_solved_pantun("h3_pantun_jali")
			return
	elif _current_zone == "hilir":
		if step == "papan_pantun_muara":
			if _is_pantun_solved("h7_pantun"):
				_show_solved_pantun("h7_pantun")
			else:
				DialogueManager.mulai("h7_pantun")
			return

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
	GameState.unlock_card("card_pantun_01")
	AudioManager.play_sfx("level_done")
	toast("Pantun Melayu Deli lengkap!", true)
	_refresh_mission()
	GameState.save_game()

# ─── Selesai perjalanan ──────────────────────────────────────────────────────

func finish_journey() -> void:
	if not can_finish_journey():
		toast("Selesaikan dulu misi pesisir: 12 mangrove, 10 sampah, 2 warga.", false)
		return
	if GameState.world_completed:
		return
	for level in [1, 2, 3, 4]:
		if level not in GameState.levels_completed:
			GameState.levels_completed.append(level)
	GameState.world_completed = true
	GameState.in_world = false
	GameState.current_level = 5
	var kode: String = GameState.hitung_kode_ending()
	GameState.ending_terakhir = kode
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
	hud.set_objective(direction, distance_tiles)

func _target_label(target: Node2D) -> String:
	if target == _bridge_talk_spot:
		return "Jembatan"
	if target is NPC:
		var key := str(target.get("npc_key"))
		match key:
			"npc_ibu_mc": return "Mamak"
			"npc_pak_hendra": return "Bapak"
			"npc_petani_1": return "Pak Darwis"
			"npc_pemilik_toko": return "Toko Jaya"
			"npc_ibu_desa": return "Kak Rina"
			"npc_pemuka_desa": return "Pemuka Desa"
			"npc_pedagang": return "Bang Jali"
			"npc_tokoh_masyarakat": return "Pak RT"
			"npc_ibu_rumah": return "Ibu Rumah"
			"npc_anak_sekolah": return "Budi"
			"npc_penjaga_hutan": return "Penjaga Hutan"
			"npc_penjaga_sungai": return "Penjaga Sungai"
			"npc_nelayan": return "Pak Nelayan"
			"npc_datuk": return "Datuk Sampan"
			_: return "Warga"
	if target is PilotBin:
		return "Tong"
	if target is TrashItem:
		return "Sampah"
	if target is TreeSpotTopDown:
		return "Titik tanam"
	if target is ZoneGate:
		return "Gerbang"
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
			var step: String = str(GameState.choices.get("hulu_story_step", ""))
			if step == "bersihkan_sungai":
				return _nearest_trash_or_bin()
			if GameState.zone_stat("hulu", "trees") < 15:
				return _nearest_unplanted("tree")
			return _exit_target("desa")
		"desa":
			if GameState.zone_stat("desa", "sorted") < 10 or GameState.river_health < 60.0:
				return _nearest_trash_or_bin()
			return _exit_target("kota")
		"kota":
			if GameState.zone_talked_count("kota") < 4:
				return _nearest_untalked_npc()
			if GameState.zone_stat("kota", "sorted") < 6 or GameState.river_health < 80.0:
				return _nearest_trash_or_bin()
			return _exit_target("hilir")
		"hilir":
			var step_h: String = str(GameState.choices.get("hulu_story_step", ""))
			if step_h == "pilah_sampah_muara":
				return _nearest_trash_or_bin()
			if step_h == "tanam_mangrove_muara" and GameState.zone_stat("hilir", "mangroves") < 12:
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
	var step := str(GameState.choices.get("hulu_story_step", ""))
	match _current_zone:
		"hulu":
			if step.is_empty() or step == "butuh_pesan_kasur":
				return _npc_by_key("npc_ibu_mc")
			if step in ["menuju_toko_jaya", "cari_suara_jembatan"]:
				return _bridge_talk_spot
			if step == "bersihkan_sungai":
				return null
			if step == "tanam_pohon_hulu":
				return _npc_by_key("npc_penjaga_hutan")
			if step == "menanam_pohon_hulu":
				if GameState.zone_stat("hulu", "trees") >= 15:
					return _npc_by_key("npc_penjaga_hutan")
				return null
			if step == "ke_toko_jaya":
				return _gate_to("desa")
			if step in ["pulang_istirahat", "pesan_gorengan", "antar_gorengan"]:
				return _npc_by_key("npc_ibu_mc")
			if step in ["ke_warung_rina", "cari_solusi_jelantah", "serahkan_jeriken_rina", "ke_kota_medan"]:
				return _gate_to("desa")
		"desa":
			if step.is_empty() or step in ["butuh_pesan_kasur", "menuju_toko_jaya", "cari_suara_jembatan", "bersihkan_sungai", "tanam_pohon_hulu", "menanam_pohon_hulu", "pulang_istirahat", "pesan_gorengan", "antar_gorengan"]:
				return _gate_to("hulu")
			if step == "ke_toko_jaya":
				return _npc_by_key("npc_petani_1")
			if step == "pantun_kasur_darwis":
				return _pantun_board_by_id("h1_pantun_darwis", "desa")
			if step == "ke_warung_rina":
				return _npc_by_key("npc_ibu_desa")
			if step == "pantun_jelantah_rina":
				return _pantun_board_by_id("h2_pantun_rina", "desa")
			if step == "cari_solusi_jelantah":
				return _npc_by_key("npc_pemuka_desa")
			if step == "serahkan_jeriken_rina":
				return _npc_by_key("npc_ibu_desa")
			if step in ["ke_kota_medan", "kota_gang_sempit", "pantun_gang_jali", "cari_solusi_rt", "serahkan_gerobak_jali", "periksa_saluran_kota", "pintu_air_dan_b3", "tanya_budi", "ke_hilir_muara", "pos_penjaga_muara", "pilah_sampah_muara", "temui_pak_nelayan", "tanam_mangrove_muara", "selesai_mangrove", "papan_pantun_muara"]:
				return _gate_to("kota")
		"kota":
			if step in ["ke_toko_jaya", "pantun_kasur_darwis", "pulang_istirahat", "pesan_gorengan", "ke_warung_rina", "pantun_jelantah_rina", "cari_solusi_jelantah", "serahkan_jeriken_rina", "antar_gorengan"] or step.is_empty() or step in ["butuh_pesan_kasur", "menuju_toko_jaya", "cari_suara_jembatan", "bersihkan_sungai", "tanam_pohon_hulu", "menanam_pohon_hulu"]:
				return _gate_to("desa")
			if step in ["ke_kota_medan", "kota_gang_sempit"]:
				return _npc_by_key("npc_pedagang")
			if step == "pantun_gang_jali":
				return _pantun_board_by_id("h3_pantun_jali", "kota")
			if step == "cari_solusi_rt":
				return _npc_by_key("npc_tokoh_masyarakat")
			if step == "serahkan_gerobak_jali":
				return _npc_by_key("npc_pedagang")
			if step == "periksa_saluran_kota":
				return _npc_by_key("npc_ibu_rumah")
			if step == "pintu_air_dan_b3":
				if not bool(GameState.choices.get("sandi_tuas_terbuka", false)):
					return _pantun_board_by_id("h3_pantun_kota", "kota")
				var next_id: int = 1
				if _lever_pressed.size() == 1 and _lever_pressed[0] == 1:
					next_id = 3
				elif _lever_pressed.size() == 2 and _lever_pressed[0] == 1 and _lever_pressed[1] == 3:
					next_id = 2
				for lever in get_tree().get_nodes_in_group("pilot_lever"):
					if int(lever.get("lever_id")) == next_id and lever.is_inside_tree() and lever.is_visible_in_tree():
						return lever
				return _nearest_in_group("pilot_bin")
			if step == "tanya_budi":
				return _npc_by_key("npc_anak_sekolah")
			if step in ["ke_hilir_muara", "pos_penjaga_muara", "pilah_sampah_muara", "papan_pantun_muara", "temui_pak_nelayan", "tanam_mangrove_muara", "selesai_mangrove"]:
				return _gate_to("hilir")
		"hilir":
			if step in ["ke_toko_jaya", "pulang_istirahat", "pesan_gorengan", "ke_warung_rina", "cari_solusi_jelantah", "serahkan_jeriken_rina", "antar_gorengan", "ke_kota_medan", "kota_gang_sempit", "cari_solusi_rt", "serahkan_gerobak_jali", "periksa_saluran_kota", "pintu_air_dan_b3", "tanya_budi"] or step.is_empty():
				return _gate_to("kota")
			if step in ["ke_hilir_muara", "pos_penjaga_muara"]:
				return _npc_by_key("npc_penjaga_sungai")
			if step == "papan_pantun_muara":
				for b in get_tree().get_nodes_in_group("pantun_board"):
					if b is Node2D and b.is_visible_in_tree():
						return b
				return _npc_by_key("npc_datuk")
			if step in ["temui_pak_nelayan", "selesai_mangrove"]:
				return _npc_by_key("npc_nelayan")
			if step == "tanam_mangrove_muara":
				if GameState.zone_stat("hilir", "mangroves") >= 12:
					return _npc_by_key("npc_nelayan")
				return null
	return null

func _pantun_board_by_id(board_id: String, zone_name: String) -> Node2D:
	for b in get_tree().get_nodes_in_group("pantun_board"):
		if b is Node2D and b.is_visible_in_tree() and b.get_parent() == _zone_containers.get(zone_name):
			if str(b.get("pantun_id")) == board_id:
				return b
	for b in get_tree().get_nodes_in_group("pantun_board"):
		if b is Node2D and b.is_visible_in_tree() and b.get_parent() == _zone_containers.get(zone_name):
			return b
	return _nearest_in_group("pantun_board")

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
	var carry_cnt: int = GameState.get_pending_trash_count() if GameState.has_method("get_pending_trash_count") else GameState.get_meta("pending_trash", []).size()
	# Jika kantong penuh (5/5), kompas langsung mengarahkan ke tong sampah terdekat
	if carry_cnt >= 5:
		var bin := _nearest_in_group("world_bin")
		if bin != null:
			return bin
	# Jika kantong belum penuh, prioritaskan sampah terdekat di tanah
	var trash := _nearest_in_group("world_trash")
	if trash != null:
		return trash
	# Jika semua sampah di tanah sudah habis tapi masih ada di kantong, arahkan ke tong sampah
	if carry_cnt > 0:
		return _nearest_in_group("world_bin")
	return null

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
	_sync_hulu_story_state()
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
