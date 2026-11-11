## Tangkapan layar epilog dengan statistik pratinjau lengkap.
extends Node

func _ready() -> void:
	call_deferred("_run")

func _frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _run() -> void:
	GameState.prepare_epilog_preview()
	var scene: Node = load("res://scenes/levels/level_5_epilog.tscn").instantiate()
	get_tree().root.add_child(scene)
	await _frames(16)
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("C:/Users/Hype AMD/AppData/Local/Temp/world_epilog.png")
	print("captured world_epilog")
	GameState.delete_save()
	get_tree().quit()