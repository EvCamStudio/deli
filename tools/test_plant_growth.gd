## Uji pertumbuhan bibit berbasis hari: menanam hanya memunculkan bibit,
## pohon menyusul setelah hari berganti, dan statusnya ikut tersimpan.
extends Node

var _fail: int = 0
var _pass: int = 0

func _ready() -> void:
	call_deferred("_run")

func _check(condition: bool, label: String) -> void:
	if condition:
		_pass += 1
		print("PASS  ", label)
	else:
		_fail += 1
		print("FAIL  ", label)

func _frames(count: int) -> void:
	for _i in range(count):
		await get_tree().process_frame

func _find_spot(world: Node) -> Node2D:
	var best: Node2D = null
	for node in world.get_tree().get_nodes_in_group("tree_spot"):
		var spot := node as Node2D
		if spot == null:
			continue
		if str(spot.get("spot_id")).begins_with("hulu_tree"):
			if best == null or int(spot.get("spot_id").split("_")[-1]) < int(best.get("spot_id").split("_")[-1]):
				best = spot
	return best

func _run() -> void:
	GameState.reset()
	GameState.quest_progress = 1
	QuestManager.start_main_quest()
	GameState.start_quest("tanam_pohon_hulu", 5)

	var world: Node = load("res://scenes/world/world_sungai_deli.tscn").instantiate()
	get_tree().root.add_child(world)
	await _frames(10)

	var spot := _find_spot(world)
	_check(spot != null, "Titik tanam hulu ditemukan")
	if spot == null:
		_finish()
		return

	_check(not spot.call("is_planted"), "Sebelum menanam: titik belum ditanam")
	_check(spot.get_node("Marker").visible, "Sebelum menanam: hanya lingkaran tanah yang tampil")
	_check(not spot.get_node("Seedling").visible and not spot.get_node("Planted").visible,
		"Sebelum menanam: tidak ada bibit/pohon")

	spot.call("interact")
	await _frames(3)

	_check(spot.call("is_planted"), "Setelah menanam: titik ditandai")
	_check(int(spot.call("current_stage")) == 0, "Hari yang sama: tahap masih bibit (0)")
	_check(spot.get_node("Seedling").visible, "Setelah menanam: bibit terlihat")
	_check(not spot.get_node("Planted").visible, "Setelah menanam: pohon dewasa tidak muncul")
	_check(not spot.get_node("Marker").visible, "Setelah menanam: lingkaran hilang")
	_check(GameState.planted_days.get(spot.get("spot_id"), 0) == GameState.hari,
		"Hari tanam tercatat (%s -> hari %d)" % [spot.get("spot_id"), GameState.hari])
	_check(GameState.zone_stat("hulu", "trees") == 1, "Statistik pohon hulu bertambah sekali (1)")

	var save_text: String = FileAccess.get_file_as_string(GameState.SAVE_PATH)
	var parsed = JSON.parse_string(save_text)
	var saved_days = parsed.get("planted_days", {}) if parsed is Dictionary else {}
	_check(saved_days is Dictionary and int(saved_days.get(spot.get("spot_id"), 0)) == GameState.hari,
		"File save menyimpan hari tanam")

	var spot_id: String = str(spot.get("spot_id"))
	world.queue_free()
	await _frames(3)
	GameState.planted_days.clear()
	GameState.planted_spots.clear()
	_check(GameState.load_game(), "Save berhasil dimuat ulang")
	_check(int(GameState.planted_days.get(spot_id, 0)) == GameState.hari,
		"Hari tanam pulih dari save")

	var world2: Node = load("res://scenes/world/world_sungai_deli.tscn").instantiate()
	get_tree().root.add_child(world2)
	await _frames(10)

	var spot2 := _find_spot(world2)
	_check(spot2 != null and spot2.call("is_planted"), "Setelah lanjut: titik tetap ditanam")
	if spot2 != null:
		_check(int(spot2.call("current_stage")) == 0, "Setelah lanjut di hari yang sama: masih bibit")
		_check(spot2.get_node("Seedling").visible and not spot2.get_node("Planted").visible,
			"Setelah lanjut: bibit yang tampil, bukan pohon")
		_check(spot2.get_node("Blocker/CollisionShape2D").disabled,
			"Bibit belum menghalangi jalan")

		GameState.hari += 1
		await _frames(3)
		_check(int(spot2.call("current_stage")) == 1, "Hari +1: jadi pohon muda")
		_check(spot2.get_node("Planted").visible and not spot2.get_node("Seedling").visible,
			"Hari +1: pohon muda menggantikan bibit")

		GameState.hari += 1
		await get_tree().create_timer(0.6).timeout
		_check(int(spot2.call("current_stage")) == 2, "Hari +2: jadi pohon dewasa")
		_check(spot2.get_node("Planted").scale.is_equal_approx(Vector2(0.5, 0.5)),
			"Hari +2: skala pohon dewasa penuh")

	world2.queue_free()
	await _frames(3)
	_finish()

func _finish() -> void:
	print("RESULT: %d passed, %d failed" % [_pass, _fail])
	GameState.delete_save()
	get_tree().quit(0 if _fail == 0 else 1)
