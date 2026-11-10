## Intro Dramatic Script — Format Komik Naratif & Panel Dialog
## Menyajikan Bab 1 s/d Bab 3 dengan pemisahan tegas antara Narasi Full Layar,
## Balon Dialog, dan Monolog Pikiran MC dengan Animasi Ketik per Ketik (Typewriter).
extends Control

const CHAPTER_SCENES: Array = [
	preload("res://scenes/intro/chapter_1_jakarta.tscn"),
	preload("res://scenes/intro/chapter_2_phk.tscn"),
	preload("res://scenes/intro/chapter_3_medan.tscn"),
]

const HEADERS: Array = [
	"BAB 1 · JAKARTA — HARI PERTAMA KERJA",
	"BAB 2 · JAKARTA — PHK",
	"BAB 3 · MEDAN — TEPI SUNGAI DELI",
]

const PORTRAITS: Dictionary = {
	"player_neutral": "res://assets/sprites/portraits/player_neutral.png",
	"player_sad": "res://assets/sprites/portraits/player_sad.png",
	"manajer": "res://assets/sprites/portraits/pakrt_neutral.png",
	"ibu": "res://assets/sprites/portraits/ibu_neutral.png",
}

# ─── Naskah Perbaikan Bab 1, 2, 3 Sesuai Kontrak Dokumen Utama ───────────────
const SCRIPT_DATA: Array = [
	# Bab 1 · Jakarta, Hari Pertama Kerja
	[
		{
			"tipe": "narasi",
			"teks": "Lantai dua puluh dua. Pagi itu kaca gedung memantulkan langit sebersih kertas baru, dan kopi di mejaku masih mengepul."
		},
		{
			"tipe": "dialog",
			"speaker": "manajer",
			"teks": "Selamat datang. Isi formulir ini dulu untuk data HRD. Nama lengkap, jangan disingkat.",
			"input_nama": true
		},
		{
			"tipe": "dialog",
			"speaker": "manajer",
			"teks": "{nama}. Oke. Kontrak satu tahun. Jangan buat saya menyesal."
		},
		{
			"tipe": "pikiran",
			"speaker": "mc",
			"teks": "Gaji pertama sudah kuhitung di kepala. Separuhnya untuk Medan, untuk atap warung yang bocor tiap hujan."
		},
		{
			"tipe": "pikiran",
			"speaker": "mc",
			"teks": "Bapak selalu bilang atap itu urusan sebelum hujan, bukan sesudahnya. Aku tersenyum. Sebelum hujan, ada waktu."
		}
	],
	# Bab 2 · Jakarta, PHK
	[
		{
			"tipe": "narasi",
			"teks": "Sebelas bulan kemudian, hujan mengetuk kaca seperti orang yang tak sabar. Separuh meja di lantai ini sudah kosong. Yang tersisa hanya bekas debu berbentuk kotak."
		},
		{
			"tipe": "dialog",
			"speaker": "manajer",
			"teks": "Duduk dulu, {nama}. Perusahaan sedang efisiensi. Kontrakmu tidak diperpanjang. Saya minta maaf."
		},
		{
			"tipe": "narasi",
			"teks": "Selembar surat, dua paragraf. Sebelas bulanku muat di sana, dan masih menyisakan ruang kosong."
		},
		{
			"tipe": "dialog",
			"speaker": "mc",
			"teks": "Baik, Pak. Terima kasih."
		},
		{
			"tipe": "pikiran",
			"speaker": "mc",
			"teks": "Terima kasih. Kata yang paling sopan untuk sesuatu yang sebenarnya tak ingin kuucapkan."
		},
		{
			"tipe": "narasi",
			"teks": "Saat kardus itu penuh, ponselku bergetar di atas meja. Di layar: Mak."
		},
		{
			"tipe": "telepon",
			"speaker": "ibu",
			"teks": "Nak… sungai naik. Bapakmu lagi angkat kursi ke atas meja. Kau tak usah pulang, kerja sajalah di sana... Eh. Pulang lah, kalau sempat."
		},
		{
			"tipe": "dialog",
			"speaker": "mc",
			"teks": "Mak? Mak…"
		},
		{
			"tipe": "pikiran",
			"speaker": "mc",
			"teks": "Sambungan putus. Hujan di Jakarta dan hujan di Medan. Aku tak tahu itu hujan yang sama atau bukan, tapi malam itu aku membeli tiket."
		}
	],
	# Bab 3 · Medan, Kembali ke Warung
	[
		{
			"tipe": "narasi",
			"teks": "Medan, dua hari kemudian. Deli sudah surut, tetapi surut bukan berarti pergi. Ia meninggalkan jejaknya setinggi dada di dinding setiap rumah."
		},
		{
			"tipe": "narasi",
			"teks": "Warung kami berdiri miring di bantaran, seperti orang yang menahan tangis. Garis lumpur melintang di dindingnya, lurus dan tak bisa dibantah. Kursi-kursi telentang. Toples gula entah di mana."
		},
		{
			"tipe": "pikiran",
			"speaker": "mc",
			"teks": "Dulu pukul lima pagi di sini ada bunyi sendok beradu gelas. Sekarang hanya air yang menetes dari atap."
		},
		{
			"tipe": "narasi",
			"teks": "Di tepi sungai, sampah menumpuk setinggi pinggang: kasur, kantong plastik, botol, dan sepasang sandal yang masih berpasangan. Air telah mencari jalannya, dan jalan itu sudah diambil."
		},
		{
			"tipe": "pikiran",
			"speaker": "mc",
			"teks": "Sebanyak ini. Sejak kapan ia menumpuk? Dan kenapa aku tak pernah melihatnya?"
		}
	]
]

