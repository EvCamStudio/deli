# DOKUMEN PROGRES PROYEK & PANDUAN PENGEMBANGAN: DELI REWIND
> **File Handover / Konteks untuk AI (Claude)**  
> **Engine**: Godot 4.x (2D Top-Down Life-Sim / RPG)  
> **Branch**: `heiz` (Repository: `EvCamStudio/deli`)  
> **Setting**: Bantaran Sungai Deli, Kota Medan, Sumatera Utara

---

## 1. Ringkasan Eksekutif & Visi Game

* **Judul**: *Deli Rewind*
* **Genre**: 2D Top-Down Slice-of-Life / Environmental RPG (ala *Citampi Stories* / *Stardew Valley*).
* **Premis Cerita**:
  * **MC (Karakter Utama)**: Pemuda berusia 24 tahun yang baru saja terkena **PHK di Jakarta**.
  * **Kepulangan ke Medan**: MC pulang kampung ke Medan untuk membantu kedua orang tuanya (**Bu Mira & Pak Hendra**) yang mengelola warung kopi & kebutuhan sehari-hari di tepi Sungai Deli.
  * **Konflik Utama**: Warung keluarga rusak parah akibat banjir bandang luapan Sungai Deli yang tersumbat gunungan sampah. Keluarga terjerat **utang darurat Rp 500.000**.
  * **Tujuan Akhir**:
    1. Membersihkan sampah sungai, menanam pohon di hulu, dan merawat mangrove di hilir (*River Health* naik 0–100%).
    2. Menghasilkan Rupiah dari menjual sampah daur ulang, pekerjaan sampingan, dan memulihkan warung keluarga.
    3. Melunasi utang keluarga sebelum tenggat waktu.

---

## 2. Status Fitur yang Sudah Selesai (Fully Implemented ✅)

| Komponen | Status | Keterangan Teknis |
|---|---|---|
| **Prolog Narasi 3 Bab** | Selesai | `scenes/intro/intro_dramatic.tscn` (Bab 1: Kantor Jakarta & Input Nama MC ➜ Bab 2: Hujan & Surat PHK ➜ Bab 3: Tiba di Warung Medan & Banjir). |
| **Movement Top-Down** | Selesai | `scripts/player_topdown.gd` — 4 arah mata angin (Down, Left, Right, Up), responsif dengan WASD/Keyboard dan Virtual Touch Joystick di mobile. Animasi idle diam sudah stabil di Frame 0 (tidak tap-dance). |
| **Fisika Air (Water Drag)** | Selesai | MC bisa masuk ke badan air Sungai Deli, memicu efek basah dan perlambatan gerak (*water drag*). |
| **Pilah Sampah 3 Jenis** | Selesai | Memungut sampah dari air/daratan lalu membuang/memilah ke tong: Organik, Plastik, dan B3. |
| **River Health System** | Selesai | Variabel `river_health` (0–100%) di `autoload/game_state.gd` otomatis memicu sinyal perubahan saat sampah dibersihkan atau pohon ditanam. |
| **Penanaman Pohon & Mangrove** | Selesai | Interaksi di titik tanam (`tree_spot_topdown.tscn`) menambah River Health. |
| **Puzzle Tuas Pintu Air** | Selesai | Teka-teki tuas kombinasi untuk membuka pintu air pengendali banjir di kota. |
| **Sistem Dialog & Portrait** | Selesai | Dialog box dengan ekspresi wajah (Netral, Senang, Sedih, Kaget) dan pilihan ganda yang memengaruhi alur cerita. |
| **Minigame Pantun Deli** | Selesai | Sambung baris pantun Melayu Deli berhadiah kesehatan sungai dan moral warga. |
| **Save / Load System** | Selesai | `GameState.save_game()` menyimpan progres ke file `user://save.json`. |

---

## 3. Tugas Pengembangan Selanjutnya yang Perlu Dikerjakan Claude

### A. Alur Cerita & Penulisan Quest (Story & Narrative Design)
1. **Dialog Pertama di Warung (Hari ke-1)**:
   * Percakapan emosional pasca-banjir antara MC dengan Bu Mira & Pak Hendra.
   * Penyerahan buku catatan utang (Rp 500.000) dan pembukaan misi harian pertama.
