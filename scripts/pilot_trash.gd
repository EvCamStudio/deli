## Sampah top-down: mengapung/bergoyang dan memberi hadiah saat dipungut.
extends TrashItem

@export var item_id: String = ""
var item_name: String = ""

static var _catalog_loaded: bool = false
static var _catalog_by_cat: Dictionary = {
	"plastik": [],
	"organik": [],
	"b3": []
}

static func _load_catalog_if_needed() -> void:
	if _catalog_loaded:
		return
	_catalog_loaded = true
	var path: String = "res://data/trash_types.json"
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var text := file.get_as_text()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) == TYPE_ARRAY:
		for item in parsed:
			if typeof(item) == TYPE_DICTIONARY:
				var cat: String = item.get("category", "")
				if not _catalog_by_cat.has(cat):
					_catalog_by_cat[cat] = []
				_catalog_by_cat[cat].append(item)

func _ready() -> void:
	super._ready()
	_update_visual_and_label()
	if label:
		label.visible = false
	_start_bob()

func _update_visual_and_label() -> void:
	_load_catalog_if_needed()
	var cat_list: Array = _catalog_by_cat.get(category, [])
	var chosen_item: Dictionary = {}

	if not item_id.is_empty():
		for it in cat_list:
			if it.get("id", "") == item_id:
				chosen_item = it
				break
	elif not cat_list.is_empty():
		var idx: int = abs(trash_id.hash()) % cat_list.size()
		chosen_item = cat_list[idx]
		item_id = chosen_item.get("id", "")

	if not chosen_item.is_empty():
		item_name = chosen_item.get("label", "")
		if label:
			label.text = item_name

	if sprite is Sprite2D:
		var s: Sprite2D = sprite as Sprite2D
		var tex: Texture2D = null
		if not chosen_item.is_empty():
			var sprite_rel: String = chosen_item.get("sprite", "")
			var tex_path: String = "res://assets/sprites/props/" + sprite_rel
			if ResourceLoader.exists(tex_path):
				tex = load(tex_path)
		if tex == null:
			var direct_path: String = "res://assets/sprites/props/trash/%s.png" % (item_id if not item_id.is_empty() else trash_id)
			if ResourceLoader.exists(direct_path):
				tex = load(direct_path)
		if tex == null:
			var fallback_path: String = "res://assets/sprites/props/trash_%s.png" % category
			if ResourceLoader.exists(fallback_path):
				tex = load(fallback_path)
		if tex != null:
			s.texture = tex

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
