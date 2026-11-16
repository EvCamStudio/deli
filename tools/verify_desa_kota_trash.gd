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
	
	# Switch to desa
	if _world.has_method("_switch_zone"):
		_world.call("_switch_zone", "desa", Vector2(25, 23) * 16)
	await _frames(15)

	var cam: Camera2D = _world.find_child("Camera2D", true, false) as Camera2D
	# Desa riverbank is along row 25
	if cam:
		cam.position = Vector2(28 * 16, 25 * 16)
		cam.zoom = Vector2(2.2, 2.2)
	await _frames(10)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_desa_new_trash.png")

	# Switch to kota
	if _world.has_method("_switch_zone"):
		_world.call("_switch_zone", "kota", Vector2(25, 14) * 16)
	await _frames(15)
	if cam:
		cam.position = Vector2(26 * 16, 14 * 16)
		cam.zoom = Vector2(2.2, 2.2)
	await _frames(10)
	_shot("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_kota_new_trash.png")

	print("Desa & Kota screenshots captured successfully!")
	get_tree().quit(0)

func _shot(path: String) -> void:
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Saved screenshot:", path)

func _frames(n: int) -> void:
	for _i in range(n):
		await get_tree().process_frame
