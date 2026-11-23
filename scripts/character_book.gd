## CharacterBook — Buku catatan karakter bergaya jurnal sesuai Deli_Rewind_Jurnal_Karakter_All_NPC.docx.
## Menampilkan 14 NPC Utama (11 Statis/Pendukung dan 3 Target Edukasi Dinamis 3-Fase).
extends CanvasLayer
class_name CharacterBook

signal opened
signal closed

@onready var overlay: ColorRect = $Overlay
@onready var book_root: Control = $BookRoot

# Left Page Nodes
@onready var left_frame: Control = $BookRoot/LeftFrame
@onready var left_photo: TextureRect = $BookRoot/LeftFrame/LeftPhoto
@onready var left_name: Label = $BookRoot/LeftName
@onready var left_status: Label = $BookRoot/LeftStatus
@onready var left_notes: Label = $BookRoot/LeftNotes
@onready var left_note_btn_prev: Button = $BookRoot/LeftNoteBtnPrev
@onready var left_note_indicator: Label = $BookRoot/LeftNoteIndicator
@onready var left_note_btn_next: Button = $BookRoot/LeftNoteBtnNext

# Right Page Nodes
@onready var right_frame: Control = $BookRoot/RightFrame
@onready var right_photo: TextureRect = $BookRoot/RightFrame/RightPhoto
@onready var right_name: Label = $BookRoot/RightName
@onready var right_status: Label = $BookRoot/RightStatus
@onready var right_notes: Label = $BookRoot/RightNotes
@onready var right_note_btn_prev: Button = $BookRoot/RightNoteBtnPrev
@onready var right_note_indicator: Label = $BookRoot/RightNoteIndicator
@onready var right_note_btn_next: Button = $BookRoot/RightNoteBtnNext

# Pagination
@onready var btn_prev: Button = $BookRoot/BtnPrev
@onready var btn_slot1: Button = $BookRoot/BtnSlot1
@onready var btn_slot2: Button = $BookRoot/BtnSlot2
@onready var btn_slot3: Button = $BookRoot/BtnSlot3
@onready var btn_next: Button = $BookRoot/BtnNext
@onready var btn_close: Button = $BookRoot/BtnClose
@onready var page_highlighter: Panel = $BookRoot/PageHighlighter

# Aliases for compatibility
var btn_page1: Button = null
var btn_page2: Button = null
var btn_page3: Button = null

var current_page: int = 1
const MAX_PAGES: int = 7
const SLOTS_COUNT: int = 3

# Sub-pagination per catatan karakter
var left_note_chunks: Array[String] = []
var left_note_index: int = 0
var right_note_chunks: Array[String] = []
var right_note_index: int = 0

const COLOR_STATIS: Color = Color(0.18, 0.44, 0.78, 1.0) # Biru Pendukung Positif
const COLOR_FASE_1: Color = Color(0.50, 0.45, 0.40, 1.0) # Abu-abu Acuh
const COLOR_FASE_2A: Color = Color(0.15, 0.58, 0.22, 1.0) # Hijau Mau Berubah
const COLOR_FASE_2B: Color = Color(0.80, 0.22, 0.20, 1.0) # Merah Tidak Suka

