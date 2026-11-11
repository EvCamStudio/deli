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
	collision_layer = 0
	collision_mask = 1
	_configure_invisible_trigger()
	body_entered.connect(_on_body_entered)
	if starts_open:
		open()

func _configure_invisible_trigger() -> void:
	# Gerbang level tampil menyatu dengan jalan tanpa sprite pintu atau label teks.
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
	if is_instance_valid(blocker_shape):
		blocker_shape.position = Vector2.ZERO
		var blocker_rect := RectangleShape2D.new()
		blocker_rect.size = Vector2(20, 64)
		blocker_shape.shape = blocker_rect

func get_action_label() -> String:
	return ""

func interact() -> void:
	_try_gate()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if _open:
			call_deferred("_try_gate")
		else:
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
	if is_instance_valid(blocker_shape):
		blocker_shape.set_deferred("disabled", true)
