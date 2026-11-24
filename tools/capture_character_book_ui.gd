extends Node

func _ready() -> void:
	GameState.reset()
	var book_scene: PackedScene = load("res://scenes/ui/character_book.tscn")
	var book: CharacterBook = book_scene.instantiate()
	add_child(book)
	book.open_book(1)
	
	for i in range(10):
		await get_tree().process_frame
	
	# 1. Initial Page 1
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png("tools/capture_book_initial_page1.png")
	
	# 2. Initial Page 6 (Both Nelayan & Darwis locked initially)
	book.goto_page(6)
	for i in range(5):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	img = get_viewport().get_texture().get_image()
	img.save_png("tools/capture_book_initial_page6.png")
	
	# 2b. Meet Darwis (Only Photo & Name unlock, Status empty, Notes ???)
	GameState.mark_character_talked("darwis")
	book.goto_page(6)
	for i in range(5):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	img = get_viewport().get_texture().get_image()
	img.save_png("tools/capture_book_darwis_met_unresolved.png")
	
	# 3. Unlock warung (Bu Mira & Pak Hendra) and capture Page 1
	GameState.mark_character_talked("ibu_mc")
	book.goto_page(1)
	for i in range(5):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	img = get_viewport().get_texture().get_image()
	img.save_png("tools/capture_book_unlocked_page1.png")
	
	# 4. Decide Darwis (Mau Berubah) and capture Page 6
	GameState.record_choice("darwis_peduli", true)
	book.goto_page(6)
	for i in range(5):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	img = get_viewport().get_texture().get_image()
	img.save_png("tools/capture_book_decided_page6.png")
	
	# 5. Decide Rina (Tidak Suka) and capture Page 7
	GameState.record_choice("rina_peduli", false)
	book.goto_page(7)
	for i in range(5):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	img = get_viewport().get_texture().get_image()
	img.save_png("tools/capture_book_decided_page7.png")
	
	print("Screenshots captured successfully!")
	get_tree().quit(0)
