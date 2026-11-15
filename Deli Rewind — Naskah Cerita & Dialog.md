# Deli Rewind — Naskah Cerita & Dialog

*Versi revisi sastra, berdasarkan DOKUMEN MASTER ALUR CERITA, SEMUA DIALOG, & ALUR GAMEPLAY*

## 0. Catatan Sebelum Membaca

**Kenapa versi lama terasa cringe**

- Tokoh bicara seperti poster penyuluhan. Mereka menyebut perasaan dan pesan moralnya langsung (“Aku tersenyum bangga”, “Jagalah sungai kita”).
- Emosi diumumkan, tidak ditunjukkan lewat benda, jeda, atau tindakan kecil.
- MC bicara terlalu baku untuk orang Medan (“Saya mengerti, Pak. Terima kasih sudah memberi kesempatan”).
- Pantun berima, tetapi isinya tidak nyambung dengan sampiran.

**Prinsip revisi**

1. **Tunjukkan lewat benda.** Garis lumpur di dinding, toples gula yang hilang, sandal yang masih berpasangan.
2. **Subteks.** Orang jarang bilang apa yang mereka rasakan. Bu Mira berkata “jangan pulang” padahal maksudnya “pulanglah”.
3. **Tiga motif yang berulang.** (a) *“Sebelum hujan, bukan sesudahnya”*, kalimat Pak Hendra tentang atap. (b) Bunyi sendok beradu gelas pukul lima pagi, bunyi warung yang hidup. (c) *Mendengar*, nasihat pertama Datuk Sampan, yang jadi dasar mekanik empati 3 langkah.
4. **Humor kering** supaya warga terasa manusia, bukan corong pesan.
5. **Suara Medan–Melayu Deli**: *kau, Bang, cemana, kali, lah*. Dipakai secukupnya.
6. **Makna judul.** *Rewind*: waktu tidak bisa diputar balik, tetapi kebiasaan bisa.

**Yang dipertahankan:** semua mekanik, angka, ID NPC, urutan misi, syarat gerbang, dan 4 ending.

**Yang diubah:** teks narasi dan dialog. Aku juga menambahkan respons untuk pilihan B/C yang sebelumnya kosong, beberapa narasi aksi, dan narasi transisi saat gerbang terbuka.

**Dua perubahan kecil yang perlu kamu cek:** panggilan “Ibu” menjadi **“Mak”** (lebih Medan; label di UI boleh tetap *Bu Mira*), dan kata **“gusuran”** di Ending B/D dihapus karena tidak pernah disiapkan di cerita sebelumnya.

**Notasi:** **\[NARASI\]** kotak narasi · **\[PIKIRAN\]** monolog MC · **\[Nama\]** (ekspresi) dialog · **\[AKSI\]** yang dilakukan pemain · **\[Δ\]** efek pada Meter Bencana / Sikap.

---

## 1. PROLOG (Komik Interaktif)

### Prolog · Jakarta — Tiga Tahun & Ruang Kosong

*Latar: kantor modern lantai lima, pagi hari, kaca jendela memantulkan langit mendung.*

**Langkah 1 · [NARASI]** Pagi ini kaca gedung lantai lima tempatku bekerja selama tiga tahun memantulkan langit mendung. Di mejaku yang hampir kosong, terletak selembar surat dengan dua paragraf. Tiga tahun yang lalu aku memulainya di sini, dan kini hanya menyisakan ruang kosong.

**Langkah 2 · [NARASI]** Aku jadi teringat kembali saat tiga tahun lalu aku diterima di perusahaan ini. Saat itu Mamak sangat senang mendengarnya. Aku pun sungguh tidak menyangka bisa bekerja di kota metropolitan terbesar di negara ini.

**Langkah 3 · [NARASI]** Aku masih ingat dengan sangat jelas betapa gugupnya aku saat HRD mewawancaraiku waktu itu...

**Langkah 4 · [HRD]** (neutral) “Selamat datang. Silakan sebutkan nama lengkapmu.”

**Langkah 5 · [AKSI]** Pemain mengetik nama, lalu menekan Konfirmasi Nama. Disimpan ke `GameState.player_name`.

**Langkah 6 · [HRD]** (neutral) “Saya sudah melihat CV kamu, {Nama}. CV kamu sangat rapi dan bagus. Di CV ini saya melihat kalau kamu berasal dari Medan, ya? Kalau saya boleh tahu, apa alasan kamu merantau ke Jakarta dan memilih perusahaan ini?”

**Langkah 7 · [MC]** (neutral) “Saya merantau ke Jakarta karena ingin mencari pekerjaan yang cocok dengan saya dengan gaji yang baik. Dan saya akhirnya memilih untuk mencoba di perusahaan ini, karena perusahaan ini sedang membutuhkan bidang yang cocok dengan keahlian saya dengan gaji yang pas sesuai ekspektasi saya. Jadi, saya mencoba mendaftar.”

**Langkah 8 · [HRD]** (neutral) “Apa kamu yakin dengan keahlian kamu itu, kamu bisa membantu perusahaan dan bekerja dengan baik?”

**Langkah 9 · [MC]** (neutral) “Ya, saya sangat yakin.”

**Langkah 10 · [HRD]** (neutral) “Bagus, saya menyukai semangat kamu.”

**Langkah 11 · [NARASI]** Yah... tiga tahun itu berlalu dengan cepat, dan aku sudah cukup membantu Mamak dan Bapak untuk membangun usaha tempat makan mereka sendiri.

**Langkah 12 · [NARASI]** Aku merenung memandangi kardus yang penuh barang-barangku itu.

**Langkah 13 · [NARASI]** Aku tersadar dari renunganku setelah ponselku bergetar di atas meja.

**Langkah 14 · [NARASI]** Di layar, aku melihat nama yang meneleponku... itu Mamak.

---

### Bab 2 · Medan — Tiga Hari Kemudian (Transisi Layar Hitam & Narasi Banjir)

*Latar: Layar hitam pekat untuk pembuka waktu, lalu berpindah ke suasana tepi Sungai Deli yang mendung dan sisa banjir.*

**Langkah 1 · [LAYAR HITAM]** 
*Medan, 3 hari kemudian.*

**Langkah 2 · [NARASI]** Tiga hari yang lalu saat Mamak meneleponku, beliau mengabarkan kalau Medan sedang diguyur hujan terus-menerus. Karena itu, air Sungai Deli yang berada dekat dengan rumah kami meluap hingga banjir pun tak bisa dihindari lagi.

**Langkah 3 · [NARASI]** Mamak memberitahuku kalau tempat makan dan rumah kami terendam air bercampur sisa-sisa lumpur. Banjirnya cukup tinggi hingga banyak perabotan yang rusak karena tidak sempat dipindahkan.

**Langkah 4 · [NARASI]** Karena itu, aku mempercepat kepulanganku ke Medan. Aku ingin membantu Mamak dan Bapak. Toh, aku juga sudah tidak ada pekerjaan lagi di Jakarta... Lebih baik aku pulang dan membantu Mamak dan Bapak.

**Langkah 5 · [Transisi]** Layar memudar ke hitam. `in_world = true`, `world_zone = "hulu"`. Pemain muncul di depan warung.

---

## 2. ZONA 1 · HULU SUNGAI DELI

*Kesehatan Sungai awal 40%. Hint layar tetap: “Joystick kiri / WASD untuk bergerak. Dekati orang atau objek lalu tekan tombol aksi (B / E).”*

### Misi 1 · Kembali ke Rumah & Warung Keluarga

**Langkah 1 · [AKSI]** Pemain berjalan ke depan warung dan mendekati Bu Mira dan Pak Hendra.

