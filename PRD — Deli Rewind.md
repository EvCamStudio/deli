# PRD — Deli Rewind

*Product Requirements Document · Versi 1.0 · Status: Draft untuk review tim*

## 1. Ringkasan Produk

**Deli Rewind** adalah game petualangan naratif top-down tentang seorang perantau yang di-PHK di Jakarta, pulang ke bantaran Sungai Deli, Medan, dan mendapati warung kopi orang tuanya hancur diterjang banjir. Pemain menyusuri sungai dari hulu ke hilir, mendengarkan warga, membersihkan sungai, dan memulihkan keluarganya.

**Pernyataan nilai:** pemain belajar bahwa banjir bukan sekadar masalah sungai, tetapi masalah kebiasaan, dan kebiasaan hanya bisa berubah lewat mendengarkan, bukan menyalahkan.

**Tagline:** *Waktu tak bisa diputar kembali. Kebiasaan bisa.*

## 2. Latar Belakang & Masalah

- Banjir bantaran sungai adalah pengalaman nyata jutaan warga perkotaan Indonesia, tetapi edukasinya sering berupa ceramah yang dilewati begitu saja.
- Game edukasi lingkungan umumnya menghukum pemain dengan angka, bukan membuat mereka memahami alasan orang membuang sampah.
- **Masalah internal saat ini:** naskah dan dialog versi awal terasa menggurui, emosinya diumumkan bukan ditunjukkan, dan beberapa pantun tidak nyambung. Ini menurunkan kepercayaan pemain pada cerita.

## 3. Tujuan & Metrik Keberhasilan

| Tujuan | Metrik | Target awal (asumsi) |
| --- | --- | --- |
| Cerita terasa autentik dan tidak menggurui | Skor kualitas naskah di playtest (skala 1–5) | ≥ 4,0 |
| Pemain memahami pelajaran empati | % pemain yang memilih opsi \[A\] di dialog ke-2 setelah mencoba \[C\] | ≥ 60% |
| Pemain menyelesaikan perjalanan | Completion rate sampai epilog | ≥ 50% |
| Ending buruk memicu pembelajaran | % pemain yang menekan **Rewind** setelah Ending D | ≥ 70% |
| Muatan edukasi tersampaikan | Rata-rata Kartu Kearifan Lokal terkumpul | ≥ 7 dari total kartu |

*Angka target adalah asumsi awal dan perlu divalidasi setelah playtest pertama.*

## 4. Target Pemain

- **Utama:** remaja dan dewasa muda (15–30 tahun), pengguna ponsel, tertarik pada game naratif ringan.
- **Sekunder:** pelajar dan guru (konteks pembelajaran lingkungan), komunitas peduli sungai di Medan dan sekitarnya.
- **Bahasa:** Indonesia, dengan warna Melayu Deli/Medan (*kau, Bang, cemana, kali*).

## 5. Ruang Lingkup

**Dalam cakupan (v1.0)**

- Prolog komik interaktif 3 bab.
- 4 zona dunia top-down: Hulu, Desa, Kota, Hilir.
- Sistem dialog empati 3 langkah dengan 3 warga kunci.
- Puzzle drainase, papan pantun, penanaman pohon dan mangrove, memilah sampah.
- 4 ending dan mekanik **Rewind**.
- Kartu Kearifan Lokal (ensiklopedia).

**Di luar cakupan (v1.0)**

- Multipemain atau fitur sosial.
- Pembelian dalam aplikasi.
- Zona atau cerita tambahan di luar empat zona.
- Pengisi suara.

## 6. Pilar Pengalaman

1. **Dengar dulu, bertindak kemudian.** Mekanik empati adalah inti, bukan hiasan.
2. **Tunjukkan, jangan ceramahi.** Pesan lingkungan disampaikan lewat benda, subteks, dan konsekuensi.
3. **Sungai sebagai satu tubuh.** Hulu, desa, kota, dan hilir saling memengaruhi lewat satu angka bersama.
4. **Kegagalan yang bisa dipelajari.** Ending buruk bukan hukuman, melainkan pintu untuk mencoba lagi.

## 7. Mekanik Inti

### 7.1 Tiga Pilar Metrik

