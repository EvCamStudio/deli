## Zone Gate — menghubungkan zona dalam world_sungai_deli.
## Zona terkunci jika river_health belum mencapai threshold.
extends Area2D
class_name ZoneGate

@export var target_zone: String = ""  # "hulu", "desa", "kota", "hilir"
@export var river_health_threshold: float = 40.0
@export var closed_hint: String = "Sungai masih kotor. Bersihkan sampah di zona ini dulu."

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var blocker: StaticBody2D = $Blocker

var _open: bool = false
var _player_in_range: bool = false

func _ready() -> void:
	add_to_group("zone_gate")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_gate_state()
	GameState.river_health_changed.connect(_on_river_health_changed)

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
	_update_gate_state()

func _update_gate_state() -> void:
	var should_open: bool = GameState.river_health >= river_health_threshold
	if should_open == _open:
		return
	
	_open = should_open
	if _open:
		sprite.texture = load("res://assets/sprites/props/gate_open.png")
		label.text = "Ke " + target_zone.capitalize()
		blocker.queue_free()
		if _player_in_range:
			_interact_prompt_show()
	else:
		sprite.texture = load("res://assets/sprites/props/gate_closed.png")
		label.text = "Terkunci (%d%%)" % int(river_health_threshold)
		if _player_in_range:
			_interact_prompt_hide()

func get_action_label() -> String:
	return "Masuk" if _open else "Periksa"

func interact() -> void:
	if _open:
		_transition_to_zone()
	else:
		_toast_hint()

func _transition_to_zone() -> void:
	var world := get_parent().get_parent() as WorldSungaiDeli
	if world:
		world.change_zone(target_zone)

func _toast_hint() -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level:
		level.toast(closed_hint, false)

func _interact_prompt_show() -> void:
	# Notify player UI untuk show interact button
	pass

func _interact_prompt_hide() -> void:
	pass