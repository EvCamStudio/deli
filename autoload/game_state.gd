## GameState Autoload
# Menyimpan semua state permainan: kesehatan sungai, sampah, progress, pilihan.
# Dipanggil dari mana saja dengan GameState.method()
extends Node

# ─── Sinyal ───────────────────────────────────────────────────────────────────
signal river_health_changed(new_value: float)
signal card_unlocked(card_id: String)
signal level_completed(level_id: int)

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
		"choices": choices
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

# ─── Siklus Aplikasi Android ──────────────────────────────────────────────────

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		# Otomatis simpan saat aplikasi masuk background
		save_game()
