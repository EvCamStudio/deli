# Rancangan Alur Game - Deli Rewind (v2.1)

Game pixel top-down (Godot, Android) bertema pelestarian Sungai Deli, Medan, dengan isu lingkungan dan kearifan lokal. Pemain menelusuri sungai dari hulu ke hilir sambil menanam pohon, memilah sampah, dan mengumpulkan kartu pengetahuan.

## Ringkasan Perubahan dari v2.0

### Perbaikan Inti (fokus eksekusi)
- **Quest gating per NPC:** setiap NPC punya misi berbeda; tanam pohon/mangrove dan pilah sampah terkunci sampai NPC terkait diajak bicara.
- **Mission counter real-time:** mission card menampilkan angka nyata (`Pohon: 3/5`, `Sampah: 8/10`, `Warga: 2/4`), bukan teks statis.
- **Sampah tersebar:** patokan bukan jarak dari spawn MC, tapi sebaran kluster yang wajar dan maks. 10 tile dari tong.
- **Tong tidak menjauhkan pemain:** tong diletakkan dekat area sampah, bukan di ujung level.
- **Sungai konsisten:** lebar 4 tile, tepi pasir 1 tile, jembatan di PATH_ROW; tidak ada pohon/sampah/NPC/tong di air.
- **Save/Continue/Reset dibakukan:** Main Lagi menghapus `save.json`; Lanjut memuat level terakhir; save corrupt tidak membuat tombol diam.

### Perbaikan UX & Onboarding
- **Mission card diperbaiki:** judul + progress + lokasi, maksimal 250×72px.
- **Visual guidance:** highlight/arrow mengarah ke NPC/tong/objek interaktif yang relevan (opsional, setelah inti stabil).
- **Feedback diperkuat:** toast singkat 1–2 baris, warna sesuai hasil, reward jelas, tidak menumpuk.
- **Tutorial interaktif Level 1:** step-by-step, bisa diskip (opsional).

### Konsistensi Level Design
- **Jalur tanah aligned:** jalur dari pintu rumah ke jalan utama sejajar dengan door sprite.
- **NPC placement konsisten:** semua NPC di depan bangunan, jarak interaksi 2–3 tile.

### Polish UI & Content
- **Dialog Ibu level 1 diperluas:** 3 node conversation dengan pilihan.
- **Quest description lebih jelas:** "Bicara dengan Penjaga Hutan di dekat mata air", bukan "Bicara dengan NPC".
- **Toast lebih informatif:** "Tanam pohon berhasil! (3/5) +Rp500".
- **Sprite nelayan khas:** caping jerami, kemeja navy, berbeda dari player.

---

## Alur Utama Gameplay

### Level 1 - Hulu (Hutan & Mata Air) - Tutorial

**Lokasi:** Kawasan hutan di hulu Sungai Deli

**Misi Utama:**
- Ikuti tutorial interaktif (gerak, interact, UI)
- Bicara dengan Ibu di depan rumah (intro cerita)
- Bicara dengan Penjaga Hutan di dekat mata air (quest)
- Tanam 5 pohon di titik tanam yang ditandai
- Menuju gerbang desa setelah semua pohon tertanam

**Tutorial Interaktif (Step-by-Step):**
1. **Kontrol Gerak:** Arrow/highlight muncul di joystick virtual, tooltip: "Geser untuk bergerak"
2. **Mendekati Objek:** Arrow mengarah ke Ibu di depan rumah, tooltip: "Dekati Ibu"
3. **Interaksi:** Tombol "Bicara" muncul saat dekat Ibu, tooltip: "Tekan untuk bicara"
4. **Dialog & Quest:** Setelah dialog Ibu selesai, arrow mengarah ke Penjaga Hutan, tooltip: "Temui Penjaga Hutan di mata air"
5. **Tanam Pohon:** Arrow mengarah ke tree spot terdekat, tooltip: "Dekati tanah bertanda, tekan Tanam"
6. **Progress Update:** Setelah pohon pertama, toast: "Pohon pertama selesai! (1/5)", lalu arrow mengarah ke spot berikutnya
7. **Gerbang:** Setelah 5 pohon, arrow mengarah ke gerbang timur, tooltip: "Menuju Desa"

**Mekanik:**
- Top-down movement
- **Quest gating:** tree spot terkunci sampai pemain bicara dengan Penjaga Hutan. Jika mencoba menanam sebelumnya, toast: "Bicara dulu dengan Penjaga Hutan di dekat mata air."
- Interaksi dengan tree spot, lalu pohon tertanam dengan animasi tumbuh + confetti
- Setiap pohon: +4 river health, +Rp500, counter quest naik
- Mission card update real-time: "🌳 Pohon: 3/5"
- 5 pohon tertanam, toast: "Hutan kembali hijau! +Rp1.000", gate terbuka

**Counter (sumber data nyata):**
- `trees_planted` (sudah ada di GameState) — bukan teks statis
- Update dipanggil setiap kali pohon berhasil ditanam

**Reward:**
- +Rp500 per pohon (total Rp2.500)
- +Rp1.000 bonus selesai quest (total Rp3.500)
- +20 river health (5 pohon × 4)
- Kartu: `card_hutan_01`, `card_sungai_deli_01`

**NPC:**
- Ibu (rumah di x=112,232): dialog pengantar, tanpa quest
- Penjaga Hutan (mata air di x=168,244): quest `tanam_pohon_hulu`

**Spawn:**
- Player start: `(64, 272)` (depan rumah Ibu)
- Tree spots: 5 lokasi di area hutan, tidak di air, jauh dari bangunan
- Gate: `(912, 264)` (ujung timur)

**Mission Card:**
```
MISI: Tanam Pohon Hulu
━━━━━━━━━━━━━━━━━━━━━
🌳 Pohon: 3/5
━━━━━━━━━━━━━━━━━━━━━
📍 Hutan dekat mata air
```
- Sebelum bicara Penjaga Hutan: baris progress menampilkan "🔒 Bicara Penjaga Hutan dulu"
- Setelah bicara: baris berubah menjadi counter pohon

---

### Level 2 - Desa (Pertanian & Pemukiman) - Pengenalan Pilah Sampah

**Lokasi:** Desa di tengah aliran sungai

