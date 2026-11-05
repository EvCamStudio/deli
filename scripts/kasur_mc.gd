## Kasur MC Script
## Tempat MC tidur untuk memulihkan energi dan berganti hari.
extends Node2D
class_name KasurMC

@onready var interact_area: Area2D = $InteractArea
@onready var label: Label = $Label

func _ready() -> void:
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)
	_update_label_state()
	GameState.h1_fase_changed.connect(func(_f): _update_label_state())

func _update_label_state() -> void:
	if not label:
		return
	if GameState.hari == 1 and GameState.h1_fase == 4:
		label.text = "[E] Tidur (Kasur)"
		label.show()
	else:
		label.text = "[E] Tidur"
		label.hide()

func interact() -> void:
	if GameState.hari == 1 and GameState.h1_fase < 4:
		var hud := get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_toast"):
			hud.show_toast("Hari belum selesai. Periksa kondisi sungai dan bicara dengan Ibu terlebih dahulu.")
		return

	# Buka konfirmasi tidur
	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("tampilkan_konfirmasi_tidur"):
		hud.tampilkan_konfirmasi_tidur()
	else:
		# Langsung tidur jika tanpa dialog konfirmasi
		GameState.tidur_ganti_hari()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and label:
		label.text = "[E] Tidur"
		label.show()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") and label:
		if GameState.hari == 1 and GameState.h1_fase == 4:
			label.text = "[E] Tidur (Kasur)"
			label.show()
		else:
			label.hide()
