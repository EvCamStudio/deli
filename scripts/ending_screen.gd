## EndingScreen Script (Deli Rewind)
## Urutan Epilog:
## 1. Layar Narasi Sinematik Pembuka (Cinematic Title & Narration Card di tengah layar)
## 2. Komik Epilog 3 Panel Interaktif (Pita Caption di tiap panel + Kotak Dialog 100% Karakter dengan Portrait)
## 3. Layar Kartu Ringkasan Akhir & Statistik + Tombol (Main Lagi / Rewind Waktu, Lihat Komik, Koleksi Kartu, Keluar)
extends Control

@onready var ending_title: Label = $Panel/VBox/EndingTitle
@onready var ending_message: RichTextLabel = $Panel/VBox/EndingMessage
@onready var stats_label: RichTextLabel = $Panel/VBox/StatsLabel
@onready var play_again_btn: Button = get_node_or_null("Panel/VBox/Buttons/PlayAgainBtn") as Button
@onready var quit_btn: Button = get_node_or_null("Panel/VBox/Buttons/QuitBtn") as Button
@onready var cards_btn: Button = get_node_or_null("Panel/VBox/Buttons/CardsBtn") as Button
@onready var card_popup: CanvasLayer = get_node_or_null("KnowledgeCardPopup") as CanvasLayer
@onready var river_visual: ColorRect = get_node_or_null("Background/RiverVisual") as ColorRect

const TYPEWRITER_SPEED: float = 0.022

var _bg_tex_rect: TextureRect = null
var _dim_overlay: ColorRect = null
var _badge_label: Label = null

# Node Layar Narasi Sinematik Pembuka (Stage 1)
var _cinematic_card: PanelContainer = null
var _cinematic_header: Label = null
var _cinematic_divider: ColorRect = null
var _cinematic_body: RichTextLabel = null
var _cinematic_hint: Label = null
var _in_cinematic_intro: bool = false

# Node Komik Interaktif (Stage 2)
var _comic_layer: Control = null
var _comic_panels_root: Control = null
var _comic_panels: Array[PanelContainer] = []
var _comic_textures: Array[TextureRect] = []
var _comic_caption_labels: Array[Label] = []
var _comic_dialog_box: Control = null
var _comic_portrait_frame: PanelContainer = null
var _comic_portrait: TextureRect = null
var _comic_speaker: Label = null
var _comic_text: RichTextLabel = null
var _comic_step_badge: Label = null
var _comic_next_hint: Label = null
var _comic_tap_btn: Button = null

var _current_code: String = "BAD"
var _is_good_ending: bool = false
var _comic_slides: Array[Dictionary] = []
var _comic_step: int = 0
var _is_typing: bool = false
var _active_typing_label: RichTextLabel = null
var _last_typed_char: int = 0
var _type_tween: Tween = null
var _in_comic_mode: bool = true

