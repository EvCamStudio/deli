## GameState Autoload (Deli Rewind — Master Game System)
## Mengelola seluruh state simulasi 7 hari, Meter Bencana, Sikap NPC,
## Ekonomi, Utang Rp 500.000, Energi, Siklus Tidur, dan Ending.
extends Node

# ─── Sinyal ───────────────────────────────────────────────────────────────────
signal meter_changed(new_val: float)
signal river_health_changed(new_val: float)
signal energi_changed(new_val: float)
signal rupiah_changed(new_val: int)
signal utang_changed(new_val: int)
signal hari_berganti(hari_baru: int)
signal npc_sikap_changed(npc: String, nilai: int)
signal warung_pulih_changed(status: bool)
signal ujian_hujan_dipicu(nomor_ujian: int)
signal ending_ditentukan(kode: String)
signal card_unlocked(card_id: String)
signal level_completed(level_id: int)

# ─── 1. Status Utama (Meter Bencana & Sungai) ──────────────────────────────────
# Meter Bencana: 0 (Aman/Jernih) s/d 100 (Bencana/Banjir). Mulai di 60.
var meter_bencana: float = 60.0 :
	set(value):
		meter_bencana = clamp(value, 0.0, 100.0)
		river_health = 100.0 - meter_bencana
		meter_changed.emit(meter_bencana)

var river_health: float = 40.0 :
	set(value):
		river_health = clamp(value, 0.0, 100.0)
		river_health_changed.emit(river_health)

# ─── 2. Siklus Hari & Waktu ───────────────────────────────────────────────────
var hari: int = 1 :
	set(value):
		hari = clamp(value, 1, 7)
		day = hari

var day: int = 1
var player_name: String = "Pemain"

# ─── 3. Energi & Stamina (⚡ 0–100) ───────────────────────────────────────────
var energi: float = 100.0 :
	set(value):
		energi = clamp(value, 0.0, 100.0)
		energy = energi
		energi_changed.emit(energi)

var energy: float = 100.0

# ─── 4. Ekonomi & Utang (💰 Rp) ───────────────────────────────────────────────
var rupiah: int = 15000 :
	set(value):
		rupiah = maxi(0, value)
		rupiah_changed.emit(rupiah)

var utang: int = 500000 :
	set(value):
		utang = maxi(0, value)
		utang_changed.emit(utang)

var utang_awal: int = 500000
var warung_bersih: bool = false :
	set(value):
		warung_bersih = value
		warung_pulih_changed.emit(warung_bersih)

# ─── 5. Sikap 3 NPC Pembuang Sampah ───────────────────────────────────────────
# -1: Menolak, 0: Acuh, 1: Ragu, 2: Peduli
var npc_sikap: Dictionary = {
	"jali": 0,
	"rina": 0,
	"darwis": 0
}

# Objek Dunia Terbuka (Muncul saat NPC Peduli)
var tps_aktif: bool = false
var jelantah_aktif: bool = false

# Batasan Harian
var setoran_sampah_hari_ini: int = 0
var pohon_ditanam_hari_ini: int = 0

# Status Ujian
var ujian1_selesai: bool = false
var ujian2_selesai: bool = false
var ujian_akhir_selesai: bool = false

# Koleksi Sampah & Kartu
var trash_collected: Dictionary = { "organik": 0, "plastik": 0, "b3": 0 }
var trees_planted: int = 0
var mangroves_planted: int = 0
var collected_cards: Array[String] = []
var choices: Dictionary = {}

const SAVE_PATH: String = "user://save_deli.json"

# ─── Fungsi Perubahan State Publik ────────────────────────────────────────────

## Ubah Meter Bencana (+ naik/bahaya, - turun/aman)
func ubah_meter(delta: float) -> void:
	self.meter_bencana += delta

## Set Sikap NPC (-1: Menolak, 0: Acuh, 1: Ragu, 2: Peduli)
func set_sikap(npc: String, nilai: int) -> void:
	var key: String = npc.to_lower()
	npc_sikap[key] = nilai
	if key == "jali" and nilai == 2:
		tps_aktif = true
	elif key == "rina" and nilai == 2:
		jelantah_aktif = true
	npc_sikap_changed.emit(key, nilai)

## Gunakan energi untuk aksi (kembalikan true jika energi cukup)
func pakai_energi(jumlah: float) -> bool:
	if energi >= jumlah:
		self.energi -= jumlah
		return true
	return false

func tambah_rupiah(jumlah: int) -> void:
	self.rupiah += jumlah

func kurangi_uang(n: int) -> void:
	self.rupiah = maxi(0, rupiah - n)

func bayar_utang(jumlah: int) -> int:
	var bayar := mini(jumlah, rupiah)
	bayar = mini(bayar, utang)
	self.rupiah -= bayar
	self.utang -= bayar
	return bayar

## Bersihkan warung orang tua (biaya Rp 50.000)
func bersihkan_warung() -> bool:
	if warung_bersih:
		return true
	if rupiah >= 50000:
		kurangi_uang(50000)
		self.warung_bersih = true
		ubah_meter(-5.0)
		return true
	return false

# ─── Pengepul Sampah & Tanam Pohon ────────────────────────────────────────────

func setor_sampah_pengepul() -> bool:
	if setoran_sampah_hari_ini >= 5:
		return false # Maksimal 5x sehari (-10 Meter max)
	if not pakai_energi(5.0):
		return false

	setoran_sampah_hari_ini += 1
	ubah_meter(-2.0)
	tambah_rupiah(6000) # Dapat upah Rp 6.000 per setoran sampah terpilah
	return true

