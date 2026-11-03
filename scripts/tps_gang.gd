## TPS Gang Script
## Menampilkan tumpukan sampah sebelum Jali Peduli, atau bak TPS rapi sesudahnya.
extends Node2D
class_name TPSGang

@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_area: Area2D = $InteractArea
@onready var label: Label = $Label

const TEX_SEBELUM := preload("res://assets/sprites/props/tps_sebelum.png")
const TEX_SESUDAH := preload("res://assets/sprites/props/tps_sesudah.png")

func _ready() -> void:
	_update_visual()
	if Engine.has_singleton("EmpatiManager") or get_node_or_null("/root/EmpatiManager"):
		var em = get_node_or_null("/root/EmpatiManager")
		if em:
			em.tps_terbuka.connect(_on_tps_terbuka)
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)
	if label:
		label.hide()

func _update_visual() -> void:
	if sprite:
		sprite.texture = TEX_SESUDAH if GameState.tps_aktif else TEX_SEBELUM

func _on_tps_terbuka() -> void:
	GameState.tps_aktif = true
	_update_visual()

func interact() -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_toast"):
		if GameState.tps_aktif:
			hud.show_toast("TPS Kecil Ujung Gang: Warga buang sampah terjadwal. Gang bersih!")
		else:
			hud.show_toast("Tumpukan sampah berserakan di mulut gang karena truk tak bisa masuk.")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and label:
		label.text = "[E] TPS Bersih" if GameState.tps_aktif else "[E] Tumpukan Sampah Gang"
		label.show()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") and label:
		label.hide()