| Metrik | Definisi | Aturan |
| --- | --- | --- |
| **Kesehatan Sungai** (`river_health`) / **Meter Bencana** | Meter Bencana = 100 − Kesehatan Sungai (0–100) | Naik karena memungut sampah, menanam, membuka drainase, dan dialog empatik. Turun karena dialog kasar dan puzzle salah. |
| **Uang & Utang** | Uang awal Rp 0, utang awal Rp 500.000 | Uang dari memungut (+Rp 500), memilah ke tong (+Rp 1.000), drainase (+Rp 2.500), penghijauan (+Rp 2.000). |
| **Sikap Warga** (`npc_sikap`) | Bang Jali, Kak Rina, Pak Darwis | −1 Menolak · 0 Acuh · 1 Ragu · 2 Peduli |

### 7.2 Dialog Empati 3 Langkah

Berlaku untuk Pak Darwis, Kak Rina, dan Bang Jali.

| Langkah | Opsi A (Empatik) | Opsi B (Menggurui) | Opsi C (Menuduh) |
| --- | --- | --- | --- |
| 1 Dengarkan | Lanjut, Δ 0 | Dialog berhenti, Meter +3 | Dialog berhenti, Meter +5, Sikap −1, sampah balasan |
| 2 Pahami | Lanjut, Sikap +1 (Ragu) | Dialog berhenti, Meter +3 | Dialog berhenti, Meter +5, Sikap −1, sampah balasan |
| 3 Solusi | Meter −3, Sikap +1 (Peduli) | Dialog berhenti, Δ 0 | Dialog berhenti, Meter +5, Sikap −1, sampah balasan |

### 7.3 Mekanik Pendukung

- **Puzzle drainase:** urutan tuas **1 → 3 → 2**. Salah: reset dan Meter +2%. Benar: Sungai +10%, +Rp 2.500, Kartu `card_drainase_01`.
- **Papan pantun:** 3 pantun, pemain memilih isi yang bersajak dan bermakna. Benar: Meter −2%.
- **Rewind:** pada Ending D, tombol utama berubah menjadi “Rewind” (`GameState.rewind()`), mengembalikan pemain ke awal dengan pengetahuan yang tersisa.

## 8. Struktur Konten

| Bagian | Lokasi | Tugas utama | Syarat gerbang berikutnya |
| --- | --- | --- | --- |
| Prolog | Komik 3 bab (Jakarta → PHK → Medan) | Input nama, pengenalan konflik | Selesai bab 3 |
| Zona 1 Hulu | Warung, mata air, hutan | Temui orang tua, Datuk Sampan, Penjaga Hutan, tanam 5 pohon | Sungai ≥ 40% + 5 pohon |
| Zona 2 Desa | Bantaran, kebun, bale bambu | Pilah 10 sampah, bicara 2 warga (Darwis, Rina) | Sungai ≥ 60% + 10 sampah + 2 warga |
| Zona 3 Kota | Gang padat, jembatan, pintu air | Pilah 6 sampah, bicara 4 warga (termasuk Jali), puzzle tuas | Sungai ≥ 75% + 6 sampah + 4 warga |
| Zona 4 Hilir | Muara, pesisir, mangrove | Tanam 8 mangrove, pilah 10 sampah, bicara 2 warga, pantun | Sungai ≥ 80% + 8 mangrove + 10 sampah + 2 warga |
| Epilog | Layar akhir | Evaluasi 4 ending | — |

## 9. Persyaratan Fungsional

**Prioritas:** P0 = wajib rilis, P1 = penting, P2 = bila waktu cukup.

