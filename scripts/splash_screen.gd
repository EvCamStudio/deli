## SplashScreen Script (Deli Rewind)
## Mini-Skit Komedi & Horor Bang Jali vs Hantu Datuk Sampan
extends Control

const MAIN_MENU_SCENE: String = "res://scenes/main_menu/main_menu.tscn"

var _stage: Control = null
var _sky_rect: ColorRect = null
var _lamp_glow: ColorRect = null
var _water_splash_lbl: Label = null

var _jali_sprite: Sprite2D = null
var _datuk_ghost: Sprite2D = null
var _datuk_aura: Sprite2D = null
var _trash_bag: TextureRect = null
var _bin_tex: TextureRect = null

var _jali_bubble: PanelContainer = null
var _jali_bubble_lbl: Label = null
var _datuk_bubble: PanelContainer = null
var _datuk_bubble_lbl: Label = null

var _title_plaque: PanelContainer = null
var _fade_overlay: ColorRect = null

var _jali_state: String = "walk" # walk, look, laugh, shocked, dizzy
var _anim_clock: float = 0.0
var _shake_amount: float = 0.0
var _stage_base_pos: Vector2 = Vector2(40, 82)
var _tween: Tween = null
var _transitioning: bool = false

func _ready() -> void:
	_build_comedy_horror_splash()
	_play_skit_sequence()

func _process(delta: float) -> void:
	_anim_clock += delta
	if _stage:
		if _shake_amount > 0.0:
			_shake_amount = move_toward(_shake_amount, 0.0, delta * 10.0)
			_stage.position = _stage_base_pos + Vector2(
				randf_range(-_shake_amount, _shake_amount),
				randf_range(-_shake_amount, _shake_amount)
			)
		else:
			_stage.position = _stage_base_pos

	if _jali_sprite:
		match _jali_state:
			"walk":
				_jali_sprite.frame = 8 + (int(_anim_clock * 9.0) % 4)
				_jali_sprite.rotation = 0.0
			"look":
				_jali_sprite.frame = 4 if (int(_anim_clock * 5.0) % 2 == 0) else 8
				_jali_sprite.rotation = 0.0
			"laugh":
				_jali_sprite.frame = 0
				_jali_sprite.position.y = 128.0 - abs(sin(_anim_clock * 18.0)) * 7.0
				_jali_sprite.rotation = sin(_anim_clock * 14.0) * 0.10
			"shocked":
				_jali_sprite.frame = 4
				_jali_sprite.rotation = sin(_anim_clock * 20.0) * 0.05
			"dizzy":
				_jali_sprite.frame = 0
				_jali_sprite.rotation = deg_to_rad(-82.0) + sin(_anim_clock * 10.0) * 0.05

	if _datuk_ghost and _datuk_ghost.visible:
		var hover: float = sin(_anim_clock * 6.0) * 4.0
		_datuk_ghost.position.y = 114.0 + hover
		if _datuk_aura:
			_datuk_aura.position = _datuk_ghost.position
			_datuk_aura.scale = _datuk_ghost.scale * (1.12 + sin(_anim_clock * 12.0) * 0.06)

func _input(event: InputEvent) -> void:
	if _transitioning:
		return
	if event is InputEventMouseButton and event.pressed:
		_finish_to_main_menu()
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed:
		_finish_to_main_menu()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("action") or event.is_action_pressed("pause"):
		_finish_to_main_menu()
		get_viewport().set_input_as_handled()