const ENDING_DATA: Dictionary = {
	"GOOD": {
		"badge": "— AKHIR PERJALANAN · SUNGAI DELI PULIH —",
		"title": "🌟 Harapan Baru Sungai Deli",
		"message": "Berkat gotong royong warga dari hulu hingga muara, Sungai Deli kini kembali mengalir jernih dan tenang. Warung makan keluarga kembali ramai dikunjungi pelanggan tanpa dihantui ancaman banjir.\n\n[b][color=#4a2c11]Bu Mira:[/color][/b] \"Alhamdulillah, Nak... Musim hujan kali ini air sungai tetap tenang dan warung kita kembali ramai.\"\n[b][color=#1b5e3a]Datuk Sampan:[/color][/b] [i]\"Waktu tak bisa diputar kembali di dunia nyata. Yang bisa kita ubah hanyalah kebiasaan kita—dan kebiasaan baik selalu dimulai dari mendengar.\"[/i]",
		"bg": "res://assets/ui/ending_good_bg.png",
		"title_color": Color(0.12, 0.44, 0.24, 1.0),
		"border_color": Color(0.28, 0.56, 0.34, 1.0),
		"cinematic_header": "— ENAM BULAN KEMUDIAN —",
		"cinematic_narration": "Pukul lima subuh di tepian Sungai Deli yang kini kembali jernih dan tenang.\n\nBerkat kepedulian warga menjaga sungai dari hulu hingga muara, musim hujan tak lagi membawa bencana. Dari dalam warung makan keluarga, kembali terdengar denting sendok yang beradu dengan gelas kaca...",
		"panels": [
			"res://assets/ui/comic_good_p1.png",
			"res://assets/ui/comic_good_p2.png",
			"res://assets/ui/comic_good_p3.png",
		],
		"panel_captions": [
			" 1 · WARUNG KELUARGA KEMBALI RAMAI ",
			" 2 · GOTONG ROYONG WARGA BANTARAN ",
			" 3 · SUNGAI DELI YANG JERNIH & LESTARI ",
		],
		"slides": [
			{
				"panel": 0,
				"speaker": "Bu Mira",
				"portrait": "res://assets/sprites/portraits/ibu_happy.png",
				"text": "\"Alhamdulillah, Nak. Musim hujan kali ini air sungai tetap tenang, dan pelanggan warung kita kembali ramai berdatangan setiap pagi.\""
			},
			{
				"panel": 1,
				"speaker": "Pak Hendra",
				"portrait": "res://assets/sprites/portraits/pak_hendra_happy.png",
				"text": "\"Lihatlah tepian sungai itu sekarang. Pak Darwis, Kak Rina, dan Bang Jali rutin bergotong royong menjaga kebersihan sungai bersama warga kampung lainnya.\""
			},
			{
				"panel": 2,
				"speaker": "Datuk Sampan",
				"portrait": "res://assets/sprites/portraits/datuk_happy.png",
				"text": "\"Aku bukan sekadar hantu, Nak. Aku adalah ingatan kampung ini tentang cara menjaga Sungai Deli. Waktu tak bisa diputar kembali di dunia nyata—yang bisa kita ubah hanyalah kebiasaan kita, dan kebiasaan baik selalu dimulai dari mendengar.\""
			}
		]
	},
	"BAD": {
		"badge": "— PERINGATAN BENCANA · SUNGAI DELI MELUAP —",
		"title": "🌧 Banjir Bandang Sungai Deli",
		"message": "Banjir bandang menerjang dahsyat. Air cokelat pekat menelan warung keluarga MC, hanya menyisakan tiang-tiang kayu yang patah dan sepasang sandal yang mengapung di atas lumpur.\n\n[b][color=#4a2c11]Datuk Sampan:[/color][/b] \"Sungai tak pernah membenci siapa pun, Nak. Ia hanya kembali mencari jalannya yang tersumbat. Satu orang membuang, semua orang yang menanggung akibatnya.\"\n[b][color=#8f241e]\"Tekan REWIND untuk memutar waktu kembali dan memulai dengan mendengar.\"[/color][/b]",
		"bg": "res://assets/ui/ending_bad_bg.png",
		"title_color": Color(0.62, 0.16, 0.14, 1.0),
		"border_color": Color(0.58, 0.24, 0.20, 1.0),
		"cinematic_header": "— MALAM BANJIR BANDANG —",
		"cinematic_narration": "Hujan badai mengguyur Sumatera Utara tanpa henti sepanjang malam.\n\nTanggul Sungai Deli yang tersumbat tumpukan sampah dan pendangkalan akhirnya tak lagi sanggup menahan desakan arus air cokelat pekat dari hulu...",
		"panels": [
			"res://assets/ui/comic_bad_p1.png",
			"res://assets/ui/comic_bad_p2.png",
			"res://assets/ui/comic_bad_p3.png",
		],
		"panel_captions": [
			" 1 · TANGGUL JEBOL DITERJANG ARUS ",
			" 2 · WARUNG KELUARGA TERENDAM LUMPUR ",
			" 3 · KESEMPATAN KEDUA DARI DATUK SAMPAN ",
		],
		"slides": [
			{
				"panel": 0,
				"speaker": "Bu Mira",
				"portrait": "res://assets/sprites/portraits/ibu_sad.png",
				"text": "\"Nak, air sungainya naik cepat sekali! Warung dan seluruh perabotan kita terendam lumpur banjir bandang!\""
			},
			{
				"panel": 1,
				"speaker": "MC",
				"portrait": "res://assets/sprites/portraits/player_sad.png",
				"text": "\"Warung Mamak dan kampung ini lumpuh diterjang air cokelat pekat... Andai saja waktu itu aku tidak terburu-buru marah dan lebih sabar mencarikan jalan keluar bersama warga...\""
			},
			{
				"panel": 2,
				"speaker": "Datuk Sampan",
				"portrait": "res://assets/sprites/portraits/datuk_sad.png",
				"text": "\"Sungai tak pernah membenci siapa pun, Nak. Ia hanya kembali mencari jalannya yang tersumbat. Satu orang membuang, semua orang yang menanggung akibatnya. Putar kembali waktumu... dan kali ini, mulailah dengan mendengar.\""
			}
		]
	}
}

func _ready() -> void:
	if play_again_btn == null:
		play_again_btn = get_node_or_null("Panel/VBox/HBox/PlayAgainBtn") as Button
	if quit_btn == null:
		quit_btn = get_node_or_null("Panel/VBox/HBox/QuitBtn") as Button
	if cards_btn == null:
		cards_btn = get_node_or_null("Panel/VBox/HBox/CardsBtn") as Button

	_setup_visual_card_layout()
	_build_comic_epilogue_ui()
	_show_ending()

	if not _is_good_ending:
		AudioManager.play_bgm("epilog_bad")
	else:
		AudioManager.play_bgm(5)

	if play_again_btn:
		play_again_btn.pressed.connect(_on_play_again)
	if cards_btn:
		cards_btn.pressed.connect(_on_cards)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit)

