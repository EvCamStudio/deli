## EndingScreen Script (Deli Rewind — Master Game System)
## Menampilkan 4 varian ending berdasarkan Dokumen Utama Bagian 7
## dan Layar Kredit / Penjelasan Edukasi untuk Dewan Juri (Bagian 9).
extends Control

@onready var ending_title: Label = $VBox/EndingTitle
@onready var ending_message: RichTextLabel = $VBox/EndingMessage
@onready var stats_label: RichTextLabel = $VBox/StatsLabel
@onready var play_again_btn: Button = $VBox/Buttons/PlayAgainBtn
@onready var cards_btn: Button = $VBox/Buttons/CardsBtn
@onready var quit_btn: Button = $VBox/Buttons/QuitBtn
@onready var river_visual: ColorRect = $Background/RiverVisual

const ENDING_DATA: Dictionary = {
	"A": {
		"title": "🏆 ENDING A: HARAPAN BARU DELI (TERBAIK)",
		"message": "[b]Sungai Deli jernih, warung kopi ramai, dan utang keluarga lunas 100%![/b]\n\nWarga bantaran kini sadar dan rutin kerja bakti. MC mendirikan bank sampah komunitas.\n[i]Datuk Sampan (tersenyum terang): \"Aku bukan hantu, Nak. Aku ingatan kampung ini tentang cara menjaga sungai. Selama kalian ingat dan peduli, aku ada.\"[/i]",
		"color": Color(0.2, 0.65, 0.95, 0.85)
	},
	"B": {
		"title": "🌤 ENDING B: KELUARGA MANDIRI (BAIK)",
		"message": "[b]Warung selamat dan kondisi sungai membaik bertahap.[/b]\n\nSebagian besar utang lunas dan warga mulai terbiasa membuang sampah pada tempatnya.\n[i]Datuk Sampan: \"Kau tidak sendirian lagi, Nak. Perjalananmu membuahkan hasil. Teruskan.\"[/i]",
		"color": Color(0.3, 0.6, 0.75, 0.8)
	},
	"C": {
		"title": "🌧 ENDING C: BERTAHAN DI TEPIAN (NETRAL)",
		"message": "[b]Warung bertahan dari banjir, tetapi utang masih tersisa dan sungai masih rawan.[/b]\n\nSebagian warga masih kembali ke kebiasaan lama jika tidak diawasi.\n[i]Datuk Sampan: \"Sungai belajar dari kita, sebagaimana kita belajar darinya. Jalanmu masih panjang.\"[/i]",
		"color": Color(0.45, 0.45, 0.4, 0.8)
	},
	"D": {
		"title": "💔 ENDING D: TERPAKSA MENYERAH (BURUK)",
		"message": "[b]Banjir bandang besar menerjang kembali bantaran Sungai Deli.[/b]\n\nWarung orang tua digusur lumpur dan keluarga terpaksa pindah.\n[i]Datuk Sampan (memudar): \"Sungai tidak membenci siapa pun. Ia hanya kembali ke jalannya...\"[/i]\n\n[color=#e06050][b]PESAN EDUKASI: Satu orang membuang sampah, semua yang menanggung bencana.[/b][/color]",
		"color": Color(0.35, 0.25, 0.2, 0.85)
	}
}

func _ready() -> void:
	if AudioManager:
		AudioManager.play_bgm(5)
	_show_ending()
	play_again_btn.pressed.connect(_on_rewind)
	if cards_btn:
		cards_btn.pressed.connect(_on_credits_or_cards)
	quit_btn.pressed.connect(_on_quit)

func _show_ending() -> void:
	var kode: String = GameState.evaluasi_ending()
	var data: Dictionary = ENDING_DATA.get(kode, ENDING_DATA["B"])

	ending_title.text = data["title"]
	ending_message.text = data["message"]

	# Hitung persentase utang lunas
	var utang_lunas := GameState.utang_awal - GameState.utang
	var pct: float = (float(utang_lunas) / float(GameState.utang_awal)) * 100.0

	var stats: String = "[b]Statistik Akhir Perjalanan 7 Hari:[/b]\n"
	stats += "💧 Meter Bencana: %d / 100 (Kejernihan: %d%%)\n" % [int(GameState.meter_bencana), int(GameState.river_health)]
	stats += "👥 Sikap Warga: Jali (%s), Rina (%s), Darwis (%s)\n" % [
		_format_sikap(GameState.npc_sikap.get("jali", 0)),
		_format_sikap(GameState.npc_sikap.get("rina", 0)),
		_format_sikap(GameState.npc_sikap.get("darwis", 0))
	]
	stats += "💰 Utang Terbayar: Rp %s / Rp %s (%.0f%%)\n" % [
		_format_number(utang_lunas), _format_number(GameState.utang_awal), pct
	]
	stats += "🏪 Kondisi Warung: %s\n" % ("Bersih & Buka" if GameState.warung_bersih else "Rusak")
	stats_label.text = stats

	if river_visual:
		river_visual.color = data["color"]

	if kode == "D":
		play_again_btn.text = "⏪ REWIND (Ulang dari Hari 1)"
	else:
		play_again_btn.text = "▶ Mainkan Lagi"

	if cards_btn:
		cards_btn.text = "📜 Daftar Pustaka & Edukasi"

func _format_sikap(val: int) -> String:
	match val:
		2: return "Peduli 💚"
		1: return "Ragu ❓"
		-1: return "Menolak ❌"
		_: return "Acuh ⚪"

func _format_number(val: int) -> String:
	var s := str(val)
	var res := ""
	var cnt := 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		cnt += 1
		if cnt % 3 == 0 and i > 0:
			res = "." + res
	return res

func _on_rewind() -> void:
	GameState.reset_ke_hari_1()
	SceneManager.change_scene("res://scenes/maps/map_a_warung.tscn")

func _on_credits_or_cards() -> void:
	# Tampilkan popup daftar pustaka dan edukasi juri
	var popup := get_node_or_null("CreditsPopup") as Control
	if popup:
		popup.show()
	else:
		_tampilkan_kredit_fallback()

func _tampilkan_kredit_fallback() -> void:
	var text := "[b]DAFTAR PUSTAKA & KEARIFAN LOKAL (UNTUK DEWAN JURI):[/b]\n\n"
	text += "1. Syaifuddin, W. & Loebis, R. A. A. The River Planning Based on Local Wisdom (Case Study: Upper Reaches of Sungai Deli Medan, North Sumatera).\n"
	text += "2. Hajar, I., Indriyanto, K. & Syahfitri, D. (2024). Representasi Nilai Kearifan Lokal pada Pantun Melayu Deli dan Pelestariannya Melalui Telangkai. GERAM, 12(2), 115-125.\n\n"
	text += "[i]Cerita dan tokoh dalam game ini adalah karya fiksi orisinal yang terinspirasi penelitian kearifan lokal sastra lisan Melayu di DAS Sungai Deli.[/i]"
	ending_message.text = text

func _on_quit() -> void:
	get_tree().quit()
