## Intro Dramatic Script — Format Komik Naratif & Panel Dialog
## Menyajikan Bab 1 s/d Bab 3 dengan pemisahan tegas antara Narasi Full Layar,
## Balon Dialog, dan Monolog Pikiran MC dengan Animasi Ketik per Ketik (Typewriter).
extends Control

const CHAPTER_SCENES: Array = [
	preload("res://scenes/intro/chapter_1_jakarta.tscn"),
	preload("res://scenes/intro/chapter_3_medan.tscn"),
]

const HEADERS: Array = [
	"PROLOG · JAKARTA",
	"MEDAN · TIGA HARI KEMUDIAN",
]

const PORTRAITS: Dictionary = {
	"player_neutral": "res://assets/sprites/portraits/player_neutral.png",
	"player_sad": "res://assets/sprites/portraits/player_sad.png",
	"hrd": "res://assets/sprites/portraits/hrd_neutral.png",
	"manajer": "res://assets/sprites/portraits/hrd_neutral.png",
	"ibu": "res://assets/sprites/portraits/ibu_neutral.png",
}

# ─── Naskah Prolog Terpadu (Revisi Sesuai Arahan) ──────────────────────────────
const SCRIPT_DATA: Array = [
	# Prolog · Jakarta — Tiga Tahun & Ruang Kosong
	[
		{
			"tipe": "narasi",
			"teks": "Pagi ini kaca gedung lantai lima tempatku bekerja selama tiga tahun memantulkan langit mendung. Di mejaku yang hampir kosong, terletak selembar surat dengan dua paragraf. Tiga tahun yang lalu aku memulainya di sini, dan kini hanya menyisakan ruang kosong."
		},
		{
			"tipe": "narasi",
			"teks": "Aku jadi teringat kembali saat tiga tahun lalu aku diterima di perusahaan ini. Saat itu Mamak sangat senang mendengarnya. Aku pun sungguh tidak menyangka bisa bekerja di kota metropolitan terbesar di negara ini."
		},
		{
			"tipe": "narasi",
			"teks": "Aku masih ingat dengan sangat jelas betapa gugupnya aku saat HRD mewawancaraiku waktu itu..."
		},
		{
			"tipe": "dialog",
			"speaker": "hrd",
			"teks": "Selamat datang. Silakan sebutkan nama lengkapmu.",
			"input_nama": true
		},
		{
			"tipe": "dialog",
			"speaker": "hrd",
			"teks": "Saya sudah melihat CV kamu, {nama}. CV kamu sangat rapi dan bagus."
		},
		{
			"tipe": "dialog",
			"speaker": "hrd",
			"teks": "Di CV ini saya melihat kalau kamu berasal dari Medan, ya? Kalau saya boleh tahu, apa alasan kamu merantau ke Jakarta dan memilih perusahaan ini?"
		},
		{
			"tipe": "dialog",
			"speaker": "mc",
			"teks": "Saya merantau ke Jakarta karena ingin mencari pekerjaan yang cocok dengan keahlian saya dan bergaji baik."
		},
		{
			"tipe": "dialog",
			"speaker": "mc",
			"teks": "Saya memilih mencoba di perusahaan ini karena posisinya sesuai dengan ekspektasi saya, Pak."
		},
		{
			"tipe": "dialog",
			"speaker": "hrd",
			"teks": "Apa kamu yakin dengan keahlian kamu itu, kamu bisa membantu perusahaan dan bekerja dengan baik?"
		},
		{
			"tipe": "dialog",
			"speaker": "mc",
			"teks": "Ya, saya sangat yakin."
		},
		{
			"tipe": "dialog",
			"speaker": "hrd",
			"teks": "Bagus, saya menyukai semangat kamu."
		},
		{
			"tipe": "narasi",
			"teks": "Yah... tiga tahun itu berlalu dengan cepat, dan aku sudah cukup membantu Mamak dan Bapak untuk membangun usaha tempat makan mereka sendiri."
		},
		{
			"tipe": "narasi",
			"teks": "Aku merenung memandangi kardus yang penuh barang-barangku itu."
		},
		{
			"tipe": "narasi",
			"teks": "Aku tersadar dari renunganku setelah ponselku bergetar di atas meja."
		},
		{
			"tipe": "narasi",
			"teks": "Di layar, aku melihat nama yang meneleponku... itu Mamak."
		}
	],
	# Bab 2 · Medan — Tiga Hari Kemudian
	[
		{
			"tipe": "layar_hitam",
			"teks": "Medan, 3 hari kemudian."
		},
		{
			"tipe": "narasi",
			"teks": "Tiga hari yang lalu saat Mamak meneleponku, beliau mengabarkan kalau Medan sedang diguyur hujan terus-menerus. Karena itu, air Sungai Deli yang berada dekat dengan rumah kami meluap hingga banjir pun tak bisa dihindari lagi."
		},
		{
			"tipe": "narasi",
			"teks": "Mamak memberitahuku kalau tempat makan dan rumah kami terendam air bercampur sisa-sisa lumpur. Banjirnya cukup tinggi hingga banyak perabotan yang rusak karena tidak sempat dipindahkan."
		},
		{
			"tipe": "narasi",
			"teks": "Karena itu, aku mempercepat kepulanganku ke Medan. Aku ingin membantu Mamak dan Bapak. Toh, aku juga sudah tidak ada pekerjaan lagi di Jakarta... Lebih baik aku pulang dan membantu Mamak dan Bapak."
		}
	]
]

