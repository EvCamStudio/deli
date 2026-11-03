## KnowledgeCardPopup
# Menampilkan kartu pengetahuan yang terbuka dan koleksi kartu.
extends CanvasLayer
class_name KnowledgeCardPopup

@onready var dim: ColorRect = $Dim
@onready var panel: PanelContainer = $Panel
@onready var category_label: Label = $Panel/VBox/CategoryLabel
@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var text_label: RichTextLabel = $Panel/VBox/TextLabel
@onready var close_btn: Button = $Panel/VBox/CloseBtn
@onready var collection_panel: PanelContainer = $CollectionPanel
@onready var collection_list: VBoxContainer = $CollectionPanel/VBox/ScrollContainer/CardList
@onready var collection_close_btn: Button = $CollectionPanel/VBox/CloseBtn

var _all_cards: Array = []

func _ready() -> void:
	dim.hide()
	panel.hide()
	collection_panel.hide()
	close_btn.pressed.connect(_close_card)
	collection_close_btn.pressed.connect(_close_collection)
	_load_all_cards()
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

func _on_card_unlocked(card_id: String) -> void:
	for card in _all_cards:
		if card.get("id", "") == card_id:
			show_card(card)
			return

func show_card(card: Dictionary) -> void:
	category_label.text = _format_category(card.get("category", ""))
	title_label.text = card.get("title", "")
	text_label.text = card.get("text", "")
	dim.show()
	panel.show()
	get_tree().paused = true
	AudioManager.play_sfx("card_open")

func _close_card() -> void:
	panel.hide()
	if not collection_panel.visible:
		dim.hide()
		get_tree().paused = false

## Tutup semua panel tanpa mengubah status pause (dipakai saat level selesai).
func close_all() -> void:
	panel.hide()
	collection_panel.hide()
	dim.hide()

func open_collection() -> void:
	_populate_collection()
	dim.show()
	collection_panel.show()
	get_tree().paused = true

func _populate_collection() -> void:
	for child in collection_list.get_children():
		child.queue_free()

	for card in _all_cards:
		var card_id: String = card.get("id", "")
		var is_collected: bool = card_id in GameState.collected_cards
		var btn := Button.new()
		btn.text = ("[v] " if is_collected else "[ ] ") + str(card.get("title", "???"))
		btn.disabled = not is_collected
		btn.custom_minimum_size = Vector2(0, 28)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD
		if is_collected:
			btn.pressed.connect(func(): show_card(card); _close_collection())
		collection_list.add_child(btn)

func _close_collection() -> void:
	collection_panel.hide()
	if not panel.visible:
		dim.hide()
		get_tree().paused = false

func _format_category(cat: String) -> String:
	match cat:
		"lingkungan": return "Lingkungan"
		"kearifan_lokal": return "Kearifan Lokal"
		"sejarah": return "Sejarah"
		_: return cat.capitalize()
