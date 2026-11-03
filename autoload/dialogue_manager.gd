## DialogueManager Autoload (Orang 2: Dialog & NPC)
## Mengelola sistem dialog lomba Deli Rewind:
## Memuat JSON dari res://data/dialog/*.json, menampilkan via portrait dialogue box,
## menangani pilihan A/B/C, kalkulasi Meter Bencana & Sikap NPC, serta sinyal sampah balasan.
extends Node

# ─── Sinyal (Kontrak Lomba Orang 2) ───────────────────────────────────────────
signal dialogue_started
signal dialogue_finished
signal dialog_selesai(id_dialog: String)
signal sampah_balasan(npc: String)

# ─── State Internal ───────────────────────────────────────────────────────────
var _dialogue_box: CanvasLayer = null
var _current_data: Array = []
var _current_node: Dictionary = {}
var _current_dialog_id: String = ""
var _current_npc_key: String = ""
var _is_active: bool = false

func _ready() -> void:
	# Hubungkan sinyal ke GameState jika ada
	pass

# ─── Setup Dialogue Box ───────────────────────────────────────────────────────
func register_dialogue_box(box: CanvasLayer) -> void:
	_dialogue_box = box

func _ensure_dialogue_box() -> bool:
	if is_instance_valid(_dialogue_box):
		return true
	# Cari di scene tree jika sudah ada
	var existing = get_tree().root.find_child("DialogueBox", true, false)
	if existing and existing is CanvasLayer:
		_dialogue_box = existing
		return true
	# Jika belum ada, instantiate portrait_dialogue.tscn otomatis
	var scene_res = load("res://scenes/ui/portrait_dialogue.tscn")
	if scene_res:
		var instance = scene_res.instantiate() as CanvasLayer
		get_tree().root.add_child(instance)
		_dialogue_box = instance
		return true
	return false

# ─── Fungsi Utama: mulai(id_dialog) ───────────────────────────────────────────

## Kontrak Lomba: Memulai dialog berdasarkan ID (misal: "h1_warung", "h2_jali", "ujian1", dst).
func mulai(id_dialog: String) -> void:
	_ensure_dialogue_box()
	_current_dialog_id = id_dialog
	_current_npc_key = _detect_npc_from_id(id_dialog)

	# 1. Cari file JSON di res://data/dialog/ atau res://data/dialogues/
	var path: String = "res://data/dialog/%s.json" % id_dialog
	if not FileAccess.file_exists(path):
		path = "res://data/dialogues/%s.json" % id_dialog
	if not FileAccess.file_exists(path):
		push_error("DialogueManager: file dialog tidak ditemukan: %s" % path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("DialogueManager: gagal membuka file: %s" % path)
		return
	var text: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(text) != OK:
		push_error("DialogueManager: gagal parse JSON: %s (error: %s)" % [path, json.get_error_message()])
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

	# Cek start node khusus untuk ujian hujan
	var start_node_id: String = "start"
	if id_dialog == "ujian1":
		start_node_id = _get_ujian1_start_node()
	elif id_dialog == "ujian2":
		start_node_id = _get_ujian2_start_node()

	_show_node(start_node_id)

## Kompatibilitas dengan kode lama: start_dialogue(array)
func start_dialogue(npc_data: Array) -> void:
	_ensure_dialogue_box()
	_current_dialog_id = "custom"
	_current_data = npc_data
	_is_active = true
	dialogue_started.emit()
	_show_node("start")

# ─── Menampilkan Node Dialog ──────────────────────────────────────────────────

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

	# Kirim node ke dialogue box UI
	if is_instance_valid(_dialogue_box) and _dialogue_box.has_method("show_node"):
		_dialogue_box.show_node(_current_node)

# ─── Navigasi & Pilihan Jawaban (Advance) ──────────────────────────────────────

func advance(choice_index: int = -1) -> void:
	if not _is_active:
		return

	# Cek apakah node saat ini punya pilihan
	var pilihan: Array = _current_node.get("pilihan", [])
	if pilihan.is_empty():
		pilihan = _current_node.get("choices", [])

	if choice_index >= 0 and choice_index < pilihan.size():
		var chosen: Dictionary = pilihan[choice_index]
		_apply_choice_effects(chosen)
		var next_id: String = str(chosen.get("next", "end"))
		_show_node(next_id)
		return

	# Jika tanpa pilihan (hanya teks narasi biasa)
	if pilihan.is_empty():
		var next_id: String = str(_current_node.get("next", "end"))
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
				GameState.set_sikap(_current_npc_key, clamp(cur_sikap + delta_sikap, -1, 2))

	# 3. Pilihan C memicu Sampah Balasan
	if tipe == "C" or delta_meter >= 5.0:
		sampah_balasan.emit(_current_npc_key)

	# 4. Simpan ke EmpatiManager jika aktif
	if Engine.has_singleton("EmpatiManager") or get_node_or_null("/root/EmpatiManager"):
		var em = get_node_or_null("/root/EmpatiManager")
		if em and em.has_method("catat_pilihan"):
			em.catat_pilihan(_current_npc_key, tipe, delta_meter, delta_sikap)

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
	elif "warung" in lower:
		return "orangtua"
	return ""

## Ujian 1: Meter <= 40 Aman, 41..70 Genangan, > 70 Banjir Lokal
func _get_ujian1_start_node() -> String:
	var meter := GameState.meter_bencana if "meter_bencana" in GameState else (100.0 - GameState.river_health)
	if meter <= 40.0:
		return "aman"
	elif meter <= 70.0:
		return "genangan"
	else:
		return "banjir"

## Ujian 2: Meter <= 35 Aman, 36..65 Genangan Parah, > 65 Banjir
func _get_ujian2_start_node() -> String:
	var meter := GameState.meter_bencana if "meter_bencana" in GameState else (100.0 - GameState.river_health)
	if meter <= 35.0:
		return "aman"
	elif meter <= 65.0:
		return "genangan"
	else:
		return "banjir"
