## PantunMinigame Script (Orang 2: Dialog & NPC)
## Mini-game sambung pantun kearifan lokal Melayu Deli (Hari 7 Pagi).
## Membaca data dari res://data/pantun_data.json.
## Jawaban benar menurunkan Meter Bencana 2 poin.
extends CanvasLayer
class_name PantunMinigame

signal pantun_selesai(benar: int, total: int)

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var panel: PanelContainer = $Panel
@onready var instruction_label: Label = $Panel/VBox/InstructionLabel
@onready var line1_label: RichTextLabel = $Panel/VBox/Line1Label
@onready var choices_container: HBoxContainer = $Panel/VBox/ChoicesContainer
@onready var feedback_label: Label = $Panel/VBox/FeedbackLabel

var _pantun_list: Array = []
var _current_index: int = 0
var _correct_count: int = 0
var _is_active: bool = false

func _ready() -> void:
	panel.hide()
	_load_pantun_data()

func _load_pantun_data() -> void:
	var path := "res://data/pantun_data.json"
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file:
			var json := JSON.new()
			if json.parse(file.get_as_text()) == OK:
				_pantun_list = json.get_data()
			file.close()

func start_minigame() -> void:
	if _pantun_list.is_empty():
		_load_pantun_data()
	_current_index = 0
	_correct_count = 0
	_is_active = true
	panel.show()
	_show_pantun(_current_index)

func _show_pantun(index: int) -> void:
	if index >= _pantun_list.size():
		_complete()
		return

	var data: Dictionary = _pantun_list[index]
	var tokoh: String = str(data.get("tokoh", "Datuk Sampan"))
	var tema: String = str(data.get("tema", "Sungai Deli"))
	instruction_label.text = "Festival Pantun Deli — Bersama %s (%s)" % [tokoh, tema]

	var sampiran: Array = data.get("sampiran", [])
	line1_label.text = "[center][i]\"%s\n%s\"[/i][/center]" % [
		sampiran[0] if sampiran.size() > 0 else "",
		sampiran[1] if sampiran.size() > 1 else ""
	]
	feedback_label.text = ""

	for child in choices_container.get_children():
		child.queue_free()

	var pilihan: Array = data.get("pilihan", [])
	for i in range(pilihan.size()):
		var opt: Dictionary = pilihan[i]
		var btn := Button.new()
		var isi_lines: Array = opt.get("isi", [])
		btn.text = "%s\n%s" % [
			isi_lines[0] if isi_lines.size() > 0 else "",
			isi_lines[1] if isi_lines.size() > 1 else ""
		]
		btn.custom_minimum_size = Vector2(240, 60)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD
		btn.add_theme_font_size_override("font_size", 11)
		var is_benar: bool = bool(opt.get("benar", false))
		var delta_m: float = float(opt.get("delta_meter", -2.0))
		btn.pressed.connect(func(): _on_choice(is_benar, delta_m))
		choices_container.add_child(btn)

func _on_choice(is_benar: bool, delta_meter: float) -> void:
	if is_benar:
		_correct_count += 1
		feedback_label.text = "✓ Tepat! Sajak yang indah dan sarat pesan (Meter Bencana -2)."
		if GameState.has_method("ubah_meter"):
			GameState.ubah_meter(delta_meter)
		if AudioManager:
			AudioManager.play_sfx("correct")
		await get_tree().create_timer(1.2).timeout
		_current_index += 1
		_show_pantun(_current_index)
	else:
		feedback_label.text = "✗ Maknanya belum pas dengan kearifan menjaga sungai. Coba telaah lagi."
		if AudioManager:
			AudioManager.play_sfx("wrong")

func _complete() -> void:
	_is_active = false
	panel.hide()
	pantun_selesai.emit(_correct_count, _pantun_list.size())
	
	# Selesai minigame: Datuk memberikan petuah penutup
	DialogueManager.mulai("h7_pantun")
