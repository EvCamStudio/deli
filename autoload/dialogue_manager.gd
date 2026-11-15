## DialogueManager Autoload (Deli Rewind)
## Mengelola sistem dialog: memuat JSON dari data/dialog atau data/dialogues,
## typewriter effect, portrait, pilihan empati A/B/C, dan efek GameState.
extends Node

# ─── Sinyal ───────────────────────────────────────────────────────────────────
signal dialogue_started
signal dialogue_finished
signal dialog_selesai(id_dialog: String)
signal sampah_balasan(npc: String)

# ─── State Internal ───────────────────────────────────────────────────────────
var _dialogue_box: CanvasLayer = null  # Referensi ke DialogueBox / PortraitDialogue
var _current_data: Array = []          # Data dialog NPC aktif
var _current_node: Dictionary = {}     # Node dialog saat ini
var _current_dialog_id: String = ""
var _current_npc_key: String = ""
var _is_active: bool = false
var last_choice_selected: Dictionary = {}

# ─── Setup ────────────────────────────────────────────────────────────────────

## Daftarkan dialogue_box dari scene level atau HUD.
func register_dialogue_box(box: CanvasLayer) -> void:
	_dialogue_box = box

func _ensure_dialogue_box() -> bool:
	if is_instance_valid(_dialogue_box):
		return true
	var existing = get_tree().root.find_child("DialogueBox", true, false)
	if existing and existing is CanvasLayer:
		_dialogue_box = existing
		return true
	var scene_res := load("res://scenes/ui/portrait_dialogue.tscn")
	if scene_res:
		var instance = scene_res.instantiate() as CanvasLayer
		get_tree().root.add_child(instance)
		_dialogue_box = instance
		return true
	return false

# ─── Memuat Dialog ────────────────────────────────────────────────────────────