# ─── Referensi Node ──────────────────────────────────────────────────────────
@onready var chapter_root: Control = $ChapterRoot
@onready var tap_advance_btn: Button = $TapAdvanceBtn
@onready var header_label: Label = $HeaderBanner/HeaderLabel
@onready var narration_screen: Control = $NarrationScreen
@onready var narration_text: RichTextLabel = $NarrationScreen/CenterBox/NarrationCard/VBox/NarrationText
@onready var narration_hint: Label = $NarrationScreen/CenterBox/NarrationCard/VBox/HintRow/NarrationHint
@onready var dialogue_container: Control = $DialogueContainer
@onready var dialog_panel: PanelContainer = $DialogueContainer/DialogPanel
@onready var speaker_tag: PanelContainer = $DialogueContainer/DialogPanel/VBox/SpeakerRow/SpeakerTag
@onready var speaker_label: Label = $DialogueContainer/DialogPanel/VBox/SpeakerRow/SpeakerTag/SpeakerLabel
@onready var portrait: TextureRect = $DialogueContainer/DialogPanel/VBox/BodyHBox/PortraitFrame/Portrait
@onready var speech_text: RichTextLabel = $DialogueContainer/DialogPanel/VBox/BodyHBox/ContentVBox/SpeechText
@onready var input_row: HBoxContainer = $DialogueContainer/DialogPanel/VBox/BodyHBox/ContentVBox/InputRow
@onready var name_input: LineEdit = $DialogueContainer/DialogPanel/VBox/BodyHBox/ContentVBox/InputRow/NameInput
@onready var confirm_btn: Button = $DialogueContainer/DialogPanel/VBox/BodyHBox/ContentVBox/InputRow/ConfirmBtn
@onready var dialog_hint_row: HBoxContainer = $DialogueContainer/DialogPanel/VBox/BodyHBox/ContentVBox/DialogHintRow
@onready var dialog_hint: Label = $DialogueContainer/DialogPanel/VBox/BodyHBox/ContentVBox/DialogHintRow/DialogHint
@onready var fade_rect: ColorRect = $FadeRect

