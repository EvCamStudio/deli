## KnowledgeCardPopup
# Menampilkan kartu pengetahuan yang terbuka dan koleksi kartu.
extends CanvasLayer
class_name KnowledgeCardPopup

signal opened
signal closed

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
	AudioManager.play_sfx("switch_a", -2.0)
	_populate_collection()
	dim.show()
	collection_panel.show()
	get_tree().paused = true

func _populate_collection() -> void:
	for child in collection_list.get_children():
		child.queue_free()

	var font_res := load("res://assets/fonts/PixelifySans.ttf") as Font
	var style_normal: StyleBoxFlat = _create_card_btn_style(false)
	var style_hover: StyleBoxFlat = _create_card_btn_style(true)
	var style_disabled: StyleBoxFlat = _create_card_disabled_style()

	for card in _all_cards:
		var card_id: String = card.get("id", "")
		var is_collected: bool = card_id in GameState.collected_cards
		var btn := Button.new()
		btn.text = ("  [v] " if is_collected else "  [ ] ") + str(card.get("title", "???"))
		btn.disabled = not is_collected
		btn.custom_minimum_size = Vector2(0, 24)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD
		if font_res:
			btn.add_theme_font_override("font", font_res)
		btn.add_theme_font_size_override("font_size", 10)
		btn.add_theme_color_override("font_color", Color(0.28, 0.16, 0.08, 1))
		btn.add_theme_color_override("font_hover_color", Color(0.18, 0.1, 0.05, 1))
		btn.add_theme_color_override("font_pressed_color", Color(0.18, 0.1, 0.05, 1))
		btn.add_theme_color_override("font_disabled_color", Color(0.55, 0.45, 0.35, 0.6))
		btn.add_theme_stylebox_override("normal", style_normal)
		btn.add_theme_stylebox_override("hover", style_hover)
		btn.add_theme_stylebox_override("pressed", style_hover)
		btn.add_theme_stylebox_override("focus", style_hover)
		btn.add_theme_stylebox_override("disabled", style_disabled)

		if is_collected:
			btn.pressed.connect(func(): show_card(card); _close_collection())
		collection_list.add_child(btn)

func _create_card_btn_style(hover: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.95, 0.82, 0.58, 1) if hover else Color(0.85, 0.72, 0.48, 0.95)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color(0.55, 0.35, 0.15, 1) if hover else Color(0.44, 0.28, 0.12, 1)
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_right = 6
	sb.corner_radius_bottom_left = 6
	sb.shadow_color = Color(0, 0, 0, 0.25)
	sb.shadow_size = 2
	sb.content_margin_left = 10.0
	sb.content_margin_top = 2.0
	sb.content_margin_right = 10.0
	sb.content_margin_bottom = 2.0
	return sb

func _create_card_disabled_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.72, 0.62, 0.48, 0.5)
	border_style(sb)
	return sb

func border_style(sb: StyleBoxFlat) -> void:
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.5, 0.4, 0.3, 0.5)
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_right = 6
	sb.corner_radius_bottom_left = 6
	sb.content_margin_left = 10.0
	sb.content_margin_top = 2.0
	sb.content_margin_right = 10.0
	sb.content_margin_bottom = 2.0

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