**Misi Utama:**
- Bicara dengan Pak Tani (depan warung, x=136,236)
- Bicara dengan Ibu Desa (depan rumah, x=480,236)
- Pilah 10 sampah ke tong yang benar (organik/plastik)

**Mekanik:**
- Top-down movement
- **Quest gating:** sampah baru bisa dipilah setelah bicara dengan Pak Tani (`pilah_desa`). Sebelum itu, bin menampilkan toast: "Bicara dulu dengan Pak Tani di depan warung."
- Pickup sampah, HUD update: "Dibawa: 2 Organik"
- 2 tong: organik (x=200,272), plastik (x=400,272)
- Arrow menunjuk ke tong terdekat saat membawa sampah
- Label tong tampil (hijau "ORGANIK", kuning "PLASTIK")
- **Counter real-time:** `Sampah: x/10` dan `Warga: x/2` di mission card

**Guidance:**
- Setelah bicara dengan NPC, arrow mengarah ke sampah terdekat
- Saat membawa sampah organik, arrow ke tong organik (bukan plastik)
- Toast saat salah tong: "Sampah diterima +Rp1.500 | Tip: sampah organik cocok di tong hijau"

**Reward:**
- Rp1.500 + 3 river health per sampah (base)
- Bonus bin benar: +Rp500 + 2 river health + fakta edukasi
- Total optimal: Rp20.000 (10 × Rp2.000) + 50 river health
- Kartu: `card_pertanian_01`, `card_gotong_royong_01`

**Sampah:** 6 organik, 4 plastik — tersebar dalam 4–5 kluster di area desa, tiap kluster maks. 10 tile dari salah satu tong.

**NPC:**
- Pak Tani (warung): quest `pilah_desa` + kartu pertanian
- Ibu Desa (rumah): quest `gotong_royong` + kartu gotong royong + bonus Rp1.500 setelah bicara 2 NPC

**Mission Card:**
```
MISI: Bersihkan Desa
━━━━━━━━━━━━━━━━━━━━━
💬 Warga: 1/2
🗑️ Sampah: 6/10
━━━━━━━━━━━━━━━━━━━━━
📍 Tong di sepanjang jalan
```

---

### Level 3 - Kota (Urbanisasi & Industri) - Pilah Sampah + Puzzle Drainase

**Lokasi:** Area perkotaan dengan drainase dan saluran air

**Misi Utama:**
- Bicara dengan 4 NPC (pedagang, ibu rumah, anak sekolah, tokoh masyarakat)
- Pilah 6 sampah ke 3 tong (organik, plastik, B3)
- Selesaikan mini-game pantun (opsional, bonus)
- Selesaikan puzzle lever drainase (1-3-2) agar gate terbuka

**Mekanik:**
- Top-down + puzzle drainase
- 3 kategori sampah, 3 tong (organik di x=216, plastik x=544, B3 x=752)
- Label tong tampil dengan warna (hijau, kuning, merah)
- Arrow menunjuk tong sesuai kategori sampah yang dibawa
- **Quest gating:** sampah terkunci sampai bicara Pedagang (`pilah_kota`); lever terkunci sampai bicara Tokoh Masyarakat (`drainase_kota`)
- Puzzle lever: tekan tuas 1 → 3 → 2 (urutan ditampilkan di mission card)
- Hint NPC: setelah 3 kali salah, NPC memberi petunjuk dialog
- **Counter real-time:** `Warga: x/4`, `Sampah: x/6`, `Tuas: x/3`

**Guidance:**
- Arrow mengarah ke NPC terdekat yang belum bicara
- Arrow mengarah ke sampah terdekat setelah semua NPC bicara
- Arrow mengarah ke lever 1 setelah sampah selesai
- Tooltip di lever: "Tekan untuk tarik tuas"
- Feedback visual: lever bergerak, SFX, toast "Tuas 1 ditarik (1/3)"

**Puzzle Lever Drainase:**
- 3 lever: tuas 1 (x=816), tuas 2 (x=912), tuas 3 (x=864)
- Urutan benar: 1 → 3 → 2
- Salah: lever reset, toast "Urutan salah! Mulai dari tuas 1"
- Benar: gate terbuka, air mengalir (animasi), +Rp2.500, +10 river health

**Reward:**
- Rp1.500 + 3 health per sampah (base)
- Bonus bin benar: +Rp500 + 2 health
- Bonus puzzle: +Rp2.500 + 10 health
- Bonus pantun (opsional): +Rp2.000 + 8 health
- Total optimal: ~Rp20.000 + 60 health
- Kartu: `card_kota_01`, `card_industri_01`, `card_drainase_01`, `card_pantun_01` (opsional)

**Sampah (6 item):**
- 2x organik (kulit pisang, daun kering)
- 3x plastik (botol, kantong, kaleng)
- 1x B3 (baterai bekas)

**NPC:**
- Pedagang (x=136,160): quest `pilah_kota` + kartu kota
- Ibu Rumah (x=480,160): quest `edukasi_industri` + kartu industri
- Anak Sekolah (x=320,184): quest `pantun_kota` (opsional) + trigger pantun board
- Tokoh Masyarakat (x=700,184): quest `drainase_kota` + hint puzzle lever

**Mission Card:**
```
MISI: Buka Drainase Kota
━━━━━━━━━━━━━━━━━━━━━
💬 Warga: 2/4
🗑️ Sampah: 4/6
🔧 Tuas: 1-3-2
```

---

### Level 4 - Hilir (Pesisir & Mangrove)

**Lokasi:** Muara sungai dan hutan mangrove

**Misi Utama:**
- Bicara dengan Nelayan (x=200,236) dan Penjaga Sungai (x=680,236)
- Pilah 10 sampah (plastik + organik) ke 2 tong
- Tanam 8 mangrove di titik tanam pesisir

**Mekanik:**
- Top-down movement
- Pickup sampah, HUD: "Dibawa: X (Kategori)"
- 3 tong: organik (x=360), plastik (x=500), B3 (x=640)
- Arrow menunjuk tong sesuai kategori
- Tree spot mangrove di tepian pantai (8 spot)
- **Quest gating:** sampah terkunci sampai bicara Nelayan (`pilah_hilir`); mangrove terkunci sampai bicara Penjaga Sungai (`tanam_mangrove`). Toast jika belum: "Bicara dulu dengan Penjaga Sungai."
- **Counter real-time:** `Warga: x/2`, `Mangrove: x/8`, `Sampah: x/10`

