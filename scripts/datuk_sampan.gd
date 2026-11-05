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
var _is_disappearing: bool = false

func _ready() -> void:
	# Jika Hari 1 dan sudah selesai dialog dengan Datuk (Fase 3+), Datuk sudah menghilang
	if GameState.hari == 1 and GameState.h1_fase >= 3:
		queue_free()
		return

	# Hubungkan ke sinyal EmpatiManager untuk update transparansi
	if Engine.has_singleton("EmpatiManager") or get_node_or_null("/root/EmpatiManager"):
		var em = get_node_or_null("/root/EmpatiManager")
		if em:
			em.datuk_opacity_changed.connect(_on_opacity_changed)
			_update_opacity(em.get_datuk_opacity())

	# Hubungkan dialog selesai & perubahan fase
	if DialogueManager:
		DialogueManager.dialog_selesai.connect(_on_dialog_selesai)
	GameState.h1_fase_changed.connect(_on_h1_fase_changed)

	# Hubungkan interaksi
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)

	# Tampilan awal Hari 1
	if GameState.hari == 1:
		if GameState.h1_fase < 2:
			modulate.a = 0.35
			if exclaim_label:
				exclaim_label.hide()
		elif GameState.h1_fase == 2:
			modulate.a = 1.0
			if exclaim_label:
				exclaim_label.show()
				exclaim_label.text = "!"
	else:
		if exclaim_label:
			exclaim_label.show()
			exclaim_label.text = "!"

	# Animasi melayang/terapung pelan di atas sampan
	_start_floating_animation()

func _update_opacity(alpha_val: float) -> void:
	if sprite and not _is_disappearing:
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

func _on_h1_fase_changed(fase_baru: int) -> void:
	if GameState.hari != 1 or _is_disappearing:
		return
	if fase_baru == 2:
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 1.0, 0.8)
		if exclaim_label:
			exclaim_label.show()
			exclaim_label.text = "!"
	elif fase_baru >= 3:
		_hilangkan_datuk()

func _on_dialog_selesai(id_selesai: String) -> void:
	if id_selesai == "h1_datuk" or (GameState.hari == 1 and GameState.h1_fase >= 2):
		_hilangkan_datuk()

## Hilang dengan efek kabut sungai perlahan memudar
func _hilangkan_datuk() -> void:
	if _is_disappearing:
		return
	_is_disappearing = true
	if _bob_tween:
		_bob_tween.kill()
	if exclaim_label:
		exclaim_label.hide()
	if interact_area:
		interact_area.monitoring = false
		interact_area.monitorable = false

	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 0.0, 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position:y", position.y - 14.0, 1.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.chain().tween_callback(func():
		var hud := get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_toast"):
			hud.show_toast("Sosok Datuk perlahan memudar menyatu dengan kabut Sungai Deli...")
		queue_free()
	)

## Dipanggil oleh player saat menekan tombol interaksi [E]
func interact() -> void:
	if _is_disappearing:
		return
	if GameState.hari == 1:
		if GameState.h1_fase < 2:
			var hud := get_tree().get_first_node_in_group("hud")
			if hud and hud.has_method("show_toast"):
				hud.show_toast("Sosok di atas sampan terlihat samar di balik kabut... Kutip dulu sampah di tepian.")
			return
		elif GameState.h1_fase == 2:
			DialogueManager.mulai("h1_datuk")
			return
		else:
			return

	# Hari-hari lainnya
	var target_dialog := dialog_id
	match GameState.hari:
		3: target_dialog = "h3_jali"
		5: target_dialog = "h5_rina"
		7: target_dialog = "h7_pantun"
	DialogueManager.mulai(target_dialog)

func _on_body_entered(body: Node) -> void:
	if _is_disappearing:
		return
	if body.is_in_group("player") and exclaim_label and exclaim_label.visible:
		exclaim_label.text = "[E] Bicara"

func _on_body_exited(body: Node) -> void:
	if _is_disappearing:
		return
	if body.is_in_group("player") and exclaim_label and exclaim_label.visible:
		exclaim_label.text = "!"
