## Regression test untuk Level 1, 2, dan 4 versi top-down.
extends Node

var _failures: int = 0

func _ready() -> void:
	call_deferred("_run")

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: ", label)
	else:
		_failures += 1
		printerr("FAIL: ", label)

func _frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _finish_dialogue() -> void:
	while DialogueManager.is_active():
		var choices: Array = DialogueManager._current_node.get("choices", [])
		if choices.is_empty():
			DialogueManager.advance()
		else:
			DialogueManager.advance(0)
		await _frames(1)

func _free_level(level: Node) -> void:
	get_tree().paused = false
	level.queue_free()
	await _frames(4)

func _collect(level: Node) -> Dictionary:
	var out: Dictionary = {"npcs": [], "trash": [], "bins": [], "spots": [], "gate": null}
	for child in level.get_children():
		if child is NPC:
			out["npcs"].append(child)
		elif child is TrashItem:
			out["trash"].append(child)
		elif child is PilotBin:
			out["bins"].append(child)
		elif child is TreeSpotTopDown:
			out["spots"].append(child)
		elif child is PilotGate:
			out["gate"] = child
	return out

func _sort_all(trash: Array, bins: Array) -> void:
	for item in trash:
		if not is_instance_valid(item):
			continue
		item.interact()
		await _frames(1)
		var pending: Array = GameState.get_meta("pending_trash")
		if pending.is_empty():
			continue
		var category: String = str(pending[0].get("category", ""))
		for b in bins:
			if b.bin_category == category:
				b.interact()
				break
		await _frames(1)

func _run() -> void:
	for level_id in [1, 2, 3, 4, 5]:
		var path: String = "res://scenes/levels/level_%d_%s.tscn" % [level_id, SceneManager._level_suffix(level_id)]
		_check(ResourceLoader.exists(path), "SceneManager path for level %d" % level_id)
	await _test_level_1()
	await _test_level_2()
	await _test_level_4()
	print("RESULT: %s (%d failures)" % ["PASS" if _failures == 0 else "FAIL", _failures])
	get_tree().quit(1 if _failures > 0 else 0)

# ─── Level 1 ─────────────────────────────────────────────────────────────────

func _test_level_1() -> void:
	print("--- LEVEL 1 ---")
	GameState.reset()
	var level: Node = load("res://scenes/levels/level_1_hulu_topdown.tscn").instantiate()
	get_tree().root.add_child(level)
	await _frames(6)

	var nodes := _collect(level)
	_check(nodes["npcs"].size() == 2, "L1: 2 NPCs spawned")
	_check(nodes["spots"].size() == 5, "L1: 5 tree spots spawned")
	_check(nodes["gate"] != null and nodes["gate"]._open, "L1: gate starts open")

	var player: Node = level.get_node("Player")
	player._on_area_entered(nodes["spots"][0])
	_check(player._interactable == nodes["spots"][0], "L1: player detects tree spot")
	_check(nodes["spots"][0].get_action_label() == "Tanam Pohon", "L1: tree spot action label")

	var npc: Node = null
	for candidate in nodes["npcs"]:
		if candidate.npc_key == "npc_penjaga_hutan":
			npc = candidate
			break
	_check(npc != null, "L1: penjaga hutan found")
	npc.interact()
	await _frames(2)
	_check(DialogueManager.is_active(), "L1: penjaga dialogue starts")
	await _finish_dialogue()
	_check(not DialogueManager.is_active(), "L1: penjaga dialogue ends")
	_check(GameState.collected_cards.has("card_sungai_deli_01"), "L1: river card unlocked")

	for spot in nodes["spots"]:
		spot.interact()
	await _frames(4)
	_check(GameState.trees_planted == 5, "L1: 5 trees planted")
	_check(GameState.collected_cards.has("card_hutan_01"), "L1: forest card unlocked")
	_check(GameState.river_health >= 40.0, "L1: river health reaches target")

	level.try_complete_level()
	await _frames(3)
	_check(GameState.levels_completed.has(1), "L1: level marked complete")
	var hud: Node = level.get_node("HUD")
	_check(hud.completion.visible, "L1: completion panel visible")
	_check(hud.completion_title.text == "BAB 1 SELESAI!", "L1: completion title")

	await _free_level(level)

