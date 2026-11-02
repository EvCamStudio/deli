## Tangkapan layar world baru: HUD, touch control, dialog, jurnal.
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

func _run() -> void:
	GameState.reset()
	GameState.quest_progress = 1
	QuestManager.start_main_quest()
	var world: Node = load("res://scenes/world/world_sungai_deli.tscn").instantiate()
	get_tree().root.add_child(world)
	await _frames(12)
	await _shot("world_hulu")

	# Dialog dengan Ibu (pemicu quest)
	var ibu: Node = null
	for child in world.get_node("ZoneHulu").get_children():
		if child is NPC and child.npc_key == "npc_ibu_desa":
			ibu = child
			break
	if ibu:
		var player: Node2D = world.get_node("Player")
		player.global_position = ibu.global_position + Vector2(0, 22)
		await _frames(4)
		ibu.interact()
		await get_tree().create_timer(0.9).timeout
		if world.has_node("DialogueBox"):
			world.get_node("DialogueBox")._finish_typewriter()
		await _shot("world_dialogue")
		DialogueManager._end_dialogue()
		await _frames(4)

	# Jurnal / pause
	world.open_pause_menu()
	await _shot("world_journal")
	world.get_node("PauseMenu").close()
	await _frames(4)

	# Kartu pengetahuan
	GameState.unlock_card("card_hutan_01")
	await _shot("world_card")
	world.get_node("KnowledgeCardPopup")._close_card()
	await _frames(4)

	# Dekat tong sampah (label in-world)
	world.get_node("Player").global_position = Vector2(168, 300)
	await _shot("world_bin")

	# Zona desa
	world.change_zone("desa")
	await _shot("world_desa")

	get_tree().quit()
