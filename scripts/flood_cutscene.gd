## FloodCutscene (Deli Rewind)
## Animasi sinematik Bad Ending: air sungai meluap dahsyat menenggelamkan seluruh map.
extends CanvasLayer
class_name FloodCutscene

signal flood_completed

@onready var water_rect: ColorRect = $WaterRect
@onready var debris_container: Control = $DebrisContainer
@onready var alert_banner: PanelContainer = $AlertBanner
@onready var subtitle_panel: PanelContainer = $SubtitlePanel
@onready var subtitle_label: RichTextLabel = $SubtitlePanel/Margin/SubtitleLabel
@onready var darkness_overlay: ColorRect = $DarknessOverlay
@onready var sfx_thunder: AudioStreamPlayer = $SFXThunder

var _camera: Camera2D = null
var _player: CharacterBody2D = null
var _shake_intensity: float = 0.0
var _current_water_level: float = 1.08
var _is_running: bool = false
var _elapsed_time: float = 0.0
var _debris_items: Array[Dictionary] = []

const DEBRIS_TEXTURES: Array[String] = [
	"res://assets/sprites/props/trash_plastik.png",
	"res://assets/sprites/props/trash_organik.png",
	"res://assets/sprites/props/prop_trash_bags_black.png",
	"res://assets/sprites/props/prop_trash_pile_small.png",
	"res://assets/sprites/props/prop_log_wood.png",
	"res://assets/sprites/props/prop_fallen_branches.png",
]

func _ready() -> void:
	layer = 30
	visible = false
	if darkness_overlay:
		darkness_overlay.color = Color(0.12, 0.08, 0.05, 0.0)
	if alert_banner:
		alert_banner.modulate.a = 0.0
	if subtitle_panel:
		subtitle_panel.modulate.a = 0.0
	_set_water_level(1.08)

func _process(delta: float) -> void:
	if not _is_running:
		return

	_elapsed_time += delta

	# 1. Update Camera Trauma Shake
	if _camera and _shake_intensity > 0.0:
		var max_dist: float = _shake_intensity * 14.0
		_camera.offset = Vector2(
			randf_range(-max_dist, max_dist),
			randf_range(-max_dist, max_dist)
		)

	# 2. Update Floating Debris Motion
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	var water_y: float = _current_water_level * vp_size.y

	for item in _debris_items:
		var sprite: Sprite2D = item["sprite"]
		if not is_instance_valid(sprite):
			continue

		# Gerak horizontal terbawa arus deras ke kanan
		item["x"] += item["speed_x"] * delta
		if item["x"] > vp_size.x + 90.0:
			item["x"] = -80.0 - randf() * 120.0

		# Ombak naik-turun (bobbing)
		var bob: float = sin(_elapsed_time * item["bob_freq"] + item["bob_phase"]) * item["bob_amp"]
		sprite.position = Vector2(item["x"], water_y + item["depth_offset"] + bob)
		sprite.rotation = sin(_elapsed_time * 3.2 + item["bob_phase"]) * 0.16

		# Hanya terlihat jika sudah tersapu oleh garis air
		sprite.visible = (_current_water_level < 1.0) and (sprite.position.y >= water_y - 14.0)

func _set_water_level(val: float) -> void:
	_current_water_level = val
	if water_rect and water_rect.material is ShaderMaterial:
		(water_rect.material as ShaderMaterial).set_shader_parameter("water_level", val)

func _play_sfx(key: String) -> void:
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_sfx"):
		am.play_sfx(key)

func _play_bgm(key: Variant) -> void:
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_bgm"):
		am.play_bgm(key)

## Memulai rangkaian animasi sinematik banjir bandang
func start_flood(camera: Camera2D = null, player: CharacterBody2D = null) -> void:
	_camera = camera
	_player = player
	_is_running = true
	_elapsed_time = 0.0
	visible = true

	# Kunci pergerakan player
	if _player:
		_player.velocity = Vector2.ZERO
		if _player.has_method("set_physics_process"):
			_player.set_physics_process(false)

	# Siapkan debris mengapung
	_spawn_debris_fleet()

	# Mainkan suara petir dan gemuruh air
	if sfx_thunder:
		sfx_thunder.play()
	_play_sfx("rain_thunder")

	# Jalankan sekuens sinematik 5 fase
	_run_flood_sequence()

