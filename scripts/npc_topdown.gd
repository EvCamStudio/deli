## NPC top-down dengan sprite 4 arah dan emote bubble.
extends NPC

@export var sprite_key: String = "pedagang"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	_build_sprite()
	super._ready()
	if not _dialogue_data.is_empty():
		show_exclaim(true)

func _build_sprite() -> void:
	var texture: Texture2D = load("res://assets/sprites/characters/%s.png" % sprite_key)
	if texture == null:
		return
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 1.5)
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(0, 0, 16, 24)
	frames.add_frame("idle", atlas)
	anim.sprite_frames = frames
	anim.play("idle")
