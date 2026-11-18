extends Node

func _ready() -> void:
	print("--- Testing Player Movement & Animation ---")
	var world_scene := preload("res://scenes/world/world_sungai_deli.tscn")
	var world = world_scene.instantiate()
	add_child(world)

	for _i in range(15):
		await get_tree().process_frame

	var player = world.player
	assert(player != null, "Player must exist")
	assert(player.sprite != null, "AnimatedSprite2D must exist")

	var initial_pos: Vector2 = player.global_position
	print("Initial player position:", initial_pos)

	# Test animations exist
	var expected_anims = [
		"idle_down", "idle_up", "idle_left", "idle_right",
		"walk_down", "walk_up", "walk_left", "walk_right"
	]
	for anim in expected_anims:
		assert(player.sprite.sprite_frames.has_animation(anim), "Missing animation: " + anim)
		print("Animation OK:", anim)

	# Test moving down
	player._update_animation(Vector2(0, 1))
	assert(player.sprite.animation == "walk_down", "Should be walk_down")
	assert(player._facing == "down", "Facing should be down")

	# Test moving up
	player._update_animation(Vector2(0, -1))
	assert(player.sprite.animation == "walk_up", "Should be walk_up")
	assert(player._facing == "up", "Facing should be up")

	# Test moving left
	player._update_animation(Vector2(-1, 0))
	assert(player.sprite.animation == "walk_left", "Should be walk_left")
	assert(player._facing == "left", "Facing should be left")

	# Test moving right
	player._update_animation(Vector2(1, 0))
	assert(player.sprite.animation == "walk_right", "Should be walk_right")
	assert(player._facing == "right", "Facing should be right")

	# Test stopping (idle)
	player._update_animation(Vector2.ZERO)
	assert(player.sprite.animation == "idle_right", "Should return to idle_right")

	print("--- All Player Movement & Animation Tests PASSED! ---")
	get_tree().quit(0)
