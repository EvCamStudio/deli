# RANCANGAN RESTYLE: DELI REWIND → GAYA CITAMPI STORIES

Status: draf final untuk disetujui  
Target: Godot 4.7, Android landscape 16:9  
Prinsip: mengambil bahasa visual dan presentasi life-sim Citampi, **bukan menyalin aset atau kontennya**.

---

## 1. Ringkasan Keputusan

| Keputusan | Nilai |
|---|---|
| Cakupan | Konversi presentasi top-down ala Citampi |
| Aset | Pack gratis berlisensi + custom khas Medan/Deli |
| Resolusi internal | 640 × 360 |
| Tile efektif | 32 × 32 px |
| Orientasi | Landscape 16:9 |
| Cerita & mekanik | Dipertahankan |
| Genre baru | Cozy life-sim ringan, bukan romance sim |

Yang berubah: kamera, peta, tileset, sprite, kontrol, HUD, dialog, menu, audio.  
Yang dipertahankan: alur 5 level, cerita, dialog JSON, `GameState`, target kebersihan sungai, kartu edukasi, puzzle tuas, pantun, save.

---

## 2. Analisis Game Saat Ini

### 2.1 Kondisi teknis

- Godot 4.7, renderer mobile / GL Compatibility.
- Viewport 480 × 270, stretch `canvas_items`, aspect `expand`.
- Platformer side-scroll: gravitasi, lompat, kamera Y dikunci.
- Autoload: `GameState`, `DialogueManager`, `SceneManager`, `AudioManager`, `SettingsManager`.
- Level 1–4 berupa platformer, level 5 berupa epilog.
- Dialog, kartu, tipe sampah, dan level disimpan sebagai JSON.
- Seluruh visual masih `ColorRect` placeholder; folder `assets/` kosong.
- Audio masih stub; file BGM/SFX belum ada.
- UI memakai kontrol default Godot, font size hardcode, dan ikon emoji.
- `WaterArea` sudah berfungsi untuk memperlambat pemain di air.
- Save JSON menyimpan river health, sampah, pohon, mangrove, kartu, dan pilihan dialog.

### 2.2 Kekuatan yang dipertahankan

- Arsitektur autoload yang rapi dan mudah diperluas.
- Konten data-driven: dialog, kartu, level, sampah.
- Mekanik sungai yang sudah menjadi identitas game.
- Progresi `river_health` dan ending berbasis pilihan.
- Dukungan mobile: getar, volume, ukuran tombol, satu tombol Home.
- `LevelBase` sebagai kontrak antarlelvel.

### 2.3 Kesenjangan dengan gaya Citampi

| Aspek | Sekarang | Target |
|---|---|---|
| Kamera | Side-scroll, Y tetap | Top-down 3/4, follow X–Y |
| Gerak | Jalan + lompat | 4 arah, tanpa lompat |
| Visual | ColorRect | Pixel art tileset + sprite 4 arah |
| Dialog | Teks polos | Portrait + name plate + kotak krem |
| HUD | Bar tipis + emoji | Badge, jam, uang, misi, ikon pixel |
| Kontrol | 2 panah + lompat + aksi | Joystick + 1 tombol aksi |
| Menu | Daftar tombol level | Peta perjalanan Sungai Deli |
| Dunia | Linier | Peta kota/desa dengan interior |
| Suasana | Tanpa audio | BGM, ambience, SFX, waktu |
| Life-sim | Minimal | Jam/hari, uang, energi, hubungan, toko |

### 2.4 Ciri Citampi yang diadopsi

- Sudut pandang top-down 3/4 dengan tile rapat.
- Palet hangat, saturated, outline jelas.
- Karakter chibi 4 arah dengan bayangan.
- Portrait anime besar saat dialog.
- Peta yang terasa seperti kota nyata: jalan, rumah, warung, jembatan.
- HUD kehidupan: waktu, uang, energi, misi, koleksi.
- Interaksi kecil: emote bubble, suara langkah, transisi pintu.
- Mini-game dan koleksi sebagai aktivitas sampingan.