**Langkah 2 · Dialog Sambutan**

**[Bu Mira]** (neutral) “Sudah sampai, Nak?”

**[MC]** (neutral) “Iya, Mak. Maaf ya, Mak, seharusnya aku pulang lebih cepat.”

**[Bu Mira]** (sad) “Banjir tidak akan menunggu siapa-siapa, Nak. Jangan pikul yang bukan bagianmu.”

**[MC]** (sad) “Rumah kita sungguh berantakan ya, Mak... air benar-benar membuat kekacauan ini.”

**[Pak Hendra]** (neutral) “Jangan mengatakan hal seperti itu, Nak. Memangnya air salah apa? Bukan air yang seharusnya bertanggung jawab…”

**[Bu Mira]** (sad) “Sudahlah, Pak. Meskipun memang banyak barang kita yang rusak akibat banjir, tapi yang terpenting kita sekeluarga masih selamat.”

**[MC]** (sad) “Melihat rumah kita terendam sisa lumpur begini, hatiku terasa sesak. Banyak perabotan yang rusak dan harus kita benahi bersama, agar Ibu juga bisa kembali berjualan.”

**[Pak Hendra]** (happy) “Ya sudah. Mari kita mulai bersih-bersih apa yang tersisa dari banjir.”

---

### Misi 2 · Dua Hari Kemudian & Memesan Kasur Baru

**Langkah 1 · [LAYAR HITAM TRANSISI WAKTU]**
*2 hari kemudian.*

**Langkah 2 · [KOTAK NARASI IN-GAME]** (`res://data/dialog/h1_narasi_2hari.json`)
*“Sungguh sangat melelahkan, selama dua hari aku harus membersihkan semua kekacauan ini. Aku tidak tahu kenapa, tapi ini sangat menjengkelkan. Air sungai yang naik itu pasti karena sampah-sampah yang ada di sana.*
*Dulu saat aku kecil, sungai itu masih layak dilihat bahkan untuk mandi di sana... tapi sekarang aku bahkan tidak bisa melihat sungai itu tanpa merasa jijik.*
*Sebenarnya dari mana semua awal kesalahannya?”*

**Langkah 3 · [AKSI]** Pemain kembali berbicara dengan Mak di warung.

**[Bu Mira]** (neutral) “Nak, bisakah kamu ke desa sebelah untuk memesan kasur baru? Kasur kita sudah tidak bisa dipakai.”

**Pilihan MC:**
- **[A]** “Bisa, Mak.”
- **[B]** “Tempatnya di mana ya, Mak?”

*(Kedua pilihan mendapat jawaban yang sama dari Mak)*

**[Bu Mira]** (neutral) “Tempatnya di Toko Jaya ya, Nak. Kamu pesan saja dulu, nanti mereka akan kirim orang untuk mengantarkannya ke sini.”

**[MC]** (neutral) “Baik, Mak.”

---

### Misi 3 · Pertemuan Misterius di Jembatan — Datuk Sampan

**Langkah 1 · [AKSI]** MC berjalan menuju jembatan penyeberangan ke arah desa sebelah.

**[MC]** (sad) “Ugh... pemandangan ini benar-benar mengerikan.”

**[Datuk Sampan]** (neutral) *(suara menggema tanpa wujud)* “Yang mengerikan itu bukan pemandangannya, melainkan orang-orang yang membuat hal ini terjadi.”

**[MC]** (surprised) “Eh? Siapa yang berbicara barusan?!”

*(MC bingung celingak-celinguk mencari di sekitar jembatan, namun tak ada seorang pun. MC kembali ke tengah jembatan.)*

**[MC]** (sad) “Ugh, itu tadi apa? Tidak ada seorang pun di sekitar sini... Apa itu hanya halusinasiku saja, atau itu hantu?”

**Langkah 2 · Kemunculan Datuk Sampan di Tengah Jembatan**

*(Sosok kakek penjaga sungai tiba-tiba berdiri di hadapan MC)*

**[Datuk Sampan]** (neutral) “Anggap saja keduanya.”

**[MC]** (surprised) “Argh! K-kau siapa?! Kenapa kau bisa tiba-tiba muncul di sana?!”

**[Datuk Sampan]** (neutral) “Aku adalah Datuk Sampan... Aku setiap hari berada di sini, karena aku yang menjaga sungai ini. Ya, meskipun tidak ada satu orang pun yang mengetahui hal itu. Tapi, untuk pertama kalinya ada orang yang dapat melihatku dan mengetahui hal itu. Mungkin ini suatu kesempatan untuk memperbaikinya sebelum terlambat.”

**Pilihan MC:**
- **[A]** “Huh? Penjaga sungai ini?”
- **[B]** “K-kau beneran h-hantu...?”

**[Datuk Sampan]** (neutral) “Ya, begitulah... Hei anak muda, siapa namamu?”

**[MC]** (neutral) “E-em, aku {nama}.”

**[Datuk Sampan]** (happy) “Nama yang bagus, senang bertemu denganmu.”

**Pilihan MC:**
- **[A]** “Aku nggak tahu apakah aku harus senang juga dengan hal ini?”
- **[B]** “Apakah aku akan mendapat musibah jika disenangi hantu?”

**[Datuk Sampan]** (happy) “Hahaha, kau pemuda yang lucu. Ini adalah kesempatan emas yang datang mungkin hanya sekali seumur hidupku mendapatkannya. Pemuda yang baik... apakah kamu bisa menolongku?”

**Pilihan MC:**
- **[A]** “Menolong? Apakah hantu butuh pertolongan?”
- **[B]** “Tidak. Aku tidak ingin berurusan dengan hantu.”

**[Datuk Sampan]** (neutral) “Aku tidak minta bantuanmu untuk diriku, Nak. Ini semua untuk kau dan orang lain. Sungai ini sudah membawa beban yang melampaui kesanggupannya. Jika tidak segera diperbaiki, maka yang ada di ujung hanyalah sebuah penyesalan yang tidak dapat diubah.”

**Pilihan MC:**
- **[A]** “Apa maksudnya?”
- **[B]** “Kau berbicara dengan sangat bertele-tele.”

**[Datuk Sampan]** (neutral) “Baiklah, aku tidak akan bertele-tele mulai sekarang. Sepertinya kau pemuda yang cukup dingin...”

**Pilihan MC:**
- **[A]** “.....”

**[Datuk Sampan]** (sad) “Dengar ini baik-baik, Nak. Bencana akan segera menimpa kota ini, dan tidak ada yang dapat kalian lakukan pada saat itu jika semuanya sudah terjadi.”

**Pilihan MC:**
- **[A]** “Bencana? Jangan bercanda.”
- **[B]** “Apa kau sekarang sedang membual?”

**[Datuk Sampan]** (neutral) “Aku tidak berbohong. Aku adalah penjaga sungai ini selama 70 tahun. Aku dengan sungai ini sudah seperti saudara yang jiwanya terikat sangat dalam, dan aku tahu apa yang kurasakan tidak pernah salah.”

**Pilihan MC:**
- **[A]** “Bukankah banjir kemarin juga sudah bencana?”
- **[B]** “Paling hanya banjir seperti kemarin lagi.”

**[Datuk Sampan]** (sad) “Aku mengatakannya sekali lagi, Nak. Aku meminta bantuan bukan untuk diriku, melainkan untuk kalian. Terserah kau mau percaya atau tak. Satu hal yang pasti: jika bencana itu terjadi, kalian pasti akan menyesal. Atau... mungkin kalian sudah tidak bisa menyesal? Karena saat bencana itu terjadi, itu bisa saja membinasakan kalian...”

