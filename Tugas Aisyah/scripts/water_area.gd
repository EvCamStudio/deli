## WaterArea Script
# Area air interaktif: membuat karakter merasakan efek air dan efek visual.
extends Area2D
class_name WaterArea

@export var water_speed_mult: float = 0.75

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1  # Mendeteksi Player (layer 1)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_in_water"):
		body.set_in_water(true)

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("set_in_water"):
		body.set_in_water(false)
