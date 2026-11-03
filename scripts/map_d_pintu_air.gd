## Map D: Pintu Air Bendungan
## Tempat berlangsungnya puzzle tuas pintu air dan Ujian Akhir (Hari 7 Malam).
extends MapBase

@onready var gate: Node2D = get_node_or_null("GateTopDown") as Node2D

var _levers_pulled: Array[int] = []
var _target_sequence: Array[int] = [1, 3, 2] # Kombinasi tuas 1-3-2

func _ready() -> void:
	map_name = "Pintu Air"
	super._ready()

	# Jika Hari 7: picu dialog Ujian Akhir
	if GameState.hari == 7 and not GameState.ujian_akhir_selesai:
		get_tree().create_timer(1.0).timeout.connect(func():
			DialogueManager.mulai("h7_ujian_akhir")
		)

func lever_pressed(lever_id: int) -> void:
	on_lever_pulled(lever_id)

func on_lever_pulled(lever_id: int) -> void:
	_levers_pulled.append(lever_id)
	if AudioManager:
		AudioManager.play_sfx("lever")

	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_toast"):
		hud.show_toast("Tuas %d diaktifkan!" % lever_id)

	# Cek apakah sudah 3 tuas ditarik
	if _levers_pulled.size() >= 3:
		if _levers_pulled == _target_sequence:
			_buka_pintu_air_sukses()
		else:
			_reset_tuas()

func _buka_pintu_air_sukses() -> void:
	GameState.ujian_akhir_selesai = true
	if AudioManager:
		AudioManager.play_sfx("correct")

	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_toast"):
		hud.show_toast("PINTU AIR TERBUKA! Aliran air banjir berhasil dialirkan lancar!")

	# Buka pintu air secara visual
	if gate and gate.has_method("open_gate"):
		gate.open_gate()

	# Tunggu sebentar lalu evaluasi ending dan pindah ke scene epilog
	get_tree().create_timer(3.0).timeout.connect(func():
		var kode_ending := GameState.evaluasi_ending()
		if SceneManager:
			SceneManager.change_scene("res://scenes/levels/level_5_epilog.tscn")
	)

func _reset_tuas() -> void:
	_levers_pulled.clear()
	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_toast"):
		hud.show_toast("Kombinasi salah! Urutan tuas ter-reset. Coba lagi.", false)
	# Reset status tuas
	for lever in get_tree().get_nodes_in_group("lever"):
		if lever.has_method("reset_lever"):
			lever.reset_lever()