func _spawn_debris_fleet() -> void:
	_debris_items.clear()
	for child in debris_container.get_children():
		child.queue_free()

	var vp_size: Vector2 = get_viewport().get_visible_rect().size

	for i in range(18):
		var tex_path: String = DEBRIS_TEXTURES[i % DEBRIS_TEXTURES.size()]
		var tex: Texture2D = load(tex_path)
		if not tex:
			continue

		var spr := Sprite2D.new()
		spr.texture = tex
		spr.scale = Vector2(randf_range(0.85, 1.25), randf_range(0.85, 1.25))
		debris_container.add_child(spr)

		var item_data := {
			"sprite": spr,
			"x": randf_range(-60.0, vp_size.x + 60.0),
			"speed_x": randf_range(160.0, 320.0), # Laju arus deras
			"bob_amp": randf_range(3.0, 7.5),
			"bob_freq": randf_range(4.0, 7.5),
			"bob_phase": randf_range(0.0, TAU),
			"depth_offset": randf_range(6.0, 50.0), # Variasi kedalaman agar menyebar alami
		}
		_debris_items.append(item_data)

func _run_flood_sequence() -> void:
	# ─── FASE 1: Alarm & Gemuruh (0.0s - 1.2s) ───
	_shake_intensity = 0.45
	_set_water_level(1.06)

	if alert_banner:
		var tw_alert := create_tween()
		tw_alert.tween_property(alert_banner, "modulate:a", 1.0, 0.4)
		tw_alert.parallel().tween_property(alert_banner, "position:y", 16.0, 0.5).from(-40.0)

	_show_subtitle("[b][color=#ffdd88]⚠️ Tanggul sungai jebol! Air bah meluap dari hulu Sungai Deli![/color][/b]")

	await get_tree().create_timer(1.2).timeout

	# ─── FASE 2: Air Meluap Menenggelamkan Bantaran (1.2s - 4.2s) ───
	_shake_intensity = 0.85
	_play_sfx("footstep_water")

	_show_subtitle("[b][color=#ffffff]Arus air bah menerjang daratan... Bantaran dan jalanan mulai terendam![/color][/b]")

	# Air naik meluap dari bawah (1.06) hingga menutupi setengah layar (0.42)
	var tw_water1 := create_tween()
	tw_water1.tween_method(_set_water_level, 1.06, 0.42, 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await tw_water1.finished

	# ─── FASE 3: Seluruh Map Tenggelam (4.2s - 6.5s) ───
	_shake_intensity = 1.0
	_play_sfx("rain_thunder")
	_show_subtitle("[b][color=#ffaaaa]Air meluap menenggelamkan rumah dan pepohonan! Seluruh kawasan tenggelam![/color][/b]")

	# Air naik sepenuhnya menenggelamkan seluruh layar (0.42 -> -0.15)
	var tw_water2 := create_tween()
	tw_water2.tween_method(_set_water_level, 0.42, -0.15, 2.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	await tw_water2.finished

	# ─── FASE 4: Submersion Pekat & Fade to Dark (6.5s - 8.2s) ───
	_shake_intensity = 0.35
	_show_subtitle("[i][color=#ddccbb]Sungai Deli menenggelamkan segalanya... Alam mencari kembali jalannya.[/color][/i]")

	if alert_banner:
		var tw_alert_out := create_tween()
		tw_alert_out.tween_property(alert_banner, "modulate:a", 0.0, 0.8)

	_play_bgm("epilog_bad")

	if darkness_overlay:
		var tw_dark := create_tween()
		tw_dark.tween_property(darkness_overlay, "color:a", 1.0, 1.6)
		await tw_dark.finished

	# ─── FASE 5: Selesai & Pindah ke Ending D ───
	_shake_intensity = 0.0
	if _camera:
		_camera.offset = Vector2.ZERO
	if _player and _player.has_method("set_physics_process"):
		_player.set_physics_process(true)

	_is_running = false
	flood_completed.emit()

	# Pindah ke Layar Ending D (Rewind)
	_trigger_ending()

func _trigger_ending() -> void:
	var gs = get_node_or_null("/root/GameState")
	if gs and gs.has_method("tentukan_ending"):
		gs.tentukan_ending(true)
	elif is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/levels/level_5_epilog.tscn")

func _show_subtitle(text: String) -> void:
	if not subtitle_label or not subtitle_panel:
		return
	if not text.begins_with("[center]"):
		subtitle_label.text = "[center][b][color=#ffffff]%s[/color][/b][/center]" % text
	else:
		subtitle_label.text = text
	var tw := create_tween()
	tw.tween_property(subtitle_panel, "modulate:a", 1.0, 0.25)
