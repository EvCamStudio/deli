## PortraitDialogue — kotak dialog berbingkai artistik (dialogue_frame_ornate & plaque_frame).
## Mengatur tampilan potret, plat nama, pembagian teks bertahap (auto-pagination),
## dan menu pilihan terpisah yang muncul setelah lawan bicara selesai bicara.
extends CanvasLayer
class_name PortraitDialogue

@onready var tap_area: Button = $TapArea
@onready var root: Control = $Root

# Frame dialog utama (bergaya Gambar 9)
@onready var dialogue_frame: Control = $Root/DialogueFrame
@onready var portrait: TextureRect = $Root/DialogueFrame/PortraitSlot/Portrait
@onready var speaker_label: Label = $Root/DialogueFrame/NamePlateSlot/Speaker
@onready var text_label: RichTextLabel = $Root/DialogueFrame/TextSlot/TextLabel
@onready var advance_icon: Label = get_node_or_null("Root/DialogueFrame/AdvanceIcon") as Label
@onready var dialog_hint: Label = get_node_or_null("Root/DialogueFrame/DialogHint") as Label

# Modal pilihan terpisah
@onready var choice_modal: Control = $Root/ChoiceModal
@onready var choices_container: VBoxContainer = $Root/ChoiceModal/ChoicePanel/VBox/ChoicesContainer

# Plakat narasi tengah
@onready var narration_center: Control = get_node_or_null("Root/NarrationCenter") as Control
@onready var narration_header: Label = get_node_or_null("Root/NarrationCenter/Content/VBox/Header") as Label
@onready var narration_text_label: RichTextLabel = get_node_or_null("Root/NarrationCenter/Content/VBox/Text") as RichTextLabel
@onready var narration_continue_hint: Label = get_node_or_null("Root/NarrationCenter/Content/Hint") as Label

# Kompatibilitas mundur dengan script/test lama
var panel: Control:
	get:
		return dialogue_frame

const TYPEWRITER_SPEED: float = 0.022
const MAX_PAGE_CHARS: int = 160
const MAX_PAGE_CHARS_NARRATION: int = 320

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
	"Mak": "ibu",
	"Bu Mira": "ibu",
	"Pak Hendra": "pakrt",
	"Bang Jali": "pedagang",
	"Kak Rina": "ibu",
	"Pak Darwis": "petani",
	"Pemilik Toko": "pedagang",
	"Datuk Sampan": "nelayan",
	"Bang Ucok": "pakrt",
	"Warga": "petani",
	"Warga 1": "petani",
	"Warga 2": "pedagang",
}

var _current_node: Dictionary = {}
var _current_pages: Array[String] = []
var _current_page_idx: int = 0
var _current_choices: Array = []
var _has_choices: bool = false
var _is_typing: bool = false
var _last_typed_char: int = 0
var _tween: Tween = null
var _is_narration_active: bool = false
var _active_label: RichTextLabel = null

func _ready() -> void:
	if text_label:
		text_label.bbcode_enabled = true
	if narration_text_label:
		narration_text_label.bbcode_enabled = true
	dialogue_frame.hide()
	choice_modal.hide()
	if narration_center:
		narration_center.hide()
	tap_area.hide()
	tap_area.pressed.connect(_on_tap)
	DialogueManager.register_dialogue_box(self)

func _process(_delta: float) -> void:
	if _is_typing and _active_label and _active_label.is_visible_in_tree():
		var cur: int = _active_label.visible_characters
		if cur > _last_typed_char:
			_last_typed_char = cur
			AudioManager.play_typewriter_blip()

