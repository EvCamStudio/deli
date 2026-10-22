## Lever Script
# Tuas puzzle drainase. Tekan tombol aksi → memberi tahu level script.
extends Area2D
class_name Lever

@export var lever_id: int = 1  # ID unik tuas ini di level

@onready var sprite: CanvasItem = get_node_or_null("Sprite2D") as CanvasItem
@onready var label: Label = get_node_or_null("Label") as Label

var _is_pressed: bool = false

func _ready() -> void:
	if label:
		label.text = "Tuas %d" % lever_id

func get_action_label() -> String:
	if _is_pressed:
		return ""
	return "Tarik"

func interact() -> void:
	if _is_pressed:
		return
	_is_pressed = true
	# Animasi sprite flip / warna
	if sprite:
		sprite.modulate = Color(0.4, 0.8, 0.4)

	# Beritahu level script
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("lever_pressed"):
		level.lever_pressed(lever_id)