func _build_comedy_horror_splash() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var pixel_font: Font = load("res://assets/fonts/PixelifySans.ttf") if ResourceLoader.exists("res://assets/fonts/PixelifySans.ttf") else null

	var outer_bg := ColorRect.new()
	outer_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	outer_bg.color = Color(0.04, 0.04, 0.05, 1.0)
	add_child(outer_bg)

	# =========================================================================
	# PANGGUNG MINI-SKIT (560 x 236)
	# =========================================================================
	var frame := PanelContainer.new()
	frame.position = _stage_base_pos
	frame.size = Vector2(560, 236)
	var frame_sb := StyleBoxFlat.new()
	frame_sb.bg_color = Color(0.07, 0.08, 0.11, 1.0)
	frame_sb.border_width_left = 4
	frame_sb.border_width_top = 4
	frame_sb.border_width_right = 4
	frame_sb.border_width_bottom = 4
	frame_sb.border_color = Color(0.68, 0.50, 0.24, 1.0)
	frame_sb.set_corner_radius_all(8)
	frame_sb.shadow_color = Color(0, 0, 0, 0.7)
	frame_sb.shadow_size = 12
	frame.add_theme_stylebox_override("panel", frame_sb)
	add_child(frame)
	_stage = frame

	var stage_inner := Control.new()
	stage_inner.clip_contents = true
	stage_inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage_inner.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(stage_inner)

	# Langit Malam Pinggir Sungai
	_sky_rect = ColorRect.new()
	_sky_rect.position = Vector2.ZERO
	_sky_rect.size = Vector2(552, 228)
	_sky_rect.color = Color(0.08, 0.10, 0.16, 1.0)
	stage_inner.add_child(_sky_rect)

	# Siluet Pepohonan & Rumah di Kejauhan
	_add_prop(stage_inner, "res://assets/sprites/props/tree_tall_beringin.png", Vector2(12, 8), Vector2(96, 108), Color(0.55, 0.62, 0.70, 0.85))
	_add_prop(stage_inner, "res://assets/sprites/props/house_seng_motor.png", Vector2(96, 26), Vector2(118, 90), Color(0.75, 0.78, 0.85, 0.92))
	_add_prop(stage_inner, "res://assets/sprites/props/tree_kelapa.png", Vector2(452, 12), Vector2(92, 108), Color(0.55, 0.65, 0.72, 0.88))

	# Bantaran Rumput & Trotoar Pinggir Sungai
	var grass_rect := ColorRect.new()
	grass_rect.position = Vector2(0, 106)
	grass_rect.size = Vector2(552, 42)
	grass_rect.color = Color(0.16, 0.34, 0.20, 1.0)
	stage_inner.add_child(grass_rect)

	var path_rect := ColorRect.new()
	path_rect.position = Vector2(0, 130)
	path_rect.size = Vector2(552, 20)
	path_rect.color = Color(0.46, 0.36, 0.25, 1.0)
	stage_inner.add_child(path_rect)

	var edge_wall := ColorRect.new()
	edge_wall.position = Vector2(0, 148)
	edge_wall.size = Vector2(552, 5)
	edge_wall.color = Color(0.32, 0.26, 0.20, 1.0)
	stage_inner.add_child(edge_wall)

	# Air Sungai Malam di Bawah (y = 153..228)
	var river_rect := ColorRect.new()
	river_rect.position = Vector2(0, 153)
	river_rect.size = Vector2(552, 75)
	river_rect.color = Color(0.10, 0.24, 0.34, 1.0)
	stage_inner.add_child(river_rect)

	var wave_line1 := ColorRect.new()
	wave_line1.position = Vector2(60, 174)
	wave_line1.size = Vector2(140, 2)
	wave_line1.color = Color(0.36, 0.66, 0.82, 0.35)
	stage_inner.add_child(wave_line1)

	var wave_line2 := ColorRect.new()
	wave_line2.position = Vector2(310, 196)
	wave_line2.size = Vector2(160, 2)
	wave_line2.color = Color(0.36, 0.66, 0.82, 0.35)
	stage_inner.add_child(wave_line2)

	# Lampu Jalan (lamp.png) + Sorot Cahaya Kuning & Tong Sampah (bin_organik.png)
	_lamp_glow = ColorRect.new()
	_lamp_glow.position = Vector2(182, 54)
	_lamp_glow.size = Vector2(88, 94)
	_lamp_glow.color = Color(1.0, 0.88, 0.42, 0.14)
	stage_inner.add_child(_lamp_glow)

	_add_prop(stage_inner, "res://assets/sprites/props/lamp.png", Vector2(204, 48), Vector2(44, 88))
	_bin_tex = _add_prop(stage_inner, "res://assets/sprites/props/bin_organik.png", Vector2(182, 102), Vector2(34, 38))
	_bin_tex.pivot_offset = Vector2(17, 34)

	# =========================================================================
	# KARAKTER 1: BANG JALI (bang_jali.png) + KANTONG SAMPAH HITAM (kantong_hitam.png)
	# =========================================================================
	_jali_sprite = Sprite2D.new()
	if ResourceLoader.exists("res://assets/sprites/characters/bang_jali.png"):
		_jali_sprite.texture = load("res://assets/sprites/characters/bang_jali.png")
	_jali_sprite.hframes = 4
	_jali_sprite.vframes = 4
	_jali_sprite.frame = 8
	_jali_sprite.scale = Vector2(1.75, 1.75)
	_jali_sprite.position = Vector2(70, 128)
	stage_inner.add_child(_jali_sprite)

	_trash_bag = _add_prop(stage_inner, "res://assets/sprites/props/trash/full/kantong_hitam.png", Vector2(82, 114), Vector2(28, 28))
	_trash_bag.pivot_offset = Vector2(14, 14)

	# Efek Tulisan Cipratan Air "💦 PLUNG!!"
	_water_splash_lbl = Label.new()
	_water_splash_lbl.text = "💦 PLUNG!!"
	_water_splash_lbl.position = Vector2(334, 168)
	_water_splash_lbl.add_theme_font_size_override("font_size", 13)
	_water_splash_lbl.add_theme_color_override("font_color", Color(0.68, 0.92, 1.0, 1.0))
	if pixel_font:
		_water_splash_lbl.add_theme_font_override("font", pixel_font)
	_water_splash_lbl.modulate.a = 0.0
	stage_inner.add_child(_water_splash_lbl)

	# =========================================================================
	# KARAKTER 2: HANTU DATUK SAMPAN RAKSASA DARI SUNGAI (datuk.png)
	# =========================================================================
	_datuk_aura = Sprite2D.new()
	if ResourceLoader.exists("res://assets/sprites/characters/datuk.png"):
		_datuk_aura.texture = load("res://assets/sprites/characters/datuk.png")
	_datuk_aura.hframes = 4
	_datuk_aura.vframes = 4
	_datuk_aura.frame = 4
	_datuk_aura.modulate = Color(0.20, 1.0, 0.95, 0.45)
	_datuk_aura.scale = Vector2(2.8, 2.8)
	_datuk_aura.position = Vector2(368, 175)
	_datuk_aura.visible = false
	stage_inner.add_child(_datuk_aura)

	_datuk_ghost = Sprite2D.new()
	if ResourceLoader.exists("res://assets/sprites/characters/datuk.png"):
		_datuk_ghost.texture = load("res://assets/sprites/characters/datuk.png")
	_datuk_ghost.hframes = 4
	_datuk_ghost.vframes = 4
	_datuk_ghost.frame = 4
	_datuk_ghost.modulate = Color(0.65, 1.0, 0.96, 0.95)
	_datuk_ghost.scale = Vector2(0.1, 0.1)
	_datuk_ghost.position = Vector2(368, 175)
	_datuk_ghost.visible = false
	stage_inner.add_child(_datuk_ghost)

	# =========================================================================
	# BALON DIALOG KOMIK (Bang Jali & Hantu Datuk Sampan)
	# =========================================================================
	_jali_bubble = _create_speech_bubble(stage_inner, Vector2(170, 44), Color(1.0, 0.97, 0.88, 0.96), Color(0.38, 0.24, 0.12, 1.0), pixel_font)
	_jali_bubble_lbl = _jali_bubble.get_child(0) as Label
	_jali_bubble.modulate.a = 0.0

	_datuk_bubble = _create_speech_bubble(stage_inner, Vector2(246, 18), Color(0.08, 0.22, 0.26, 0.96), Color(0.32, 0.96, 0.88, 1.0), pixel_font)
	_datuk_bubble_lbl = _datuk_bubble.get_child(0) as Label
	_datuk_bubble_lbl.add_theme_color_override("font_color", Color(0.68, 1.0, 0.95, 1.0))
	_datuk_bubble.modulate.a = 0.0

	# =========================================================================
	# PAPAN JUDUL "DELI REWIND" (plaque_frame.png — Bersih Tanpa Slogan Cringe)
	# =========================================================================
	_title_plaque = PanelContainer.new()
	_title_plaque.position = Vector2(150, 10)
	_title_plaque.size = Vector2(340, 64)
	if ResourceLoader.exists("res://assets/ui/plaque_frame.png"):
		var plaque_sb := StyleBoxTexture.new()
		plaque_sb.texture = load("res://assets/ui/plaque_frame.png")
		plaque_sb.content_margin_left = 24.0
		plaque_sb.content_margin_top = 10.0
		plaque_sb.content_margin_right = 24.0
		plaque_sb.content_margin_bottom = 10.0
		_title_plaque.add_theme_stylebox_override("panel", plaque_sb)
	add_child(_title_plaque)

	var main_title := Label.new()
	main_title.text = "DELI REWIND"
	main_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main_title.add_theme_font_size_override("font_size", 24)
	main_title.add_theme_color_override("font_color", Color(0.26, 0.14, 0.05, 1.0))
	if pixel_font:
		main_title.add_theme_font_override("font", pixel_font)
	_title_plaque.add_child(main_title)

	var skip_hint := Label.new()
	skip_hint.text = "Next ▶"
	skip_hint.position = Vector2(440, 336)
	skip_hint.size = Vector2(160, 16)
	skip_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	skip_hint.add_theme_font_size_override("font_size", 9)
	skip_hint.add_theme_color_override("font_color", Color(0.65, 0.56, 0.44, 0.60))
	if pixel_font:
		skip_hint.add_theme_font_override("font", pixel_font)
	add_child(skip_hint)

	_fade_overlay = ColorRect.new()
	_fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_overlay.color = Color(0.03, 0.03, 0.03, 1.0)
	_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade_overlay)