const CHARACTER_PAGES: Array[Dictionary] = [
	# Halaman 1
	{
		"left": {
			"key": "ibu_mc",
			"name": "Bu Mira",
			"portrait_neutral": "res://assets/sprites/portraits/ibu_neutral.png",
			"portrait_happy": "res://assets/sprites/portraits/ibu_happy.png",
			"portrait_sad": "res://assets/sprites/portraits/ibu_sad.png",
			"is_dynamic": false,
			"status": "Penyayang & Ramah",
			"notes": "Ibu yang membesarkanku dan mengelola warung makan sederhana keluarga kami. Sosoknya penyayang, tegar, dan selalu menanamkan nilai-nilai luhur padaku sejak kecil. Meskipun warung kebanggaannya sering hancur direndam banjir lumpur, Mak tidak pernah menyalahkan air sungai apalagi menyerah. Perjuanganku membersihkan kampung ini, sebagian besar adalah untuk melihat senyum Mak kembali tenang berjualan."
		},
		"right": {
			"key": "bapak",
			"name": "Pak Hendra",
			"portrait_neutral": "res://assets/sprites/portraits/pak_hendra_neutral.png",
			"portrait_happy": "res://assets/sprites/portraits/pak_hendra_happy.png",
			"portrait_sad": "res://assets/sprites/portraits/pak_hendra_sad.png",
			"is_dynamic": false,
			"status": "Tenang & Bijaksana",
			"notes": "Bapak adalah pria yang tidak banyak bicara namun selalu tahu cara menenangkan keluarga. Ketika banjir bandang datang dan menghanyutkan sebagian perabotan, Bapak adalah orang pertama yang sigap menyelamatkan kami. Dia sering mengingatkanku bahwa air tidak pernah salah, karena manusialah yang harus sadar menjaga jalannya. Kalau soal memperbaiki perabotan patah bekas banjir, Bapak jagonya."
		}
	},
	# Halaman 2
	{
		"left": {
			"key": "datuk",
			"name": "Datuk Sampan",
			"portrait_neutral": "res://assets/sprites/portraits/datuk_neutral.png",
			"portrait_happy": "res://assets/sprites/portraits/datuk_happy.png",
			"portrait_sad": "res://assets/sprites/portraits/datuk_sad.png",
			"is_dynamic": false,
			"status": "Roh Penjaga Sungai",
			"notes": "Hantu tua, oh ralat... roh penjaga Sungai Deli yang tiba-tiba muncul di jembatan dan hanya bisa dilihat olehku. Selama 70 tahun dia menjaga sungai ini tanpa ada yang menyadarinya. Gaya bicaranya sering bertele-tele dan menyebalkan, tapi dia tahu segalanya tentang isi hati sungai ini. Kalau bukan karena ancaman bencananya, mungkin aku tidak akan repot-repot memungut sampah dari hulu sampai ke laut. Jangan bilang-bilang padanya, tapi kehadirannya cukup membantuku."
		},
		"right": {
			"key": "penjaga_hutan",
			"name": "Penjaga Hutan",
			"portrait_neutral": "res://assets/sprites/portraits/penjaga_hutan_neutral.png",
			"portrait_happy": "res://assets/sprites/portraits/penjaga_hutan_happy.png",
			"portrait_sad": "res://assets/sprites/portraits/penjaga_hutan_sad.png",
			"is_dynamic": false,
			"status": "Peduli Hutan",
			"notes": "Bapak tua yang menjaga hutan di bukit hulu sendirian. Dia terlihat sedih menatap lereng bukit yang gundul akibat penebangan liar. Kata Pak Harun, akar pohon itu seperti spons raksasa. Tanpa akar di hulu, air hujan akan langsung meluncur membawa tanah longsor dan merendam rumah warga. Aku sudah membantunya menanam bibit pohon hutan. Semoga pohon itu cepat besar sebelum hujan badai berikutnya turun."
		}
	},
	# Halaman 3
	{
		"left": {
			"key": "pemilik_toko",
			"name": "Koh Jaya",
			"portrait_neutral": "res://assets/sprites/portraits/pemilik_toko_neutral.png",
			"portrait_happy": "res://assets/sprites/portraits/pemilik_toko_happy.png",
			"portrait_sad": "res://assets/sprites/portraits/pemilik_toko_sad.png",
			"is_dynamic": false,
			"status": "Kooperatif & Ramah",
			"notes": "Koh Jaya, pemilik toko kasur satu-satunya di desa sebelah. Banjir kemarin merendam hampir setengah isi tokonya, jadi dia tahu betul betapa repotnya mengurus barang yang berlumpur. Dari dia jugalah aku tahu kalau pengepul barang bekas di hulu mau membeli busa kasur sintetik yang sudah dicincang."
		},
		"right": {
			"key": "pemuka_desa",
			"name": "Kepala Desa",
			"portrait_neutral": "res://assets/sprites/portraits/pemuka_desa_neutral.png",
			"portrait_happy": "res://assets/sprites/portraits/pemuka_desa_happy.png",
			"portrait_sad": "res://assets/sprites/portraits/pemuka_desa_sad.png",
			"is_dynamic": false,
			"status": "Bijaksana & Peduli",
			"notes": "Tetua di Desa Deli yang sangat memegang teguh petuah Melayu tentang gotong royong: 'berat sama dipikul, ringan sama dijinjing'. Dari bapak inilah aku belajar bahwa masalah sampah tidak bisa dipikul sendirian. Berkat informasi dan jeriken gratis yang diberikannya, aku berhasil menyelamatkan selokan desa dari tumpahan minyak jelantah Kak Rina."
		}
	},
	# Halaman 4
	{
		"left": {
			"key": "pak_rt",
			"name": "Pak RT",
			"portrait_neutral": "res://assets/sprites/portraits/pakrt_neutral.png",
			"portrait_happy": "res://assets/sprites/portraits/pakrt_happy.png",
			"portrait_sad": "res://assets/sprites/portraits/pakrt_sad.png",
			"is_dynamic": false,
			"status": "Solutif & Terbuka",
			"notes": "Pak RT di pemukiman padat pinggiran kota. Pemikirannya sangat terbuka. Dia mengajarkan filosofi bahwa saluran air kota itu ibarat 'urat nadi'; kalau tersumbat, seluruh tubuh kota akan sakit. Pak RT inilah yang memberiku izin dan bahan roda bekas agar pemuda di gang Bang Jali bisa merakit Gerobak Sampah Komunal mereka sendiri."
		},
		"right": {
			"key": "ibu_rumah",
			"name": "Ibu Rumah Tangga",
			"portrait_neutral": "res://assets/sprites/portraits/ibu_rumah_neutral.png",
			"portrait_happy": "res://assets/sprites/portraits/ibu_rumah_happy.png",
			"portrait_sad": "res://assets/sprites/portraits/ibu_rumah_sad.png",
			"is_dynamic": false,
			"status": "Ramah & Khawatir",
			"notes": "Ibu yang rumahnya berada tepat di tepi saluran air besar dekat jembatan kota. Dia sering panik kalau air selokan tertahan oleh tumpukan sampah B3 (Berbahaya dan Beracun) seperti baterai dan pecahan lampu. Berkat petunjuk darinya, aku berhasil menemukan tuas pintu air yang tersembunyi."
		}
	},
	# Halaman 5
	{
		"left": {
			"key": "budi",
			"name": "Budi",
			"portrait_neutral": "res://assets/sprites/portraits/budi_neutral.png",
			"portrait_happy": "res://assets/sprites/portraits/budi_happy.png",
			"portrait_sad": "res://assets/sprites/portraits/budi_sad.png",
			"is_dynamic": false,
			"status": "Ceria & Membantu",
			"notes": "Anak sekolah dasar yang kutemui di pinggir sungai kota. Dia sedang sibuk menghafalkan rumus rima sajak a-b-a-b untuk pelajaran Pantun Melayu Deli. Tanpa petunjuk dari Budi, aku pasti tidak akan tahu cara melengkapi Papan Pantun Tua peninggalan leluhur (dan Datuk Sampan) di hilir muara."
		},
		"right": {
			"key": "penjaga_sungai",
			"name": "Penjaga Sungai",
			"portrait_neutral": "res://assets/sprites/portraits/penjaga_sungai_neutral.png",
			"portrait_happy": "res://assets/sprites/portraits/penjaga_sungai_happy.png",
			"portrait_sad": "res://assets/sprites/portraits/penjaga_sungai_sad.png",
			"is_dynamic": false,
			"status": "Peduli Lingkungan",
			"notes": "Petugas yang berjaga di pesisir muara tempat bertemunya Sungai Deli dan laut lepas. Di sinilah muara akhir semua sampah yang hanyut dari hulu dan kota menumpuk di depan matanya. Aku membantunya memilah tumpukan sampah itu ke dalam karung terpilah agar laut tidak tercekik oleh beban yang dibawanya."
		}
	},
	# Halaman 6
	{
		"left": {
			"key": "nelayan",
			"name": "Pak Nelayan",
			"portrait_neutral": "res://assets/sprites/portraits/nelayan_neutral.png",
			"portrait_happy": "res://assets/sprites/portraits/nelayan_happy.png",
			"portrait_sad": "res://assets/sprites/portraits/nelayan_sad.png",
			"is_dynamic": false,
			"status": "Sabar & Bersahabat",
			"notes": "Nelayan tua yang hidupnya bergantung pada hasil laut. Dia sangat sedih karena hutan mangrove di pesisir pantai kini ompong dan rusak. Padahal akar bakau adalah tempat anak-anak ikan berlindung dan benteng pemecah ombak alami dari abrasi air laut pasang (rob). Bersamanya, aku ikut menanam 5 bibit bakau baru di tepian pantai. Semoga nelayan sepertinya tidak harus merantau jauh dari kampung halaman lagi."
		},
		"right": {
			"key": "darwis",
			"name": "Pak Darwis",
			"portrait_neutral": "res://assets/sprites/portraits/pak_darwis_neutral.png",
			"portrait_happy": "res://assets/sprites/portraits/pak_darwis_happy.png",
			"portrait_sad": "res://assets/sprites/portraits/pak_darwis_sad.png",
			"is_dynamic": true,
			"phases": {
				"fase_1": {
					"status": "Acuh",
					"notes": "Bapak tua ini langganan Toko Jaya. Tadi aku dengar dia mengeluh pinggangnya sakit setelah membuang kasur lamanya ke sungai di belakang rumah. Kalau dibiarkan, kasur itu pasti bakal menyumbat aliran air. Sebaiknya aku tegur dia sebelum jadi kebiasaan buruk."
				},
				"fase_2a": {
					"status": "Mau Berubah",
					"notes": "Syukurlah Pak Darwis mau mendengarkan. Ternyata dia membuang kasur ke sungai karena fisiknya sudah tua dan tidak sanggup menggotongnya jauh-jauh ke TPS. Untungnya, busa kasur itu bisa dipotong kecil-kecil pakai parang untuk dijual ke pengepul daur ulang. Pak Darwis senang karena pinggangnya aman dan malah dapat uang tambahan!"
				},
				"fase_2b": {
					"status": "Tidak Suka",
					"notes": "Ugh... aku terlalu emosi dan malah menceramahinya. Dia tersinggung berat dan pergi begitu saja. Padahal kasur busa sebesar itu tidak akan hancur di air. Kalau dibiarkan hanyut, kasur itu pasti akan menyumbat pilar jembatan di hilir desa. Harusnya tadi aku mendengarkan alasannya dulu dan membantunya mencari jalan keluar."
				}
			}
		}
	},
	# Halaman 7
	{
		"left": {
			"key": "rina",
			"name": "Kak Rina",
			"portrait_neutral": "res://assets/sprites/portraits/kak_rina_neutral.png",
			"portrait_happy": "res://assets/sprites/portraits/kak_rina_happy.png",
			"portrait_sad": "res://assets/sprites/portraits/kak_rina_sad.png",
			"is_dynamic": true,
			"phases": {
				"fase_1": {
					"status": "Acuh",
					"notes": "Pedagang gorengan langganan ibu di simpang jembatan desa. Gorengannya memang enak, tapi aku baru sadar kalau dia selalu membuang minyak bekas gorengannya (jelantah) langsung ke parit selokan yang mengalir ke sungai. Aku harus menghentikannya sebelum dia menuang minyak hitam pekat itu lagi!"
				},
				"fase_2a": {
					"status": "Mau Berubah",
					"notes": "Ternyata Kak Rina bukannya sengaja ingin mengotori selokan, dia hanya tidak punya wadah dan takut rugi kalau beli jeriken sendiri. Berkat info dari Pemuka Desa, sekarang Kak Rina tahu minyak kotornya bisa ditampung di jeriken gratis Bank Sampah untuk diolah jadi Biodiesel. Malah dapat tambahan modal Rp3.000 per liter!"
				},
				"fase_2b": {
					"status": "Tidak Suka",
					"notes": "Dia benar-benar marah dan mengusirku dari warungnya. Minyak jelantah itu akhirnya tetap dia tuang ke selokan! Minyak itu bisa mengeras jadi gumpalan lemak padat yang menyumbat total parit desa. Sial, kenapa tadi aku malah menyalahkan dagangannya padahal dia sedang susah cari makan..."
				}
			}
		},
		"right": {
			"key": "jali",
			"name": "Bang Jali",
			"portrait_neutral": "res://assets/sprites/portraits/bang_jali_neutral.png",
			"portrait_happy": "res://assets/sprites/portraits/bang_jali_happy.png",
			"portrait_sad": "res://assets/sprites/portraits/bang_jali_sad.png",
			"is_dynamic": true,
			"phases": {
				"fase_1": {
					"status": "Acuh",
					"notes": "Pemuda temperamental yang tinggal di pemukiman padat mulut gang kota. Tadi aku memergokinya sedang menenteng dua kantong plastik besar penuh sampah rumah tangga yang berbau busuk. Gelagatnya aneh, sepertinya dia bersiap untuk melempar bungkusan raksasa itu langsung ke aliran parit sungai. Aku harus mencegahnya sekarang!"
				},
				"fase_2a": {
					"status": "Mau Berubah",
					"notes": "Gaya bicaranya memang galak, tapi Bang Jali sebenarnya warga yang masuk akal. Dia terpaksa membuang ke parit karena gang rumahnya terlalu sempit untuk dilewati truk kota. Untungnya, dengan membuat Gerobak Sampah Roda komunal bantuan Pak RT di mulut gang, warga sekarang bisa bergotong royong menarik sampah mereka!"
				},
				"fase_2b": {
					"status": "Tidak Suka",
					"notes": "Dia membentakku, melempar plastiknya ke parit, dan menolak bicara denganku lagi! Sialan, kantong sampah sebesar itu pasti berisi ribuan plastik yang akan menyumbat pintu air drainase kota. Kenapa tadi aku malah menuduhnya malas padahal akses fasilitas di gang mereka memang sangat buruk..."
				}
			}
		}
	}
]

