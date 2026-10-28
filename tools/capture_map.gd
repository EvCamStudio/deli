extends Node

func _ready() -> void:
	call_deferred("_run")

func _frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _shot(name: String) -> void:
	await _frames(4)
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("C:/Users/Hype AMD/AppData/Local/Temp/%s.png" % name)
	print("captured ", name)

func _run() -> void:
	GameState.reset()
	var level: Node = load("res://scenes/levels/level_3_kota_topdown.tscn").instantiate()
	get_tree().root.add_child(level)
	await _frames(8)
	var player: Node2D = level.get_node("Player")

	player.global_position = Vector2(470, 210)
	await _frames(6)
	await _shot("pilot_map_center")

	player.global_position = Vector2(848, 224)
	await _frames(6)
	await _shot("pilot_map_east")

	player.global_position = Vector2(420, 340)
	await _frames(6)
	await _shot("pilot_map_south")

	player.global_position = Vector2(60, 480)
	await _frames(6)
	await _shot("pilot_map_sw")

	get_tree().quit()