Yang **tidak** diadopsi: romance, dating, konten dewasa, dan aset khas Citampi.

---

## 3. Fondasi Teknis Baru

### 3.1 Pengaturan proyek

```ini
[display]
window/size/viewport_width=640
window/size/viewport_height=360
window/size/window_width_override=1280
window/size/window_height_override=720
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
window/handheld/orientation=1

[rendering]
renderer/rendering_method="mobile"
renderer/rendering_method.mobile="gl_compatibility"
textures/canvas_textures/default_texture_filter=0
2d/snap/snap_2d_transforms_to_pixel=true
2d/snap/snap_2d_vertices_to_pixel=true

[gui]
theme/custom="res://assets/ui/theme/citampi_theme.tres"
```

### 3.2 Skala tile

Pilih salah satu dan kunci:

- **Opsi A:** tile sumber 16 px, kamera zoom 2×. Efektif 32 px di layar. Cocok untuk pack gratis 16 px.
- **Opsi B:** tile native 32 px, kamera zoom 1×. Perlu pack 32 px atau tileset custom.

Jangan mencampur dua skala dalam satu peta. Rekomendasi: Opsi A agar bisa memakai pack gratis yang lebih banyak, dengan UI tetap native 640 × 360.

Area pandang dunia: sekitar 20 × 11 tile efektif.

### 3.3 Struktur dunia

```
World (y_sort_enabled)
├── Ground        → TileMapLayer rumput/tanah/jalan
├── Water         → TileMapLayer air + WaterArea
├── Props         → pohon, warung, tong, tuas, gerbang
├── Entities      → Player, NPC, sampah (y-sort)
├── Lighting      → CanvasModulate waktu
├── Ambience      → partikel daun, ripple, hujan
└── Camera2D
```

Aturan:
- Origin sprite karakter di kaki.
- Properti tinggi memakai `y_sort_origin`.
- Tile air memakai physics layer khusus agar bisa dideteksi `WaterArea`.
- Kamera memiliki limit per peta dan zoom integer.
- Peta level sekitar 60 × 36 tile (3 × 3 layar).

### 3.4 Kontrol

| Aksi | Keyboard | Sentuh |
|---|---|---|
| Gerak | WASD / arrow | Joystick kiri |
| Interaksi | E | Tombol aksi kanan |
| Pause | Esc | Tombol Home HUD |
| Lanjut dialog | Space / klik | Ketuk layar |

Tombol lompat dihapus. Puzzle platforming diganti ramp, jembatan, batu pijakan, dan jalur memutar.

### 3.5 Interaksi

- `InteractArea` pendek di depan pemain, bukan radius besar.
- Label kontekstual: `[E] Bicara`, `[E] Ambil`, `[E] Tanam`, `[E] Tarik`.
- Ikon tombol aksi berubah sesuai target.
- NPC menampilkan emote bubble saat punya dialog baru.

---

## 4. Arah Visual

### 4.1 Palet

| Peran | Hex |
|---|---|
| Kertas/panel | `#F6E7C1` |
| Border cokelat | `#6B4A2F` |
| Hijau daun | `#3F6F45` |
| Air sungai | `#3E8FB0` |
| Aksen emas | `#E0A33E` |
| Peringatan | `#C65B4E` |
| Teks utama | `#3A2A1E` |
| Teks terang | `#FFF8E7` |

### 4.2 Dialog

- Portrait bust kiri, tinggi 180–220 px.
- Kotak krem 9-patch di bawah, border cokelat.
- Name plate menempel di atas kotak.
- Typewriter + blip suara per karakter.
- Pilihan jawaban bergaya kartu, dengan ikon.
- Emosi portrait: netral, senang, sedih, marah, kaget.

### 4.3 HUD

- Kiri atas: badge kejernihan air + ikon tetes.
- Tengah atas: hari dan jam.
- Kanan atas: Rupiah + tombol Home tunggal.
- Kiri bawah: kartu misi aktif.
- Kanan bawah: tombol aksi kontekstual.
- Bawah kiri: joystick virtual.

Batas tinggi HUD: 36 px. Dialog: 104 px. Jangan menutupi area bermain.

