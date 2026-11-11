## Tangkapan layar world baru: onboarding, misi, dialog, tong, zona, pantun.
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

func _find_in_zone(world: Node, zone: String, key: String) -> Node:
	var container := world.get_node_or_null("Zone" + zone.capitalize())
	if container == null:
		return null
	for child in container.get_children():
		if child is NPC and child.npc_key == key:
			return child
	return null

func _run() -> void:
	GameState.reset()
	GameState.quest_progress = 1
	QuestManager.start_main_quest()
	var world: Node = load("res://scenes/world/world_sungai_deli.tscn").instantiate()
	get_tree().root.add_child(world)
	await _frames(14)
	await _shot("world_hulu_onboarding")

	# Dialog dengan Penjaga Hutan (pemicu misi tanam pohon)
	var npc: Node = _find_in_zone(world, "hulu", "npc_penjaga_hutan")
	if npc:
		var player: Node2D = world.get_node("Player")
		player.global_position = npc.global_position + Vector2(0, 22)
		await _frames(4)
		npc.interact()
		await get_tree().create_timer(0.8).timeout
		if world.has_node("DialogueBox"):
			world.get_node("DialogueBox")._finish_typewriter()
		await _shot("world_dialogue")
		# Pilih opsi pertama sampai quest aktif.
		DialogueManager.advance(0)
		await _frames(2)
		DialogueManager.advance(0)
		await _frames(2)
		DialogueManager.advance(0)
		await _frames(2)
		DialogueManager.advance()
		await _frames(6)
		var popup: Node = world.get_node_or_null("KnowledgeCardPopup")
		if popup and popup.panel.visible:
			popup._close_card()
		await _frames(4)
	await _shot("world_hulu_mission")

	# Dekat tong sampah (label kategori harus terlihat)
	var bin: Node = null
	for child in world.get_node("ZoneHulu").get_children():
		if child is PilotBin:
			bin = child
			break
	if bin:
		world.get_node("Player").global_position = bin.global_position + Vector2(0, 24)
		await _shot("world_bin_labels")

	# Zona berikutnya
	world.change_zone("desa")
	await _shot("world_desa")
	world.change_zone("kota")
	await _shot("world_kota")
	world.change_zone("hilir")
	await _shot("world_hilir")

	# Pantun
	world.open_pantun()
	await _shot("world_pantun")
	world.get_node("PantunPanel")._close()
	await _frames(4)

	GameState.delete_save()
	get_tree().quit()
