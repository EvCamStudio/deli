extends Node

func _ready() -> void:
	GameState.player_name = "Yura"
	var dlg_scene := preload("res://scenes/ui/portrait_dialogue.tscn")
	var dlg = dlg_scene.instantiate()
	add_child(dlg)
	_run(dlg)

func _run(dlg) -> void:
	await _frames(10)
	dlg.show_node({
		"speaker": "Datuk Sampan",
		"teks": "Dengarlah sungai ini, nak. Airnya mengingat semua tangan yang menjaga atau melukainya.",
		"portrait": "datuk",
		"emotion": "neutral"
	})
	await _frames(20)
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png("/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/verify_datuk_dialogue_portrait.png")
	print("Saved verify_datuk_dialogue_portrait.png")
	get_tree().quit(0)

func _frames(n: int) -> void:
	for _i in range(n):
		await get_tree().process_frame

