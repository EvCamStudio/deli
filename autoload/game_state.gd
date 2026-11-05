## GameState Autoload (Orang 1: Sistem Inti - Ridwan)
# Menyimpan semua state permainan sesuai Kontrak Bersama:
# Meter Bencana (100 - river_health), sikap 3 NPC, siklus hari (1-7),
# uang, utang, energi, status warung, ujian hujan, dan ending.
extends Node

# ─── Sinyal Kontrak Bersama ───────────────────────────────────────────────────
signal meter_changed(nilai: float)
signal sikap_changed(npc: String, nilai: int)
signal hari_changed(hari: int)
signal malam_dimulai
signal ujian_hujan_selesai(nomor: int, hasil: String)
signal ending_ditentukan(kode: String)
signal waktu_changed(waktu_baru: String)
signal utang_menu_selesai(pilihan: String, jumlah_dibayar: int)
signal puzzle_pintu_air_selesai

# ─── Sinyal Kompatibilitas Lama ───────────────────────────────────────────────
signal river_health_changed(new_value: float)
signal card_unlocked(card_id: String)
signal level_completed(level_id: int)
signal energy_changed(new_value: float)
signal rupiah_changed(new_value: int)
signal utang_changed(new_value: int)
signal day_changed(new_day: int)
signal zone_opened(zone: String)

# ─── Konstanta Siklus & Nilai Sikap ───────────────────────────────────────────
const SIKAP_MENOLAK: int = -1
const SIKAP_ACUH: int = 0
const SIKAP_RAGU: int = 1
const SIKAP_PEDULI: int = 2

const FASE_WAKTU: Array[String] = ["pagi", "siang", "sore", "malam"]
const UTANG_AWAL: int = 500000
const SAVE_PATH: String = "user://save.json"

# ─── Variabel Inti Sesuai Kontrak Bersama ─────────────────────────────────────
var _syncing: bool = false
var _debug_panel: CanvasLayer = null

func _ready() -> void:
	var dbg_script := load("res://scripts/debug_panel.gd")
	if dbg_script:
		_debug_panel = CanvasLayer.new()
		_debug_panel.name = "SystemDebugPanel"
		_debug_panel.set_script(dbg_script)
		add_child(_debug_panel)

## Meter Bencana mulai 60 -> river_health mulai 40 (Meter Bencana = 100 - river_health)
@export_range(0.0, 100.0, 1.0) var river_health: float = 40.0 :
	set(value):
		river_health = clampf(value, 0.0, 100.0)
		river_health_changed.emit(river_health)
		meter_changed.emit(100.0 - river_health)

## Getter praktis untuk Meter Bencana (0 sampai 100)
var meter_bencana: float :
	get:
		return 100.0 - river_health
	set(value):
		river_health = 100.0 - clampf(value, 0.0, 100.0)

@export_range(1, 7, 1) var hari: int = 1 :
	set(value):
		hari = clampi(value, 1, 7)
		if not _syncing:
			_syncing = true
			day = hari
			_syncing = false
		hari_changed.emit(hari)
		day_changed.emit(hari)
		_cek_otomatis_ujian_hujan()

@export_enum("pagi", "siang", "sore", "malam") var waktu: String = "pagi" :
	set(value):
		var clean_val: String = value.strip_edges().to_lower()
		waktu = clean_val if clean_val in FASE_WAKTU else value
		if clean_val in FASE_WAKTU:
			match clean_val:
				"pagi": minutes = 8 * 60
				"siang": minutes = 12 * 60
				"sore": minutes = 16 * 60
				"malam": minutes = 20 * 60
			waktu_changed.emit(waktu)
			_cek_otomatis_ujian_hujan()

var uang: int = 0 :
	set(value):
		uang = maxi(0, value)
		if not _syncing:
			_syncing = true
			rupiah = uang
			_syncing = false
		rupiah_changed.emit(uang)

var utang: int = UTANG_AWAL :
	set(value):
		utang = clampi(value, 0, UTANG_AWAL)
		if not _syncing:
			_syncing = true
			debt_amount = utang
			debt_paid = UTANG_AWAL - utang
			_syncing = false
		utang_changed.emit(utang)

var energi: float = 100.0 :
	set(value):
		energi = clampf(value, 0.0, 100.0)
		if not _syncing:
			_syncing = true
			energy = energi
			_syncing = false
		energy_changed.emit(energi)