**Guidance:**
- Arrow ke NPC terdekat yang belum bicara
- Arrow ke sampah/mangrove spot terdekat setelah NPC bicara
- Tooltip: "Dekati mangrove spot → Tekan Tanam"

**Reward:**
- Rp1.500 + 3 health per sampah
- Bonus bin benar: +Rp500 + 2 health
- Rp2.000 + 5 health per mangrove
- Total optimal: ~Rp36.000 + 90 health
- Kartu: `card_mangrove_01`, `card_pesisir_01`, `card_nelayan_01`

**Sampah (10 item):**
- 4x organik (sisa sayur, daun kering, kulit pisang, ranting)
- 5x plastik (botol, kantong, sedotan, kaleng, kardus)
- 1x B3 (baterai bekas)
- Tersebar dalam 4–5 kluster di pesisir, tidak menumpuk di satu titik

**NPC:**
- Nelayan (rumah pantai, sprite caping jerami): quest `pilah_hilir` + kartu nelayan
- Penjaga Sungai (area timur): quest `tanam_mangrove` + kartu pesisir

**Mission Card:**
```
MISI: Pulihkan Pesisir
━━━━━━━━━━━━━━━━━━━━━
💬 Warga: 1/2
🌱 Mangrove: 5/8
🗑️ Sampah: 7/10
```

---

### Level 5 - Epilog

**Lokasi:** Cutscene/narrative ending

**Isi:**
- Kilas balik perjalanan hulu ke hilir (slideshow 4 scene)
- Ringkasan pemain: pohon ditanam, sampah dipilah, kartu terkumpul, total Rupiah
- Ending ditentukan oleh `river_health` akhir:

| River Health | Ending | Visual | Narasi |
|---|---|---|---|
| 0-39 | Sungai Masih Berjuang | Sungai keruh, warga khawatir | Air mulai membaik, tapi masih butuh banyak perawatan. Mari coba lagi! |
| 40-74 | Sungai Mulai Pulih | Sungai mulai jernih, ikan kembali | Air mulai jernih, warga mulai peduli. Sungai Deli bangkit! |
| 75-100 | Deli Kembali Hidup | Sungai jernih, warga & anak kecil main air | Sungai jernih, warga dan alam kembali akrab dengan Sungai Deli. Kamu pahlawan! |

- Tampilkan koleksi kartu pengetahuan (galeri) + badge "HULU KE HILIR"
- Opsi: "Main Lagi" (reset) atau "Lihat Kartu" (galeri)

**Stats Panel:**
```
════════════════════════
   PERJALANAN SELESAI
════════════════════════
Pohon Ditanam:      13
Mangrove Ditanam:    8
Sampah Terpilah:    36
Kejernihan Sungai:  82%
Kontribusi:      Rp79.500
Kartu Terkumpul:  10/10
════════════════════════
```

---

## Save, Continue & Reset (WAJIB BENAR)

Tiga tombol harus konsisten satu sama lain:

### Simpan
- Auto-save setiap kali level selesai (`complete_level`) dan setiap quest selesai.
- Isi save: `river_health`, `trees_planted`, `mangroves_planted`, `trash_collected`, `levels_completed`, `collected_cards`, `active_quests`, `current_level`.
- File: `user://save.json`.

### Lanjut (Main Menu)
- Tombol **Lanjut** aktif hanya jika `has_save()` true.
- Jika save corrupt/kosong: tampilkan toast "Save tidak bisa dimuat. Mulai baru?" dan jangan crash.
- Setelah `load_game()` sukses: masuk ke `current_level`, bukan selalu level 1.
- Jangan biarkan tombol terlihat aktif tapi tidak melakukan apa-apa.

### Main Lagi (Epilog)
- `GameState.reset()` **harus menghapus** `user://save.json` di disk, bukan hanya state memori.
- Setelah reset: `has_save()` harus false, jadi tombol Lanjut disabled sampai pemain menyelesaikan level lagi.
- Baru setelah itu pindah ke Level 1.

### Aturan
- `reset()` = state memori bersih + file save terhapus.
- `has_save()` = file save ada **dan** valid JSON.
- Tidak ada dua sumber kebenaran: HUD selalu baca dari `GameState`, bukan variabel lokal level.

---

## Sistem Pilah Sampah

### Kategori Sampah
1. **Organik** (hijau): sisa makanan, daun, ranting
2. **Plastik** (kuning): botol, kantong plastik, kemasan
3. **B3** (merah): baterai bekas, kaleng cat (level 3-4)

### Alur Interaksi
1. Pemain mendekati sampah, arrow muncul + prompt "Ambil"
2. Tekan interact, sampah masuk `pending_trash`, animasi pickup
3. HUD update: "Dibawa: 2 Organik" (kategori dari sampah pertama)
4. Arrow menunjuk ke tong kategori yang sesuai
5. Pemain mendekati bin, prompt "Pilah" + highlight bin
6. Tekan interact pada bin:
   - **Bin sesuai kategori:** +Rp2.000, +5 health, toast fakta edukasi, confetti
   - **Bin tidak sesuai:** +Rp1.500, +3 health, toast petunjuk ringan, tanpa confetti
7. Sampah hilang dari `pending_trash`, HUD reset

### Contoh Toast
- **Benar:** "Tepat! Sampah organik dipilah. +Rp2.000 | Organik jadi kompos dalam 3-6 bulan."
- **Kurang tepat:** "Sampah diterima. +Rp1.500 | Tip: sampah organik cocok di tong hijau!"

### Aturan Toast (WAJIB)
- **Maksimal 2 baris**, font Pixelify 10px, padding 8px.
- **Durasi 2.5 detik**, fade out 0.2s; tidak perlu tombol tutup.
- **Warna:** hijau = sukses/benar, kuning = info/kurang tepat, merah = gagal/terkunci.
- **Selalu sertakan reward** jika ada: "+Rp2.000", "+3 health", "(3/5)".
- **Tidak menumpuk:** toast baru menggantikan toast lama (satu panel saja). Jika ada antrean, tampilkan berurutan dengan jeda 0.3s.
- **Muncul setelah interaksi selesai**, bukan saat mendekat.
- **Tidak menutupi HUD atas** — posisi bottom-center, maks. 2 baris.

