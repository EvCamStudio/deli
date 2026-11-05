## Panel Debug Sistem Inti (Orang 1 - Ridwan)
# Menggunakan tema bawaan project (citampi_theme.tres) tanpa mengubah style font bawaan.
# Shortcut F1-F4 & Panel UI interaktif untuk menyetel Meter Bencana,
# sikap 3 NPC (Jali, Rina, Darwis), uang, utang, hari/waktu,
# menguji 3 Ujian Hujan, serta menguji keempat Ending (A, B, C, D) dengan cepat.
extends CanvasLayer
class_name SystemDebugPanel

var _overlay: ColorRect
var _panel: PanelContainer
var _status_label: Label
var _toggle_hint_btn: Button

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_refresh_status()

	GameState.meter_changed.connect(func(_v): _refresh_status())
	GameState.sikap_changed.connect(func(_n, _v): _refresh_status())
	GameState.hari_changed.connect(func(_h): _refresh_status())
	GameState.waktu_changed.connect(func(_w): _refresh_status())
	GameState.rupiah_changed.connect(func(_u): _refresh_status())
	GameState.utang_changed.connect(func(_u): _refresh_status())
	GameState.energy_changed.connect(func(_e): _refresh_status())

func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key_event := event as InputEventKey
	match key_event.keycode:
		KEY_F1:
			_set_open(not _panel.visible)
			get_viewport().set_input_as_handled()
		KEY_F2:
			_set_open(true)
			_cycle_all_npc_sikap()
			get_viewport().set_input_as_handled()
		KEY_F3:
			_set_open(true)
			GameState.tambah_uang(250000)
			GameState.ubah_meter(-15.0)
			GameState.show_toast("Debug F3: Uang +Rp250rb, Meter -15%", true)
			_refresh_status()
			get_viewport().set_input_as_handled()
		KEY_F4:
			_set_open(true)
			if GameState.hari < 7:
				GameState.hari += 1
			else:
				GameState.hari = 1
			GameState.show_toast("Debug F4: Pindah ke Hari %d" % GameState.hari, true)
			_refresh_status()
			get_viewport().set_input_as_handled()

func _set_open(open: bool) -> void:
	_panel.visible = open
	_overlay.visible = open
	_refresh_status()

func _cycle_all_npc_sikap() -> void:
	var peduli: int = GameState.get_jumlah_npc_peduli()
	if peduli == 0:
		GameState.set_sikap("jali", GameState.SIKAP_PEDULI)
		GameState.set_sikap("rina", GameState.SIKAP_ACUH)
		GameState.set_sikap("darwis", GameState.SIKAP_ACUH)
	elif peduli == 1:
		GameState.set_sikap("jali", GameState.SIKAP_PEDULI)
		GameState.set_sikap("rina", GameState.SIKAP_PEDULI)
		GameState.set_sikap("darwis", GameState.SIKAP_ACUH)
	elif peduli == 2:
		GameState.set_sikap("jali", GameState.SIKAP_PEDULI)
		GameState.set_sikap("rina", GameState.SIKAP_PEDULI)
		GameState.set_sikap("darwis", GameState.SIKAP_PEDULI)
	else:
		GameState.set_sikap("jali", GameState.SIKAP_ACUH)
		GameState.set_sikap("rina", GameState.SIKAP_ACUH)
		GameState.set_sikap("darwis", GameState.SIKAP_ACUH)
	GameState.show_toast("Debug F2: Warga Peduli = %d/3" % GameState.get_jumlah_npc_peduli(), true)
	_refresh_status()