## Sikap 3 NPC: -1 Menolak, 0 Acuh (awal), 1 Ragu, 2 Peduli
var npc_sikap: Dictionary = {
	"jali": SIKAP_ACUH,
	"rina": SIKAP_ACUH,
	"darwis": SIKAP_ACUH,
}

## Mencatat NPC yang sudah pernah memberikan bonus -10 Meter saat pertama kali jadi Peduli
var _npc_peduli_bonus: Dictionary = {
	"jali": false,
	"rina": false,
	"darwis": false,
}

var warung_bersih: bool = false :
	set(value):
		warung_bersih = value
		parent_shop_status = "pulih" if warung_bersih else "rusak"

var warung_buka: bool = false :
	set(value):
		if value and warung_terkunci_sampai_h7 and hari < 7:
			warung_buka = false
			return
		warung_buka = value

## State Ujian Hujan (Tahap 3)
var penalti_energi_besok: float = 0.0
var warung_terkunci_sampai_h7: bool = false
var hasil_ujian_hujan: Dictionary = {
	1: "",
	2: "",
	3: "",
}
var cutscene_ujian_akhir: String = ""
var ending_terakhir: String = ""
var puzzle_pintu_air_beres: bool = false
var _menu_utang_h7_muncul: bool = false
var _ujian_sudah_jalan: Dictionary = {
	1: false,
	2: false,
	3: false,
}

# ─── Variabel Kompatibilitas Lama ─────────────────────────────────────────────
var trash_collected: Dictionary = { "organik": 0, "plastik": 0, "b3": 0 }
var trees_planted: int = 0
var mangroves_planted: int = 0
var current_level: int = 1
var levels_completed: Array[int] = []
var collected_cards: Array[String] = []
var choices: Dictionary = {}

var player_name: String = ""
var debt_amount: int = UTANG_AWAL :
	set(value):
		debt_amount = clampi(value, 0, UTANG_AWAL)
		if not _syncing:
			utang = debt_amount

var parent_shop_status: String = "rusak"
var quest_progress: int = 0

var rupiah: int = 0 :
	set(value):
		rupiah = maxi(0, value)
		if not _syncing:
			uang = rupiah

var day: int = 1 :
	set(value):
		day = clampi(value, 1, 7)
		if not _syncing:
			hari = day

var minutes: int = 8 * 60

var energy: float = 100.0 :
	set(value):
		energy = clampf(value, 0.0, 100.0)
		if not _syncing:
			energi = energy

var relationships: Dictionary = {}
var zone_unlocked: Dictionary = {"hulu": true, "desa": false, "kota": false, "hilir": false}
var debt_paid: int = 0

## Data posisi & objek dunia untuk Save/Load
var saved_scene: String = "res://scenes/world/world_sungai_deli.tscn"
var saved_zone: String = "hulu"
var saved_player_x: float = -1.0
var saved_player_y: float = -1.0
var planted_spots: Array[String] = []
var picked_trash_ids: Array[String] = []

# ─── Fungsi Kontrak Bersama (Tahap 1: GameState & Siklus Hari) ────────────────

## Mengubah Meter Bencana.
## delta positif = Meter Bencana naik (river_health berkurang).
## delta negatif = Meter Bencana turun (river_health bertambah).
func ubah_meter(delta: float) -> void:
	river_health -= delta

func get_meter() -> float:
	return 100.0 - river_health

## Mengatur sikap NPC ("jali", "rina", "darwis") ke nilai -1, 0, 1, atau 2.
## Jika NPC menjadi Peduli (2) untuk pertama kali, Meter turun 10 sekali.
func set_sikap(npc: String, nilai: int) -> void:
	var key: String = npc.to_lower()
	var clamped: int = clampi(nilai, SIKAP_MENOLAK, SIKAP_PEDULI)
	npc_sikap[key] = clamped
	relationships[key] = clamped
	if clamped == SIKAP_PEDULI and not _npc_peduli_bonus.get(key, false):
		_npc_peduli_bonus[key] = true
		ubah_meter(-10.0)
	sikap_changed.emit(key, clamped)

func get_sikap(npc: String) -> int:
	return int(npc_sikap.get(npc.to_lower(), SIKAP_ACUH))

## Menambah uang pemain.
func tambah_uang(n: int) -> void:
	if n <= 0:
		return
	uang += n

