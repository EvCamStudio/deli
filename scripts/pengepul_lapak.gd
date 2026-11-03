## Pengepul Lapak Script
## Tempat MC menukarkan sampah terpilah menjadi Rupiah & menurunkan Meter Bencana.
extends Node2D
class_name PengepulLapak

@onready var interact_area: Area2D = $InteractArea
@onready var label: Label = $Label

func _ready() -> void:
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)
	if label:
		label.text = "[E] Jual Sampah"
		label.hide()

func interact() -> void:
	if GameState.setoran_sampah_hari_ini >= 5:
		_show_message("Pengepul: 'Hari ini kuotaku sudah penuh, Dek. Besok lagi ya!'")
		return

	if GameState.energi < 5.0:
		_show_message("Kamu terlalu lelah untuk memilah & menyetor sampah! Tidurlah di kasur.")
		return

	var sukses := GameState.setor_sampah_pengepul()
	if sukses:
		_show_message("Pengepul: 'Bagus! Sampahmu terpilah rapi. Ini Rp 6.000!' (Meter Bencana -2)")
		if AudioManager:
			AudioManager.play_sfx("coin")

func _show_message(pesan: String) -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_toast"):
		hud.show_toast(pesan)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and label:
		label.show()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") and label:
		label.hide()

