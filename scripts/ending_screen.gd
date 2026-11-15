## EndingScreen Script (Deli Rewind)
## Menampilkan layar akhir berdasarkan 4 Ending (A, B, C, D) atau ringkasan perjalanan.
extends Control

@onready var ending_title: Label = $Panel/VBox/EndingTitle
@onready var ending_message: RichTextLabel = $Panel/VBox/EndingMessage
@onready var stats_label: RichTextLabel = $Panel/VBox/StatsLabel
@onready var play_again_btn: Button = get_node_or_null("Panel/VBox/Buttons/PlayAgainBtn") as Button
@onready var quit_btn: Button = get_node_or_null("Panel/VBox/Buttons/QuitBtn") as Button
@onready var cards_btn: Button = get_node_or_null("Panel/VBox/Buttons/CardsBtn") as Button
@onready var card_popup: CanvasLayer = get_node_or_null("KnowledgeCardPopup") as CanvasLayer
@onready var river_visual: ColorRect = get_node_or_null("Background/RiverVisual") as ColorRect

const ENDING_DATA: Dictionary = {
	"A": {
		"title": "🌟 Ending A: Harapan Baru Deli (True Ending)",
		"message": "Enam bulan kemudian. Pukul lima subuh, dari dalam warung makan keluarga kami kembali terdengar denting sendok yang beradu dengan gelas kaca. Pelanggan ramai berdatangan, dan warga rutin kerja bakti menjaga tanggul sungai.\n\n[b]Datuk Sampan:[/b] \"Aku bukan sekadar hantu, Nak. Aku ingatan kampung ini tentang cara menjaga Sungai Deli. Selama ada yang mengingat, aku akan selalu ada.\"\n[i]\"Waktu tak bisa diputar kembali di dunia nyata. Yang bisa kita ubah hanyalah kebiasaan kita. Dan kebiasaan baik dimulai dari mendengar.\"[/i]"
	},
	"B": {
		"title": "🌤 Ending B: Keluarga Mandiri (Normal Ending)",
		"message": "Musim hujan kembali tiba dengan curah air cukup deras. Air sungai sempat naik sampai anak tangga teras warung, tapi tidak sampai menenggelamkan meja seperti dulu.\n\n[b]Bu Mira:[/b] \"Kita memang belum menang sepenuhnya melawan banjir, Nak, tapi setidaknya kali ini kita tidak kalah seperti dulu.\"\n[b]Datuk Sampan:[/b] \"Kau tak sendirian lagi sekarang, Nak. Ada yang ikut menjaga. Teruskan perjuanganmu.\""
	},
	"C": {
		"title": "🌥 Ending C: Bertahan di Tepian (Warning Ending)",
		"message": "Hujan lebat kembali datang. Warung masih berdiri, tapi dindingnya kembali basah kuyup sampai batas lumpur lama. Perbaikan tempat makan ibu tersendat dan sungai masih rawan.\n\n[b]MC:[/b] \"Seperti menambal atap saat hujan badai sudah turun. Bisa bertahan, tapi tak pernah benar-benar kering.\"\n[b]Datuk Sampan:[/b] \"Sungai belajar dari kita, seperti kita belajar darinya. Jalanmu masih panjang, Nak. Jangan berhenti di tengah jalan.\""
	},
	"D": {
		"title": "🌧 Ending D: Banjir Bandang (Bad Ending — Rewind)",
		"message": "Banjir bandang menerjang dahsyat. Air cokelat pekat menelan warung keluarga MC hanya menyisakan tiang-tiang kayu yang patah dan sepasang sandal yang mengapung di lumpur.\n\n[b]Datuk Sampan:[/b] \"Sungai tak pernah membenci siapa pun, Nak. Ia hanya kembali mencari jalannya yang tersumbat. Satu orang membuang, semua orang yang menanggung akibatnya.\"\n[b][color=#ffd166]\"Tekan REWIND untuk memutar waktu kembali dan memulai dengan mendengar.\"[/color][/b]"
	},
	"baik": {
		"title": "Sungai Deli Pulih!",
		"message": "Luar biasa! Berkat usahamu, Sungai Deli kembali jernih. Air mengalir bening, ikan kembali berenang, dan warga bisa kembali menikmati bantaran sungai yang hijau.\n\n[i]Pepatah Melayu Deli: sungai yang dijaga akan menjaga kita. Hulu yang rimbun menurunkan air yang jernih ke hilir.[/i]"
	},
	"biasa": {
		"title": "Sungai Mulai Membaik",
		"message": "Sungai Deli sudah lebih bersih dari sebelumnya. Masih ada yang perlu diperbaiki, tapi perjalananmu telah memberi harapan.\n\n[i]Gotong royong adalah kunci: berat sama dipikul, ringan sama dijinjing.[/i]"
	},
	"buruk": {
		"title": "Sungai Masih Sakit",
		"message": "Sungai Deli masih membutuhkan pertolongan. Jangan menyerah! Setiap orang bisa mulai dari hal kecil.\n\n[i]Satu sampah yang dipungut hari ini adalah satu harapan untuk sungai esok hari.[/i]"
	}
}

