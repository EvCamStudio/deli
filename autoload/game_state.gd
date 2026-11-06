## GameState Autoload
# Menyimpan semua state permainan: kesehatan sungai, sampah, progress, pilihan.
# Dipanggil dari mana saja dengan GameState.method()
extends Node

# ─── Sinyal ───────────────────────────────────────────────────────────────────
signal river_health_changed(new_value: float)
signal card_unlocked(card_id: String)
signal level_completed(level_id: int)
signal energy_changed(new_value: float)
signal rupiah_changed(new_value: int)
signal day_changed(new_day: int)
signal zone_opened(zone: String)
signal quest_started(quest_id: String)

# ─── State ────────────────────────────────────────────────────────────────────
var river_health: float = 20.0 :
	set(value):
		river_health = clamp(value, 0.0, 100.0)
		river_health_changed.emit(river_health)

var trash_collected: Dictionary = { "organik": 0, "plastik": 0, "b3": 0 }
var trees_planted: int = 0
var mangroves_planted: int = 0
var current_level: int = 1
var levels_completed: Array[int] = []
var collected_cards: Array[String] = []
var choices: Dictionary = {}  # pilihan dialog yang memengaruhi ending
var active_quests: Dictionary = {}  # quest_id -> target (progress dari counter nyata)

# ─── Intro & Scriptwriting (baru) ──────────────────────────────────────────────
var player_name: String = ""
var debt_amount: int = 500000  # utang awal (contoh: 500 ribu rupiah untuk pemulihan warung)
var parent_shop_status: String = "rusak"  # "rusak" → "pulih" → "hidup"
var quest_progress: int = 0

# ─── Life-sim ringan (pilot Citampi) ─────────────────────────────────────────
var rupiah: int = 0 :
	set(value):
		rupiah = value
		rupiah_changed.emit(rupiah)

var day: int = 1 :
	set(value):
		day = value
		day_changed.emit(day)

var minutes: int = 8 * 60

var energy: float = 100.0 :
	set(value):
		energy = clamp(value, 0.0, 100.0)
		energy_changed.emit(energy)

var relationships: Dictionary = {}
var zone_unlocked: Dictionary = {"hulu": true, "desa": false, "kota": false, "hilir": false}
var debt_paid: int = 0  # track cicilan yang sudah dibayar

const SAVE_PATH: String = "user://save.json"

# ─── Fungsi Publik ────────────────────────────────────────────────────────────

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

## Tandai quest aktif. Progress tidak disimpan di sini — pakai counter nyata.
func start_quest(quest_id: String, target: int) -> bool:
	if quest_id.is_empty():
		return false
	if active_quests.has(quest_id):
		return false
	active_quests[quest_id] = target
	quest_started.emit(quest_id)
	return true

func has_quest(quest_id: String) -> bool:
	return active_quests.has(quest_id)

func quest_target(quest_id: String) -> int:
	return int(active_quests.get(quest_id, 0))

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

## Pay debt (cicilan)
func pay_debt(amount: int) -> bool:
	if rupiah < amount:
		return false
	rupiah -= amount
	debt_paid += amount
	debt_amount -= amount
	if debt_amount < 0:
		debt_amount = 0
	return true

## Unlock zone by river health threshold
func unlock_zone(zone: String) -> void:
	if zone not in zone_unlocked:
		return
	if zone_unlocked[zone]:
		return
	zone_unlocked[zone] = true
	zone_opened.emit(zone)

## Spend energy
func spend_energy(amount: float) -> bool:
	if energy < amount:
		return false
	energy -= amount
	return true

## Restore energy
func restore_energy(amount: float) -> void:
	energy += amount

## Sleep (reset day, restore energy, reset daily quests)
func sleep() -> void:
	day += 1
	energy = 100.0
	minutes = 8 * 60
	# Trigger daily event atau quest reset via QuestManager
	save_game()

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
		"active_quests": active_quests,
		"rupiah": rupiah,
		"day": day,
		"minutes": minutes,
		"energy": energy,
		"relationships": relationships,
		"player_name": player_name,
		"debt_amount": debt_amount,
		"parent_shop_status": parent_shop_status,
		"quest_progress": quest_progress,
		"zone_unlocked": zone_unlocked,
		"debt_paid": debt_paid
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
	current_level = int(data.get("current_level", 1))
	levels_completed.clear()
	for level in data.get("levels_completed", []):
		levels_completed.append(int(level))
	collected_cards.clear()
	for card in data.get("collected_cards", []):
		collected_cards.append(str(card))
	choices = data.get("choices", {})
	active_quests = data.get("active_quests", {})
	rupiah = int(data.get("rupiah", 0))
	day = int(data.get("day", 1))
	minutes = int(data.get("minutes", 8 * 60))
	energy = float(data.get("energy", 100.0))
	relationships = data.get("relationships", {})
	player_name = str(data.get("player_name", ""))
	debt_amount = int(data.get("debt_amount", 500000))
	parent_shop_status = str(data.get("parent_shop_status", "rusak"))
	quest_progress = int(data.get("quest_progress", 0))
	zone_unlocked = data.get("zone_unlocked", {"hulu": true, "desa": false, "kota": false, "hilir": false})
	debt_paid = int(data.get("debt_paid", 0))
	return true

func has_save() -> bool:
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
	return json.get_data() is Dictionary

func delete_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func reset() -> void:
	river_health = 20.0
	trash_collected = { "organik": 0, "plastik": 0, "b3": 0 }
	trees_planted = 0
	mangroves_planted = 0
	current_level = 1
	levels_completed = []
	collected_cards = []
	choices = {}
	active_quests = {}
	rupiah = 0
	day = 1
	minutes = 8 * 60
	energy = 100.0
	relationships = {}
	player_name = ""
	debt_amount = 500000
	parent_shop_status = "rusak"
	quest_progress = 0
	zone_unlocked = {"hulu": true, "desa": false, "kota": false, "hilir": false}
	debt_paid = 0
	delete_save()

# ─── Siklus Aplikasi Android ──────────────────────────────────────────────────

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		# Otomatis simpan saat aplikasi masuk background
		save_game()