2. **Quest Harian & Side Quest Warga**:
   * **Bung Reza** (Penjaga Hutan Hulu): Misi reboisasi dan pencegahan erosi tebing sungai.
   * **Pak RT / Tokoh Adat**: Penyadartahuan warga tentang larangan membuang kasur/sampah ke sungai & festival pantun.
   * **Pak Tani** (Desa): Irigasi sawah yang tersumbat sampah plastik.
   * **Nelayan** (Hilir): Kerusakan jaring dan habitat ikan akibat limbah B3 dan kepunahan mangrove.
   * **Pengepul Sampah**: Tempat MC menukarkan sampah pilah menjadi Rupiah.
   * **Penagih Utang**: Datang berkala menagih cicilan dengan batas tenggat waktu.

### B. Desain Mekanik & Siklus Gameplay (Gameplay Loop)
```
[Pagi: Bangun Tidur di Warung (⚡ 100)]
         │
         ▼
[Siang: Pungut & Pilah Sampah (-5⚡) / Tanam Pohon (-10⚡) / Side Quest (-15⚡)]
         │
         ▼
[Sore: Jual Sampah ke Pengepul (+Rupiah) / Beli Makan (+⚡) / Bayar Cicilan Utang]
         │
         ▼
[Malam: Tidur di Kasur Warung (Reset Hari 📅, Full Restore ⚡, Arus Membawa Sampah Baru)]
```

### C. Restorasi Warung Orang Tua
Warung mengalami 4 tahapan visual & fungsional:
1. **Tahap 1 (Rusak - Awal)**: Dinding berlumpur, atap bocor, meja retak.
2. **Tahap 2 (Bersih - Biaya Rp 50.000)**: Lumpur hilang, cat diperbarui, belum bisa jualan.
3. **Tahap 3 (Buka Kembali - Biaya Rp 150.000 + RH > 40%)**: Bu Mira mulai menjual kopi tubruk & gorengan (memberi passive income Rp 15.000/hari ke MC).
4. **Tahap 4 (Makmur - Biaya Rp 300.000 + RH > 70%)**: Warung ramai dikunjungi warga bantaran sungai yang kini bersih dan asri.

### D. Sistem 4 Ending (Berdasarkan Skor Akhir)
* **Ending A (Harapan Baru Deli - Terbaik)**: River Health ≥ 80% & Utang 100% lunas. Sungai jernih, warung makmur, MC menjadi pelopor komunitas lingkungan.
* **Ending B (Keluarga Mandiri - Baik)**: River Health 60–79% & Utang 70–99% lunas. Warung selamat, kondisi sungai membaik bertahap.
* **Ending C (Bertahan di Tepian - Netral)**: River Health 40–59% & Utang 50–69%. Utang masih tersisa, sungai masih rawan banjir saat musim hujan lebat.
* **Ending D (Terpaksa Menyerah - Buruk)**: River Health < 40% & Utang < 50%. Banjir besar kembali menerjang, warung digusur/tutup, keluarga pindah.

---

## 5. Format & Standar Aset Visual (Untuk Panduan Integrasi Aset Nanti)

* **Spritesheet Karakter Top-Down**:
  * Ukuran file: `64 × 96 px` (Grid 4 baris × 4 kolom @ `16 × 24 px` per frame).
  * Format baris: Baris 0 = Bawah (Down), Baris 1 = Kiri (Left), Baris 2 = Kanan (Right), Baris 3 = Atas (Up).
  * Frame 0 = Idle diam (posisi kaki rapat).
* **Portrait Kotak Dialog**:
  * Ukuran file: `160 × 200 px` PNG transparan.
  * 4 varian emosi: `_neutral.png`, `_happy.png`, `_sad.png`, `_surprised.png`.
* **Objek Lingkungan (Props)**:
  * Pohon: `32 × 48 px` | Mangrove: `32 × 40 px` | Rumah/Warung: `96 × 64 px`.
  * Tong Sampah: `16 × 24 px` | Sampah Tergeletak: `12 × 12 px`.
  * Tileset: Grid `16 × 16 px`.

