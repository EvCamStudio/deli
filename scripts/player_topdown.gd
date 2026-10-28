## PlayerTopDown — kontrol karakter untuk peta top-down ala Citampi.
## 4 arah, tanpa gravitasi, interaksi kontekstual, dan efek air.
extends CharacterBody2D
class_name PlayerTopDown

# ─── Export ───────────────────────────────────────────────────────────────────
@export var speed: float = 72.0
@export var water_speed_mult: float = 0.72
@export var sprite_path: String = "res://assets/sprites/characters/player.png"

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadow: Sprite2D = $Shadow
@onready var interact_area: Area2D = $InteractArea
@onready var action_label: Label = $ActionLabel

# ─── State ────────────────────────────────────────────────────────────────────
const ROWS: Dictionary = {"down": 0, "left": 1, "right": 2, "up": 3}
var _facing: String = "down"
var _is_dialog_active: bool = false
var _in_water: bool = false
var _candidates: Array[Node] = []
var _interactable: Node = null

func _ready() -> void:
	add_to_group("player")
	_build_frames()
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)
	interact_area.area_entered.connect(_on_area_entered)
	interact_area.area_exited.connect(_on_area_exited)
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	action_label.visible = false

func _physics_process(delta: float) -> void:
	if _is_dialog_active:
		velocity = Vector2.ZERO
		_update_animation(Vector2.ZERO)
		return

	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var current_speed: float = speed * water_speed_mult if _in_water else speed
	velocity = direction * current_speed
	move_and_slide()

	if Input.is_action_just_pressed("action") and _interactable != null:
		if _interactable.has_method("interact"):
			_interactable.interact()

	_update_animation(direction)
	_refresh_interactable()

func _build_frames() -> void:
	var texture: Texture2D = load(sprite_path)
	if texture == null:
		return
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for dir in ROWS:
		var row: int = ROWS[dir]
		var idle_name := "idle_%s" % dir
		var walk_name := "walk_%s" % dir
		frames.add_animation(idle_name)
		frames.set_animation_loop(idle_name, true)
		frames.set_animation_speed(idle_name, 4.0)
		frames.add_animation(walk_name)
		frames.set_animation_loop(walk_name, true)
		frames.set_animation_speed(walk_name, 8.0)
		for col in range(4):
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(col * 16.0, row * 24.0, 16.0, 24.0)
			frames.add_frame(walk_name, atlas)
			if col == 0 or col == 2:
				frames.add_frame(idle_name, atlas)
	sprite.sprite_frames = frames
	sprite.play("idle_down")

func _update_animation(direction: Vector2) -> void:
	if direction.length() > 0.05:
		if abs(direction.x) > abs(direction.y):
			_facing = "right" if direction.x > 0.0 else "left"
		else:
			_facing = "down" if direction.y > 0.0 else "up"
		sprite.play("walk_%s" % _facing)
	else:
		sprite.play("idle_%s" % _facing)

func set_in_water(state: bool) -> void:
	_in_water = state
	if sprite:
		sprite.modulate = Color(0.82, 0.94, 1.0, 1.0) if state else Color.WHITE
	if shadow:
		shadow.modulate = Color(1, 1, 1, 0.4) if state else Color.WHITE

# ─── Interaksi ────────────────────────────────────────────────────────────────

func _on_body_entered(body: Node) -> void:
	if body.has_method("interact"):
		_add_candidate(body)

func _on_body_exited(body: Node) -> void:
	_candidates.erase(body)
	_refresh_interactable()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("interact"):
		_add_candidate(area)
		return
	var parent: Node = area.get_parent()
	if parent and parent.has_method("interact"):
		_add_candidate(parent)

func _on_area_exited(area: Area2D) -> void:
	if area.has_method("interact"):
		_candidates.erase(area)
		_refresh_interactable()
		return
	var parent: Node = area.get_parent()
	if parent:
		_candidates.erase(parent)
	_refresh_interactable()

func _add_candidate(node: Node) -> void:
	if node not in _candidates:
		_candidates.append(node)
	_refresh_interactable()

func _refresh_interactable() -> void:
	var nearest: Node = null
	var nearest_dist: float = 999999.0
	for node in _candidates:
		if not is_instance_valid(node):
			continue
		var node_2d := node as Node2D
		if node_2d == null:
			continue
		var dist: float = global_position.distance_squared_to(node_2d.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = node

	_interactable = nearest
	if _interactable == null:
		action_label.visible = false
		return

	var text: String = "Aksi"
	if _interactable.has_method("get_action_label"):
		text = str(_interactable.get_action_label())
	if text.is_empty():
		action_label.visible = false
		return
	action_label.text = "[E] %s" % text
	action_label.visible = true

# ─── Dialog ───────────────────────────────────────────────────────────────────

func _on_dialogue_started() -> void:
	_is_dialog_active = true
	action_label.visible = false

func _on_dialogue_finished() -> void:
	_is_dialog_active = false
	_refresh_interactable()