func _build_ui() -> void:
	# Latar redup saat panel debug dibuka
	_overlay = ColorRect.new()
	_overlay.visible = false
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.09, 0.12, 0.10, 0.55)
	add_child(_overlay)

	# Tombol kecil di pojok kiri bawah
	_toggle_hint_btn = Button.new()
	_toggle_hint_btn.add_theme_font_size_override("font_size", 10)
	_toggle_hint_btn.text = "Debug [F1]"
	_toggle_hint_btn.anchors_preset = Control.PRESET_BOTTOM_LEFT
	_toggle_hint_btn.anchor_top = 1.0
	_toggle_hint_btn.anchor_bottom = 1.0
	_toggle_hint_btn.offset_left = 8
	_toggle_hint_btn.offset_top = -28
	_toggle_hint_btn.offset_right = 82
	_toggle_hint_btn.offset_bottom = -6
	_toggle_hint_btn.pressed.connect(func(): _set_open(not _panel.visible))
	add_child(_toggle_hint_btn)

	# Panel Utama Debug — menggunakan style bawaan citampi_theme.tres (panel kertas)
	# Ukuran pas di dalam layar 640x360 (lebar 520, tinggi 256, tepat di tengah)
	_panel = PanelContainer.new()
	_panel.visible = false
	_panel.anchors_preset = Control.PRESET_CENTER
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -260
	_panel.offset_top = -126
	_panel.offset_right = 260
	_panel.offset_bottom = 130
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	_panel.add_child(vbox)

	# Header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	vbox.add_child(header)

	var title := Label.new()
	title.add_theme_font_size_override("font_size", 12)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.text = "PANEL DEBUG SISTEM INTI  (F1: Buka/Tutup · F2: NPC · F3: Uang/Meter · F4: Hari)"
	header.add_child(title)

	var close_btn := _make_btn("Tutup [F1]", func(): _set_open(false))
	header.add_child(close_btn)

	# Status ringkas
	_status_label = Label.new()
	_status_label.add_theme_font_size_override("font_size", 10)
	_status_label.add_theme_color_override("font_color", Color(0.18, 0.38, 0.22))
	vbox.add_child(_status_label)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	# Baris 1: Meter Bencana
	var row_meter := HBoxContainer.new()
	row_meter.add_theme_constant_override("separation", 4)
	vbox.add_child(row_meter)
	row_meter.add_child(_make_row_label("Meter:"))
	row_meter.add_child(_make_btn("-10", func(): GameState.ubah_meter(-10)))
	row_meter.add_child(_make_btn("+10", func(): GameState.ubah_meter(10)))
	row_meter.add_child(_make_btn("15% (A)", func(): GameState.meter_bencana = 15))
	row_meter.add_child(_make_btn("35% (B)", func(): GameState.meter_bencana = 35))
	row_meter.add_child(_make_btn("50% (C)", func(): GameState.meter_bencana = 50))
	row_meter.add_child(_make_btn("75% (D)", func(): GameState.meter_bencana = 75))

	# Baris 2: Sikap 3 NPC
	var row_npc := HBoxContainer.new()
	row_npc.add_theme_constant_override("separation", 4)
	vbox.add_child(row_npc)
	row_npc.add_child(_make_row_label("Sikap NPC:"))
	row_npc.add_child(_make_btn("Jali", func(): _step_npc("jali")))
	row_npc.add_child(_make_btn("Rina", func(): _step_npc("rina")))
	row_npc.add_child(_make_btn("Darwis", func(): _step_npc("darwis")))
	row_npc.add_child(_make_btn("Semua Peduli", func():
		for k in ["jali", "rina", "darwis"]:
			GameState.set_sikap(k, GameState.SIKAP_PEDULI)
	))
	row_npc.add_child(_make_btn("Reset Acuh", func():
		for k in ["jali", "rina", "darwis"]:
			GameState._npc_peduli_bonus[k] = false
			GameState.set_sikap(k, GameState.SIKAP_ACUH)
	))

	# Baris 3: Uang & Utang
	var row_money := HBoxContainer.new()
	row_money.add_theme_constant_override("separation", 4)
	vbox.add_child(row_money)
	row_money.add_child(_make_row_label("Uang/Utang:"))
	row_money.add_child(_make_btn("+100rb", func(): GameState.tambah_uang(100000)))
	row_money.add_child(_make_btn("+500rb", func(): GameState.tambah_uang(500000)))
	row_money.add_child(_make_btn("Lunas 100%", func(): GameState.utang = 0))
	row_money.add_child(_make_btn("Lunas 70%", func(): GameState.utang = 150000))
	row_money.add_child(_make_btn("Menu Utang H7", func():
		_set_open(false)
		GameState.buka_menu_bayar_utang()
	))

	# Baris 4: Hari, Waktu, & Tidur
	var row_day := HBoxContainer.new()
	row_day.add_theme_constant_override("separation", 4)
	vbox.add_child(row_day)
	row_day.add_child(_make_row_label("Siklus Hari:"))
	row_day.add_child(_make_btn("Hari -1", func(): GameState.hari = maxi(1, GameState.hari - 1)))
	row_day.add_child(_make_btn("Hari +1", func(): GameState.hari = mini(7, GameState.hari + 1)))
	row_day.add_child(_make_btn("Hari 7", func(): GameState.hari = 7))
	row_day.add_child(_make_btn("Ganti Waktu", func(): GameState.majukan_waktu()))
	row_day.add_child(_make_btn("Tidur()", func(): GameState.tidur()))

	# Baris 5: Uji 3 Ujian Hujan & Save/Load
	var row_rain := HBoxContainer.new()
	row_rain.add_theme_constant_override("separation", 4)
	vbox.add_child(row_rain)
	row_rain.add_child(_make_row_label("Ujian & Save:"))
	row_rain.add_child(_make_btn("Ujian 1 (H3)", func(): GameState.jalankan_ujian_hujan(1)))
	row_rain.add_child(_make_btn("Ujian 2 (H5)", func(): GameState.jalankan_ujian_hujan(2)))
	row_rain.add_child(_make_btn("Ujian 3 (H7)", func(): GameState.jalankan_ujian_hujan(3)))
	row_rain.add_child(_make_btn("Save", func():
		GameState.save_game()
		GameState.show_toast("Game disimpan!", true)
	))
	row_rain.add_child(_make_btn("Load", func():
		if GameState.load_game():
			GameState.show_toast("Game dimuat!", true)
	))

	# Baris 6: Uji Cepat 4 Ending (A, B, C, D)
	var row_end := HBoxContainer.new()
	row_end.add_theme_constant_override("separation", 4)
	vbox.add_child(row_end)
	row_end.add_child(_make_row_label("Uji Ending:"))
	row_end.add_child(_make_btn("Ending A", func(): _trigger_preset_ending("A")))
	row_end.add_child(_make_btn("Ending B", func(): _trigger_preset_ending("B")))
	row_end.add_child(_make_btn("Ending C", func(): _trigger_preset_ending("C")))
	row_end.add_child(_make_btn("Ending D", func(): _trigger_preset_ending("D")))
	row_end.add_child(_make_btn("Cek Ending Ini", func():
		_set_open(false)
		GameState.tentukan_ending(true)
	))

