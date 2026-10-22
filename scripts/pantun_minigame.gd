## PantunMinigame Script
# Mini-game pantun: pemain memilih baris yang bersajak dengan baris pertama.
# Tap tombol yang benar untuk membuka gerbang.
extends CanvasLayer
class_name PantunMinigame

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var panel: PanelContainer = $Panel
@onready var instruction_label: Label = $Panel/VBox/InstructionLabel
@onready var line1_label: RichTextLabel = $Panel/VBox/Line1Label
@onready var choices_container: HBoxContainer = $Panel/VBox/ChoicesContainer
@onready var feedback_label: Label = $Panel/VBox/FeedbackLabel

# ─── Data Pantun ──────────────────────────────────────────────────────────────
# Format: { "line1": "...", "correct": 1 (index 0-based), "options": ["...", "...", "..."] }
const PANTUN_DATA: Array = [
	{
		"line1": "Ke pasar membeli ikan,\nIkan bawal bukan cupang.",
		"options": [
			"Mari kita jaga sungai bersama-sama,\nAgar anak cucu turut senang.",
			"Pergi ke hutan cari kayu,\nKayu jati bukan sembarang.",
			"Naik perahu ke tengah danau,\nHati senang tiada terbilang."
		],
		"correct": 0
	},
	{
		"line1": "Bunga raya di tepi sungai,\nHarum semerbak ke udara.",
		"options": [
			"Jangan kita buang sampah di sini,\nSungai bersih milik semua.",
			"Pergi ke kota membeli baju,\nBaju merah warna permata.",
			"Burung terbang melintas sawah,\nPetani gembira kerja."
		],
		"correct": 0
	}
]

var _current_pantun_index: int = 0
var _attempts: int = 0
var _is_active: bool = false

func _ready() -> void:
	panel.hide()

func start_minigame() -> void:
	_current_pantun_index = 0
	_attempts = 0
	_is_active = true
	_show_pantun(_current_pantun_index)
	panel.show()

func _show_pantun(index: int) -> void:
	if index >= PANTUN_DATA.size():
		_complete()
		return

	var data: Dictionary = PANTUN_DATA[index]
	instruction_label.text = "Ketuk baris yang bersajak!"
	line1_label.text = data["line1"]
	feedback_label.text = ""

	# Bersihkan tombol lama
	for child in choices_container.get_children():
		child.queue_free()

	var options: Array = data["options"]
	for i in range(options.size()):
		var btn := Button.new()
		btn.text = options[i]
		btn.custom_minimum_size = Vector2(120, 40)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD
		var idx: int = i
		btn.pressed.connect(func(): _on_choice(idx, data["correct"]))
		choices_container.add_child(btn)

func _on_choice(selected: int, correct: int) -> void:
	_attempts += 1
	if selected == correct:
		feedback_label.text = "✓ Tepat! Sajak yang indah."
		AudioManager.play_sfx("correct")
		SettingsManager.vibrate(20)
		await get_tree().create_timer(1.0).timeout
		_current_pantun_index += 1
		_show_pantun(_current_pantun_index)
	else:
		feedback_label.text = "✗ Coba lagi! Perhatikan bunyi akhirnya."
		AudioManager.play_sfx("wrong")
		GameState.add_river_health(-2.0)

func _complete() -> void:
	_is_active = false
	panel.hide()
	# Beritahu level script
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("on_pantun_completed"):
		level.on_pantun_completed()