### 4.4 Menu

- **Menu utama:** ilustrasi bantaran Sungai Deli, logo, papan kayu, animasi daun/air.
- **Pilih level:** peta aliran Deli Hulu → Hilir dengan pin dan status selesai.
- **Pause:** buku jurnal dengan tab Misi, Koleksi, Pengaturan, Keluar.
- **Kartu edukasi:** album kartu berbingkai, animasi flip.
- **Pantun:** panggung dengan portrait Budi dan pilihan baris bergaya kartu.
- **Ending:** kartu ilustrasi, bukan teks polos.

Semua emoji diganti ikon pixel.

---

## 5. Rencana Aset

| Kebutuhan | Spesifikasi | Sumber |
|---|---|---|
| Tileset dasar | 16 px (efektif 32), autotile 47-blob | Pack gratis CC0/OFL |
| Karakter | 16 × 24 px, 4 arah × 4 frame walk | Pack gratis + penyesuaian |
| Portrait | 512 × 512 PNG transparan, 4–6 ekspresi | Original/komisi atau AI + poles |
| UI | 9-patch margin 24–32 px, ikon 16/24 px | Custom |
| Props Medan | Warung, becak, gerobak, rumah Melayu, perahu, mangrove | Custom |
| Audio | BGM `.ogg`, SFX `.wav`, 44.1 kHz | Pack gratis + custom |
| Font | Pixel judul + rounded sans isi | OFL |

Aturan lisensi:
- Simpan lisensi di `assets/credits/`.
- Tulis `CREDITS.md`.
- Jangan meniru karakter atau UI Citampi secara langsung.
- Verifikasi lisensi setiap pack sebelum dipakai komersial.

Kandidat arah pack: Kenney (CC0) untuk base urban/UI, Ninja Adventure (CC0) untuk karakter/audio, LimeZu (berbayar, lisensi komersial) bila ada budget. Nama pack final ditentukan saat Sprint 0.

---

## 6. Rancangan Level

### Level 1 — Hulu
- Hutan, mata air, sungai kecil berkelok.
- Jembatan kayu, batu pijakan, spot tanam pohon.
- NPC penjaga hutan.
- Fokus: menanam dan memahami fungsi hutan.

### Level 2 — Desa
- Sawah, jalan kampung, saluran irigasi.
- Petani, rumah warga, warung kecil.
- Puzzle pupuk/limbah pertanian.
- Fokus: praktik pertanian yang tidak mencemari sungai.

### Level 3 — Kota Medan
- Jalan kota, warung, bantaran, jembatan, drainase.
- 4 NPC, 6 sampah, 3 tong, 3 tuas, gerbang, pantun.
- Fokus: sampah rumah tangga, drainase, gotong royong.

### Level 4 — Hilir
- Kampung pesisir, boardwalk mangrove, perahu nelayan.
- Spot tanam mangrove, NPC nelayan.
- Fokus: ekosistem pesisir dan mata pencaharian.

### Level 5 — Epilog
- Layar sinematik: kondisi sungai berdasarkan `river_health` dan pilihan.
- Tiga variasi ending: baik, biasa, buruk.
- Kartu penutup dan ajakan menjaga sungai.

### Interior
Minimal satu interior per level:
- Pos ranger (L1)
- Warung/rumah warga (L2)
- Warung kopi/toko (L3)
- Gudang nelayan (L4)

Interior dimuat sebagai scene terpisah dengan spawn point dan state di `GameState`.

---

## 7. Tahapan Pengerjaan

### Sprint 0 — Style Kit (3 hari)
- Update `project.godot`.
- Buat `citampi_theme.tres`.
- Siapkan palet, font, ikon dasar.
- Buat satu layar uji berisi player, tanah, air, dialog, HUD.
- Output: screenshot target yang disetujui.

### Sprint 1 — Controller Top-Down (5 hari)
- Tulis ulang `scripts/player.gd`.
- Sprite 4 arah, bayangan, footstep.
- Kamera follow X–Y, zoom, limit.
- Interaksi kontekstual.
- Joystick virtual + tombol aksi.
- Output: ruang uji yang bisa dijelajahi.

