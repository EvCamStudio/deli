# Rancangan Alur Game - Deli Rewind (v1.1)

Game pixel top-down (Godot, Android) bertema pelestarian Sungai Deli, Medan, dengan isu lingkungan dan kearifan lokal. Pemain menelusuri sungai dari hulu ke hilir sambil menanam pohon, memilah sampah, dan mengumpulkan kartu pengetahuan.

## Ringkasan Perubahan dari v1.0

- Bar Hari/Waktu, Energy, dan Debt dihapus dari HUD (tidak punya fungsi).
- Rupiah sekarang berfungsi sebagai **poin kontribusi** dan ditampilkan di ringkasan Epilog.
- Level 3 dilengkapi (sampah campuran, 3 bin, puzzle drainase, quest, kartu, dialog).
- Quest dirapikan: satu quest per level, tidak ada lagi ID quest yang dipakai ganda.
- Sistem pilah sampah diubah: tetap ramah (tidak ada hukuman), tapi **bin yang benar memberi bonus** dan fakta edukasi.
- Label bin ditampilkan lagi pada level dengan lebih dari satu bin.
- Kategori B3 dipakai di Level 3 (industri).
- Level 4 dibuat campuran (plastik + organik) dengan 2 bin.
- Kartu pengetahuan diisi konten kearifan lokal Medan/Deli.
- Level 5 (Epilog) punya 3 versi ending berdasarkan `river_health`.
- Titik tanam pohon memakai node `Marker2D`, bukan koordinat hardcode.
- Checklist testing dan struktur file dilengkapi untuk semua level.

---

## Alur Utama Gameplay

### Level 1 - Hulu (Hutan & Mata Air) - Tutorial

**Lokasi:** Kawasan hutan di hulu Sungai Deli

**Misi Utama:**
- Ikuti pengenalan kontrol singkat (gerak + tombol interact)
- Bicara dengan NPC Penjaga Hutan (memicu quest dan membuka kartu)
- Tanam 5 pohon di titik tanam
- Menuju gerbang desa setelah semua pohon tertanam

**Mekanik:**
- Top-down movement
- Interaksi dengan tree spot, lalu pohon tertanam
- Setiap pohon: +river health, progress quest naik
- 5 pohon tertanam, gate ke desa terbuka

**Reward:**
- +Rp1.000 setelah 5 pohon selesai
- Kartu: `card_hutan_01`, `card_sungai_deli_01`

**NPC:** Penjaga Hutan (quest `tanam_pohon_hulu`)

---

### Level 2 - Desa (Pertanian & Pemukiman) - Pengenalan Pilah Sampah

**Lokasi:** Desa di tengah aliran sungai

**Misi Utama:**
- Bicara dengan NPC Desa
- Kumpulkan dan buang 10 sampah organik ke bin organik

**Mekanik:**
- Top-down movement
- Pickup sampah, HUD menampilkan jumlah + kategori (`Dibawa: 2 (Organik)`)
- Level ini sengaja hanya satu jenis sampah dan satu bin sebagai pengenalan mekanik; pilihan bin baru muncul di Level 3

**Reward:**
- Rp1.500 + 3 river health per sampah
- Kartu: `card_desa_01`, `card_melayu_deli_01`

**Sampah:** 10x organik
**Bin:** 1x bin organik (label tampil)
**NPC:** NPC Desa (quest `pilah_sampah_desa`)

---

### Level 3 - Kota (Urbanisasi & Industri) - Pilah Sampah + Puzzle Drainase

**Lokasi:** Area perkotaan dengan drainase dan saluran air

**Misi Utama:**
- Bicara dengan NPC Pedagang
- Pilah 12 sampah ke bin yang sesuai
- Selesaikan puzzle lever drainase agar aliran air terbuka

**Mekanik:**
- Top-down + puzzle drainase
- 3 kategori sampah, 3 bin (organik, plastik, B3), label bin tampil dan diberi warna
- Gate drainase terbuka, aliran air kembali lancar, `river_health` naik