func _process(_delta: float) -> void:
	if _is_typing and _active_typing_label and _active_typing_label.is_visible_in_tree():
		var cur: int = _active_typing_label.visible_characters
		if cur > _last_typed_char:
			_last_typed_char = cur
			AudioManager.play_typewriter_blip()

func _input(event: InputEvent) -> void:
	if not _in_comic_mode:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("action"):
		_on_comic_tap()
		get_viewport().set_input_as_handled()

func _setup_visual_card_layout() -> void:
	var bg_node := get_node_or_null("Background") as Control
	if bg_node:
		var rf := bg_node.get_node_or_null("RiverFar") as CanvasItem
		if rf:
			rf.visible = false
		if river_visual:
			river_visual.visible = false

		_bg_tex_rect = TextureRect.new()
		_bg_tex_rect.name = "EndingIllustrationBG"
		_bg_tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		_bg_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_bg_tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_bg_tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg_node.add_child(_bg_tex_rect)

		_dim_overlay = ColorRect.new()
		_dim_overlay.name = "DimOverlay"
		_dim_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		_dim_overlay.color = Color(0.06, 0.05, 0.04, 0.48)
		_dim_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg_node.add_child(_dim_overlay)

	var panel := get_node_or_null("Panel") as PanelContainer
	var vbox := get_node_or_null("Panel/VBox") as VBoxContainer
	var pixel_font: Font = load("res://assets/fonts/PixelifySans.ttf") if ResourceLoader.exists("res://assets/fonts/PixelifySans.ttf") else null

	if panel:
		panel.offset_left = -270.0
		panel.offset_top = -166.0
		panel.offset_right = 270.0
		panel.offset_bottom = 166.0

	if vbox:
		vbox.add_theme_constant_override("separation", 6)
		_badge_label = Label.new()
		_badge_label.name = "BadgeLabel"
		_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_badge_label.add_theme_font_size_override("font_size", 10)
		_badge_label.add_theme_color_override("font_color", Color(0.48, 0.34, 0.20, 0.95))
		if pixel_font:
			_badge_label.add_theme_font_override("font", pixel_font)
		vbox.add_child(_badge_label)
		vbox.move_child(_badge_label, 0)

	if ending_title:
		ending_title.add_theme_font_size_override("font_size", 20)

	if ending_message:
		ending_message.custom_minimum_size = Vector2(0, 96)
		ending_message.add_theme_color_override("default_color", Color(0.20, 0.14, 0.09, 1.0))
		ending_message.add_theme_font_size_override("normal_font_size", 11)
		ending_message.add_theme_font_size_override("bold_font_size", 11)
		ending_message.add_theme_font_size_override("italics_font_size", 11)
		if pixel_font:
			ending_message.add_theme_font_override("normal_font", pixel_font)
			ending_message.add_theme_font_override("bold_font", pixel_font)
			ending_message.add_theme_font_override("italics_font", pixel_font)

	if stats_label:
		stats_label.custom_minimum_size = Vector2(0, 74)
		stats_label.add_theme_color_override("default_color", Color(0.24, 0.18, 0.12, 1.0))
		stats_label.add_theme_font_size_override("normal_font_size", 11)
		stats_label.add_theme_font_size_override("bold_font_size", 11)
		if pixel_font:
			stats_label.add_theme_font_override("normal_font", pixel_font)
			stats_label.add_theme_font_override("bold_font", pixel_font)
		var stats_sb := StyleBoxFlat.new()
		stats_sb.bg_color = Color(0.88, 0.80, 0.66, 0.55)
		stats_sb.border_width_left = 1
		stats_sb.border_width_top = 1
		stats_sb.border_width_right = 1
		stats_sb.border_width_bottom = 1
		stats_sb.border_color = Color(0.56, 0.42, 0.26, 0.6)
		stats_sb.set_corner_radius_all(6)
		stats_sb.content_margin_left = 12.0
		stats_sb.content_margin_top = 6.0
		stats_sb.content_margin_right = 12.0
		stats_sb.content_margin_bottom = 6.0
		stats_label.add_theme_stylebox_override("normal", stats_sb)

	var buttons_row := get_node_or_null("Panel/VBox/Buttons") as HBoxContainer
	if buttons_row and buttons_row.get_node_or_null("ReplayComicBtn") == null:
		var replay_btn := Button.new()
		replay_btn.name = "ReplayComicBtn"
		replay_btn.text = "📖 Lihat Komik"
		replay_btn.custom_minimum_size = Vector2(0, 30)
		replay_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		replay_btn.pressed.connect(func(): _start_comic_sequence())
		buttons_row.add_child(replay_btn)
		buttons_row.move_child(replay_btn, 1)
		if pixel_font:
			replay_btn.add_theme_font_override("font", pixel_font)
			replay_btn.add_theme_font_size_override("font_size", 12)

	for btn in [play_again_btn, cards_btn, quit_btn]:
		if btn and pixel_font:
			btn.add_theme_font_override("font", pixel_font)
			btn.add_theme_font_size_override("font_size", 12)

