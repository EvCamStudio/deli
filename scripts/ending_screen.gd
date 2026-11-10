## EndingScreen Script
# Layer 5 / Epilog: tampilkan ringkasan statistik dan pesan ending.
extends Control

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var ending_title: Label = $Panel/VBox/EndingTitle
@onready var ending_message: RichTextLabel = $Panel/VBox/EndingMessage
@onready var stats_label: RichTextLabel = $Panel/VBox/StatsLabel
@onready var play_again_btn: Button = $Panel/VBox/Buttons/PlayAgainBtn
@onready var cards_btn: Button = $Panel/VBox/Buttons/CardsBtn
@onready var quit_btn: Button = $Panel/VBox/Buttons/QuitBtn
@onready var card_popup: CanvasLayer = $KnowledgeCardPopup
@onready var river_visual: ColorRect = $Background/RiverVisual

const ENDING_DATA: Dictionary = {
	"baik": {
		"title": "Sungai Deli Pulih!",
		"message": "Luar biasa! Berkat usahamu, Sungai Deli kembali jernih. Air mengalir bening, ikan kembali berenang, dan warga bisa kembali menikmati bantaran sungai yang hijau. Setiap tindakan kecilmu membuat perbedaan besar!"
	},
	"biasa": {
		"title": "Sungai Mulai Membaik",
		"message": "Sungai Deli sudah lebih bersih dari sebelumnya. Masih ada yang perlu diperbaiki, tapi perjalananmu telah memberi harapan. Coba lagi dan buat perbedaan yang lebih besar!"
	},
	"buruk": {
		"title": "Sungai Masih Sakit",
		"message": "Sungai Deli masih membutuhkan pertolongan. Jangan menyerah! Setiap orang bisa mulai dari hal kecil. Coba lagi dan buat pilihan yang lebih baik untuk sungai kita."
	}
}

const LOCAL_WISDOM: Dictionary = {
	"baik": "Pepatah Melayu Deli: sungai yang dijaga akan menjaga kita. Hulu yang rimbun menurunkan air yang jernih ke hilir.",
	"biasa": "Gotong royong adalah kunci: berat sama dipikul, ringan sama dijinjing. Sungai tidak bisa dibersihkan seorang diri.",
	"buruk": "Belum terlambat untuk memulai. Satu sampah yang dipungut hari ini adalah satu harapan untuk sungai esok hari."
}

func _ready() -> void:
	AudioManager.play_bgm(5)
	_show_ending()
	play_again_btn.pressed.connect(_on_play_again)
	cards_btn.pressed.connect(_on_cards)
	quit_btn.pressed.connect(_on_quit)

func _show_ending() -> void:
	var ending_type: String = GameState.calculate_ending()
	var data: Dictionary = ENDING_DATA.get(ending_type, ENDING_DATA["biasa"])
	var wisdom: String = str(LOCAL_WISDOM.get(ending_type, ""))

	ending_title.text = data["title"]
	ending_message.text = "[center]%s[/center]\n\n[center][i]%s[/i][/center]" % [data["message"], wisdom]

	# Statistik
	var total_cards: int = GameState.total_cards_available()
	if total_cards <= 0:
		total_cards = 16
	var stats: String = "[b]Statistik Perjalanan[/b]\n"
	stats += "Sampah dikumpulkan: %d\n" % GameState.get_total_trash()
	stats += "Pohon ditanam: %d\n" % GameState.trees_planted
	stats += "Mangrove ditanam: %d\n" % GameState.mangroves_planted
	stats += "Kartu terkumpul: %d / %d\n" % [GameState.collected_cards.size(), total_cards]
	stats += "Rupiah terkumpul: Rp %s\n" % _format_number(GameState.rupiah)
	stats += "Kejernihan akhir: %d%%" % int(GameState.river_health)
	stats_label.text = stats

	# Ubah visual sungai sesuai ending
	match ending_type:
		"baik":   river_visual.color = Color(0.2, 0.6, 0.9, 0.8)
		"biasa":  river_visual.color = Color(0.4, 0.55, 0.65, 0.7)
		"buruk":  river_visual.color = Color(0.35, 0.3, 0.25, 0.8)

func _on_play_again() -> void:
	GameState.reset()
	SceneManager.go_to_intro()

func _format_number(value: int) -> String:
	var text: String = str(value)
	var out: String = ""
	var count: int = 0
	for i in range(text.length() - 1, -1, -1):
		out = text[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "." + out
	return out

func _on_cards() -> void:
	if card_popup and card_popup.has_method("open_collection"):
		card_popup.open_collection()

func _on_quit() -> void:
	get_tree().quit()