**Puzzle Lever Drainase:**
- 3 gate drainase (G1, G2, G3), 3 lever (A, B, C)
- Lever A membalik status G1 dan G2; lever B membalik G2 dan G3; lever C membalik G1 dan G3
- Kondisi awal: G1 tertutup, G2 terbuka, G3 tertutup
- Target: semua gate terbuka
- Solusi: tekan A, lalu B
- Tidak ada hukuman jika salah; lever boleh ditekan berulang kali. Tampilkan hint dari NPC jika pemain menekan lever lebih dari 6 kali tanpa berhasil

**Sampah (12 item):**
- 4x organik (sisa makanan pasar)
- 6x plastik (botol, kantong, kemasan)
- 2x B3 (baterai bekas, kaleng cat)

**Reward:**
- Rp1.500 + 3 river health per sampah (bin apa pun)
- Bonus bin benar: lihat Sistem Pilah Sampah
- Bonus puzzle selesai: +Rp1.000, +5 river health
- Kartu: `card_kota_01`, `card_industri_01`, `card_kuliner_medan_01`

**NPC:** Pedagang (quest `pilah_sampah_kota`, memberi hint puzzle drainase)

---

### Level 4 - Hilir (Pesisir & Mangrove)

**Lokasi:** Muara sungai dan hutan mangrove

**Misi Utama:**
- Bicara dengan NPC Nelayan dan Penjaga Sungai
- Pilah 10 sampah (6 plastik, 4 organik) ke bin yang sesuai
- Tanam mangrove di titik tanam

**Mekanik:**
- Top-down movement
- Pickup sampah, HUD menampilkan `Dibawa: X (Kategori)`
- 2 bin (plastik, organik), label tampil
- Tree spot mangrove, tanam bakau

**Reward:**
- Rp1.500 + 3 river health per sampah
- Bonus bin benar (lihat Sistem Pilah Sampah)
- Kartu: `card_mangrove_01`, `card_pesisir_01`, `card_belawan_01`

**NPC:**
- Nelayan (quest `pilah_sampah_hilir`)
- Penjaga Sungai (quest `tanam_mangrove_hilir`)

---

### Level 5 - Epilog

**Lokasi:** Cutscene/narrative ending

**Isi:**
- Kilas balik perjalanan hulu ke hilir
- Ringkasan pemain: pohon ditanam, sampah dipilah, kartu terkumpul, total Rupiah (poin kontribusi)
- Ending ditentukan oleh `river_health` akhir:

| River Health | Ending | Gambaran |
|---|---|---|
| 0-39 | Ending 1: Sungai Masih Berjuang | Sungai membaik sedikit, tapi masih butuh banyak perawatan; ajakan untuk mencoba lagi |
| 40-74 | Ending 2: Sungai Mulai Pulih | Air mulai jernih, warga mulai peduli |
| 75-100 | Ending 3: Deli Kembali Hidup | Sungai jernih, warga dan alam kembali akrab dengan sungai |

- Tampilkan koleksi kartu pengetahuan dan opsi "Main Lagi"

---

## Sistem Pilah Sampah

### Kategori Sampah
1. **Organik** (hijau): sisa makanan, daun, ranting
2. **Plastik** (kuning): botol, kantong plastik, kemasan
3. **B3** (merah): baterai bekas, kaleng cat (hanya Level 3)

### Alur Interaksi
1. Pemain mendekati sampah, muncul prompt "Ambil"
2. Tekan interact, sampah masuk daftar `pending_trash`
3. HUD update: `Dibawa: [jumlah] ([kategori])`
   - Kategori diambil dari sampah pertama di daftar
   - Jika kosong, label disembunyikan
4. Pemain mendekati bin, muncul prompt "Pilah"
5. Tekan interact pada bin:
   - Bin menerima semua kategori (ramah pemain, **tanpa hukuman**, `river_health` tidak pernah turun)
   - Reward dasar: +Rp1.500, +3 river health
   - **Jika kategori sesuai bin: bonus +Rp500 dan +2 river health**, toast menampilkan fakta edukasi
   - Jika tidak sesuai: tetap diterima, tanpa bonus, toast memberi petunjuk ringan ("Hmm, sampah ini lebih cocok di bin [kategori]")