func _build_comic_epilogue_ui() -> void:
	var pixel_font: Font = load("res://assets/fonts/PixelifySans.ttf") if ResourceLoader.exists("res://assets/fonts/PixelifySans.ttf") else null

	_comic_layer = Control.new()
	_comic_layer.name = "ComicEpilogueLayer"
	_comic_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_comic_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_comic_layer)
	var panel_node := get_node_or_null("Panel")
	if panel_node:
		move_child(_comic_layer, panel_node.get_index())

	# =========================================================================
	# STAGE 1: Layar Narasi Sinematik Pembuka (Cinematic Intro Card)
	# =========================================================================
	_cinematic_card = PanelContainer.new()
	_cinematic_card.name = "CinematicIntroCard"
	_cinematic_card.position = Vector2(76, 64)
	_cinematic_card.size = Vector2(488, 224)
	_cinematic_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cin_sb := StyleBoxFlat.new()
	cin_sb.bg_color = Color(0.08, 0.06, 0.05, 0.90)
	cin_sb.border_width_left = 2
	cin_sb.border_width_top = 2
	cin_sb.border_width_right = 2
	cin_sb.border_width_bottom = 2
	cin_sb.border_color = Color(0.86, 0.70, 0.36, 0.85)
	cin_sb.set_corner_radius_all(10)
	cin_sb.shadow_color = Color(0, 0, 0, 0.65)
	cin_sb.shadow_size = 12
	cin_sb.content_margin_left = 30.0
	cin_sb.content_margin_top = 24.0
	cin_sb.content_margin_right = 30.0
	cin_sb.content_margin_bottom = 20.0
	_cinematic_card.add_theme_stylebox_override("panel", cin_sb)
	_comic_layer.add_child(_cinematic_card)

	var cin_vbox := VBoxContainer.new()
	cin_vbox.add_theme_constant_override("separation", 12)
	cin_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	cin_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cinematic_card.add_child(cin_vbox)

	_cinematic_header = Label.new()
	_cinematic_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cinematic_header.add_theme_font_size_override("font_size", 18)
	_cinematic_header.add_theme_color_override("font_color", Color(0.98, 0.86, 0.50, 1.0))
	if pixel_font:
		_cinematic_header.add_theme_font_override("font", pixel_font)
	cin_vbox.add_child(_cinematic_header)

	var div_center := CenterContainer.new()
	div_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cin_vbox.add_child(div_center)
	_cinematic_divider = ColorRect.new()
	_cinematic_divider.custom_minimum_size = Vector2(220, 2)
	_cinematic_divider.color = Color(0.86, 0.70, 0.36, 0.65)
	_cinematic_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	div_center.add_child(_cinematic_divider)

	_cinematic_body = RichTextLabel.new()
	_cinematic_body.bbcode_enabled = true
	_cinematic_body.scroll_active = false
	_cinematic_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_cinematic_body.add_theme_color_override("default_color", Color(0.95, 0.91, 0.84, 1.0))
	_cinematic_body.add_theme_font_size_override("normal_font_size", 12)
	_cinematic_body.add_theme_font_size_override("italics_font_size", 12)
	_cinematic_body.add_theme_font_size_override("bold_font_size", 12)
	if pixel_font:
		_cinematic_body.add_theme_font_override("normal_font", pixel_font)
		_cinematic_body.add_theme_font_override("italics_font", pixel_font)
		_cinematic_body.add_theme_font_override("bold_font", pixel_font)
	_cinematic_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cin_vbox.add_child(_cinematic_body)

	_cinematic_hint = Label.new()
	_cinematic_hint.text = "Tap / Tekan Spasi untuk membuka kisah epilog ▶"
	_cinematic_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cinematic_hint.add_theme_color_override("font_color", Color(0.86, 0.74, 0.48, 0.90))
	_cinematic_hint.add_theme_font_size_override("font_size", 10)
	if pixel_font:
		_cinematic_hint.add_theme_font_override("font", pixel_font)
	cin_vbox.add_child(_cinematic_hint)

	# =========================================================================
	# STAGE 2: Halaman Komik 3 Panel + Kotak Dialog Karakter
	# =========================================================================
	_comic_panels_root = Control.new()
	_comic_panels_root.name = "ComicPanelsRoot"
	_comic_panels_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_comic_panels_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_comic_layer.add_child(_comic_panels_root)

	var rects: Array[Rect2] = [
		Rect2(34, 12, 280, 108),
		Rect2(326, 12, 280, 108),
		Rect2(34, 128, 572, 110),
	]
	_comic_panels.clear()
	_comic_textures.clear()
	_comic_caption_labels.clear()

	for i in range(rects.size()):
		var r: Rect2 = rects[i]
		var p_frame := PanelContainer.new()
		p_frame.position = r.position
		p_frame.size = r.size
		p_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_comic_panels_root.add_child(p_frame)
		_comic_panels.append(p_frame)

		var tex_rect := TextureRect.new()
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tex_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tex_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p_frame.add_child(tex_rect)
		_comic_textures.append(tex_rect)

		# Pita Caption Komik (Comic Caption Box) di pojok kiri atas tiap panel
		var cap_badge := Label.new()
		cap_badge.text = " %d " % (i + 1)
		cap_badge.position = Vector2(6, 5)
		cap_badge.add_theme_font_size_override("font_size", 9)
		cap_badge.add_theme_color_override("font_color", Color(0.20, 0.12, 0.05, 1.0))
		if pixel_font:
			cap_badge.add_theme_font_override("font", pixel_font)
		var badge_sb := StyleBoxFlat.new()
		badge_sb.bg_color = Color(0.97, 0.89, 0.68, 0.94)
		badge_sb.border_width_left = 1
		badge_sb.border_width_top = 1
		badge_sb.border_width_right = 1
		badge_sb.border_width_bottom = 1
		badge_sb.border_color = Color(0.42, 0.26, 0.10, 0.95)
		badge_sb.set_corner_radius_all(3)
		badge_sb.content_margin_left = 4.0
		badge_sb.content_margin_top = 1.0
		badge_sb.content_margin_right = 4.0
		badge_sb.content_margin_bottom = 1.0
		cap_badge.add_theme_stylebox_override("normal", badge_sb)
		tex_rect.add_child(cap_badge)
		_comic_caption_labels.append(cap_badge)

	# Kotak Dialog Karakter di Bagian Bawah Layar (y=246..350)
	_comic_dialog_box = PanelContainer.new()
	_comic_dialog_box.position = Vector2(34, 246)
	_comic_dialog_box.size = Vector2(572, 104)
	_comic_dialog_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dlg_sb := StyleBoxFlat.new()
	dlg_sb.bg_color = Color(0.96, 0.91, 0.81, 0.97)
	dlg_sb.border_width_left = 3
	dlg_sb.border_width_top = 3
	dlg_sb.border_width_right = 3
	dlg_sb.border_width_bottom = 3
	dlg_sb.border_color = Color(0.46, 0.30, 0.15, 1.0)
	dlg_sb.set_corner_radius_all(8)
	dlg_sb.shadow_color = Color(0, 0, 0, 0.45)
	dlg_sb.shadow_size = 6
	dlg_sb.content_margin_left = 12.0
	dlg_sb.content_margin_top = 8.0
	dlg_sb.content_margin_right = 14.0
	dlg_sb.content_margin_bottom = 8.0
	_comic_dialog_box.add_theme_stylebox_override("panel", dlg_sb)
	_comic_panels_root.add_child(_comic_dialog_box)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_comic_dialog_box.add_child(hbox)

	# Frame Foto Portrait Karakter Asli
	_comic_portrait_frame = PanelContainer.new()
	_comic_portrait_frame.custom_minimum_size = Vector2(76, 84)
	_comic_portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var p_sb := StyleBoxFlat.new()
	p_sb.bg_color = Color(0.86, 0.77, 0.62, 1.0)
	p_sb.border_width_left = 2
	p_sb.border_width_top = 2
	p_sb.border_width_right = 2
	p_sb.border_width_bottom = 2
	p_sb.border_color = Color(0.48, 0.32, 0.16, 1.0)
	p_sb.set_corner_radius_all(6)
	_comic_portrait_frame.add_theme_stylebox_override("panel", p_sb)
	hbox.add_child(_comic_portrait_frame)

	_comic_portrait = TextureRect.new()
	_comic_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_comic_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_comic_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_comic_portrait_frame.add_child(_comic_portrait)

	var text_vbox := VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_vbox.add_theme_constant_override("separation", 3)
	text_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(text_vbox)

	var top_bar := HBoxContainer.new()
	top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_vbox.add_child(top_bar)

	_comic_speaker = Label.new()
	_comic_speaker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_comic_speaker.add_theme_color_override("font_color", Color(0.44, 0.26, 0.10, 1.0))
	_comic_speaker.add_theme_font_size_override("font_size", 13)
	if pixel_font:
		_comic_speaker.add_theme_font_override("font", pixel_font)
	top_bar.add_child(_comic_speaker)

	_comic_step_badge = Label.new()
	_comic_step_badge.add_theme_color_override("font_color", Color(0.52, 0.38, 0.24, 0.9))
	_comic_step_badge.add_theme_font_size_override("font_size", 10)
	if pixel_font:
		_comic_step_badge.add_theme_font_override("font", pixel_font)
	top_bar.add_child(_comic_step_badge)

	_comic_text = RichTextLabel.new()
	_comic_text.bbcode_enabled = true
	_comic_text.scroll_active = false
	_comic_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_comic_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_comic_text.add_theme_color_override("default_color", Color(0.20, 0.13, 0.08, 1.0))
	_comic_text.add_theme_font_size_override("normal_font_size", 11)
	_comic_text.add_theme_font_size_override("bold_font_size", 11)
	_comic_text.add_theme_font_size_override("italics_font_size", 11)
	if pixel_font:
		_comic_text.add_theme_font_override("normal_font", pixel_font)
		_comic_text.add_theme_font_override("bold_font", pixel_font)
		_comic_text.add_theme_font_override("italics_font", pixel_font)
	_comic_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_vbox.add_child(_comic_text)

	_comic_next_hint = Label.new()
	_comic_next_hint.text = "Tap / Tekan Spasi untuk panel berikutnya ▶"
	_comic_next_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_comic_next_hint.add_theme_color_override("font_color", Color(0.50, 0.36, 0.22, 0.95))
	_comic_next_hint.add_theme_font_size_override("font_size", 10)
	if pixel_font:
		_comic_next_hint.add_theme_font_override("font", pixel_font)
	text_vbox.add_child(_comic_next_hint)

	# Tombol transparan fullscreen untuk Tap / Klik Lanjut
	_comic_tap_btn = Button.new()
	_comic_tap_btn.name = "ComicTapAdvanceBtn"
	_comic_tap_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	_comic_tap_btn.flat = true
	_comic_tap_btn.focus_mode = Control.FOCUS_NONE
	_comic_tap_btn.pressed.connect(_on_comic_tap)
	_comic_layer.add_child(_comic_tap_btn)

