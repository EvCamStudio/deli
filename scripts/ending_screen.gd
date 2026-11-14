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
		"title": "🌟 Ending A: Harapan Baru Deli (Terbaik)",
		"message": "Enam bulan kemudian. Pukul lima pagi, sendok kembali beradu gelas di warung kopi keluarga. Tujuh meja berdiri, atap tertambal sebelum hujan, dan utang telah lunas diselipkan di bawah toples gula baru.\n\n[b]Datuk Sampan:[/b] \"Aku bukan hantu, Nak. Aku ingatan kampung ini tentang cara menjaga sungai. Selama ada yang mengingat, aku ada.\"\n[i]\"Waktu tak bisa diputar kembali. Yang bisa hanya kebiasaan. Dan kebiasaan dimulai dari mendengar.\"[/i]"
	},
	"B": {
		"title": "🌤 Ending B: Keluarga Mandiri (Baik)",
		"message": "Hujan deras datang lagi bulan itu. Warung kami basah, tapi tidak tenggelam. Utang pokok hampir tak bersisa di buku Mak.\n\n[b]Bu Mira:[/b] \"Air naik sampai tangga kedua. Dulu sampai meja. Kita tak menang, Nak, tapi kita tak kalah seperti dulu.\"\n[b]Datuk Sampan:[/b] \"Kau tak sendirian lagi, Nak. Ada yang ikut menjaga. Teruskan.\""
	},
	"C": {
		"title": "🌥 Ending C: Bertahan di Tepian (Netral)",
		"message": "Hujan lebat kembali datang. Warung bertahan, tapi dindingnya basah sampai garis lumpur lama. Utang masih tersisa dan sungai masih rawan.\n\n[b]MC:[/b] \"Seperti menambal atap saat hujan sudah turun. Bisa, tapi tak pernah benar-benar kering.\"\n[b]Datuk Sampan:[/b] \"Sungai belajar dari kita, seperti kita belajar darinya. Jalanmu masih panjang. Jangan berhenti di tengah.\""
	},
	"D": {
		"title": "🌧 Ending D: Terpaksa Menyerah (Buruk)",
		"message": "Banjir bandang datang malam hari tanpa aba-aba. Air coklat pekat menelan bantaran dan warung keluarga. Pagi harinya, hanya tiang yang tersisa dan sandal yang masih berpasangan.\n\n[b]Datuk Sampan (memudar):[/b] \"Sungai tak membenci siapa pun, Nak. Ia hanya kembali ke jalannya. Kalau kau diberi kesempatan sekali lagi, dengarkan dulu sebelum bicara.\"\n[b][color=#ffd166]\"Satu orang membuang, semua menanggung.\"[/color][/b]"
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
	if GameState.has_method("get_jumlah_npc_peduli") and GameState.has_method("get_persen_utang_lunas"):
		var meter_akhir: int = int(round(GameState.meter_bencana if "meter_bencana" in GameState else (100.0 - GameState.river_health)))
		var peduli_count: int = GameState.get_jumlah_npc_peduli()
		var persen_utang: int = int(round(GameState.get_persen_utang_lunas() * 100.0))
		stats += "• Meter Bencana: %d%% (Kejernihan %d%%)\n" % [meter_akhir, int(round(GameState.river_health))]
		stats += "• Warga Peduli: %d / 3 | Utang Lunas: %d%%\n" % [peduli_count, persen_utang]
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
