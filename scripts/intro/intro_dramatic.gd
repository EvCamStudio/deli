## Intro Dramatic Script
# Alur: Bab 1 (Jakarta, Manajer tanya nama) → Bab 2 (PHK) → Bab 3 (Reunion Medan)
extends Control

@onready var dialogue_box: RichTextLabel = $MarginContainer/VBox/DialogueBox
@onready var name_input: LineEdit = $MarginContainer/VBox/NameInput
@onready var next_btn: Button = $MarginContainer/VBox/NextBtn
@onready var fade_rect: ColorRect = $FadeRect

var stage: int = 0  # 0=Bab 1 Jakarta, 1=Bab 2 PHK, 2=Bab 3 Reunion Medan, 3=Penutup
var _leaving: bool = false

func _ready() -> void:
	name_input.hide()
	next_btn.hide()
	fade_rect.color = Color(0, 0, 0, 0)
	
	name_input.text_changed.connect(_on_name_changed)
	name_input.text_submitted.connect(_on_name_submitted)
	next_btn.pressed.connect(_advance)
	
	_update_stage()

func _update_stage() -> void:
	var name_text: String = GameState.player_name if GameState.player_name != "" else "Pemain"
	
	match stage:
		0:
			dialogue_box.text = "[b]BAB 1 — JAKARTA[/b]\n\nRuang kantor modern. Pagi cerah tapi tegang.\n\n[i]\"Saya tidak tahu bahwa hari pertama bekerja akan menjadi hari terakhir saya...\"[/i]\n\n[b]Manajer[/b]: \"Halo, anak baru. Siapa namamu? Kita butuh nama lengkap untuk catatan perusahaan.\""
			name_input.show()
			name_input.text = GameState.player_name
			name_input.caret_column = name_input.text.length()
			name_input.grab_focus.call_deferred()
			next_btn.text = "Konfirmasi Nama →"
			next_btn.visible = GameState.player_name.strip_edges().length() > 0
		1:
			name_input.hide()
			next_btn.show()
			next_btn.text = "Lanjut ke Medan →"
			dialogue_box.text = "[b]BAB 2 — PHK[/b]\n\nBeberapa bulan kemudian. Surat PHK diterima. Ruang kantor kosong dan gelap, hujan deras di luar jendela.\n\n[i]\"%s… kamu sudah berusaha. Tapi Jakarta tidak lagi punya tempat untukmu. Aku pulang, bukan karena kalah, tapi demi keluarga.\"[/i]" % name_text
		2:
			name_input.hide()
			next_btn.show()
			next_btn.text = "Mulai Perjalanan →"
			dialogue_box.text = "[b]BAB 3 — KEMBALI KE MEDAN[/b]\n\nRumah orang tua, tepi Sungai Deli. Bekas lumpur banjir masih menempel di dinding warung.\n\n[b]Bu Mira[/b]: \"%s… kamu sudah pulang. Sungai sudah terlalu kotor. Banjir merusak warung kita. Kita terpaksa berutang.\"\n\n[b]%s[/b]: \"Aku tahu, Bu. Aku akan bantu memulihkan warung dan membersihkan sungai ini.\"" % [name_text, name_text]
		3:
			name_input.hide()
			next_btn.show()
			next_btn.text = "Masuk ke Sungai Deli →"
			dialogue_box.text = "[b]PETUALANGAN DIMULAI[/b]\n\nSungai Deli membutuhkan bantuanmu, [b]%s[/b].\n\nBersihkan sampah, pulihkan warung keluarga, dan lunasi utang!" % name_text

func _on_name_changed(new_text: String) -> void:
	var clean_name := new_text.strip_edges()
	GameState.player_name = clean_name
	if stage == 0:
		next_btn.visible = clean_name.length() > 0

func _on_name_submitted(new_text: String) -> void:
	var clean_name := new_text.strip_edges()
	if clean_name.length() > 0:
		GameState.player_name = clean_name
		_advance()

func _advance() -> void:
	if _leaving:
		return
	if stage == 0 and GameState.player_name.strip_edges().length() == 0:
		return
	
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
	# Lanjut dengan Enter/Space setelah Bab 1 (saat LineEdit tidak aktif)
	if _leaving or stage == 0:
		return
	if event.is_action_pressed("ui_accept"):
		_advance()
		get_viewport().set_input_as_handled()
