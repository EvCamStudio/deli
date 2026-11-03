## Datuk Sampan (Orang 2: Dialog & NPC)
## Tokoh orisinal penutur lisan kearifan lokal Melayu Deli.
## Mengapung di tepi sungai dengan sampan berkabut.
## Transparansi mengikuti kepedulian warga: 0.4 + 0.2 * jumlah_peduli.
extends Node2D
class_name DatukSampan

@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_area: Area2D = $InteractArea
@onready var exclaim_label: Label = $ExclaimLabel

@export var dialog_id: String = "h1_datuk"

var _bob_tween: Tween = null

func _ready() -> void:
	# Hubungkan ke sinyal EmpatiManager untuk update transparansi
	if Engine.has_singleton("EmpatiManager") or get_node_or_null("/root/EmpatiManager"):
		var em = get_node_or_null("/root/EmpatiManager")
		if em:
			em.datuk_opacity_changed.connect(_on_opacity_changed)
			_update_opacity(em.get_datuk_opacity())

	# Hubungkan interaksi
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)

	if exclaim_label:
		exclaim_label.visible = true

	# Animasi melayang/terapung pelan di atas sampan
	_start_floating_animation()

func _update_opacity(alpha_val: float) -> void:
	if sprite:
		var tw := create_tween()
		tw.tween_property(sprite, "modulate:a", alpha_val, 0.4)

func _on_opacity_changed(new_opacity: float) -> void:
	_update_opacity(new_opacity)

func _start_floating_animation() -> void:
	if _bob_tween:
		_bob_tween.kill()
	_bob_tween = create_tween().set_loops()
	_bob_tween.tween_property(sprite, "position:y", -2.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_bob_tween.tween_property(sprite, "position:y", 2.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## Dipanggil oleh player saat menekan tombol interaksi [E]
func interact() -> void:
	# Tentukan dialog berdasarkan hari saat ini
	var cur_day: int = GameState.hari if "hari" in GameState else GameState.day
	var target_dialog := "h1_datuk"
	match cur_day:
		1: target_dialog = "h1_datuk"
		3: target_dialog = "h3_jali"
		5: target_dialog = "h5_rina"
		7: target_dialog = "h7_pantun"
		_: target_dialog = dialog_id

	DialogueManager.mulai(target_dialog)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and exclaim_label:
		exclaim_label.text = "[E] Bicara"

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") and exclaim_label:
		exclaim_label.text = "!"