**Pilihan MC:**
- **[A]** “Kau membuatku takut...”
- **[B]** “.....”

**[Datuk Sampan]** (neutral) “Jangan khawatir… jika kau berhasil membantuku, bencana itu tidak akan terjadi.”

**Pilihan MC:**
- **[A]** “Baiklah... aku akan membantu.”
- **[B]** “Jadi, aku harus ngapain?”

**[Datuk Sampan]** (happy) “Bagus! Pilihan yang bijak. Yang kau lakukan tidaklah sulit. Pertama, karena arus sungainya lagi tidak bersahabat, yang dapat kau lakukan untuk sekarang kau hanya perlu membersihkan sampah yang ada di sekitar pinggiran sungai saja dulu. Lalu, coba carilah orang-orang yang bertanggung jawab dengan sampah yang ada di dalam sungai ini.”

**Pilihan MC:**
- **[A]** “Mencari orang? Untuk apa?”
- **[B]** “Jika aku menemukan orangnya, apakah aku harus melemparnya ke sungai?”

**[Datuk Sampan]** (neutral) “Mereka pasti punya alasan.”

**[MC]** (surprised) “Alasan, huh?!”

**[Datuk Sampan]** (neutral) “Setiap manusia pasti punya alasannya sendiri, Nak.”

**Pilihan MC:**
- **[A]** “Baiklah… aku akan melakukannya.”

*(Datuk Sampan menghilang di depan mata MC, namun suaranya tetap membimbing di dalam kepala)*

**[MC]** (neutral) *(Batin)* “Aku membantu hantu itu bukan karena ancamannya ya... Aku melakukannya hanya karena aku juga sejujurnya tidak suka dengan pemandangan penuh sampah ini.”

---

### Misi 4 · Pembersihan Pinggir Sungai & Petang Hari

**Langkah 1 · [Gameplay]** Pemain memungut dan memilah sampah yang mengotori pinggiran sungai hulu ke tong sampah terpilah.

**Langkah 2 · Dialog Selesai Pembersihan**

**[MC]** (sad) “Melelahkan sekali membersihkan semua ini...”

**[Datuk Sampan]** (neutral) *(suara di batin)* “Wajar saja... banyaknya sampah-sampah itu sungguh sebuah ironi.”

**[MC]** (surprised) “Suara ini? Datuk Sampan? Di mana kau? Aku nggak bisa melihatmu...”

**[Datuk Sampan]** (neutral) “Ya... sekarang sepertinya kau tak bisa melihatku lagi. Tapi syukurlah, kau masih bisa mendengar suaraku. Kau sudah membersihkan semuanya dengan baik. Kau sungguh pemuda yang luar biasa.”

**Pilihan MC:**
- **[A]** “Hantu menyebalkan ini... kenapa selalu mengagetkanku?”
- **[B]** “Dipuji oleh hantu menyebalkan, huh...?”

**[Datuk Sampan]** (happy) “Memangnya salah jika hantu memujimu?”

**Pilihan MC:**
- **[A]** “.....”

**[MC]** (neutral) “Aku harus ke toko dulu. Aku harus memesan kasur sebelum tokonya tutup. Ini sudah sore, untuk mencari orang yang membuang sampah-sampah itu sebaiknya besok saja.”

**[Datuk Sampan]** (neutral) “Aku tidak keberatan, toh manusia juga butuh istirahat.”

---

### Misi 5 · Toko Jaya di Desa & Misteri Kasur Hanyut

**Langkah 1 · [AKSI]** Pemain menyeberang ke Desa dan tiba di Toko Jaya.

**Langkah 2 · Percakapan Tercuri Dengarkan**

**[Pak Darwis]** (neutral) “Untung kasur basah yang kena banjir kemarin sudah kuhanyutkan ke sungai tadi pagi. Berat kali kalau mau dibuang ke bak sampah di ujung sana. Jadi kasur busa yang baru ini bisa langsung dikirim ke rumahku, kan?”

**[Pemilik Toko]** (happy) “Bisa, Pak Darwis. Nanti sore diantar becak barang ke rumah ya.”

**[MC]** (surprised) “Permisi, Pak... Tadi saya tidak sengaja dengar. Bapak menghanyutkan kasur bekas ke sungai?!”

**[Pak Darwis]** (neutral) “Eh? Kau siapa, anak muda? Iya, memangnya kenapa? Kasur itu sudah basah kuyup kena lumpur banjir, beratnya bukan main. Mau kubawa ke mana lagi? Ke sungai kan langsung hanyut terbawa arus!”

**Pilihan MC:**
- **[A]** “Tapi Pak, kasur itu menyumbat aliran sungai dan bikin banjir makin parah!”
- **[B]** “Bapak tahu tidak, rumah orang tua saya di hilir kena banjir karena luapan sampah seperti itu?”

**[Pak Darwis]** (sad) “Bah! Mana kutahu bakal sampai begitu... Kami di sini juga panik air naik mendadak, perabotan rusak semua. Orang tua sepertiku mana sanggup angkat kasur basah ratusan kilo sendirian!”

**[Datuk Sampan]** (neutral) *(Suara di kepala MC)* “Kau dengar itu, Nak? Seperti yang kubilang tadi... setiap orang pasti punya alasannya sendiri. Jangan langsung menghakimi, carilah jalan keluarnya.”

---

### Misi 3 · Penjaga Hutan dan 5 Pohon

**Langkah 1 · \[AKSI\]** Pemain berjalan ke hutan hulu dan mendekati Penjaga Hutan.

**Langkah 2 · \[NARASI\]** Mata air itu hanya seutas benang bening di atas batu berlumut. Bunyinya seperti keran yang tak ditutup rapat.

**Langkah 3 · \[Penjaga Hutan\]** (neutral) “Kau dengar itu? Dulu bunyinya seperti hujan yang tak habis-habis.” *(jeda)* “Sekarang dengar sendiri.”

**Langkah 4 · \[PILIHAN\]**

- **1.** “Apa yang terjadi di sini, Pak?”
  - **\[Penjaga Hutan\]** “Pohonnya ditebang. Akar itu semacam spons, Nak. Tanpa akar, hujan tak sempat meresap. Ia langsung lari ke bawah, membawa tanah, sampai ke rumah-rumah kalian.”
  - Pilihan lanjutan: “Bibitnya di mana?” **\[+2% Air · Quest: Tanam 5 pohon di Hulu\]**
- **2.** “Aku bisa bantu.” **\[+2% Air\]**
  - **\[Penjaga Hutan\]** *(melirik tanganmu)* “Tangan orang kantoran. Tak apa, tanah tak pilih-pilih.” *(jeda)* “Tanah bertanda itu: dekati, tekan aksi. Tak usah dalam-dalam, cukup tak terbalik.”
  - Pilihan lanjutan: “Siap!” **\[Quest: Tanam 5 pohon di Hulu\]**

**Langkah 5 · \[Gameplay\]** *(tidak berubah)*

1. Telusuri hutan, temukan 6 gundukan `tree_spot`.
2. Tanam di 5 titik → buka Kartu `card_hutan_01`.
3. Pungut sampah (+Rp 500/buah) dan buang ke tong terpilah (+Rp 1.000).
4. Kesehatan Sungai ≥ 40% dan 5 pohon selesai → gerbang desa terbuka.

**Langkah 6 · \[Dialog Penutup\] Penjaga Hutan** (happy) “Pohon yang kau tanam hari ini mungkin tak sempat kau teduhi. Tak apa. Pohon yang meneduhimu sekarang pun bukan kau yang tanam.”

