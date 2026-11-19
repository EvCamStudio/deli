extends Node

const NPCS = [
	{
		"speaker": "Penjaga Hutan",
		"teks": "Hutan ini adalah benteng utama hulu Deli. Jika pepohonan di sini lestari, air sungai akan jernih sampai ke hilir.",
		"portrait": "penjaga_hutan",
		"filename": "dialogue_penjaga_hutan.png"
	},
	{
		"speaker": "Pak Darwis",
		"teks": "Kasur busa ini memang sudah lapuk, nak. Tapi kalau dibuang ke sungai, airnya akan tersumbat dan meluap ke desa.",
		"portrait": "petani",
		"filename": "dialogue_pak_darwis.png"
	},
	{
		"speaker": "Pemilik Toko",
		"teks": "Selamat datang di Toko Jaya! Toko kami mendukung pelestarian lingkungan dengan menyediakan bibit pohon dan jeriken jelantah.",
		"portrait": "pemilik_toko",
		"filename": "dialogue_pemilik_toko.png"
	},
	{
		"speaker": "Kak Rina",
		"teks": "Minyak jelantah dari gorengan jangan dibuang ke parit ya. Nanti bisa kita kumpulkan ke bank jelantah desa!",
		"portrait": "kak_rina",
		"filename": "dialogue_kak_rina.png"
	},
	{
		"speaker": "Pemuka Desa",
		"teks": "Alhamdulillah, warga desa kini mengerti pentingnya menjaga kebersihan sungai. Terima kasih atas kepedulianmu, nak.",
		"portrait": "pemuka_desa",
		"filename": "dialogue_pemuka_desa.png"
	},
	{
		"speaker": "Bang Jali",
		"teks": "Gerobak sampah ini mantap betul, nak! Sekarang warga gang tidak perlu buang sampah sembarangan ke selokan lagi.",
		"portrait": "pedagang",
		"filename": "dialogue_bang_jali.png"
	},
	{
		"speaker": "Ibu Rumah Tangga",
		"teks": "Aliran selokan di depan rumah sekarang lancar dan tidak ada bau limbah menyengat lagi. Anak-anak jadi sehat!",
		"portrait": "ibu_rumah",
		"filename": "dialogue_ibu_rumah.png"
	},
	{
		"speaker": "Budi",
		"teks": "Kakak hebat sekali! Pantun Melayu Deli ternyata punya pesan bijak untuk menjaga sungai dan alam kita ya!",
		"portrait": "budi",
		"filename": "dialogue_budi.png"
	},
	{
		"speaker": "Pak RT",
		"teks": "Koordinasi warga dan tempat pembuangan sampah terpadu kini sudah tertata rapi di lingkungan rukun tetangga kita.",
		"portrait": "pakrt",
		"filename": "dialogue_pak_rt.png"
	},
	{
		"speaker": "Pak Nelayan",
		"teks": "Air muara sudah jauh lebih bersih. Jala kami tidak lagi tersangkut plastik kotor, hasil tangkapan pun melimpah!",
		"portrait": "nelayan",
		"filename": "dialogue_pak_nelayan.png"
	},
	{
		"speaker": "Penjaga Sungai",
		"teks": "Pos pantau hilir melaporkan indeks kualitas air Deli terus membaik. Pengawasan pintu air tetap kami siagakan penuh.",
		"portrait": "penjaga_sungai",
		"filename": "dialogue_penjaga_sungai.png"
	}
]

func _ready() -> void:
	GameState.player_name = "Yura"
	var dlg_scene := preload("res://scenes/ui/portrait_dialogue.tscn")
	var dlg = dlg_scene.instantiate()
	add_child(dlg)
	_run(dlg)

func _run(dlg) -> void:
	var base_dir := "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8"
	for npc in NPCS:
		dlg.show_node({
			"speaker": npc["speaker"],
			"teks": npc["teks"],
			"portrait": npc["portrait"],
			"emotion": "neutral"
		})
		await _frames(6)
		var img: Image = get_viewport().get_texture().get_image()
		var out_path: String = base_dir + "/" + npc["filename"]
		img.save_png(out_path)
		print("Saved " + npc["filename"])
	get_tree().quit(0)

func _frames(n: int) -> void:
	for _i in range(n):
		await get_tree().process_frame