### Toast per Kejadian
| Kejadian | Warna | Contoh |
|---|---|---|
| Ambil sampah | kuning | "Sampah diambil: organik" |
| Buang ke tong benar | hijau | "Tepat! +Rp2.000 +5 health" |
| Buang ke tong lain | kuning | "Diterima +Rp1.500 | Coba tong hijau" |
| Tanam pohon | hijau | "Pohon ditanam! (3/5) +Rp500" |
| Aksi terkunci | merah | "Bicara dulu dengan Penjaga Hutan" |
| Quest selesai | hijau | "Misi selesai! +Rp1.000" |

### Perilaku Bin
- **Visual:** sprite per kategori + label berwarna di atas bin
- **Label:** "ORGANIK" (hijau), "PLASTIK" (kuning), "B3" (merah)
- **Collision:** Area2D, radius 32px
- **Feedback:** bump animation, SFX (`correct` atau `accepted`), toast, haptic
- **Highlight:** outline glow saat arrow menunjuk

### Alasan Desain
- Pemain tidak dihukum (tetap ramah), tapi bonus memberi makna
- Arrow guidance mengurangi trial-and-error
- Label & warna membantu pembelajaran kategori
- Fakta edukasi muncul saat benar untuk reinforce positive behavior

---

## Visual Guidance System (NEW)

### Arrow Pointer
- Sprite: panah kuning/putih, animasi bounce
- Posisi: di atas/samping objek target
- Muncul saat:
  - Tutorial step aktif
  - Quest memerlukan interaksi dengan objek spesifik
  - Pemain idle >10 detik tanpa progress
- Hilang saat: objek diinteraksi atau quest progress update

### Highlight Effect
- Outline glow putih/kuning di sekitar objek interaktif
- Pulse animation (opacity 0.5 ↔ 1.0)
- Muncul saat: arrow menunjuk atau pemain dekat (<48px)

### Tooltip System
- Panel kecil di atas objek
- Font: Pixelify 10px
- Background: semi-transparan hitam
- Contoh: "Tekan A untuk tanam pohon"

### Feedback Visual
- **Quest Complete:** confetti particle, SFX fanfare, screen flash hijau
- **Reward Pickup:** coin/heart float up, SFX coin
- **Save Game:** ikon floppy disk di pojok kanan atas, fade out 2 detik
- **Wrong Action:** screen shake ringan, SFX buzz

---

## Mission Card System (UPGRADED)

### Format Baru (Ringkas — Muat di HUD)
Mission card harus tetap kecil dan tidak menutupi layar. Maksimal **3 baris progress + 1 baris hint**:
```
╔══════════════════════════════╗
║ MISI: [Judul Quest]          ║
╠══════════════════════════════╣
║ 🌳 Pohon: 3/5                ║
║ 🗑️ Sampah: 8/10              ║
╠══════════════════════════════╣
║ 📍 Hutan dekat mata air      ║
╚══════════════════════════════╝
```
- **Ukuran:** 250×72px (bukan 56px, karena butuh 4 baris). Tetap di pojok kiri atas, di bawah top bar.
- **Font:** Pixelify 10px body, 9px judul.
- **Baris hint:** hanya tampil jika quest punya instruksi khusus (mis. urutan tuas). Jika tidak, card cukup 3 baris (judul + 2 progress).
- **Jangan tampilkan semua step sekaligus:** tampilkan hanya step yang sedang aktif + step yang sudah selesai. Step terkunci tidak perlu ditampilkan (menghemat ruang).

### Contoh Real
**Level 1:**
```
MISI: Tanam Pohon Hulu
━━━━━━━━━━━━━━━━━━━━━
🌳 Pohon: 3/5
━━━━━━━━━━━━━━━━━━━━━
📍 Hutan dekat mata air
```

**Level 3:**
```
MISI: Buka Drainase Kota
━━━━━━━━━━━━━━━━━━━━━
💬 Bicara warga: 2/4
🗑️ Sampah: 4/6
🔧 Tuas: 1-3-2
```

### Update Logic
- Real-time saat progress berubah
- Animasi slide/fade saat update
- Warna: hijau saat step selesai, putih saat aktif, abu saat locked
- Angka progress **selalu** diambil dari counter nyata (`_sorted`, `trees_planted`, `_talked.size()`), bukan teks statis

---

## Quest Gating per NPC (NEW)

Setiap NPC punya misi sendiri. Aksi hanya terbuka setelah NPC terkait diajak bicara. Ini mencegah pemain menanam pohon/mangrove atau memilah sampah tanpa konteks cerita.

### Aturan
1. **Satu NPC = satu quest.** NPC menyimpan `quest_id` unik dan flag `quest_given`.
2. **Aksi terkunci sampai quest diberikan.** Contoh: `TreeSpotTopDown` menolak tanam jika `GameState.has_quest("tanam_pohon_hulu") == false`, lalu menampilkan toast: "Bicara dulu dengan Penjaga Hutan di dekat mata air."
3. **Quest aktif muncul di mission card.** Setelah bicara, quest masuk daftar aktif dan counter mulai berjalan.
4. **Beberapa quest bisa aktif bersamaan.** Mission card menampilkan maksimal 2 quest aktif; sisanya diakses lewat jurnal/menu.
5. **NPC berbeda, misi berbeda.** Tidak ada satu NPC yang memberi semua misi.

### Tabel Quest per Level
Setiap NPC memberi misi berbeda. Misi boleh saling terkait, tapi tidak ada NPC yang memberi semua misi.

