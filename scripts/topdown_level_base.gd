## Basis level top-down untuk Level 1, 2, dan 4.
## Menyediakan spawn helper, pengecekan misi, dan gerbang akhir.
extends LevelBase
class_name TopdownLevelBase

const NPC_SCENE := preload("res://scenes/world/npc_topdown.tscn")
const TRASH_SCENE := preload("res://scenes/world/trash_topdown.tscn")
const BIN_SCENE := preload("res://scenes/world/bin_topdown.tscn")
const GATE_SCENE := preload("res://scenes/world/gate_topdown.tscn")
const TREE_SPOT_SCENE := preload("res://scenes/world/tree_spot_topdown.tscn")

var _gate: Node = null
var _talked_npcs: Dictionary = {}

func _ready() -> void:
	camera_topdown = true
	auto_advance = false
	super._ready()

# ─── Spawn helper ────────────────────────────────────────────────────────────

func spawn_npc(dialogue_key: String, sprite_key: String, pos: Vector2) -> Node:
	var npc := NPC_SCENE.instantiate()
	npc.position = pos
	npc.npc_key = dialogue_key
	npc.sprite_key = sprite_key
	npc.level_id = level_id
	npc.talked.connect(_on_npc_talked)
	add_child(npc)
	return npc

func spawn_trash(trash_id: String, category: String, pos: Vector2) -> void:
	var trash := TRASH_SCENE.instantiate()
	trash.position = pos
	trash.trash_id = trash_id
	trash.category = category
	add_child(trash)

func spawn_bin(category: String, pos: Vector2) -> void:
	var bin := BIN_SCENE.instantiate()
	bin.position = pos
	bin.bin_category = category
	add_child(bin)

func spawn_tree_spot(kind: String, pos: Vector2) -> void:
	var spot := TREE_SPOT_SCENE.instantiate()
	spot.position = pos
	spot.kind = kind
	add_child(spot)

func spawn_gate(pos: Vector2, starts_open: bool = true, open_label: String = "Jalan Terbuka") -> void:
	_gate = GATE_SCENE.instantiate()
	_gate.position = pos
	_gate.starts_open = starts_open
	_gate.open_label = open_label
	add_child(_gate)

func gate() -> Node:
	return _gate

# ─── Callback gameplay ───────────────────────────────────────────────────────

func on_trash_picked(category: String, _trash_id: String) -> void:
	GameState.rupiah += 500
	toast("Sampah %s dipungut. +Rp500" % category, true)

func on_bin_sorted(_category: String) -> void:
	toast("Sampah terpilah! Sungai membaik.", true)

func on_tree_planted(_kind: String) -> void:
	pass

func on_npc_talked(_npc_key: String) -> void:
	pass

func _on_npc_talked(npc_key: String) -> void:
	_talked_npcs[npc_key] = true
	on_npc_talked(npc_key)

func talked_count() -> int:
	return _talked_npcs.size()

func has_talked(npc_key: String) -> bool:
	return _talked_npcs.has(npc_key)

func update_mission(text: String) -> void:
	if hud and hud.has_method("update_mission"):
		hud.update_mission(text)

# ─── Penyelesaian level ──────────────────────────────────────────────────────

func _mission_ready() -> bool:
	return true

func _not_ready_message() -> String:
	return "Selesaikan misi dulu!"

func try_complete_level() -> void:
	if not _mission_ready():
		toast(_not_ready_message(), false)
		return
	if GameState.river_health < river_health_target:
		toast("Kejernihan baru %d%%. Butuh %d%%." % [int(GameState.river_health), int(river_health_target)], false)
		update_mission("Bersihkan dan tanam lebih banyak (target %d%%)." % int(river_health_target))
		return
	GameState.complete_level(level_id)
