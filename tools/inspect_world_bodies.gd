extends Node

func _ready():
	var world_packed = load("res://scenes/world/world_sungai_deli.tscn")
	var world = world_packed.instantiate()
	add_child(world)
	
	for i in range(10):
		await get_tree().process_frame

	var map = world.map if "map" in world else world.get_node_or_null("TopdownMap")
	print("World loaded successfully!")

	# Print all children of world with StaticBody2D
	var bodies = []
	for child in world.get_children():
		if child is StaticBody2D:
			bodies.append(child)
	print("Total StaticBody2Ds in world:", bodies.size())
	for b in bodies:
		var col = b.get_node_or_null("CollisionShape2D")
		if col and col.shape:
			print("StaticBody at pos=", b.position, " size=", col.shape.size)

	get_tree().quit(0)
