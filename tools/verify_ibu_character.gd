extends Node

var _world: Node = null

func _ready() -> void:
	GameState.rupiah = 0
	GameState.picked_trash_ids.clear()
	GameState.set_meta("pending_trash", [])

	var world_scene := preload("res://scenes/world/world_sungai_deli.tscn")
	_world = world_scene.instantiate()
	add_child(_world)
	_run()

func _run() -> void:
	await _frames(25)

	var ibu_npc: Node2D = _world.call("_npc_by_key", "npc_ibu_mc") as Node2D
	assert(ibu_npc != null, "npc_ibu_mc must exist")

	var player: Node2D = _world.get("player") as Node2D
	if not player:
		player = _world.find_child("Player", true, false) as Node2D
	assert(player != null, "Player must exist")

	var cam: Camera2D = player.find_child("Camera2D", true, false) as Camera2D
	if cam:
		cam.position = Vector2.ZERO

	# Stand player right next to Ibu in front of Warung Hulu
	player.global_position = ibu_npc.global_position + Vector2(26, 0)
	var player_char = player.get_node_or_null("PlayerTopDown")
	if not player_char:
		player_char = player.find_child("PlayerTopDown", true, false)
	if player_char and player_char.get("sprite"):
		player_char.sprite.play("idle_left") # Face Ibu

	# 1. Overview of Warung Hulu with Bu Mira and MC standing together
	if cam:
		cam.zoom = Vector2(2.5, 2.5)
	await _frames(8)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_ibu_at_warung.png")

	# 2. Close-up zoom on Bu Mira and MC (zoom 4.0)
	if cam:
		cam.zoom = Vector2(4.5, 4.5)
	await _frames(8)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_ibu_closeup.png")

	# 3. Trigger Dialogue with Bu Mira to see the new portrait in the dialogue box
	if cam:
		cam.zoom = Vector2(1.0, 1.0)
	if ibu_npc.has_method("interact"):
		ibu_npc.interact()
	await _frames(15)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_ibu_dialogue_portrait.png")

	print("All verification screenshots of ibu captured successfully!")
	get_tree().quit(0)

func _shot(path: String) -> void:
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Saved screenshot:", path)

func _frames(n: int) -> void:
	for _i in range(n):
		await get_tree().process_frame