| Level | NPC | Quest ID | Aksi yang Dibuka | Counter |
|---|---|---|---|---|
| 1 | Ibu | `intro_hulu` | (dialog pengantar, tanpa aksi) | — |
| 1 | Penjaga Hutan | `tanam_pohon_hulu` | Tanam pohon | `Pohon: x/5` |
| 2 | Pak Tani | `pilah_desa` | Pilah sampah organik/plastik | `Sampah: x/10` |
| 2 | Ibu Desa | `gotong_royong` | Bonus setelah bicara 2 NPC | `Warga: x/2` |
| 3 | Pedagang | `pilah_kota` | Pilah sampah kota | `Sampah: x/6` |
| 3 | Ibu Rumah | `edukasi_industri` | Buka kartu industri + tips B3 | `Kartu: x/1` |
| 3 | Anak Sekolah | `pantun_kota` | Buka mini-game pantun (opsional) | `Pantun: x/1` |
| 3 | Tokoh Masyarakat | `drainase_kota` | Tarik tuas drainase | `Tuas: x/3` |
| 4 | Nelayan | `pilah_hilir` | Pilah sampah pesisir | `Sampah: x/10` |
| 4 | Penjaga Sungai | `tanam_mangrove` | Tanam mangrove | `Mangrove: x/8` |

**Aturan misi opsional:** `pantun_kota` dan `edukasi_industri` tidak menghalangi gate. Jika pemain melewatinya, level tetap bisa selesai.

### Implementasi Minimal (efisien, tanpa dua sumber data)
- `GameState.active_quests: Dictionary` → `quest_id: target_int` (contoh: `{"tanam_pohon_hulu": 5}`).
- Progress **tidak** disimpan di quest; progress dibaca dari counter nyata yang sudah ada (`trees_planted`, `mangroves_planted`, `trash_collected`, `_talked`).
- `QuestManager.start_quest(id, target)` dipanggil dari dialog NPC dan mengisi `active_quests`.
- `TreeSpotTopDown`/`TrashBin`/`Lever` cek `GameState.active_quests.has(id)` sebelum mengizinkan aksi.
- HUD membentuk string `Pohon: %d/%d` dari counter + target. Tidak ada variabel progress terpisah.
- Tidak perlu sistem quest tree kompleks; cukup flag + target + counter yang sudah ada.

### Toast Quest
- Quest baru: "Misi baru: Tanam 5 pohon di area hutan."
- Quest selesai: "Misi selesai: Hutan kembali hijau! +Rp1.000"
- Aksi terkunci: "Bicara dulu dengan Penjaga Hutan."

---

## Level Design Standards (NEW)

### Sungai & Air (WAJIB KONSISTEN)
- **Lebar sungai:** 4 tile (64px) konsisten semua level
- **Tepi pasir:** 1 tile (16px) di kiri-kanan air
- **Jembatan:** tile bridge (6-7) di PATH_ROW (y=256-272) jika sungai vertikal/horizontal memotong
- **Validasi:** semua pohon/prop min 32px dari water rect
- **Aturan keras:** tidak boleh ada pohon, sampah, NPC, atau tong yang berada di dalam air
- **Cek visual:** setiap level harus punya tepi air yang sama (pasir, bukan rumput langsung ke air)

### Jalur Tanah (Door Path)
- **Lebar:** 2 tile (32px)
- **Posisi:** x-left = building_center_x - 24, x-right = building_center_x - 8
- **Panjang:** dari y=208 (bottom of building) ke y=PATH_ROW
- **Visual:** tile 3-4 (dirt path)

### NPC Placement
- **Posisi:** 2 tile (32px) di depan pintu bangunan
- **Exclamation mark:** tampil jika dialog belum pernah dibuka
- **Interaction radius:** 48px (3 tile)

### Sampah Placement (Tersebar, Bukan di Spawn Pemain)
Patokan **bukan** jarak dari spawn MC. Patokan utamanya adalah **sebaran yang wajar** dan **kemudahan membuang**:
- **Tersebar merata:** sampah ditempatkan di beberapa kluster kecil (2–3 item per kluster) yang saling berjauhan, bukan menumpuk di satu titik.
- **Jarak antar kluster:** min 5 tile (80px), ideal 8–12 tile (128–192px).
- **Jarak dari tong:** tiap kluster berada dalam radius 10 tile (160px) dari minimal satu tong, supaya pemain tidak menyeret sampah terlalu jauh.
- **Posisi logis:** di bantaran sungai, tepi jalan, dekat warung/rumah, area publik — tempat sampah memang biasanya berserakan.
- **Tidak di jalur utama** (PATH_ROW): beri offset min 1 tile agar tidak menghalangi gerak.
- **Tidak di dalam air:** min 32px dari water rect.
- **Boleh dekat spawn** selama posisinya logis dan tidak menutupi jalan keluar — yang penting sebarannya rata, bukan jarak dari spawn.

### Tong Sampah Placement (Dekat, Tidak Menjauhkan Pemain)
Tujuan: pemain tidak perlu berjalan jauh hanya untuk membuang sampah.
- **Jarak tong ke area sampah:** maksimal 10 tile (160px) — ini patokan utama, bukan jarak dari spawn.
- **Jarak antar tong:** min 6 tile (96px) agar label tidak bertumpuk, tapi tetap dalam satu area layar.
- **Posisi:** di sepanjang PATH_ROW atau sedikit di sisinya (offset 1 tile), tidak blocking jalur utama.
- **Tidak di dalam air:** min 64px dari water rect.
- **Konsistensi visual:** ikon kategori + label di atas tong, warna sesuai kategori.
- **Aturan praktis:** kalau pemain harus berjalan lebih dari ~5 detik dari kluster sampah terakhir ke tong, posisi tong salah.

### Tree Spot Placement (Hanya di Darat)
- **Jarak dari bangunan:** min 3 tile (48px)
- **Jarak dari air:** min 2 tile (32px) kecuali mangrove (boleh 1 tile dari garis pantai, tetap di darat)
- **Tidak di dalam air:** validasi keras vs water rect — pohon tidak boleh "mengapung"
- **Tidak di atap bangunan:** validasi vs BUILDING_RECTS
- **Spread:** tidak clustered, tersebar merata di area darat level

---

## HUD & UI Standards

### Top Bar (36px height)
- **River Health Bar:** 74×10px, 3-warna (merah <40, kuning 40-69, biru ≥70)
- **River Label:** Pixelify 11px, alignment right
- **Rupiah:** ikon coin + label, min-width 58px agar tidak bergeser
- **Location Label:** center, Pixelify 10px, all-caps