### Sprint 2 — Pilot Level 3 (7 hari)
- Peta 60 × 36 tile: warung, jembatan, bantaran, drainase.
- 4 NPC, 6 sampah, 3 tong, 3 tuas, gerbang, pantun.
- Dialog berportrait, HUD baru, jurnal misi.
- Output: vertical slice 10–15 menit.

Kriteria lulus pilot:
- Terasa seperti pixel life-sim, bukan platformer.
- Alur bicara → ambil → pilah → tuas → pantun → selesai berjalan.
- 60 FPS di perangkat menengah.
- Nyaman dimainkan satu tangan.

Jika belum lulus, perbaiki style kit sebelum lanjut.

### Sprint 3 — Peta Lainnya (10 hari)
- L1, L2, L4, L5.
- Interior.
- Siklus waktu, hujan, partikel.
- Transisi pintu dan spawn.
- Output: seluruh alur game dapat dimainkan.

### Sprint 4 — UI & Menu (7 hari)
- Menu utama, peta level, pause jurnal, koleksi kartu, pengaturan.
- Toast misi, notifikasi kartu, indikator sampah.
- Cutscene kecil: judul bab, pan kamera, dialog pembuka.
- Output: UI konsisten tanpa kontrol default.

### Sprint 5 — Life-sim, Audio, QA (6–8 hari)
- Jam/hari, Rupiah, energi opsional.
- Toko upgrade.
- Hati hubungan NPC.
- Simpan di rumah + auto-save.
- BGM, ambience, SFX.
- Uji Android, save lama, berbagai rasio layar.
- Output: release candidate.

Total inti: sekitar 38–45 hari kerja. Life-sim dapat ditunda.

---

## 8. Perubahan File

| File/Area | Perubahan |
|---|---|
| `project.godot` | Resolusi, theme, input, pixel snap |
| `scripts/player.gd` | Ditulis ulang top-down |
| `scenes/player/player.tscn` | Sprite, bayangan, collision |
| `scripts/level_base.gd` | Kamera X–Y, spawn, transisi |
| `scenes/levels/*.tscn` | Dibangun ulang dengan TileMapLayer |
| `scenes/ui/hud.tscn` | HUD baru |
| `scenes/ui/dialogue_box.tscn` | Portrait + name plate |
| `scenes/ui/touch_controls.tscn` | Joystick + tombol aksi |
| `scenes/ui/pause_menu.tscn` | Jurnal bertab |
| `scenes/main_menu/main_menu.tscn` | Key art + papan kayu |
| `data/dialogues/*.json` | Field portrait/emotion/sfx |
| `data/characters.json` | Profil NPC, portrait, hubungan |
| `data/items.json` | Sampah, alat, toko |
| `autoload/time_manager.gd` | Baru: jam/hari |
| `autoload/quest_manager.gd` | Baru: misi (opsional) |
| `scripts/ui/virtual_joystick.gd` | Baru |
| `scripts/ui/portrait_dialogue.gd` | Baru |
| `scripts/world/map_transition.gd` | Baru |
| `assets/fonts/` | Font OFL |
| `assets/sprites/` | Karakter, props, portrait |
| `assets/tilesets/` | TileSet + autotile |
| `assets/ui/` | Theme, 9-patch, ikon |
| `assets/audio/` | BGM, SFX, ambience |

---

## 9. Skema Data

### 9.1 Dialog

```json
{
  "id": "start",
  "speaker": "Pak Pedagang",
  "portrait": "pak_pedagang",
  "emotion": "sedih",
  "text": "Dulu sungai ini jernih, Nak...",
  "sfx": "sigh",
  "choices": [
    {
      "text": "Kenapa sekarang kotor?",
      "next": "why",
      "effect": { "river_health": 0 }
    }
  ]
}
```

Path portrait: `res://assets/sprites/portraits/{id}_{emotion}.png`.

### 9.2 Karakter

