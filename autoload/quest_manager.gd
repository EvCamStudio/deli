## Quest Manager — mengelola quest utama, harian, dan side quest.
extends Node

signal quest_started(quest_id: String)
signal quest_updated(quest_id: String, progress: int)
signal quest_completed(quest_id: String)

var active_quests: Dictionary = {}  # quest_id → {progress, target, description, type}
var completed_quests: Array[String] = []
var daily_quests: Array[String] = []

const MAIN_QUEST_ID: String = "pulihkan_warung_sungai"

func _ready() -> void:
	pass

## Start main quest (triggered by Ibu's dialogue)
func start_main_quest() -> void:
	if MAIN_QUEST_ID in active_quests:
		return
	
	active_quests[MAIN_QUEST_ID] = {
		"type": "main",
		"description": "Pulihkan Warung & Sungai",
		"progress": 0,
		"target": 100,  # river_health + debt_paid combined
	}
	quest_started.emit(MAIN_QUEST_ID)
	GameState.quest_progress = 1

## Add daily quest (reset on sleep)
func add_daily_quest(quest_id: String, description: String, target: int) -> void:
	if quest_id in active_quests:
		return
	
	active_quests[quest_id] = {
		"type": "daily",
		"description": description,
		"progress": 0,
		"target": target,
	}
	daily_quests.append(quest_id)
	quest_started.emit(quest_id)

## Add side quest
func add_side_quest(quest_id: String, description: String, target: int) -> void:
	if quest_id in active_quests:
		return
	
	active_quests[quest_id] = {
		"type": "side",
		"description": description,
		"progress": 0,
		"target": target,
	}
	quest_started.emit(quest_id)

## Add side quest with NPC trigger (used in dialogue effect)
func trigger_npc_quest(quest_id: String, description: String, target: int) -> void:
	add_side_quest(quest_id, description, target)
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("toast"):
		level.toast("Quest diterima: %s" % description, true)

## Update quest progress
func update_quest(quest_id: String, amount: int) -> void:
	if quest_id not in active_quests:
		return
	
	var quest: Dictionary = active_quests[quest_id]
	quest["progress"] = mini(quest["progress"] + amount, quest["target"])
	quest_updated.emit(quest_id, quest["progress"])
	
	if quest["progress"] >= quest["target"]:
		complete_quest(quest_id)

## Complete quest
func complete_quest(quest_id: String) -> void:
	if quest_id not in active_quests:
		return
	
	completed_quests.append(quest_id)
	active_quests.erase(quest_id)
	quest_completed.emit(quest_id)

## Reset daily quests (called on sleep)
func reset_daily_quests() -> void:
	for quest_id in daily_quests:
		active_quests.erase(quest_id)
	daily_quests.clear()

## Get current main quest text — satu tujuan singkat, bukan dump statistik.
func get_main_quest_text() -> String:
	if MAIN_QUEST_ID not in active_quests:
		return ""
	
	var river_pct: int = int(round(GameState.river_health))
	if river_pct < 40:
		return "Bersihkan Hulu — %d%% / 40%%" % river_pct
	if river_pct < 60:
		return "Bersihkan Desa — %d%% / 60%%" % river_pct
	if river_pct < 80:
		return "Bersihkan Kota — %d%% / 80%%" % river_pct
	if GameState.debt_amount > 0:
		return "Lunasi utang warung — sisa Rp %s" % _format_rupiah(GameState.debt_amount)
	return "Sungai pulih! Kembali ke warung Ibu."

func _format_rupiah(amount: int) -> String:
	var s: String = str(amount)
	var result: String = ""
	for i in range(s.length()):
		if i > 0 and (s.length() - i) % 3 == 0:
			result += "."
		result += s[i]
	return result

## Check if main quest started
func is_main_quest_active() -> bool:
	return MAIN_QUEST_ID in active_quests
