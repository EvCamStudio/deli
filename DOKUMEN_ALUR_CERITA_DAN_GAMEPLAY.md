# DOKUMEN MASTER ALUR CERITA, SEMUA DIALOG, & MEKANIK GAMEPLAY (V2)
## Deli Rewind — Master Design & Naskah Lengkap (Godot Engine)

Dokumen ini adalah naskah master dan pedoman resmi game *Deli Rewind*, diperbarui berdasarkan naskah master V2 (`Master_Naskah_dan_Mekanik_Game_Sungai_Deli-v2.docx`). Menggabungkan alur petualangan top-down Sungai Deli dengan dialog manusiawi, mekanik pilihan terkunci, 2 titik penanaman pohon, 4 variasi ending, dan siklus Deja Vu REWIND.

---

# 1. PANDUAN UTAMA SISTEM (SYSTEM RULES)

1. **Pemisahan Kotak Narasi, Layar Hitam, dan Dialog Karakter**:
   * **[TRANSISI LAYAR HITAM]**: Fade to Black dengan teks putih di tengah layar untuk penanda waktu (*"2 Hari Kemudian..."*, *"1 Hari Kemudian..."*, *"Beberapa saat kemudian, di pemukiman padat pinggir sungai Kota Medan..."*, *"Perjalanan menyusuri Sungai Deli akhirnya membawaku sampai ke ujung muara..."*).
   * **[KOTAK NARASI / MONOLOG INTERNAL]**: Kotak teks narasi tanpa nama/potret NPC untuk pemikiran batin MC (`speaker: "Narasi"`).
   * **[SUARA DI KEPALA MC]**: Saat Datuk Sampan berbicara secara telepati, teks miring `[i][color=#8be9fd](Suara di kepala MC)[/color][/i]`.
2. **JANGAN Masukkan Instruksi Tombol ke Mulut NPC**:
   * Kalimat seperti *"Dekati tanah bertanda, lalu tekan tombol aksi"* DILARANG diucapkan oleh NPC (Penjaga Hutan / Pak Nelayan).
   * Semua petunjuk kontrol dan target misi diletakkan di UI Quest Tracker / Objective HUD di pojok layar.
3. **Mekanik 2 Titik Penanaman Pohon**:
   * **Zona 1 (Hutan Hulu)**: Penjaga Hutan (`npc_penjaga_hutan`) meminta MC menanam **5 Bibit Pohon Hutan** (penahan longsor & spons resapan air hujan).
   * **Zona 4 (Pesisir Muara Hilir)**: Pak Nelayan (`npc_nelayan`) meminta MC menanam **8 Bibit Pohon Bakau / Mangrove** (penahan abrasi ombak & rumah anak ikan).
4. **Mekanik Cabang Warga: PEDULI (Solusi) vs MENOLAK (Gagal)**:
   * **Pak Darwis**:
     * Berhasil (A - Solusi Empati): Cincang busa parang jual ke pengepul di hulu $\rightarrow$ `darwis_peduli = true`, Meter Bencana $-10\%$.
     * Gagal (B Menggurui / C Menghakimi): Pak Darwis banting pintu toko $\rightarrow$ `darwis_peduli = false`, Kasur menyumbat jembatan desa, Meter Bencana $+20\%$.
   * **Kak Rina**:
     * Berhasil: Opsi Terkunci $\rightarrow$ Cari Solusi ke **Pemuka Desa** (dapat *Jeriken Kosong* & info Rp3.000/L) $\rightarrow$ Kembali ke Kak Rina $\rightarrow$ `rina_peduli = true`, bonus tahu isi, Meter Bencana $-10\%$.
     * Gagal (B Menggurui / C Menghakimi): Kak Rina marah dan langsung menuang minyak ke selokan $\rightarrow$ `rina_peduli = false`, Meter Bencana $+20\%$.
   * **Bang Jali**:
     * Berhasil: Opsi Terkunci $\rightarrow$ Cari Solusi ke **Pak RT** (filosofi urat nadi + dapat *Bahan Gerobak Sampah Roda*) $\rightarrow$ Kembali ke Bang Jali $\rightarrow$ `jali_peduli = true`, rakit saat pos ronda, Meter Bencana $-10\%$.
     * Gagal (B Menggurui / C Menghakimi): Bang Jali marah dan langsung melempar 2 kantong plastik ke parit $\rightarrow$ `jali_peduli = false`, Meter Bencana $+20\%$.
