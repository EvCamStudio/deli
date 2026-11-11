## Titik tanam top-down untuk pohon hulu dan mangrove pesisir.
extends Area2D
class_name TreeSpotTopDown

@export var kind: String = "tree"  # "tree" atau "mangrove"
@export var spot_id: String = ""

@onready var marker: Sprite2D = $Marker
@onready var planted_sprite: Sprite2D = $Planted
@onready var blocker_col: CollisionShape2D = $Blocker/CollisionShape2D

var _planted: bool = false

func _ready() -> void:
	add_to_group("tree_spot")
	marker.texture = load("res://assets/sprites/props/tree_spot.png")
	marker.scale = Vector2.ONE
	var path: String = "res://assets/sprites/props/mangrove.png" if kind == "mangrove" else "res://assets/sprites/props/tree.png"
	planted_sprite.texture = load(path)
	planted_sprite.position = Vector2(0, -planted_sprite.texture.get_height() * 0.5)
	if not spot_id.is_empty() and spot_id in GameState.planted_spots:
		_planted = true
		marker.hide()
		planted_sprite.show()
	else:
		planted_sprite.hide()
	_update_blocker()

func _update_blocker() -> void:
	if is_instance_valid(blocker_col):
		blocker_col.set_deferred("disabled", not _planted)

func get_action_label() -> String:
	if _planted:
		return ""
	return "Tanam Mangrove" if kind == "mangrove" else "Tanam Pohon"

func is_planted() -> bool:
	return _planted

## Tandai sudah ditanam tanpa memicu hadiah (dipakai saat memuat save).
func mark_planted() -> void:
	if _planted:
		return
	_planted = true
	marker.hide()
	planted_sprite.show()
	planted_sprite.scale = Vector2.ONE
	_update_blocker()

func _required_quest() -> String:
	return "tanam_mangrove" if kind == "mangrove" else "tanam_pohon_hulu"

func _show_locked_message() -> void:
	var guide: String = "Nelayan" if kind == "mangrove" else "Penjaga Hutan"
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("toast"):
		level.toast("Bicara dulu dengan %s." % guide, false)

func interact() -> void:
	if _planted:
		return
	if not GameState.has_quest(_required_quest()):
		_show_locked_message()
		return
	_planted = true
	marker.hide()
	planted_sprite.show()
	_update_blocker()

	if kind == "mangrove":
		GameState.plant_mangrove()
		GameState.add_river_health(5.0)
		GameState.rupiah += 2000
	else:
		GameState.plant_tree()
		GameState.add_river_health(4.0)
		GameState.rupiah += 500

	AudioManager.play_sfx("correct")
	SettingsManager.vibrate(30)

	var tween := create_tween()
	planted_sprite.scale = Vector2(0.15, 0.15)
	tween.tween_property(planted_sprite, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if not spot_id.is_empty() and spot_id not in GameState.planted_spots:
		GameState.planted_spots.append(spot_id)

	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("on_tree_planted"):
		level.on_tree_planted(kind)
	GameState.save_game()
