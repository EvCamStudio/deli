extends Node

const ARTIFACT_DIR := "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8"

func _ready() -> void:
	call_deferred("_run")

func _frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _shot(name: String) -> void:
	await _frames(4)
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("%s/%s.png" % [ARTIFACT_DIR, name])
	print("captured ", name)

func _run() -> void:
	GameState.reset()
	var menu: Node = load("res://scenes/main_menu/main_menu.tscn").instantiate()
	get_tree().root.add_child(menu)
	await _frames(10)
	await _shot("menu_main")

	menu.get_node("SettingsPanel").show()
	await _frames(4)
	await _shot("menu_settings")
	menu.get_node("SettingsPanel").hide()

	menu.get_node("LevelSelectPanel").show()
	await _frames(4)
	await _shot("menu_levels")
	menu.get_node("LevelSelectPanel").hide()

	var popup: Node = menu.get_node("KnowledgeCardPopup")
	popup.open_collection()
	await _frames(4)
	await _shot("menu_cards")
	popup._close_collection()
	get_tree().paused = false

	# Unlock a card to test the single-card panel.
	GameState.unlock_card("card_plastik_01")
	await _frames(6)
	await _shot("menu_card_single")
	popup._close_card()
	get_tree().paused = false
	await _frames(2)

	get_tree().quit()
