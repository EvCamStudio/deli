## DialogueBox Script
# Menampilkan dialog dari DialogueManager: teks typewriter,
# pilihan besar (tap), ketuk untuk lanjut/percepat.
extends CanvasLayer
class_name DialogueBox

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var panel: PanelContainer = $Panel
@onready var speaker_label: Label = $Panel/VBox/SpeakerLabel
@onready var text_label: RichTextLabel = $Panel/VBox/TextLabel
@onready var continue_hint: Label = $Panel/VBox/ContinueHint
@onready var choices_container: VBoxContainer = $Panel/VBox/ChoicesContainer
@onready var tap_area: Button = $TapArea  # Transparan, menutupi layar

# ─── State ────────────────────────────────────────────────────────────────────
const TYPEWRITER_SPEED: float = 0.03  # detik per karakter
var _full_text: String = ""
var _is_typing: bool = false
var _tween: Tween = null
var _has_choices: bool = false

func _ready() -> void:
	panel.hide()
	tap_area.hide()
	tap_area.pressed.connect(_on_tap)
	# Daftarkan ke DialogueManager
	DialogueManager.register_dialogue_box(self)

# ─── Tampilkan Node Dialog ────────────────────────────────────────────────────

## Dipanggil oleh DialogueManager untuk menampilkan satu node.
func show_node(node: Dictionary) -> void:
	_clear_choices()
	panel.show()
	tap_area.show()

	speaker_label.text = node.get("speaker", "")
	var full_text: String = node.get("text", "")
	var choices: Array = node.get("choices", [])
	_has_choices = not choices.is_empty()

	# Sembunyikan hint jika ada pilihan
	continue_hint.visible = not _has_choices

	# Mulai typewriter
	_start_typewriter(full_text)

	# Tampilkan tombol pilihan setelah teks selesai
	if _has_choices:
		await _wait_typewriter_done()
		_show_choices(choices)

func _start_typewriter(text: String) -> void:
	_full_text = text
	_is_typing = true
	text_label.text = ""
	text_label.visible_characters = 0

	if _tween:
		_tween.kill()
	_tween = create_tween()
	var char_count: int = text.length()
	_tween.tween_property(text_label, "visible_characters", char_count, TYPEWRITER_SPEED * char_count)
	_tween.tween_callback(func():
		_is_typing = false
		text_label.text = _full_text  # Pastikan teks penuh
	)

func _wait_typewriter_done() -> void:
	while _is_typing:
		await get_tree().process_frame

func _show_choices(choices: Array) -> void:
	tap_area.hide()  # Nonaktifkan tap-to-continue selama pilihan tampil
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		var btn := Button.new()
		btn.text = choice.get("text", "")
		btn.custom_minimum_size = Vector2(0, 28)
		# Sambungkan dengan index yang di-capture
		var idx: int = i
		btn.pressed.connect(func(): _on_choice_selected(idx))
		choices_container.add_child(btn)

func _clear_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()

# ─── Input ────────────────────────────────────────────────────────────────────

func _on_tap() -> void:
	if _is_typing:
		# Percepat: tampilkan teks penuh sekarang
		if _tween:
			_tween.kill()
		_is_typing = false
		text_label.text = _full_text
		text_label.visible_characters = -1
		if _has_choices:
			var current_node: Dictionary = DialogueManager._current_node
			_show_choices(current_node.get("choices", []))
	else:
		# Lanjut ke node berikutnya (tanpa pilihan)
		if not _has_choices:
			DialogueManager.advance()

func _on_choice_selected(index: int) -> void:
	_clear_choices()
	tap_area.show()
	DialogueManager.advance(index)

## Dipanggil oleh DialogueManager saat dialog selesai.
func hide_box() -> void:
	panel.hide()
	tap_area.hide()
	_clear_choices()