func _resolve_is_good_ending() -> bool:
	var raw_code: String = str(GameState.ending_terakhir).strip_edges().to_upper()
	if raw_code in ["A", "B", "BAIK", "GOOD", "HAPPY", "GOOD_ENDING", "HAPPY_ENDING"]:
		return true
	if raw_code in ["C", "D", "BURUK", "BAD", "REWIND", "BAD_ENDING"]:
		return false
	# Rumus 2 Ending anti-bug: Ending D jika Meter >= 100% atau (Meter > 60% dan Peduli < 2)
	var meter_akhir: int = int(round(GameState.meter_bencana if "meter_bencana" in GameState else (100.0 - GameState.river_health)))
	var peduli_count: int = GameState.get_jumlah_npc_peduli() if GameState.has_method("get_jumlah_npc_peduli") else 0
	return not (meter_akhir >= 100 or (meter_akhir > 60 and peduli_count < 2))

func _show_ending() -> void:
	_is_good_ending = _resolve_is_good_ending()
	_current_code = "GOOD" if _is_good_ending else "BAD"

	var data: Dictionary = ENDING_DATA[_current_code]
	if _badge_label:
		_badge_label.text = str(data.get("badge", ""))
	ending_title.text = str(data["title"])
	ending_title.add_theme_color_override("font_color", data["title_color"])
	ending_message.text = "[center]%s[/center]" % str(data["message"])

	var bg_path: String = str(data.get("bg", ""))
	if _bg_tex_rect and ResourceLoader.exists(bg_path):
		_bg_tex_rect.texture = load(bg_path)

	var panel := get_node_or_null("Panel") as PanelContainer
	if panel:
		var card_sb := StyleBoxFlat.new()
		card_sb.bg_color = Color(0.96, 0.91, 0.81, 0.95)
		card_sb.border_width_left = 3
		card_sb.border_width_top = 3
		card_sb.border_width_right = 3
		card_sb.border_width_bottom = 3
		card_sb.border_color = data["border_color"]
		card_sb.set_corner_radius_all(10)
		card_sb.shadow_color = Color(0, 0, 0, 0.45)
		card_sb.shadow_size = 8
		card_sb.content_margin_left = 20.0
		card_sb.content_margin_top = 14.0
		card_sb.content_margin_right = 20.0
		card_sb.content_margin_bottom = 14.0
		panel.add_theme_stylebox_override("panel", card_sb)

	if play_again_btn:
		if not _is_good_ending:
			play_again_btn.text = "⏪ Rewind Waktu"
		else:
			play_again_btn.text = "🔄 Main Lagi"

	var meter_akhir: int = int(round(GameState.meter_bencana if "meter_bencana" in GameState else (100.0 - GameState.river_health)))
	var kejernihan: int = clampi(100 - meter_akhir, 0, 100)
	var peduli_count: int = GameState.get_jumlah_npc_peduli() if GameState.has_method("get_jumlah_npc_peduli") else 0
	var pohon_hulu: int = maxi(GameState.trees_planted, GameState.zone_stat("hulu", "trees"))
	var bakau_hilir: int = maxi(GameState.mangroves_planted, GameState.zone_stat("hilir", "mangroves"))

	var stats: String = "[center][b][color=#3d2510]— RINGKASAN PERJALANAN SUNGAI DELI —[/color][/b]\n"
	stats += "Meter Bencana: [b]%d%%[/b] (Kejernihan Air [b]%d%%[/b])   ·   Warga Peduli: [b]%d / 3 Warga[/b]\n" % [meter_akhir, kejernihan, peduli_count]
	stats += "Sampah Dipilah: [b]%d[/b]   ·   Pohon Hulu: [b]%d[/b]   ·   Mangrove Muara: [b]%d[/b]   ·   Kartu: [b]%d[/b][/center]" % [
		GameState.get_total_trash(),
		pohon_hulu,
		bakau_hilir,
		GameState.collected_cards.size()
	]
	stats_label.text = stats

	# Muat 3 tekstur panel komik & pita caption komik sesuai Good / Bad Ending
	var panel_paths: Array = data.get("panels", [])
	for i in range(mini(panel_paths.size(), _comic_textures.size())):
		var p_path: String = str(panel_paths[i])
		if ResourceLoader.exists(p_path):
			_comic_textures[i].texture = load(p_path)

	var captions: Array = data.get("panel_captions", [])
	for i in range(mini(captions.size(), _comic_caption_labels.size())):
		_comic_caption_labels[i].text = str(captions[i])

	_comic_slides.clear()
	for s in data.get("slides", []):
		_comic_slides.append(s)

	# Mulai dari Layar Narasi Sinematik -> Komik 3 Panel -> Kartu Ending
	_start_comic_sequence()

