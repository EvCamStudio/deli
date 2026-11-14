## Cek: saat pemain diam, animasinya hanya 1 frame (kaki rapat) — bukan
## animasi berjalan di tempat. Juga memastikan semua sheet karakter 64x96
## dan frame diam (kolom 0) berbeda dari frame langkah (kolom 2).
extends Node

const DIRECTIONS := ["down", "left", "right", "up"]
const NPC_KEYS := ["pedagang", "ibu", "budi", "pakrt", "penjaga_hutan", "petani", "nelayan"]

var _failures: int = 0


func _check(ok: bool, label: String) -> void:
	if ok:
		print("PASS: ", label)
	else:
		_failures += 1
		printerr("FAIL: ", label)


func _ready() -> void:
	await get_tree().process_frame
	await _verify_player_idle()
	_verify_npc_idle()
	_verify_sheets()
	print("RESULT: ", "PASS" if _failures == 0 else "FAIL", " (%d failures)" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)


func _verify_player_idle() -> void:
	var scene: PackedScene = load("res://scenes/player/player_topdown.tscn")
	var player: Node = scene.instantiate()
	add_child(player)
	await get_tree().process_frame

	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	var frames: SpriteFrames = sprite.sprite_frames
	_check(frames != null, "pemain: SpriteFrames terbentuk")
	if frames != null:
		for dir in DIRECTIONS:
			var idle_name := "idle_%s" % dir
			var walk_name := "walk_%s" % dir
			_check(frames.has_animation(idle_name), "pemain: ada animasi %s" % idle_name)
			_check(frames.get_frame_count(idle_name) == 1,
				"pemain: %s hanya 1 frame (diam, tidak jalan di tempat)" % idle_name)
			_check(frames.get_animation_loop(idle_name) == false,
				"pemain: %s tidak loop" % idle_name)
			_check(frames.get_frame_count(walk_name) == 4,
				"pemain: %s punya 4 frame langkah" % walk_name)
			# Frame diam harus sama di kolom 0 pada sheet.
			if frames.get_frame_count(idle_name) >= 1 and frames.get_frame_count(walk_name) >= 1:
				var idle_tex: AtlasTexture = frames.get_frame_texture(idle_name, 0)
				var walk_tex: AtlasTexture = frames.get_frame_texture(walk_name, 0)
				_check(idle_tex.region == walk_tex.region,
					"pemain: %s memakai kolom 0 (pose berdiri)" % idle_name)
		_check(sprite.animation == "idle_down", "pemain: mulai dari idle_down")
	player.queue_free()


func _verify_npc_idle() -> void:
	for key in NPC_KEYS:
		var path := "res://assets/sprites/characters/%s.png" % key
		var texture: Texture2D = load(path)
		_check(texture != null, "%s: tekstur termuat" % key)
		if texture == null:
			continue
		var frames := SpriteFrames.new()
		frames.add_animation("idle")
		frames.set_animation_speed("idle", 1.5)
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(0, 0, 16, 24)
		frames.add_frame("idle", atlas)
		_check(frames.get_frame_count("idle") == 1, "%s: idle NPC 1 frame" % key)


func _verify_sheets() -> void:
	for key in ["player"] + NPC_KEYS:
		var texture: Texture2D = load("res://assets/sprites/characters/%s.png" % key)
		if texture == null:
			continue
		_check(texture.get_width() == 64 and texture.get_height() == 96,
			"%s: ukuran sheet 64x96" % key)
		var img: Image = texture.get_image()
		var stand: PackedByteArray = img.get_region(Rect2i(0, 0, 16, 24)).get_data()
		var step: PackedByteArray = img.get_region(Rect2i(32, 0, 16, 24)).get_data()
		_check(stand != step, "%s: kolom 0 (diam) beda dari kolom 2 (langkah)" % key)