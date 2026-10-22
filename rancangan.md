# RANCANGAN PROYEK & PANDUAN PENGUJIAN: DELI REWIND

Dokumen ini adalah cetak biru teknis dan panduan pengerjaan agar game **Deli Rewind** dapat langsung diuji coba (*fully playable & testable*) dengan visual placeholder bawaan Godot, sehingga Anda nantinya cukup mengganti/memasukkan aset grafis dan audionya (*drop-in assets*).

---

## 1. Analisis & Perbaikan Masalah: Tombol "Mulai" Tetap di Menu Utama

### Penyebab Utama
Ketika tombol **Mulai** diklik di `main_menu.tscn`:
1. Script memanggil `SceneManager.change_level(1)`.
2. `SceneManager` memanggil fungsi Godot `get_tree().change_scene_to_file("res://scenes/levels/level_1_hulu.tscn")`.
3. Godot 4 menolak memuat file `.tscn` karena terdapat deklarasi syntax node yang tidak valid di dalam file `.tscn`:
   - Bentuk tabrakan (`RectangleShape2D`, `CircleShape2D`, `CapsuleShape2D`) dideklarasikan sebagai node anak (`[node name="..." type="RectangleShape2D"]`), padahal di Godot 4 jenis tersebut adalah **Resource/SubResource**, bukan **Node**.
   - Hal serupa terjadi pada `player.tscn` dan `touch_controls.tscn` yang di-instance di dalam level.
4. Karena `change_scene_to_file()` mengembalikan error `ERR_PARSE_ERROR`, `SceneManager` mencetak error dan melakukan fade-in kembali ke scene saat ini (menu utama).

### Solusi Teknis
* Merestrukturisasi seluruh file `.tscn` (`player.tscn`, `touch_controls.tscn`, dan `level_1_hulu.tscn` s/d `level_4_hilir.tscn`) agar menggunakan format resmi Godot 4:
  `[sub_resource type="RectangleShape2D" id="..."]` yang dirujuk dengan `shape = SubResource("...")`.
* Memberikan visual placeholder (*ColorRect* terstruktur) pada Player, NPC, Sampah, Tong Sampah, dan Tuas sehingga seluruh objek langsung terlihat jelas dan siap dimainkan tanpa error.

---

## 2. Peta Tahapan Pengembangan (Roadmap)

```
[Tahap 1: Perbaikan Sintaks Scene] ──▶ [Tahap 2: Minigame Pantun] ──▶ [Tahap 3: Pengujian Gameplay] ──▶ [Tahap 4: Integrasi Aset Pengguna]
 (Memperbaiki player, kontrol,         (Scene & UI minigame pantun       (Testing loop level 1-5,          (Tinggal memasukkan PNG/OGG
  dan level 1-5 tscn)                   Lobi -> Level -> Epilog)          puzzle, dialog, & HUD)            ke folder assets/)
```

### Tahap 1: Standardisasi Scene Godot 4 (SELESAI ✅)
1. `player.tscn` diperbaiki (CollisionShape2D, Area2D interact, visual box, action indicator).
2. `touch_controls.tscn` diperbaiki (SubResource shape tombol sentuh, layout responsive).
3. `level_1_hulu.tscn` diperbaiki (Platform, tanah, pohon interaktif, NPC Penjaga Hutan, portal level).
4. `level_2_desa.tscn` diperbaiki (Platform sawah, jembatan, NPC petani, portal level).
5. `level_3_kota.tscn` diperbaiki (Vertical slice lengkap: platform kota, 6 sampah, 3 jenis tong, puzzle 3 tuas, 4 NPC, pintu air).
6. `level_4_hilir.tscn` diperbaiki (Dermaga, perahu, mangrove, NPC nelayan, portal epilog).
7. Kamera 2D diatur melacak pergerakan horizontal pemain secara otomatis di semua level.
8. Menu Utama (`main_menu.tscn`) ditambahkan fitur **"🗺 Pilih Level"** sehingga Anda bisa langsung melompat menguji level mana pun (terutama Level 3).

### Tahap 2: Pembuatan Scene Minigame Pantun (SELESAI ✅)
- Dibuat `scenes/minigames/pantun_minigame.tscn` yang dihubungkan ke `scripts/pantun_minigame.gd` (sambung baris pantun Melayu Deli berhadiah health sungai).

