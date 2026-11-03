## Warung Interactable Script
## Mengatur visual warung (rusak vs bersih) dan interaksi pemulihan warung.
extends Node2D
class_name WarungInteractable

@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_area: Area2D = $InteractArea
@onready var label: Label = $Label

const TEX_RUSAK := preload("res://assets/sprites/props/warung_rusak.png")
const TEX_BERSIH := preload("res://assets/sprites/props/warung_bersih.png")

func _ready() -> void:
	_update_visual()
	GameState.warung_pulih_changed.connect(_on_warung_changed)
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)
	if label:
		label.hide()

func _update_visual() -> void:
	if sprite:
		sprite.texture = TEX_BERSIH if GameState.warung_bersih else TEX_RUSAK

func _on_warung_changed(status: bool) -> void:
	_update_visual()

func interact() -> void:
	if GameState.warung_bersih:
		var hud := get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_toast"):
			hud.show_toast("Warung sudah bersih dan asri! Memberikan Rp 15.000 setiap pagi.")
		return

	# Coba bersihkan warung
	if GameState.rupiah >= 50000:
		var sukses := GameState.bersihkan_warung()
		if sukses:
			var hud := get_tree().get_first_node_in_group("hud")
			if hud and hud.has_method("show_toast"):
				hud.show_toast("Warung berhasil dibersihkan! (Biaya Rp 50.000, Meter Bencana -5)")
			if AudioManager:
				AudioManager.play_sfx("correct")
	else:
		var sisa: int = 50000 - GameState.rupiah
		var hud := get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_toast"):
			hud.show_toast("Butuh Rp 50.000 untuk membersihkan warung. Kurang Rp %d lagi." % sisa)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and label:
		label.text = "[E] Warung Bersih" if GameState.warung_bersih else "[E] Bersihkan Warung (Rp 50rb)"
		label.show()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") and label:
		label.hide()