## Mengurangi uang pemain jika cukup. Mengembalikan true jika berhasil.
func kurangi_uang(n: int) -> bool:
	if n < 0 or uang < n:
		return false
	uang -= n
	return true

## Membayar utang warung sebanyak n. Mengembalikan true jika berhasil.
func bayar_utang(n: int) -> bool:
	if n <= 0 or utang <= 0:
		return false
	var bayar: int = mini(n, utang)
	if not kurangi_uang(bayar):
		return false
	utang -= bayar
	return true

## Mengubah energi pemain (positif = tambah, negatif = kurang).
func ubah_energi(n: float) -> void:
	energi = clampf(energi + n, 0.0, 100.0)

## Mengatur atau memajukan siklus waktu dalam sehari (pagi -> siang -> sore -> malam).
func set_waktu(fase: String) -> void:
	waktu = fase

func majukan_waktu() -> String:
	var idx: int = FASE_WAKTU.find(waktu)
	if idx < 0 or idx >= FASE_WAKTU.size() - 1:
		waktu = "malam"
	else:
		waktu = FASE_WAKTU[idx + 1]
	return waktu

## Tidur: menjalankan efek malam, memancarkan malam_dimulai,
## memajukan hari, dan memulihkan energi ke 100 (dikurangi penalti ujian hujan jika ada).
func tidur() -> void:
	# Pastikan jika tidur di Hari 3 atau Hari 5 sebelum fase sore, ujian hujan hari itu tetap dicek
	if hari == 3 and not _ujian_sudah_jalan.get(1, false):
		jalankan_ujian_hujan(1)
	elif hari == 5 and not _ujian_sudah_jalan.get(2, false):
		jalankan_ujian_hujan(2)

	_jalankan_efek_malam()
	malam_dimulai.emit()
	if hari < 7:
		hari += 1
	waktu = "pagi"
	energi = clampf(100.0 - penalti_energi_besok, 0.0, 100.0)
	penalti_energi_besok = 0.0
	if Engine.has_singleton("QuestManager") or get_node_or_null("/root/QuestManager") != null:
		get_node("/root/QuestManager").reset_daily_quests()
	save_game()

## Efek malam sesuai spesifikasi:
## - Tiap NPC Acuh (0) atau Menolak (-1) menambah Meter +4
## - Tiap NPC Ragu (1) menambah Meter +2
## - Tiap NPC Peduli (2) menambah 0
## - Jika warung_buka == true, uang bertambah 15000 per hari
func _jalankan_efek_malam() -> void:
	var tambahan_meter: float = 0.0
	for npc_key in ["jali", "rina", "darwis"]:
		var sikap: int = int(npc_sikap.get(npc_key, SIKAP_ACUH))
		if sikap == SIKAP_ACUH or sikap == SIKAP_MENOLAK:
			tambahan_meter += 4.0
		elif sikap == SIKAP_RAGU:
			tambahan_meter += 2.0
	if tambahan_meter > 0.0:
		ubah_meter(tambahan_meter)

	if warung_buka:
		tambah_uang(15000)

# ─── Ujian Hujan (Tahap 3: Hari 3 Sore, Hari 5 Sore, Hari 7 Malam) ────────────

func _cek_otomatis_ujian_hujan() -> void:
	if hari == 3 and waktu == "sore" and not _ujian_sudah_jalan.get(1, false):
		jalankan_ujian_hujan(1)
	elif hari == 5 and waktu == "sore" and not _ujian_sudah_jalan.get(2, false):
		jalankan_ujian_hujan(2)
	elif hari == 7 and waktu == "sore" and not _menu_utang_h7_muncul:
		_menu_utang_h7_muncul = true
		buka_menu_bayar_utang()
	elif hari == 7 and waktu == "malam" and not _ujian_sudah_jalan.get(3, false):
		jalankan_ujian_hujan(3)

