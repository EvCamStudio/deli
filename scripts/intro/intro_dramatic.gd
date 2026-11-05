## Intro Dramatic Script — Format Komik Naratif & Panel Dialog
## Menyajikan Bab 1 s/d Bab 3 dengan pemisahan tegas antara Narasi (Caption),
## Balon Dialog, dan Monolog Pikiran MC.
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
	# Bab 1: Jakarta, hari pertama kerja
	[
		{
			"tipe": "narasi",
			"teks": "Pagi di Jakarta. Gedung PT Cahaya Nusantara menjulang di antara kemacetan. Kemeja baru, kopi masih hangat."
		},
		{
			"tipe": "pikiran",
			"speaker": "mc",
			"teks": "Akhirnya kerja tetap. Gaji pertama kukirim ke rumah."
		},
		{
			"tipe": "dialog",
			"speaker": "manajer",
			"teks": "Halo, anak baru. Siapa namamu? Kita perlu nama lengkap untuk catatan perusahaan.",
			"input_nama": true
		},
		{
			"tipe": "dialog",
			"speaker": "mc",
			"teks": "{nama}, Pak. Mohon bimbingannya."
		},
		{
			"tipe": "dialog",
			"speaker": "manajer",
			"teks": "Selamat bergabung, {nama}. Di sini kita seperti keluarga."
		},
		{
			"tipe": "telepon",
			"speaker": "ibu",
			"teks": "Selamat ya, Nak, kerja barumu. Warung sehat, sungai tenang. Jangan lupa makan."
		}
	],
	# Bab 2: Jakarta, beberapa bulan kemudian
	[
		{
			"tipe": "narasi",
			"teks": "Beberapa bulan kemudian. Hujan deras mengguyur Jakarta, dan separuh meja kantor sudah kosong."
		},
		{
			"tipe": "dialog",
			"speaker": "manajer",
			"teks": "{nama}, perusahaan sedang efisiensi. Kontrakmu tidak bisa dilanjutkan. Maaf."
		},
		{
			"tipe": "narasi",
			"teks": "Surat PHK tergeletak di meja."
		},
		{
			"tipe": "dialog",
			"speaker": "mc",
			"teks": "Saya mengerti, Pak. Terima kasih sudah memberi kesempatan."
		},
		{
			"tipe": "pikiran",
			"speaker": "mc",
			"teks": "Jakarta tidak lagi punya tempat untukku. Aku pulang, bukan karena kalah, tapi demi keluarga."
		},
		{
			"tipe": "telepon",
			"speaker": "ibu",
			"teks": "Nak, hujan di sini deras sekali dan sungai naik. Pulanglah, ibu dan bapak butuh kau."
		}
	],
	# Bab 3: Medan
	[
		{
			"tipe": "narasi",
			"teks": "Medan, dua hari kemudian. Sungai Deli sudah surut, tapi meninggalkan lumpur dan sampah di sepanjang tebing."
		},
		{
			"tipe": "narasi",
			"teks": "Warung keluarga di bantaran sungai: dinding berlumpur, kursi terbalik, kopi hanyut entah ke mana."
		},
		{
			"tipe": "pikiran",
			"speaker": "mc",
			"teks": "Warung yang dulu penuh tawa. Sekarang..."
		},
		{
			"tipe": "narasi",
			"teks": "Di tepi sungai, gunungan sampah menyumbat aliran: kasur bekas, plastik, botol."
		},
		{
			"tipe": "pikiran",
			"speaker": "mc",
			"teks": "Jadi ini yang membuat air tak punya jalan."
		}
	]
]

# ─── Referensi Node ──────────────────────────────────────────────────────────
@onready var chapter_root: Control = $ChapterRoot
@onready var tap_advance_btn: Button = $TapAdvanceBtn
@onready var header_label: Label = $HeaderBanner/HeaderLabel
@onready var caption_box: PanelContainer = $CaptionBox
@onready var caption_text: RichTextLabel = $CaptionBox/VBox/CaptionText
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
@onready var fade_rect: ColorRect = $FadeRect

var _current_chapter: int = 0
var _current_step: int = 0
var _current_chapter_node: Control = null
var _is_waiting_input: bool = false
var _is_transitioning: bool = false
var _last_advance_frame: int = -1

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
	tw.tween_property(_current_chapter_node, "modulate:a", 1.0, 0.4)

