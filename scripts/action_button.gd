## ActionButton — tombol aksi kontekstual untuk perangkat sentuh.
extends TextureButton

func _ready() -> void:
	add_to_group("touch_controls")
	focus_mode = Control.FOCUS_NONE
	button_down.connect(_on_down)
	button_up.connect(_on_up)
	modulate.a = SettingsManager.get_setting("touch_opacity", 0.7)

func _on_down() -> void:
	Input.action_press("action")

func _on_up() -> void:
	Input.action_release("action")

func apply_settings() -> void:
	modulate.a = SettingsManager.get_setting("touch_opacity", 0.7)