6. Sampah hilang dari `pending_trash`, HUD update

### Contoh Toast
- Benar: `Tepat! Sampah plastik dipilah. +Rp2.000 | Plastik butuh ratusan tahun untuk terurai.`
- Kurang tepat: `Sampah diterima. +Rp1.500 | Coba bin plastik untuk bonus!`

### Perilaku Bin
- **Visual:** sprite per kategori (`bin_organik.png`, `bin_plastik.png`, `bin_b3.png`)
- **Label:** tampil di atas bin pada level dengan lebih dari satu bin (Level 3 dan 4); di Level 2 boleh disembunyikan karena hanya satu bin
- **Collision:** Area2D, deteksi kedekatan pemain
- **Feedback:** bump animation, SFX, toast, haptic

### Alasan Desain
- Pemain tidak dihukum karena salah bin (tetap ramah), tetapi pemain yang memilah dengan benar dihargai lebih, sehingga mekanik pilah punya makna dan edukasi lingkungan tersampaikan.
- Label bin ditampilkan supaya pemain bisa belajar kategori, bukan menebak.
- Level 2 sebagai pengenalan (1 jenis, 1 bin), Level 3-4 menaikkan kompleksitas bertahap.

---

## Rupiah (Poin Kontribusi)

- Rupiah tidak dipakai untuk belanja. Fungsinya adalah poin kontribusi pemain, ditampilkan di HUD dan di ringkasan Epilog.
- Opsional (jika waktu cukup): ambang Rupiah tertentu membuka kartu bonus.

---

## Sistem Quest & Dialogue

### Quest Trigger via NPC
- Dialog NPC memiliki `effect.quest` (dictionary) dengan key `id`, `description`, `target`
- Contoh:
  ```json
  {
    "effect": {
      "quest": {
        "id": "tanam_pohon_hulu",
        "description": "Tanam 5 pohon di hutan hulu",
        "target": 5
      }
    }
  }
  ```
- `DialogueManager` memanggil `QuestManager.trigger_npc_quest()`
- Toast muncul: `Quest baru: [description]`

### Daftar Quest (satu ID per quest, tidak ada yang dipakai ganda)

| Level | Quest ID | Target |
|---|---|---|
| 1 | `tanam_pohon_hulu` | Tanam 5 pohon |
| 2 | `pilah_sampah_desa` | Pilah 10 sampah organik |
| 3 | `pilah_sampah_kota` | Pilah 12 sampah + selesaikan puzzle drainase |
| 4 | `pilah_sampah_hilir` | Pilah 10 sampah |
| 4 | `tanam_mangrove_hilir` | Tanam mangrove di titik tanam |

---

## Kartu Pengetahuan (Kearifan Lokal & Lingkungan)

Kartu muncul sebagai pop-up singkat (judul, ilustrasi pixel, 2-3 kalimat) dan tersimpan di koleksi. **Isi kartu perlu diverifikasi ke sumber** (buku sejarah Medan, situs pemerintah daerah, wawancara tokoh lokal) sebelum rilis.

| ID | Level | Topik |
|---|---|---|
| `card_hutan_01` | 1 | Fungsi hutan hulu sebagai penyangga mata air |
| `card_sungai_deli_01` | 1 | Sungai Deli: asal aliran dan peran bagi Kota Medan |
| `card_desa_01` | 2 | Pertanian dan pengelolaan sampah organik (kompos) di desa |
| `card_melayu_deli_01` | 2 | Budaya Melayu Deli dan hubungannya dengan sungai |
| `card_kota_01` | 3 | Drainase kota dan banjir akibat sampah |
| `card_industri_01` | 3 | Bahaya limbah B3 bagi sungai |
| `card_kuliner_medan_01` | 3 | Kuliner khas Medan yang lahir di sekitar jalur perdagangan sungai |
| `card_mangrove_01` | 4 | Fungsi mangrove: penahan abrasi dan habitat |
| `card_pesisir_01` | 4 | Kehidupan nelayan pesisir |
| `card_belawan_01` | 4 | Belawan dan muara sungai sebagai pintu perdagangan |

