## SceneManager Autoload
# Mengelola perpindahan scene dengan animasi fade in/out.
extends Node

# ─── Konstanta ────────────────────────────────────────────────────────────────
const FADE_DURATION: float = 0.4

# ─── Node ─────────────────────────────────────────────────────────────────────
var _overlay: ColorRect = null
var _tween: Tween = null
var _is_transitioning: bool = false

func _ready() -> void:
	# Buat overlay gelap untuk fade effect
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var canvas := CanvasLayer.new()
	canvas.layer = 128  # Di atas semua konten
	canvas.add_child(_overlay)
	add_child(canvas)

# ─── Publik ───────────────────────────────────────────────────────────────────

## Pindah ke scene berdasarkan path string.
func change_scene(scene_path: String) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_fade_out(scene_path)

## Pindah ke level berdasarkan ID (1–5).
func change_level(level_id: int) -> void:
	GameState.current_level = level_id
	if level_id == 1:
		change_scene("res://scenes/maps/map_a_warung.tscn")
		return
	elif level_id == 5:
		change_scene("res://scenes/levels/level_5_epilog.tscn")
		return
	var path: String = "res://scenes/levels/level_%d_%s.tscn" % [level_id, _level_suffix(level_id)]
	change_scene(path)

## Pindah ke 4 peta Dokumen Utama ("warung", "sungai", "gang_jali", "pintu_air")
func change_map(map_key: String) -> void:
	match map_key.to_lower():
		"warung": change_scene("res://scenes/maps/map_a_warung.tscn")
		"sungai": change_scene("res://scenes/maps/map_b_sungai.tscn")
		"gang_jali", "gang": change_scene("res://scenes/maps/map_c_gang_jali.tscn")
		"pintu_air": change_scene("res://scenes/maps/map_d_pintu_air.tscn")
		_: change_scene("res://scenes/maps/map_a_warung.tscn")

## Pindah ke scene intro dramatis.
func go_to_intro() -> void:
	change_scene("res://scenes/intro/intro_dramatic.tscn")

## Pindah ke main menu.
func go_to_main_menu() -> void:
	change_scene("res://scenes/main_menu/main_menu.tscn")

# ─── Internal ─────────────────────────────────────────────────────────────────

func _fade_out(next_scene: String) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_overlay, "color:a", 1.0, FADE_DURATION)
	_tween.tween_callback(func():
		var err := get_tree().change_scene_to_file(next_scene)
		if err != OK:
			push_error("SceneManager: gagal load scene: " + next_scene)
		_fade_in()
	)

func _fade_in() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_overlay, "color:a", 0.0, FADE_DURATION)
	_tween.tween_callback(func():
		_is_transitioning = false
	)

func _level_suffix(level_id: int) -> String:
	match level_id:
		1: return "hulu_topdown"
		2: return "desa_topdown"
		3: return "kota_topdown"
		4: return "hilir_topdown"
		5: return "epilog"
		_: return "hulu_topdown"