5. **Karakterisasi MC**:
   * MC adalah pemuda yang peduli keluarga namun agak sinis, blak-blakan, dan gengsi (*tsundere*) terhadap Datuk Sampan.

---

# 2. PROLOG & BAGIAN 1: RUMAH KEBANJIRAN & JEMBATAN HULU

### Adegan 1.1: Kepulangan MC Saat Banjir Surut
* **Lokasi**: Di dalam Rumah MC (lumpur sisa banjir).
* **Dialog (`res://data/dialog/h1_warung.json`)**:
  * Bu Mira (Mak): *"Sudah sampai nak?"*
  * MC: *"Iya mak, maaf ya mak, seharusnya aku pulang lebih cepat."*
  * Pak Hendra: *"Banjir tidak akan menunggu siapa-siapa nak. Jangan pikul yang bukan bagianmu."*
  * MC: *"Rumah kita sungguh berantakan ya mak, air benar-benar membuat kekacauan ini."*
  * Pak Hendra: *"Jangan mengatakan hal seperti itu nak, memangnya air salah apa? Bukan air yang seharusnya bertanggung jawab…."*
  * Bu Mira (Mak): *"Sudahlah pak. Meskipun memang banyak barang kita yang rusak akibat banjir, tapi yang terpenting kita sekeluarga masih selamat."*
  * MC: *"Melihat rumah kita terendam sisa lumpur begini, hatiku terasa sesak. Banyak perabotan yang rusak dan harus kita benahi bersama, agar ibu juga bisa kembali berjualan."*
  * Pak Hendra: *"Yasudah. Mari kita mulai bersih-bersih apa yang tersisa dari banjir."*
* **Transisi Layar Hitam**: *"2 Hari Kemudian..."*
* **Kotak Narasi In-Game (`res://data/dialog/h1_narasi_2hari.json`)**:
  > *"Sungguh sangat melelahkan, selama 2 hari aku harus membersihkan semua kekacauan ini. Aku tidak tahu kenapa tapi ini sangat menjengkelkan, air sungai yang naik itu pasti karena sampah-sampah yang ada di sana.*  
  > *Dulu saat aku kecil sungai itu masih layak dilihat bahkan untuk mandi di sana, tapi sekarang aku bahkan tidak bisa melihat sungai itu tanpa merasa jijik.*  
  > *Sebenarnya dari mana semua awal kesalahannya?"*

### Adegan 1.2: Misi Memesan Kasur Baru
* **Dialog (`res://data/dialog/h1_warung_kasur.json`)**:
  * Mak: *"Nak, bisakah kamu ke desa sebelah untuk memesan kasur baru? Kasur kita sudah tidak bisa dipakai."*
  * Pilihan MC: *"Bisa mak."* / *"Tempatnya di mana ya mak?"*
  * Mak: *"Tempatnya di Toko Jaya ya nak, kamu pesan saja dulu, nanti mereka akan kirim orang untuk mengantarkan ke sini."*
  * MC: *"Baik mak."*

### Adegan 1.3: Pertemuan dengan Datuk Sampan di Jembatan
* **Dialog 1 (Suara Misterius, `res://data/dialog/h1_jembatan_suara.json`)**:
  * MC: *"Ugh, pemandangan ini benar-benar mengerikan."*
  * Datuk Sampan: *(Suara misterius terdengar dekat)* *"Yang mengerikan itu bukan pemandangannya, melainkan orang-orang yang membuat hal ini terjadi."*
  * MC: *"Eh? Siapa yang berbicara barusan?"*
