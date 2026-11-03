## PortraitDialogue — kotak dialog bergaya Citampi dengan portrait dan name plate.
extends CanvasLayer
class_name PortraitDialogue

@onready var tap_area: Button = $TapArea
@onready var panel: PanelContainer = $Root/Panel
@onready var portrait: TextureRect = $Root/Portrait
@onready var name_plate: PanelContainer = $Root/NamePlate
@onready var speaker_label: Label = $Root/NamePlate/Speaker
@onready var text_label: RichTextLabel = $Root/Panel/VBox/TextLabel
@onready var continue_hint: Label = $Root/Panel/VBox/ContinueHint
@onready var choices_container: VBoxContainer = $Root/Panel/VBox/ChoicesContainer

const TYPEWRITER_SPEED: float = 0.022
const PORTRAITS: Dictionary = {
	"Pak Pedagang": "pedagang",
	"Ibu Rumah Tangga": "ibu",
	"Budi": "budi",
	"Pak RT": "pakrt",
	"Penjaga Hutan": "penjaga_hutan",
	"Pak Tani": "petani",
	"Ibu Sari": "ibu",
	"Pak Nelayan": "nelayan",
	"Penjaga Sungai": "pakrt",
	"Player": "player",
	"Kamu": "player",
	"MC": "player",
	"Bu Mira": "ibu",
	"Pak Hendra": "pakrt",
	"Bang Jali": "pedagang",
	"Kak Rina": "ibu",
	"Pak Darwis": "penjaga_hutan",
	"Datuk Sampan": "penjaga_hutan",
	"Bang Ucok": "pakrt",
	"Warga": "petani",
	"Warga 1": "petani",
	"Warga 2": "pedagang",
}

var _full_text: String = ""
var _is_typing: bool = false
var _tween: Tween = null
var _has_choices: bool = false
var _choices_shown: bool = false
var _current_node: Dictionary = {}

func _ready() -> void:
	panel.hide()
	portrait.hide()
	name_plate.hide()
	tap_area.hide()
	tap_area.pressed.connect(_on_tap)
	DialogueManager.register_dialogue_box(self)

func show_node(node: Dictionary) -> void:
	_current_node = node
	_clear_choices()
	panel.show()
	portrait.show()
	name_plate.show()
	tap_area.show()

	speaker_label.text = str(node.get("speaker", ""))
	_update_portrait(node)

	var full_text: String = str(node.get("teks", node.get("text", "")))
	var choices: Array = node.get("pilihan", node.get("choices", []))
	_has_choices = not choices.is_empty()
	continue_hint.visible = not _has_choices
	_start_typewriter(full_text)

	if _has_choices:
		await _wait_typewriter_done()
		if is_inside_tree():
			_show_choices(choices)

func _update_portrait(node: Dictionary) -> void:
	var key: String = str(node.get("portrait", ""))
	if key.is_empty():
		key = PORTRAITS.get(str(node.get("speaker", "")), "player")
	var emotion: String = str(node.get("emosi", node.get("emotion", "neutral")))
	var path: String = "res://assets/sprites/portraits/%s_%s.png" % [key, emotion]
	if not ResourceLoader.exists(path):
		path = "res://assets/sprites/portraits/%s_neutral.png" % key
	if ResourceLoader.exists(path):
		portrait.texture = load(path)
		portrait.show()
	else:
		portrait.hide()

	var tween := create_tween()
	portrait.modulate.a = 0.0
	tween.tween_property(portrait, "modulate:a", 1.0, 0.16)

func _start_typewriter(text: String) -> void:
	_full_text = text
	_is_typing = true
	text_label.text = text
	text_label.visible_characters = 0

	if _tween:
		_tween.kill()
	_tween = create_tween()
	var char_count: int = text.length()
	_tween.tween_property(text_label, "visible_characters", char_count, TYPEWRITER_SPEED * char_count)
	_tween.tween_callback(func():
		_is_typing = false
		text_label.visible_characters = -1
	)

func _wait_typewriter_done() -> void:
	while _is_typing:
		await get_tree().process_frame

func _show_choices(choices: Array) -> void:
	if _choices_shown or choices.is_empty():
		return
	_choices_shown = true
	tap_area.hide()
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		var btn := Button.new()
		var label_str: String = str(choice.get("teks", choice.get("text", "")))
		if choice.has("tipe"):
			btn.text = " [%s] %s" % [choice.get("tipe"), label_str]
		else:
			btn.text = "  %s" % label_str
		btn.custom_minimum_size = Vector2(0, 28)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD
		btn.add_theme_font_size_override("font_size", 12)
		var idx: int = i
		btn.pressed.connect(func(): _on_choice_selected(idx))
		choices_container.add_child(btn)

func _clear_choices() -> void:
	_choices_shown = false
	for child in choices_container.get_children():
		child.queue_free()

func _on_tap() -> void:
	if _is_typing:
		_finish_typewriter()
	elif not _has_choices:
		DialogueManager.advance()

func _finish_typewriter() -> void:
	if _tween:
		_tween.kill()
	_is_typing = false
	text_label.text = _full_text
	text_label.visible_characters = -1
	if _has_choices:
		var choices: Array = _current_node.get("pilihan", _current_node.get("choices", []))
		_show_choices(choices)

func _input(event: InputEvent) -> void:
	if not panel.visible:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("action"):
		if _is_typing:
			_finish_typewriter()
		elif not _has_choices:
			DialogueManager.advance()
		get_viewport().set_input_as_handled()

func _on_choice_selected(index: int) -> void:
	_clear_choices()
	tap_area.show()
	DialogueManager.advance(index)

func hide_box() -> void:
	panel.hide()
	portrait.hide()
	name_plate.hide()
	tap_area.hide()
	_clear_choices()
	_has_choices = false
