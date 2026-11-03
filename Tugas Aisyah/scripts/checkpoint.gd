## Checkpoint Script
# Checkpoint: pemain respawn di sini kalau jatuh/mati.
extends Area2D
class_name Checkpoint

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer

var _activated: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Player and not _activated:
		_activated = true
		body.set_checkpoint(global_position)
		if anim:
			anim.play("activate")