# ─── Render Panel Sesuai Tipe (Narasi / Dialog / Pikiran / Telepon) ────────────

func _render_current_step() -> void:
	if _current_chapter >= SCRIPT_DATA.size():
		_finish_intro()
		return

	var chapter_entries: Array = SCRIPT_DATA[_current_chapter]
	if _current_step >= chapter_entries.size():
		_next_chapter()
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
			# Sembunyikan Balon Dialog, Tampilkan Caption Box di atas/tengah
			dialogue_container.hide()
			caption_box.show()
			caption_text.text = "[i]%s[/i]" % processed_teks

		"dialog":
			caption_box.hide()
			dialogue_container.show()
			speech_text.text = processed_teks
			_setup_dialog_speaker(speaker, player_name, false)

		"pikiran":
			caption_box.hide()
			dialogue_container.show()
			speech_text.text = "[i]\"%s\"[/i]" % processed_teks
			_setup_thought_speaker(speaker, player_name)

		"telepon":
			caption_box.hide()
			dialogue_container.show()
			speech_text.text = processed_teks
			_setup_phone_speaker(speaker)

func _setup_dialog_speaker(speaker: String, player_name: String, _is_thought: bool) -> void:
	match speaker:
		"mc":
			speaker_label.text = player_name
			portrait.texture = load(PORTRAITS["player_neutral"]) as Texture2D
		"manajer":
			speaker_label.text = "Manajer PT Cahaya Nusantara"
			portrait.texture = load(PORTRAITS["manajer"]) as Texture2D
		"ibu":
			speaker_label.text = "Bu Mira"
			portrait.texture = load(PORTRAITS["ibu"]) as Texture2D
		_:
			speaker_label.text = speaker.capitalize()
			portrait.texture = load(PORTRAITS["player_neutral"]) as Texture2D

func _setup_thought_speaker(speaker: String, player_name: String) -> void:
	if speaker == "mc":
		speaker_label.text = "💭 %s (Dalam Hati)" % player_name
		# Di Bab 2 dan 3 gunakan potret sedih untuk memperkuat emosi PHK & banjir
		if _current_chapter >= 1:
			portrait.texture = load(PORTRAITS["player_sad"]) as Texture2D
		else:
			portrait.texture = load(PORTRAITS["player_neutral"]) as Texture2D
	else:
		speaker_label.text = "💭 %s" % speaker.capitalize()
		portrait.texture = load(PORTRAITS["player_neutral"]) as Texture2D

func _setup_phone_speaker(_speaker: String) -> void:
	speaker_label.text = "📞 Bu Mira (Panggilan Telepon)"
	portrait.texture = load(PORTRAITS["ibu"]) as Texture2D

# ─── Navigasi & Input ─────────────────────────────────────────────────────────

func _on_tap_advanced() -> void:
	if _is_waiting_input or _is_transitioning:
		return
	_advance_step()

func _advance_step() -> void:
	var frame := Engine.get_process_frames()
	if frame == _last_advance_frame:
		return
	_last_advance_frame = frame

	_current_step += 1
	_render_current_step()

func _next_chapter() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true

	var next_ch := _current_chapter + 1
	if next_ch >= SCRIPT_DATA.size():
		_finish_intro()
		return

	# Fade transisi antar bab
	var tw := create_tween()
	tw.tween_property(fade_rect, "color:a", 1.0, 0.3)
	tw.tween_callback(func():
		_current_step = 0
		_show_chapter(next_ch)
		_render_current_step()
	)
	tw.tween_property(fade_rect, "color:a", 0.0, 0.3)
	tw.tween_callback(func():
		_is_transitioning = false
	)

func _finish_intro() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true

	# Pastikan data tersimpan
	GameState.save_game()

	var tw := create_tween()
	tw.tween_property(fade_rect, "color:a", 1.0, 0.7)
	tw.tween_callback(func():
		# Transisi langsung ke Peta A (Warung) Hari 1
		SceneManager.change_scene("res://scenes/maps/map_a_warung.tscn")
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
	GameState.player_name = clean_name
	_is_waiting_input = false
	input_row.hide()
	dialog_hint_row.show()
	_advance_step()

func _unhandled_input(event: InputEvent) -> void:
	if _is_waiting_input or _is_transitioning:
		return
	if event.is_action_pressed("ui_accept"):
		_advance_step()
		get_viewport().set_input_as_handled()