### Mission Card (250×72px)
- **Position:** top-left, offset (0, 62)
- **Style:** panel_paper texture, margin 8px
- **Font:** Pixelify 10px body, 9px title
- **Separation:** 2px antar baris
- **Isi:** judul + maks. 3 baris progress + 1 baris lokasi
- **Tidak boleh** lebih tinggi dari 72px agar tidak menutupi area main di layar 640×360

### Carry Label (bottom-center)
- **Text:** "Dibawa: [count] [category]"
- **Font:** Pixelify 11px
- **Background:** semi-transparan
- **Show:** saat `pending_trash` tidak kosong

### Toast (bottom-center)
- **Duration:** 2.5 detik
- **Style:** panel_paper, padding 8px
- **Font:** Pixelify 10px
- **Color:** hijau (sukses), kuning (info), merah (error)

### Pause Button (40×36px)
- **Position:** top-right, offset (-4, 4)
- **Icon:** card.png (journal/menu)
- **Tooltip:** "Jurnal / Menu"

---

## Audio & Feedback Standards

### SFX
- `correct`: sampah ke bin benar, puzzle benar, quest selesai
- `accepted`: sampah ke bin salah (netral, bukan error)
- `pickup`: ambil sampah/item
- `interact`: bicara NPC, tekan lever, buka gate
- `plant`: tanam pohon/mangrove
- `coin`: dapat rupiah
- `card_unlock`: kartu terbuka
- `lever`: tarik tuas drainase
- `water_flow`: air drainase mengalir

### Haptic
- `vibrate(20)`: ringan (pickup, interact)
- `vibrate(40)`: sedang (bin benar, quest progress)
- `vibrate(60)`: kuat (quest selesai, level selesai)

### Visual Feedback
- **Bump animation:** scale (1.0, 1.0) → (1.14, 0.9) → (1.0, 1.0), 0.3s
- **Confetti:** 10-15 partikel warna-warni, fall down, 1.5s
- **Coin float:** sprite coin naik 32px sambil fade, 0.8s
- **Screen flash:** overlay putih/hijau opacity 0.3, fade 0.2s
- **Glow pulse:** outline shader, opacity 0.5 ↔ 1.0, loop

---

## Struktur File & Dependencies

### Scripts (Core)
- `autoload/game_state.gd`: state global + save/load
- `autoload/quest_manager.gd`: trigger quest, tracking progress
- `autoload/dialogue_manager.gd`: dialog NPC + efek quest
- `autoload/audio_manager.gd`: SFX + BGM manager
- `autoload/scene_manager.gd`: transisi level

### Scripts (UI)
- `scripts/hud.gd`: HUD world (river bar, rupiah, location, mission, carry, toast)
- `scripts/pilot_hud.gd`: HUD chapter (sama, tapi tanpa location)
- `scripts/tutorial_manager.gd`: **[NEW]** step-by-step tutorial, arrow pointer, tooltip
- `scripts/guidance_system.gd`: **[NEW]** arrow/highlight logic per quest step

### Scripts (Gameplay)
- `scripts/level_base.gd`: base class semua level
- `scripts/topdown_level_base.gd`: base class level top-down
- `scripts/level_1_hulu_topdown.gd`: Level 1 + tutorial
- `scripts/level_2_desa_topdown.gd`: Level 2
- `scripts/level_3_kota_topdown.gd`: Level 3 + puzzle drainase
- `scripts/level_4_hilir_topdown.gd`: Level 4
- `scripts/level_5_epilog.gd`: Epilog + ending
- `scripts/trash_item.gd`: pickup sampah logic
- `scripts/trash_bin.gd`: **[UPGRADED]** bin logic dengan bonus/fakta
- `scripts/tree_spot_topdown.gd`: tanam pohon/mangrove
- `scripts/npc_topdown.gd`: NPC + exclamation mark
- `scripts/topdown_map.gd`: **[UPGRADED]** prosedural map + validasi spawn

### Data Files
- `data/dialogues/level1.json`: Ibu (3 node) + Penjaga Hutan
- `data/dialogues/level2.json`: Pak Tani + Ibu Desa
- `data/dialogues/level3.json`: 4 NPC kota + hint puzzle
- `data/dialogues/level4.json`: Nelayan + Penjaga Sungai
- `data/cards.json`: **[UPGRADED]** isi kartu + verifikasi sumber
- `data/facts.json`: **[NEW]** fakta edukasi singkat untuk toast bin
- `data/tutorial_steps.json`: **[NEW]** step-by-step tutorial Level 1

### Scenes (Prefabs)
- `scenes/world/bin_topdown.tscn`: **[UPGRADED]** bin + label + highlight
- `scenes/world/trash_topdown.tscn`: sampah + bob animation
- `scenes/world/tree_spot_topdown.tscn`: spot tanam + marker
- `scenes/world/npc_topdown.tscn`: **[UPGRADED]** NPC + exclamation + portrait
- `scenes/world/gate_topdown.tscn`: gerbang level
- `scenes/world/lever_topdown.tscn`: tuas drainase
- `scenes/ui/arrow_pointer.tscn`: **[NEW]** arrow guidance
- `scenes/ui/tooltip.tscn`: **[NEW]** tooltip interaktif
- `scenes/ui/confetti.tscn`: **[NEW]** partikel confetti

---

## Testing Checklist (EXTENDED)

### Tutorial & Onboarding
- [ ] Tutorial Level 1 step-by-step berfungsi
- [ ] Arrow pointer menunjuk objek yang benar
- [ ] Tooltip muncul saat hover/dekat objek
- [ ] Tutorial bisa diskip setelah step 3
- [ ] Tutorial tidak muncul jika save game ada

### Visual Guidance
- [ ] Arrow menunjuk NPC yang belum bicara
- [ ] Arrow menunjuk sampah terdekat setelah NPC bicara
- [ ] Arrow menunjuk tong sesuai kategori sampah dibawa
- [ ] Highlight muncul di objek yang ditunjuk arrow
- [ ] Arrow hilang setelah objek diinteraksi