## Memulai dialog berdasarkan ID file (misal: "h1_warung", "h1_datuk", "h2_jali", dst).
func mulai(id_dialog: String) -> void:
	_ensure_dialogue_box()
	_current_dialog_id = id_dialog
	_current_npc_key = _detect_npc_from_id(id_dialog)

	var path: String = "res://data/dialog/%s.json" % id_dialog
	if not FileAccess.file_exists(path):
		path = "res://data/dialogues/%s.json" % id_dialog
	if not FileAccess.file_exists(path):
		push_error("DialogueManager: file dialog tidak ditemukan: %s" % path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var text: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(text) != OK:
		push_error("DialogueManager: gagal parse JSON: %s" % path)
		return

	var parsed = json.get_data()
	if parsed is Array:
		_current_data = parsed
	elif parsed is Dictionary and parsed.has("dialog"):
		_current_data = parsed["dialog"]
	else:
		_current_data = [parsed]

	_is_active = true
	dialogue_started.emit()
	_show_node("start")

## Muat file dialog level dari JSON, kembalikan Dictionary semua NPC.
func load_dialogue_file(level_id: int) -> Dictionary:
	var path: String = "res://data/dialogues/level%d.json" % level_id
	if not FileAccess.file_exists(path):
		path = "res://data/dialog/level%d.json" % level_id
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

## Mulai dialog untuk NPC tertentu dari array data langsung.
func start_dialogue(npc_data: Array, npc_key_name: String = "", custom_id: String = "") -> void:
	_ensure_dialogue_box()
	if _dialogue_box == null:
		push_error("DialogueManager: dialogue_box belum didaftarkan!")
		return
	_current_dialog_id = custom_id if not custom_id.is_empty() else ("custom" if npc_key_name.is_empty() else npc_key_name)
	_current_npc_key = _detect_npc_from_id(_current_dialog_id)
	if _current_npc_key.is_empty():
		_current_npc_key = _detect_npc_from_id(npc_key_name)
	_current_data = npc_data
	_is_active = true
	dialogue_started.emit()
	_show_node("start")

## Tampilkan node dialog berdasarkan id.
func _show_node(node_id: String) -> void:
	if node_id == "end" or node_id.is_empty():
		_end_dialogue()
		return

	_current_node = {}
	for node in _current_data:
		if str(node.get("id", "")) == node_id:
			_current_node = node
			break

	if _current_node.is_empty():
		_end_dialogue()
		return

	# Normalisasi struktur choices / pilihan
	if not _current_node.has("choices") and _current_node.has("pilihan"):
		_current_node["choices"] = _current_node["pilihan"]

	# Bersihkan lakuan panggung dalam kurung pada teks utama jika ada
	if _current_node.has("text"):
		_current_node["text"] = _clean_stage_directions(str(_current_node["text"]))
	if _current_node.has("teks"):
		_current_node["teks"] = _clean_stage_directions(str(_current_node["teks"]))

	# Kirim data ke DialogueBox untuk ditampilkan
	if _dialogue_box and _dialogue_box.has_method("show_node"):
		_dialogue_box.show_node(_current_node)

func _clean_stage_directions(raw: String) -> String:
	var regex := RegEx.new()
	regex.compile("\\s*\\([a-zA-Z\\s—–,\\.]{3,80}\\)\\s*")
	return regex.sub(raw, " ", true).strip_edges()

## Dipanggil saat pemain mengetuk layar / memilih opsi.
func advance(choice_index: int = -1) -> void:
	if not _is_active:
		return

	# Proses efek dari node saat ini jika ada
	_apply_effects(_current_node)

	var choices: Array = _current_node.get("choices", [])
	if choices.is_empty():
		choices = _current_node.get("pilihan", [])

	if choice_index >= 0 and choice_index < choices.size():
		var chosen: Dictionary = choices[choice_index]
		last_choice_selected = chosen
		_apply_effects(chosen)
		_apply_choice_effects(chosen)
		var next_id: String = str(chosen.get("next", "end"))
		if next_id.is_empty() or next_id == "end":
			_end_dialogue()
		else:
			_show_node(next_id)
		return

	# Tanpa pilihan: lanjut ke node berikutnya
	if choices.is_empty():
		var next_id: String = str(_current_node.get("next", "end"))
		if next_id.is_empty() or next_id == "end":
			_end_dialogue()
		else:
			_show_node(next_id)

func _apply_choice_effects(choice: Dictionary) -> void:
	var delta_meter: float = float(choice.get("delta_meter", 0.0))
	var delta_sikap: int = int(choice.get("delta_sikap", 0))
	var tipe: String = str(choice.get("tipe", "")).to_upper()

	# 1. Update Meter Bencana di GameState
	if delta_meter != 0.0 and GameState.has_method("ubah_meter"):
		GameState.ubah_meter(delta_meter)

	# 2. Update Sikap NPC di GameState
	if _current_npc_key != "" and GameState.has_method("set_sikap"):
		if delta_sikap != 0 or tipe == "C":
			var cur_sikap: int = GameState.npc_sikap.get(_current_npc_key, 0)
			if tipe == "C":
				GameState.set_sikap(_current_npc_key, -1) # Menolak langsung
			else:
				GameState.set_sikap(_current_npc_key, clampi(cur_sikap + delta_sikap, -1, 2))

	# 3. Pilihan C memicu Sampah Balasan
	if tipe == "C" or delta_meter >= 5.0:
		sampah_balasan.emit(_current_npc_key)

	# 4. Simpan ke EmpatiManager jika aktif
	var em = get_node_or_null("/root/EmpatiManager")
	if em and em.has_method("catat_pilihan"):
		em.catat_pilihan(_current_npc_key, tipe, delta_meter, delta_sikap)

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
	if effect.has("quest"):
		var quest_data: Dictionary = effect["quest"]
		var quest_id: String = quest_data.get("id", "")
		var description: String = quest_data.get("description", "")
		var target: int = quest_data.get("target", 1)
		if not quest_id.is_empty():
			QuestManager.trigger_npc_quest(quest_id, description, target)

func _end_dialogue() -> void:
	_is_active = false
	var finished_id := _current_dialog_id
	_current_data = []
	_current_node = {}

	if is_instance_valid(_dialogue_box) and _dialogue_box.has_method("hide_box"):
		_dialogue_box.hide_box()

	dialogue_finished.emit()
	dialog_selesai.emit(finished_id)

func is_active() -> bool:
	return _is_active

# ─── Helper Internal ──────────────────────────────────────────────────────────

func _detect_npc_from_id(id_dialog: String) -> String:
	var lower := id_dialog.to_lower()
	if "jali" in lower:
		return "jali"
	elif "rina" in lower:
		return "rina"
	elif "darwis" in lower:
		return "darwis"
	elif "ucok" in lower:
		return "ucok"
	elif "datuk" in lower:
		return "datuk"
	elif "warung" in lower or "ibu" in lower:
		return "orangtua"
	return ""