**Saran gaya NPC:** beri dialog dengan sedikit logat/istilah lokal (Melayu/Batak/Karo) agar tema kearifan lokal terasa di gameplay, bukan hanya di kartu.

---

## HUD & UI

### Top Bar
- **River Health:** bar kejernihan sungai (0-100%)
- **Rupiah:** poin kontribusi pemain
- Bar Hari/Waktu, Energy, dan Debt **dihapus**

### Mission Card
- Teks misi aktif, update real-time (contoh: `Tanam pohon: 3/5`)

### Carry Label
- Tampil saat membawa sampah: `Dibawa: [count] ([category])`
- Hilang saat `pending_trash` kosong

### Toast Notification
- Muncul di bawah layar, durasi sekitar 2 detik
- Hijau untuk sukses, kuning/merah untuk petunjuk atau error

---

## Game State

### Persistent Data
- `rupiah`: poin kontribusi
- `river_health`: 0-100
- `trees_planted`: jumlah pohon ditanam
- `trash_collected`: dictionary per kategori
- `unlocked_cards`: array ID kartu
- `completed_quests`: array ID quest selesai
- `current_level`: level terakhir dimainkan
- `drainage_solved`: boolean puzzle Level 3

### Temporary Meta
- `pending_trash`: array sampah yang dibawa, item `{ "category": "organik" | "plastik" | "b3" }`

---

## Audio & Feedback

### SFX
- `correct`: sampah dibuang ke bin yang tepat
- `accepted`: sampah dibuang ke bin kurang tepat (nada netral, bukan error)
- `pickup`: ambil item
- `interact`: interaksi umum
- `lever`: lever drainase

### Haptic
- `vibrate(20)`: ringan (sukses/bonus)
- `vibrate(40)`: sedang (diterima tanpa bonus)

### Visual
- **Bump animation:** scale tween (1.14, 0.9) ke (1.0, 1.0)
- **Partikel:** saat menanam pohon, membuang sampah, atau air drainase mengalir

---

## Level Design Considerations

### Spawn Logic
- **Level 1:** 5 tree spot (Marker2D) di posisi aman, tidak menimpa bangunan
  - Referensi koordinat: `(160, 320)`, `(352, 312)`, `(400, 192)`, `(592, 240)`, `(704, 312)`
  - Posisi pertama dipindah dari `(240, 232)` agar tidak menimpa rumah
- **Level 2:** 1 bin organik, 10 sampah organik, area tengah desa
- **Level 3:** 3 bin (organik, plastik, B3), 12 sampah campuran, 3 lever + 3 gate drainase
- **Level 4:** 2 bin (plastik, organik), 10 sampah campuran, tree spot mangrove di pesisir

### Gate Logic
- Gate terbuka setelah misi selesai
- `_mission_ready()` bernilai true, gate bisa dilewati
- Jika belum siap, toast: `[_not_ready_message()]`

---

## Struktur File

### Scripts
- `autoload/game_state.gd`: state global
- `autoload/quest_manager.gd`: trigger dan tracking quest
- `autoload/dialogue_manager.gd`: dialog NPC + efek quest
- `scripts/hud.gd`: logika HUD
- `scripts/pilot_bin.gd`: interaksi bin (pengecekan kategori untuk bonus)
- `scripts/pilot_trash.gd`: pickup sampah
- `scripts/drainage_puzzle.gd`: logika lever dan gate drainase
- `scripts/level_1_hulu_topdown.gd`
- `scripts/level_2_desa_topdown.gd`
- `scripts/level_3_kota_topdown.gd`
- `scripts/level_4_hilir_topdown.gd`
- `scripts/level_5_epilog.gd`: pemilihan ending berdasarkan `river_health`