```json
{
  "pak_pedagang": {
    "name": "Pak Pedagang",
    "portrait": "pak_pedagang",
    "voice_pitch": 0.9,
    "role": "Pedagang pasar",
    "relationship": 0
  }
}
```

### 9.3 Save versi 2

Field baru:
- `save_version`
- `rupiah`
- `day`
- `minutes`
- `energy`
- `relationships`
- `inventory`
- `tool_level`
- `quests`

Field lama tetap dibaca dengan default agar save eksisting tidak rusak.

---

## 10. Life-sim Ringan

Opsional, dikerjakan setelah pilot lulus.

- Jam 06.00–24.00, waktu berhenti saat menu/dialog.
- Satu hari dalam game sekitar 15–20 menit nyata.
- Uang dari sampah, misi, dan kartu.
- Energi sebagai pembatas lembut, bukan fail state.
- Toko menjual upgrade: sepatu cepat, jaring, tas sampah.
- Hati hubungan NPC bertambah saat bicara/berbuat baik.
- Tidur di rumah untuk menyimpan.
- Pohon bertumbuh antar-hari.
- Cuaca hujan memengaruhi sungai dan NPC.

Fokus tetap edukasi; life-sim adalah bumbu, bukan tujuan utama.

---

## 11. Audio

| Kebutuhan | Arah |
|---|---|
| Menu | Akustik hangat, gamelan ringan |
| Hulu | Ambient hutan, burung, air |
| Desa | Gamelan akustik, sawah |
| Kota | Jalan ramai, klakson jauh, pasar |
| Hilir | Ombak, angin, burung laut |
| Epilog | Piano lembut |
| SFX | Langkah per material, pungut, tuas, pintu, UI, kartu, level selesai |
| Voice blip | Nada pendek per karakter saat typewriter |

---

## 12. Risiko & Mitigasi

| Risiko | Mitigasi |
|---|---|
| Aset tidak seragam | Satu palet, satu skala, aturan recoloring |
| Tile 16 px terlalu kecil | Kamera zoom 2×; uji komposisi 20 × 11 |
| Rebuild level memakan waktu | Pilot L3 dulu, baru peta lain |
| UI terlalu padat | HUD 36 px, dialog 104 px, portrait 180 px |
| Performa mobile | Atlas, batasi partikel, Y-sort hanya entitas |
| Lisensi aset | Catat lisensi sejak Sprint 0 |
| Save lama rusak | `save_version` + default value |
| Scope creep | Life-sim dikunci sebagai fase opsional |
| Kemiripan dengan Citampi | Ambil prinsip desain, bukan aset/karakter |

---

## 13. QA & Definisi Selesai

Checklist:
- [ ] Tidak ada kontrol/emoji default Godot.
- [ ] Semua scene memakai theme global.
- [ ] Dialog memiliki portrait dan name plate.
- [ ] HUD menampilkan kejernihan, misi, jam, uang.
- [ ] Joystick dan tombol aksi berfungsi di Android.
- [ ] Keyboard WASD/arrow + E berfungsi.
- [ ] Alur 5 level selesai tanpa error.
- [ ] Air memperlambat pemain dan memicu ripple.
- [ ] Sampah bisa diambil, dipilah, dan menambah river health.
- [ ] Tuas, gerbang, pantun, dan kartu berfungsi.
- [ ] Save/load kompatibel.
- [ ] 60 FPS di perangkat menengah.
- [ ] Tidak ada aset tanpa lisensi.
- [ ] `CREDITS.md` lengkap.

Definisi selesai:
- Sekali lihat terasa seperti cozy pixel life-sim.
- Cerita dan nilai edukasi tetap utuh.
- Nyaman dimainkan di ponsel dan desktop.
- Tidak ada placeholder ColorRect di build final.

---

## 14. Langkah Berikutnya

1. Setujui dokumen ini.
2. Jalankan Sprint 0: style kit + satu layar uji.
3. Bangun pilot Level 3.
4. Review screenshot dan feel sebelum membangun ulang semua level.
5. Lanjutkan Sprint 3–5.

Catatan: implementasi kode dilakukan setelah keluar dari Plan mode.
