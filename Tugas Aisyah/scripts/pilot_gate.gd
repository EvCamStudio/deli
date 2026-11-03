## Gerbang akhir level top-down.
extends Area2D
class_name PilotGate

@export var starts_open: bool = false
@export var open_label: String = "Jalan Terbuka"
@export var closed_hint: String = "Gerbang masih tertutup."

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var blocker: StaticBody2D = $Blocker
@onready var blocker_shape: CollisionShape2D = $Blocker/Col

var _open: bool = false

func _ready() -> void:
	add_to_group("pilot_gate")
	body_entered.connect(_on_body_entered)
	if starts_open:
		open()
	else:
		sprite.texture = load("res://assets/sprites/props/gate_closed.png")
		label.text = "Gerbang"

func get_action_label() -> String:
	return "Selesai" if _open else "Periksa"

func interact() -> void:
	_try_gate()

func _on_body_entered(body: Node2D) -> void:
	if _open and body.is_in_group("player"):
		_try_gate()

func _try_gate() -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level == null:
		return
	if _open:
		level.try_complete_level()
	else:
		level.toast(closed_hint, false)

func open() -> void:
	_open = true
	sprite.texture = load("res://assets/sprites/props/gate_open.png")
	label.text = open_label
	blocker_shape.set_deferred("disabled", true)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1.2, 1.2, 1.0), 0.15)
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)
