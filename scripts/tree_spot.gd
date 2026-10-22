## TreeSpot Script
# Titik di mana pemain bisa menanam pohon (Level 1).
# Setelah tanam: animasi tumbuh, +river_health.
extends Area2D
class_name TreeSpot

@onready var sprite: CanvasItem = get_node_or_null("Sprite2D") as CanvasItem
@onready var planted_sprite: CanvasItem = get_node_or_null("PlantedSprite") as CanvasItem

var _is_planted: bool = false

func _ready() -> void:
	if sprite == null:
		sprite = get_node_or_null("SpotVis") as CanvasItem
	if planted_sprite == null:
		planted_sprite = get_node_or_null("TreeVis") as CanvasItem
	if planted_sprite:
		planted_sprite.hide()

func get_action_label() -> String:
	if _is_planted:
		return ""
	return "Tanam"

func interact() -> void:
	if _is_planted:
		return
	_is_planted = true
	sprite.hide()
	planted_sprite.show()
	GameState.plant_tree()
	GameState.add_river_health(4.0)
	AudioManager.play_sfx("correct")
	SettingsManager.vibrate(30)

	# Animasi tumbuh sederhana
	var tween := create_tween()
	planted_sprite.scale = Vector2(0.1, 0.1)
	tween.tween_property(planted_sprite, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT)
