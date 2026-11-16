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

	var raw_speaker: String = str(node.get("speaker", ""))
	var p_name: String = GameState.player_name.strip_edges() if GameState.player_name.strip_edges() != "" else "Pemain"
	if raw_speaker.to_lower() in ["mc", "player", "kamu", "pemain", "arisyah", "rian"] or (not p_name.is_empty() and raw_speaker.to_lower() == p_name.to_lower()):
		speaker_label.text = p_name
	else:
		speaker_label.text = raw_speaker
	var full_text: String = _clean_text(str(node.get("text", node.get("teks", ""))))
	var choices: Array = node.get("choices", node.get("pilihan", []))
	_has_choices = not choices.is_empty()

	# Sembunyikan hint jika ada pilihan
	continue_hint.visible = not _has_choices

	# Mulai typewriter
	_start_typewriter(full_text)

	# Tampilkan tombol pilihan setelah teks selesai
	if _has_choices:
		await _wait_typewriter_done()
		_show_choices(choices)

func _clean_text(raw: String) -> String:
	var regex := RegEx.new()
	regex.compile("\\s*\\([a-zA-Z\\s—–,\\.]{3,80}\\)\\s*")
	return regex.sub(raw, " ", true).strip_edges()

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
		var choice_text: String = str(choice.get("text", choice.get("teks", "")))

		var clean_choice := choice_text
		var prefix_regex := RegEx.new()
		prefix_regex.compile("^\\[?[A-D](\\s*[-–:]\\s*[^]]+)?\\]?\\s*(\\.\\s*)?")
		clean_choice = prefix_regex.sub(clean_choice, "").strip_edges()

		var letter: String = str(["A", "B", "C", "D", "E"][clampi(i, 0, 4)])
		btn.text = "%s. %s" % [letter, clean_choice]
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
