extends Node

func _ready() -> void:
	print("\n=== STARTING VERIFICATION: REMOVAL OF TRASH IN DESA SOUTHEAST YARD ===")
	
	var world_scene: PackedScene = load("res://scenes/world/world_sungai_deli.tscn")
	assert(world_scene != null, "Failed to load world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)
	
	for i in range(25): await get_tree().process_frame
	
	# Switch to Desa
	world.change_zone("desa", Vector2(850, 368))
	for i in range(25): await get_tree().process_frame
	
	var desa_container: Node2D = world._zone_containers["desa"]
	assert(desa_container != null, "Zone Desa container missing")
	
	# Check all props in Desa in the area shown in the image (x >= 870, y >= 350)
	var found_trash_props: Array = []
	for child in desa_container.get_children():
		if child is StaticBody2D:
			for grand in child.get_children():
				if grand is Sprite2D and grand.texture != null:
					var path: String = grand.texture.resource_path
					if path.contains("trash"):
						if child.position.x >= 870 and child.position.y >= 350:
							found_trash_props.append({"path": path.get_file(), "pos": child.position})
		elif child is Sprite2D and child.texture != null:
			var path: String = child.texture.resource_path
			if path.contains("trash"):
				if child.position.x >= 870 and child.position.y >= 350:
					found_trash_props.append({"path": path.get_file(), "pos": child.position})
		elif child.is_in_group("world_trash"):
			if child.position.x >= 870 and child.position.y >= 350:
				found_trash_props.append({"type": "world_trash", "pos": child.position})
				
	print("Trash items found in southeast Desa yard (x >= 870, y >= 350):", found_trash_props)
	assert(found_trash_props.is_empty(), "Southeast Desa yard must be completely free of trash!")
	print("  -> PASS: Semua tumpukan sampah di pekarangan rumah modern Desa telah berhasil dihapus bersih!")
	print("  -> PASS: Semua tumpukan sampah di pekarangan rumah modern Desa telah berhasil dihapus bersih!")
	
	get_tree().quit(0)
