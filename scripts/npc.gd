## NPC Script
# NPC generik yang memulai dialog saat pemain berinteraksi.
# Dialog dimuat dari JSON sesuai level dan npc_key atau dialog_id khusus.
extends CharacterBody2D
class_name NPC

signal talked(npc_key: String)

# ─── Export ───────────────────────────────────────────────────────────────────
@export var npc_key: String = "npc_pedagang"   # Kunci di file JSON level
@export var level_id: int = 3                  # Level tempat NPC ini berada
@export var dialog_id: String = ""             # ID file khusus di data/dialog/

# ─── Node ─────────────────────────────────────────────────────────────────────
@onready var sprite: CanvasItem = get_node_or_null("AnimatedSprite2D") as CanvasItem
@onready var exclaim: Label = get_node_or_null("ExclaimLabel") as Label

# ─── State ────────────────────────────────────────────────────────────────────
var _dialogue_data: Array = []
var _has_talked: bool = false
var _last_talked_step: String = ""
var _in_dialogue: bool = false

func _ready() -> void:
	if exclaim:
		exclaim.hide()
	_load_dialogue()
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)

func is_interactable_now() -> bool:
	var step := str(GameState.choices.get("hulu_story_step", ""))
	var current_step_key := step if not step.is_empty() else "_initial"
	if _last_talked_step == current_step_key:
		return false

	var talked_hulu: Array = GameState.zone_progress.get("hulu", {}).get("talked_keys", [])
	var talked_desa: Array = GameState.zone_progress.get("desa", {}).get("talked_keys", [])
	var talked_kota: Array = GameState.zone_progress.get("kota", {}).get("talked_keys", [])
	var talked_hilir: Array = GameState.zone_progress.get("hilir", {}).get("talked_keys", [])

	match npc_key:
		"npc_ibu_mc":
			if step.is_empty():
				return "npc_ibu_mc" not in talked_hulu
			if step == "butuh_pesan_kasur":
				return true
			if step == "pesan_gorengan":
				return true
			if step == "antar_gorengan":
				return true
			return false

		"npc_pak_hendra":
			if step.is_empty():
				return "npc_pak_hendra" not in talked_hulu
			return false

		"npc_datuk":
			return step == "cari_suara_jembatan"

		"npc_penjaga_hutan":
			if step == "tanam_pohon_hulu":
				return true
			if step == "menanam_pohon_hulu" and GameState.zone_stat("hulu", "trees") >= 5:
				return not bool(GameState.choices.get("penjaga_hutan_selesai", false))
			return false

		"npc_petani_1": # Pak Darwis
			if step == "ke_toko_jaya":
				return not bool(GameState.choices.get("darwis_done", false))
			return false

		"npc_pemilik_toko":
			# Di Toko Jaya urusan utama adalah adegan bersama Pak Darwis
			return false

		"npc_ibu_desa": # Kak Rina
			if step == "ke_warung_rina":
				return not bool(GameState.choices.get("rina_done", false))
			if step == "serahkan_jeriken_rina":
				return not bool(GameState.choices.get("h5_rina_done", false))
			return false

		"npc_pemuka_desa":
			if step == "cari_solusi_jelantah":
				return not bool(GameState.choices.get("has_jeriken_and_info", false))
			return false

		"npc_pedagang": # Bang Jali
			if step == "kota_gang_sempit":
				return not bool(GameState.choices.get("jali_done", false))
			if step == "serahkan_gerobak_jali":
				return not bool(GameState.choices.get("h3_jali_done", false))
			return false

		"npc_tokoh_masyarakat": # Pak RT
			if step == "cari_solusi_rt":
				return not bool(GameState.choices.get("has_rt_cart_approval", false))
			return false

		"npc_ibu_rumah":
			if step in ["periksa_saluran_kota", "pintu_air_dan_b3"]:
				return "npc_ibu_rumah" not in talked_kota
			return false

		"npc_anak_sekolah": # Budi
			if step in ["tanya_budi", "pintu_air_dan_b3", "ke_hilir_muara"]:
				return "npc_anak_sekolah" not in talked_kota
			return false

		"npc_penjaga_sungai":
			if step in ["pos_penjaga_muara", "pilah_sampah_muara"]:
				return "npc_penjaga_sungai" not in talked_hilir
			return false

		"npc_nelayan":
			if step == "temui_pak_nelayan":
				return "npc_nelayan" not in talked_hilir
			if step == "tanam_mangrove_muara" and GameState.zone_stat("hilir", "mangroves") >= 8:
				return not bool(GameState.choices.get("nelayan_selesai", false))
			return false

	return true

