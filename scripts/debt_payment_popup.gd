## Menu Bayar Utang Hari 7 Sore (Orang 1: Sistem Inti - Ridwan)
# Menggunakan tema bawaan project (citampi_theme.tres) tanpa mengubah style font bawaan.
# Menampilkan 3 pilihan sesuai spesifikasi:
# 1. "Ini, kubayar semua." (aktif jika uang cukup -> utang lunas 100%)
# 2. "Kubayar sebagian dulu." (dengan HSlider untuk memilih jumlah pembayaran)
# 3. "Beri aku waktu." (utang tidak berkurang)
extends CanvasLayer
class_name DebtPaymentPopup

var _slider: HSlider
var _partial_btn: Button

func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func _build_ui() -> void:
	# Latar redup
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.09, 0.12, 0.10, 0.60)
	add_child(dim)

	# Panel tengah menggunakan style bawaan citampi_theme.tres
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(380, 210)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	# Judul
	var title := Label.new()
	title.add_theme_font_size_override("font_size", 13)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text = "HARI 7 SORE · PEMBAYARAN UTANG WARUNG"
	vbox.add_child(title)

	# Dialog singkat Bang Ucok
	var quote := Label.new()
	quote.add_theme_font_size_override("font_size", 11)
	quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quote.text = "Bang Ucok: \"Selamat sore, Dek. Hari ini jadwal pembayaran sisa utang.\""
	vbox.add_child(quote)

	# Info Uang & Sisa Utang
	var info := Label.new()
	info.add_theme_font_size_override("font_size", 11)
	info.add_theme_color_override("font_color", Color(0.18, 0.38, 0.22))
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.text = "Uang Kamu: Rp %s   |   Sisa Utang: Rp %s" % [
		_format_rupiah(GameState.uang),
		_format_rupiah(GameState.utang)
	]
	vbox.add_child(info)

	# Pilihan 1: Bayar Semua (jika uang cukup)
	var btn_all := Button.new()
	btn_all.add_theme_font_size_override("font_size", 11)
	var bisa_lunas: bool = GameState.utang > 0 and GameState.uang >= GameState.utang
	btn_all.disabled = not bisa_lunas
	if GameState.utang <= 0:
		btn_all.text = "1. \"Ini, kubayar semua.\" (Utang sudah lunas!)"
	elif bisa_lunas:
		btn_all.text = "1. \"Ini, kubayar semua.\" (Bayar Rp %s - Lunas 100%%)" % _format_rupiah(GameState.utang)
	else:
		btn_all.text = "1. \"Ini, kubayar semua.\" (Uang belum cukup untuk lunas)"
	btn_all.pressed.connect(_on_pay_all)
	vbox.add_child(btn_all)

	# Pilihan 2: Bayar Sebagian dengan Slider
	var partial_box := VBoxContainer.new()
	partial_box.add_theme_constant_override("separation", 4)
	vbox.add_child(partial_box)

	var max_partial: int = mini(GameState.uang, GameState.utang)
	_slider = HSlider.new()
	_slider.min_value = 0
	_slider.max_value = maxi(0, max_partial)
	_slider.step = 1000 if max_partial >= 1000 else 100
	_slider.value = int(max_partial * 0.5)
	_slider.editable = max_partial > 0
	_slider.value_changed.connect(_on_slider_changed)
	partial_box.add_child(_slider)

	_partial_btn = Button.new()
	_partial_btn.add_theme_font_size_override("font_size", 11)
	_partial_btn.disabled = max_partial <= 0
	_partial_btn.pressed.connect(_on_pay_partial)
	partial_box.add_child(_partial_btn)
	_update_partial_button_text(int(_slider.value))

	# Pilihan 3: Minta Waktu
	var btn_wait := Button.new()
	btn_wait.add_theme_font_size_override("font_size", 11)
	btn_wait.text = "3. \"Beri aku waktu.\" (Utang tidak berkurang)"
	btn_wait.pressed.connect(_on_ask_time)
	vbox.add_child(btn_wait)

func _on_slider_changed(val: float) -> void:
	_update_partial_button_text(int(val))

func _update_partial_button_text(amount: int) -> void:
	if not _partial_btn:
		return
	_partial_btn.disabled = amount <= 0
	_partial_btn.text = "2. \"Kubayar sebagian dulu.\" (Bayar Rp %s)" % _format_rupiah(amount)

func _on_pay_all() -> void:
	var bayar: int = GameState.utang
	if GameState.bayar_utang(bayar):
		GameState.show_toast("Bang Ucok: \"Lunas. Warung ini jalan terus, ya.\"", true)
		GameState.utang_menu_selesai.emit("semua", bayar)
		GameState.save_game()
	queue_free()

func _on_pay_partial() -> void:
	var bayar: int = int(_slider.value)
	if bayar > 0 and GameState.bayar_utang(bayar):
		GameState.show_toast("Bang Ucok: \"Boleh. Sisanya kutunggu, jangan terlalu lama.\"", true)
		GameState.utang_menu_selesai.emit("sebagian", bayar)
		GameState.save_game()
	queue_free()

func _on_ask_time() -> void:
	GameState.show_toast("Bang Ucok: \"Baik, tapi lain kali jangan begini.\"", false)
	GameState.utang_menu_selesai.emit("waktu", 0)
	queue_free()

func _format_rupiah(amount: int) -> String:
	var s: String = str(maxi(0, amount))
	var res: String = ""
	for i in range(s.length()):
		if i > 0 and (s.length() - i) % 3 == 0:
			res += "."
		res += s[i]
	return res
