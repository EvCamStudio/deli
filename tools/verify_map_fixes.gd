extends Node

func _ready() -> void:
	GameState.player_name = "Yura"
	var world_scene := preload("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	_run(world)

func _run(world) -> void:
	await _frames(25)
	var cam: Camera2D = world.get_node_or_null("Camera2D")
	var player = world.player
	var base_dir := "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8"

	# Spot 1: Hilir - Pohon baru di celah house_coastal & house_suburban_blue
	world.change_zone("hilir")
	await _frames(20)
	if player:
		player.global_position = world._zone_containers["hilir"].global_position + Vector2(210, 110)
	if cam:
		cam.global_position = world._zone_containers["hilir"].global_position + Vector2(210, 110)
	await _frames(15)
	_save_screen(base_dir + "/verify_1_hilir_tree_clean.png")

	# Spot 2: Hilir - Jembatan kayu dengan pagar kayu vertikal kiri & kanan
	if player:
		player.global_position = world._zone_containers["hilir"].global_position + Vector2(344, 260)
	if cam:
		cam.global_position = world._zone_containers["hilir"].global_position + Vector2(344, 260)
	await _frames(15)
	_save_screen(base_dir + "/verify_2_hilir_bridge_rails.png")

	# Spot 3 & 4: Kota Medan - Menampilkan Market Kelontong & Market Sembako (Tanpa Toko Jaya & Tanpa Warung Bu Sri)
	world.change_zone("kota")
	await _frames(20)
	if player:
		player.global_position = world._zone_containers["kota"].global_position + Vector2(740, 270)
	if cam:
		cam.global_position = world._zone_containers["kota"].global_position + Vector2(740, 270)
	await _frames(15)
	_save_screen(base_dir + "/verify_3_4_kota_markets_no_dupes.png")

	# Spot 5: Desa - Warung Barokah bersih tanpa garis kotak border di bawah
	world.change_zone("desa")
	await _frames(20)
	if player:
		player.global_position = world._zone_containers["desa"].global_position + Vector2(430, 290)
	if cam:
		cam.global_position = world._zone_containers["desa"].global_position + Vector2(430, 290)
	await _frames(15)
	_save_screen(base_dir + "/verify_5_desa_warung_barokah_clean.png")

	# Spot 6: Desa - Rumah Brick (house_brick) di pekarangan rumput bersih (tidak berada di tengah jalan)
	if player:
		player.global_position = world._zone_containers["desa"].global_position + Vector2(270, 290)
	if cam:
		cam.global_position = world._zone_containers["desa"].global_position + Vector2(270, 290)
	await _frames(15)
	_save_screen(base_dir + "/verify_6_desa_house_brick_clean.png")

	# Spot 7: Desa - Toko Jaya bersih tanpa garis kotak wireframe
	if player:
		player.global_position = world._zone_containers["desa"].global_position + Vector2(180, 200)
	if cam:
		cam.global_position = world._zone_containers["desa"].global_position + Vector2(180, 200)
	await _frames(15)
	_save_screen(base_dir + "/verify_7_desa_toko_jaya_clean.png")

	print("All 6 verification screenshots saved successfully!")
	get_tree().quit(0)

func _save_screen(path: String) -> void:
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png(path)
	print("Saved " + path.get_file())

func _frames(n: int) -> void:
	for _i in range(n):
		await get_tree().process_frame