func _start_comic_sequence() -> void:
	var panel := get_node_or_null("Panel") as Control
	if panel:
		panel.visible = false
	if _comic_layer:
		_comic_layer.visible = true
		_comic_layer.modulate.a = 1.0
	_in_comic_mode = true
	_comic_step = 0
	_show_cinematic_intro_card()

func _show_cinematic_intro_card() -> void:
	_in_cinematic_intro = true
	if _comic_panels_root:
		_comic_panels_root.visible = false
	if not _cinematic_card:
		_transition_cinematic_to_comic()
		return

	var data: Dictionary = ENDING_DATA[_current_code]
	var accent: Color = Color(0.95, 0.80, 0.42, 1.0) if _is_good_ending else Color(0.92, 0.38, 0.30, 1.0)
	_cinematic_header.text = str(data.get("cinematic_header", ""))
	_cinematic_header.add_theme_color_override("font_color", accent)
	if _cinematic_divider:
		_cinematic_divider.color = Color(accent.r, accent.g, accent.b, 0.65)

	_cinematic_card.visible = true
	_cinematic_card.modulate.a = 0.0
	var tw_in := create_tween()
	tw_in.tween_property(_cinematic_card, "modulate:a", 1.0, 0.28)

	var narration: String = "[center][i]%s[/i][/center]" % str(data.get("cinematic_narration", ""))
	_start_typewriter_on(_cinematic_body, _cinematic_hint, narration)

