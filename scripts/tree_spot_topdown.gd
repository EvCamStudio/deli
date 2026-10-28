## Titik tanam top-down untuk pohon hulu dan mangrove pesisir.
extends Area2D
class_name TreeSpotTopDown

@export var kind: String = "tree"  # "tree" atau "mangrove"

@onready var marker: Sprite2D = $Marker
@onready var planted_sprite: Sprite2D = $Planted

var _planted: bool = false

func _ready() -> void:
	add_to_group("tree_spot")
	marker.texture = load("res://assets/sprites/props/tree_spot.png")
	var path: String = "res://assets/sprites/props/mangrove.png" if kind == "mangrove" else "res://assets/sprites/props/tree.png"
	planted_sprite.texture = load(path)
	planted_sprite.position = Vector2(0, -planted_sprite.texture.get_height() * 0.5)
	planted_sprite.hide()

func get_action_label() -> String:
	if _planted:
		return ""
	return "Tanam Mangrove" if kind == "mangrove" else "Tanam Pohon"

func interact() -> void:
	if _planted:
		return
	_planted = true
	marker.hide()
	planted_sprite.show()

	if kind == "mangrove":
		GameState.plant_mangrove()
		GameState.add_river_health(5.0)
	else:
		GameState.plant_tree()
		GameState.add_river_health(4.0)

	AudioManager.play_sfx("correct")
	SettingsManager.vibrate(30)

	var tween := create_tween()
	planted_sprite.scale = Vector2(0.15, 0.15)
	tween.tween_property(planted_sprite, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("on_tree_planted"):
		level.on_tree_planted(kind)
