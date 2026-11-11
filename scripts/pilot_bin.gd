## Tong sampah top-down dengan validasi kategori, fakta singkat, dan hadiah.
## Salah tong tetap diterima (forgiving), tapi hadiahnya lebih kecil.
extends Area2D
class_name PilotBin

@export var bin_category: String = "plastik"
@export var required_quest: String = ""
@export var quest_hint: String = "Bicara dulu dengan warga yang memberi misi."

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

var _facts: Dictionary = {}

func _ready() -> void:
	sprite.texture = load("res://assets/sprites/props/bin_%s.png" % bin_category)
	label.text = _category_name()
	label.show()
	match bin_category:
		"organik":
			label.add_theme_color_override("font_color", Color(0.2, 0.42, 0.18))
		"plastik":
			label.add_theme_color_override("font_color", Color(0.48, 0.33, 0.08))
		"b3":
			label.add_theme_color_override("font_color", Color(0.55, 0.16, 0.12))
	_load_facts()

func _category_name() -> String:
	match bin_category:
		"organik": return "Organik"
		"plastik": return "Plastik"
		"b3": return "B3"
		_: return bin_category.capitalize()

func _load_facts() -> void:
	var path: String = "res://data/facts.json"
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK:
		var data = json.get_data()
		if data is Dictionary:
			_facts = data
	file.close()

func _fact_for(category: String) -> String:
	var list: Array = _facts.get(category, [])
	if list.is_empty():
		return ""
	return str(list[randi() % list.size()])

func get_action_label() -> String:
	return "" if _pending().is_empty() else "Pilah"

func _pending() -> Array:
	if GameState.has_meta("pending_trash"):
		return GameState.get_meta("pending_trash")
	return []

func interact() -> void:
	if not required_quest.is_empty() and not GameState.has_quest(required_quest):
		_toast(quest_hint, false)
		return
	var pending: Array = _pending()
	if pending.is_empty():
		_toast("Bawa sampah dulu ke tong ini.", false)
		return

	var item: Dictionary = pending[0]
	var item_cat: String = str(item.get("category", bin_category))
	var correct: bool = item_cat == bin_category
	pending.remove_at(0)
	GameState.set_meta("pending_trash", pending)
	GameState.collect_trash(item_cat)

	if correct:
		GameState.add_river_health(5.0)
		GameState.rupiah += 2000
		AudioManager.play_sfx("correct")
		SettingsManager.vibrate(20)
		_toast("Tepat! Sampah %s masuk tong %s. +Rp2.000" % [_display_category(item_cat), _category_name()], true)
	else:
		GameState.add_river_health(3.0)
		GameState.rupiah += 1500
		AudioManager.play_sfx("click")
		SettingsManager.vibrate(12)
		_toast("Hampir! %s seharusnya ke tong %s. +Rp1.500" % [
			_display_category(item_cat), _category_name_for(item_cat)
		], false)

	_bump()
	var fact: String = _fact_for(item_cat)
	if not fact.is_empty():
		_show_fact(fact)

	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("on_bin_sorted"):
		level.on_bin_sorted(item_cat)

func _category_name_for(cat: String) -> String:
	match cat:
		"organik": return "Organik"
		"plastik": return "Plastik"
		"b3": return "B3"
		_: return cat.capitalize()

func _display_category(cat: String) -> String:
	match cat:
		"organik": return "organik"
		"plastik": return "plastik"
		"b3": return "B3"
		_: return cat

func _show_fact(text: String) -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level and level.get("hud") and level.hud.has_method("show_hint"):
		level.hud.show_hint("Fakta: " + text, 6.5)

func _bump() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.14, 0.9), 0.08)
	tween.tween_property(self, "scale", Vector2.ONE, 0.18)

func _toast(text: String, good: bool) -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("toast"):
		level.toast(text, good)