**Langkah 7 · \[NARASI\]** *(saat gerbang terbuka)* Di bawah, atap-atap seng desa berkilat basah. Di sebuah belokan sungai, sekilas, ada sampan yang berlayar tanpa dayung.

---

## 3. ZONA 2 · DESA SUNGAI DELI

*Misi HUD: “Pilah 10 sampah desa & bicara dengan 2 warga desa.” Syarat gerbang kota: 10 sampah terpilah + 2 warga + Kesehatan Sungai ≥ 60%.*

**Aturan umum dialog empati (berlaku untuk Darwis, Rina, dan Jali):** Langkah 1 *Dengarkan* → Langkah 2 *Pahami* → Langkah 3 *Solusi*. Pilihan **\[A\]** empatik (lanjut), **\[B\]** menggurui (dialog berhenti, ΔMeter +3), **\[C\]** menuduh (dialog berhenti, ΔMeter +5, Sikap −1, memicu sampah balasan). Naskah di bawah menambahkan respons untuk B/C yang sebelumnya kosong.

### A. Pak Darwis (Petani Bantaran) · `npc_petani_1`

**Langkah 1 · \[AKSI\]** Pemain mendekati bale bambu dekat kebun sayur.

**Langkah 2 · \[NARASI\]** Pak Darwis menyeret kasur busa bernoda ke arah tebing kebun. Melihatku, ia berhenti, dengan satu tangan masih memegang ujung kasur.

**Langkah 3 · \[Pak Darwis\]** (neutral) “Dulu kasur rusak kami lepas ke air, hanyut sendiri sampai ke laut. Tak ada yang marah. Sekarang tiba-tiba itu dosa. Zaman ini memang aneh.”

**Langkah 4 · Dengarkan**

- **\[A\]** “Dulu sungainya seperti apa, Pak? Waktu Bapak muda.” **\[ΔMeter 0 · ΔSikap 0\]**
  - **\[Pak Darwis\]** (happy) “Bening, Nak. Ikan lewat bisa kau lihat sebelum sampai ke kaki. Kami mandi di situ, cuci piring di situ. Orangnya sedikit. Apa yang kami lepas, sungai terima, dan dia diam saja.” → lanjut Langkah 5.
- **\[B\]** “Cara itu sudah tidak cocok sekarang, Pak.” **\[ΔMeter +3\]**
  - **\[Pak Darwis\]** (neutral) *(menyeret kasur lagi)* “Anak kemarin sore. Hmm.” *(dialog berakhir)*
- **\[C\]** “Bapak sendiri yang mengajari warga buang sampah ke sungai!” **\[ΔMeter +5 · Sikap −1\]**
  - **\[Pak Darwis\]** (sad) “Kau menuduh aku? Aku sudah makan garam sebelum kau lahir! Tak sopan kau!” *(Narasi: sebuah kantong plastik melayang ke dekat kakimu. Pemicu sampah balasan.)*

**Langkah 5 · Pahami** — \[PIKIRAN\] *Bagaimana menjelaskannya tanpa membuat dia merasa dihakimi?*

- **\[A\]** “Jadi bukan Bapak yang berubah. Sungainya yang tak sanggup lagi: orang makin banyak, dan plastik tak ikut hanyut.” **\[ΔMeter 0 · Sikap +1 Ragu\]**
  - **\[Pak Darwis\]** (neutral) *(lama diam)* “Kasur zaman dulu kapuk, hancur sendiri di air. Yang sekarang ini busa… Iya juga ya.” → lanjut Langkah 6.
- **\[B\]** “Plastik itu ratusan tahun baru hancur, Pak.” **\[ΔMeter +3\]**
  - **\[Pak Darwis\]** (neutral) “Aku tak akan hidup ratusan tahun. Jadi bukan urusanku.” *(dialog berakhir)*
- **\[C\]** “Orang tua memang keras kepala kalau dibilangin.” **\[ΔMeter +5 · Sikap −1\]**
  - **\[Pak Darwis\]** (sad) “Kalau aku keras kepala, kau keras mulut!” *(pemicu sampah balasan)*

**Langkah 6 · Solusi**

- **\[A\]** “Kasur itu kalau dicincang, busanya bisa dijual ke pengepul di hulu, Pak. Lebih baik jadi uang daripada jadi sampah di muara.” **\[ΔMeter −3 · Sikap +1 Peduli\]**
  - **\[Pak Darwis\]** (happy) “Dijual? Busa?” *(jeda)* “Parangku masih tajam. Mulai sekarang kasur ini tak ke sungai lagi.”
  - **\[NARASI\]** Ia menyeret kasur itu kembali ke arah kebun. Kali ini tanpa menoleh ke tebing.
- **\[B\]** “Bapak bawa saja ke TPA sendiri.” **\[ΔMeter 0\]**
  - **\[Pak Darwis\]** (neutral) “TPA itu sepuluh kilo. Kau yang angkat?” *(dialog berakhir)*
- **\[C\]** “Kalau buang lagi, Bapak kulaporkan ke lurah!” **\[ΔMeter +5 · Sikap −1\]**
  - **\[Pak Darwis\]** (neutral) “Lapor lah. Lurah itu keponakanku.” *(pemicu sampah balasan)*

---

### B. Kak Rina (Pedagang Gorengan) · `npc_ibu_desa`

**Langkah 1 · \[NARASI\]** Bau minyak panas dan pisang manis menyambut dari jauh. Kak Rina berdiri di depan wajan hitamnya, menyeka dahi dengan punggung tangan.

**Langkah 2 · \[Kak Rina\]** (happy) “Eh, Dek! Mau gorengan? Baru angkat, panas-panas.”

**Langkah 3 · Dengarkan**

- **\[A\]** “Minyak bekasnya Kakak biasa buang ke mana?” **\[Δ 0\]**
  - **\[Kak Rina\]** (neutral) “Ke selokan belakang, lah. Mau ke mana lagi? Botolnya mahal, tempatnya tak ada.” → lanjut.
- **\[B\]** “Jangan dibuang ke selokan, Kak, nanti mencemari.” **\[ΔMeter +3\]**
  - **\[Kak Rina\]** (neutral) “Iya, iya. Jadi, Dek, mau beli apa tidak?” *(berakhir)*
- **\[C\]** “Kakak sadar tidak, minyak itu merusak sungai?” **\[ΔMeter +5 · Sikap −1\]**
  - **\[Kak Rina\]** (sad) “Adek baru pulang sudah menyalahkan orang yang cari makan?!” *(sampah balasan)*

**Langkah 4 · Pahami**

- **\[A\]** “Repot ya, Kak, kalau tak ada yang mau menampung minyak bekas.” **\[Sikap +1 Ragu\]**
  - **\[Kak Rina\]** (neutral) “Nah! Kalau ada yang mau beli, Kakak kumpul, Dek. Sayang, itu minyak, bukan air.” → lanjut.
- **\[B\]** “Tapi selokan jadi bau dan mampat, Kak.” **\[ΔMeter +3\]**
  - **\[Kak Rina\]** (neutral) “Bau? Kakak yang tiap hari menciumnya.” *(berakhir)*
- **\[C\]** “Gorengan laku, selokan jadi korban.” **\[ΔMeter +5 · Sikap −1\]**
  - **\[Kak Rina\]** (sad) “Oh, jadi Kakak penjahatnya.” *(sampah balasan)*

**Langkah 5 · Solusi**

