## Zone Gate — menghubungkan zona dalam world_sungai_deli.
## Zona terbuka jika river_health mencapai threshold DAN misi zona sumber selesai.
extends Area2D
class_name ZoneGate

@export var target_zone: String = ""  # "desa", "kota", "hilir", "epilog"
@export var source_zone: String = ""  # zona tempat gate ini berada
@export var river_health_threshold: float = 40.0
@export var closed_hint: String = "Sungai masih kotor. Bersihkan sampah di zona ini dulu."

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var blocker: StaticBody2D = $Blocker

var _open: bool = false
var _player_in_range: bool = false
var _initialized: bool = false

func _ready() -> void:
	add_to_group("zone_gate")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	GameState.river_health_changed.connect(_on_river_health_changed)
	GameState.quest_started.connect(_on_quest_started)
	refresh_gate_state()
	_initialized = true

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
	return GameState.river_health >= river_health_threshold and _mission_done()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		if _open:
			_interact_prompt_show()

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
		if _initialized:
			AudioManager.play_sfx("gate_open")
		sprite.texture = load("res://assets/sprites/props/gate_open.png")
		label.text = "Ke " + target_zone.capitalize()
		_set_blocker_disabled(true)
		if _player_in_range:
			_interact_prompt_show()
	else:
		sprite.texture = load("res://assets/sprites/props/gate_closed.png")
		if GameState.river_health < river_health_threshold:
			label.text = "Terkunci (%d%%)" % int(river_health_threshold)
		else:
			label.text = "Misi belum selesai"
		_set_blocker_disabled(false)
		if _player_in_range:
			_interact_prompt_hide()

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
	return "Masuk" if _open else "Periksa"

func interact() -> void:
	if _open:
		_transition_to_zone()
	else:
		_toast_hint()

func _transition_to_zone() -> void:
	var world := _world()
	if world == null:
		return
	AudioManager.play_sfx("gate_open")
	if target_zone == "epilog":
		if world.has_method("finish_journey"):
			world.call("finish_journey")
		return
	if world.has_method("change_zone"):
		world.call("change_zone", target_zone)

func _toast_hint() -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("toast"):
		level.call("toast", closed_hint, false)

func _interact_prompt_show() -> void:
	pass

func _interact_prompt_hide() -> void:
	pass
