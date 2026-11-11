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

func _run() -> void:
	GameState.reset()
	var packed: PackedScene = load("res://scenes/levels/level_3_kota_topdown.tscn")
	var level: Node = packed.instantiate()
	get_tree().root.add_child(level)
	await _frames(5)

	var npcs: Array = []
	var trash: Array = []
	var bins: Array = []
	var levers: Array = []
	var gate: Node = null
	for child in level.get_children():
		if child is NPC:
			npcs.append(child)
		elif child is TrashItem:
			trash.append(child)
		elif child is PilotBin:
			bins.append(child)
		elif child is PilotLever:
			levers.append(child)
		elif child is PilotGate:
			gate = child

	_check(npcs.size() == 4, "4 NPC spawned")
	_check(trash.size() == 6, "6 trash spawned")
	_check(bins.size() == 3, "3 bins spawned")
	_check(levers.size() == 3, "3 levers spawned")
	_check(gate != null, "gate spawned")

	var pedagang: Node = null
	for npc in npcs:
		if npc.npc_key == "npc_pedagang":
			pedagang = npc
			break
	_check(pedagang != null, "pedagang found")

	# Full dialogue path: pedagang -> why -> help -> end.
	pedagang.interact()
	await _frames(2)
	_check(DialogueManager.is_active(), "dialogue starts")
	DialogueManager.advance(0)
	await _frames(2)
	DialogueManager.advance(0)
	await _frames(2)
	DialogueManager.advance(0)
	await _frames(2)
	DialogueManager.advance()
	await _frames(2)
	_check(not DialogueManager.is_active(), "dialogue ends")
	_check(abs(GameState.river_health - 23.0) < 0.01, "choice effect raises river health to 23")

	# Pick organic trash, sort into correct bin.
	var organic_trash: TrashItem = null
	for item in trash:
		if is_instance_valid(item) and item.category == "organik":
			organic_trash = item
			break
	_check(organic_trash != null, "organic trash found")
	organic_trash.interact()
	await _frames(2)
	_check(GameState.get_meta("pending_trash").size() == 1, "trash enters inventory")
	var organik_bin: Node = null
	var plastik_bin: Node = null
	for b in bins:
		if b.bin_category == "organik":
			organik_bin = b
		elif b.bin_category == "plastik":
			plastik_bin = b
	organik_bin.interact()
	await _frames(2)
	_check(GameState.get_meta("pending_trash").is_empty(), "correct bin empties inventory")
	_check(GameState.get_total_trash() == 1, "correct trash counted")
	_check(abs(GameState.river_health - 26.0) < 0.01, "sorting raises river health to 26")

	# Tong bersifat forgiving: kategori apa pun diterima tanpa penalti.
	var plastic_trash: TrashItem = null
	for item in trash:
		if is_instance_valid(item) and item.category == "plastik":
			plastic_trash = item
			break
	plastic_trash.interact()
	await _frames(2)
	organik_bin.interact()
	await _frames(2)
	_check(GameState.get_meta("pending_trash").is_empty(), "forgiving bin accepts plastic trash")
	_check(GameState.get_total_trash() == 2, "second trash counted")
	_check(abs(GameState.river_health - 29.0) < 0.01, "forgiving bin raises river health to 29")

	# Pantun minigame: two correct answers.
	var pantun: Node = level.get_node("PantunPanel")
	level.open_pantun()
	await _frames(2)
	_check(pantun.panel.visible, "pantun panel opens")
	pantun._on_choice(0, 0)
	await get_tree().create_timer(1.0).timeout
	pantun._on_choice(0, 0)
	await get_tree().create_timer(1.0).timeout
	await _frames(2)
	_check(not pantun.panel.visible, "pantun panel closes after completion")
	_check(abs(GameState.river_health - 37.0) < 0.01, "pantun reward raises river health to 37")

	# Wrong lever sequence then correct 1-3-2.
	levers.sort_custom(func(a, b): return a.lever_id < b.lever_id)
	levers[0].interact()
	await _frames(1)
	levers[1].interact()
	await _frames(1)
	_check(abs(GameState.river_health - 35.0) < 0.01, "wrong lever sequence penalizes health")
	levers[0].interact()
	await _frames(1)
	levers[2].interact()
	await _frames(1)
	levers[1].interact()
	await _frames(3)
	_check(level._gate_open, "correct lever sequence opens gate")
	_check(gate._open, "gate visual opens")
	_check(abs(GameState.river_health - 45.0) < 0.01, "gate reward raises river health to 45")

	# Reward the remaining conversations.
	for npc in npcs:
		if npc == pedagang:
			continue
		npc.interact()
		await _frames(2)
		while DialogueManager.is_active():
			var choices: Array = DialogueManager._current_node.get("choices", [])
			if choices.is_empty():
				DialogueManager.advance()
			else:
				DialogueManager.advance(0)
			await _frames(1)

	# Dismantle the remaining trash to reach the target.
	for item in trash:
		if not is_instance_valid(item):
			continue
		item.interact()
		await _frames(2)
		var pending: Array = GameState.get_meta("pending_trash")
		if pending.is_empty():
			continue
		var category: String = str(pending[0].get("category", ""))
		for b in bins:
			if b.bin_category == category:
				b.interact()
				break
		await _frames(2)

	_check(GameState.river_health >= 55.0, "river health reaches completion target")
	level.try_complete_level()
	await _frames(3)
	_check(GameState.levels_completed.has(3), "level 3 marked complete")
	var hud: Node = level.get_node("HUD")
	_check(hud.completion.visible, "completion panel visible")
	get_tree().paused = false

	print("RESULT: %s (%d failures)" % ["PASS" if _failures == 0 else "FAIL", _failures])
	get_tree().quit(1 if _failures > 0 else 0)
