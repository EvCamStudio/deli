## MapGate Script
## Pintu gerbang perpindahan antar 4 peta (Warung, Sungai, Gang Jali, Pintu Air).
extends Area2D
class_name MapGate

@export var target_scene_path: String = "res://scenes/maps/map_b_sungai.tscn"
@export var gate_name: String = "Ke Tepi Sungai Deli"
@export var require_interact: bool = false

@onready var label: Label = get_node_or_null("Label") as Label

func _ready() -> void:
	if label:
		label.text = "→ %s" % gate_name
		label.show()
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if not require_interact:
			_pindah_peta()

func interact() -> void:
	_pindah_peta()

func _pindah_peta() -> void:
	if target_scene_path.is_empty():
		return
	if SceneManager:
		SceneManager.change_scene(target_scene_path)
	else:
		get_tree().change_scene_to_file(target_scene_path)