### Tahap 3: Uji Coba Penuh (Full Playable Loop)
- Verifikasi alur permainan dari:
  `Main Menu` ➜ `Level 1 (Hulu)` ➜ `Level 2 (Desa)` ➜ `Level 3 (Kota)` ➜ `Level 4 (Hilir)` ➜ `Level 5 (Epilog/Ending)`.
- Verifikasi mekanik: jalan, lompat, angkat/buang sampah, dialog pilihan ganda, puzzle tuas 1-3-2, dan pembukaan kartu edukasi.

### Tahap 4: Slot Integrasi Aset (Untuk Anda Masukkan Nanti)
Setelah semua logika dan scene selesai serta dapat Anda mainkan, Anda tinggal memasukkan aset ke struktur folder berikut tanpa perlu coding ulang:

| Kategori | Folder Tujuan | Format | Keterangan |
|---|---|---|---|
| **Karakter Pemain** | `res://assets/sprites/player/` | `.png` | Animasi idle, run, jump, pick (frame 16x16 atau 24x24) |
| **Tileset Lingkungan** | `res://assets/sprites/tiles/` | `.png` | Tileset batu hulu, desa, kota, dan hilir |
| **Objek Interaktif** | `res://assets/sprites/objects/` | `.png` | Sampah organik/plastik/B3, tong sampah, tuas |
| **NPC & Karakter** | `res://assets/sprites/npcs/` | `.png` | Sprite NPC Bung Reza, Tokoh Masyarakat, Petani, dll. |
| **UI & Ikon** | `res://assets/ui/` | `.png` | Frame dialog, tombol sentuh kustom, icon kartu |
| **Musik Latar (BGM)** | `res://assets/audio/bgm/` | `.ogg` | BGM menu, level 1, 2, 3, 4, minigame, ending |
| **Efek Suara (SFX)** | `res://assets/audio/sfx/` | `.wav` | Jump, pickup, sort_correct, lever, click, dll. |

---

## 3. Catatan Desain & Arahan Khusus Pengguna

### A. Tata Letak Fisik Sungai Deli (Playable Riverbed / Dasar Sungai)
* **Bukan Strip Background Samping**: Air sungai tidak diposisikan sebagai strip ornamen di latar belakang/samping jalan.
* **Dasar Sungai Sebagai Lantai Permainan**:
  * Level memiliki daratan/tanggul di kiri dan kanan.
  * Terdapat tangga/turunan tanah bertingkat menuju ke cekungan badan air Sungai Deli.
  * Karakter utama (MC) **bisa turun langsung ke dalam air**, berjalan di dasar sungai (*riverbed*), dan merasakan efek gesekan air (*water drag/slow*).
  * Sampah-sampah tergeletak/mengapung di dalam air sehingga MC harus turun ke air untuk mengambilnya lalu membawanya naik ke daratan untuk dipilah ke tong sampah.
* **Komponen Teknis**: Menggunakan script [`water_area.gd`](file:///c:/Users/Hype%20AMD/OneDrive/Documents/deli/scripts/water_area.gd) (`WaterArea`) yang mendeteksi `Player` dan mengaktifkan status basah/terendam.

### B. Aturan Tombol Navigasi / Home Tunggal (Single Home Button)
* **1 Tombol Saja di Layar**: Tidak boleh ada 2 tombol Home/Pause secara bersamaan di layar saat gameplay.
* **Implementasi**:
  * Tombol navigasi home tunggal berada di pojok kanan atas pada HUD (`SafeMargin/TopBar/PauseBtn` berikon `🏠`).
  * Tombol pause ganda di `TouchControls` telah dihapus secara permanen.

---

## 4. Cara Pengujian Mandiri
1. Buka Godot 4 ➜ Import folder project `deli`.
2. Tekan **F5** (atau klik Play).
3. Di Menu Utama:
   * Klik **"▶ Mulai"** (Level 1 Hulu) atau **"🗺 Pilih Level"** (misal Level 3 Kota Medan).
4. Di Dalam Game:
   * Turunkan MC dari tanggul beton/daratan ke dalam aliran air Sungai Deli. MC akan berjalan di dalam air dan mengambil sampah dari air!
   * Perhatikan pojok kanan atas layar hanya memiliki **1 tombol Home `🏠`**.
5. Gunakan keyboard:
   * Gerak: `A` / `D`
   * Lompat: `Space`
   * Interaksi / Angkat Sampah / Bicara: `E`
   * Buang / Pilah Sampah ke Tong: `Q`
   * Buka Pause / Home: Tekan tombol `🏠` di layar atau tombol `Esc` di keyboard.
