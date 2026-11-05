## TrashItem Script
# Objek sampah yang bisa dipungut pemain.
# Ketika dipungut, masuk ke inventaris; pemain membawanya ke tong pilah.
extends Area2D
class_name TrashItem

# ─── Export ───────────────────────────────────────────────────────────────────
@export var trash_id: String = "botol_plastik"
@export var category: String = "plastik"  # organik / plastik / b3

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var sprite: CanvasItem = get_node_or_null("Sprite2D") as CanvasItem
@onready var label: Label = get_node_or_null("Label") as Label

# ─── State ────────────────────────────────────────────────────────────────────
var _is_collected: bool = false

func _ready() -> void:
	if label:
		label.text = _get_label_from_id(trash_id)

func get_action_label() -> String:
	return "Ambil"

func interact() -> void:
	if _is_collected:
		return
	_is_collected = true
	AudioManager.play_sfx("trash_pickup")
	SettingsManager.vibrate(30)

	# Tambah ke inventaris global sementara (akan diproses di tong pilah)
	_add_to_inventory()

	# Cek progres misi Hari 1
	if GameState.hari == 1 and GameState.h1_fase == 1:
		GameState.tambah_sampah_h1()

	queue_free()

func _add_to_inventory() -> void:
	# Simpan di GameState sebagai pending item untuk ditentukan kategorinya di tong
	if not GameState.has_meta("pending_trash"):
		GameState.set_meta("pending_trash", [])
	var pending: Array = GameState.get_meta("pending_trash")
	pending.append({ "id": trash_id, "category": category })
	GameState.set_meta("pending_trash", pending)

func _get_label_from_id(id: String) -> String:
	# Muat dari trash_types.json (cache sederhana)
	return id.replace("_", " ").capitalize()
