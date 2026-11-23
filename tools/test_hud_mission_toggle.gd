extends Node

func _ready() -> void:
	print("\n=== TESTING HUD MISSION TOGGLE BUTTON ===")
	var hud_packed: PackedScene = load("res://scenes/ui/hud.tscn")
	var hud = hud_packed.instantiate()
	add_child(hud)
	
	# Wait for HUD ready
	await get_tree().process_frame
	await get_tree().process_frame
	
	var toggle_btn: Button = hud.get_node_or_null("SafeMargin/Root/MissionToggleBtn") as Button
	var mission_card: Control = hud.get_node_or_null("SafeMargin/Root/MissionCard") as Control
	
	assert(toggle_btn != null, "MissionToggleBtn must exist!")
	assert(mission_card != null, "MissionCard must exist!")
	
	# Simulate setting a mission
	hud.update_mission("WARUNG HULU\nBicara dengan Mak dan Bapak di warung.")
	await get_tree().process_frame
	
	print("Checking initial collapsed state...")
	print("ToggleBtn visible: ", toggle_btn.visible)
	print("MissionCard visible: ", mission_card.visible)
	assert(toggle_btn.visible == true, "Toggle button should be visible when mission exists")
	assert(mission_card.visible == false, "Mission card should be hidden initially!")
	
	# Save screenshot of collapsed state
	await _capture("tools/capture_hud_mission_closed.png")
	
	# Simulate player clicking the toggle button
	print("Clicking toggle button to OPEN mission...")
	toggle_btn.pressed.emit()
	await get_tree().process_frame
	
	print("MissionCard visible after click: ", mission_card.visible)
	assert(mission_card.visible == true, "MissionCard should be open after clicking toggle!")
	
	# Save screenshot of open state
	await _capture("tools/capture_hud_mission_open.png")
	
	# Simulate player clicking again to CLOSE
	print("Clicking toggle button to CLOSE mission...")
	toggle_btn.pressed.emit()
	await get_tree().process_frame
	
	print("MissionCard visible after second click: ", mission_card.visible)
	assert(mission_card.visible == false, "MissionCard should be hidden again!")
	
	print("ALL MISSION TOGGLE TESTS PASSED!")
	get_tree().quit(0)

func _capture(path: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Captured: ", path)

