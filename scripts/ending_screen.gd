## EndingScreen Script (Orang 1: Sistem Inti - Ridwan)
# Menampilkan 4 Ending (A, B, C, D) sesuai Dokumen Utama Bagian 7 & 14,
# statistik Meter Bencana, jumlah NPC Peduli, persentase utang lunas,
# serta tombol Rewind di Ending D yang mereset GameState ke Hari 1.
extends Control

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var ending_title: Label = $VBox/EndingTitle
@onready var ending_message: RichTextLabel = $VBox/EndingMessage
@onready var stats_label: RichTextLabel = $VBox/StatsLabel
@onready var play_again_btn: Button = $VBox/Buttons/PlayAgainBtn
@onready var cards_btn: Button = $VBox/Buttons/CardsBtn
@onready var quit_btn: Button = $VBox/Buttons/QuitBtn
@onready var card_popup: CanvasLayer = $KnowledgeCardPopup
@onready var river_visual: ColorRect = $Background/RiverVisual

const ENDING_DATA: Dictionary = {
	"A": {
		"title": "🌟 Ending A: Harapan Baru Deli (Terbaik)",
		"message": "Beberapa bulan kemudian, sungai jernih dan warung ramai. Warga rutin kerja bakti dan bank sampah komunitas berdiri.\n\n[b]Datuk Sampan:[/b] \"Aku bukan hantu, Nak. Aku ingatan kampung ini tentang cara menjaga sungai. Selama kalian ingat, aku ada.\""
	},
	"B": {
		"title": "🌤 Ending B: Keluarga Mandiri (Baik)",
		"message": "Warung selamat, sungai membaik pelan-pelan. Beberapa warga masih kembali ke kebiasaan lama, namun perubahan sudah berjalan.\n\n[b]Datuk Sampan:[/b] \"Kau tidak sendirian lagi. Teruskan.\""
	},
	"C": {
		"title": "🌥 Ending C: Bertahan di Tepian (Netral)",
		"message": "Hujan berikutnya datang. Warung bertahan, tapi utang masih tersisa dan sungai masih rawan banjir.\n\n[b]Datuk Sampan:[/b] \"Sungai belajar dari kita, sebagaimana kita belajar darinya. Jalanmu masih panjang.\""
	},
	"D": {
		"title": "🌧 Ending D: Terpaksa Menyerah (Buruk)",
		"message": "Banjir besar menerjang. Warung digusur dan keluarga pindah.\n\n[b]Datuk Sampan (memudar):[/b] \"Sungai tidak membenci siapa pun. Ia hanya kembali ke jalannya.\"\n[b][color=#ffd166]\"Satu orang membuang, semua menanggung.\"[/color][/b]"
	}
}

var _current_code: String = "D"

func _ready() -> void:
	AudioManager.play_bgm(5)
	_show_ending()
	play_again_btn.pressed.connect(_on_play_again)
	cards_btn.pressed.connect(_on_cards)
	quit_btn.pressed.connect(_on_quit)

func _show_ending() -> void:
	_current_code = GameState.ending_terakhir if GameState.ending_terakhir in ["A", "B", "C", "D"] else GameState.tentukan_ending(false)
	var data: Dictionary = ENDING_DATA.get(_current_code, ENDING_DATA["D"])

	ending_title.text = data["title"]
	ending_message.text = data["message"]

	# Tombol Rewind khusus untuk Ending D sesuai spesifikasi
	if _current_code == "D":
		play_again_btn.text = "⏪ Rewind (Hari 1)"
	else:
		play_again_btn.text = "🔄 Main Lagi (Hari 1)"

	# Statistik akhir sesuai syarat ending
	var meter_akhir: int = int(round(GameState.meter_bencana))
	var peduli_count: int = GameState.get_jumlah_npc_peduli()
	var persen_utang: int = int(round(GameState.get_persen_utang_lunas() * 100.0))

	var stats: String = "[b]Ringkasan Akhir (Hari %d):[/b]\n" % GameState.hari
	stats += "• Meter Bencana: %d%% (Kejernihan %d%%)\n" % [meter_akhir, int(round(GameState.river_health))]
	stats += "• Warga Peduli: %d / 3 (Jali: %s, Rina: %s, Darwis: %s)\n" % [
		peduli_count,
		_nama_sikap(GameState.get_sikap("jali")),
		_nama_sikap(GameState.get_sikap("rina")),
		_nama_sikap(GameState.get_sikap("darwis")),
	]
	stats += "• Utang Lunas: %d%% (Sisa Utang: Rp %d)\n" % [persen_utang, GameState.utang]
	stats += "• Sampah Terpilah: %d | Pohon Ditanam: %d" % [GameState.get_total_trash(), GameState.trees_planted]
	stats_label.text = stats

	# Ubah visual sungai sesuai ending A/B/C/D
	match _current_code:
		"A": river_visual.color = Color(0.18, 0.65, 0.92, 0.85)
		"B": river_visual.color = Color(0.28, 0.58, 0.78, 0.80)
		"C": river_visual.color = Color(0.42, 0.52, 0.58, 0.78)
		"D": river_visual.color = Color(0.36, 0.28, 0.22, 0.85)

func _nama_sikap(nilai: int) -> String:
	match nilai:
		GameState.SIKAP_MENOLAK: return "Menolak"
		GameState.SIKAP_ACUH: return "Acuh"
		GameState.SIKAP_RAGU: return "Ragu"
		GameState.SIKAP_PEDULI: return "Peduli"
		_: return "Acuh"

func _on_play_again() -> void:
	# Rewind mereset GameState kembali ke Hari 1
	GameState.rewind()

func _on_cards() -> void:
	if card_popup and card_popup.has_method("open_collection"):
		card_popup.open_collection()

func _on_quit() -> void:
	SceneManager.go_to_main_menu()
