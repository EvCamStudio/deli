extends Node

func _ready() -> void:
	print("\n=== VERIFYING USER FIX: REMOVED 3 UGLY PROPS & REPLACED WITH IMAGE 4 TRASH BAGS ===")

	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for i in range(25): await get_tree().process_frame

	# 1. VERIFY HILIR MUARA
	print("\n[CHECK 1] Verifying Hilir Muara has NO ugly props from Images 1-3, and HAS Image 4 trash bags...")
	world.change_zone("hilir", Vector2(100, 200))
	for i in range(25): await get_tree().process_frame

	var hilir = world._zone_containers["hilir"]
	var hilir_props: Dictionary = {}
	for child in hilir.get_children():
		var tex_name: String = ""
		var pos: Vector2 = child.position
		if child is Sprite2D and child.texture != null:
			tex_name = child.texture.resource_path.get_file()
		elif child is StaticBody2D:
			for grand in child.get_children():
				if grand is Sprite2D and grand.texture != null:
					tex_name = grand.texture.resource_path.get_file()
					break
		if tex_name.begins_with("prop_"):
			hilir_props[tex_name] = pos

	print("Found Hilir props:", hilir_props.keys())

	# Check that ugly props from Images 1, 2, 3 are DELETED
	assert(not hilir_props.has("prop_large_dumpster.png"), "Dumpster from Image 1 must be DELETED!")
	assert(not hilir_props.has("prop_huge_trash_mound.png"), "Huge trash mound from Image 2 must be DELETED!")
	assert(not hilir_props.has("prop_construction_debris.png"), "Construction debris from Image 3 must be DELETED!")
	assert(not hilir_props.has("prop_trash_pile_small.png"), "Small trash pile from Image 3 must be DELETED!")
	assert(not hilir_props.has("prop_mud_tire_mound.png"), "Mud tire mound must be DELETED!")
	assert(not hilir_props.has("prop_mud_debris_mound.png"), "Mud debris mound must be DELETED!")
	print("  -> PASS: Semua prop jelek dari Gambar 1, 2, dan 3 telah BERHASIL DIHAPUS dari Hilir!")

	# Check that Image 4 trash bags exist
	assert(hilir_props.has("prop_trash_bags_black.png"), "Hilir must have black trash bags from Image 4!")
	assert(hilir_props.has("prop_trash_bags_blue_white.png"), "Hilir must have blue/white trash bags from Image 4!")
	print("  -> PASS: Kantong sampah hitam dan biru/putih dari Gambar 4 berhasil terpasang di Hilir!")

	# Check distance from bush at (60, 95)
	var bush_pos := Vector2(60, 95)
	for p_name in hilir_props:
		var p_pos: Vector2 = hilir_props[p_name]
		var dist: float = bush_pos.distance_to(p_pos)
		assert(dist > 50.0, "Prop %s at %s is too close to bush at %s (dist=%.1f)!" % [p_name, p_pos, bush_pos, dist])
	print("  -> PASS: Tidak ada prop sampah yang menimpa semak/bunga di Hilir (Gambar 1 Fix)!")

	# Check distance from 8 mangrove spots
	var world_script = load("res://scripts/world_sungai_deli.gd")
	for m_spot in world_script.HILIR_MANGROVE_SPOTS:
		var spot_px: Vector2 = Vector2(m_spot.x * 16.0 + 8.0, m_spot.y * 16.0 + 8.0)
		for p_name in hilir_props:
			var p_pos: Vector2 = hilir_props[p_name]
			var dist: float = spot_px.distance_to(p_pos)
			assert(dist > 25.0, "Prop %s at %s is too close to mangrove spot at %s (dist=%.1f)!" % [p_name, p_pos, spot_px, dist])

	print("  -> PASS: Titik tanam mangrove steril dari sampah!")

	# Check player walkability on beach and sidewalk
	var player = world.player
	var hilir_origin = hilir.global_position
	player.global_position = hilir_origin + Vector2(250, 420)
	var init_x = player.global_position.x
	for f in range(40):
		player.velocity = Vector2(100, 0)
		player.move_and_slide()
		await get_tree().physics_frame
	var walked_x = player.global_position.x - init_x
	print("Player walked eastward on beach: %.1f px" % walked_x)
	assert(walked_x > 50.0, "Player must freely navigate along the beach!")
	print("  -> PASS: Navigasi pemain di pesisir pantai lancar tanpa halangan!")

	# 2. VERIFY KOTA MEDAN
	print("\n[CHECK 2] Verifying Kota Medan uses Image 4 trash bags and has no ugly dumpster/debris...")
	world.change_zone("kota", Vector2(100, 205))
	for i in range(25): await get_tree().process_frame

	var kota = world._zone_containers["kota"]
	var kota_props: Array[String] = []
	for child in kota.get_children():
		var tex_name: String = ""
		if child is Sprite2D and child.texture != null:
			tex_name = child.texture.resource_path.get_file()
		elif child is StaticBody2D:
			for grand in child.get_children():
				if grand is Sprite2D and grand.texture != null:
					tex_name = grand.texture.resource_path.get_file()
					break
		if tex_name.begins_with("prop_") and not kota_props.has(tex_name):
			kota_props.append(tex_name)

	print("Found Kota props:", kota_props)
	assert(not kota_props.has("prop_large_dumpster.png"), "Dumpster must be removed from Kota!")
	assert(not kota_props.has("prop_construction_debris.png"), "Debris must be removed from Kota!")
	assert(kota_props.has("prop_trash_bags_black.png"), "Kota must have black trash bags from Image 4!")
	assert(kota_props.has("prop_trash_bags_blue_white.png"), "Kota must have blue/white trash bags from Image 4!")
	print("  -> PASS: Kota Medan juga bersih dari prop jelek dan memakai kantong sampah Gambar 4!")

	print("\n>>> ALL CHECKS PASSED 100%! <<<\n")
	get_tree().quit(0)