func _step_npc(npc_key: String) -> void:
	var cur: int = GameState.get_sikap(npc_key)
	var next_val: int = cur + 1
	if next_val > GameState.SIKAP_PEDULI:
		next_val = GameState.SIKAP_MENOLAK
	GameState.set_sikap(npc_key, next_val)
	_refresh_status()

func _trigger_preset_ending(kode: String) -> void:
	GameState.hari = 7
	GameState.waktu = "malam"
	match kode:
		"A":
			for k in ["jali", "rina", "darwis"]:
				GameState.set_sikap(k, GameState.SIKAP_PEDULI)
			GameState.meter_bencana = 15.0
			GameState.utang = 0
		"B":
			GameState.set_sikap("jali", GameState.SIKAP_PEDULI)
			GameState.set_sikap("rina", GameState.SIKAP_PEDULI)
			GameState.set_sikap("darwis", GameState.SIKAP_RAGU)
			GameState.meter_bencana = 32.0
			GameState.utang = 100000
		"C":
			GameState.set_sikap("jali", GameState.SIKAP_PEDULI)
			GameState.set_sikap("rina", GameState.SIKAP_ACUH)
			GameState.set_sikap("darwis", GameState.SIKAP_ACUH)
			GameState.meter_bencana = 50.0
			GameState.utang = 350000
		"D":
			for k in ["jali", "rina", "darwis"]:
				GameState.set_sikap(k, GameState.SIKAP_MENOLAK)
			GameState.meter_bencana = 75.0
			GameState.utang = 500000

	_set_open(false)
	GameState.tentukan_ending(true)

func _nama_sikap_pendek(nilai: int) -> String:
	match nilai:
		GameState.SIKAP_MENOLAK: return "Menolak"
		GameState.SIKAP_ACUH: return "Acuh"
		GameState.SIKAP_RAGU: return "Ragu"
		GameState.SIKAP_PEDULI: return "Peduli"
		_: return "Acuh"

func _refresh_status() -> void:
	if not _status_label:
		return
	var lunas_pct: int = int(round(GameState.get_persen_utang_lunas() * 100.0))
	var prediksi: String = GameState.hitung_kode_ending()
	_status_label.text = "Hari %d (%s) · Meter %d%% · Jali:%s Rina:%s Darwis:%s · Utang Lunas %d%% -> Prediksi: Ending %s" % [
		GameState.hari,
		GameState.waktu.capitalize(),
		int(round(GameState.meter_bencana)),
		_nama_sikap_pendek(GameState.get_sikap("jali")),
		_nama_sikap_pendek(GameState.get_sikap("rina")),
		_nama_sikap_pendek(GameState.get_sikap("darwis")),
		lunas_pct,
		prediksi,
	]

func _make_row_label(text: String) -> Label:
	var lbl := Label.new()
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.custom_minimum_size = Vector2(74, 0)
	lbl.text = text
	return lbl

func _make_btn(text: String, callback: Callable) -> Button:
	var btn := Button.new()
	btn.add_theme_font_size_override("font_size", 10)
	btn.custom_minimum_size = Vector2(0, 24)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.text = text
	btn.pressed.connect(callback)
	return btn