func _transition_cinematic_to_comic() -> void:
	_in_cinematic_intro = false
	if _cinematic_card and _cinematic_card.visible:
		var tw_out := create_tween()
		tw_out.tween_property(_cinematic_card, "modulate:a", 0.0, 0.20)
		tw_out.tween_callback(func():
			_cinematic_card.visible = false
		)
	if _comic_panels_root:
		_comic_panels_root.visible = true
		_comic_panels_root.modulate.a = 0.0
		var tw_in := create_tween()
		tw_in.tween_interval(0.12)
		tw_in.tween_property(_comic_panels_root, "modulate:a", 1.0, 0.25)
	_comic_step = 0
	_render_comic_step()

func _render_comic_step() -> void:
	if _comic_step < 0 or _comic_step >= _comic_slides.size():
		_finish_comic_to_final_card()
		return

	var slide: Dictionary = _comic_slides[_comic_step]
	var active_panel_idx: int = int(slide.get("panel", _comic_step))
	var prev_panel_idx: int = int(_comic_slides[_comic_step - 1].get("panel", -1)) if _comic_step > 0 else -1
	var accent_color: Color = Color(0.94, 0.78, 0.36, 1.0) if _is_good_ending else Color(0.86, 0.32, 0.24, 1.0)

	# Highlight panel komik yang sedang aktif dan redupkan panel yang belum/sudah lewat
	for i in range(_comic_panels.size()):
		var p: PanelContainer = _comic_panels[i]
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.08, 0.06, 0.05, 1.0)
		sb.set_corner_radius_all(4)
		if i == active_panel_idx:
			sb.border_width_left = 3
			sb.border_width_top = 3
			sb.border_width_right = 3
			sb.border_width_bottom = 3
			sb.border_color = accent_color
			sb.shadow_color = Color(0, 0, 0, 0.55)
			sb.shadow_size = 5
			p.add_theme_stylebox_override("panel", sb)
			if active_panel_idx != prev_panel_idx:
				var tw := create_tween()
				p.modulate = Color(0.6, 0.6, 0.6, 1.0)
				tw.tween_property(p, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25)
			else:
				p.modulate = Color(1.0, 1.0, 1.0, 1.0)
		elif i < active_panel_idx:
			sb.border_width_left = 2
			sb.border_width_top = 2
			sb.border_width_right = 2
			sb.border_width_bottom = 2
			sb.border_color = Color(0.45, 0.36, 0.25, 0.85)
			p.add_theme_stylebox_override("panel", sb)
			p.modulate = Color(0.68, 0.66, 0.62, 0.95)
		else:
			sb.border_width_left = 2
			sb.border_width_top = 2
			sb.border_width_right = 2
			sb.border_width_bottom = 2
			sb.border_color = Color(0.24, 0.20, 0.16, 0.65)
			p.add_theme_stylebox_override("panel", sb)
			p.modulate = Color(0.26, 0.24, 0.22, 0.80)

	var spk: String = str(slide.get("speaker", ""))
	if spk == "MC":
		var p_name: String = GameState.player_name.strip_edges() if GameState.player_name.strip_edges() != "" else "Pemain"
		_comic_speaker.text = p_name
	else:
		_comic_speaker.text = spk

	_comic_step_badge.text = "Panel %d / %d" % [active_panel_idx + 1, _comic_panels.size()]

	var port_path: String = str(slide.get("portrait", ""))
	if port_path != "" and ResourceLoader.exists(port_path):
		if _comic_portrait_frame:
			_comic_portrait_frame.visible = true
		_comic_portrait.texture = load(port_path)
	else:
		if _comic_portrait_frame:
			_comic_portrait_frame.visible = false
		_comic_portrait.texture = null

	if _comic_step + 1 < _comic_slides.size():
		_comic_next_hint.text = "Tap / Tekan Spasi untuk panel berikutnya ▶"
	else:
		_comic_next_hint.text = "Tap / Tekan Spasi untuk hasil akhir ▶"

	_start_typewriter_on(_comic_text, _comic_next_hint, str(slide.get("text", "")))

