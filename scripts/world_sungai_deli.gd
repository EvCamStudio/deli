## World Sungai Deli — satu map besar, 4 zona dengan gate dinamis.
## Zona: Warung & Hulu → Desa → Kota → Hilir
extends Node2D
class_name WorldSungaiDeli

const TILE: int = 16
const ZONE_WIDTH: int = 60  # tile per zona
const ZONE_HEIGHT: int = 34

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var hud: HUD = $HUD
@onready var touch_controls: CanvasLayer = $TouchControls
@onready var pause_menu: CanvasLayer = $PauseMenu

var _current_zone: String = "hulu"
var _dialogue_active: bool = false
var _zone_containers: Dictionary = {}
var _spawn_positions: Dictionary = {
	"hulu": Vector2(8, 10) * TILE,
	"desa": Vector2(8, 10) * TILE,
	"kota": Vector2(8, 10) * TILE,
	"hilir": Vector2(8, 10) * TILE,
}

func _ready() -> void:
	add_to_group("level")
	GameState.set_meta("pending_trash", [])
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	GameState.river_health_changed.connect(func(_value: float): _refresh_mission())
	GameState.rupiah_changed.connect(func(_value: int): _refresh_mission())

	_build_zones()
	_spawn_gates()
	_spawn_npcs()
	_spawn_gameplay_objects()
	_setup_camera()
	_setup_hud()

	if pause_menu:
		pause_menu.connect("opened", _on_pause_opened)
		pause_menu.connect("closed", _on_pause_closed)

	# Hidden mission sampai trigger dialog Ibu
	if GameState.quest_progress == 0:
		hud.hide_mission()
	else:
		_refresh_mission()

	change_zone("hulu")

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
	# Gate dari Hulu ke Desa (unlock river_health 40%)
	_create_gate("hulu", Vector2(59, 16) * TILE, "desa", 40.0, "Bersihkan mata air dan tanam pohon dulu.")
	
	# Gate dari Desa ke Kota (unlock river_health 60%)
	_create_gate("desa", Vector2(59, 16) * TILE, "kota", 60.0, "Ajak warga desa bergabung bersihkan sungai dulu.")
	
	# Gate dari Kota ke Hilir (unlock river_health 80%)
	_create_gate("kota", Vector2(59, 16) * TILE, "hilir", 80.0, "Kota belum cukup bersih. Kurangi sampah plastik.")

func _create_gate(zone: String, pos: Vector2, target: String, threshold: float, hint: String) -> void:
	var gate_scene := preload("res://scenes/world/gate_topdown.tscn")
	var gate := gate_scene.instantiate() as Area2D
	gate.position = pos
	gate.set_script(load("res://scripts/zone_gate.gd"))
	gate.set("target_zone", target)
	gate.set("river_health_threshold", threshold)
	gate.set("closed_hint", hint)
	_zone_containers[zone].add_child(gate)

func _spawn_npcs() -> void:
	# Hulu: Ibu di warung (trigger quest) + penjaga hutan
	_create_npc("hulu", "npc_ibu_desa", "ibu", Vector2(6, 12) * TILE, 2)
	_create_npc("hulu", "npc_penjaga_hutan", "penjaga_hutan", Vector2(45, 14) * TILE, 1)
	
	# Desa: Petani, ibu desa
	_create_npc("desa", "npc_petani_1", "petani", Vector2(10, 10) * TILE, 2)
	_create_npc("desa", "npc_ibu_desa", "ibu", Vector2(53, 10) * TILE, 2)
	
	# Kota: Pedagang, anak sekolah
	_create_npc("kota", "npc_pedagang", "pedagang", Vector2(30, 10) * TILE, 3)
	_create_npc("kota", "npc_anak_sekolah", "budi", Vector2(50, 13) * TILE, 3)
	
	# Hilir: Nelayan, penjaga sungai
	_create_npc("hilir", "npc_nelayan", "nelayan", Vector2(10, 14) * TILE, 4)
	_create_npc("hilir", "npc_penjaga_sungai", "pakrt", Vector2(50, 12) * TILE, 4)

func _create_npc(zone: String, dialogue_key: String, sprite_key: String, pos: Vector2, npc_level: int) -> void:
	var npc_scene := preload("res://scenes/world/npc_topdown.tscn")
	var npc := npc_scene.instantiate()
	npc.position = pos
	npc.set("npc_key", dialogue_key)
	npc.set("sprite_key", sprite_key)
	npc.set("level_id", npc_level)
	_zone_containers[zone].add_child(npc)

