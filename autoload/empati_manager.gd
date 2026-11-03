## EmpatiManager Autoload (Orang 2: Dialog & NPC)
## Mengelola sistem Empati 3 Langkah (Dengarkan -> Pahami -> Solusi Bersama)
## dan dinamika sikap NPC: Menolak (-1), Acuh (0), Ragu (1), Peduli (2).
extends Node

# ─── Sinyal (Kontrak Lomba Orang 2 & Orang 3) ──────────────────────────────────
signal langkah_selesai(npc: String, langkah: int, tipe: String)
signal npc_peduli(npc: String)
signal npc_ragu(npc: String)
signal npc_menolak(npc: String)
signal sampah_balasan(npc: String)
signal tps_terbuka()
signal jelantah_terbuka()
signal datuk_opacity_changed(new_opacity: float)

# ─── Riwayat Pilihan per NPC ──────────────────────────────────────────────────
# Format: {"jali": ["A", "A", "A"], "rina": ["A", "B", "A"], ...}
var riwayat_pilihan: Dictionary = {
	"jali": [],
	"rina": [],
	"darwis": []
}

var kesempatan_ulang_b: Dictionary = {
	"jali": true,
	"rina": true,
	"darwis": true
}

func _ready() -> void:
	pass

# ─── Mulai Langkah Empati ─────────────────────────────────────────────────────

## Memulai langkah empati tertentu untuk NPC.
## Jali: Langkah 1 & 2 di Hari 2 ("h2_jali"), Langkah 3 di Hari 3 ("h3_jali").
## Rina: Langkah 1 & 2 di Hari 4 ("h4_rina"), Langkah 3 di Hari 5 ("h5_rina").
## Darwis: Langkah 1, 2, 3 di Hari 6 ("h6_darwis").
func mulai(npc: String, langkah: int = 1) -> void:
	var key := npc.to_lower()
	var dialog_id := ""

	match key:
		"jali":
			if langkah <= 2:
				dialog_id = "h2_jali"
			else:
				dialog_id = "h3_jali"
		"rina":
			if langkah <= 2:
				dialog_id = "h4_rina"
			else:
				dialog_id = "h5_rina"
		"darwis":
			dialog_id = "h6_darwis"
		_:
			dialog_id = "h2_jali"

	DialogueManager.mulai(dialog_id)

# ─── Pencatatan Pilihan dari DialogueManager ──────────────────────────────────

func catat_pilihan(npc: String, tipe: String, delta_meter: float, delta_sikap: int) -> void:
	var key := npc.to_lower()
	if not riwayat_pilihan.has(key):
		riwayat_pilihan[key] = []

	riwayat_pilihan[key].append(tipe.to_upper())

	# Jika pilihan C (menyalahkan):
	if tipe.to_upper() == "C":
		GameState.set_sikap(key, -1) # Menolak langsung
		sampah_balasan.emit(key)
		npc_menolak.emit(key)
		return

	# Cek apakah sudah menyelesaikan Langkah 3 (Solusi)
	# Untuk Jali & Rina: 3 langkah (Dengarkan, Pahami, Solusi)
	# Untuk Darwis: 3 langkah
	if riwayat_pilihan[key].size() >= 3:
		_evaluasi_hasil_akhir(key)

func _evaluasi_hasil_akhir(npc: String) -> void:
	var history: Array = riwayat_pilihan.get(npc, [])
	var ada_c: bool = false
	var ada_b: bool = false
	var semua_a: bool = true

	for t in history:
		if t == "C":
			ada_c = true
			semua_a = false
		elif t == "B":
			ada_b = true
			semua_a = false

	if ada_c:
		GameState.set_sikap(npc, -1)
		npc_menolak.emit(npc)
	elif semua_a:
		# Semua A = Peduli (Nilai 2, Meter -10 sekali)
		GameState.set_sikap(npc, 2)
		GameState.ubah_meter(-10.0)
		npc_peduli.emit(npc)
		
		# Sinyal spawn ke Orang 3
		if npc == "jali":
			tps_terbuka.emit()
		elif npc == "rina":
			jelantah_terbuka.emit()
	else:
		# Ada B = Ragu (Nilai 1)
		GameState.set_sikap(npc, 1)
		npc_ragu.emit(npc)

	# Update opacity Datuk Sampan setiap status sikap berubah
	datuk_opacity_changed.emit(get_datuk_opacity())

# ─── Logika Datuk Sampan ──────────────────────────────────────────────────────

## Menghitung jumlah warga yang berstatus Peduli (nilai 2)
func get_jumlah_peduli() -> int:
	var count: int = 0
	for npc in GameState.npc_sikap:
		if GameState.npc_sikap[npc] == 2:
			count += 1
	return count

## Transparansi Datuk mengikuti jumlah NPC Peduli: 0.4 + 0.2 * jumlah_peduli
func get_datuk_opacity() -> float:
	return clamp(0.4 + 0.2 * float(get_jumlah_peduli()), 0.4, 1.0)
