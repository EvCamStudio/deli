# Laporan Penyelesaian Tugas — Orang 1: Sistem Inti (Ridwan)

**Proyek:** Deli Rewind (Godot 4)  
**Modul:** Orang 1 — Sistem Inti (`GameState`, Siklus Hari, Ujian Hujan, Ending Resolver, HUD, Menu Utang, Save/Load, Rewind, & Panel Debug)  
**Status:** ✅ **Selesai 100% (Siap Diintegrasikan dengan Orang 2 & Orang 3)**

---

## 1. Ringkasan Checklist Tugas (`Orang 1 Sistem Inti.pdf`)

### A. `GameState` dan Siklus Hari (`autoload/game_state.gd`)
- [x] **Variabel sesuai Kontrak Bersama**:
  - `hari: int` (`1` sampai `7`, awal `1`)
  - `waktu: String` (`"pagi"`, `"siang"`, `"sore"`, `"malam"`, awal `"pagi"`)
  - `uang: int` (awal `0`)
  - `utang: int` (awal `500000`)
  - `energi: float` (maks `100.0`, awal `100.0`)
  - `river_health: float` (awal `40.0`) & `meter_bencana: float` (`100.0 - river_health`, awal `60.0`)
  - `npc_sikap: Dictionary` (`{"jali": 0, "rina": 0, "darwis": 0}` dengan nilai `-1` Menolak, `0` Acuh, `1` Ragu, `2` Peduli)
  - `warung_bersih: bool` (`false`) & `warung_buka: bool` (`false`)
- [x] **Fungsi sesuai Kontrak Bersama**:
  - `ubah_meter(delta: float)`: Positif = Meter Bencana naik (`river_health` berkurang), Negatif = Meter Bencana turun (`river_health` bertambah).
  - `set_sikap(npc: String, nilai: int)`: Mengubah sikap `"jali"`, `"rina"`, atau `"darwis"`. Saat pertama kali mencapai Peduli (`2`), otomatis menurunkan Meter Bencana `-10` satu kali.
  - `tambah_uang(n: int)`
  - `kurangi_uang(n: int) -> bool`
  - `bayar_utang(n: int) -> bool`
  - `ubah_energi(n: float)`
  - `tidur()`: Menjalankan efek malam, memancarkan `malam_dimulai`, memajukan `hari`, mereset fase ke `"pagi"`, memulihkan `energi` ke `100` (dikurangi penalti ujian hujan jika ada), dan menyimpan permainan.
- [x] **Sinyal sesuai Kontrak Bersama**:
  - `meter_changed(nilai: float)`
  - `sikap_changed(npc: String, nilai: int)`
  - `hari_changed(hari: int)`
  - `malam_dimulai`
  - `ujian_hujan_selesai(nomor: int, hasil: String)` (`hasil`: `"aman"`, `"genangan"`, atau `"banjir"`)
  - `ending_ditentukan(kode: String)` (`kode`: `"A"`, `"B"`, `"C"`, atau `"D"`)
- [x] **Efek Malam Otomatis saat `tidur()`**:
  - Tiap NPC bersikap Acuh (`0`) atau Menolak (`-1`) menambah Meter `+4`.
  - Tiap NPC bersikap Ragu (`1`) menambah Meter `+2`.
  - Tiap NPC bersikap Peduli (`2`) menambah `0`.
  - Jika `warung_buka == true`, `uang` bertambah `+15000` per hari.

---

### B. Tiga Ujian Hujan (`autoload/game_state.gd`)
Dicek otomatis saat memasuki **Hari 3 Sore (Ujian 1)**, **Hari 5 Sore (Ujian 2)**, dan **Hari 7 Malam (Ujian Akhir)**, atau dapat dipanggil langsung melalui `GameState.jalankan_ujian_hujan(nomor)`:

