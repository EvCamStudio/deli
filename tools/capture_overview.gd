extends Node

func _ready() -> void:
	call_deferred("_run")

func _frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _run() -> void:
	GameState.reset()
	var level: Node = load("res://scenes/levels/level_3_kota_topdown.tscn").instantiate()
	get_tree().root.add_child(level)
	await _frames(8)
	var camera: Camera2D = level.get_node("Camera2D")
	camera.position_smoothing_enabled = false
	camera.zoom = Vector2(0.64, 0.64)
	camera.global_position = Vector2(480, 268)
	await _frames(8)
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("C:/Users/Hype AMD/AppData/Local/Temp/pilot_map_overview.png")
	print("captured overview")
	get_tree().quit()
