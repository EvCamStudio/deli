## Zone Gate — menghubungkan zona dalam world_sungai_deli secara dua arah.
## Akses antar-map terbuka bebas; hanya gate epilog yang menunggu misi hilir bila require_mission_to_open aktif.
extends Area2D
class_name ZoneGate

@export var target_zone: String = ""  # "hulu", "desa", "kota", "hilir", "epilog"
@export var source_zone: String = ""  # zona tempat gate ini berada
@export var river_health_threshold: float = 0.0
@export var closed_hint: String = "Selesaikan dulu misi di zona ini."
@export var require_mission_to_open: bool = false
@export var entry_position: Vector2 = Vector2(-1, -1)  # posisi masuk lokal di target_zone (-1 = spawn default)

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var blocker: StaticBody2D = $Blocker

var _open: bool = false
var _player_in_range: bool = false

func _ready() -> void:
	add_to_group("zone_gate")
	collision_layer = 0
	collision_mask = 1
	_configure_invisible_trigger()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	GameState.river_health_changed.connect(_on_river_health_changed)
	GameState.quest_started.connect(_on_quest_started)
	refresh_gate_state()

func _configure_invisible_trigger() -> void:
	# Gerbang zona tampil menyatu dengan jalan tanpa sprite pintu atau label teks.
	if is_instance_valid(sprite):
		sprite.visible = false
	if is_instance_valid(label):
		label.text = ""
		label.visible = false
	var trigger_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if trigger_shape:
		trigger_shape.position = Vector2.ZERO
		var area_rect := RectangleShape2D.new()
		area_rect.size = Vector2(28, 64)
		trigger_shape.shape = area_rect
	if is_instance_valid(blocker):
		for child in blocker.get_children():
			if child is CollisionShape2D:
				var col := child as CollisionShape2D
				col.position = Vector2.ZERO
				var blocker_rect := RectangleShape2D.new()
				blocker_rect.size = Vector2(20, 64)
				col.shape = blocker_rect

func _world() -> Node:
	var node: Node = get_parent()
	while node != null:
		if node.has_method("is_zone_cleared") and node.has_method("get_current_zone"):
			return node
		node = node.get_parent()
	return null

func _zone_key() -> String:
	if not source_zone.is_empty():
		return source_zone
	var world := _world()
	if world and world.has_method("get_current_zone"):
		return str(world.call("get_current_zone"))
	return ""

func _mission_done() -> bool:
	var world := _world()
	if world == null or not world.has_method("is_zone_cleared"):
		return true
	var zone: String = _zone_key()
	if zone.is_empty():
		return true
	return bool(world.call("is_zone_cleared", zone))

func _can_open() -> bool:
	if not require_mission_to_open:
		return true
	return GameState.river_health >= river_health_threshold and _mission_done()

func _is_in_active_zone() -> bool:
	var world := _world()
	if world == null:
		return false
	var zone: String = _zone_key()
	return zone.is_empty() or str(world.call("get_current_zone")) == zone

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or not _is_in_active_zone():
		return
	_player_in_range = true
	if _open:
		call_deferred("_transition_to_zone")
	else:
		_toast_hint()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_interact_prompt_hide()

func _on_river_health_changed(_new_value: float) -> void:
	refresh_gate_state()

func _on_quest_started(_quest_id: String) -> void:
	refresh_gate_state()

## Dipanggil world setiap progres misi berubah.
func refresh_gate_state() -> void:
	var should_open: bool = _can_open()
	if _open:
		return  # gate yang sudah terbuka tidak menutup lagi
	if should_open:
		_open = true
		_set_blocker_disabled(true)
		if _player_in_range:
			call_deferred("_transition_to_zone")
	else:
		_set_blocker_disabled(false)

func get_target_zone() -> String:
	return target_zone

func is_open() -> bool:
	return _open

func _set_blocker_disabled(disabled_state: bool) -> void:
	if not is_instance_valid(blocker):
		return
	blocker.process_mode = Node.PROCESS_MODE_DISABLED if disabled_state else Node.PROCESS_MODE_INHERIT
	for child in blocker.get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).set_deferred("disabled", disabled_state)

func get_action_label() -> String:
	return ""

func interact() -> void:
	if _open:
		_transition_to_zone()
	else:
		_toast_hint()

func _transition_to_zone() -> void:
	if not _open or not _is_in_active_zone():
		return
	var world := _world()
	if world == null:
		return
	if world.has_method("can_use_zone_gate") and not bool(world.call("can_use_zone_gate")):
		return
	_player_in_range = false
	if target_zone == "epilog":
		if world.has_method("finish_journey"):
			world.call("finish_journey")
		return
	if world.has_method("change_zone"):
		if entry_position.x >= 0.0 and entry_position.y >= 0.0:
			world.call("change_zone", target_zone, entry_position)
		else:
			world.call("change_zone", target_zone)

func _toast_hint() -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("toast"):
		level.call("toast", closed_hint, false)

func _interact_prompt_show() -> void:
	pass

func _interact_prompt_hide() -> void:
	pass