func _ready() -> void:
	btn_page1 = btn_slot1
	btn_page2 = btn_slot2
	btn_page3 = btn_slot3
	visible = false
	
	btn_prev.pressed.connect(_on_btn_prev_pressed)
	btn_next.pressed.connect(_on_btn_next_pressed)
	btn_close.pressed.connect(close_book)
	
	btn_slot1.pressed.connect(func(): _on_slot_pressed(0))
	btn_slot2.pressed.connect(func(): _on_slot_pressed(1))
	btn_slot3.pressed.connect(func(): _on_slot_pressed(2))
	
	left_note_btn_prev.pressed.connect(_on_left_note_prev_pressed)
	left_note_btn_next.pressed.connect(_on_left_note_next_pressed)
	right_note_btn_prev.pressed.connect(_on_right_note_prev_pressed)
	right_note_btn_next.pressed.connect(_on_right_note_next_pressed)
	
	_render_page()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and (event.keycode == KEY_ESCAPE or event.keycode == KEY_B or event.keycode == KEY_J)):
		close_book()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_LEFT or event.keycode == KEY_A or event.keycode == KEY_Q:
			_on_btn_prev_pressed()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_RIGHT or event.keycode == KEY_D or event.keycode == KEY_E:
			_on_btn_next_pressed()
			get_viewport().set_input_as_handled()

