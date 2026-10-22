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
	var path: String = "res://scenes/levels/level_%d_%s.tscn" % [level_id, _level_suffix(level_id)]
	change_scene(path)

## Kembali ke main menu.
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
		1: return "hulu"
		2: return "desa"
		3: return "kota"
		4: return "hilir"
		5: return "epilog"
		_: return "hulu"