func show_node(node: Dictionary) -> void:
	_current_node = node
	_clear_choices()
	choice_modal.hide()
	tap_area.show()

	var speaker_name: String = str(node.get("speaker", ""))
	var is_narration: bool = speaker_name.to_lower() == "narasi" or speaker_name.is_empty()
	_is_narration_active = is_narration

	# Persiapkan pilihan jika ada
	_current_choices = node.get("choices", node.get("pilihan", []))
	_has_choices = not _current_choices.is_empty()

	if is_narration and narration_center:
		dialogue_frame.hide()
		narration_center.show()
		if narration_header:
			narration_header.hide()
			narration_header.text = ""
		_active_label = narration_text_label
	else:
		if narration_center:
			narration_center.hide()
		dialogue_frame.show()
		_active_label = text_label
		var p_name: String = GameState.player_name.strip_edges() if GameState.player_name.strip_edges() != "" else "Pemain"
		var spk_lower := speaker_name.to_lower()
		if spk_lower in ["mc", "player", "kamu", "pemain", "arisyah", "rian"] or (not p_name.is_empty() and spk_lower == p_name.to_lower()):
			speaker_label.text = p_name
		else:
			speaker_label.text = speaker_name
		_update_portrait(node)

	# Format dan bagi teks menjadi halaman-halaman yang muat rapi
	var full_text: String = _clean_text(str(node.get("text", node.get("teks", ""))))
	var p_name: String = GameState.player_name.strip_edges() if GameState.player_name.strip_edges() != "" else "Pemain"
	full_text = full_text.replace("{nama}", p_name).replace("{Nama}", p_name).replace("{player}", p_name)

	var max_chars: int = MAX_PAGE_CHARS_NARRATION if is_narration else MAX_PAGE_CHARS
	_current_pages = _paginate_text(full_text, max_chars)
	_current_page_idx = 0
	_show_page(_current_page_idx)

func _show_page(page_idx: int) -> void:
	if page_idx < 0 or page_idx >= _current_pages.size():
		return
	var page_text: String = _current_pages[page_idx]
	_start_typewriter(page_text)

func _paginate_text(text: String, max_chars: int = MAX_PAGE_CHARS) -> Array[String]:
	text = text.strip_edges()
	if text.length() <= max_chars and not "\n\n" in text:
		return [text]

	var paragraphs: PackedStringArray = text.split("\n\n")
	var pages: Array[String] = []
	var current_page: String = ""

	for para in paragraphs:
		para = para.strip_edges().replace("\n", " ")
		if para.is_empty():
			continue

		# Bagi berdasarkan tanda baca kalimat
		var regex := RegEx.new()
		regex.compile("([^.?!…]+[.?!…]+)")
		var matches := regex.search_all(para)

		var sentences: Array[String] = []
		if matches.is_empty():
			sentences.append(para)
		else:
			var last_end: int = 0
			for m in matches:
				sentences.append(m.get_string().strip_edges())
				last_end = m.get_end()
			if last_end < para.length():
				var rest: String = para.substr(last_end).strip_edges()
				if not rest.is_empty():
					sentences.append(rest)

		for s in sentences:
			s = s.strip_edges()
			if s.is_empty():
				continue

			# Jika satu kalimat saja sudah lebih panjang dari max_chars, pecah berdasarkan kata
			var sub_chunks: Array[String] = _split_long_sentence(s, max_chars)
			for chunk in sub_chunks:
				if current_page.is_empty():
					current_page = chunk
				elif current_page.length() + 1 + chunk.length() <= max_chars:
					current_page += " " + chunk
				else:
					pages.append(current_page)
					current_page = chunk

	if not current_page.is_empty():
		pages.append(current_page)

	if pages.is_empty():
		pages.append(text)
	return pages

func _split_long_sentence(sentence: String, max_len: int) -> Array[String]:
	if sentence.length() <= max_len:
		return [sentence]

	# Coba pecah berdasarkan jeda koma / titik dua / tanda pisah terlebih dahulu
	var regex := RegEx.new()
	regex.compile("([^,;–-]+[,;–-]+)")
	var matches := regex.search_all(sentence)

	var clauses: Array[String] = []
	if not matches.is_empty():
		var last_end: int = 0
		for m in matches:
			clauses.append(m.get_string().strip_edges())
			last_end = m.get_end()
		if last_end < sentence.length():
			var rest: String = sentence.substr(last_end).strip_edges()
			if not rest.is_empty():
				clauses.append(rest)

	var chunks: Array[String] = []
	if not clauses.is_empty():
		var cur := ""
		for c in clauses:
			if cur.is_empty():
				cur = c
			elif cur.length() + 1 + c.length() <= max_len:
				cur += " " + c
			else:
				chunks.append(cur)
				cur = c
		if not cur.is_empty():
			chunks.append(cur)

		var final_chunks: Array[String] = []
		for ch in chunks:
			if ch.length() > max_len:
				final_chunks.append_array(_split_by_words(ch, max_len))
			else:
				final_chunks.append(ch)
		return final_chunks
	else:
		return _split_by_words(sentence, max_len)

