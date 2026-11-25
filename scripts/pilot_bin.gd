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
	# Sesuaikan tekstur visual dengan kategori tong sampah (Organik/Hijau, Plastik/Kuning, B3/Merah)
	match bin_category:
		"plastik", "anorganik":
			sprite.texture = load("res://assets/sprites/props/bin_plastik.png")
		"b3":
			sprite.texture = load("res://assets/sprites/props/bin_b3.png")
		_:
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
	var pending: Array = _pending()
	if pending.is_empty():
		return "Tempat Sampah"
	return "Buang Sampah (%d)" % pending.size()

func _pending() -> Array:
	if GameState.has_meta("pending_trash"):
		return GameState.get_meta("pending_trash")
	return []

func interact() -> void:
	var pending: Array = _pending()
	if pending.is_empty():
		_toast("Kantong sampah kosong. Pungut sampah di sepanjang sungai dulu!", false)
		return

	var count: int = pending.size()
	var total_reward: int = 0
	var level := get_tree().get_first_node_in_group("level")
	var last_cat: String = "plastik"

	# Kosongkan seluruh sampah di kantong ke dalam tong sampah
	while not pending.is_empty():
		var item: Dictionary = pending[0]
		var item_cat: String = str(item.get("category", "plastik"))
		last_cat = item_cat
		pending.remove_at(0)
		GameState.collect_trash(item_cat)
		GameState.rupiah += 2000
		total_reward += 2000
		if level and level.has_method("on_bin_sorted"):
			level.call("on_bin_sorted", item_cat)

	GameState.set_meta("pending_trash", pending)
	AudioManager.play_sfx("correct")
	SettingsManager.vibrate(30)
	if count == 1:
		_toast("1 sampah %s dibuang ke tempat sampah!" % _display_category(last_cat), true)
	else:
		_toast("%d sampah dibuang ke tempat sampah!" % count, true)

	_bump()
	var fact: String = _fact_for(last_cat)
	if not fact.is_empty():
		_show_fact(fact)

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

func _format_number(value: int) -> String:
	var text: String = str(value)
	var out: String = ""
	var count: int = 0
	for i in range(text.length() - 1, -1, -1):
		out = text[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "." + out
	return out

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
