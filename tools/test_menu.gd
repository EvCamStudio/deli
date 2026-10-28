extends Node

var _failures: int = 0

func _ready() -> void:
	call_deferred("_run")

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: ", label)
	else:
		_failures += 1
		printerr("FAIL: ", label)

func _frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _run() -> void:
	GameState.reset()
	# Keep this test node alive across scene changes.
	get_tree().current_scene = null
	var menu: Node = load("res://scenes/main_menu/main_menu.tscn").instantiate()
	get_tree().root.add_child(menu)
	get_tree().current_scene = menu
	await _frames(6)
	_check(menu.name == "MainMenu", "main menu loads")

	var settings_panel: Control = menu.get_node("SettingsPanel")
	menu.get_node("VBox/Buttons/SettingsBtn").emit_signal("pressed")
	await _frames(2)
	_check(settings_panel.visible, "settings opens")
	var options: OptionButton = settings_panel.get_node("Panel/VBox/TouchSizeRow/TouchSizeOptions")
	_check(options.item_count == 3, "touch size options filled")
	settings_panel.get_node("Panel/VBox/CloseBtn").emit_signal("pressed")
	await _frames(2)
	_check(not settings_panel.visible, "settings closes")

	var levels: Control = menu.get_node("LevelSelectPanel")
	menu.get_node("VBox/Buttons/LevelSelectBtn").emit_signal("pressed")
	await _frames(2)
	_check(levels.visible, "level select opens")
	levels.get_node("Panel/VBox/CloseSelectBtn").emit_signal("pressed")
	await _frames(2)
	_check(not levels.visible, "level select closes")

	var popup: Node = menu.get_node("KnowledgeCardPopup")
	menu.get_node("VBox/Buttons/CardsBtn").emit_signal("pressed")
	await _frames(2)
	_check(popup.collection_panel.visible, "card collection opens")
	_check(get_tree().paused, "collection pauses tree")
	popup.collection_close_btn.emit_signal("pressed")
	await _frames(2)
	_check(not get_tree().paused, "closing collection unpauses")

	# Enter level 3 through the chapter select.
	menu.get_node("VBox/Buttons/LevelSelectBtn").emit_signal("pressed")
	await _frames(2)
	levels.get_node("Panel/VBox/L3Btn").emit_signal("pressed")
	await _frames(4)
	await get_tree().create_timer(1.4).timeout
	await _frames(4)
	var level: Node = get_tree().current_scene
	_check(level != null and level.name == "Level3Kota", "level 3 pilot loads from menu")
	_check(GameState.current_level == 3, "current level is 3")
	var player: Node = level.get_node_or_null("Player")
	_check(player != null, "player spawns in pilot")

	print("RESULT: %s (%d failures)" % ["PASS" if _failures == 0 else "FAIL", _failures])
	get_tree().quit(1 if _failures > 0 else 0)