* **Dialog 2 (Datuk Muncul, `res://data/dialog/h1_datuk.json`)**:
  * MC: *"Ugh, itu tadi apa? Tidak ada seseorang pun di sekitar sini… apa itu hanya halusinasiku saja atau itu hantu?"*
  * Datuk: *"Anggap saja keduanya. Aku adalah Datuk Sampan… penjaga sungai ini selama 70 tahun. Dengar baik-baik nak, bencana akan segera menimpa kota ini jika sungai tidak diperbaiki... Setiap manusia pasti punya alasannya sendiri nak. Jangan mulai dengan amarah, mulailah dengan telinga. Dengarkan kenapa mereka melakukannya, lalu carilah jalan keluarnya."*

---

# 3. BAGIAN 2: ZONA 1 (HULU & HUTAN RESAPAN)

### Adegan 2.1: Pembersihan Sampah Pinggiran Sungai
* **Misi**: Memungut 5 sampah di tepian sungai hulu.
* **Dialog Selesai (`res://data/dialog/h1_selesai_sungai.json`)**:
  * MC: *"Melelahkan sekali membersihkan semua ini."*
  * Datuk: *(Suara di kepala MC)* *"Wajar saja… banyaknya sampah-sampah itu sungguh sebuah ironi. Kau sudah membersihkan semuanya dengan baik."*

### Adegan 2.2: Penjaga Hutan & 5 Bibit Pohon
* **File Dialog**: `res://data/dialog/h1_penjaga_hutan.json` & `h1_penjaga_hutan_selesai.json`
* **Cerita**:
  * Datuk: *(Suara di kepala MC)* *"Lihatlah ke bukit hulu itu sebentar, nak. Percuma kau punguti sampah kalau tanah di bukit hulu terus longsor saat hujan turun."*
  * Penjaga Hutan: *"Banyak pohon ditebang liar... Akar pohon itu semacam spons raksasa, nak. Tanpa akar di hulu, air hujan langsung lari ke bawah membawa lumpur ke rumah kalian."*
  * MC membantu menanam **5 bibit pohon hutan** di titik tanah bertanda.
  * Penutup: *"Pohon yang kau tanam hari ini mungkin tak sempat kau teduhi dalam waktu dekat. Tak apa. Pohon besar yang meneduhimu sekarang pun dulunya bukan kau yang tanam."*

---

# 4. BAGIAN 3: ZONA 2 (DESA DELI) — PAK DARWIS & KAK RINA

### Adegan 3.1: Pak Darwis di Toko Jaya (Kasur Bekas)
* **File Dialog**: `res://data/dialog/h1_toko_jaya.json` & `h6_darwis.json`
* **Dilema**: Kasur busa basah banjir ratusan kilo, fisik Pak Darwis sudah tua renta & pinggang sakit, TPS sepuluh kilo.
* **Cabang Pilihan**:
  * **[A - SOLUSI EMPATI]**: Cincang busa pakai parang, jual ke pengepul hulu $\rightarrow$ Pak Darwis senang dan lega (`darwis_peduli = true`).
  * **[B / C - MENGGURUI / MENGHAKIMI]**: Pak Darwis tersinggung (*"Anak kemarin sore tahu apa soal susahnya orang tua!"*), banting pintu toko $\rightarrow$ Kasur menyumbat jembatan desa (`darwis_peduli = false`, Meter $+20\%$).
* **Pemesanan Kasur**: MC memesan kasur Bu Mira ke Pemilik Toko Jaya $\rightarrow$ Pemilik Toko berjanji antar nanti sore $\rightarrow$ Transisi Layar Hitam: *"1 Hari Kemudian..."*