| Ujian | Aman | Genangan | Banjir |
| :--- | :--- | :--- | :--- |
| **Ujian 1 (Hari 3 Sore)** | Meter `0..40`: tanpa efek negatif | Meter `41..70`: `kurangi_uang(50000)`, energi besok `-20` | Meter `> 70`: `warung_bersih = false`, energi besok `-30`, 1 NPC Ragu turun jadi Menolak |
| **Ujian 2 (Hari 5 Sore)** | Meter `0..35`: `warung_buka = true` | Meter `36..65`: `warung_buka = false` (terkunci sampai Hari 7) | Meter `> 65`: `warung_buka = false`, 1 NPC Peduli turun jadi Ragu |
| **Ujian Akhir (Hari 7 Malam)** | Meter `0..40`: `cutscene_ujian_akhir = "bersih"` | Meter `41..60`: `cutscene_ujian_akhir = "setengah"` | Meter `> 60`: `cutscene_ujian_akhir = "kotor"` |

Setiap ujian memancarkan sinyal **`GameState.ujian_hujan_selesai(nomor, hasil)`** untuk ditangkap oleh **Orang 2 (Dialog)** dan **Orang 3 (Efek Hujan)**.

---

### C. Ending Resolver A, B, C, D (`autoload/game_state.gd` & `scripts/ending_screen.gd`)
Dicek berurutan dari atas ke bawah melalui `GameState.tentukan_ending()` dengan rumus `persen_utang_lunas = (500000 - utang) / 500000.0`:
- [x] **Ending A (Harapan Baru Deli — Terbaik)**: Meter `<= 20`, ke-3 NPC `Peduli (2)`, Utang lunas `100%` (`utang == 0`).
- [x] **Ending B (Keluarga Mandiri — Baik)**: Meter `<= 40`, minimal 2 NPC `Peduli`, Utang lunas minimal `70%` (`utang <= 150000`).
- [x] **Ending C (Bertahan di Tepian — Netral)**: Meter `<= 60`, minimal 1 NPC `Peduli`.
- [x] **Ending D (Terpaksa Menyerah — Buruk)**: Selain kondisi di atas. Menampilkan pesan edukasi *"Satu orang membuang, semua menanggung"* dan tombol **Rewind** (`GameState.rewind()`) yang mereset permainan kembali ke Hari 1.
- [x] Memancarkan sinyal **`GameState.ending_ditentukan(kode)`**.

---

### D. HUD, Menu Bayar Utang Hari 7, Save/Load, Puzzle Pintu Air, & Panel Debug
- [x] **HUD (`scripts/hud.gd` & `scenes/ui/hud.tscn`)**:
  - Menampilkan **Bar Meter Bencana (`0–100%`)** dengan warna indikator bahaya (Hijau `<= 35%`, Kuning `36–65%`, Merah `> 65%`).
  - Menampilkan **Sikap 3 NPC (`Jali`, `Rina`, `Darwis`)** lengkap dengan kotak warna (`Merah` = Menolak, `Abu-abu` = Acuh, `Kuning` = Ragu, `Hijau` = Peduli) + label teks.
  - Menampilkan **Hari (`Hari 1/7 · Pagi/Siang/Sore/Malam`)**, **Uang (`Rp`)**, **Energi (`/100`)**, dan **Utang (`Rp`)**.
- [x] **Menu Bayar Utang Hari 7 Sore (`scripts/debt_payment_popup.gd`)**:
  - Muncul otomatis pada Hari 7 Sore atau dapat dipanggil dari dialog Bang Ucok (Orang 2) lewat `GameState.buka_menu_bayar_utang()`.
  - Memiliki 3 pilihan:
    1. *"Ini, kubayar semua."* (aktif jika uang mencukupi sisa utang)
    2. *"Kubayar sebagian dulu."* (dilengkapi `HSlider` untuk memilih nominal pembayaran)
    3. *"Beri aku waktu."* (utang tidak berkurang)
- [x] **Simpan & Muat (`save_game()` & `load_game()`)**:
  - Menyimpan dan mengembalikan seluruh variabel kontrak baru, status ujian hujan, posisi pemain, zona aktif, serta objek pohon/sampah yang sudah ditanam/diambil.
- [x] **Integrasi Puzzle Tuas Pintu Air Hari 7 Malam**:
  - Fungsi `GameState.selesaikan_puzzle_pintu_air()` dan urutan tuas `1-3-2` di `scripts/world_sungai_deli.gd` terhubung ke Ujian Akhir & penentuan Ending.
