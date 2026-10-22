## Player Script — CharacterBody2D
# Gerak horizontal, lompat, coyote time, jump buffer, kamera.
# Deteksi interaksi via Area2D; tombol action kontekstual.
extends CharacterBody2D
class_name Player

# ─── Export ───────────────────────────────────────────────────────────────────
@export var speed: float = 90.0
@export var jump_velocity: float = -220.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12

# ─── Node Referensi ───────────────────────────────────────────────────────────
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_area: Area2D = $InteractArea
@onready var action_label: Label = $ActionLabel  # Label di atas pemain

# ─── State ────────────────────────────────────────────────────────────────────
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _interactable: Node = null    # Objek interaktif terdekat
var _is_dialog_active: bool = false
var _facing_right: bool = true
var _checkpoint_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	_checkpoint_pos = global_position
	# Dengarkan sinyal dialog untuk memblokir kontrol
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	# Dengarkan area interact
	interact_area.body_entered.connect(_on_interact_body_entered)
	interact_area.body_exited.connect(_on_interact_body_exited)
	interact_area.area_entered.connect(_on_interact_area_entered)
	interact_area.area_exited.connect(_on_interact_area_exited)

func _physics_process(delta: float) -> void:
	if _is_dialog_active:
		velocity = Vector2.ZERO
		_update_animation()
		return

	_apply_gravity(delta)
	_handle_jump(delta)
	_handle_movement()
	_handle_action()
	move_and_slide()
	_update_animation()
	_check_fall_out()

# ─── Fisika ───────────────────────────────────────────────────────────────────

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += _gravity * delta
		_coyote_timer = max(_coyote_timer - delta, 0.0)
	else:
		velocity.y = 0.0
		_coyote_timer = coyote_time  # Reset coyote time saat di lantai

func _handle_jump(delta: float) -> void:
	_jump_buffer_timer = max(_jump_buffer_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time

	# Lompat jika buffer aktif DAN (di lantai ATAU coyote time masih aktif)
	if _jump_buffer_timer > 0.0 and (is_on_floor() or _coyote_timer > 0.0):
		velocity.y = jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		AudioManager.play_sfx("jump")

var _is_in_water: bool = false

func set_in_water(state: bool) -> void:
	_is_in_water = state

func _handle_movement() -> void:
	var direction: float = Input.get_axis("move_left", "move_right")
	var current_speed: float = speed * 0.75 if _is_in_water else speed
	if direction != 0.0:
		velocity.x = direction * current_speed
		_facing_right = direction > 0
		if sprite:
			sprite.flip_h = not _facing_right
	else:
		# Deselerasi smooth
		velocity.x = move_toward(velocity.x, 0.0, current_speed * 0.3)

func _handle_action() -> void:
	if Input.is_action_just_pressed("action") and _interactable != null:
		if _interactable.has_method("interact"):
			_interactable.interact()

# ─── Checkpoint dan Jatuh ─────────────────────────────────────────────────────

## Dipanggil saat pemain mencapai checkpoint.
func set_checkpoint(pos: Vector2) -> void:
	_checkpoint_pos = pos

func respawn() -> void:
	global_position = _checkpoint_pos
	velocity = Vector2.ZERO
	GameState.add_river_health(-5.0)

func _check_fall_out() -> void:
	# Jika jatuh terlalu jauh ke bawah (dari level)
	if global_position.y > 600.0:
		respawn()

# ─── Interaksi ────────────────────────────────────────────────────────────────

func _on_interact_body_entered(body: Node) -> void:
	if body.has_method("interact"):
		_set_interactable(body)

func _on_interact_body_exited(body: Node) -> void:
	if body == _interactable:
		_clear_interactable()

func _on_interact_area_entered(area: Area2D) -> void:
	var parent: Node = area.get_parent()
	if parent.has_method("interact"):
		_set_interactable(parent)

func _on_interact_area_exited(area: Area2D) -> void:
	var parent: Node = area.get_parent()
	if parent == _interactable:
		_clear_interactable()

func _set_interactable(obj: Node) -> void:
	_interactable = obj
	# Perbarui label aksi (Bicara / Ambil / Tanam / Tarik)
	var label_text: String = "Aksi"
	if obj.has_method("get_action_label"):
		label_text = obj.get_action_label()
	action_label.text = "[%s]" % label_text
	action_label.visible = true

func _clear_interactable() -> void:
	_interactable = null
	action_label.visible = false

# ─── Animasi ──────────────────────────────────────────────────────────────────

func _update_animation() -> void:
	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	elif abs(velocity.x) > 5.0:
		sprite.play("walk")
	else:
		sprite.play("idle")

# ─── Dialog ───────────────────────────────────────────────────────────────────

func _on_dialogue_started() -> void:
	_is_dialog_active = true
	action_label.visible = false

func _on_dialogue_finished() -> void:
	_is_dialog_active = false
