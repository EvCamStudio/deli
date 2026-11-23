extends Node

func _ready() -> void:
	print("Loading world scene for in-game HUD mission toggle verification...")
	var world_packed: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_packed.instantiate()
	add_child(world)
	
	# Wait for world and HUD initialization
	for i in range(10):
		await get_tree().process_frame
	
	var hud = world.hud if "hud" in world else world.get_node_or_null("HUD")
	if not hud:
		hud = get_node_or_null("HUD")
	
	assert(hud != null, "HUD must exist in world scene!")
	
	var toggle_btn: Button = hud.get_node_or_null("SafeMargin/Root/MissionToggleBtn") as Button
	var mission_card: Control = hud.get_node_or_null("SafeMargin/Root/MissionCard") as Control
	
	# Ensure mission is active
	hud.update_mission("WARUNG HULU\nBicara dengan Mak dan Bapak di warung.")
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Capture 1: In-game with mission toggle button collapsed (showing '>')
	await _capture("tools/capture_ingame_mission_closed.png")
	
	# Click toggle button to open
	toggle_btn.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Capture 2: In-game with mission card open (showing '<' and card)
	await _capture("tools/capture_ingame_mission_open.png")
	
	print("In-game captures complete!")
	get_tree().quit(0)

func _capture(path: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Saved in-game capture: ", path)

