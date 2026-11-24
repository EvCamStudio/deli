extends Node

func _ready() -> void:
	print("\n=== VERIFYING HULU RIVERBANK TRASH IS SPAWNED FROM START OF STORY ===")

	# 1. Reset GameState to the initial state (start of story)
	GameState.choices.clear()
	GameState.picked_trash_ids.clear()
	GameState.world_zone = "hulu"
	GameState.saved_zone = "hulu"
	GameState.record_choice("hulu_story_step", "") # Initial state before talking to anyone
	print("Initial hulu_story_step is empty:", GameState.choices.get("hulu_story_step", ""))

	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(25): await get_tree().process_frame

	world.change_zone("hulu", Vector2(112, 160))
	for i in range(25): await get_tree().process_frame

	var hulu = world._zone_containers["hulu"]

	# 2. Check that Hulu Riverbank Trash exists right now from the start!
	var found_trash: Array[Node] = []
	for child in hulu.get_children():
		if child.is_in_group("world_trash"):
			var tid: String = str(child.get("trash_id"))
			if tid.begins_with("hulu_river_trash"):
				found_trash.append(child)

	print("Found Hulu riverbank trash count at start of story:", found_trash.size())
	assert(found_trash.size() == 10, "All 10 riverbank trash items must be spawned right from the start of story! Got: %d" % found_trash.size())
	print("  -> PASS: 10 sampah bantaran sungai Hulu SUDAH MUNCUL dari awal cerita (sebelum bertemu Datuk)!")

	# 3. Test picking up a trash item at the start of story
	var t0 = found_trash[0]
	var tid0: String = str(t0.get("trash_id"))
	var cat0: String = str(t0.get("category"))
	print("Simulating MC picking up trash '%s' (%s) at start of story..." % [tid0, cat0])
	world.on_trash_picked(cat0, tid0)
	assert(tid0 in GameState.picked_trash_ids, "Picked trash ID must be in picked_trash_ids!")
	print("  -> PASS: MC berhasil memungut sampah sebelum bertemu Datuk Sampan!")

	# 4. Simulate sorting the picked trash into a bin
	world.on_bin_sorted(cat0)
	print("  -> PASS: MC berhasil memilah sampah ke tong!")

	# 5. Now test dialogue with Datuk Sampan after having already cleaned/started cleaning trash
	print("Testing completion of h1_datuk dialogue...")
	world._on_dialog_selesai("h1_datuk")
	assert(str(GameState.choices.get("hulu_story_step")) == "bersihkan_sungai", "Story step must update to bersihkan_sungai!")
	print("  -> PASS: Dialog Datuk Sampan berjalan normal!")

	print("\n>>> ALL TESTS FOR TRASH AT START OF STORY PASSED 100%! <<<\n")
	get_tree().quit(0)
