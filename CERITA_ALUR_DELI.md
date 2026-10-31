# DELI REWIND — CERITA LENGKAP & ALUR FULL (DRAFT FINAL)

Status: DRAFT FINAL — siap implementasi  
Target: Godot 4 / Life-Sim Citampi-style (satu dunia, tanpa level terpisah)

---

## 1. KONSEP UTAMA

| Aspek | Keputusan |
|---|---|
| Format | Life-sim top-down 3/4 (Citampi-style), bukan platformer level-based |
| Level | **Hilangkan** level 1-4 terpisah → jadi **satu peta dunia Sungai Deli** (Hulu → Desa → Kota → Hilir dalam satu world) |
| Tema | Kebersihan sungai + ekonomi keluarga + lingkungan |
| Cerita | MC dari Jakarta PHK → balik Medan bantu orang tua → banjir karena sungai kotor → keluarga utang → MC harus bekerja & bersihkan sungai |
| Fitur Wajib | Intro dramatis + Input Nama MC + Scriptwriting ditingkatkan |

---

## 2. IDENTITAS MC & DUNIA

### MC (Karakter Utama)
- **Nama**: Diinput user di awal permainan (disimpan di `GameState.player_name`)
- **Umur**: 24 tahun
- **Asal**: Jakarta
- **Latar**: Karyawan admin/teknik di gedung perkantoran Jakarta; baru saja **di-PHK** karena perusahaan downsizing
- **Karakter**: Tenang, bertanggung jawab, sedikit pesimis tapi punya tekad kuat. Tidak suka banyak bicara tapi peduli pada keluarga.
- **Motivasi balik**: Orang tua di Medan punya **warung kecil** yang sudah berdiri 15 tahun; dia rasa harus membantu karena keluarga kesulitan.

### Orang Tua / Tokoh Kunci
- **Nama**: Pak Hendra (ayah) & Bu Mira (ibu) — pemilik dagangan/warung kecil di tepi sungai Deli, daerah Kota Medan
- **Dagangannya**: Warung kopi + jualan kebutuhan sehari-hari kecil (kopi tubruk, gorengan, minuman dingin, barang sembako kecil)
- **Karakter**: Sederhana, pekerja keras, percaya bahwa sungai adalah sumber rezeki mereka

### Tokoh Pendukung
- **Bapak Reza**: Penjaga hutan / warga senior yang tahu sejarah sungai Deli
- **Kakak Tetangga**: Pedagang kecil lain yang juga terkena dampak banjir
- **Anak kecil di tepi sungai**: Simbol bahwa sungai sudah “menangis” dan harus diselamatkan

---

## 3. PLOT CERITA — FULL ALUR

### BAB 1 — MASUK KERJA / PENGENALAN (Intro Drama — Jakarta)
> **Lokasi**: Ruang kantor modern, Jakarta. Pagi, cerah tapi tegang.
> **Suasana**: MC baru saja diterima bekerja. Suara keyboard, suara kopling kopi, suara manajer yang datang.

**Narasi (Intro Dramatis)**:
> *"Saya tidak tahu bahwa hari pertama bekerja akan menjadi hari terakhir saya bekerja. Tapi di sinilah saya mengenal diri saya sendiri lagi — bukan hanya sebagai orang yang lelah, tapi sebagai [Nama], anak baru yang baru saja ingin membuktikan sesuatu."*

**Scene — Manajer/Bos mendekat**:
> **Manajer**: *"Halo, anak baru. Sebelum kita mulai — siapa namamu? Kita butuh nama lengkap untuk catatan perusahaan."*
> **MC**: *(User mengetik nama)* → Nama tersimpan.
> **Manajer**: *"Baik, [Nama]. Selamat bekerja. Semoga kita bisa berjalan bersama."*

**Input Nama** (terpadu dalam scene ini — bukan form terpisah, tapi bagian dialog):
- Nama yang diinput akan dipakai dalam monolog PHK dan reunion nanti.
- UI sederhana: kotak teks muncul saat manajer bertanya, dengan efek suara klik ringan.

---

### BAB 2 — PHK / KEHILANGAN (Konflik — Beberapa Waktu Kemudian)
> **Lokasi**: Ruang kantor yang sama, tapi kini kosong dan gelap.
> **Suasana**: Malam, hujan di luar jendela. Suara surat yang dibuka perlahan.

