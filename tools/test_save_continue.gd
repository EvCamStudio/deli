## Uji simpan dari jurnal lalu "Lanjut" (load + masuk world lagi).
## Memastikan progres, zona, dan posisi pemain terakhir benar-benar pulih.
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

func _run() -> void:
	GameState.reset()
	GameState.quest_progress = 1
	GameState.rupiah = 4321
	GameState.add_zone_stat("desa", "sorted", 3)
	GameState.picked_trash_ids.append("desa_trash_0")
	GameState.world_zone = "desa"

	var world: Node = load("res://scenes/world/world_sungai_deli.tscn").instantiate()
	get_tree().root.add_child(world)
	await _frames(10)

	var player: Node2D = world.get_node("Player")
	var target_pos := Vector2(60 * 16 + 320, 260)
	player.global_position = target_pos
	await _frames(2)

	# Tekan tombol "Simpan Progres" di jurnal.
	var journal: Node = world.get_node("PauseMenu")
	journal.call("open")
	journal.call("_on_save")
	await _frames(2)
	journal.call("close")

	_check(Vector2(GameState.saved_player_x, GameState.saved_player_y).distance_to(target_pos) < 1.0,
		"Tombol simpan mencatat posisi pemain (%.0f,%.0f)" % [GameState.saved_player_x, GameState.saved_player_y])

	var file_text: String = FileAccess.get_file_as_string(GameState.SAVE_PATH)
	var parsed = JSON.parse_string(file_text)
	_check(parsed is Dictionary and int(parsed.get("rupiah", 0)) == 4321, "File save berisi rupiah terbaru")
	_check(parsed is Dictionary and int(parsed.get("zone_progress", {}).get("desa", {}).get("sorted", 0)) == 3,
		"File save berisi progres sampah desa")

	# Simulasikan keluar ke menu utama lalu klik "Lanjut".
	GameState.rupiah = 0
	GameState.zone_progress = GameState._default_zone_progress()
	GameState.picked_trash_ids.clear()
	world.queue_free()
	await _frames(3)

	var loaded: bool = GameState.load_game()
	_check(loaded, "Save berhasil dimuat")
	_check(GameState.world_zone == "desa", "Zona terakhir pulih (%s)" % GameState.world_zone)
	_check(GameState.rupiah == 4321, "Rupiah pulih (%d)" % GameState.rupiah)
	_check(GameState.zone_stat("desa", "sorted") == 3, "Progres sampah pulih (%d)" % GameState.zone_stat("desa", "sorted"))
	_check("desa_trash_0" in GameState.picked_trash_ids, "Daftar sampah terpungut pulih")

	var world2: Node = load("res://scenes/world/world_sungai_deli.tscn").instantiate()
	get_tree().root.add_child(world2)
	await _frames(10)

	var player2: Node2D = world2.get_node("Player")
	_check(player2.global_position.distance_to(target_pos) < 1.0,
		"Posisi pemain pulih setelah Lanjut (%.0f,%.0f vs %.0f,%.0f)" % [
			player2.global_position.x, player2.global_position.y, target_pos.x, target_pos.y])
	_check(GameState.zone_stat("desa", "sorted") == 3, "Progres tetap ada setelah world dimuat ulang")

	world2.queue_free()
	await _frames(3)

	# ── Auto-save saat aplikasi di-pause di menu utama ──────────────────────
	# Simulasikan proses baru: file berisi progres, memori masih default.
	GameState.rupiah = 777
	GameState.save_game()
	GameState.rupiah = 0
	GameState._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	await _frames(1)
	var after_pause = JSON.parse_string(FileAccess.get_file_as_string(GameState.SAVE_PATH))
	_check(after_pause is Dictionary and int(after_pause.get("rupiah", 0)) == 777,
		"Pause di menu utama tidak menimpa save lama")

	GameState.delete_save()
	print("RESULT: %d PASS, %d FAIL" % [_pass, _fail])
	get_tree().quit(1 if _fail > 0 else 0)