# ─── Level 2 ─────────────────────────────────────────────────────────────────

func _test_level_2() -> void:
	print("--- LEVEL 2 ---")
	GameState.reset()
	var level: Node = load("res://scenes/levels/level_2_desa_topdown.tscn").instantiate()
	get_tree().root.add_child(level)
	await _frames(6)

	var nodes := _collect(level)
	_check(nodes["npcs"].size() == 2, "L2: 2 NPCs spawned")
	_check(nodes["trash"].size() == 10, "L2: 10 trash spawned")
	_check(nodes["bins"].size() == 2, "L2: 2 bins spawned")
	_check(nodes["gate"] != null and nodes["gate"]._open, "L2: gate starts open")

	for npc in nodes["npcs"]:
		npc.interact()
		await _frames(2)
		await _finish_dialogue()
	_check(level.talked_count() == 2, "L2: both villagers talked")
	_check(GameState.collected_cards.has("card_pertanian_01"), "L2: farming card unlocked")
	_check(GameState.collected_cards.has("card_gotong_royong_01"), "L2: gotong royong card unlocked")

	await _sort_all(nodes["trash"], nodes["bins"])
	_check(level._sorted == 10, "L2: 10 trash sorted")
	_check(GameState.river_health >= 55.0, "L2: river health reaches target")

	level.try_complete_level()
	await _frames(3)
	_check(GameState.levels_completed.has(2), "L2: level marked complete")
	var hud: Node = level.get_node("HUD")
	_check(hud.completion.visible, "L2: completion panel visible")
	_check(hud.completion_title.text == "BAB 2 SELESAI!", "L2: completion title")

	await _free_level(level)

# ─── Level 4 ─────────────────────────────────────────────────────────────────

func _test_level_4() -> void:
	print("--- LEVEL 4 ---")
	GameState.reset()
	var level: Node = load("res://scenes/levels/level_4_hilir_topdown.tscn").instantiate()
	get_tree().root.add_child(level)
	await _frames(6)

	var nodes := _collect(level)
	_check(nodes["npcs"].size() == 2, "L4: 2 NPCs spawned")
	_check(nodes["spots"].size() == 8, "L4: 8 mangrove spots spawned")
	_check(nodes["trash"].size() == 8, "L4: 8 trash spawned")
	_check(nodes["bins"].size() == 3, "L4: 3 bins spawned")
	_check(nodes["gate"] != null and nodes["gate"]._open, "L4: gate starts open")

	for npc in nodes["npcs"]:
		npc.interact()
		await _frames(2)
		await _finish_dialogue()
	_check(level.talked_count() == 2, "L4: both villagers talked")
	_check(GameState.collected_cards.has("card_nelayan_01"), "L4: fisherman card unlocked")

	for spot in nodes["spots"]:
		spot.interact()
	await _frames(4)
	_check(GameState.mangroves_planted == 8, "L4: 8 mangroves planted")
	_check(GameState.collected_cards.has("card_mangrove_01"), "L4: mangrove card unlocked")

	await _sort_all(nodes["trash"], nodes["bins"])
	_check(level._sorted == 8, "L4: 8 trash sorted")
	_check(GameState.river_health >= 85.0, "L4: river health reaches target")

	level.try_complete_level()
	await _frames(3)
	_check(GameState.levels_completed.has(4), "L4: level marked complete")
	var hud: Node = level.get_node("HUD")
	_check(hud.completion.visible, "L4: completion panel visible")
	_check(hud.completion_title.text == "BAB 4 SELESAI!", "L4: completion title")

	await _free_level(level)
