## TrashBin Script (Forgiving Mode)
# Tong sampah yang menerima semua jenis sampah tanpa penalty.
extends Area2D
class_name TrashBin

@export var bin_category: String = "plastik"
@export var required_quest: String = ""
@export var quest_hint: String = "Bicara dulu dengan warga yang memberi misi."

@onready var sprite: CanvasItem = get_node_or_null("Sprite2D") as CanvasItem
@onready var label: Label = get_node_or_null("Label") as Label

func _ready() -> void:
	if label:
		label.hide()

func get_action_label() -> String:
	var pending: Array = _get_pending_trash()
	if pending.is_empty():
		return ""
	return "Pilah"

func interact() -> void:
	if not required_quest.is_empty() and not GameState.has_quest(required_quest):
		_show_locked()
		return
	var pending: Array = _get_pending_trash()
	if pending.is_empty():
		return
	
	var item: Dictionary = pending[0]
	var item_cat: String = str(item.get("category", bin_category))
	
	_remove_from_pending(item)
	
	# Forgiving: terima semua kategori, no penalty
	GameState.collect_trash(item_cat)
	GameState.add_river_health(3.0)
	GameState.rupiah += 1500
	AudioManager.play_sfx("correct")
	SettingsManager.vibrate(20)
	
	# Bump animation
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.14, 0.9), 0.08)
	tween.tween_property(self, "scale", Vector2.ONE, 0.18)
	
	# Toast
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("toast"):
		level.toast("Berhasil! Sampah %s dipilah. +Rp1.500" % _display_category(item_cat), true)
	
	if level and level.has_method("on_bin_sorted"):
		level.on_bin_sorted(item_cat)

func _get_pending_trash() -> Array:
	if GameState.has_meta("pending_trash"):
		return GameState.get_meta("pending_trash")
	return []

func _remove_from_pending(item: Dictionary) -> void:
	var pending: Array = _get_pending_trash()
	for i in range(pending.size()):
		if pending[i].get("id", "") == item.get("id", ""):
			pending.remove_at(i)
			break
	GameState.set_meta("pending_trash", pending)

func _show_locked() -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("toast"):
		level.toast(quest_hint, false)

func _display_category(cat: String) -> String:
	match cat:
		"organik": return "organik"
		"plastik": return "plastik"
		"b3": return "B3"
		_: return cat