func is_open() -> bool:
	return visible

func open(page: int = 1) -> void:
	open_book(page)

func close() -> void:
	close_book()

func open_book(page: int = 1) -> void:
	current_page = clampi(page, 1, MAX_PAGES)
	left_note_index = 0
	right_note_index = 0
	_render_page()
	visible = true
	get_tree().paused = true
	opened.emit()

func close_book() -> void:
	visible = false
	get_tree().paused = false
	closed.emit()

func goto_page(page: int) -> void:
	current_page = clampi(page, 1, MAX_PAGES)
	left_note_index = 0
	right_note_index = 0
	_render_page()

func _get_current_group_start() -> int:
	return ((current_page - 1) / SLOTS_COUNT) * SLOTS_COUNT + 1

func _on_slot_pressed(slot_index: int) -> void:
	var group_start := _get_current_group_start()
	var target_page := group_start + slot_index
	if target_page <= MAX_PAGES:
		goto_page(target_page)

func _on_btn_prev_pressed() -> void:
	if current_page > 1:
		goto_page(current_page - 1)

func _on_btn_next_pressed() -> void:
	if current_page < MAX_PAGES:
		goto_page(current_page + 1)

# --- Sub-Pagination Catatan Karakter ---

func _split_note_into_chunks(text: String, max_chars: int = 240) -> Array[String]:
	text = text.strip_edges()
	if text.is_empty():
		return [""]
	if text.length() <= max_chars:
		return [text]
	
	var chunks: Array[String] = []
	var remaining: String = text
	
	while remaining.length() > max_chars:
		var split_pos: int = -1
		for end_char in [". ", "! ", "? "]:
			var p: int = remaining.rfind(end_char, max_chars)
			if p > split_pos:
				split_pos = p + 1
		if split_pos <= 30:
			var p: int = remaining.rfind(", ", max_chars)
			if p > 30:
				split_pos = p + 1
			else:
				var sp: int = remaining.rfind(" ", max_chars)
				split_pos = sp if sp > 30 else max_chars
		var chunk := remaining.substr(0, split_pos).strip_edges()
		chunks.append(chunk)
		remaining = remaining.substr(split_pos).strip_edges()
	
	if not remaining.is_empty():
		chunks.append(remaining)
	
	return chunks

