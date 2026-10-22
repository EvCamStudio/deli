## KnowledgeCardPopup Script
# Menampilkan kartu pengetahuan saat misi selesai.
# Juga menyediakan mode "koleksi" untuk melihat semua kartu.
extends CanvasLayer
class_name KnowledgeCardPopup

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var panel: PanelContainer = $Panel
@onready var category_label: Label = $Panel/VBox/CategoryLabel
@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var text_label: RichTextLabel = $Panel/VBox/TextLabel
@onready var close_btn: Button = $Panel/VBox/CloseBtn
@onready var collection_list: VBoxContainer = $CollectionPanel/ScrollContainer/CardList
@onready var collection_panel: PanelContainer = $CollectionPanel
@onready var collection_close_btn: Button = $CollectionPanel/VBox/CloseBtn

# ─── Data ─────────────────────────────────────────────────────────────────────
var _all_cards: Array = []

func _ready() -> void:
	panel.hide()
	collection_panel.hide()
	close_btn.pressed.connect(_close_card)
	collection_close_btn.pressed.connect(_close_collection)
	_load_all_cards()

	# Sambungkan sinyal kartu dibuka
	GameState.card_unlocked.connect(_on_card_unlocked)

func _load_all_cards() -> void:
	var path: String = "res://data/knowledge_cards.json"
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK:
		_all_cards = json.get_data()
	file.close()

# ─── Tampilkan Kartu Baru ─────────────────────────────────────────────────────

func _on_card_unlocked(card_id: String) -> void:
	for card in _all_cards:
		if card.get("id", "") == card_id:
			show_card(card)
			return

func show_card(card: Dictionary) -> void:
	category_label.text = _format_category(card.get("category", ""))
	title_label.text = card.get("title", "")
	text_label.text = card.get("text", "")
	panel.show()
	AudioManager.play_sfx("card_open")

func _close_card() -> void:
	panel.hide()

# ─── Koleksi Kartu ────────────────────────────────────────────────────────────

func open_collection() -> void:
	_populate_collection()
	collection_panel.show()

func _populate_collection() -> void:
	# Hapus daftar lama
	for child in collection_list.get_children():
		child.queue_free()

	for card in _all_cards:
		var card_id: String = card.get("id", "")
		var is_collected: bool = card_id in GameState.collected_cards

		var btn := Button.new()
		btn.text = ("✓ " if is_collected else "? ") + card.get("title", "???")
		btn.disabled = not is_collected
		if is_collected:
			btn.pressed.connect(func(): show_card(card); _close_collection())
		collection_list.add_child(btn)

func _close_collection() -> void:
	collection_panel.hide()

# ─── Helper ───────────────────────────────────────────────────────────────────

func _format_category(cat: String) -> String:
	match cat:
		"lingkungan":    return "🌿 Lingkungan"
		"kearifan_lokal": return "🏠 Kearifan Lokal"
		"sejarah":       return "📜 Sejarah"
		_:               return cat.capitalize()
