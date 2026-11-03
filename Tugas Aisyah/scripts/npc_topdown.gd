## NPC top-down dengan sprite 4 arah, emote bubble, dan integrasi Dialog/Empati.
extends NPC
class_name NPCTopDown

@export var sprite_key: String = "pedagang"
@export var dialog_id: String = ""       # ID dialog di data/dialog/ (misal: "h1_warung", "h7_ucok")
@export var empati_npc: String = ""      # Jika NPC empati: "jali", "rina", "darwis"
@export var langkah_empati: int = 1

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	_build_sprite()
	super._ready()
	if not dialog_id.is_empty() or not empati_npc.is_empty() or not _dialogue_data.is_empty():
		show_exclaim(true)

func _build_sprite() -> void:
	var path: String = "res://assets/sprites/characters/%s.png" % sprite_key
	if not ResourceLoader.exists(path):
		path = "res://assets/sprites/characters/player.png"
	var texture: Texture2D = load(path)
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

func get_action_label() -> String:
	return "Bicara"

func interact() -> void:
	if not empati_npc.is_empty() and (Engine.has_singleton("EmpatiManager") or get_node_or_null("/root/EmpatiManager")):
		_in_dialogue = true
		var em = get_node_or_null("/root/EmpatiManager")
		# Hitung langkah berdasarkan hari jika otomatis
		var cur_day: int = GameState.hari if "hari" in GameState else GameState.day
		var step := langkah_empati
		if empati_npc.to_lower() == "jali":
			step = 3 if cur_day >= 3 else 1
		elif empati_npc.to_lower() == "rina":
			step = 3 if cur_day >= 5 else 1
		elif empati_npc.to_lower() == "darwis":
			step = 1

		em.mulai(empati_npc, step)
		return

	if not dialog_id.is_empty():
		_in_dialogue = true
		DialogueManager.mulai(dialog_id)
		return

	# Fallback ke base NPC jika memakai format lama
	super.interact()