# ─── Referensi Node ──────────────────────────────────────────────────────────
@onready var chapter_root: Control = $ChapterRoot
@onready var tap_advance_btn: Button = $TapAdvanceBtn
@onready var header_banner: PanelContainer = $HeaderBanner
@onready var header_label: Label = $HeaderBanner/HeaderLabel
@onready var narration_screen: Control = $NarrationScreen
@onready var paper_header: Label = $NarrationScreen/CenterBox/PaperCard/VBox/PaperHeader
@onready var narration_text: RichTextLabel = $NarrationScreen/CenterBox/PaperCard/VBox/NarrationText
@onready var narration_hint: Label = $NarrationScreen/CenterBox/PaperCard/NarrationHint
@onready var dialogue_container: Control = $DialogueContainer
@onready var dialog_panel: Control = $DialogueContainer
@onready var speaker_tag: Control = get_node_or_null("DialogueContainer/NamePlateSlot")
@onready var speaker_label: Label = $DialogueContainer/NamePlateSlot/SpeakerLabel
@onready var portrait: TextureRect = $DialogueContainer/PortraitSlot/Portrait
@onready var speech_text: RichTextLabel = $DialogueContainer/TextSlot/ContentVBox/SpeechText
@onready var input_row: HBoxContainer = $DialogueContainer/TextSlot/ContentVBox/InputRow
@onready var name_input: LineEdit = $DialogueContainer/TextSlot/ContentVBox/InputRow/NameInput
@onready var confirm_btn: Button = $DialogueContainer/TextSlot/ContentVBox/InputRow/ConfirmBtn
@onready var dialog_hint: Label = $DialogueContainer/DialogHint
@onready var fade_rect: ColorRect = $FadeRect

const TYPEWRITER_SPEED: float = 0.024  # Kecepatan ketik (detik per karakter)
const MAX_PAGE_CHARS: int = 160        # Maksimal karakter per lembar dialog (2-3 baris aman)
const MAX_PAGE_CHARS_NARRATION: int = 320 # Narasi muat banyak di dalam plakat tengah tanpa terpotong premature

var _current_chapter: int = 0
var _current_step: int = 0
var _current_chapter_node: Control = null
var _is_waiting_input: bool = false
var _is_transitioning: bool = false
var _last_advance_frame: int = -1

var _current_pages: Array[String] = []
var _current_page_idx: int = 0

var _is_typing: bool = false
var _last_typed_char: int = 0
var _typewriter_tween: Tween = null
var _current_target_label: RichTextLabel = null
var _current_target_hint: Control = null

var _black_screen_container: Control = null
var _black_screen_label: RichTextLabel = null
var _black_screen_hint: Label = null

func _ready() -> void:
	AudioManager.stop_bgm()
	fade_rect.color = Color(0, 0, 0, 0)
	tap_advance_btn.pressed.connect(_on_tap_advanced)
	confirm_btn.pressed.connect(_on_confirm_name_pressed)
	name_input.text_submitted.connect(_on_name_submitted)
	name_input.text_changed.connect(_on_name_text_changed)

	_show_chapter(0)
	_render_current_step()

