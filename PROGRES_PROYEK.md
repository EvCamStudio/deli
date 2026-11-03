# DOKUMEN PROGRES PROYEK & PANDUAN PENGEMBANGAN: DELI REWIND
> **Status**: Full Implementation Complete (Dokumen Utama & Tugas Aisyah Terintegrasi)  
> **Engine**: Godot 4.6.1 (2D Top-Down Life-Sim / Environmental RPG)  
> **Branch**: `heiz-dialog` (Repository: `EvCamStudio/deli`)  
> **Setting**: Bantaran Sungai Deli, Kota Medan, Sumatera Utara  
> **Backup**: `Tugas Aisyah/` (Tersimpan aman & diabaikan oleh engine via `.gdignore`)

---

## 1. Ringkasan Eksekutif & Arsitektur Game

* **Judul**: *Deli Rewind*
* **Genre**: 2D Top-Down Environmental Slice-of-Life / RPG
* **Target Viewport**: 640 × 360 px (Kamera Zoom 2x, Pixel Art Nearest-Neighbor, bebas blur)
* **Struktur Alur Utama**:
  * **Prolog**: `scenes/intro/intro_dramatic.tscn` (Jakarta PHK ➜ Tiba di Medan ➜ Warung Kebanjiran).
  * **Siklus 7 Hari**: Peta A (Warung) sebagai Basecamp ➜ Peta B (Sungai Deli) ➜ Peta C (Gang Jali) ➜ Peta D (Pintu Air).
  * **3 Ujian Hujan**: Hari 3 (Hujan Kecil), Hari 5 (Hujan Sedang), Hari 7 (Hujan Lebat / Ujian Akhir).
  * **Klimaks Hari 7**: Pagi Festival Pantun ➜ Sore Pelunasan Utang Rp 500.000 ke Bang Ucok ➜ Malam Puzzle Pintu Air (Kombinasi 1-3-2) ➜ Epilog & Evaluasi Ending.

---

## 2. Status Fitur Terintegrasi (Fully Implemented & Verified ✅)

### A. Core Systems & State (`autoload/`)
1. **`game_state.gd`**:
   - `meter_bencana` (0–100, default 60): Dinamis terhadap sampah, dialog empati, dan setoran pengepul.
   - `river_health` = `100.0 - meter_bencana`.
   - `hari` (1–7): Dikontrol via `tidur_ganti_hari()` dengan penambahan sampah harian sesuai sikap NPC.
   - `energi` (⚡ 0–100): Dipulihkan penuh saat tidur di kasur, berkurang saat aktivitas berat.
   - `rupiah` & `utang` (Rp 500.000): Pelunasan cicilan, pendapatan warung bersih (+Rp 15.000/pagi), dan upah pengepul (+Rp 6.000/setor).
   - `evaluasi_ending()`: Menghitung persentase utang dan meter bencana untuk menentukan Ending A, B, C, atau D.
   - `reset_ke_hari_1()`: Mekanik *Rewind* khusus Ending D untuk mengulang dari Hari 1 tanpa kehilangan ingatan naratif.
2. **`dialogue_manager.gd`**:
   - Mendukung format JSON Section 14 (`teks`, `pilihan`, `tipe`, `emosi`, `next`) sekaligus kompatibilitas format lama.
   - Otomatis mengeksekusi `delta_meter` dan sinyal `sampah_balasan`.
3. **`empati_manager.gd`**:
   - Menghitung 3 tingkat respon empati: Pilihan A (0 pt), Pilihan B (+3 pt w/ reprompt), Pilihan C (+5 pt w/ sampah balasan).
   - Menghitung transparansi Datuk Sampan berdasarkan jumlah NPC yang berhasil disadarkan (`0.4 + 0.2 * count_peduli`).
   - Sinyal `tps_terbuka` (TPS Gang Bang Jali) dan `jelantah_terbuka` (Gerobak Kak Rina).

---

### B. 4 Peta Dunia (World Maps) Sesuai Section 11 GDD
Semua peta telah diuji coba dan lulus verifikasi Godot Headless Engine tanpa error:
1. **Peta A: Warung (`scenes/maps/map_a_warung.tscn`)**:
   - Hub utama pemain, tempat Bu Mira, Kasur MC tidur, Warung interactable, Pengepul Sampah, Kak Rina + Gerobak Gorengan, Bang Ucok (Hari 7).
   - Gerbang timur menuju Peta B (Sungai Deli), gerbang selatan menuju Peta C (Gang Jali).