func _get_default_dialog_id() -> String:
	var step := str(GameState.choices.get("hulu_story_step", ""))
	match npc_key:
		"npc_ibu_mc":
			if step == "butuh_pesan_kasur":
				return "h1_warung_kasur"
			if step == "pesan_gorengan":
				return "h2_warung_gorengan"
			if step == "antar_gorengan":
				return "h2_warung_gorengan_selesai"
			return "h1_warung"
		"npc_pak_hendra":
			return "h1_warung"
		"npc_datuk":
			if bool(GameState.choices.get("is_rewound", false)):
				return "h1_datuk_dejavu"
			return "h1_datuk"
		"npc_penjaga_hutan":
			if GameState.zone_stat("hulu", "trees") >= 5:
				return "h1_penjaga_hutan_selesai"
			return "h1_penjaga_hutan"
		"npc_petani_1":
			return "h1_toko_jaya"
		"npc_pemilik_toko":
			return "h1_toko_jaya"
		"npc_ibu_desa":
			if bool(GameState.choices.get("has_jeriken_and_info", false)):
				return "h5_rina"
			return "h4_rina"
		"npc_pemuka_desa":
			return "h2_pemuka_desa"
		"npc_pedagang":
			if bool(GameState.choices.get("has_rt_cart_approval", false)):
				return "h3_jali"
			return "h2_jali"
		"npc_ibu_rumah":
			return "h3_ibu_rumah"
		"npc_anak_sekolah":
			return "h3_budi"
		"npc_tokoh_masyarakat":
			return "h3_pak_rt"
		"npc_nelayan":
			if GameState.zone_stat("hilir", "mangroves") >= 8:
				return "h7_nelayan_selesai"
			return "h7_nelayan"
		"npc_penjaga_sungai":
			return "h7_penjaga_sungai"
	return ""

func _load_dialogue() -> void:
	# 1. Cek dialog_id khusus atau default dari data/dialog/
	var target_id := dialog_id
	if target_id.is_empty():
		target_id = _get_default_dialog_id()

	if not target_id.is_empty():
		var path := "res://data/dialog/%s.json" % target_id
		if FileAccess.file_exists(path):
			var file := FileAccess.open(path, FileAccess.READ)
			if file:
				var json := JSON.new()
				if json.parse(file.get_as_text()) == OK:
					var data = json.get_data()
					if data is Array:
						_dialogue_data = data
						return
					elif data is Dictionary and data.has("dialog"):
						_dialogue_data = data["dialog"]
						return

	# 2. Muat dari file level JSON biasa
	var all_dialogues: Dictionary = DialogueManager.load_dialogue_file(level_id)
	if all_dialogues.has(npc_key):
		_dialogue_data = all_dialogues[npc_key]

func get_action_label() -> String:
	if not is_interactable_now():
		return ""
	_load_dialogue()
	if _dialogue_data.is_empty():
		return ""
	return "Bicara"

func has_talked() -> bool:
	return _has_talked

func set_dialog_id(new_id: String) -> void:
	dialog_id = new_id
	_has_talked = false
	_load_dialogue()

func interact() -> void:
	if not is_interactable_now():
		return
	_load_dialogue()
	if _dialogue_data.is_empty():
		return
	_in_dialogue = true
	var target_id := dialog_id
	if target_id.is_empty():
		target_id = _get_default_dialog_id()
	DialogueManager.start_dialogue(_dialogue_data, npc_key, target_id)

func show_exclaim(visible_state: bool) -> void:
	if exclaim:
		exclaim.visible = visible_state and is_interactable_now()

func _on_dialogue_finished() -> void:
	if not _in_dialogue:
		return
	_in_dialogue = false
	_has_talked = true
	var step := str(GameState.choices.get("hulu_story_step", ""))
	_last_talked_step = step if not step.is_empty() else "_initial"
	if exclaim:
		exclaim.hide()
	talked.emit(npc_key)