func _start_typewriter_on(target_label: RichTextLabel, hint_label: Label, bbcode_text: String) -> void:
	if _type_tween:
		_type_tween.kill()
	_is_typing = true
	_active_typing_label = target_label
	_last_typed_char = 0
	target_label.text = bbcode_text
	target_label.visible_characters = 0
	if hint_label:
		hint_label.modulate.a = 0.25

	var char_count: int = target_label.get_parsed_text().length()
	if char_count <= 0:
		char_count = bbcode_text.length()
	_type_tween = create_tween()
	_type_tween.tween_property(target_label, "visible_characters", char_count, TYPEWRITER_SPEED * char_count)
	_type_tween.tween_callback(func():
		_finish_active_typewriter()
	)

func _finish_active_typewriter() -> void:
	if _type_tween:
		_type_tween.kill()
	_is_typing = false
	if _active_typing_label:
		_active_typing_label.visible_characters = -1
	if _in_cinematic_intro and _cinematic_hint:
		_cinematic_hint.modulate.a = 1.0
	elif _comic_next_hint:
		_comic_next_hint.modulate.a = 1.0

func _on_comic_tap() -> void:
	if not _in_comic_mode:
		return
	AudioManager.play_sfx("tap_b")
	if _is_typing:
		_finish_active_typewriter()
		return
	if _in_cinematic_intro:
		_transition_cinematic_to_comic()
		return
	_comic_step += 1
	if _comic_step < _comic_slides.size():
		_render_comic_step()
	else:
		_finish_comic_to_final_card()

func _finish_comic_to_final_card() -> void:
	_in_comic_mode = false
	_in_cinematic_intro = false
	if _type_tween:
		_type_tween.kill()
	_is_typing = false

	var panel := get_node_or_null("Panel") as Control
	if _comic_layer:
		var tw_out := create_tween()
		tw_out.tween_property(_comic_layer, "modulate:a", 0.0, 0.22)
		tw_out.tween_callback(func():
			_comic_layer.visible = false
		)

	if panel:
		panel.visible = true
		panel.modulate.a = 0.0
		panel.scale = Vector2(0.96, 0.96)
		panel.pivot_offset = panel.size * 0.5
		var tw_in := create_tween()
		tw_in.tween_interval(0.15)
		tw_in.tween_property(panel, "modulate:a", 1.0, 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw_in.parallel().tween_property(panel, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _nama_sikap(nilai: int) -> String:
	match nilai:
		GameState.SIKAP_MENOLAK: return "Menolak"
		GameState.SIKAP_ACUH: return "Acuh"
		GameState.SIKAP_RAGU: return "Ragu"
		GameState.SIKAP_PEDULI: return "Peduli"
		_: return "Acuh"

func _on_play_again() -> void:
	if not _is_good_ending and GameState.has_method("rewind"):
		GameState.rewind()
	else:
		GameState.reset()
		SceneManager.go_to_main_menu()

func _format_number(value: int) -> String:
	var text: String = str(value)
	var out: String = ""
	var count: int = 0
	for i in range(text.length() - 1, -1, -1):
		out = text[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "." + out
	return out

func _on_cards() -> void:
	if card_popup and card_popup.has_method("open_collection"):
		card_popup.open_collection()

func _on_quit() -> void:
	SceneManager.go_to_main_menu()