- **\[A\]** “Kak, kumpulkan di jeriken. Bank sampah beli Rp 3.000 per liter untuk biodiesel.” **\[ΔMeter −3 · Sikap +1 Peduli\]**
  - **\[Kak Rina\]** (happy) “Dibeli?! Tiga ribu seliter? Itu dua bungkus terigu, Dek! Mulai hari ini Kakak simpan jelantahnya.”
- **\[B\]** “Kakak gali lubang saja di tanah.” **\[Δ 0\]**
  - **\[Kak Rina\]** (neutral) “Nanti rembes ke sumur tetangga. Berantem Kakak.” *(berakhir)*
- **\[C\]** “Pokoknya jangan ke selokan lagi!” **\[ΔMeter +5 · Sikap −1\]**
  - **\[Kak Rina\]** (sad) “Pokoknya, pokoknya. Kau kira Kakak buang minyak karena senang?” *(sampah balasan)*

---

### C. Pemuka Desa · `npc_pemuka_desa`

**Langkah 1 · \[NARASI\]** Di balai desa, seorang lelaki tua duduk bersila dengan secangkir kopi hitam. Dua kursi kosong di sebelahnya, seolah memang menunggu seseorang.

**Langkah 2 · \[Pemuka Desa\]** (neutral) “Selamat datang. Di sini, urusan sungai selalu kami bicarakan bersama-sama. Tak ada yang bekerja sendirian.”

**Langkah 3 · \[PILIHAN\]**

- **1.** “Kenapa harus dibicarakan bersama?”
  - **\[Pemuka Desa\]** “Karena sungai melewati rumah semua orang, Nak. Kalau keputusan diambil bersama, semua ikut menjaga. Orang Melayu bilang: *berat sama dipikul, ringan sama dijinjing*.”
- **2.** “Aku siap membantu warga.” **\[+2% Air\]**
  - **\[Pemuka Desa\]** “Bagus. Mulailah dari yang kecil: pilah sampahmu, sapa warga. Kalau hati sudah terbuka, pekerjaan besar jadi ringan.”

**Langkah 4 · \[Gameplay\]** *(tidak berubah)*

1. Pungut dan pilah 10 sampah (organik, plastik, B3 pertanian) ke 3 tong desa (+Rp 1.000 · Kartu `card_pertanian_01`).
2. Bicara dengan Pak Darwis dan Kak Rina (target status Peduli).
3. Buka Kartu `card_gotong_royong_01`.
4. Kesehatan Sungai ≥ 60% → gerbang kota terbuka.

**Langkah 5 · \[NARASI\]** *(saat gerbang terbuka)* Di kejauhan, kota naik seperti dinding. Di antara atap-atapnya, bunyi klakson datang lebih dulu daripada bayangan. Sungai berbelok ke sana, lalu menyempit.

---

## 4. ZONA 3 · KOTA MEDAN

*Misi HUD: “Pilah 6 sampah kota & bicara dengan 4 warga kota & bonus tuas drainase 1-3-2.” Syarat gerbang hilir: 6 sampah terpilah + 4 warga + Kesehatan Sungai ≥ 75%.*

### A. Bang Jali (Warga Gang Padat) · `npc_pedagang`

**Langkah 1 · \[NARASI\]** Di mulut gang yang sempit, seorang lelaki melempar kantong hitam ke got tanpa melihat. Kantong itu mendarat dengan bunyi pelan. Ia menoleh dan mendapati aku menatapnya.

**Langkah 2 · \[Bang Jali\]** (neutral) “Apa lihat-lihat, Bang?”

**Langkah 3 · Dengarkan**

- **\[A\]** “Aku baru pulang, Bang. Boleh aku tanya, kenapa dibuang di situ?” **\[Δ 0\]**
  - **\[Bang Jali\]** (neutral) “Haha. Cemana lagi, Bang? Tong sampah itu di ujung jalan sana, dua ratus meter. Truknya pun tak muat masuk gang. Kau mau bawa kantong ini tiap pagi, sambil kerja, sambil gendong anak?” → lanjut.
- **\[B\]** “Sungai lagi sakit, Bang. Tolong jangan buang sampah ya.” **\[ΔMeter +3\]**
  - **\[Bang Jali\]** (neutral) “Sakit? Aku yang sakit, Bang.” *(berakhir)*
- **\[C\]** “Kalian ini jorok! Gara-gara kalian kampung banjir!” **\[ΔMeter +5 · Sikap −1\]**
  - **\[Bang Jali\]** (sad) “Siapa kau ceramahi aku? Baru pulang sudah sok pintar!” *(sampah balasan)*

**Langkah 4 · Pahami** — \[PIKIRAN\] *Apa yang sebenarnya jadi masalahnya?*

- **\[A\]** “Berarti bukan karena malas. Tempat buangnya yang tak terjangkau.” **\[Sikap +1 Ragu\]**
  - **\[Bang Jali\]** (happy) “Nah! Akhirnya ada yang ngerti, Bang. Kau pikir aku suka kampung ini kumuh?” → lanjut.
- **\[B\]** “Mungkin Abang buru-buru karena kerja ya.” **\[ΔMeter +3\]**
  - **\[Bang Jali\]** (neutral) “Ya… itu juga.” *(ia pergi; berakhir)*
- **\[C\]** “Pokoknya malas! Anak muda sekarang begitu semua.” **\[ΔMeter +5 · Sikap −1\]**
  - **\[Bang Jali\]** (sad) “Aku empat puluh satu, Bang. Kau yang anak muda.” *(sampah balasan)*

**Langkah 5 · Solusi**

- **\[A\]** “Bagaimana kalau kita buat bak sampah roda di mulut gang? Ditarik bergiliran ke jalan besar.” **\[ΔMeter −3 · Sikap +1 Peduli\]**
  - **\[Bang Jali\]** (happy) “Mantap kali ide Abang! Nanti kubilang sama anak-anak muda sini, kita iuran buat bak sampahnya.”
- **\[B\]** “Bawa sajalah ke TPS depan tiap pagi.” **\[Δ 0\]**
  - **\[Bang Jali\]** (neutral) “Kau yang bawa?” *(berakhir)*
- **\[C\]** “Kalau malas ya sampai kiamat pun banjir terus.” **\[ΔMeter +5 · Sikap −1\]**
  - **\[Bang Jali\]** (sad) “Bah.” *(sampah balasan)*

---

### B. Warga Kota Lainnya

**1. Ibu Rumah Tangga** · `npc_ibu_rumah` → Kartu `card_b3_01`

**\[Ibu Rumah Tangga\]** (neutral) “Got di belakang rumahku mampat lagi. Kemarin kuangkat plastiknya, hari ini sudah penuh. Yang buang entah siapa.”

**\[Ibu Rumah Tangga\]** (neutral) “Kalau mau lihat sumbernya, di bawah jembatan ada pintu air. Tuasnya tiga, sudah lama tak ada yang berani sentuh.”

*(Edukasi limbah rumah tangga: baterai, lampu bekas, dan obat kadaluarsa jangan dicampur sampah biasa.)*

**2. Budi, Anak Sekolah** · `npc_anak_sekolah` → Kartu `card_pantun_01`

**\[Budi\]** (happy) “Bang! Tadi di sekolah Ibu Guru suruh kami hafal pantun. Aku sampai pusing cari sampirannya.”

**\[Budi\]** (happy) “Kata Ibu Guru, pantun itu cara orang Melayu menyampaikan yang berat dengan cara yang ringan. Jadi tak ada yang tersinggung.”

**\[PIKIRAN\]** Mungkin itu juga rahasia untuk bicara pada Pak Darwis dan Bang Jali: yang berat disampaikan dengan ringan.

**3. Pak RT** · `npc_tokoh_masyarakat`