const TYPEWRITER_SPEED: float = 0.028  # Kecepatan ketik (detik per karakter)

var _current_chapter: int = 0
var _current_step: int = 0
var _current_chapter_node: Control = null
var _is_waiting_input: bool = false
var _is_transitioning: bool = false
var _last_advance_frame: int = -1

var _is_typing: bool = false
var _typewriter_tween: Tween = null
var _current_target_label: RichTextLabel = null
var _current_target_hint: Control = null

func _ready() -> void:
	fade_rect.color = Color(0, 0, 0, 0)
	tap_advance_btn.pressed.connect(_on_tap_advanced)
	confirm_btn.pressed.connect(_on_confirm_name_pressed)
	name_input.text_submitted.connect(_on_name_submitted)
	name_input.text_changed.connect(_on_name_text_changed)

	_show_chapter(0)
	_render_current_step()

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
	var speaker: String = entry.get("speaker", "")
	var player_name: String = GameState.player_name if GameState.player_name.strip_edges() != "" else "Pemain"

	# Substitusi {nama}
	var processed_teks: String = raw_teks.replace("{nama}", player_name)

	# Cek apakah butuh input nama
	if entry.get("input_nama", false) and (GameState.player_name.strip_edges() == "" or GameState.player_name == "Pemain"):
		_is_waiting_input = true
		input_row.show()
		dialog_hint_row.hide()
		name_input.text = ""
		name_input.placeholder_text = "Ketik nama karaktermu..."
		name_input.grab_focus.call_deferred()
		confirm_btn.disabled = true
	else:
		_is_waiting_input = false
		input_row.hide()
		dialog_hint_row.show()

	match tipe:
		"narasi":
			# Tampilkan Narasi Full Layar dengan Card Elegan
			dialogue_container.hide()
			narration_screen.show()
			_start_typewriter(narration_text, narration_hint, "[i]%s[/i]" % processed_teks)

		"dialog":
			narration_screen.hide()
			dialogue_container.show()
			_setup_dialog_speaker(speaker, player_name)
			_start_typewriter(speech_text, dialog_hint, "\"%s\"" % processed_teks)

		"pikiran":
			narration_screen.hide()
			dialogue_container.show()
			_setup_thought_speaker(speaker, player_name)
			_start_typewriter(speech_text, dialog_hint, "[i]%s[/i]" % processed_teks)

		"telepon":
			narration_screen.hide()
			dialogue_container.show()
			_setup_phone_speaker(speaker)
			_start_typewriter(speech_text, dialog_hint, "\"%s\"" % processed_teks)

func _setup_dialog_speaker(speaker: String, player_name: String) -> void:
	match speaker:
		"mc":
			speaker_label.text = player_name
			portrait.texture = load(PORTRAITS["player_neutral"]) as Texture2D
		"manajer":
			speaker_label.text = "Manajer"
			portrait.texture = load(PORTRAITS["manajer"]) as Texture2D
		"ibu":
			speaker_label.text = "Bu Mira"
			portrait.texture = load(PORTRAITS["ibu"]) as Texture2D
		_:
			speaker_label.text = speaker.capitalize()
			portrait.texture = load(PORTRAITS["player_neutral"]) as Texture2D

func _setup_thought_speaker(speaker: String, player_name: String) -> void:
	if speaker == "mc":
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

# ─── Navigasi & Input ─────────────────────────────────────────────────────────

func _on_tap_advanced() -> void:
	_handle_advance_request()

func _handle_advance_request() -> void:
	if _is_waiting_input or _is_transitioning:
		return

	# Jika masih dalam proses mengetik: ketukan pertama langsung selesaikan teks!
	if _is_typing:
		_finish_typewriter()
		return

	# Jika teks sudah selesai: lanjut ke langkah berikutnya
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
	dialog_hint_row.show()
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
