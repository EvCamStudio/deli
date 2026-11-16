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
	
	# Cluster 1: West riverbank around y=10..18 (x=376, y=200)
	if cam:
		cam.position = Vector2(380, 200)
		cam.zoom = Vector2(2.5, 2.5)
	await _frames(10)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_riverbank_cluster1.png")

	# Cluster 2: West riverbank around y=18..25 (x=376, y=340)
	if cam:
		cam.position = Vector2(380, 340)
		cam.zoom = Vector2(2.5, 2.5)
	await _frames(10)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_riverbank_cluster2.png")

	# East riverbank around bridge (x=556, y=200)
	if cam:
		cam.position = Vector2(550, 200)
		cam.zoom = Vector2(2.5, 2.5)
	await _frames(10)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_riverbank_cluster3.png")

	print("Screenshots captured successfully!")
	get_tree().quit(0)

func _shot(path: String) -> void:
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Saved screenshot:", path)

func _frames(n: int) -> void:
	for _i in range(n):
		await get_tree().process_frame
