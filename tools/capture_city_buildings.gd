extends Node

const ARTIFACT_DIR := "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8"

func _ready() -> void:
	call_deferred("_run")

func _frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _shot(filename: String) -> void:
	await _frames(8)
	var vp := get_viewport()
	var tex := vp.get_texture()
	if tex != null:
		var img := tex.get_image()
		if img != null:
			var save_path := "%s/%s" % [ARTIFACT_DIR, filename]
			img.save_png(save_path)
			print("Saved screenshot: ", save_path)

func _run() -> void:
	GameState.reset()
	GameState.world_zone = "kota"
	var level_scene := load("res://scenes/levels/level_3_kota_topdown.tscn")
	var level: Node = level_scene.instantiate()
	get_tree().root.add_child(level)
	await _frames(15)

	var camera: Camera2D = level.get_node_or_null("Camera2D")
	var player: Node2D = level.get_node_or_null("Player")
	if camera != null:
		camera.position_smoothing_enabled = false

	var hud := level.get_node_or_null("HUD")
	if hud != null:
		hud.visible = false
	var touch := level.get_node_or_null("TouchControls")
	if touch != null:
		touch.visible = false

	# 1. North West: building_apartment & building_office_glass
	if camera != null and player != null:
		player.global_position = Vector2(180, 150)
		camera.global_position = Vector2(180, 130)
		camera.zoom = Vector2(2.0, 2.0)
	await _shot("ingame_kota_north_west.png")

	# 2. North Central: market_sayur, building_corporate_tower, building_helipad_tower
	if camera != null and player != null:
		player.global_position = Vector2(530, 150)
		camera.global_position = Vector2(530, 130)
		camera.zoom = Vector2(1.8, 1.8)
	await _shot("ingame_kota_north_central.png")

	# 3. North East: building_condo_terrace
	if camera != null and player != null:
		player.global_position = Vector2(830, 150)
		camera.global_position = Vector2(830, 130)
		camera.zoom = Vector2(2.0, 2.0)
	await _shot("ingame_kota_north_east.png")

	# 4. South East: building_brick_complex
	if camera != null and player != null:
		player.global_position = Vector2(830, 440)
		camera.global_position = Vector2(830, 420)
		camera.zoom = Vector2(2.0, 2.0)
	await _shot("ingame_kota_south_east.png")

	# 5. Full Kota Overview
	if camera != null and player != null:
		player.global_position = Vector2(480, 272)
		camera.global_position = Vector2(480, 272)
		camera.zoom = Vector2(0.85, 0.85)
	await _shot("ingame_kota_overview.png")

	get_tree().quit()
