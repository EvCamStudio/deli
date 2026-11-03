## GameState Autoload
# Menyimpan semua state permainan: kesehatan sungai, sampah, progress, pilihan.
# Dipanggil dari mana saja dengan GameState.method()
extends Node

# ─── Sinyal ───────────────────────────────────────────────────────────────────
signal river_health_changed(new_value: float)
signal card_unlocked(card_id: String)
signal level_completed(level_id: int)
signal ujian_hujan_selesai(nomor: int, hasil: String)
signal ending_ditentukan(kode: String)
signal npc_sikap_changed(npc: String, nilai: int)

# ─── State ────────────────────────────────────────────────────────────────────
var river_health: float = 40.0 :
	set(value):
		river_health = clamp(value, 0.0, 100.0)
		river_health_changed.emit(river_health)

var meter_bencana: float = 60.0 :
	set(value):
		meter_bencana = clamp(value, 0.0, 100.0)
		river_health = 100.0 - meter_bencana

var npc_sikap: Dictionary = {
	"jali": 0,    # -1: Menolak, 0: Acuh, 1: Ragu, 2: Peduli
	"rina": 0,
	"darwis": 0
}
var hari: int = 1:
	set(value):
		hari = value
		day = value

var trash_collected: Dictionary = { "organik": 0, "plastik": 0, "b3": 0 }
var trees_planted: int = 0
var mangroves_planted: int = 0
var current_level: int = 1
var levels_completed: Array[int] = []
var collected_cards: Array[String] = []
var choices: Dictionary = {}  # pilihan dialog yang memengaruhi ending

# ─── Intro & Scriptwriting (baru) ──────────────────────────────────────────────
var player_name: String = ""
var debt_amount: int = 500000  # utang awal (contoh: 500 ribu rupiah untuk pemulihan warung)
var parent_shop_status: String = "rusak"  # "rusak" → "pulih" → "hidup"
var quest_progress: int = 0

# ─── Life-sim ringan (pilot Citampi) ─────────────────────────────────────────
var rupiah: int = 0
var day: int = 1
var minutes: int = 8 * 60
var energy: float = 100.0
var relationships: Dictionary = {}

const SAVE_PATH: String = "user://save.json"

# ─── Fungsi Publik ────────────────────────────────────────────────────────────

func add_river_health(amount: float) -> void:
	river_health += amount
	meter_bencana = clamp(100.0 - river_health, 0.0, 100.0)

## Kontrak Orang 1 & 2: Ubah Meter Bencana (+ naik/bahaya, - turun/aman)
func ubah_meter(delta: float) -> void:
	meter_bencana = clamp(meter_bencana + delta, 0.0, 100.0)
	river_health = 100.0 - meter_bencana

## Kontrak Orang 1 & 2: Set sikap NPC (-1: Menolak, 0: Acuh, 1: Ragu, 2: Peduli)
func set_sikap(npc: String, nilai: int) -> void:
	var key: String = npc.to_lower()
	npc_sikap[key] = nilai
	npc_sikap_changed.emit(key, nilai)

## Kontrak Orang 1 & 2: Kurangi uang
func kurangi_uang(n: int) -> void:
	rupiah = maxi(0, rupiah - n)

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

## Hitung ending berdasarkan river_health akhir dan pilihan dialog.
func calculate_ending() -> String:
	var good_choices: int = 0
	for key in choices:
		if choices[key] == true:
			good_choices += 1

	if river_health >= 75 and good_choices >= 3:
		return "baik"
	elif river_health >= 45 or good_choices >= 2:
		return "biasa"
	else:
		return "buruk"

func get_total_trash() -> int:
	var total: int = 0
	for key in trash_collected:
		total += trash_collected[key]
	return total

# ─── Save / Load ──────────────────────────────────────────────────────────────

func save_game() -> void:
	var data: Dictionary = {
		"river_health": river_health,
		"trash_collected": trash_collected,
		"trees_planted": trees_planted,
		"mangroves_planted": mangroves_planted,
		"current_level": current_level,
		"levels_completed": levels_completed,
		"collected_cards": collected_cards,
		"choices": choices,
		"rupiah": rupiah,
		"day": day,
		"minutes": minutes,
		"energy": energy,
		"relationships": relationships,
		"player_name": player_name,
		"debt_amount": debt_amount,
		"parent_shop_status": parent_shop_status,
		"quest_progress": quest_progress
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

	var data: Dictionary = json.get_data()
	river_health = data.get("river_health", 20.0)
	trash_collected = data.get("trash_collected", { "organik": 0, "plastik": 0, "b3": 0 })
	trees_planted = data.get("trees_planted", 0)
	mangroves_planted = data.get("mangroves_planted", 0)
	current_level = data.get("current_level", 1)
	levels_completed = data.get("levels_completed", [])
	collected_cards = data.get("collected_cards", [])
	choices = data.get("choices", {})
	rupiah = int(data.get("rupiah", 0))
	day = int(data.get("day", 1))
	minutes = int(data.get("minutes", 8 * 60))
	energy = float(data.get("energy", 100.0))
	relationships = data.get("relationships", {})
	player_name = str(data.get("player_name", ""))
	debt_amount = int(data.get("debt_amount", 500000))
	parent_shop_status = str(data.get("parent_shop_status", "rusak"))
	quest_progress = int(data.get("quest_progress", 0))
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func reset() -> void:
	river_health = 20.0
	trash_collected = { "organik": 0, "plastik": 0, "b3": 0 }
	trees_planted = 0
	mangroves_planted = 0
	current_level = 1
	levels_completed = []
	collected_cards = []
	choices = {}
	rupiah = 0
	day = 1
	minutes = 8 * 60
	energy = 100.0
	relationships = {}
	player_name = ""
	debt_amount = 500000
	parent_shop_status = "rusak"
	quest_progress = 0

# ─── Siklus Aplikasi Android ──────────────────────────────────────────────────

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		# Otomatis simpan saat aplikasi masuk background
		save_game()