func _process(_delta: float) -> void:
	if _is_typing and _current_target_label:
		var cur: int = _current_target_label.visible_characters
		if cur > _last_typed_char:
			_last_typed_char = cur
			AudioManager.play_typewriter_blip()

# ─── Visual Bab ───────────────────────────────────────────────────────────────

func _show_chapter(chapter_idx: int) -> void:
	if is_instance_valid(_current_chapter_node):
		_current_chapter_node.queue_free()

	_current_chapter = chapter_idx
	header_label.text = HEADERS[_current_chapter]

	_current_chapter_node = CHAPTER_SCENES[_current_chapter].instantiate() as Control
	chapter_root.add_child(_current_chapter_node)
	_current_chapter_node.modulate.a = 0.0

	var tw := create_tween()
	tw.tween_property(_current_chapter_node, "modulate:a", 1.0, 0.35)

# ─── Animasi Ketik per Ketik (Typewriter) ─────────────────────────────────────

func _start_typewriter(label: RichTextLabel, hint: Control, full_bbcode_text: String) -> void:
	if _typewriter_tween:
		_typewriter_tween.kill()
		_typewriter_tween = null

	_current_target_label = label
	_current_target_hint = hint
	_is_typing = true
	_last_typed_char = 0

	if hint:
		hint.modulate.a = 0.0

	label.text = full_bbcode_text
	label.visible_characters = 0

	# Hitung jumlah karakter teks biasa (tanpa tag bbcode) untuk durasi
	var plain_len: int = label.get_parsed_text().length()
	if plain_len <= 0:
		plain_len = full_bbcode_text.length()
	var duration: float = float(plain_len) * TYPEWRITER_SPEED

	_typewriter_tween = create_tween()
	_typewriter_tween.tween_property(label, "visible_characters", plain_len, duration)
	_typewriter_tween.tween_callback(func():
		_finish_typewriter()
	)

func _finish_typewriter() -> void:
	if _typewriter_tween:
		_typewriter_tween.kill()
		_typewriter_tween = null

	if _current_target_label:
		_current_target_label.visible_characters = -1

	_is_typing = false

	if _current_target_hint and not _is_waiting_input:
		var tw := create_tween()
		tw.tween_property(_current_target_hint, "modulate:a", 1.0, 0.2)

# ─── Render Panel Sesuai Tipe (Narasi / Dialog / Pikiran / Telepon) ────────────

func _render_current_step() -> void:
	if _current_chapter >= SCRIPT_DATA.size():
		_finish_intro()
		return

	var chapter_entries: Array = SCRIPT_DATA[_current_chapter]
	if _current_step >= chapter_entries.size():
		_finish_intro()
		return

	var entry: Dictionary = chapter_entries[_current_step]
	var tipe: String = entry.get("tipe", "narasi")
	var raw_teks: String = entry.get("teks", "")
	var player_name: String = GameState.player_name if GameState.player_name.strip_edges() != "" else "Pemain"

	# Substitusi {nama}
	var processed_teks: String = raw_teks.replace("{nama}", player_name).replace("{Nama}", player_name).replace("{player}", player_name)

	# Cek apakah butuh input nama
	if entry.get("input_nama", false) and (GameState.player_name.strip_edges() == "" or GameState.player_name == "Pemain"):
		_is_waiting_input = true
		input_row.show()
		dialog_hint.hide()
		name_input.text = ""
		name_input.placeholder_text = "Ketik nama karaktermu..."
		name_input.grab_focus.call_deferred()
		confirm_btn.disabled = true
	else:
		_is_waiting_input = false
		input_row.hide()
		dialog_hint.show()

	_ensure_black_screen_node()
	if _black_screen_container:
		_black_screen_container.hide()

	# Ganti background Jakarta sesuai konteks bicara/narasi
	if _current_chapter == 0 and is_instance_valid(_current_chapter_node):
		var bg_rect: TextureRect = _current_chapter_node.get_node_or_null("Background") as TextureRect
		if bg_rect:
			if tipe in ["dialog", "pikiran"]:
				bg_rect.texture = load("res://assets/ui/intro_office_dialog_bg.png")
			else:
				bg_rect.texture = load("res://assets/ui/intro_jakarta_bg.png")

	if entry.get("input_nama", false) and _is_waiting_input:
		_current_pages = [processed_teks]
	else:
		var max_chars: int = MAX_PAGE_CHARS_NARRATION if tipe == "narasi" else (250 if tipe == "layar_hitam" else MAX_PAGE_CHARS)
		_current_pages = _paginate_text(processed_teks, max_chars)

	_current_page_idx = 0
	_show_current_page()