- [x] **Panel Debug Sistem Inti (`scripts/debug_panel.gd`)**:
  - Menggunakan tema asli project (`citampi_theme.tres`) tanpa mengubah style font.
  - Shortcut keyboard:
    - **`F1`**: Buka / Tutup Panel Debug Sistem Inti (atau klik tombol `Debug [F1]` di kiri bawah layar).
    - **`F2`**: Siklus cepat ubah jumlah NPC Peduli (`0/3` -> `1/3` -> `2/3` -> `3/3`).
    - **`F3`**: Tambah Uang `+Rp 250.000` & turunkan Meter Bencana `-15%`.
    - **`F4`**: Majukan Hari `+1` (`Hari 1` s/d `Hari 7`).
  - Di dalam panel tersedia tombol lengkap untuk mengatur Meter, Sikap tiap NPC, Uang/Utang, Siklus Hari/Waktu, `Tidur()`, memicu Ujian Hujan 1/2/3, membuka Menu Utang Hari 7, Save/Load, serta menguji langsung **Ending A, B, C, dan D**.

---

## 2. Panduan Pemanggilan Cepat untuk Orang 2 (Dialog) & Orang 3 (Dunia)

### Untuk Orang 2 (Aisyah — Dialog & NPC)
```gdscript
# Mengubah Meter Bencana & Sikap NPC dari pilihan dialog Empati:
GameState.ubah_meter(delta_meter)        # contoh: +3, +5, atau -10
GameState.set_sikap("jali", nilai_sikap) # "jali", "rina", "darwis" -> -1, 0, 1, 2

# Membaca kondisi saat ini untuk memilih dialog:
var hari_ini: int = GameState.hari
var sikap_jali: int = GameState.get_sikap("jali")
var hasil_ujian_1: String = GameState.hasil_ujian_hujan[1] # "aman", "genangan", "banjir"

# Memunculkan Menu Bayar Utang setelah dialog Bang Ucok di Hari 7 Sore:
GameState.buka_menu_bayar_utang()

# Mendengarkan sinyal Ujian Hujan & Ending:
GameState.ujian_hujan_selesai.connect(func(nomor: int, hasil: String):
    # Tampilkan dialog hasil ujian hujan
    pass
)
GameState.ending_ditentukan.connect(func(kode: String):
    # kode bernilai "A", "B", "C", atau "D"
    pass
)
```

### Untuk Orang 3 (Hezron — Dunia & Interaksi)
```gdscript
# Saat pemain memungut/memilah sampah, menanam pohon, atau menjual ke pengepul:
GameState.ubah_energi(-5)     # kurangi energi
GameState.ubah_meter(-2)      # turunkan Meter Bencana
GameState.tambah_uang(1500)   # tambah uang pemain

# Saat membersihkan warung (Rp 50.000):
if GameState.kurangi_uang(50000):
    GameState.warung_bersih = true

# Saat pemain berinteraksi dengan kasur untuk tidur:
GameState.tidur()

# Mendengarkan sinyal malam_dimulai & meter_changed:
GameState.malam_dimulai.connect(func():
    # Spawn sampah malam hari berdasarkan GameState.meter_bencana & GameState.npc_sikap
    pass
)
GameState.meter_changed.connect(func(nilai_meter: float):
    # Ubah tint visual air/langit sesuai Meter Bencana
    pass
)
```

---

## 3. Daftar File yang Diperbarui / Ditambahkan (Lingkup Orang 1)
1. `autoload/game_state.gd` *(Diperbarui — Kontrak Bersama, Siklus Hari, Ujian Hujan, Ending Resolver, Save/Load, Rewind)*
2. `scripts/hud.gd` & `scenes/ui/hud.tscn` *(Diperbarui — Bar Meter Bencana & Panel Sikap 3 NPC)*
3. `scripts/debt_payment_popup.gd` *(Baru — Menu Bayar Utang Hari 7 Sore dengan Slider)*
4. `scripts/debug_panel.gd` *(Baru — Panel Debug Sistem Inti F1–F4)*
5. `scripts/ending_screen.gd` *(Diperbarui — Layar 4 Ending A/B/C/D & Tombol Rewind)*
6. `scripts/main_menu.gd`, `scripts/pause_menu.gd`, `scripts/world_sungai_deli.gd`, `scripts/tree_spot_topdown.gd`, `scripts/zone_gate.gd` *(Perbaikan integrasi Save/Load, Puzzle Pintu Air Hari 7, & pencegahan bug gerbang)*