**Scene — Surat PHK diterima**:
> **Monolog/Narator (suara lembut)**: *"Beberapa bulan kemudian… perusahaan memutuskan untuk mengecilkan operasional. [Nama] bukan satu-satunya, tapi tetap saja dia yang harus pergi. Surat itu bukan hanya kertas — itu adalah akhir dari satu bab, dan awal dari bab lain yang tidak pernah dia minta."*

**Visual**: MC mengemas barang kecil, mengambil foto keluarga, menutup laptop. Suasana sedih tapi tenang — dia tahu ini bukan akhir.

**Dialogue (dengan diri sendiri / pesannya)**:
> **MC**: *"[Nama]… kamu sudah berusaha. Tapi Jakarta tidak lagi punya tempat untukmu. Aku akan pulang. Bukan karena kalah. Tapi karena aku harus hati-hati untuk keluarga."*

**Transisi**: Fade gelap → suara kereta/bis → suara hujan → **Medan**.

---

### BAB 3 — KEMBALI KE MEDAN / REUNI (Reunion — Yang Masuk Akal)
> **Lokasi**: Rumah orang tua, tepi Sungai Deli, daerah Kota Medan.
> **Suasana**: Pagi, tapi masih ada lumpur banjir di dinding warung. Air belum benar-benar surut.

**Scene — Kedatangan MC**:
> MC tiba dengan koper kecil. Suasana bukan "penuh keajaiban", tapi **tenang dan berat**. Dia sudah tahu kondisi sebelumnya (dari telepon/pesan sebelum berangkat), tapi menyadari bahwa kondisi nyata lebih buruk dari yang dibayangkan.

**Reuni — Dialog dengan Orang Tua (Natural, karena nama sudah dikenal)**:
> **Bu Mira**: *"[Nama]… kamu sudah pulang. Aku tidak pernah ragu kamu akan kembali. Tapi aku harus jujur — sungai sudah terlalu kotor. Banjir tahun lalu merusak segalanya. Kita harus utang untuk memulihkan warung."*
> **MC**: *"Aku tahu, Bu. Aku akan membantu. Bukan hanya di warung. Tapi juga untuk sungai ini — karena sungai yang kotor adalah penyebab kita di sini sekarang."*

**Kenapa ini masuk akal?**
- Nama tidak "dilupakan" — sudah diperkenalkan sejak Bab 1 sebagai identitas MC.
- Orang tua memanggil [Nama] bukan karena tiba-tiba tahu — tapi karena mereka memang tahu anak mereka sejak lahir.
- Tidak ada "NPC tiba-tiba datang" — semua sudah terhubung secara logis: Jakarta → PHK → Medan → tragedi sungai → utang.

---

### BAB 4 — MUSIBAH & MISSION (Konflik & Quest — Di Medan)
> **Lokasi**: Warung orang tua / Bantaran sungai Deli
> **Suasana**: Pagi, cerah tapi suram, lumpur masih terlihat

**Terjadi**:
- **Banjir besar tahun lalu** karena sungai Deli sudah tidak bisa menampung air — sampah menyumbat saluran air, air meluap.
- **Warung orang tua** kena banjir: meja, stok kopi, peralatan rusak, barang dagangan hilang atau rusak.
- **Orang tua terpaksa utang** ke koperasi desa / keluarga besar dan tetangga untuk **memperbaiki warung dan membeli barang dagangan baru**.
- **Utang besar** — mereka harus membayar dalam waktu tertentu, atau warung akan tutup dan mereka kehilangan satu-satunya sumber penghidupan.

**MC menyadari**:
- Dia tidak bisa hanya “membantu” dengan bekerja di warung — karena dagangan belum pulih, penghasilan belum cukup.
- **Sungai yang kotor = penyebab banjir = penyebab utang = penyebab keluarga hancur.**

---

### BAB 3 — MISSION / QUEST UTAMA (Main Quest)

**Judul Misi**: *"Sungai yang Menunggu Kita”*  
**Tujuan Akhir**: Membersihkan sungai Deli → mengurangi risiko banjir → memulihkan warung keluarga → bayar utang.

**Alur Misi (Game Loop)**:

| Tahap | Aksi Player | Hasil / Cerita |
|---|---|---|
| **1. Bangkit** | Bantu orang tua membuka warung kecil lagi, membersihkan lumpur | Warung bisa buka lagi, tapi stok masih kurang |
| **2. Cari Penghasilan** | Kerja sampah (ambil sampah di sungai, pilah, jual ke pengumpul) / Misi warga / Jual barang kecil | Mendapat uang kecil untuk hidup sehari-hari |
| **3. Bersihkan Sungai** | Ambil sampah dari air, bawa ke tong sampah, perbaiki saluran | Sungai mulai bersih, air lebih jernih |
| **4. Bangun Kembali** | Gunakan uang yang dikumpulkan + bantuan sungai yang lebih baik → beli stok dagangan baru | Warung pulih, penghasilan naik |
| **5. Bayar Utang** | Kumpulkan cukup uang → bayar utang ke koperasi / keluarga | Keluarga terbebas dari beban |
| **6. Epilog** | Sungai bersih, warung hidup, keluarga bahagia | Ending baik / biasa / buruk tergantung aksi player |

---

## 4. DIALOG & SCRIPTWRITING

### Narasi Pembuka (Intro — ditampilkan di layar dengan fade & BGM lembut)
> *“Medan. Bukan lagi kota yang pernah aku kenal. Sungai Deli sudah berubah — bukan karena waktu, tapi karena kita. Aku kembali bukan untuk lupa, tapi untuk mengingat janji: bahwa sungai ini adalah sumber rezeki kita semua.”*

### Dialog Pertama — MC & Orang Tua (di warung)
> **Bu Mira**: *"Nak, kau sudah pulang. Aku tahu kau lelah dari kota besar. Tapi di sini, kita harus mulai lagi dari nol. Sungai kita sudah kotor… dan karena sungai, kita kena banjir. Kita harus bayar utang besar untuk perbaiki warung.”*
>
> **MC**: *"Aku akan bantu. Aku akan bekerja. Tidak hanya untuk utang, tapi untuk sungai ini.”*

### Dialog — Penjaga Hutan / Warga Senior (Bapak Reza)
> **Bapak Reza**: *"Dulu sungai ini jernih, Nak. Airnya bisa diminum. Sekarang… sampah dari kota dan desa menyumbat. Kalau kita tidak bersihkan, banjir akan datang lagi. Bukan hanya warungmu yang hancur, tapi seluruh kampung.”*

### Dialog — Anak Kecil (simbol sungai yang “menangis”)
> **Anak kecil**: *"Pak/Bu, kenapa sungai ini sedih? Airnya kok hitam?”*
> **MC**: *"Karena kita belum membersihkannya, Nak. Tapi kita akan mulai sekarang.”*

---

## 5. ALUR GAME (FULL FLOW — Life-Sim, Tanpa Level Terpisah)

```
[App Start / Splash Screen]
    ↓
[Intro Scene — Bab 1 Dramatis Jakarta (Boss tanya nama)]
    ↓
[Input Nama — Bagian dialog manajer]
    ↓
[BAB 2 — PHK / Dark Scene (Surat, monolog, fade)]
    ↓
[BAB 3 — Reunion Medan (Orang tua menyebut [Nama], warung rusak)]
    ↓
[Main Menu — Peta Sungai Deli + Pilih Mulai / Lanjutkan]
    ↓
[World Map — Satu peta besar (Top-Down 3/4)]
    ├── Area Hulu (hutan, mata air)
    ├── Area Desa (sawah, jalan kampung, saluran irigasi)
    ├── Area Kota (warung, bantaran, drainase, jembatan)
    └── Area Hilir (dermaga, mangrove, pesisir)
    ↓
[Gameplay Loop]
    ├── Bantu orang tua buka warung
    ├── Ambil sampah di sungai → pilah ke tong
    ├── Bekerja misi warga / jual barang kecil → dapat uang
    ├── Perbaiki saluran air / tanam pohon mangrove
    ├── Bayar utang ke koperasi / keluarga
    ├── Pulihkan warung → penghasilan naik
    ↓
[Epilog — Kondisi sungai berdasarkan river_health + debt_status]
    ├── Ending Bagus: Sungai jernih, utang lunas, warung hidup
    ├── Ending Biasa: Sungai mulai bersih tapi masih ada utang kecil
    └── Ending Buruk: Sungai tetap kotor, utang belum lunas, warung tutup
```

---

## 6. DATA & TECHNICAL PLAN

### File Baru / Diubah