## Menjalankan Ujian Hujan (nomor 1, 2, atau 3) berdasarkan Meter Bencana saat ini.
## Mengembalikan hasil: "aman", "genangan", atau "banjir".
func jalankan_ujian_hujan(nomor: int) -> String:
	var m: int = int(round(meter_bencana))
	var hasil: String = "aman"

	match nomor:
		1:
			# Ujian 1 (Hari 3 Sore, Hujan Kecil)
			if m <= 40:
				hasil = "aman"
				show_toast("Ujian Hujan 1: AMAN (Meter %d%%)" % m, true)
			elif m <= 70:
				hasil = "genangan"
				if not kurangi_uang(50000):
					uang = 0
				penalti_energi_besok = 20.0
				show_toast("Ujian Hujan 1: GENANGAN (-Rp50.000, Energi besok -20)", false)
			else:
				hasil = "banjir"
				warung_bersih = false
				penalti_energi_besok = 30.0
				_turunkan_satu_npc(SIKAP_RAGU, SIKAP_MENOLAK)
				show_toast("Ujian Hujan 1: BANJIR (Warung kotor, Energi besok -30, 1 NPC Menolak)", false)

		2:
			# Ujian 2 (Hari 5 Sore, Hujan Sedang)
			if m <= 35:
				hasil = "aman"
				warung_terkunci_sampai_h7 = false
				warung_buka = true
				show_toast("Ujian Hujan 2: AMAN (Warung mulai buka!)", true)
			elif m <= 65:
				hasil = "genangan"
				warung_terkunci_sampai_h7 = true
				warung_buka = false
				show_toast("Ujian Hujan 2: GENANGAN (Warung tutup sampai Hari 7)", false)
			else:
				hasil = "banjir"
				warung_buka = false
				_turunkan_satu_npc(SIKAP_PEDULI, SIKAP_RAGU)
				show_toast("Ujian Hujan 2: BANJIR (1 NPC Peduli turun jadi Ragu)", false)

		3:
			# Ujian Akhir (Hari 7 Malam, Hujan Besar)
			if m <= 40:
				hasil = "aman"
				cutscene_ujian_akhir = "bersih"
				show_toast("Ujian Akhir: AMAN (Cutscene Sungai Bersih)", true)
			elif m <= 60:
				hasil = "genangan"
				cutscene_ujian_akhir = "setengah"
				show_toast("Ujian Akhir: GENANGAN (Cutscene Setengah Bersih)", false)
			else:
				hasil = "banjir"
				cutscene_ujian_akhir = "kotor"
				show_toast("Ujian Akhir: BANJIR BESAR (Cutscene Sungai Kotor)", false)

		_:
			push_warning("GameState: nomor ujian hujan tidak valid: %d" % nomor)
			return ""

	_ujian_sudah_jalan[nomor] = true
	hasil_ujian_hujan[nomor] = hasil
	ujian_hujan_selesai.emit(nomor, hasil)
	return hasil

## Helper untuk menurunkan 1 NPC dari sikap_asal ke sikap_tujuan (dipakai saat banjir)
func _turunkan_satu_npc(sikap_asal: int, sikap_tujuan: int) -> void:
	for npc_key in ["jali", "rina", "darwis"]:
		if int(npc_sikap.get(npc_key, SIKAP_ACUH)) == sikap_asal:
			set_sikap(npc_key, sikap_tujuan)
			break

# ─── Ending Resolver, Menu Utang Hari 7, Puzzle Pintu Air, & Rewind (Tahap 4) ─

func get_jumlah_npc_peduli() -> int:
	var count: int = 0
	for npc_key in ["jali", "rina", "darwis"]:
		if int(npc_sikap.get(npc_key, SIKAP_ACUH)) == SIKAP_PEDULI:
			count += 1
	return count

func get_persen_utang_lunas() -> float:
	return clampf(float(UTANG_AWAL - utang) / float(UTANG_AWAL), 0.0, 1.0)

## Menghitung kode ending ("A", "B", "C", atau "D") tanpa memancarkan sinyal/pindah scene
func hitung_kode_ending() -> String:
	var m: int = int(round(meter_bencana))
	var peduli: int = get_jumlah_npc_peduli()
	var persen_lunas: float = get_persen_utang_lunas()

	if m <= 20 and peduli >= 3 and utang <= 0:
		return "A"
	elif m <= 40 and peduli >= 2 and persen_lunas >= 0.70:
		return "B"
	elif m <= 60 and peduli >= 1:
		return "C"
	return "D"

