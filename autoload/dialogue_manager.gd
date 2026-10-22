## DialogueManager Autoload
# Mengelola sistem dialog: memuat JSON, menampilkan via dialogue_box,
# typewriter effect, pilihan bercabang, dan sinyal aktif/selesai.
extends Node

# ─── Sinyal ───────────────────────────────────────────────────────────────────
signal dialogue_started
signal dialogue_finished

# ─── State Internal ───────────────────────────────────────────────────────────
var _dialogue_box: CanvasLayer = null  # Referensi ke node DialogueBox di scene
var _current_data: Array = []          # Data dialog NPC aktif
var _current_node: Dictionary = {}     # Node dialog saat ini
var _is_active: bool = false

# ─── Setup ────────────────────────────────────────────────────────────────────

## Daftarkan dialogue_box dari scene level atau HUD.
func register_dialogue_box(box: CanvasLayer) -> void:
	_dialogue_box = box

# ─── Memuat Dialog ────────────────────────────────────────────────────────────

## Muat file dialog level dari JSON, kembalikan Dictionary semua NPC.
func load_dialogue_file(level_id: int) -> Dictionary:
	var path: String = "res://data/dialogues/level%d.json" % level_id
	if not FileAccess.file_exists(path):
		push_warning("DialogueManager: file tidak ditemukan: " + path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var text: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(text) != OK:
		push_error("DialogueManager: gagal parse JSON: " + path)
		return {}
	return json.get_data()

## Mulai dialog untuk NPC tertentu dari level tertentu.
## npc_data: Array node dialog [{id, speaker, text, choices[]}]
func start_dialogue(npc_data: Array) -> void:
	if _dialogue_box == null:
		push_error("DialogueManager: dialogue_box belum didaftarkan!")
		return
	_current_data = npc_data
	_is_active = true
	dialogue_started.emit()
	_show_node("start")

## Tampilkan node dialog berdasarkan id.
func _show_node(node_id: String) -> void:
	_current_node = {}
	for node in _current_data:
		if node.get("id", "") == node_id:
			_current_node = node
			break

	if _current_node.is_empty():
		_end_dialogue()
		return

	# Kirim data ke DialogueBox untuk ditampilkan
	if _dialogue_box and _dialogue_box.has_method("show_node"):
		_dialogue_box.show_node(_current_node)

## Dipanggil saat pemain mengetuk layar / memilih opsi.
func advance(choice_index: int = -1) -> void:
	if not _is_active:
		return

	# Proses efek dari node saat ini
	_apply_effects(_current_node)

	if choice_index >= 0:
		var choices: Array = _current_node.get("choices", [])
		if choice_index < choices.size():
			var chosen = choices[choice_index]
			_apply_effects(chosen)
			var next_id: String = chosen.get("next", "")
			if next_id.is_empty():
				_end_dialogue()
			else:
				_show_node(next_id)
		return

	# Tanpa pilihan: cek choices di node sekarang
	var choices: Array = _current_node.get("choices", [])
	if choices.is_empty():
		_end_dialogue()
	# Jika ada pilihan, tunggu input pemain (pilihan ditampilkan oleh DialogueBox)

func _apply_effects(node: Dictionary) -> void:
	var effect: Dictionary = node.get("effect", {})
	if effect.is_empty():
		return
	if effect.has("river_health"):
		GameState.add_river_health(float(effect["river_health"]))
	if effect.has("choice"):
		var choice_dict: Dictionary = effect["choice"]
		for key in choice_dict:
			GameState.record_choice(key, choice_dict[key])

func _end_dialogue() -> void:
	_is_active = false
	_current_data = []
	_current_node = {}
	if _dialogue_box and _dialogue_box.has_method("hide_box"):
		_dialogue_box.hide_box()
	dialogue_finished.emit()

func is_active() -> bool:
	return _is_active
