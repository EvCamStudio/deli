## Tong sampah top-down dengan validasi kategori langsung.
extends Area2D
class_name PilotBin

@export var bin_category: String = "plastik"

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready() -> void:
	sprite.texture = load("res://assets/sprites/props/bin_%s.png" % bin_category)
	label.text = _category_name()
	label.hide()
	match bin_category:
		"organik":
			label.add_theme_color_override("font_color", Color(0.35, 0.55, 0.32))
		"plastik":
			label.add_theme_color_override("font_color", Color(0.62, 0.46, 0.14))
		"b3":
			label.add_theme_color_override("font_color", Color(0.62, 0.24, 0.2))

func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		label.hide()
		return
	label.visible = global_position.distance_squared_to(player.global_position) < 48.0 * 48.0

func _category_name() -> String:
	match bin_category:
		"organik": return "Organik"
		"plastik": return "Plastik"
		"b3": return "B3"
		_: return bin_category.capitalize()

func get_action_label() -> String:
	return "" if _pending().is_empty() else "Pilah"

func _pending() -> Array:
	if GameState.has_meta("pending_trash"):
		return GameState.get_meta("pending_trash")
	return []

func interact() -> void:
	var pending: Array = _pending()
	if pending.is_empty():
		_toast("Bawa sampah dulu ke tong ini.", false)
		return

	var item: Dictionary = pending[0]
	var item_cat: String = str(item.get("category", bin_category))
	pending.remove_at(0)
	GameState.set_meta("pending_trash", pending)
	GameState.collect_trash(item_cat)
	GameState.add_river_health(3.0)
	GameState.rupiah += 1500
	AudioManager.play_sfx("correct")
	SettingsManager.vibrate(20)
	_bump()
	_toast("Berhasil! Sampah %s dipilah. +Rp1.500" % _display_category(item_cat), true)
	
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("on_bin_sorted"):
		level.on_bin_sorted(item_cat)

func _display_category(cat: String) -> String:
	match cat:
		"organik": return "organik"
		"plastik": return "plastik"
		"b3": return "B3"
		_: return cat

func _bump() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.14, 0.9), 0.08)
	tween.tween_property(self, "scale", Vector2.ONE, 0.18)

func _toast(text: String, good: bool) -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("toast"):
		level.toast(text, good)