| ID | Persyaratan | Prioritas |
| --- | --- | --- |
| FR-01 | Menu utama dengan “Mulai Perjalanan Baru” yang membuka prolog | P0 |
| FR-02 | Prolog 3 bab: narasi, balon dialog, monolog pikiran, telepon masuk, dan input nama pemain yang disimpan di `GameState.player_name` | P0 |
| FR-03 | Dunia top-down dengan joystick kiri / WASD dan tombol aksi (B / E) | P0 |
| FR-04 | Sistem metrik Kesehatan Sungai, Meter Bencana, uang, dan utang sesuai bagian 7.1 | P0 |
| FR-05 | Sistem dialog empati 3 langkah dengan sikap warga dan pemicu sampah balasan | P0 |
| FR-06 | Dialog bercabang berbasis JSON untuk semua NPC | P0 |
| FR-07 | Mekanik memungut, memilah ke 3 tong, menanam pohon dan mangrove | P0 |
| FR-08 | Gerbang zona yang terbuka berdasarkan syarat di bagian 8, dengan narasi transisi | P0 |
| FR-09 | Puzzle drainase tuas 1-3-2 dengan umpan balik benar/salah | P0 |
| FR-10 | Evaluasi dan tampilan 4 ending dengan warna air berbeda | P0 |
| FR-11 | Mekanik Rewind pada Ending D | P0 |
| FR-12 | Papan pantun dengan 3 pantun dan 3 opsi tiap pantun | P1 |
| FR-13 | Kartu Kearifan Lokal yang terbuka sepanjang perjalanan | P1 |
| FR-14 | Layar rekap statistik akhir (8 komponen) | P1 |
| FR-15 | Hint petunjuk tuas drainase setelah dua kali gagal | P2 |
| FR-16 | Pelacakan analitik dasar untuk metrik di bagian 3 | P2 |

## 10. Persyaratan Narasi

Naskah lengkap tersimpan di dokumen terpisah: *Deli Rewind — Naskah Cerita & Dialog (Revisi Sastra)*. Dokumen itu adalah sumber kebenaran untuk teks. Persyaratan berikut berlaku untuk semua teks baru.

**Gaya penulisan**

- Tunjukkan emosi lewat benda dan tindakan kecil, bukan pernyataan langsung.
- Dialog memakai subteks; tokoh jarang mengatakan persis apa yang mereka rasakan.
- Humor kering untuk warga, tanpa merendahkan.
- Bahasa Medan–Melayu Deli secukupnya, tidak berlebihan.
- Dilarang: dialog ala penyuluhan, pesan moral eksplisit di mulut tokoh, kalimat baku kaku di mulut MC.

**Tiga motif wajib dijaga**

1. *Sebelum hujan, bukan sesudahnya* (pencegahan).
2. Bunyi sendok beradu gelas pukul lima pagi (warung yang hidup).
3. *Mendengar* (nasihat pertama Datuk Sampan, dasar mekanik empati).

**Aturan konten**

- Setiap pantun harus berima a-b-a-b dan isinya menyambung dengan sampiran.
- Datuk Sampan tidak pernah menjelaskan dirinya sampai Ending A.
- Pilihan B dan C pada dialog empati wajib punya respons tertulis.

## 11. Logika Ending

| Ending | Syarat | Visual air |
| --- | --- | --- |
| **A · Harapan Baru Deli** | Meter ≤ 20%, 3 warga Peduli, Utang Lunas 100% | Biru kristal `(0.18, 0.65, 0.92)` |
| **B · Keluarga Mandiri** | Meter ≤ 40%, ≥ 2 warga Peduli, Utang Lunas ≥ 70% | Biru kehijauan `(0.28, 0.58, 0.78)` |
| **C · Bertahan di Tepian** | Meter ≤ 60%, ≥ 1 warga Peduli | Keruh keabuan `(0.42, 0.52, 0.58)` |
| **D · Terpaksa Menyerah** | Meter > 60% atau kriteria lain tidak terpenuhi | Coklat pekat, ditambah tombol Rewind |

*Utang Lunas % = (500.000 − Utang) / 500.000 × 100%.* Evaluasi dilakukan berurutan A → B → C → D, dan ending pertama yang terpenuhi yang ditampilkan.

## 12. Persyaratan Non-Fungsional

- **Mesin dan platform (asumsi):** Godot, target Android dan iOS, dengan kontrol sentuh joystick.
- **Performa:** minimal 30 FPS pada perangkat menengah.
- **Keterbacaan:** teks dialog dan narasi dapat dibaca di layar ponsel tanpa pemotongan.
- **Bahasa:** Indonesia untuk v1.0, struktur teks siap dilokalisasi.
- **Penyimpanan:** progres tersimpan otomatis di antara zona.
- **Sensitivitas konten:** tidak ada konten yang merendahkan kelompok sosial atau daerah tertentu.

