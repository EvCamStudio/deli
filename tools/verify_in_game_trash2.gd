extends Node

var _world: Node = null

func _ready() -> void:
	GameState.rupiah = 0
	GameState.picked_trash_ids.clear()
	GameState.set_meta("pending_trash", [])
	GameState.choices["hulu_story_step"] = "bersihkan_sungai"

	var world_scene := preload("res://scenes/world/world_sungai_deli.tscn")
	_world = world_scene.instantiate()
	add_child(_world)
	_run()

func _run() -> void:
	await _frames(20)
	if _world.has_method("_spawn_hulu_riverbank_trash"):
		_world.call("_spawn_hulu_riverbank_trash")
	if _world.has_method("_sync_hulu_story_state"):
		_world.call("_sync_hulu_story_state")

	await _frames(10)
	var cam: Camera2D = _world.find_child("Camera2D", true, false) as Camera2D

	# 1. Eastern riverbank near bridge (x=556, y=170)
	if cam:
		cam.position = Vector2(556, 170)
		cam.zoom = Vector2(2.5, 2.5)
	await _frames(10)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_east_riverbank_trash.png")

	# 2. Western riverbank southern segment (x=380, y=290)
	if cam:
		cam.position = Vector2(380, 290)
		cam.zoom = Vector2(2.5, 2.5)
	await _frames(10)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_southwest_riverbank_trash.png")

	# 3. Overview of the river with multiple trash items and bridge (x=460, y=200, zoom=1.6)
	if cam:
		cam.position = Vector2(460, 200)
		cam.zoom = Vector2(1.6, 1.6)
	await _frames(10)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_river_wide_trash.png")

	get_tree().quit(0)

func _shot(path: String) -> void:
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Saved screenshot:", path)

func _frames(n: int) -> void:
	for _i in range(n):
		await get_tree().process_frame