**\[Pak RT\]** (neutral) “Orang Melayu Deli sejak dulu menyebut sungai *urat nadi*. Kalau urat nadi tersumbat, tubuhnya yang sakit.”

**\[Pak RT\]** (neutral) “Musyawarah dan gotong royong itu bukan hiasan, Nak. Itu cara kami mengangkat sesuatu yang tak mungkin diangkat satu orang.”

---

### C. Puzzle Drainase Kota (Tuas 1 → 3 → 2)

**Langkah 1 · \[NARASI\]** Di bawah jembatan, tiga tuas besi berkarat berjajar, dengan angka yang nyaris terhapus: *I*, *III*, *II*. Tak ada yang menyentuhnya selama bertahun-tahun.

**Langkah 2 · \[Ibu Rumah Tangga / Pak RT\]** *(petunjuk, opsional, muncul jika pemain gagal dua kali)* “Buka yang paling depan dulu, lalu yang paling belakang, baru yang tengah. Supaya air tak datang sekaligus.”

**Langkah 3 · \[AKSI\]** Pemain menarik tuas dengan urutan benar: **1 → 3 → 2**.

**Jika salah:** tuas berderak, terkunci, lalu kembali ke posisi awal. Narasi: *Besi itu menolak dengan bunyi seperti orang yang menghela napas.* **\[+2% Meter Bencana\]**

**Jika benar:** tuas ketiga bergeser, dan dari dalam tanah terdengar bunyi panjang seperti napas yang ditahan lama lalu dilepas.

- **\[NARASI\]** Air mengalir deras di bawah kaki, jernih, mencari jalan yang selama ini terhalang.
- **\[Efek\]** Kesehatan Sungai +10% · +Rp 2.500 · Kartu `card_drainase_01`.

**Langkah 4 · \[NARASI\]** *(saat gerbang hilir terbuka)* Bau garam mulai terbawa angin. Sungai yang tadi menyempit di kota kini melebar, pelan-pelan, seperti orang yang akhirnya boleh bernapas panjang.

---

## 5. ZONA 4 · HILIR SUNGAI DELI (Muara & Pesisir)

*Misi HUD: “Tanam 8 Mangrove, Pilah 10 Sampah Pesisir, & Bicara dengan 2 Warga.” Syarat gerbang epilog: 8 mangrove + 10 sampah terpilah + 2 warga + Kesehatan Sungai ≥ 80%.*

### A. Pak Nelayan · `npc_nelayan`

**Langkah 1 · \[NARASI\]** Muara terbuka seperti telapak tangan. Air sungai dan air laut bertemu di sini tanpa bersalaman, hanya saling mendorong pelan. Perahu-perahu kayu bersandar miring di lumpur, dan di antara akar-akar bakau yang tersisa, plastik tersangkut seperti bendera menyerah.

**Langkah 2 · \[Pak Nelayan\]** (neutral) “Hati-hati melangkah, Nak. Banyak pecahan botol. Dulu sepanjang pantai ini bakau semua. Sekarang tinggal gigi-gigi yang ompong.”

**Langkah 3 · \[PILIHAN\]**

- **1.** “Aku bisa bantu tanam mangrove.” **\[+3% Air\]**
- **2.** “Kenapa mangrove sepenting itu, Pak?”
  - **\[Pak Nelayan\]** “Di bawah akarnya, anak ikan bersembunyi sampai cukup besar untuk takut. Pantai pun begitu: kalau akarnya hilang, ombak makan tanah sedikit demi sedikit, tak pernah sekaligus. Makanya orang tak sadar.”
  - **\[MC\]** “Kalau begitu aku tanam.” **\[+3% Air\]**

**Langkah 4 · \[Dialog Penutup\] Pak Nelayan** (neutral) “Titik tanamnya kutandai di tepian. Dekati, tekan aksi. Kami cari makan dari laut yang sehat. Kalau laut sakit, anak-anak kami yang pergi merantau.”

**\[PIKIRAN\]** Aku berhenti sebentar. Kata itu, merantau, terasa seperti sesuatu yang kukenal sendiri.

---

### B. Penjaga Sungai · `npc_penjaga_sungai`

**Langkah 1 · \[NARASI\]** Di dekat pos pemantau, gunungan sampah menyumbat mulut muara, tinggi dan lengket oleh pasang surut.

**Langkah 2 · \[Penjaga Sungai\]** (neutral) “Lihat itu. Semua yang dibuang di hulu akhirnya sampai ke sini. Muara itu tempat sungai menyerahkan semua yang dibawanya.”

**Langkah 3 · \[PILIHAN\]** “Ayo kita hadapi bersama.” **\[Quest: Pilah 10 sampah di hilir\]**

**Langkah 4 · \[Penjaga Sungai\]** (neutral) “Susuri pesisir, pungut yang berserakan, pilah sesuai jenisnya. Pelan-pelan saja. Gunungan ini juga tak datang dalam sehari.”

---

### C. Papan Pantun Melayu Deli · `pantun_board` · `pantun_data.json`

**Langkah 1 · \[NARASI\]** Papan kayu tua tertancap di pasir, ditulisi kapur yang hampir pudar. Dua baris pertama selalu ada. Dua baris sisanya hilang, dan menunggu diisi.

**Langkah 2 · \[AKSI\]** Pemain membaca sampiran dan memilih isi yang bersajak (a-b-a-b) *dan* bermakna. Jawaban benar = **\[ΔMeter −2%\]**. Jawaban salah tidak menghukum, hanya papan tetap kosong dan bisa dicoba lagi.

**Pantun 1 · Datuk Sampan (Pelestarian Sungai)**

> Sampan tua menyusur tebing, Pagi berkabut di hulu Deli.

- **\[A\] (benar)**

  > Sungai dirawat airnya bening, Apa dibuang pasti kembali.
- **\[B\]** “Biar sungai mengalir deras, / Sampah hanyut ke mana-mana.”
- **\[C\]** “Sungai itu urusan pemerintah, / Kita cukup menonton saja.”

**Pantun 2 · Kak Rina (Jelantah)**

> Pagi hari menggoreng pisang, Wajan hitam di atas tungku.

- **\[A\] (benar)**

  > Minyak sisa jangan dibuang, Ditampung dulu, jadi rezeki baru.
- **\[B\]** “Minyak sisa buang ke got, / Biar hanyut entah ke mana.”
- **\[C\]** “Minyak sisa dibakar saja, / Asapnya hilang di udara.”

**Pantun 3 · Bang Jali (Gotong Royong TPS)**

> Lewat gang membawa karung, Menuju TPS di ujung jalan.

- **\[A\] (benar)**

  > Kerja bersama hati tak murung, Sampah terangkut, ringan pikiran.
- **\[B\]** “Biarkan saja urusan orang, / Sampah menumpuk di mana-mana.”
- **\[C\]** “Buang saja ke tepi kali, / Besok pagi hilang sendiri.”

**Langkah 3 · \[NARASI\]** *(jawaban benar)* Kapur itu seperti menyala sebentar, lalu tenang. Ada yang mengisi baris yang hilang, dan terasa bukan aku saja.

---

### D. Menanam 8 Mangrove & Membersihkan Muara

**Langkah 1 · \[AKSI\]** Pemain menanam 8 bibit di bibir pantai (+Rp 2.000 · Kartu `card_mangrove_01`).

**Langkah 2 · \[AKSI\]** Memungut dan memilah 10 sampah pesisir (Kartu `card_pesisir_01`).

**Langkah 3 · \[NARASI\]** *(bibit terakhir tertanam)* Bibit-bibit itu tak lebih tinggi dari jariku. Mereka berdiri di lumpur dengan keyakinan yang tak masuk akal, seperti semua awal yang baik.