func _on_left_note_prev_pressed() -> void:
	if left_note_index > 0:
		left_note_index -= 1
		_update_left_note_display()

func _on_left_note_next_pressed() -> void:
	if left_note_index < left_note_chunks.size() - 1:
		left_note_index += 1
		_update_left_note_display()

func _update_left_note_display() -> void:
	if left_note_chunks.is_empty():
		left_notes.text = ""
		left_note_btn_prev.visible = false
		left_note_btn_next.visible = false
		left_note_indicator.visible = false
		return
	
	left_notes.text = left_note_chunks[left_note_index]
	var total := left_note_chunks.size()
	if total > 1:
		left_note_indicator.visible = true
		left_note_indicator.text = "%d / %d" % [left_note_index + 1, total]
		left_note_btn_prev.visible = (left_note_index > 0)
		left_note_btn_next.visible = (left_note_index < total - 1)
	else:
		left_note_indicator.visible = false
		left_note_btn_prev.visible = false
		left_note_btn_next.visible = false

func _on_right_note_prev_pressed() -> void:
	if right_note_index > 0:
		right_note_index -= 1
		_update_right_note_display()

func _on_right_note_next_pressed() -> void:
	if right_note_index < right_note_chunks.size() - 1:
		right_note_index += 1
		_update_right_note_display()

