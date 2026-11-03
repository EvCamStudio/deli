## TrashBin Script
# Tong sampah pilah: organik / plastik / b3.
# Pemain menekan aksi → menu pilih jenis muncul → validasi benar/salah.
extends Area2D
class_name TrashBin

# ─── Export ───────────────────────────────────────────────────────────────────
@export var bin_category: String = "plastik"  # organik / plastik / b3

@onready var sprite: CanvasItem = get_node_or_null("Sprite2D") as CanvasItem
@onready var label: Label = get_node_or_null("Label") as Label
@onready var sort_menu: Control = get_node_or_null("SortMenu") as Control

# ─── Signal ───────────────────────────────────────────────────────────────────
signal trash_sorted(correct: bool)

func _ready() -> void:
	if label:
		label.text = _get_bin_label()
	if sort_menu:
		sort_menu.hide()

func get_action_label() -> String:
	# Hanya tampilkan jika ada sampah di inventaris
	var pending: Array = _get_pending_trash()
	if pending.is_empty():
		return ""
	return "Buang"

func interact() -> void:
	var pending: Array = _get_pending_trash()
	if pending.is_empty():
		return
	_show_sort_menu(pending)

# ─── Menu Pilih Sampah ────────────────────────────────────────────────────────

func _show_sort_menu(pending: Array) -> void:
	if not sort_menu:
		return
	# Bersihkan tombol lama
	for child in sort_menu.get_children():
		if child is Button:
			child.queue_free()

	for item in pending:
		var btn := Button.new()
		btn.text = item.get("id", "").replace("_", " ").capitalize()
		btn.custom_minimum_size = Vector2(80, 28)
		var item_ref: Dictionary = item
		btn.pressed.connect(func(): _sort_item(item_ref))
		sort_menu.add_child(btn)

	sort_menu.show()

func _sort_item(item: Dictionary) -> void:
	sort_menu.hide()
	_remove_from_pending(item)

	var correct: bool = item.get("category", "") == bin_category
	if correct:
		GameState.collect_trash(bin_category)
		GameState.add_river_health(3.0)
		AudioManager.play_sfx("correct")
		SettingsManager.vibrate(20)
	else:
		GameState.add_river_health(-5.0)
		AudioManager.play_sfx("wrong")
		SettingsManager.vibrate(80)

	trash_sorted.emit(correct)

# ─── Inventaris ───────────────────────────────────────────────────────────────

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

func _get_bin_label() -> String:
	match bin_category:
		"organik": return "🟫 Organik"
		"plastik":  return "🟡 Plastik"
		"b3":       return "🔴 B3"
		_:          return bin_category.capitalize()