**Langkah 4 · Syarat:** Kesehatan Sungai ≥ 80% (Meter Bencana ≤ 20%).

**Langkah 5 · \[NARASI\]** *(gerbang epilog terbuka)* Angin berubah arah. Dari muara, tampak aliran sungai yang tadi kususuri, utuh dari hulu sampai laut, seperti urat nadi yang akhirnya mengalirkan darah lagi. Aku berjalan masuk ke fajar yang belum sepenuhnya datang.

---

## 6. EPILOG · EMPAT AKHIR

*Sistem tetap mengevaluasi: Persentase Utang Lunas = (500.000 − Utang) / 500.000 × 100%.*

### 🌟 ENDING A · “Harapan Baru Deli”

**Syarat:** Meter Bencana ≤ 20%, Jali, Rina, dan Darwis semuanya Peduli, Utang Lunas 100%. Air biru kristal `Color(0.18, 0.65, 0.92)`.

**Langkah 1 · \[NARASI\]** Enam bulan kemudian. Pukul lima pagi, dan dari dalam warung terdengar bunyi yang sudah lama hilang: sendok beradu gelas.

**Langkah 2 · \[NARASI\]** Tujuh meja kembali berdiri. Dindingnya sudah dicat ulang, kecuali satu garis tipis setinggi dada yang sengaja dibiarkan Bapak. “Biar kita ingat,” katanya.

**Langkah 3 · \[Pak Hendra\]** (happy) “Atap sudah kutambal. Sebelum hujan, kali ini.”

**Langkah 4 · \[NARASI\]** Mak membuka buku catatan lusuh itu, menyobek halaman utang, lalu melipatnya kecil-kecil dan menyelipkannya ke bawah toples gula yang baru. Ia tak berkata apa-apa. Tak perlu.

**Langkah 5 · \[Pak Hendra\]** (happy) “Warga sekarang kerja bakti tiap Minggu, jaga tanggul. Bang Jali yang pegang iuran bak sampah. Kak Rina setor jelantah tiap Kamis. Pak Darwis…” *(ia tertawa)* “dia yang paling rajin cincang kasur.”

**Langkah 6 · \[NARASI\]** Aku berjalan ke sungai. Airnya jernih sampai ke dasar, dan batu-batunya yang dulu tak pernah kulihat kini bisa kuhitung. Di tengah arus, sebuah sampan tertambat tanpa tali.

**Langkah 7 · \[Datuk Sampan\]** (happy) “Aku bukan hantu, Nak. Aku ingatan kampung ini tentang cara menjaga sungai. Ingatan perlu orang yang mengingatnya. Selama ada yang mengingat, aku ada.”

**Langkah 8 · \[NARASI\]** Datuk Sampan tersenyum. Tubuhnya berpendar keemasan, lalu menyatu pelan-pelan dengan aliran air yang jernih, seperti tak pernah pergi dan tak pernah benar-benar ada.

**Langkah 9 · \[PIKIRAN\]** (happy) Waktu tak bisa diputar kembali. Yang bisa hanya kebiasaan. Dan kebiasaan, ternyata, dimulai dari mendengar.

---

### 🌤 ENDING B · “Keluarga Mandiri”

**Syarat:** Meter Bencana ≤ 40%, minimal 2 warga Peduli. Air biru kehijauan `Color(0.28, 0.58, 0.78)`.

**Langkah 1 · [NARASI]** Hujan datang lagi bulan itu, deras seperti dulu. Warung kami basah, tapi tidak tenggelam.

**Langkah 2 · [Bu Mira]** (happy) “Air naik sampai tangga kedua. Dulu sampai meja. Kita tak menang, Nak, tapi kita tak kalah seperti dulu.”

**Langkah 3 · [PIKIRAN]** (happy) Tempat makan Mak sudah kembali bersih dan mulai ramai pelanggan, menghidupkan kembali harapan yang sempat tersapu banjir.

**Langkah 4 · [Datuk Sampan]** (happy) “Kau tak sendirian lagi, Nak. Yang tadinya hanya mendengar, sekarang ada yang ikut menjaga. Teruskan.”

---

### 🌥 ENDING C · “Bertahan di Tepian”

**Syarat:** Meter Bencana ≤ 60%, minimal 1 warga Peduli. Air keruh keabuan `Color(0.42, 0.52, 0.58)`.

**Langkah 1 · [NARASI]** Hujan lebat datang lagi. Warung bertahan, dindingnya basah sampai ke garis lumpur yang lama. Perbaikan tempat makan masih tersendat, dan sungai masih rawan.

**Langkah 2 · [PIKIRAN]** (sad) Seperti menambal atap saat hujan sudah turun. Bisa, tapi tak pernah benar-benar kering.

**Langkah 3 · [Datuk Sampan]** (neutral) “Sungai belajar dari kita, seperti kita belajar darinya. Jalanmu masih panjang. Jangan berhenti di tengah.”

---

### 🌧 ENDING D · “Terpaksa Menyerah” (dengan Mekanik Rewind)

**Syarat:** Meter Bencana > 60%, atau tidak memenuhi kriteria lain. Pesan moral: **“Satu orang membuang, semua menanggung.”**

**Langkah 1 · \[NARASI\]** Banjir bandang datang malam hari, tanpa memberi aba-aba. Air coklat pekat menelan bantaran, lalu menelan warung, lalu menelan bunyi-bunyi yang tersisa.

**Langkah 2 · \[NARASI\]** Pagi harinya, warung orang tuaku hanya tinggal tiang. Di atas lumpur yang mengeras, sepasang sandal masih berpasangan.

**Langkah 3 · \[Datuk Sampan\]** (sad) “Sungai tak membenci siapa pun, Nak. Ia hanya kembali ke jalannya.” *(jeda)* “Kalau kau diberi kesempatan sekali lagi, dengarkan dulu sebelum bicara.” *(ia memudar, lalu lenyap)*

**Langkah 4 · \[PIKIRAN\]** (sad) Satu orang membuang. Semua yang menanggung.

**Langkah 5 · \[Mekanik\]** Tombol utama berubah menjadi **“Rewind”** (`GameState.rewind()`).

**Langkah 6 · \[NARASI\]** *(saat Rewind ditekan)* Air surut mundur. Lumpur naik kembali ke dinding, garisnya menghilang, dan dari kejauhan terdengar bunyi sendok beradu gelas pukul lima pagi. Waktu berputar ke awal. Yang tidak ikut terputar adalah apa yang telah kupelajari.

---

## 7. Rekap Statistik Akhir

*Tidak ada perubahan.* Kartu rangkuman tetap menampilkan Meter Bencana, Kejernihan Air, Warga Peduli (x/3), Persentase Utang Lunas, Sampah Terkumpul, Pohon & Mangrove, Kartu Kearifan Lokal, dan Total Saldo Rupiah.

---

## 8. Catatan Implementasi

1. **Respons B/C yang baru:** pilihan B dan C pada Langkah 2 dan 3 (Darwis, Rina, Jali) sebelumnya tidak punya respons. Teks barunya perlu ditambahkan ke `h6_darwis.json`, `h4_rina.json`, dan `h2_jali.json`.
2. **“Mak” vs “Ibu”:** kalau ingin konsisten, ganti panggilan MC ke Bu Mira di semua JSON (`h1_warung.json`, prolog Bab 2).
3. **Hint tuas drainase** (Langkah 2 puzzle) adalah tambahan. Ia opsional dan bisa dipicu setelah dua kegagalan.
4. **Narasi transisi gerbang** (Hulu, Desa, Kota, Hilir) adalah tambahan untuk menyambung antarzona. Kalau tidak ada slot narasi di game, bisa dibuang tanpa merusak alur.
5. **Tiga motif** perlu dijaga di dialog tambahan ke depan: *sebelum hujan*, *bunyi sendok pukul lima*, dan *mendengar*.