func _update_right_note_display() -> void:
	if right_note_chunks.is_empty():
		right_notes.text = ""
		right_note_btn_prev.visible = false
		right_note_btn_next.visible = false
		right_note_indicator.visible = false
		return
	
	right_notes.text = right_note_chunks[right_note_index]
	var total := right_note_chunks.size()
	if total > 1:
		right_note_indicator.visible = true
		right_note_indicator.text = "%d / %d" % [right_note_index + 1, total]
		right_note_btn_prev.visible = (right_note_index > 0)
		right_note_btn_next.visible = (right_note_index < total - 1)
	else:
		right_note_indicator.visible = false
		right_note_btn_prev.visible = false
		right_note_btn_next.visible = false

# --- Render Halaman Utama ---

func _render_page() -> void:
	if current_page < 1 or current_page > CHARACTER_PAGES.size():
		return
	
	var page_data: Dictionary = CHARACTER_PAGES[current_page - 1]
	
	# Render Sisi Kiri
	var left_data: Dictionary = page_data.get("left", {})
	_render_character(left_data, left_photo, left_name, left_status, true)
	
	# Render Sisi Kanan
	var right_data: Dictionary = page_data.get("right", {})
	_render_character(right_data, right_photo, right_name, right_status, false)
	
	# Perbarui Navigasi Halaman
	_update_pagination_ui()