## Ending Resolver sesuai spesifikasi Orang 1 Sistem Inti:
## Dicek dari atas ke bawah, jatuh ke ending berikutnya jika syarat tidak lengkap.
## - A: Meter <= 20, ketiga NPC Peduli (3), utang lunas 100%
## - B: Meter <= 40, minimal 2 NPC Peduli, utang lunas minimal 70%
## - C: Meter <= 60, minimal 1 NPC Peduli
## - D: selain itu
## Memancarkan ending_ditentukan(kode) dengan kode "A", "B", "C", atau "D".
func tentukan_ending(buka_layar: bool = true) -> String:
	var kode: String = hitung_kode_ending()

	ending_terakhir = kode
	ending_ditentukan.emit(kode)
	show_toast("Ending Ditentukan: Ending %s" % kode, kode in ["A", "B"])

	if buka_layar and is_inside_tree():
		var current_scene := get_tree().current_scene
		if current_scene and current_scene.scene_file_path == "res://scenes/levels/level_5_epilog.tscn" and current_scene.has_method("_show_ending"):
			current_scene._show_ending()
		else:
			SceneManager.change_scene("res://scenes/levels/level_5_epilog.tscn")
	return kode

## Tombol Rewind di Ending D: mereset GameState kembali ke Hari 1 dan memulai dari awal.
func rewind() -> void:
	reset()
	save_game()
	if is_inside_tree():
		SceneManager.change_scene("res://scenes/world/world_sungai_deli.tscn")

## Membuka Menu Bayar Utang Hari 7 Sore (3 pilihan: bayar semua, bayar sebagian via slider, minta waktu)
func buka_menu_bayar_utang() -> void:
	if not is_inside_tree():
		return
	var existing := get_tree().root.get_node_or_null("DebtPaymentPopup")
	if existing:
		existing.queue_free()

	var popup_script := load("res://scripts/debt_payment_popup.gd")
	if popup_script:
		var popup := CanvasLayer.new()
		popup.name = "DebtPaymentPopup"
		popup.set_script(popup_script)
		get_tree().root.add_child(popup)

## Dipanggil saat puzzle tuas pintu air di Hari 7 malam selesai
func selesaikan_puzzle_pintu_air() -> void:
	if puzzle_pintu_air_beres:
		return
	puzzle_pintu_air_beres = true
	ubah_meter(-10.0)
	puzzle_pintu_air_selesai.emit()
	if not _ujian_sudah_jalan.get(3, false):
		jalankan_ujian_hujan(3)
	tentukan_ending(true)

# ─── Fungsi Kompatibilitas Lama ───────────────────────────────────────────────

func add_river_health(amount: float) -> void:
	river_health += amount

func collect_trash(category: String) -> void:
	if trash_collected.has(category):
		trash_collected[category] += 1
	else:
		trash_collected[category] = 1

func plant_tree() -> void:
	trees_planted += 1

func plant_mangrove() -> void:
	mangroves_planted += 1

func unlock_card(card_id: String) -> void:
	if card_id not in collected_cards:
		collected_cards.append(card_id)
		card_unlocked.emit(card_id)

func record_choice(key: String, value: Variant) -> void:
	choices[key] = value

func complete_level(level_id: int) -> void:
	if level_id not in levels_completed:
		levels_completed.append(level_id)
	level_completed.emit(level_id)
	save_game()

func calculate_ending() -> String:
	return tentukan_ending(false)

func get_total_trash() -> int:
	var total: int = 0
	for key in trash_collected:
		total += trash_collected[key]
	return total

func pay_debt(amount: int) -> bool:
	return bayar_utang(amount)

func unlock_zone(zone: String) -> void:
	if zone not in zone_unlocked:
		return
	if zone_unlocked[zone]:
		return
	zone_unlocked[zone] = true
	zone_opened.emit(zone)

func spend_energy(amount: float) -> bool:
	if energi < amount:
		return false
	ubah_energi(-amount)
	return true

func restore_energy(amount: float) -> void:
	ubah_energi(amount)

func sleep() -> void:
	tidur()

## Tampilkan notifikasi toast lewat level/HUD yang sedang aktif
func show_toast(text: String, good: bool = true) -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("toast"):
		level.toast(text, good)

# ─── Save / Load ──────────────────────────────────────────────────────────────