## 13. Data & Aset

| Aset | Lokasi |
| --- | --- |
| Prolog | `res://scenes/intro/intro_dramatic.tscn` dan `res://scripts/intro/intro_dramatic.gd` |
| Dialog warga | `res://data/dialog/*.json` (`h1_warung`, `h1_datuk`, `h2_jali`, `h4_rina`, `h6_darwis`) |
| Dialog NPC lain | `res://data/dialogues/level1–level4.json` |
| Pantun | `res://data/pantun_data.json` |
| Epilog | `res://scenes/levels/level_5_epilog.tscn`, `res://scripts/ending_screen.gd` |
| Ending | `ending_a.json` hingga `ending_d.json` |

## 14. Risiko & Asumsi

| Risiko / Asumsi | Dampak | Mitigasi |
| --- | --- | --- |
| Teks baru lebih panjang dan melebihi kotak dialog | Teks terpotong di ponsel | Uji tampilan tiap dialog; pecah menjadi beberapa balon |
| Pemain merasa dialog empati terlalu mudah ditebak | Mekanik terasa menggurui | Variasikan respons B/C dan tambah dampak nyata |
| Panggilan “Mak” tidak konsisten di seluruh file | Cerita terasa janggal | Audit semua JSON sebelum rilis |
| Isu “gusuran” pada ending lama tidak pernah disiapkan | Ending terasa melompat | Sudah dihapus; tambahkan di Misi 1 bila ingin dipertahankan |
| Target metrik adalah asumsi | Keputusan salah arah | Validasi lewat playtest awal |

## 15. Pertanyaan Terbuka

1. Apakah panggilan “Mak” disetujui, atau kembali ke “Ibu”?
2. Apakah narasi transisi antarzona punya slot di engine, atau perlu dibuat?
3. Berapa total Kartu Kearifan Lokal yang direncanakan, supaya target metrik bisa dipastikan?
4. Apakah Penjaga Hutan, Pak Nelayan, dan Penjaga Sungai perlu diberi nama?
5. Apakah ada rencana pengisi suara atau musik tematik yang memengaruhi gaya penulisan?

## 16. Fase Pengerjaan

| Fase | Isi | Keluaran |
| --- | --- | --- |
| **1. Integrasi naskah** | Masukkan teks revisi ke semua JSON dan prolog, audit “Mak” | Build dengan naskah baru |
| **2. Respons B/C** | Tulis dan masukkan respons yang sebelumnya kosong | Dialog empati lengkap |
| **3. Polesan alur** | Narasi transisi, hint tuas, pantun | Pengalaman zona mulus |
| **4. Playtest** | Uji dengan pemain target, ukur metrik bagian 3 | Laporan temuan |
| **5. Revisi & rilis** | Perbaiki dari temuan, finalisasi | Rilis v1.0 |

## 17. Kriteria Penerimaan Rilis

- Seluruh persyaratan P0 lolos uji.
- Keempat ending dapat dicapai dan sesuai syarat.
- Rewind berfungsi dan tidak menghapus progres kartu pengetahuan.
- Tidak ada teks terpotong pada ukuran layar ponsel target.
- Playtest menunjukkan skor kualitas naskah ≥ 4,0.

---

## 18. Addendum v1.1 — Titik Tak Kembali & Banjir Pemicu

### 18.1 Masalah

- Ending D hanya dievaluasi di epilog, sehingga pilihan buruk di tengah permainan tidak punya konsekuensi langsung.
- Pemain bisa masuk kondisi **tak bisa menang**: Meter Bencana terlalu tinggi, sementara tugas yang tersisa terlalu sedikit untuk menurunkannya.
- Gerbang zona mensyaratkan Kesehatan Sungai ≥ 40 / 60 / 75 / 80%. Jika syarat itu tak mungkin dicapai, pemain terjebak (*softlock*) tanpa penjelasan.

### 18.2 Tahapan Bencana

*Meter Bencana = 100 − Kesehatan Sungai. Meter 80% setara Kesehatan Sungai 20%.*

