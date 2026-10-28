## Sampah top-down: mengapung/bergoyang dan memberi hadiah saat dipungut.
extends TrashItem

func _ready() -> void:
	super._ready()
	if sprite is Sprite2D:
		(sprite as Sprite2D).texture = load("res://assets/sprites/props/trash_%s.png" % category)
	if label:
		label.visible = false
	_start_bob()

func _start_bob() -> void:
	var base_y: float = position.y
	var tween := create_tween().set_loops()
	tween.tween_property(self, "position:y", base_y - 2.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", base_y, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func interact() -> void:
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("on_trash_picked"):
		level.on_trash_picked(category, trash_id)
	super.interact()