### Mission Card
- [ ] Mission card menampilkan judul, progress, lokasi, cara
- [ ] Progress update real-time (pohon, sampah, NPC)
- [ ] Ikon/emoji tampil sesuai jenis quest
- [ ] Animasi slide saat update
- [ ] Warna step: hijau (done), putih (aktif), abu (locked)

### Mekanik Sampah
- [ ] HUD carry label menampilkan kategori + count
- [ ] Label bin tampil di semua level dengan warna
- [ ] Bin benar: +Rp2.000, +5 health, fakta edukasi, confetti
- [ ] Bin salah: +Rp1.500, +3 health, petunjuk, tanpa confetti
- [ ] Toast sukses/petunjuk muncul dengan warna yang benar
- [ ] Arrow menunjuk tong kategori saat membawa sampah

### Quest & NPC (Gating)
- [ ] Dialog NPC memicu quest di semua level
- [ ] Toast quest muncul dengan format: "Misi baru: [desc]"
- [ ] Progress quest update di Mission Card
- [ ] Gate terbuka setelah quest selesai
- [ ] NPC exclamation mark hilang setelah bicara
- [ ] Pohon/mangrove tidak bisa ditanam sebelum bicara NPC terkait
- [ ] Aksi terkunci menampilkan toast arahan ke NPC yang benar
- [ ] Setiap NPC punya quest_id berbeda (tidak ada quest ganda)
- [ ] Beberapa quest bisa aktif bersamaan, mission card menampilkan maks. 2

### Level Design
- [ ] Sungai lebar 4 tile, tepi pasir 1 tile, konsisten
- [ ] Jembatan ada di PATH_ROW semua zona yang perlu
- [ ] Pohon tidak spawn di dalam air (validasi water rect)
- [ ] Pohon tidak spawn di atap bangunan (BUILDING_RECTS)
- [ ] Sampah tersebar merata (bukan menumpuk di satu titik)
- [ ] Sampah tidak berada di dalam air atau di jalur utama
- [ ] Jarak kluster sampah ke tong maks. 10 tile (160px)
- [ ] Tong tidak berdekatan (min 6 tile antar tong)
- [ ] Jalur tanah aligned dengan pintu bangunan
- [ ] NPC di depan bangunan, jarak interact 48px
- [ ] Tong tidak blocking jalur utama

### Level Spesifik
- [ ] Level 1: tutorial berjalan, 2 NPC, 5 tree spot
- [ ] Level 2: 2 NPC, 2 bin, 10 sampah (spread merata)
- [ ] Level 3: 4 NPC, 3 bin, 6 sampah, puzzle 1-3-2, pantun opsional
- [ ] Level 3: hint muncul setelah 3× salah lever
- [ ] Level 4: 2 NPC, 3 bin, 10 sampah, 8 mangrove spot
- [ ] Level 5: ending sesuai river_health (0-39, 40-74, 75-100)
- [ ] Semua gate berfungsi

### Feedback & Polish
- [ ] SFX correct/accepted sesuai bin
- [ ] Haptic vibrate sesuai intensitas (20/40/60)
- [ ] Confetti muncul saat quest selesai
- [ ] Coin float saat dapat rupiah
- [ ] Screen flash saat level selesai
- [ ] Save icon muncul saat auto-save
- [ ] Bump animation saat interact

### UI & HUD
- [ ] River bar 3-warna (merah/kuning/biru)
- [ ] Rupiah label min-width 58px, tidak bergeser
- [ ] Mission card 250×72px, font Pixelify
- [ ] Carry label show/hide sesuai pending_trash
- [ ] Toast 2.5 detik, warna sesuai type
- [ ] Pause button 40×36px, ikon card

### Kartu & Konten
- [ ] Setiap kartu terbuka di level yang benar
- [ ] Isi kartu sudah diverifikasi ke sumber
- [ ] Fakta edukasi di toast sudah akurat
- [ ] Dialog NPC punya sedikit logat/istilah lokal

### Audio
- [ ] BGM loop per level (1-4)
- [ ] SFX pickup/interact/correct/accepted
- [ ] Volume BGM/SFX bisa diatur di settings
- [ ] Audio fade saat transisi level

---

## Known Issues & TODO

### Sudah Diperbaiki (v2.0–v2.1)
- ID quest ganda → setiap level punya ID unik
- Level 3 dilengkapi puzzle + dialog + kartu
- Mekanik pilah sampah punya insentif tanpa hukuman
- HUD tanpa fungsi dihapus (Energy, Debt, Hari)
- Epilog punya 3 ending bercabang
- Door path aligned dengan building sprite
- Nelayan sprite berbeda dari player (caping jerami)
- Pohon tidak spawn di atap bangunan (BUILDING_RECTS)
- Quest toast tidak error (pakai level.toast via group)
- Sungai sudah diseragamkan sebagian (lebar, pasir, jembatan) — **perlu verifikasi visual tiap level**

### Perlu Implementasi (v2.1 — Prioritas)
- [ ] **Fix save/continue:** `reset()` hapus `user://save.json`, `main_menu` tangani load gagal, `ending_screen` reset penuh
- [ ] **Mission counter real-time:** "Pohon: 3/5", "Sampah: 8/10", "Warga: 2/4" dari counter nyata
- [ ] **Quest gating per NPC:** aksi terkunci sampai NPC terkait diajak bicara (flag `active_quests`)
- [ ] **Sampah tersebar:** kluster merata, maks. 10 tile dari tong, tidak di jalur utama/air
- [ ] **Tong tidak terlalu jauh:** posisi dekat area sampah, min 6 tile antar tong
- [ ] **Validasi pohon vs air:** tidak ada pohon/mangrove di dalam water rect
- [ ] **Sungai konsisten:** lebar 4 tile, pasir 1 tile, jembatan di PATH_ROW
- [ ] Tutorial manager Level 1 (arrow, tooltip, step logic) — opsional, setelah prioritas di atas
- [ ] Guidance system (arrow pointer scene, highlight shader) — opsional
- [ ] Mission card upgrade (format baru, ikon, animasi)
- [ ] Trash bin upgrade (bonus logic, fakta toast)
- [ ] Confetti particle scene — opsional
- [ ] Save notification (ikon floppy disk fade) — opsional
- [ ] Facts.json content (10-15 fakta edukasi)
- [ ] Tutorial_steps.json content (7-8 step Level 1) — opsional