var _current_code: String = "D"

func _ready() -> void:
	if play_again_btn == null:
		play_again_btn = get_node_or_null("Panel/VBox/HBox/PlayAgainBtn") as Button
	if quit_btn == null:
		quit_btn = get_node_or_null("Panel/VBox/HBox/QuitBtn") as Button
	if cards_btn == null:
		cards_btn = get_node_or_null("Panel/VBox/HBox/CardsBtn") as Button
	_show_ending()
	if _current_code in ["D", "buruk"]:
		AudioManager.play_bgm("epilog_bad")
	else:
		AudioManager.play_bgm(5)
	if play_again_btn:
		play_again_btn.pressed.connect(_on_play_again)
	if cards_btn:
		cards_btn.pressed.connect(_on_cards)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit)

func _show_ending() -> void:
	if GameState.has_method("tentukan_ending"):
		_current_code = GameState.ending_terakhir if GameState.ending_terakhir in ["A", "B", "C", "D"] else GameState.tentukan_ending(false)
	else:
		_current_code = GameState.calculate_ending()

	var data: Dictionary = ENDING_DATA.get(_current_code, ENDING_DATA.get("B", ENDING_DATA["biasa"]))
	ending_title.text = data["title"]
	ending_message.text = "[center]%s[/center]" % data["message"]

	if play_again_btn:
		if _current_code == "D":
			play_again_btn.text = "⏪ Rewind"
		else:
			play_again_btn.text = "🔄 Main Lagi"

	var stats: String = "[b]Statistik Akhir Perjalanan[/b]\n"
	if GameState.has_method("get_jumlah_npc_peduli"):
		var meter_akhir: int = int(round(GameState.meter_bencana if "meter_bencana" in GameState else (100.0 - GameState.river_health)))
		var peduli_count: int = GameState.get_jumlah_npc_peduli()
		stats += "• Meter Bencana: %d%% (Kejernihan %d%%)\n" % [meter_akhir, int(round(GameState.river_health))]
		stats += "• Warga Peduli: %d / 3 Warga\n" % peduli_count
	stats += "• Sampah Terkumpul: %d | Pohon Ditanam: %d\n" % [GameState.get_total_trash(), GameState.trees_planted]
	stats += "• Mangrove: %d | Kartu: %d\n" % [GameState.mangroves_planted, GameState.collected_cards.size()]
	stats += "• Rupiah Terkumpul: Rp %s" % _format_number(GameState.rupiah)
	stats_label.text = stats

	if river_visual:
		match _current_code:
			"A", "baik": river_visual.color = Color(0.18, 0.65, 0.92, 0.85)
			"B", "biasa": river_visual.color = Color(0.28, 0.58, 0.78, 0.80)
			"C": river_visual.color = Color(0.42, 0.52, 0.58, 0.78)
			"D", "buruk": river_visual.color = Color(0.36, 0.28, 0.22, 0.85)

func _nama_sikap(nilai: int) -> String:
	match nilai:
		GameState.SIKAP_MENOLAK: return "Menolak"
		GameState.SIKAP_ACUH: return "Acuh"
		GameState.SIKAP_RAGU: return "Ragu"
		GameState.SIKAP_PEDULI: return "Peduli"
		_: return "Acuh"

func _on_play_again() -> void:
	if _current_code == "D" and GameState.has_method("rewind"):
		GameState.rewind()
	else:
		GameState.reset()
		SceneManager.go_to_main_menu()

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
	SceneManager.go_to_main_menu()