func _split_by_words(text: String, max_len: int) -> Array[String]:
	var words: PackedStringArray = text.split(" ")
	var chunks: Array[String] = []
	var cur := ""
	for w in words:
		if cur.is_empty():
			cur = w
		elif cur.length() + 1 + w.length() <= max_len:
			cur += " " + w
		else:
			chunks.append(cur)
			cur = w
	if not cur.is_empty():
		chunks.append(cur)
	return chunks

func _clean_text(raw: String) -> String:
	var p_name: String = GameState.player_name.strip_edges() if GameState.player_name.strip_edges() != "" else "Pemain"
	var telepathy_tag := "(Suara di kepala MC)"
	var has_telepathy := telepathy_tag in raw
	var temp := raw.replace(telepathy_tag, "___TELEPATHY___")

	var regex := RegEx.new()
	regex.compile("\\s*\\([a-zA-Z\\s—–,\\.]{3,80}\\)\\s*")
	temp = regex.sub(temp, " ", true).strip_edges()

	if has_telepathy:
		temp = temp.replace("___TELEPATHY___", "[i][color=#8be9fd](Suara di kepala %s)[/color][/i]" % p_name)
	return temp

func _update_portrait(node: Dictionary) -> void:
	var key: String = str(node.get("portrait", ""))
	if key.is_empty():
		var spk: String = str(node.get("speaker", ""))
		var spk_lower := spk.to_lower()
		var p_name: String = GameState.player_name.strip_edges().to_lower()
		if spk_lower in ["mc", "player", "kamu", "pemain", "arisyah", "rian"] or (not p_name.is_empty() and spk_lower == p_name):
			key = "player"
		else:
			key = PORTRAITS.get(spk, "player")
	var emotion: String = str(node.get("emotion", node.get("emosi", "neutral")))
	var path: String = "res://assets/sprites/portraits/%s_%s.png" % [key, emotion]
	if not ResourceLoader.exists(path):
		path = "res://assets/sprites/portraits/%s_neutral.png" % key
	if ResourceLoader.exists(path):
		portrait.texture = load(path)
		portrait.show()
	else:
		portrait.texture = null

	var tween := create_tween()
	portrait.modulate.a = 0.0
	tween.tween_property(portrait, "modulate:a", 1.0, 0.16)

func _start_typewriter(text: String) -> void:
	_is_typing = true
	_last_typed_char = 0
	if advance_icon:
		advance_icon.modulate.a = 0.0
	if dialog_hint:
		dialog_hint.modulate.a = 0.0
	if narration_continue_hint:
		narration_continue_hint.modulate.a = 0.0

	var target: RichTextLabel = _active_label if _active_label else text_label
	target.text = text
	target.visible_characters = 0

	if _tween:
		_tween.kill()
	_tween = create_tween()
	var char_count: int = text.length()
	_tween.tween_property(target, "visible_characters", char_count, TYPEWRITER_SPEED * char_count)
	_tween.tween_callback(func():
		_finish_typewriter()
	)

func _finish_typewriter() -> void:
	if _tween:
		_tween.kill()
	_is_typing = false
	var target: RichTextLabel = _active_label if _active_label else text_label
	target.visible_characters = -1
	if advance_icon:
		advance_icon.modulate.a = 1.0
	if dialog_hint and not _is_narration_active:
		var tw := create_tween()
		tw.tween_property(dialog_hint, "modulate:a", 1.0, 0.2)
	if narration_continue_hint and _is_narration_active:
		var tw := create_tween()
		tw.tween_property(narration_continue_hint, "modulate:a", 1.0, 0.2)

func _on_tap() -> void:
	if _is_typing:
		AudioManager.play_sfx("tap_b")
		_finish_typewriter()
		return

	# Jika masih ada halaman berikutnya dari teks panjang, lanjut ke halaman berikutnya
	if _page_index_has_next():
		AudioManager.play_sfx("tap_b")
		_current_page_idx += 1
		_show_page(_current_page_idx)
		return

	# Halaman terakhir tercapai:
	if _has_choices:
		# Sesuai arahan user: tutup kotak dialog NPC, lalu tampilkan modal pilihan MC
		AudioManager.play_sfx("tap_b")
		dialogue_frame.hide()
		if narration_center:
			narration_center.hide()
		_open_choice_modal()
	else:
		AudioManager.play_sfx("tap_b")
		DialogueManager.advance()