### Adegan 3.2 s/d 3.4: Kak Rina & Pemuka Desa (Minyak Jelantah)
* **File Dialog**: `res://data/dialog/h4_rina.json`, `h2_pemuka_desa.json`, `h5_rina.json`
* **Dilema**: Minyak jelantah menumpuk, wadah jeriken mahal, untung jualan tipis sehabis banjir.
* **Alur Mekanik**:
  1. Kak Rina bersiap menuang minyak hitam ke selokan $\rightarrow$ MC cegah.
  2. Pilihan solusi berstatus **TERKUNCI** (butuh jeriken & info).
  3. MC pamit menemui **Pemuka Desa** di balai desa.
  4. Pemuka Desa: Filosofi *"berat sama dipikul, ringan sama dijinjing"*, serahkan **[Jeriken Kosong]** gratis & info Bank Sampah biodiesel membeli jelantah Rp3.000/liter!
  5. MC kembali ke Kak Rina membawa jeriken $\rightarrow$ Kak Rina antusias (`rina_peduli = true`), simpan jelantah, dan beri MC bonus tahu isi!
  6. Jika memilih opsi kasar/menghakimi: Kak Rina marah dan langsung tuang minyak ke selokan (`rina_peduli = false`, Meter $+20\%$).

---

# 5. BAGIAN 4: ZONA 3 (KOTA MEDAN) — BANG JALI, PINTU AIR, & BUDI

### Adegan 4.1 s/d 4.3: Bang Jali & Pak RT (Sampah Gang Padat)
* **File Dialog**: `res://data/dialog/h2_jali.json`, `h3_pak_rt.json`, `h3_jali.json`
* **Transisi**: *"Beberapa saat kemudian, di pemukiman padat pinggir sungai Kota Medan..."*
* **Dilema**: Gang sempit tak muat truk, TPS 200m di jalan besar, rumah sempit bau, buru-buru berangkat kerja.
* **Alur Mekanik**:
  1. Bang Jali bersiap melempar 2 kantong kresek ke parit $\rightarrow$ MC cegah.
  2. Pilihan solusi berstatus **TERKUNCI**.
  3. MC pamit menemui **Pak RT**.
  4. Pak RT: Filosofi sungai sebagai *"urat nadi kota"*, berikan **[Bahan Gerobak Sampah Roda RT]** untuk ditaruh di depan mulut gang.
  5. MC kembali ke Bang Jali $\rightarrow$ Bang Jali sepakat rakit bersama pemuda gang di pos ronda (`jali_peduli = true`), bawa kantong ke depan!
  6. Jika memilih opsi kasar: Bang Jali bentak MC dan langsung lempar kantong ke parit (`jali_peduli = false`, Meter $+20\%$).

### Adegan 4.4: Ibu Rumah Tangga & Pintu Air
* **File Dialog**: `res://data/dialog/h3_ibu_rumah.json`
* **Teka-teki Tuas**: Urutan tuas pintu air adalah: **Tuas 1 (Depan) $\rightarrow$ Tuas 3 (Belakang) $\rightarrow$ Tuas 2 (Tengah)**.
* **Edukasi B3**: Pisahkan baterai dan lampu bekas ke tong khusus merah (B3).

### Adegan 4.5: Budi & Rumus Pantun Melayu Deli
* **File Dialog**: `res://data/dialog/h3_budi.json`
* **Petunjuk**: Rumus sajak pantun adalah **a-b-a-b** (bunyi akhir baris 1 = baris 3, baris 2 = baris 4).

---

# 6. BAGIAN 5: ZONA 4 (MUARA HILIR) — PEMILAHAN, PANTUN, & MANGROVE

* **Transisi**: *"Perjalanan menyusuri Sungai Deli akhirnya membawaku sampai ke ujung muara..."*

### Adegan 5.1: Penjaga Sungai di Muara
* **File Dialog**: `res://data/dialog/h7_penjaga_sungai.json`
* **Misi**: Pilah 10 sampah pesisir muara ke 3 tong (Organik / Hijau, Anorganik / Kuning, B3 / Merah).

### Adegan 5.2: Teka-Teki Papan Pantun Tua
* **File Dialog**: `res://data/dialog/h7_pantun.json`
* **3 Bait Pantun Melayu Deli (Rima a-b-a-b)**:
  1. *"Kayuh sampan ke Tanjung Jati, / Singgah sebentar membeli ikan..."*
     ➜ **[A - Benar]**: *"Sungai Deli urat nadi hati, / Janganlah sampah kita hanyutkan."*
  2. *"Buah kuini di atas para, / Jatuh sebiji di tepi perigi..."*
     ➜ **[A - Benar]**: *"Kalau warga bersatu suara, / Bencana banjir tak datang lagi."*
  3. *"Burung camar terbang ke muara, / Hinggap berteduh di dahan bakau..."*
     ➜ **[A - Benar]**: *"Alam lestari kita pelihara, / Anak dan cucu tak lagi risau."*

