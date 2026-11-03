## Tuas drainase top-down.
extends Area2D
class_name PilotLever

@export var lever_id: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

var _pressed: bool = false

func _ready() -> void:
	add_to_group("pilot_lever")
	sprite.texture = load("res://assets/sprites/props/lever_off.png")
	label.text = "Tuas %d" % lever_id

func get_action_label() -> String:
	return "" if _pressed else "Tarik"

func interact() -> void:
	if _pressed:
		return
	_pressed = true
	sprite.texture = load("res://assets/sprites/props/lever_on.png")
	var tween := create_tween()
	tween.tween_property(self, "rotation", 0.12, 0.08)
	tween.tween_property(self, "rotation", 0.0, 0.12)
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("lever_pressed"):
		level.lever_pressed(lever_id)

func reset_lever() -> void:
	_pressed = false
	sprite.texture = load("res://assets/sprites/props/lever_off.png")
