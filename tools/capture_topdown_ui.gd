## Tangkapan layar UI top-down: dialog, tanam, dan panel selesai.
extends Node

func _ready() -> void:
	call_deferred("_run")

func _frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _shot(name: String) -> void:
	await _frames(6)
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("C:/Users/Hype AMD/AppData/Local/Temp/%s.png" % name)
	print("captured ", name)

func _find_npc(level: Node, key: String) -> Node:
	for child in level.get_children():
		if child is NPC and child.npc_key == key:
			return child
	return null

func _run() -> void:
	GameState.reset()
	var level: Node = load("res://scenes/levels/level_1_hulu_topdown.tscn").instantiate()
	get_tree().root.add_child(level)
	await _frames(10)
	var player: Node2D = level.get_node("Player")
	var npc: Node = _find_npc(level, "npc_penjaga_hutan")
	player.global_position = npc.global_position + Vector2(0, 22)
	await _frames(6)
	npc.interact()
	await get_tree().create_timer(0.9).timeout
	await _shot("topdown_l1_dialogue")
	DialogueManager.advance(0)
	await _frames(2)
	DialogueManager.advance(0)
	await _frames(2)
	DialogueManager.advance(0)
	await _frames(2)
	DialogueManager.advance()
	await _frames(4)
	var popup: Node = level.get_node_or_null("KnowledgeCardPopup")
	if popup and popup.panel.visible:
		popup._close_card()
	await _frames(4)

	var spots: Array = []
	for child in level.get_children():
		if child is TreeSpotTopDown:
			spots.append(child)
	for i in range(4):
		spots[i].interact()
	await _frames(16)
	player.global_position = spots[0].global_position + Vector2(0, 26)
	await _frames(8)
	await _shot("topdown_l1_planted")

	spots[4].interact()
	await _frames(8)
	popup = level.get_node_or_null("KnowledgeCardPopup")
	if popup and popup.panel.visible:
		popup._close_card()
	await _frames(4)
	level.try_complete_level()
	await _frames(8)
	await _shot("topdown_l1_complete")
	get_tree().paused = false
	level.queue_free()
	await _frames(4)

	GameState.reset()
	var level4: Node = load("res://scenes/levels/level_4_hilir_topdown.tscn").instantiate()
	get_tree().root.add_child(level4)
	await _frames(10)
	var nelayan: Node = _find_npc(level4, "npc_nelayan")
	var player4: Node2D = level4.get_node("Player")
	player4.global_position = nelayan.global_position + Vector2(0, 22)
	await _frames(6)
	nelayan.interact()
	await get_tree().create_timer(0.9).timeout
	await _shot("topdown_l4_dialogue")
	var popup4: Node = level4.get_node_or_null("KnowledgeCardPopup")
	if popup4 and popup4.panel.visible:
		popup4._close_card()
	await _frames(4)

	var spots4: Array = []
	for child in level4.get_children():
		if child is TreeSpotTopDown:
			spots4.append(child)
	for i in range(7):
		spots4[i].interact()
	await _frames(16)
	player4.global_position = spots4[0].global_position + Vector2(0, 26)
	await _frames(8)
	await _shot("topdown_l4_mangrove")

	level4.queue_free()
	await _frames(4)
	get_tree().quit()