func _spawn_gameplay_objects() -> void:
	# Sampah, bin, tree_spot di setiap zona
	_spawn_zone_trash("hulu", 15, ["organik", "plastik"])
	_spawn_zone_bins("hulu", ["organik", "plastik"])
	_spawn_zone_tree_spots("hulu", 8, "tree")
	
	_spawn_zone_trash("desa", 12, ["organik", "plastik", "b3"])
	_spawn_zone_bins("desa", ["organik", "plastik", "b3"])
	_spawn_zone_tree_spots("desa", 6, "tree")
	
	_spawn_zone_trash("kota", 20, ["plastik", "b3"])
	_spawn_zone_bins("kota", ["plastik", "b3"])
	
	_spawn_zone_trash("hilir", 10, ["plastik", "b3"])
	_spawn_zone_bins("hilir", ["plastik", "b3"])
	_spawn_zone_tree_spots("hilir", 5, "mangrove")

func _spawn_zone_trash(zone: String, count: int, categories: Array) -> void:
	var trash_scene := preload("res://scenes/world/trash_topdown.tscn")
	for i in range(count):
		var trash := trash_scene.instantiate()
		var x: int = 4 + (i * 73 + 17) % (ZONE_WIDTH - 8)
		var y: int = 4 + (i * 37 + 11) % (ZONE_HEIGHT - 8)
		if y >= 15 and y <= 18:
			y += 6
		trash.position = Vector2(x, y) * TILE
		trash.set("trash_id", "%s_trash_%d" % [zone, i])
		trash.set("category", categories[i % categories.size()])
		_zone_containers[zone].add_child(trash)

func _spawn_zone_bins(zone: String, categories: Array) -> void:
	var bin_scene := preload("res://scenes/world/bin_topdown.tscn")
	for i in range(categories.size()):
		var bin := bin_scene.instantiate()
		var x: int = 10 + i * 15
		var y: int = 20
		bin.position = Vector2(x, y) * TILE
		bin.set("bin_category", categories[i])
		_zone_containers[zone].add_child(bin)

func _spawn_zone_tree_spots(zone: String, count: int, kind: String) -> void:
	var tree_scene := preload("res://scenes/world/tree_spot_topdown.tscn")
	for i in range(count):
		var spot := tree_scene.instantiate()
		var x: int = 8 + (i * 61 + 23) % (ZONE_WIDTH - 16)
		var y: int = 6 + (i * 43 + 31) % 8
		spot.position = Vector2(x, y) * TILE
		spot.set("kind", kind)
		_zone_containers[zone].add_child(spot)

func _setup_camera() -> void:
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = ZONE_WIDTH * TILE
	camera.limit_bottom = ZONE_HEIGHT * TILE

func _setup_hud() -> void:
	if hud:
		hud.update_all()

func change_zone(zone: String) -> void:
	if zone not in _zone_containers:
		return
	
	# Hide all zones
	for z in _zone_containers.values():
		z.visible = false
	
	# Show target zone
	_zone_containers[zone].visible = true
	_current_zone = zone
	
	# Move player to spawn position
	if zone in _spawn_positions:
		player.global_position = _zone_containers[zone].global_position + _spawn_positions[zone]
	
	# Update camera limits
	var zone_offset: int = ["hulu", "desa", "kota", "hilir"].find(zone)
	camera.limit_left = zone_offset * ZONE_WIDTH * TILE
	camera.limit_right = (zone_offset + 1) * ZONE_WIDTH * TILE
	
	# Toast
	toast("Memasuki zona: %s" % zone.capitalize(), true)

func toast(text: String, is_good: bool = true) -> void:
	if hud:
		hud.show_toast(text, is_good)

func _refresh_mission() -> void:
	if QuestManager.is_main_quest_active():
		hud.update_mission(QuestManager.get_main_quest_text())
	else:
		hud.hide_mission()

# ─── Callback gameplay ───────────────────────────────────────────────────────

func on_trash_picked(category: String, _trash_id: String) -> void:
	GameState.rupiah += 500
	toast("Sampah %s dipungut. +Rp500" % category, true)

func on_bin_sorted(category: String) -> void:
	toast("Sampah %s terpilah. Sungai membaik." % category, true)

func on_tree_planted(kind: String) -> void:
	var label: String = "Mangrove" if kind == "mangrove" else "Pohon"
	toast("%s ditanam. Sungai membaik." % label, true)

func on_npc_talked(_npc_key: String) -> void:
	pass

# ─── Kontrol & pause ─────────────────────────────────────────────────────────

func _on_dialogue_started() -> void:
	_dialogue_active = true
	if hud:
		hud.hide_toast()
	set_touch_controls_visible(false)

func _on_dialogue_finished() -> void:
	_dialogue_active = false
	set_touch_controls_visible(true)

func _on_pause_opened() -> void:
	if hud:
		hud.hide_toast()
		hud.visible = false
	set_touch_controls_visible(false)

func _on_pause_closed() -> void:
	if hud:
		hud.visible = true
	set_touch_controls_visible(not _dialogue_active)

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

func try_complete_level() -> void:
	pass