func _show_current_page() -> void:
	if _current_page_idx < 0 or _current_page_idx >= _current_pages.size():
		return

	var page_text: String = _current_pages[_current_page_idx]
	var chapter_entries: Array = SCRIPT_DATA[_current_chapter]
	var entry: Dictionary = chapter_entries[_current_step]
	var tipe: String = entry.get("tipe", "narasi")
	var speaker: String = entry.get("speaker", "")
	var player_name: String = GameState.player_name if GameState.player_name.strip_edges() != "" else "Pemain"

	match tipe:
		"layar_hitam":
			header_banner.hide()
			narration_screen.hide()
			dialogue_container.hide()
			_black_screen_container.show()
			if _black_screen_hint:
				_black_screen_hint.hide()
			_start_typewriter(_black_screen_label, null, "[center][b]%s[/b][/center]" % page_text)

		"narasi":
			# Tampilkan Narasi dalam format plakat terpusat
			header_banner.hide()
			if paper_header:
				paper_header.hide()
				paper_header.text = ""
			dialogue_container.hide()
			narration_screen.show()
			_start_typewriter(narration_text, narration_hint, "[i]%s[/i]" % page_text)

		"dialog":
			header_banner.show()
			narration_screen.hide()
			dialogue_container.show()
			_setup_dialog_speaker(speaker, player_name)
			_start_typewriter(speech_text, dialog_hint, "\"%s\"" % page_text)

		"pikiran":
			header_banner.show()
			narration_screen.hide()
			dialogue_container.show()
			_setup_thought_speaker(speaker, player_name)
			_start_typewriter(speech_text, dialog_hint, "[i]%s[/i]" % page_text)

		"telepon":
			header_banner.show()
			narration_screen.hide()
			dialogue_container.show()
			_setup_phone_speaker(speaker)
			_start_typewriter(speech_text, dialog_hint, "\"%s\"" % page_text)

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
			current_page = ""

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

func _setup_dialog_speaker(speaker: String, player_name: String) -> void:
	match speaker.to_lower():
		"mc", "player", "pemain":
			speaker_label.text = player_name
			portrait.texture = load(PORTRAITS["player_neutral"]) as Texture2D
		"hrd", "manajer":
			speaker_label.text = "HRD"
			portrait.texture = load(PORTRAITS["manajer"]) as Texture2D
		"ibu", "mamak":
			speaker_label.text = "Mamak"
			portrait.texture = load(PORTRAITS["ibu"]) as Texture2D
		_:
			speaker_label.text = speaker.capitalize()
			portrait.texture = load(PORTRAITS["player_neutral"]) as Texture2D

func _setup_thought_speaker(speaker: String, player_name: String) -> void:
	if speaker.to_lower() in ["mc", "player", "pemain"]:
		speaker_label.text = "%s (Batin)" % player_name
		if _current_chapter >= 1:
			portrait.texture = load(PORTRAITS["player_sad"]) as Texture2D
		else:
			portrait.texture = load(PORTRAITS["player_neutral"]) as Texture2D
	else:
		speaker_label.text = speaker.capitalize()
		portrait.texture = load(PORTRAITS["player_neutral"]) as Texture2D

func _setup_phone_speaker(_speaker: String) -> void:
	speaker_label.text = "Bu Mira (Telepon)"
	portrait.texture = load(PORTRAITS["ibu"]) as Texture2D

func _ensure_black_screen_node() -> void:
	if _black_screen_container and is_instance_valid(_black_screen_container):
		return

	_black_screen_container = Control.new()
	_black_screen_container.name = "BlackScreenOverlay"
	_black_screen_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	_black_screen_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_black_screen_container)
	move_child(_black_screen_container, fade_rect.get_index())

	var bg := ColorRect.new()
	bg.name = "BlackBG"
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 1)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_black_screen_container.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_black_screen_container.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	vbox.custom_minimum_size = Vector2(480, 0)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(vbox)

	_black_screen_label = RichTextLabel.new()
	_black_screen_label.name = "BlackScreenText"
	_black_screen_label.bbcode_enabled = true
	_black_screen_label.fit_content = true
	_black_screen_label.scroll_active = false
	_black_screen_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_black_screen_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_black_screen_label.add_theme_color_override("default_color", Color(0.96, 0.96, 0.96, 1.0))
	_black_screen_label.add_theme_font_size_override("normal_font_size", 18)
	_black_screen_label.add_theme_font_size_override("bold_font_size", 18)
	vbox.add_child(_black_screen_label)

	_black_screen_hint = Label.new()
	_black_screen_hint.name = "BlackScreenHint"
	_black_screen_hint.visible = false
	_black_screen_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_black_screen_hint)

