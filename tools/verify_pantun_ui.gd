extends Node

func _ready() -> void:
	var world_scene := preload("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	_run(world)

func _run(world) -> void:
	await _frames(20)
	var pantun = world.get_node_or_null("PantunPanel")
	if pantun and pantun.has_method("start"):
		pantun.start()
	await _frames(15)
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_pantun_ui.png")
	print("Saved verify_pantun_ui.png")
	get_tree().paused = false
	get_tree().quit(0)

func _frames(n: int) -> void:
	for _i in range(n):
		await get_tree().process_frame

