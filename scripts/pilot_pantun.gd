## PilotPantun — mini-game pantun bergaya panggung kecil.
extends CanvasLayer
class_name PilotPantun

@onready var panel: PanelContainer = $Panel
@onready var portrait: TextureRect = $Panel/VBox/Body/Portrait
@onready var line_label: RichTextLabel = $Panel/VBox/Body/Content/LineLabel
@onready var choices: VBoxContainer = $Panel/VBox/Body/Content/Choices
@onready var feedback: Label = $Panel/VBox/Body/Content/Feedback
@onready var close_btn: Button = $Panel/VBox/CloseBtn

const PANTUN: Array = [
	{
		"line1": "Ke pasar membeli ikan,\nIkan bawal bukan cupang.",
		"options": [
			"Mari kita jaga sungai bersama-sama,\nAgar anak cucu turut senang.",
			"Pergi ke hutan cari kayu,\nKayu jati bukan sembarang.",
			"Naik perahu ke tengah danau,\nHati senang tiada terbilang.",
		],
		"correct": 0,
		"wisdom": "Sungai bersih adalah warisan untuk anak cucu.",
	},
	{
		"line1": "Bunga raya di tepi sungai,\nHarum semerbak ke udara.",
		"options": [
			"Jangan kita buang sampah di sini,\nSungai bersih milik semua.",
			"Pergi ke kota membeli baju,\nBaju merah warna permata.",
			"Burung terbang melintas sawah,\nPetani gembira kerja.",
		],
		"correct": 0,
		"wisdom": "Sampah yang dijaga tidak akan kembali ke sungai.",
	},
	{
		"line1": "Anak ikan di dalam kolam,\nBerenang tenang di air jernih.",
		"options": [
			"Mari kita jaga sungai dalam,\nAgar airnya tetap bersih.",
			"Pergi ke pasar membeli jambu,\nJambu manis dari taman.",
			"Burung terbang ke atas awan,\nAwan putih di langit cerah.",
		],
		"correct": 0,
		"wisdom": "Air yang jernih lahir dari kebiasaan kecil yang dijaga.",
	},
	{
		"line1": "Pohon rimbun di tepi hutan,\nTempat burung bernyanyi riang.",
		"options": [
			"Jangan tebang pohon sembarangan,\nAgar sungai tetap tenang.",
			"Pergi ke kota naik kereta,\nKereta cepat tiada henti.",
			"Beli kain di pasar malam,\nKain batik warna cerah.",
		],
		"correct": 0,
		"wisdom": "Hutan yang lestari menjaga mata air dan kehidupan.",
	},
]

var _index: int = 0
var _locked: bool = false

func _ready() -> void:
	panel.hide()
	close_btn.pressed.connect(_close)
	portrait.texture = load("res://assets/sprites/portraits/budi_happy.png")

func start() -> void:
	if panel.visible:
		return
	_index = 0
	_locked = false
	panel.show()
	_hide_touch_controls()
	get_tree().paused = true
	_show_pantun()

func _show_pantun() -> void:
	if _index >= PANTUN.size():
		_complete()
		return
	_locked = false
	feedback.text = ""
	for child in choices.get_children():
		child.queue_free()
	var data: Dictionary = PANTUN[_index]
	line_label.text = str(data["line1"])
	var options: Array = data["options"]
	for i in range(options.size()):
		var btn := Button.new()
		btn.text = str(options[i])
		btn.custom_minimum_size = Vector2(0, 30)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD
		btn.add_theme_font_size_override("font_size", 11)
		var idx: int = i
		btn.pressed.connect(func(): _on_choice(idx, int(data["correct"])))
		choices.add_child(btn)

func _on_choice(selected: int, correct: int) -> void:
	if _locked:
		return
	if selected == correct:
		_locked = true
		var wisdom: String = str(PANTUN[_index].get("wisdom", ""))
		feedback.text = "Tepat!" if wisdom.is_empty() else "Tepat! " + wisdom
		feedback.add_theme_color_override("font_color", Color(0.2, 0.45, 0.25))
		AudioManager.play_sfx("correct")
		SettingsManager.vibrate(20)
		await get_tree().create_timer(1.5).timeout
		_index += 1
		_show_pantun()
	else:
		feedback.text = "Belum tepat. Perhatikan bunyi akhirnya."
		feedback.add_theme_color_override("font_color", Color(0.6, 0.22, 0.18))
		GameState.add_river_health(-1.0)
		AudioManager.play_sfx("wrong")
		SettingsManager.vibrate(50)

func _complete() -> void:
	panel.hide()
	get_tree().paused = false
	_restore_touch_controls()
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("on_pantun_completed"):
		level.on_pantun_completed()

func _close() -> void:
	panel.hide()
	get_tree().paused = false
	_restore_touch_controls()

func _hide_touch_controls() -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("set_touch_controls_visible"):
		level.set_touch_controls_visible(false)

func _restore_touch_controls() -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("set_touch_controls_visible"):
		level.set_touch_controls_visible(true)