### Adegan 5.3: Pak Nelayan & 8 Bibit Mangrove
* **File Dialog**: `res://data/dialog/h7_nelayan.json` & `h7_nelayan_selesai.json`
* **Cerita**: Pohon bakau menahan abrasi ombak dan melindungi anak-anak ikan. MC menanam **8 bibit mangrove** di pesisir bibir laut.

### Adegan 5.4: Epilog Sunset di Muara
* **File Dialog**: `res://data/dialog/h7_epilog.json`
* **Penutup**: Wujud utuh Datuk Sampan muncul di cahaya sunset keemasan. Berterima kasih kepada MC karena jiwa sungai telah pulih dan bencana berhasil dicegah.

---

# 7. BAGIAN 6: 4 VARIASI ENDING & MEKANIK REWIND

| Ending | Syarat | Alur Cerita Singkat |
|---|---|---|
| **ENDING A: Harapan Baru Deli** (True Ending) | Meter Bencana $\le 20\%$, 3 Warga Peduli, 5 Pohon Hulu + 8 Mangrove Selesai | 6 bulan kemudian, warung Mak ramai pelanggan, warga rutin kerja bakti (Bang Jali bak roda, Kak Rina setor jelantah, Pak Darwis cincang kasur). Air Deli jernih hingga batu terlihat. Datuk Sampan tenang: *"Waktu tak bisa diputar, tapi kebiasaan bisa dimulai dari mendengar."* |
| **ENDING B: Keluarga Mandiri** (Normal Ending) | Meter Bencana $\le 40\%$, minimal 2 Warga Peduli | Musim hujan tiba, air naik hanya sampai anak tangga teras warung (tidak merendam meja). Warung bisa tetap buka. Datuk: *"Kau tak sendirian lagi, teruskan perjuanganmu."* |
| **ENDING C: Bertahan di Tepian** (Warning Ending) | Meter Bencana $\le 60\%$, minimal 1 Warga Peduli | Hujan lebat merendam warung sampai batas lumpur lama. Perbaikan warung tersendat. Datuk: *"Seperti menambal atap saat hujan turun. Jalanmu masih panjang."* |
| **ENDING D: Banjir Bandang & REWIND** (Bad Ending) | Meter Bencana $> 60\%$ (atau $\ge 80\%$ pemicu bencana) | Banjir bandang dahsyat menerjang, meratakan warung keluarga hanya menyisakan tiang dan sandal. Warga yang menolak terduduk menyesal. Datuk: *"Satu orang membuang, semua menanggung."* Muncul tombol **[ REWIND ]**. |

### Adegan 6.5: Setelah REWIND (Deja Vu di Jembatan Hulu)
* **File Dialog**: `res://data/dialog/h1_datuk_dejavu.json`
* **Cerita**: MC terbangun kaget di jembatan dengan ingatan Deja Vu: *"Bukannya tadi warung ibuku sudah hancur diterjang banjir bandang?!"*
* **Petunjuk Spesifik Datuk**:
  * Banyak menuduh (Opsi C): *"Kemarin kau bicara lebih cepat daripada mendengar. Kali ini pelankan suaramu, dengarkan dulu beban mereka."*
  * Menggurui tanpa bukti (Opsi B): *"Sekadar menyuruh orang berhenti bukan menolong, nak. Temui Pemuka Desa dan Pak RT untuk mencari solusi nyata."*
  * Malas pungut sampah: *"Telinga saja tak cukup, tanganmu juga perlu bekerja membersihkan tepian sungai."*
  * Lewatkan tanam pohon: *"Ada hal yang tak bisa diselesaikan hanya dengan bicara. Pohon di bukit hulu dan bakau di muara harus kau tanam."*