| File | Perubahan |
|---|---|
| `scenes/intro/intro_dramatic.tscn` | Scene intro dramatis: latar ilustrasi, panel cerita, input nama, fade |
| `scripts/intro/intro_dramatic.gd` | Script 3 bab intro + input nama + simpan state |
| `scenes/ui/name_input.tscn` | Tidak dipakai — input nama terpadu di dalam scene intro |
| `autoload/game_state.gd` | Tambah: `player_name`, `debt_amount`, `parent_shop_status`, `quest_progress` |
| `autoload/scene_manager.gd` | Tambah: `go_to_intro()` |
| `scripts/main_menu.gd` | Tombol "Mulai Perjalanan" → reset state → intro |
| `scenes/world/main_world.tscn` | Scene satu peta besar (rencana lanjutan) |
| `data/dialogues/start.json` | Dialog pembuka MC + orang tua + Bapak Reza (rencana lanjutan) |
| `data/characters.json` | Profil MC, Orang Tua, Bapak Reza, Anak Kecil (rencana lanjutan) |
| `scripts/world/quest_manager.gd` | Manager misi utama: bayar utang + bersihkan sungai (rencana lanjutan) |

---

## 7. CATATAN PENTING

- **Tidak ada lagi level terpisah** (level_1, level_2, dst). Semua jadi satu dunia yang bisa dieksplorasi.
- **Input nama** wajib ada dan disimpan untuk digunakan di dialog NPC.
- **Utang + Banjir** adalah pendukung cerita utama, bukan sekadar latar.
- **MC bukan pahlawan sempurna** — dia baru pulang, lelah, tapi punya tekad. Itu membuat cerita lebih manusiawi.
- **Plot “dari Jakarta ke Medan karena PHK”** menjelaskan kenapa MC tidak tahu kondisi sungai saat ini — dia baru menyadari setelah kembali.

---

## 8. DETAIL TAMBAHAN — SCENE-BY-SCENE (Agar Lebih Bagus)

### Detail Bab 1 — Jakarta (Masuk Kerja)
- **BGM**: Musik ringan dengan nada piano dan sedikit suara ambient kota Jakarta (klakson jauh, suara langkah kaki cepat).
- **Visual**: Warna cerah tapi sedikit dingin — menggambarkan harapan yang belum teruji. Logo perusahaan terlihat sekilas.
- **Efek suara**: Saat user mengetik nama, suara ketikan keyboard yang lembut. Saat nama tersimpan, suara "ding" kecil.
- **Dialog variasi (jika nama pendek/panjang)**: Manajer selalu merespons dengan nada ramah tapi formal.

### Detail Bab 2 — PHK (Kehilangan)
- **BGM**: Musik piano melankolis, satu nada yang berulang-ulang. Tidak ada suara kota lagi — hanya suara hujan dan angin.
- **Visual**: Warna berubah menjadi abu-abu gelap. Kertas PHK terlihat jelas — tulisan "Pemutusan Hubungan Kerja" yang terlihat besar tapi kabur oleh air mata MC (secara visual: efek blur atau fade).
- **Monolog**: Suara MC terdengar pelan tapi tegas. "[Nama]" disebut dengan nada yang tidak sedih, tapi penuh tekad.
- **Transisi visual**: Kertas PHK jatuh ke lantai → layar gelap → suara kereta → suara hujan di Medan → warna kembali tapi lebih hangat (bukan cerah).

### Detail Bab 3 — Reunion (Kembali ke Medan)
- **BGM**: Musik akustik hangat, gamelan ringan — khas Medan/Deli. Tidak terlalu cerah, tapi lebih hangat dibandingkan Bab 2.
- **Visual**: Warung orang tua terlihat dari dekat. Lumpur masih menempel. Air sungai terlihat gelap tapi mulai bergerak (simbol bahwa sungai masih hidup, tapi sakit).
- **Dialog variasi**: Jika user menginput nama unik/aneh, Bu Mira tetap menyebutnya dengan lembut, tanpa mengejek. Ini menambah rasa personalisasi.
- **Efek suara**: Suara air sungai yang lambat, suara angin yang membawa bau tanah basah.

---

**Disetujui?** Kalau sudah, langkah implementasi:
1. Buat `intro_dramatic.tscn` + `name_input.tscn`
2. Update `game_state.gd`
3. Tulis script dialog `start.json`
4. Integrasi ke world map (atau buat `main_world.tscn`)
