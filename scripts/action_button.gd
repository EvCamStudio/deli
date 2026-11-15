## ActionButton — tombol aksi kontekstual untuk perangkat sentuh.
extends TextureButton

@onready var icon_rect: TextureRect = get_node_or_null("Icon") as TextureRect

var _press_tween: Tween = null

func _ready() -> void:
	add_to_group("touch_controls")
	focus_mode = Control.FOCUS_NONE
	button_down.connect(_on_down)
	button_up.connect(_on_up)
	resized.connect(_update_pivot)
	_update_pivot()
	modulate = Color.WHITE
	var opacity: float = SettingsManager.get_setting("touch_opacity", 0.7)
	self_modulate = Color(1, 1, 1, opacity)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_refresh_textures()

## Muat tekstur langsung dari PNG sumber supaya perubahan aset langsung terlihat
## tanpa menunggu cache impor Godot diperbarui.
func _refresh_textures() -> void:
	var normal := _load_png("res://assets/ui/action_button.png")
	if normal:
		texture_normal = normal
	var pressed := _load_png("res://assets/ui/action_button_pressed.png")
	if pressed:
		texture_pressed = pressed
	if icon_rect == null:
		return
	var icon := _load_png("res://assets/ui/icons/hand.png")
	if icon:
		icon_rect.texture = icon
		icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _load_png(path: String) -> Texture2D:
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	if bytes.is_empty():
		return null
	var image := Image.new()
	if image.load_png_from_buffer(bytes) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _update_pivot() -> void:
	pivot_offset = size * 0.5

func _on_down() -> void:
	Input.action_press("action")
	_animate_scale(0.9, 0.07)

func _on_up() -> void:
	Input.action_release("action")
	_animate_scale(1.0, 0.14)

func _animate_scale(target: float, duration: float) -> void:
	if _press_tween:
		_press_tween.kill()
	_press_tween = create_tween()
	_press_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_press_tween.tween_property(self, "scale", Vector2(target, target), duration)

func apply_settings() -> void:
	var opacity: float = SettingsManager.get_setting("touch_opacity", 0.7)
	self_modulate = Color(1, 1, 1, opacity)
