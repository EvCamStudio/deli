## NPC top-down dengan sprite 4 arah dan emote bubble.
extends NPC

const ROWS: Dictionary = {
	"down": 0,
	"left": 1,
	"right": 2,
	"up": 3
}

@export var sprite_key: String = "pedagang"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	_build_sprite()
	super._ready()
	if not _dialogue_data.is_empty():
		show_exclaim(true)
	var click_area = get_node_or_null("ClickArea") as Area2D
	if click_area:
		click_area.input_event.connect(_on_click_area_input_event)

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		_try_direct_interaction()

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		_try_direct_interaction()

func _try_direct_interaction() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) <= 64.0:
		interact()

func _build_sprite() -> void:
	var texture: Texture2D = load("res://assets/sprites/characters/%s.png" % sprite_key)
	if texture == null:
		return
	var frames := SpriteFrames.new()
	frames.remove_animation("default")

	var frame_w: float = texture.get_width() / 4.0
	var frame_h: float = texture.get_height() / 4.0

	# 1. Animasi default 'idle' (Row 0 Down, Col 0) kompatibel mundur
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 1.5)
	var default_atlas := AtlasTexture.new()
	default_atlas.atlas = texture
	default_atlas.region = Rect2(0.0, 0.0, frame_w, frame_h)
	frames.add_frame("idle", default_atlas)

	# 2. Animasi 4-arah (idle & walk)
	for dir in ROWS:
		var row: int = ROWS[dir]
		var idle_name := "idle_%s" % dir
		var walk_name := "walk_%s" % dir

		frames.add_animation(idle_name)
		frames.set_animation_loop(idle_name, false)
		frames.set_animation_speed(idle_name, 4.0)
		var idle_atlas := AtlasTexture.new()
		idle_atlas.atlas = texture
		idle_atlas.region = Rect2(0.0, row * frame_h, frame_w, frame_h)
		frames.add_frame(idle_name, idle_atlas)

		frames.add_animation(walk_name)
		frames.set_animation_loop(walk_name, true)
		frames.set_animation_speed(walk_name, 7.0)
		for col in [1, 2, 3, 0]:
			var walk_atlas := AtlasTexture.new()
			walk_atlas.atlas = texture
			walk_atlas.region = Rect2(col * frame_w, row * frame_h, frame_w, frame_h)
			frames.add_frame(walk_name, walk_atlas)

	anim.sprite_frames = frames
	anim.position = Vector2(0, -frame_h / 2.0)

	var exclaim_lbl: Control = get_node_or_null("ExclaimLabel") as Control
	if exclaim_lbl:
		exclaim_lbl.position.y = -frame_h - 18.0

	anim.play("idle")