### Perlu Diverifikasi Playtest
- [ ] Keseimbangan reward: ending 75+ achievable tapi tidak terlalu mudah
- [ ] Puzzle drainase: jelas bagi pemain baru dengan hint NPC
- [ ] Sebaran sampah: pemain menemukan sampah tanpa berputar-putar
- [ ] Jarak tong: tidak terlalu jauh, tidak terlalu dekat (maks. 10 tile dari sampah)
- [ ] Quest gating: pemain paham harus bicara NPC dulu, tidak bingung
- [ ] Mission counter: angka naik sesuai aksi nyata
- [ ] Tutorial: tidak terlalu panjang, bisa diskip
- [ ] Toast durasi: 2.5 detik cukup atau terlalu cepat?

### Risiko
- Konten kearifan lokal harus akurat; verifikasi ke sumber sebelum rilis
- Tutorial bisa terasa lambat bagi pemain berpengalaman → wajib diskippable
- Arrow/highlight bisa over-guide → perlu toggle di settings
- Jumlah level & konten banyak → prioritaskan Level 1-4 + Epilog jika waktu mepet

---

## Pengembangan Opsional (Post-Launch)

- **Hint system:** tombol "?" di mission card untuk hint tambahan
- **Achievement:** badge per ending, speedrun, perfect run
- **Leaderboard:** total rupiah, waktu tercepat
- **Kartu bonus:** unlock berdasarkan ambang rupiah/perfect level
- **Mini-game tambahan:** pantun di tiap level, tebak sampah
- **Mode sandbox:** explore world tanpa quest
- **Foto mode:** screenshot tanpa HUD, share ke sosmed
- **Localization:** bahasa Inggris untuk reach lebih luas

---

**Versi:** 2.1
**Terakhir diperbarui:** 2026-11-06
**Status:** Rancangan eksekusi final, siap diimplementasi bertahap
**Target:** Godot 4.7.2, Android 8.0+, resolusi 640×360 (2× scale)

---

## Peta Eksekusi (Requirement → File → Perubahan)

| Requirement | File utama | Perubahan konkret | Risiko |
|---|---|---|---|
| Save/Continue bug | `autoload/game_state.gd`, `scripts/main_menu.gd`, `scripts/ending_screen.gd` | `reset()` hapus `save.json`; `has_save()` validasi JSON; `load_game()` gagal → toast | Rendah |
| Mission counter real-time | `scripts/pilot_hud.gd`, `scripts/hud.gd`, `scripts/level_*_topdown.gd` | Format `Pohon: x/5`, `Sampah: x/10`, `Warga: x/2`; update tiap aksi | Rendah |
| Quest gating per NPC | `autoload/game_state.gd`, `autoload/quest_manager.gd`, `scripts/tree_spot_topdown.gd`, `scripts/trash_bin.gd`, `scripts/lever_topdown.gd` | `active_quests` + cek sebelum aksi; toast arahan NPC | Sedang |
| Sampah tersebar | `scripts/level_2_desa_topdown.gd`, `scripts/level_3_kota_topdown.gd`, `scripts/level_4_hilir_topdown.gd` | Susun ulang koordinat jadi 4–5 kluster, maks. 10 tile dari tong | Rendah |
| Tong tidak jauh | file level yang sama | Geser tong dekat kluster sampah; min 6 tile antar tong | Rendah |
| Pohon tidak di air | `scripts/topdown_map.gd`, `scripts/level_1_hulu_topdown.gd`, `scripts/level_4_hilir_topdown.gd` | Validasi vs `WATER_RECTS`/water rect; pindah ke darat terdekat | Sedang |
| Sungai konsisten | `scripts/topdown_map.gd` | Lebar 4 tile, pasir 1 tile, jembatan di `PATH_ROW` semua zona | Sedang |
| `try_complete_level()` kosong | `scripts/world_sungai_deli.gd` | Implementasi cek target + `GameState.complete_level()` | Rendah |
| Tutorial/arrow | baru: `scripts/tutorial_manager.gd`, `scenes/ui/arrow_pointer.tscn` | Opsional setelah 7 item di atas stabil | Tinggi |

---

## Prioritas Implementasi (Efisien, Bukan 7-11 Hari)

Prinsip: **perbaiki yang merusak pengalaman dulu, baru poles**. Jangan menambah sistem baru sebelum 7 item inti stabil.

### Tahap 1 — Wajib (±1 hari)
1. Fix save/continue/reset (`game_state.gd`, `main_menu.gd`, `ending_screen.gd`)
2. Implementasi `try_complete_level()` di `world_sungai_deli.gd`
3. Mission counter real-time di HUD (string + update hook)
4. Quest gating per NPC (flag `active_quests`)

### Tahap 2 — Wajib (1–2 hari)
5. Susun ulang sebaran sampah + posisi tong (Level 2, 3, 4)
6. Validasi pohon/mangrove vs air (Level 1, 4)
7. Standarisasi sungai (lebar, pasir, jembatan) di `topdown_map.gd`

### Tahap 3 — Verifikasi (½ hari)
8. Jalankan test headless + capture visual semua level
9. Cek manual: alur Level 1 → Epilog, save → lanjut, main lagi
10. Commit

### Tahap 4 — Opsional (hanya jika Tahap 1–3 selesai dan stabil)
11. Tutorial arrow/tooltip
12. Confetti/coin float
13. Save notification
14. Facts/tutorial JSON content

**Estimasi realistis:** 2–4 hari kerja untuk Tahap 1–3. Tahap 4 tidak menghambat rilis.

### Definisi Selesai (Definition of Done)
- [ ] Pemain baru bisa menyelesaikan Level 1 tanpa bingung (mission card jelas)
- [ ] Counter pohon/sampah/warga naik sesuai aksi nyata
- [ ] Tidak bisa menanam/memilah sebelum bicara NPC terkait
- [ ] Tidak ada pohon/sampah/NPC/tong di dalam air
- [ ] Sungai sama lebarnya di 4 level
- [ ] Tong tidak lebih dari 10 tile dari kluster sampah
- [ ] Main Lagi benar-benar mengosongkan save; Lanjut memuat level terakhir
- [ ] Semua test headless lulus
