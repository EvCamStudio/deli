extends Node

func _ready() -> void:
	print("\n=== CAPTURING HULU MC HOUSE FOREST & NORTH CLEARING ===")
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	
	for i in range(12):
		await get_tree().process_frame
		
	var player = world.player
	var camera = world.camera
	
	# View 1: Standing behind MC house (Image 1 area)
	player.global_position = Vector2(192, 55)
	if camera:
		camera.global_position = Vector2(192, 100)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("tools/capture_hulu_mc_forest.png")
	print("Saved View 1: tools/capture_hulu_mc_forest.png")
	
	# View 2: Standing in northern forest clearing (Image 2 area)
	player.global_position = Vector2(300, 55)
	if camera:
		camera.global_position = Vector2(300, 90)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("tools/capture_hulu_north_clearing.png")
	print("Saved View 2: tools/capture_hulu_north_clearing.png")
	
	print("Captures complete!")
	get_tree().quit(0)

