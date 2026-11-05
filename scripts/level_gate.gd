## LevelGate Script
# Gerbang akhir level. Saat pemain menyentuhnya,
# cek apakah syarat selesai terpenuhi.
extends Area2D
class_name LevelGate

@onready var sprite: CanvasItem = get_node_or_null("Sprite2D") as CanvasItem
@onready var label: Label = get_node_or_null("Label") as Label

func _ready() -> void:
	if label:
		label.text = "Lanjut"
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Player:
		# Cari LevelBase di parent tree
		var level: Node = get_tree().get_first_node_in_group("level")
		if level and level.has_method("try_complete_level"):
			level.try_complete_level()