2. **Peta B: Tepi Sungai Deli (`scenes/maps/map_b_sungai.tscn`)**:
   - Datuk Sampan di atas perahu (opacity dinamis).
   - Pak Darwis & Bale Bambu di bawah rindang pohon.
   - 3 Tong Sampah Terpilah (Organik, Plastik, B3) & Titik Tanam Pohon.
   - Papan Pantun Melayu Deli & sebaran sampah sungai harian.
   - Gerbang barat menuju Warung, gerbang timur menuju Pintu Air.
3. **Peta C: Gang Bang Jali (`scenes/maps/map_c_gang_jali.tscn`)**:
   - Bang Jali di depan lorong gang.
   - Area TPS Gang dinamis (sebelum vs sesudah disadarkan).
   - Gerbang utara kembali ke Warung.
4. **Peta D: Pintu Air Bendungan (`scenes/maps/map_d_pintu_air.tscn`)**:
   - Bendungan pengendali banjir kota dengan 3 tuas mekanis.
   - Puzzle kombinasi tuas: **1 - 3 - 2**.
   - Event Hujan Lebat Hari 7 & transisi ke Ending Epilog.

---

### C. Aset Props & Pixel Art (Section 13 Sesuai Standar Resolusi)
Semua tekstur telah dibuat dan dirender dengan Nearest-Neighbor:
- `warung_rusak.png` & `warung_bersih.png` (96 × 64 px)
- `kasur_mc.png` (32 × 32 px)
- `tps_sebelum.png` & `tps_sesudah.png` (32 × 32 px)
- `gerobak_gorengan.png` (32 × 32 px)
- `botol_jelantah.png` (16 × 24 px)
- `bale_darwis.png` (48 × 32 px)
- `sampan_datuk.png` (48 × 32 px)
- `lapak_pengepul.png` (32 × 32 px)

---

### D. Dialog & Lore (Section 14 Verbatim)
16 file JSON dialog lengkap di `data/dialog/`:
- `h1_warung.json`, `h1_datuk.json`
- `h2_jali.json`, `h3_jali.json`, `ujian1.json`
- `h4_rina.json`, `h5_rina.json`, `ujian2.json`
- `h6_darwis.json`
- `h7_pantun.json`, `h7_ucok.json`, `h7_ujian_akhir.json`
- `ending_a.json`, `ending_b.json`, `ending_c.json`, `ending_d.json`
- `data/pantun_data.json`: 3 Pantun otentik Melayu Deli (Sungai, Jelantah Kak Rina, TPS Bang Jali).

---

### E. 4 Ending & Kriteria Evaluasi (Section 12 & 15)
- **Ending A (Sungai Deli Bangkit - Terbaik)**: Meter Bencana ≤ 30 & Utang Lunas 100%.
- **Ending B (Langkah Kecil Berarti - Baik)**: Meter Bencana 31–50 & Utang Lunas ≥ 50%.
- **Ending C (Dilema Bertahan - Netral)**: Meter Bencana 51–70 atau Utang Lunas < 50%.
- **Ending D (Air Mata Deli - Buruk + Rewind)**: Meter Bencana > 70. Muncul tombol *"Putar Kembali Waktu"* yang memicu reset ke Hari 1.
- Evaluasi otomatis & bibliografi juri formal di `scripts/ending_screen.gd` dan [CREDITS.md](file:///home/arisyah/.gemini/antigravity/scratch/deli/CREDITS.md).

---

## 3. Direktori Backup: `Tugas Aisyah/`
Folder backup terisolasi penuh berisi seluruh pengerjaan awal tugas Orang 2:
- `Tugas Aisyah/autoload/`
- `Tugas Aisyah/data/`
- `Tugas Aisyah/scenes/`
- `Tugas Aisyah/scripts/`
- `Tugas Aisyah/project.godot`
- `Tugas Aisyah/.gdignore` (mencegah konflik scan oleh Godot engine)
- `Tugas Aisyah/README.md`
