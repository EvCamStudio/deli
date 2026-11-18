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

	var player = _world.player
	assert(player != null, "Player must exist")

	var cam: Camera2D = _world.camera
	if cam:
		cam.position = Vector2.ZERO
		cam.zoom = Vector2(3.5, 3.5) # Zoom in close on player

	# 1. Idle Down
	player.set("_facing", "down")
	player.sprite.play("idle_down")
	await _frames(6)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_player_idle_down.png")

	# 2. Walk Down (step)
	player.set("_facing", "down")
	player.sprite.play("walk_down")
	player.sprite.frame = 1
	await _frames(6)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_player_walk_down.png")

	# 3. Idle Right
	player.set("_facing", "right")
	player.sprite.play("idle_right")
	await _frames(6)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_player_idle_right.png")

	# 4. Walk Right
	player.set("_facing", "right")
	player.sprite.play("walk_right")
	player.sprite.frame = 1
	await _frames(6)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_player_walk_right.png")

	# 5. Idle Left
	player.set("_facing", "left")
	player.sprite.play("idle_left")
	await _frames(6)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_player_idle_left.png")

	# 6. Walk Left
	player.set("_facing", "left")
	player.sprite.play("walk_left")
	player.sprite.frame = 1
	await _frames(6)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_player_walk_left.png")

	# 7. Idle Up
	player.set("_facing", "up")
	player.sprite.play("idle_up")
	await _frames(6)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_player_idle_up.png")

	# 8. Walk Up
	player.set("_facing", "up")
	player.sprite.play("walk_up")
	player.sprite.frame = 1
	await _frames(6)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_player_walk_up.png")

	# 9. Overview zoom 2.0
	if cam:
		cam.zoom = Vector2(2.0, 2.0)
	player.set("_facing", "down")
	player.sprite.play("idle_down")
	await _frames(6)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_player_in_game_overview.png")

	print("Screenshots captured successfully!")
	get_tree().quit(0)

func _shot(path: String) -> void:
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Saved screenshot:", path)

func _frames(n: int) -> void:
	for _i in range(n):
		await get_tree().process_frame