### Data
- `data/dialogues/level1.json`: Penjaga Hutan
- `data/dialogues/level2.json`: NPC Desa
- `data/dialogues/level3.json`: Pedagang
- `data/dialogues/level4.json`: Nelayan dan Penjaga Sungai
- `data/cards.json`: isi semua kartu pengetahuan
- `data/facts.json`: fakta edukasi singkat untuk toast bin

### Scenes
- `scenes/levels/*.tscn`: scene level (1-5)
- `scenes/world/bin_topdown.tscn`: prefab bin
- `scenes/world/lever.tscn`, `scenes/world/drain_gate.tscn`: puzzle drainase
- `scenes/entities/trash_item.tscn`: prefab sampah

---

## Testing Checklist

### Mekanik Sampah
- [ ] HUD carry label menampilkan kategori
- [ ] Label bin tampil di Level 3 dan 4
- [ ] Bin menerima semua kategori tanpa error
- [ ] Bin sesuai kategori memberi bonus (+Rp500, +2 river health) dan fakta edukasi
- [ ] Bin tidak sesuai tetap diterima tanpa bonus, `river_health` tidak turun
- [ ] Toast sukses/petunjuk muncul
- [ ] `pending_trash` kosong setelah dibuang

### Quest & NPC
- [ ] Dialog NPC memicu quest di semua level (1-4)
- [ ] Toast quest muncul
- [ ] Progress quest update di Mission Card
- [ ] Gate terbuka setelah quest selesai
- [ ] Tidak ada ID quest yang dipakai dua kali

### Level Spesifik
- [ ] Level 1: tree spot tidak menimpa rumah
- [ ] Level 2: 1 bin organik, 10 sampah organik
- [ ] Level 3: 3 bin, 12 sampah (4/6/2), puzzle drainase bisa diselesaikan dengan A lalu B
- [ ] Level 3: hint NPC muncul setelah lever ditekan lebih dari 6 kali
- [ ] Level 4: 2 bin, 10 sampah (6 plastik, 4 organik), tanam mangrove
- [ ] Level 5: ending sesuai rentang `river_health` (0-39, 40-74, 75-100)
- [ ] Semua gate level berfungsi

### Kartu & Konten
- [ ] Setiap kartu terbuka di level yang benar
- [ ] Isi kartu sudah diverifikasi ke sumber

### HUD
- [ ] Hanya River Health dan Rupiah di top bar
- [ ] Tidak ada sisa referensi Hari/Waktu, Energy, Debt di kode dan scene

### Audio & Feedback
- [ ] SFX `correct` dan `accepted` benar
- [ ] Haptic dan bump animation berjalan

---

## Known Issues & Catatan

### Diperbaiki di v1.1
- ID quest ganda (`pilah_sampah_desa` di Level 3) diganti `pilah_sampah_kota`
- Level 3 dilengkapi
- Mekanik pilah sampah punya insentif (bonus) tanpa hukuman
- Elemen HUD tanpa fungsi dihapus
- Epilog punya ending bercabang

### Perlu Diverifikasi di Playtest Berikutnya
- Keseimbangan reward dan kenaikan `river_health` agar ending 3 (75+) bisa dicapai tanpa terlalu mudah
- Kejelasan puzzle drainase bagi pemain baru
- Tampilan label bin di layar Android kecil
- Panjang teks kartu dan toast (jangan menutupi layar)

### Risiko
- Konten kearifan lokal harus akurat; verifikasi ke sumber sebelum rilis
- Jumlah level dan kartu cukup banyak untuk tenggat tertentu; jika waktu mepet, prioritaskan Level 1-4 + Epilog dan kurangi kartu menjadi 1-2 per level

---

## Pengembangan Opsional

- Time limit atau combo buang sampah berturut-turut
- Achievement
- Leaderboard
- Kartu bonus berdasarkan ambang Rupiah

---

**Versi:** 1.1
**Terakhir diperbarui:** 2026-11-02
**Status:** Draft revisi, belum diuji playtest