# ─── Navigasi & Input ─────────────────────────────────────────────────────────

func _on_tap_advanced() -> void:
	_handle_advance_request()

func _handle_advance_request() -> void:
	if _is_waiting_input or _is_transitioning:
		return

	# Jika masih dalam proses mengetik: ketukan pertama langsung selesaikan teks!
	if _is_typing:
		AudioManager.play_sfx("tap_b")
		_finish_typewriter()
		return

	# Cek apakah masih ada lembar teks lanjutan pada langkah saat ini
	if _current_page_idx < _current_pages.size() - 1:
		_current_page_idx += 1
		AudioManager.play_sfx("tap_b")
		_show_current_page()
		return

	# Jika teks sudah tuntas seluruh halaman: lanjut ke langkah berikutnya
	AudioManager.play_sfx("tap_b")
	_advance_step()

func _advance_step() -> void:
	if _is_waiting_input or _is_transitioning:
		return

	var frame := Engine.get_process_frames()
	if frame == _last_advance_frame:
		return
	_last_advance_frame = frame

	_current_step += 1
	var chapter_entries: Array = SCRIPT_DATA[_current_chapter]
	if _current_step >= chapter_entries.size():
		# Bab saat ini telah selesai
		if _current_chapter + 1 >= SCRIPT_DATA.size():
			_finish_intro()
		else:
			_next_chapter(_current_chapter + 1)
	else:
		_render_current_step()

func _next_chapter(next_ch: int) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	AudioManager.play_sfx("switch_a", -2.0)

	# Fade transisi antar bab
	var tw := create_tween()
	tw.tween_property(fade_rect, "color:a", 1.0, 0.25)
	tw.tween_callback(func():
		_current_chapter = next_ch
		_current_step = 0
		_show_chapter(_current_chapter)
		_render_current_step()
	)
	tw.tween_property(fade_rect, "color:a", 0.0, 0.25)
	tw.tween_callback(func():
		_is_transitioning = false
	)

func _finish_intro() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	tap_advance_btn.disabled = true

	# Simpan nama pemain dan status awal
	GameState.in_world = true
	GameState.world_zone = "hulu"
	var qm = get_node_or_null("/root/QuestManager")
	if qm and qm.has_method("start_main_quest"):
		qm.start_main_quest()
	GameState.save_game()

	# Fade to black lalu pindah ke world
	var tw := create_tween()
	tw.tween_property(fade_rect, "color:a", 1.0, 0.5)
	tw.tween_callback(func():
		SceneManager.go_to_world()
	)

# ─── Input Nama MC ────────────────────────────────────────────────────────────

func _clean_name(raw: String) -> String:
	return raw.replace("[", "").replace("]", "").strip_edges()

func _on_name_text_changed(new_text: String) -> void:
	var clean := _clean_name(new_text)
	confirm_btn.disabled = clean.length() == 0

func _on_name_submitted(new_text: String) -> void:
	var clean := _clean_name(new_text)
	if clean.length() > 0:
		_save_and_confirm_name(clean)

func _on_confirm_name_pressed() -> void:
	var clean := _clean_name(name_input.text)
	if clean.length() > 0:
		_save_and_confirm_name(clean)

func _save_and_confirm_name(clean_name: String) -> void:
	var final_name := clean_name if clean_name.length() > 0 else "Rian"
	GameState.player_name = final_name
	_is_waiting_input = false
	input_row.hide()
	dialog_hint.show()
	_advance_step()

func _unhandled_input(event: InputEvent) -> void:
	if _is_waiting_input or _is_transitioning:
		return
	if event.is_action_pressed("ui_accept"):
		_handle_advance_request()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_advance_request()
		get_viewport().set_input_as_handled()