| Tahap | Kondisi | Respons game |
| --- | --- | --- |
| Normal | Meter < 65% | Tidak ada |
| **Pertanda** | Meter 65–74% | Langit menggelap, gerimis, musik melambat |
| **Siaga** | Meter 75–79% | HUD meter berkedip, Datuk Sampan muncul satu kali dengan peringatan |
| **Banjir Pemicu** | Meter ≥ 80% **atau** Titik Tak Kembali | Kontrol dikunci, cutscene banjir sesuai zona, lalu Ending D |

### 18.3 Definisi Titik Tak Kembali

Dievaluasi setiap kali Meter Bencana berubah:

`best_possible_meter = meter_sekarang − remaining_reducible()`

Banjir Pemicu dipicu jika salah satu terpenuhi:

1. `best_possible_meter` > 50% (tak mungkin lagi turun ke bawah 50%).
2. Kesehatan Sungai tertinggi yang mungkin dicapai < syarat gerbang berikutnya (mencegah softlock).
3. Meter Bencana ≥ 80% (pemicu langsung, apa pun sisa tugasnya).

`remaining_reducible()` menghitung semua pengurang yang masih tersedia: sampah belum dipungut, titik tanam kosong, puzzle belum dikerjakan, pantun belum dijawab, dan langkah dialog empati yang belum dipakai.

**Aturan keadilan:** evaluasi dimulai setelah pemain keluar dari area warung di Hulu. Pemicu otomatis tidak aktif selama dialog sedang berlangsung, dan baru dijalankan setelah dialog selesai.

### 18.4 Persyaratan Fungsional Tambahan

| ID | Persyaratan | Prioritas |
| --- | --- | --- |
| FR-17 | Efek tahap Pertanda dan Siaga (visual, audio, HUD berkedip) | P0 |
| FR-18 | Hitung `best_possible_meter` dan evaluasi tiga kondisi pemicu | P0 |
| FR-19 | Cutscene Banjir Pemicu dalam 4 varian zona, dengan teks reaksi warga yang bergantung pada Sikap | P0 |
| FR-20 | Setelah cutscene, masuk Ending D varian Banjir Pemicu dengan tombol Rewind | P0 |
| FR-21 | Peringatan Datuk Sampan satu kali di tahap Siaga | P1 |
| FR-22 | Catatan Datuk setelah Rewind berdasarkan penyebab dominan (menuduh, menggurui, sampah abai, puzzle terlewat) | P1 |
| FR-23 | Sekuens evakuasi yang bisa dimainkan sebelum Ending D | P2 |
| FR-24 | Telemetri: zona dan penyebab dominan tiap Banjir Pemicu | P2 |

### 18.5 Perubahan pada Bagian Lain

- **7.1 Mekanik inti:** tambahkan tahap Pertanda, Siaga, dan Banjir Pemicu pada metrik Meter Bencana.
- **11 Logika ending:** Ending D juga dicapai lewat Banjir Pemicu di tengah permainan, bukan hanya di epilog.
- **3 Metrik:** tambahkan *% sesi yang memicu banjir* dan *zona yang paling sering memicu*.
- **14 Risiko:** pemicu yang terlalu cepat membuat pemain frustrasi. Mitigasinya adalah tahap Pertanda dan Siaga serta Catatan Datuk.
- **17 Kriteria penerimaan:** Banjir Pemicu dapat dipicu dan terputar benar di setiap zona; tidak ada kondisi softlock tersisa.

### 18.6 Pertanyaan Terbuka

1. **Rewind ke awal atau ke awal zona?** Versi asli mengembalikan ke awal. Untuk Banjir Pemicu di Kota atau Hilir, itu bisa terasa menghukum. Alternatif: checkpoint di awal tiap zona.
2. **Nilai pengurang per aksi.** Dokumen sumber belum mencatat berapa persen tiap sampah, tanam, atau pantun menurunkan meter. Angka itu dibutuhkan untuk menghitung `remaining_reducible()`.
3. **Apakah sampah balasan** dari dialog \[C\] ikut dihitung sebagai sampah yang bisa dipungut kembali (jadi pengurang tersisa)?
4. **Batas 50%** untuk Titik Tak Kembali perlu dipastikan lewat playtest agar tidak terlalu ketat atau terlalu longgar.
