extends Node

func _ready() -> void:
	print("\n=== TESTING MAIN MENU CONTINUE BUTTON ===")
	var menu_scene: PackedScene = load("res://scenes/main_menu/main_menu.tscn")
	var menu = menu_scene.instantiate()
	get_tree().root.add_child(menu)
	
	for i in range(10):
		await get_tree().process_frame
		
	var cont_btn = menu.get_node_or_null("VBox/Buttons/ContinueBtn")
	print("Continue btn found:", cont_btn != null, " disabled:", cont_btn.disabled if cont_btn else true)
	if cont_btn and not cont_btn.disabled:
		print("Pressing Continue Button...")
		cont_btn.emit_signal("pressed")
		
		for i in range(30):
			await get_tree().process_frame
		
		print("Current scene after continue:", get_tree().current_scene)
		print("In world:", GameState.in_world)

	print("=== TEST COMPLETED ===")
	get_tree().quit(0)