func tanam_pohon_harian() -> bool:
	if pohon_ditanam_hari_ini >= 3:
		return false # Maksimal 3 pohon sehari (-9 Meter max)
	if not pakai_energi(10.0):
		return false

	pohon_ditanam_hari_ini += 1
	trees_planted += 1
	ubah_meter(-3.0)
	return true

# ─── Siklus Tidur & Pergantian Hari (Kasur Warung) ────────────────────────────

## Dipanggil saat MC berinteraksi dengan kasur di warung untuk tidur malam.
func tidur_ganti_hari() -> void:
	# 1. Evaluasi Sampah Malam Hari dari NPC yang belum peduli
	var meter_tambahan: float = 0.0
	for npc in ["jali", "rina", "darwis"]:
		var status_sikap: int = npc_sikap.get(npc, 0)
		if status_sikap <= 0: # Acuh (0) atau Menolak (-1)
			meter_tambahan += 4.0
		elif status_sikap == 1: # Ragu (1)
			meter_tambahan += 2.0
		# Peduli (2): +0 (tidak menambah sampah)

	ubah_meter(meter_tambahan)

	# 2. Pendapatan pasif warung jika sudah bersih
	if warung_bersih:
		tambah_rupiah(15000) # Warung jualan kopi/gorengan menghasilkan Rp 15.000/hari

	# 3. Pulihkan energi penuh
	self.energi = 100.0

	# 4. Reset batas harian
	setoran_sampah_hari_ini = 0
	pohon_ditanam_hari_ini = 0

	# 5. Ganti Hari
	if hari < 7:
		self.hari += 1
		hari_berganti.emit(hari)
		save_game()
		_cek_event_pagi_hari(hari)
	else:
		# Sudah akhir hari 7: picu evaluasi ending
		evaluasi_ending()

func _cek_event_pagi_hari(hari_baru: int) -> void:
	match hari_baru:
		3:
			# Hari 3: Hari Bang Jali (Solusi) & Sore Ujian 1
			pass
		5:
			# Hari 5: Hari Kak Rina (Solusi) & Sore Ujian 2
			pass
		7:
			# Hari 7: Pagi Pantun, Sore Bang Ucok, Malam Ujian Akhir
			pass

# ─── Evaluasi 4 Ending (Berdasarkan Dokumen Utama Bagian 7) ────────────────────

func evaluasi_ending() -> String:
	var jumlah_peduli: int = 0
	for npc in npc_sikap:
		if npc_sikap[npc] == 2:
			jumlah_peduli += 1

	var utang_lunas_pct: float = float(utang_awal - utang) / float(utang_awal) * 100.0
	var kode_ending: String = "D"

	# Syarat dicek dari atas ke bawah:
	# Ending A: Meter <= 20, 3 NPC Peduli, Utang 100% lunas
	if meter_bencana <= 20.0 and jumlah_peduli >= 3 and utang == 0:
		kode_ending = "A"
	# Ending B: Meter 21..40, minimal 2 NPC Peduli, Utang minimal 70% lunas
	elif meter_bencana <= 40.0 and jumlah_peduli >= 2 and utang_lunas_pct >= 70.0:
		kode_ending = "B"
	# Ending C: Meter 41..60, minimal 1 NPC Peduli
	elif meter_bencana <= 60.0 and jumlah_peduli >= 1:
		kode_ending = "C"
	# Ending D: Meter > 60 atau tidak ada NPC Peduli
	else:
		kode_ending = "D"

	ending_ditentukan.emit(kode_ending)
	return kode_ending

## Rewind: Mengulang kembali permainan ke Hari 1
func reset_ke_hari_1() -> void:
	meter_bencana = 60.0
	hari = 1
	energi = 100.0
	rupiah = 15000
	utang = 500000
	warung_bersih = false
	tps_aktif = false
	jelantah_aktif = false
	npc_sikap = {"jali": 0, "rina": 0, "darwis": 0}
	setoran_sampah_hari_ini = 0
	pohon_ditanam_hari_ini = 0
	ujian1_selesai = false
	ujian2_selesai = false
	ujian_akhir_selesai = false
	save_game()

func reset() -> void:
	reset_ke_hari_1()

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func get_total_trash() -> int:
	var total: int = 0
	for k in trash_collected:
		total += trash_collected[k]
	return total

# ─── Save / Load ──────────────────────────────────────────────────────────────

func save_game() -> void:
	var data := {
		"meter_bencana": meter_bencana,
		"hari": hari,
		"energi": energi,
		"rupiah": rupiah,
		"utang": utang,
		"warung_bersih": warung_bersih,
		"npc_sikap": npc_sikap,
		"tps_aktif": tps_aktif,
		"jelantah_aktif": jelantah_aktif,
		"player_name": player_name
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
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(text) != OK:
		return false
	var d = json.get_data()
	if d is Dictionary:
		meter_bencana = float(d.get("meter_bencana", 60.0))
		hari = int(d.get("hari", 1))
		energi = float(d.get("energi", 100.0))
		rupiah = int(d.get("rupiah", 15000))
		utang = int(d.get("utang", 500000))
		warung_bersih = bool(d.get("warung_bersih", false))
		npc_sikap = d.get("npc_sikap", {"jali": 0, "rina": 0, "darwis": 0})
		tps_aktif = bool(d.get("tps_aktif", false))
		jelantah_aktif = bool(d.get("jelantah_aktif", false))
		player_name = str(d.get("player_name", "Pemain"))
		return true
	return false
