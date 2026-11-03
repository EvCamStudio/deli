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
	if label:
		label.text = "[E] Tidur"
		label.hide()

func interact() -> void:
	# Buka konfirmasi tidur
	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("tampilkan_konfirmasi_tidur"):
		hud.tampilkan_konfirmasi_tidur()
	else:
		# Langsung tidur jika tanpa dialog konfirmasi
		GameState.tidur_ganti_hari()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and label:
		label.show()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") and label:
		label.hide()