---

## 9. JALUR “BAGAIMANA JIKA?” — BANJIR PEMICU

**Masalah di versi sebelumnya:** bencana hanya dicek di epilog. Padahal pemain yang membuat pilihan kasar berulang kali bisa sampai ke titik di mana Meter Bencana sudah terlalu tinggi dan tugas yang tersisa tak cukup untuk menurunkannya. Cerita harus bereaksi saat itu terjadi, bukan menunggu sampai akhir.

**Prinsip:** bencana tidak datang tiba-tiba. Pemain diberi pertanda, lalu peringatan, baru banjir. Banjirnya sendiri adalah konsekuensi dari pilihan mereka, bukan hukuman acak.

*Catatan: Meter Bencana 80% setara Kesehatan Sungai 20%. Aturan teknis pemicu ada di PRD bagian 18.*

### 9.1 Tahap Pertanda (Meter Bencana ≥ 65%)

**Langkah 1 · \[NARASI\]** Langit di atas Deli berubah. Bukan hitam, hanya lebih rendah, seperti atap yang pelan-pelan menunduk. Gerimis mulai terdengar di seng warung.

**Langkah 2 · \[PIKIRAN\]** (neutral) Belum hujan sungguhan. Tapi bunyinya sudah seperti sesuatu yang sedang berlatih.

### 9.2 Tahap Siaga (Meter Bencana ≥ 75%)

*HUD berkedip. Datuk Sampan muncul satu kali saja, di tepi air terdekat.*

**Langkah 1 · \[Datuk Sampan\]** (sad) “Kau dengar sungainya?”

**Langkah 2 · \[MC\]** (neutral) “Aku tak dengar apa-apa.”

**Langkah 3 · \[Datuk Sampan\]** (sad) “Itu dia. Sungai yang sehat selalu berisik. Yang diam sedang menahan sesuatu.” *(jeda)* “Kalau masih ada yang bisa kau dengarkan, dengarkan sekarang.”

### 9.3 Banjir Pemicu

*Terjadi saat Meter Bencana ≥ 80%, atau saat sistem menghitung bahwa meter tak mungkin lagi diturunkan ke bawah 50% (Titik Tak Kembali). Pemain berada di zona mana pun saat itu; adegan menyesuaikan.*

**Langkah 1 · \[AKSI\]** Kontrol pemain dikunci. Musik berhenti. Hanya bunyi air.

**Langkah 2 · \[NARASI\]** *(varian sesuai zona)*

**Hulu** Hujan di hulu turun tanpa akar yang menahan. Tanah ikut lari bersama air, dan air itu bukan lagi bening: coklat, berat, membawa batang-batang pohon. Dari kejauhan, bunyinya seperti kereta yang tidak punya rel.

**Desa** Air naik dari kebun, bukan dari sungai. Bale bambu terangkat dari tiangnya lalu hanyut. Kasur-kasur busa yang dulu dilepas ke air kembali, mengapung, menyumbat bawah jembatan, dan membuat air mencari jalan lain: lewat rumah-rumah.

**Kota** Got meluap lebih dulu, lalu jalan, lalu mulut gang. Plastik naik ke permukaan seperti ikan yang mati. Di bawah jembatan, tiga tuas besi tenggelam tanpa bunyi.

**Hilir** Pasang laut bertemu air kiriman dari hulu. Muara yang tersumbat gunungan sampah menolak menerima apa pun, jadi air berbalik ke daratan. Perahu-perahu terangkat, lalu terbanting di atas atap.

**Langkah 3 · \[NARASI\]** *(adegan keluarga, semua varian)* Di warung, Bapak naik ke atap membawa termos penyok. Mak berdiri di ambang pintu memeluk buku catatan utang itu di dadanya, seolah hanya itu yang bisa diselamatkan.

**Langkah 4 · \[Pak Hendra\]** (sad) “Naik, Nak! Naik ke atas!”

**Langkah 5 · \[Bu Mira\]** (sad) “Biarkan sajalah semuanya. Yang penting kau.”

**Langkah 6 · \[Reaksi warga\]** *(bergantung Sikap, tampil singkat sebagai teks melayang)*

- **Pak Darwis Peduli:** *“Kasur itu belum kujual… bantu anak-anak itu dulu, Nak!”* (ia menggendong dua anak tetangga.)
- **Pak Darwis Menolak/Acuh:** *“Jadi begini rupanya yang kau bilang kemarin.”* (ia tak menatap)
- **Kak Rina Peduli:** *“Jeriken-jeriken itu, Dek, jangan sampai bocor ke air!”*
- **Kak Rina Menolak/Acuh:** *“Sudah kubilang selokan itu tak apa-apa…”* (suaranya pecah di tengah)
- **Bang Jali Peduli:** *“Bak roda! Dorong ke atas jembatan, cepat!”*
- **Bang Jali Menolak/Acuh:** *“Bah, ini bukan salahku!”* (lalu diam, menatap air)

**Langkah 7 · \[PIKIRAN\]** (sad) Aku pikir masih ada waktu. Ternyata sungai tak pernah menunggu aku selesai belajar.

**Langkah 8 · \[Transisi\]** Layar memutih, lalu memudar ke **Ending D** (varian “Banjir Pemicu”). Semua progres kartu pengetahuan tersimpan.

### 9.4 Ending D — Varian Banjir Pemicu

**Langkah 1 · \[NARASI\]** Pagi setelah banjir, Deli kembali tenang, seolah tak terjadi apa-apa. Hanya garis lumpur di dinding yang kini lebih tinggi dari yang lama.

**Langkah 2 · \[Datuk Sampan\]** (sad) “Sungai tak membenci siapa pun, Nak. Ia hanya kembali ke jalannya.” *(jeda)* “Belum terlambat untuk mendengar. Tapi lain kali, mulailah sebelum hujan.” *(ia memudar)*

**Langkah 3 · \[PIKIRAN\]** (sad) Satu orang membuang. Semua yang menanggung.

**Langkah 4 · \[Mekanik\]** Tombol utama berubah menjadi **“Rewind”**.

### 9.5 Catatan Datuk setelah Rewind (satu kali, di awal putaran baru)

*Datuk memberi satu petunjuk sesuai penyebab dominan kegagalan. Ini mengubah ending buruk menjadi pelajaran.*

| Penyebab dominan | Kalimat Datuk |
| --- | --- |
| Banyak memilih opsi \[C\] (menuduh) | “Kemarin kau bicara lebih cepat daripada mendengar. Coba lain kali pelankan.” |
| Banyak memilih opsi \[B\] (menggurui) | “Memberi tahu itu bukan mendengarkan, Nak. Tanyalah dulu.” |
| Sampah banyak diabaikan | “Telinga saja tak cukup. Tangan juga perlu bekerja.” |
| Puzzle dan penanaman terlewat | “Ada hal-hal yang tak bisa diselesaikan dengan bicara. Pohon, misalnya.” |

**Langkah 5 · \[NARASI\]** *(saat Rewind ditekan)* Air surut mundur. Lumpur naik kembali ke dinding. Dari kejauhan, bunyi sendok beradu gelas pukul lima pagi. Waktu berputar ke awal. Yang tak ikut terputar adalah apa yang telah kupelajari.
