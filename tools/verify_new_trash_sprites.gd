extends Node

func _ready() -> void:
	print("--- Testing New Trash Sprites ---")
	var trash_scene: PackedScene = preload("res://scenes/world/trash_topdown.tscn")
	assert(trash_scene != null, "trash_topdown scene must exist")

	var test_cats: Array = ["plastik", "organik", "b3"]
	for i in range(15):
		var t: Node = trash_scene.instantiate()
		var tid: String = "test_trash_%d" % i
		var cat: String = test_cats[i % test_cats.size()]
		t.set("trash_id", tid)
		t.set("category", cat)
		add_child(t)
		
		var spr: Sprite2D = t.get_node_or_null("Sprite2D") as Sprite2D
		assert(spr != null, "Sprite2D must exist")
		assert(spr.texture != null, "Sprite texture must not be null")
		print("Spawned trash %d: ID=%s, Cat=%s, ItemID=%s, ItemName=%s, Texture=%s, Size=%s" % [
			i, tid, cat, t.get("item_id"), t.get("item_name"), spr.texture.resource_path, spr.texture.get_size()
		])
		t.queue_free()

	print("--- All Trash Sprites Loaded Successfully! ---")
	get_tree().quit(0)
