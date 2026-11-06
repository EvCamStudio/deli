## Ambil tangkapan layar Level 1, 2, 3, dan 4 top-down untuk inspeksi visual.
extends Node

func _ready() -> void:
	call_deferred("_run")

func _frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _shot(name: String) -> void:
	await _frames(5)
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("C:/Users/Hype AMD/AppData/Local/Temp/%s.png" % name)
	print("captured ", name)

func _capture(path: String, tag: String) -> void:
	GameState.reset()
	var level: Node = load(path).instantiate()
	get_tree().root.add_child(level)
	await _frames(10)

	var camera: Camera2D = level.get_node("Camera2D")
	var player: Node2D = level.get_node("Player")
	camera.position_smoothing_enabled = false

	# Overview seluruh peta.
	level.get_node("HUD").visible = false
	level.get_node("TouchControls").visible = false
	player.global_position = Vector2(480, 268)
	camera.zoom = Vector2(0.64, 0.64)
	await _frames(8)
	await _shot("topdown_%s_overview" % tag)

	# Tampilan gameplay dekat area awal.
	level.get_node("HUD").visible = true
	level.get_node("TouchControls").visible = true
	camera.zoom = Vector2(2, 2)
	player.global_position = Vector2(210, 272)
	await _frames(8)
	await _shot("topdown_%s_game" % tag)

	level.queue_free()
	await _frames(4)

func _run() -> void:
	await _capture("res://scenes/levels/level_1_hulu_topdown.tscn", "l1")
	await _capture("res://scenes/levels/level_2_desa_topdown.tscn", "l2")
	await _capture("res://scenes/levels/level_3_kota_topdown.tscn", "l3")
	await _capture("res://scenes/levels/level_4_hilir_topdown.tscn", "l4")
	get_tree().quit()