func save_game() -> void:
	# Ambil posisi player & zona dari world jika sedang berada di dalam level
	var level := get_tree().get_first_node_in_group("level") if is_inside_tree() else null
	if level:
		if level.scene_file_path != "":
			saved_scene = level.scene_file_path
		if "_current_zone" in level:
			saved_zone = str(level.get("_current_zone"))
		var p := level.get_node_or_null("Player") as Node2D
		if p:
			saved_player_x = p.global_position.x
			saved_player_y = p.global_position.y

	var data: Dictionary = {
		"hari": hari,
		"waktu": waktu,
		"uang": uang,
		"utang": utang,
		"energi": energi,
		"river_health": river_health,
		"npc_sikap": npc_sikap,
		"npc_peduli_bonus": _npc_peduli_bonus,
		"warung_bersih": warung_bersih,
		"warung_buka": warung_buka,
		"penalti_energi_besok": penalti_energi_besok,
		"warung_terkunci_sampai_h7": warung_terkunci_sampai_h7,
		"hasil_ujian_hujan": hasil_ujian_hujan,
		"cutscene_ujian_akhir": cutscene_ujian_akhir,
		"ending_terakhir": ending_terakhir,
		"puzzle_pintu_air_beres": puzzle_pintu_air_beres,
		"menu_utang_h7_muncul": _menu_utang_h7_muncul,
		"ujian_sudah_jalan": _ujian_sudah_jalan,
		"trash_collected": trash_collected,
		"trees_planted": trees_planted,
		"mangroves_planted": mangroves_planted,
		"current_level": current_level,
		"levels_completed": levels_completed,
		"collected_cards": collected_cards,
		"choices": choices,
		"minutes": minutes,
		"relationships": relationships,
		"player_name": player_name,
		"parent_shop_status": parent_shop_status,
		"quest_progress": quest_progress,
		"zone_unlocked": zone_unlocked,
		"debt_paid": debt_paid,
		"saved_scene": saved_scene,
		"saved_zone": saved_zone,
		"saved_player_x": saved_player_x,
		"saved_player_y": saved_player_y,
		"planted_spots": planted_spots,
		"picked_trash_ids": picked_trash_ids,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var text: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(text) != OK:
		return false

	var parsed: Variant = json.get_data()
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var data: Dictionary = parsed

	# Muat status ujian & menu utang lebih dulu sebelum mengisi hari & waktu
	var loaded_hasil: Dictionary = data.get("hasil_ujian_hujan", {})
	hasil_ujian_hujan = {
		1: str(loaded_hasil.get("1", loaded_hasil.get(1, ""))),
		2: str(loaded_hasil.get("2", loaded_hasil.get(2, ""))),
		3: str(loaded_hasil.get("3", loaded_hasil.get(3, ""))),
	}
	var loaded_ujian_jalan: Dictionary = data.get("ujian_sudah_jalan", {})
	_ujian_sudah_jalan = {
		1: bool(loaded_ujian_jalan.get("1", loaded_ujian_jalan.get(1, false))),
		2: bool(loaded_ujian_jalan.get("2", loaded_ujian_jalan.get(2, false))),
		3: bool(loaded_ujian_jalan.get("3", loaded_ujian_jalan.get(3, false))),
	}
	_menu_utang_h7_muncul = bool(data.get("menu_utang_h7_muncul", false))
	ending_terakhir = str(data.get("ending_terakhir", ""))
	puzzle_pintu_air_beres = bool(data.get("puzzle_pintu_air_beres", false))

	river_health = float(data.get("river_health", 40.0))
	hari = int(data.get("hari", data.get("day", 1)))
	waktu = str(data.get("waktu", "pagi"))
	uang = int(data.get("uang", data.get("rupiah", 0)))
	utang = int(data.get("utang", data.get("debt_amount", UTANG_AWAL)))
	energi = float(data.get("energi", data.get("energy", 100.0)))

	var loaded_sikap: Dictionary = data.get("npc_sikap", {})
	npc_sikap = {
		"jali": int(loaded_sikap.get("jali", SIKAP_ACUH)),
		"rina": int(loaded_sikap.get("rina", SIKAP_ACUH)),
		"darwis": int(loaded_sikap.get("darwis", SIKAP_ACUH)),
	}
	var loaded_bonus: Dictionary = data.get("npc_peduli_bonus", {})
	_npc_peduli_bonus = {
		"jali": bool(loaded_bonus.get("jali", npc_sikap["jali"] == SIKAP_PEDULI)),
		"rina": bool(loaded_bonus.get("rina", npc_sikap["rina"] == SIKAP_PEDULI)),
		"darwis": bool(loaded_bonus.get("darwis", npc_sikap["darwis"] == SIKAP_PEDULI)),
	}
	for npc_key in ["jali", "rina", "darwis"]:
		sikap_changed.emit(npc_key, int(npc_sikap[npc_key]))

	warung_terkunci_sampai_h7 = bool(data.get("warung_terkunci_sampai_h7", false))
	warung_bersih = bool(data.get("warung_bersih", false))
	warung_buka = bool(data.get("warung_buka", false))
	penalti_energi_besok = float(data.get("penalti_energi_besok", 0.0))
	cutscene_ujian_akhir = str(data.get("cutscene_ujian_akhir", ""))

	trash_collected = data.get("trash_collected", { "organik": 0, "plastik": 0, "b3": 0 })
	trees_planted = int(data.get("trees_planted", 0))
	mangroves_planted = int(data.get("mangroves_planted", 0))
	current_level = int(data.get("current_level", 1))

	levels_completed.clear()
	for item in data.get("levels_completed", []):
		levels_completed.append(int(item))

	collected_cards.clear()
	for card in data.get("collected_cards", []):
		collected_cards.append(str(card))

	choices = data.get("choices", {})
	minutes = int(data.get("minutes", 8 * 60))
	relationships = data.get("relationships", {})
	player_name = str(data.get("player_name", ""))
	parent_shop_status = str(data.get("parent_shop_status", "pulih" if warung_bersih else "rusak"))
	quest_progress = int(data.get("quest_progress", 0))
	zone_unlocked = data.get("zone_unlocked", {"hulu": true, "desa": false, "kota": false, "hilir": false})
	debt_paid = int(data.get("debt_paid", UTANG_AWAL - utang))

	saved_scene = str(data.get("saved_scene", "res://scenes/world/world_sungai_deli.tscn"))
	saved_zone = str(data.get("saved_zone", "hulu"))
	saved_player_x = float(data.get("saved_player_x", -1.0))
	saved_player_y = float(data.get("saved_player_y", -1.0))

	planted_spots.clear()
	for spot in data.get("planted_spots", []):
		planted_spots.append(str(spot))

	picked_trash_ids.clear()
	for tid in data.get("picked_trash_ids", []):
		picked_trash_ids.append(str(tid))

	if quest_progress > 0 and get_node_or_null("/root/QuestManager") != null:
		get_node("/root/QuestManager").start_main_quest()
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func reset() -> void:
	river_health = 40.0
	hari = 1
	waktu = "pagi"
	uang = 0
	utang = UTANG_AWAL
	energi = 100.0
	npc_sikap = {
		"jali": SIKAP_ACUH,
		"rina": SIKAP_ACUH,
		"darwis": SIKAP_ACUH,
	}
	_npc_peduli_bonus = {
		"jali": false,
		"rina": false,
		"darwis": false,
	}
	warung_terkunci_sampai_h7 = false
	warung_bersih = false
	warung_buka = false
	penalti_energi_besok = 0.0
	hasil_ujian_hujan = {1: "", 2: "", 3: ""}
	cutscene_ujian_akhir = ""
	ending_terakhir = ""
	puzzle_pintu_air_beres = false
	_menu_utang_h7_muncul = false
	_ujian_sudah_jalan = {1: false, 2: false, 3: false}
	trash_collected = { "organik": 0, "plastik": 0, "b3": 0 }
	trees_planted = 0
	mangroves_planted = 0
	current_level = 1
	levels_completed.clear()
	collected_cards.clear()
	choices = {}
	minutes = 8 * 60
	relationships = {}
	player_name = ""
	parent_shop_status = "rusak"
	quest_progress = 0
	zone_unlocked = {"hulu": true, "desa": false, "kota": false, "hilir": false}
	debt_paid = 0
	saved_scene = "res://scenes/world/world_sungai_deli.tscn"
	saved_zone = "hulu"
	saved_player_x = -1.0
	saved_player_y = -1.0
	planted_spots.clear()
	picked_trash_ids.clear()
	if get_node_or_null("/root/QuestManager") != null:
		var qm := get_node("/root/QuestManager")
		qm.active_quests.clear()
		qm.completed_quests.clear()
		qm.daily_quests.clear()

# ─── Siklus Aplikasi Android ──────────────────────────────────────────────────

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()
