extends Node

func _ready() -> void:
	GameState.player_name = "Yura"
	var world_scene := preload("res://scenes/world/world_sungai_deli.tscn")
	var world: WorldSungaiDeli = world_scene.instantiate()
	add_child(world)
	_run(world)

func _run(world: WorldSungaiDeli) -> void:
	for i in range(25):
		await get_tree().process_frame

	world.change_zone("kota")
	for i in range(25):
		await get_tree().process_frame

	var player = world.player
	var base_dir := "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8"

	# Quest state: pintu_air_dan_b3, cipher solved, lever 1 already pulled
	GameState.record_choice("hulu_story_step", "pintu_air_dan_b3")
	GameState.record_choice("sandi_tuas_terbuka", true)
	world._sync_hulu_story_state()
	world._refresh_mission()

	var levers = get_tree().get_nodes_in_group("pilot_lever")
	var lever1 = null
	var lever3 = null
	for l in levers:
		if l.lever_id == 1: lever1 = l
		elif l.lever_id == 3: lever3 = l

	if lever1:
		lever1.interact() # Pull lever 1 so lever 3 is the active target!
	world._update_guidance()

	var kota_origin: Vector2 = world._zone_containers["kota"].global_position

	# Place player directly in front of lever 3 so the interaction prompt "Tarik" is triggered
	if player and lever3:
		player.global_position = lever3.global_position + Vector2(0, 14)

	for i in range(25):
		await get_tree().process_frame

	var img: Image = get_viewport().get_texture().get_image()
	if img:
		var out_path := base_dir + "/verify_tuas_3_clean_fixed.png"
		img.save_png(out_path)
		print("SUCCESS: Saved verification screenshot to ", out_path)

	get_tree().quit()

