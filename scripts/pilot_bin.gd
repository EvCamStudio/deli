## Tong sampah top-down umum (1 jenis tong untuk semua kategori sampah, tanpa label teks di atasnya).
extends Area2D
class_name PilotBin

@export var bin_category: String = "umum"
@export var required_quest: String = ""
@export var quest_hint: String = "Bicara dulu dengan warga yang memberi misi."

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

var _facts: Dictionary = {}

func _ready() -> void:
	# Gunakan 1 tampilan tong sampah standar dan sembunyikan label teks di atasnya
	sprite.texture = load("res://assets/sprites/props/bin_organik.png")
	if label:
		label.hide()
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
	return "Buang Sampah"

func _pending() -> Array:
	if GameState.has_meta("pending_trash"):
		return GameState.get_meta("pending_trash")
	return []

func interact() -> void:
	var pending: Array = _pending()
	if pending.is_empty():
		_toast("Bawa sampah dulu ke tempat sampah ini.", false)
		return

	var item: Dictionary = pending[0]
	var item_cat: String = str(item.get("category", "plastik"))
	pending.remove_at(0)
	GameState.set_meta("pending_trash", pending)
	GameState.collect_trash(item_cat)

	# Semua jenis sampah langsung diterima di 1 tong sampah umum
	GameState.add_river_health(5.0)
	GameState.rupiah += 2000
	AudioManager.play_sfx("correct")
	SettingsManager.vibrate(20)
	_toast("Sampah %s dibuang ke tempat sampah! +Rp2.000" % _display_category(item_cat), true)

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