func _add_prop(parent: Control, path: String, pos: Vector2, sz: Vector2, tint: Color = Color.WHITE) -> TextureRect:
	var tr := TextureRect.new()
	tr.position = pos
	tr.size = sz
	tr.modulate = tint
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(path):
		tr.texture = load(path)
	parent.add_child(tr)
	return tr

func _create_speech_bubble(parent: Control, pos: Vector2, bg_col: Color, border_col: Color, font: Font) -> PanelContainer:
	var pc := PanelContainer.new()
	pc.position = pos
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = border_col
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 10.0
	sb.content_margin_top = 5.0
	sb.content_margin_right = 10.0
	sb.content_margin_bottom = 5.0
	pc.add_theme_stylebox_override("panel", sb)
	parent.add_child(pc)

	var lbl := Label.new()
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(0.20, 0.12, 0.06, 1.0))
	if font:
		lbl.add_theme_font_override("font", font)
	pc.add_child(lbl)
	return pc

func _play_skit_sequence() -> void:
	_tween = create_tween()

	# 1. (0.0s - 0.85s) Bang Jali jalan santai bawa kantong sampah melewati tong sampah
	_tween.tween_property(_fade_overlay, "modulate:a", 0.0, 0.30)
	_tween.parallel().tween_property(_jali_sprite, "position:x", 242.0, 0.85)
	_tween.parallel().tween_property(_trash_bag, "position:x", 252.0, 0.85)

	# 2. (0.85s - 1.15s) Celingak-celinguk tengok kiri kanan
	_tween.tween_callback(func():
		_jali_state = "look"
	)
	_tween.tween_interval(0.32)

	# 3. (1.15s - 1.65s) Lempar kantong sampah melambung ke sungai + ketawa
	_tween.tween_callback(func():
		_jali_state = "laugh"
		_jali_bubble_lbl.text = "😂 \"Hehehe... Hanyut kau ke sungai!\""
		_jali_bubble.modulate.a = 1.0
		if AudioManager and AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("tap_a")
	)
	_tween.tween_property(_trash_bag, "position", Vector2(310, 56), 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(_trash_bag, "rotation_degrees", 180.0, 0.24)
	_tween.tween_property(_trash_bag, "position", Vector2(360, 174), 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.parallel().tween_property(_trash_bag, "rotation_degrees", 360.0, 0.24)

	# Cipratan Air Sungai ("💦 PLUNG!!")
	_tween.tween_callback(func():
		_water_splash_lbl.modulate.a = 1.0
		if AudioManager and AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("footstep_water")
	)
	_tween.tween_interval(0.65)

	# 4. Hantu Datuk Sampan muncul dari sungai tepat di tempat sampah jatuh!
	_tween.tween_callback(func():
		_water_splash_lbl.modulate.a = 0.0
		_sky_rect.color = Color(0.03, 0.14, 0.18, 1.0)
		_lamp_glow.color = Color(0.20, 1.0, 0.90, 0.22)
		_shake_amount = 2.2
		_datuk_ghost.visible = true
		_datuk_aura.visible = true
		_datuk_bubble_lbl.text = "👻 \"Enak kali kau lempar pas ke kepalaku ya?!\""
		_datuk_bubble.modulate.a = 1.0
		_jali_state = "shocked"
		_jali_bubble_lbl.text = "😱 \"ALAMAK!! HANTU DATUK!!\""
		SettingsManager.vibrate(80)
		if AudioManager and AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("wrong")
	)
	_tween.tween_property(_datuk_ghost, "scale", Vector2(2.65, 2.65), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(_datuk_ghost, "position:y", 114.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(_jali_sprite, "position:y", 104.0, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_jali_sprite, "position:y", 128.0, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_interval(1.05)

	# 5. Datuk putar balik sampahnya -> nge-bonk kepala Bang Jali -> masuk ke tong!
	_tween.tween_callback(func():
		_shake_amount = 1.0
		_datuk_bubble_lbl.text = "⏪ \"Makan tuh balik!\""
		if AudioManager and AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("gate_open")
	)
	_tween.tween_property(_trash_bag, "position", Vector2(236, 96), 0.30).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.parallel().tween_property(_trash_bag, "rotation_degrees", -180.0, 0.30)
	_tween.tween_callback(func():
		_shake_amount = 2.5
		_jali_state = "dizzy"
		_jali_sprite.position.y = 136.0
		_jali_bubble_lbl.text = "💫 \"ADUH!! Ampun Tok...!\""
		SettingsManager.vibrate(90)
		if AudioManager and AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("lever")
	)
	_tween.tween_property(_trash_bag, "position", Vector2(185, 98), 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(_trash_bag, "scale", Vector2(0.2, 0.2), 0.24)
	_tween.tween_callback(func():
		_shake_amount = 0.0
		_trash_bag.visible = false
		if AudioManager and AudioManager.has_method("play_sfx"):
			AudioManager.play_sfx("correct")
		var bin_tw := create_tween()
		bin_tw.tween_property(_bin_tex, "scale", Vector2(1.25, 0.82), 0.08)
		bin_tw.tween_property(_bin_tex, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)
	_tween.tween_interval(1.05)

	# 6. Fade-out masuk ke Main Menu
	_tween.tween_callback(func():
		_finish_to_main_menu()
	)

func _finish_to_main_menu() -> void:
	if _transitioning:
		return
	_transitioning = true
	_shake_amount = 0.0
	if _tween:
		_tween.kill()
	var out_tw := create_tween()
	out_tw.tween_property(_fade_overlay, "modulate:a", 1.0, 0.35)
	out_tw.tween_callback(func():
		get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	)
