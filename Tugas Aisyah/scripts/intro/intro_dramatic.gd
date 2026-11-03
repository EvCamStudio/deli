## Intro Dramatic Script
# 3 bab dengan scene visual berbeda:
#   Bab 1 — Kantor Jakarta (hari pertama kerja, input nama)
#   Bab 2 — PHK (kantor malam, hujan)
#   Bab 3 — Kembali ke Medan (rumah orang tua, banjir)
extends Control

const CHAPTER_SCENES: Array = [
	preload("res://scenes/intro/chapter_1_jakarta.tscn"),
	preload("res://scenes/intro/chapter_2_phk.tscn"),
	preload("res://scenes/intro/chapter_3_medan.tscn"),
]

const HEADERS: Array = [
	"BAB 1 · JAKARTA — HARI PERTAMA KERJA",
	"BAB 2 · JAKARTA — PHK",
	"BAB 3 · MEDAN — KEMBALI KE WARUNG",
	"PERJALANAN DIMULAI",
]

const PORTRAITS: Array = [
	"res://assets/sprites/portraits/player_neutral.png",
	"res://assets/sprites/portraits/player_sad.png",
	"res://assets/sprites/portraits/ibu_neutral.png",
	"res://assets/sprites/portraits/player_neutral.png",
]

@onready var chapter_root: Control = $ChapterRoot
@onready var dialogue_box: RichTextLabel = $MarginContainer/VBox/StoryPanel/VBox/HBox/DialogueBox
@onready var portrait: TextureRect = $MarginContainer/VBox/StoryPanel/VBox/HBox/PortraitFrame/Portrait
@onready var name_input: LineEdit = $MarginContainer/VBox/StoryPanel/VBox/ActionRow/NameInput
@onready var next_btn: Button = $MarginContainer/VBox/StoryPanel/VBox/ActionRow/NextBtn
@onready var fade_rect: ColorRect = $FadeRect

var stage: int = 0  # 0=Bab 1, 1=Bab 2, 2=Bab 3, 3=Penutup
var _leaving: bool = false
var _current_chapter: int = -1
var _chapter_node: Control = null
var _last_advance_frame: int = -1

func _ready() -> void:
	name_input.hide()
	next_btn.hide()
	fade_rect.color = Color(0, 0, 0, 0)

	name_input.text_changed.connect(_on_name_changed)
	name_input.text_submitted.connect(_on_name_submitted)
	next_btn.pressed.connect(_advance)

	_update_stage()

# ─── Visual per bab ───────────────────────────────────────────────────────────

func _show_chapter(index: int) -> void:
	if _current_chapter == index:
		return
	_current_chapter = index
	if is_instance_valid(_chapter_node):
		_chapter_node.queue_free()
	_chapter_node = CHAPTER_SCENES[index].instantiate() as Control
	chapter_root.add_child(_chapter_node)
	_chapter_node.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_chapter_node, "modulate:a", 1.0, 0.35)

# ─── Isi tiap bab ─────────────────────────────────────────────────────────────

func _update_stage() -> void:
	var name_text: String = _clean_name(GameState.player_name) if GameState.player_name != "" else "Pemain"
	portrait.texture = load(PORTRAITS[stage]) as Texture2D
	_show_chapter(mini(stage, 2))

	match stage:
		0:
			dialogue_box.text = _heading(0) + "\n\nHari pertama kerja di gedung kantor. Pagi cerah, kopi masih hangat.\n[i]\"Saya tidak tahu bahwa hari pertama ini akan menjadi hari terakhir saya bekerja.\"[/i]\n[b]Manajer:[/b] \"Halo, anak baru. Siapa namamu? Kita perlu nama lengkap untuk catatan perusahaan.\""
			name_input.show()
			name_input.text = GameState.player_name
			name_input.caret_column = name_input.text.length()
			name_input.grab_focus.call_deferred()
			next_btn.text = "Konfirmasi Nama"
			next_btn.visible = GameState.player_name.strip_edges().length() > 0
		1:
			name_input.hide()
			next_btn.show()
			next_btn.text = "Lanjut ke Medan"
			dialogue_box.text = _heading(1) + "\n\nBeberapa bulan kemudian. Kantor kosong, lampu mati, hujan deras di luar jendela. Surat PHK tergeletak di meja.\n[i]\"%s… kamu sudah berusaha. Jakarta tidak lagi punya tempat untukmu. Aku pulang, bukan karena kalah — tapi demi keluarga.\"[/i]" % name_text
		2:
			name_input.hide()
			next_btn.show()
			next_btn.text = "Mulai Perjalanan"
			dialogue_box.text = _heading(2) + "\n\nRumah orang tua di tepi Sungai Deli. Lumpur banjir masih menempel di dinding warung.\n[b]Bu Mira:[/b] \"%s… sungai terlalu kotor. Banjir merusak warung kita. Kita terpaksa berutang.\"\n[b]%s:[/b] \"Aku akan bantu, Bu. Memulihkan warung dan membersihkan sungai.\"" % [name_text, name_text]
		3:
			name_input.hide()
			next_btn.show()
			next_btn.text = "Masuk ke Sungai Deli"
			dialogue_box.text = _heading(3) + "\n\nSungai Deli menunggu bantuanmu, [b]%s[/b].\nBersihkan sampah, pulihkan warung, lunasi utang, dan bawa sungai ini kembali jernih." % name_text

## Judul bab bergaya heading di dalam panel cerita.
func _heading(index: int) -> String:
	return "[font_size=16][b][color=#8a5a2e]%s[/color][/b][/font_size]" % HEADERS[index]

# ─── Input nama ───────────────────────────────────────────────────────────────

## Bersihkan nama: buang spasi tepi dan karakter kurung agar tidak merusak BBCode.
func _clean_name(raw: String) -> String:
	return raw.replace("[", "").replace("]", "").strip_edges()

func _on_name_changed(new_text: String) -> void:
	var clean_name := _clean_name(new_text)
	GameState.player_name = clean_name
	if stage == 0:
		next_btn.visible = clean_name.length() > 0

func _on_name_submitted(new_text: String) -> void:
	var clean_name := _clean_name(new_text)
	if clean_name.length() > 0:
		GameState.player_name = clean_name
		_advance()

# ─── Navigasi bab ─────────────────────────────────────────────────────────────

func _advance() -> void:
	if _leaving:
		return
	if stage == 0 and GameState.player_name.strip_edges().length() == 0:
		return
	# Cegah dua kali lanjut dalam satu frame (tombol + keyboard)
	var frame := Engine.get_process_frames()
	if frame == _last_advance_frame:
		return
	_last_advance_frame = frame

	stage += 1
	if stage > 3:
		_fade_and_go()
	else:
		_update_stage()

func _fade_and_go() -> void:
	if _leaving:
		return
	_leaving = true
	next_btn.disabled = true
	name_input.editable = false
	GameState.save_game()
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.6)
	tween.tween_callback(func():
		SceneManager.change_level(1)
	)

func _unhandled_input(event: InputEvent) -> void:
	# Enter/Space melanjutkan bab (kecuali saat mengetik nama)
	if _leaving or stage == 0:
		return
	if event.is_action_pressed("ui_accept"):
		_advance()
		get_viewport().set_input_as_handled()