func _render_character(data_char: Dictionary, photo_rect: TextureRect, label_name: Label, label_status: Label, is_left: bool) -> void:
	if data_char.is_empty():
		label_name.text = ""
		label_status.text = ""
		photo_rect.texture = null
		if is_left:
			left_note_chunks = []
			_update_left_note_display()
		else:
			right_note_chunks = []
			_update_right_note_display()
		return
	
	var is_dynamic: bool = data_char.get("is_dynamic", false)
	var key: String = data_char.get("key", "")
	var name_text: String = data_char.get("name", "")
	var status_text: String = ""
	var notes_text: String = ""
	var status_color: Color = COLOR_STATIS
	var portrait_path: String = data_char.get("portrait_neutral", "")
	
	if is_dynamic:
		# PENGECUALIAN untuk 3 NPC Dinamis (Pak Darwis, Kak Rina, Bang Jali):
		# Foto profil dan nama selalu terbuka sejak awal.
		# Sebelum MC menjawab solusi mereka: status kosong ("") dan catatan karakter "???".
		# Setelah MC menjawab solusi mereka: status "Mau Berubah" (hijau) atau "Tidak Suka" (merah),
		# dan catatan karakter terisi narasi fase terkait.
		name_text = data_char.get("name", "")
		var has_decided: bool = GameState.has_decided_npc(key)
		if has_decided:
			var sikap: int = GameState.get_sikap(key)
			var is_peduli: bool = (sikap == GameState.SIKAP_PEDULI) or bool(GameState.choices.get(key + "_peduli", false))
			var is_menolak: bool = (sikap == GameState.SIKAP_MENOLAK) or bool(GameState.choices.get(key + "_menolak", false))
			var phases: Dictionary = data_char.get("phases", {})
			
			if is_peduli:
				var p2a: Dictionary = phases.get("fase_2a", {})
				status_text = p2a.get("status", "Mau Berubah")
				notes_text = p2a.get("notes", "")
				status_color = COLOR_FASE_2A
				portrait_path = data_char.get("portrait_happy", portrait_path)
			elif is_menolak:
				var p2b: Dictionary = phases.get("fase_2b", {})
				status_text = p2b.get("status", "Tidak Suka")
				notes_text = p2b.get("notes", "")
				status_color = COLOR_FASE_2B
				portrait_path = data_char.get("portrait_sad", portrait_path)
			else:
				status_text = ""
				notes_text = "???"
				portrait_path = data_char.get("portrait_neutral", portrait_path)
		else:
			status_text = ""
			notes_text = "???"
			portrait_path = data_char.get("portrait_neutral", portrait_path)
	else:
		# NPC Statis (11 Karakter Pendukung):
		# Muncul saat MC sudah berbicara dengan karakter tersebut.
		# Sebelum MC berbicara: foto tanda tanya, nama "???", status kosong (""), catatan "???".
		# Setelah MC berbicara: foto profil asli, nama asli, status kesan positif, catatan narasi lengkap.
		var has_talked: bool = GameState.has_talked_to_npc(key)
		if has_talked:
			portrait_path = data_char.get("portrait_neutral", "")
			name_text = data_char.get("name", "")
			status_text = data_char.get("status", "")
			status_color = COLOR_STATIS
			notes_text = data_char.get("notes", "")
		else:
			portrait_path = "res://assets/sprites/portraits/unknown_neutral.png"
			name_text = "???"
			status_text = ""
			notes_text = "???"
	
	label_name.text = name_text
	label_status.text = status_text
	label_status.add_theme_color_override("font_color", status_color)
	
	# Split dan tampilkan catatan karakter
	if notes_text == "???":
		var chunks: Array[String] = ["???"]
		if is_left:
			left_note_chunks = chunks
			left_note_index = 0
			_update_left_note_display()
		else:
			right_note_chunks = chunks
			right_note_index = 0
			_update_right_note_display()
	else:
		var chunks := _split_note_into_chunks(notes_text, 240)
		if is_left:
			left_note_chunks = chunks
			left_note_index = 0
			_update_left_note_display()
		else:
			right_note_chunks = chunks
			right_note_index = 0
			_update_right_note_display()
	
	if ResourceLoader.exists(portrait_path):
		photo_rect.texture = load(portrait_path)
	elif FileAccess.file_exists(portrait_path) or FileAccess.file_exists(ProjectSettings.globalize_path(portrait_path)):
		var actual_path: String = ProjectSettings.globalize_path(portrait_path)
		var img := Image.load_from_file(actual_path)
		if img:
			photo_rect.texture = ImageTexture.create_from_image(img)
	else:
		photo_rect.texture = null

func _update_pagination_ui() -> void:
	var group_start := _get_current_group_start()
	var slot_buttons := [btn_slot1, btn_slot2, btn_slot3]
	
	for i in range(SLOTS_COUNT):
		var page_num := group_start + i
		var btn: Button = slot_buttons[i]
		if page_num <= MAX_PAGES:
			btn.visible = true
			btn.text = str(page_num)
			if page_num == current_page:
				if page_highlighter:
					page_highlighter.visible = true
					page_highlighter.position = btn.position
					page_highlighter.size = btn.size
				# Warna angka aktif: Tinta cokelat tua pekat tegas (SANGAT JELAS TERBACA, TIDAK HILANG)
				btn.add_theme_color_override("font_color", Color(0.18, 0.10, 0.05, 1.0))
			else:
				# Warna angka inaktif: Tinta cokelat netral terbaca
				btn.add_theme_color_override("font_color", Color(0.38, 0.24, 0.15, 0.85))
		else:
			btn.visible = false
	
	# Sembunyikan highlighter jika halaman aktif di luar slot yang tampil (safety check)
	var active_slot_idx := current_page - group_start
	if active_slot_idx < 0 or active_slot_idx >= SLOTS_COUNT or current_page > MAX_PAGES:
		if page_highlighter:
			page_highlighter.visible = false
