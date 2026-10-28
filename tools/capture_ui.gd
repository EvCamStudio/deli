extends Node

func _ready() -> void:
	call_deferred("_run")

func _frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _shot(name: String) -> void:
	await _frames(3)
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("C:/Users/Hype AMD/AppData/Local/Temp/%s.png" % name)
	print("captured ", name)

func _run() -> void:
	GameState.reset()
	var level: Node = load("res://scenes/levels/level_3_kota_topdown.tscn").instantiate()
	get_tree().root.add_child(level)
	await _frames(8)

	var pedagang: Node = null
	for child in level.get_children():
		if child is NPC and child.npc_key == "npc_pedagang":
			pedagang = child
			break
	pedagang.interact()
	await _frames(30)
	var box: Node = level.get_node("DialogueBox")
	box._finish_typewriter()
	await _frames(10)
	await _shot("pilot_dialogue")

	box.hide_box()
	DialogueManager._end_dialogue()
	await _frames(2)
	level.open_pantun()
	await _frames(8)
	await _shot("pilot_pantun")
	level.get_node("PantunPanel")._close()
	await _frames(2)

	GameState.unlock_card("card_drainase_01")
	await _frames(8)
	await _shot("pilot_card")
	level.get_node("KnowledgeCardPopup")._close_card()
	get_tree().paused = false
	await _frames(2)

	GameState.complete_level(3)
	await _frames(12)
	await _shot("pilot_completion")
	get_tree().paused = false
	get_tree().quit()
