extends Node

func _ready() -> void:
	print("\n=== VERIFYING USER FEEDBACK: NO BRIDGE MOUND, MC ON TOP OF MUD (Z=-1), ORGANIC SCATTER & REBOISASI MOUNDS ===")

	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(25): await get_tree().process_frame

	# 1. VERIFY HULU
	print("\n[CHECK 1] Verifying Hulu Map fixes...")
	world.change_zone("hulu", Vector2(112, 160))
	for i in range(25): await get_tree().process_frame

	var hulu = world._zone_containers["hulu"]

	# A. Verify Bridge Railing Area (Image 1 fix: x: 510..560, y: 280..320) has NO dirt mound!
	print("Checking bridge railing area (around 535, 300) for awkward mound...")
	for child in hulu.get_children():
		var pos: Vector2 = child.position
		var tex_name: String = ""
		if child is Sprite2D and child.texture != null:
			tex_name = child.texture.resource_path.get_file()
		elif child is StaticBody2D:
			for grand in child.get_children():
				if grand is Sprite2D and grand.texture != null:
					tex_name = grand.texture.resource_path.get_file()
					break
		if (tex_name.contains("prop_dirt_mound") or tex_name.contains("soil_patch")):
			var d_bridge: float = pos.distance_to(Vector2(535, 300))
			assert(d_bridge > 40.0, "Awkward dirt mound/patch at %s is still at bridge railing! (dist=%.1f)" % [pos, d_bridge])

	print("  -> PASS: Jembatan/pagar sungai Hulu steril dari gundukan canggung (Gambar 1 Fix).")

	# B. Verify South Hulu Felled Trees Area (Image 2 fix: x: 580..920, y: 250..370)
	print("Checking South Hulu felled trees area for non-linear scatter and z_index == -1...")
	var south_mounds: Array[Node] = []
	var south_mound_ys: Array[float] = []
	for child in hulu.get_children():
		var pos: Vector2 = child.position
		var tex_name: String = ""
		if child is Sprite2D and child.texture != null:
			tex_name = child.texture.resource_path.get_file()
		if (tex_name.contains("prop_dirt_mound") or tex_name.contains("soil_patch")) and pos.x >= 580.0 and pos.y >= 250.0:
			south_mounds.append(child)
			south_mound_ys.append(pos.y)

	print("Found South Hulu mounds:", south_mounds.size(), "Positions:", south_mound_ys)
	assert(south_mounds.size() == 4, "Must have exactly 4 mounds in South Hulu! Found: %d" % south_mounds.size())
	
	# Verify NOT in a straight line (Y coordinates must vary significantly, e.g. min vs max >= 50px)
	var min_y: float = south_mound_ys[0]
	var max_y: float = south_mound_ys[0]
	for y in south_mound_ys:
		if y < min_y: min_y = y
		if y > max_y: max_y = y
	var y_spread: float = max_y - min_y
	print("Y spread of South Hulu mounds: %.1f px (min=%.1f, max=%.1f)" % [y_spread, min_y, max_y])
	assert(y_spread >= 50.0, "Mounds must not be in a straight line row! Spread must be >= 50px")
	print("  -> PASS: Gundukan di padang selatan Hulu tersebar secara acak/organik (tidak berjejer lurus).")

	# Verify all mounds have z_index == -1 so MC is drawn on top (no sinking)
	for m in south_mounds:
		assert(m.z_index == -1, "Mound %s must have z_index == -1 so MC steps ON TOP!" % m)
	print("  -> PASS: Semua gundukan memiliki z_index = -1 (MC berjalan di atasnya tanpa tenggelam).")

	# C. Verify Upper Hill Reboisasi Area (tempat nanam pohon dekat pohon yang sudah ditebang)
	print("Checking Upper Hill Reboisasi Area (x: 620..900, y: 60..180) for dirt mounds near felled trees...")
	var reboisasi_mounds: Array[Vector2] = []
	for child in hulu.get_children():
		var pos: Vector2 = child.position
		var tex_name: String = ""
		if child is Sprite2D and child.texture != null:
			tex_name = child.texture.resource_path.get_file()
		if (tex_name.contains("prop_dirt_mound") or tex_name.contains("soil_patch")) and pos.x >= 620.0 and pos.y <= 180.0:
			reboisasi_mounds.append(pos)
			assert(child.z_index == -1, "Reboisasi mound/patch at %s must have z_index == -1!" % pos)

	print("Found Upper Hill Reboisasi mounds:", reboisasi_mounds)
	assert(reboisasi_mounds.size() == 4, "Must have exactly 4 dirt mounds near felled trees in Reboisasi area! Found: %d" % reboisasi_mounds.size())

	# Verify none of the 15 tree planting spots collide with these mounds
	var world_script = load("res://scripts/world_sungai_deli.gd")
	var spots = world_script.HULU_FOREST_SPOTS
	for spot in spots:
		var spot_px: Vector2 = Vector2(spot.x * 16.0 + 8.0, spot.y * 16.0 + 8.0)
		for m_pos in reboisasi_mounds:
			var dist: float = spot_px.distance_to(m_pos)
			assert(dist > 20.0, "Mound at %s overlaps planting spot at %s (dist=%.1f)!" % [m_pos, spot_px, dist])

	print("  -> PASS: Gundukan tanah di kawasan reboisasi atas terpasang rapi dekat pohon ditebang tanpa menimpa 15 titik tanam.")

	# D. Verify Player walking over mud/dirt mound in South Hulu
	var player = world.player
	var hulu_origin = hulu.global_position
	player.global_position = hulu_origin + Vector2(610, 250) # Just above mound at (610, 270)
	var init_y = player.global_position.y
	for f in range(35):
		player.velocity = Vector2(0, 100)
		player.move_and_slide()
		await get_tree().physics_frame

	var walked_y = player.global_position.y - init_y
	print("Player walked southward over dirt mound: %.1f px" % walked_y)
	assert(walked_y > 35.0, "Player must freely walk across dirt mound!")
	assert(player.z_index > -1, "Player z_index (%d) must be greater than mound z_index (-1)!" % player.z_index)
	print("  -> PASS: Player melintasi gundukan tanah dengan mulus dan dirender tepat di atasnya!")

	# 2. VERIFY DESA
	print("\n[CHECK 2] Verifying Desa deforested dirt mounds & trash mound...")
	world.change_zone("desa", Vector2(200, 200))
	for i in range(25): await get_tree().process_frame
	var desa = world._zone_containers["desa"]
	var desa_mounds := 0
	for child in desa.get_children():
		var tex_name: String = ""
		if child is Sprite2D and child.texture != null:
			tex_name = child.texture.resource_path.get_file()
		if tex_name.contains("prop_dirt_mound"):
			desa_mounds += 1
			assert(child.z_index == -1, "Desa dirt mound must have z_index == -1!")

	assert(desa_mounds == 4, "Desa must have 4 dirt mounds in deforested area!")
	print("  -> PASS: 4 gundukan tanah di area hutan desa terverifikasi z_index = -1.")

	print("\n>>> ALL CHECKS PASSED 100%! <<<\n")
	get_tree().quit(0)