func _page_index_has_next() -> bool:
	return _current_page_idx + 1 < _current_pages.size()

func _open_choice_modal() -> void:
	tap_area.hide()
	dialogue_frame.hide()
	choice_modal.show()
	_clear_choices()

	var btn_style_normal: StyleBoxFlat = _create_choice_btn_style(false)
	var btn_style_hover: StyleBoxFlat = _create_choice_btn_style(true)

	for i in range(_current_choices.size()):
		var choice: Dictionary = _current_choices[i]
		var btn := Button.new()
		var choice_text: String = str(choice.get("text", choice.get("teks", "")))

		var is_locked: bool = bool(choice.get("locked", false)) or bool(choice.get("disabled", false))
		if choice.has("requires_flag"):
			var req_flag: String = str(choice["requires_flag"])
			if not bool(GameState.choices.get(req_flag, false)):
				is_locked = true
		if "[terkunci" in choice_text.to_lower():
			is_locked = true

		var clean_choice := choice_text
		var prefix_regex := RegEx.new()
		prefix_regex.compile("^(?:\\[?[A-D]\\]|(?:\\[?[A-D][\\.\\-–:]))\\s*")
		clean_choice = prefix_regex.sub(clean_choice, "").strip_edges()

		var was_text_locked := false
		if clean_choice.to_lower().begins_with("[terkunci]"):
			was_text_locked = true
			clean_choice = clean_choice.substr(10).strip_edges()

		var letter: String = str(["A", "B", "C", "D", "E"][clampi(i, 0, 4)])
		if is_locked or was_text_locked:
			btn.text = "  %s. [Terkunci] %s" % [letter, clean_choice]
		else:
			btn.text = "  %s. %s" % [letter, clean_choice]

		btn.custom_minimum_size = Vector2(0, 26)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD
		btn.add_theme_font_override("font", load("res://assets/fonts/PixelifySans.ttf"))
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", Color(0.28, 0.16, 0.08, 1))
		btn.add_theme_color_override("font_hover_color", Color(0.18, 0.1, 0.05, 1))
		btn.add_theme_color_override("font_pressed_color", Color(0.18, 0.1, 0.05, 1))
		btn.add_theme_stylebox_override("normal", btn_style_normal)
		btn.add_theme_stylebox_override("hover", btn_style_hover)
		btn.add_theme_stylebox_override("pressed", btn_style_hover)
		btn.add_theme_stylebox_override("focus", btn_style_hover)

		if is_locked or was_text_locked:
			btn.disabled = true
			btn.focus_mode = Control.FOCUS_NONE
			btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
			btn.modulate = Color(0.65, 0.65, 0.65, 0.7)
		else:
			var idx: int = i
			btn.pressed.connect(func(): _on_choice_selected(idx))

		choices_container.add_child(btn)

func _create_choice_btn_style(hover: bool) -> StyleBoxFlat:
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
	sb.content_margin_left = 8.0
	sb.content_margin_top = 4.0
	sb.content_margin_right = 8.0
	sb.content_margin_bottom = 4.0
	return sb

func _clear_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()

func _on_choice_selected(index: int) -> void:
	choice_modal.hide()
	_clear_choices()
	tap_area.show()
	AudioManager.play_sfx("tap_b")
	DialogueManager.advance(index)

func _input(event: InputEvent) -> void:
	var is_open: bool = dialogue_frame.visible or (narration_center and narration_center.visible)
	if not is_open:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("action"):
		_on_tap()
		get_viewport().set_input_as_handled()

func hide_box() -> void:
	dialogue_frame.hide()
	choice_modal.hide()
	if narration_center:
		narration_center.hide()
	tap_area.hide()
	_clear_choices()
	_has_choices = false
	_is_narration_active = false
	if dialog_hint:
		dialog_hint.modulate.a = 0.0
	if narration_continue_hint:
		narration_continue_hint.modulate.a = 0.0
