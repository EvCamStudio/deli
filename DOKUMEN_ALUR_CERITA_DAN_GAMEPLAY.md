# DOKUMEN MASTER ALUR CERITA, SEMUA DIALOG, & ALUR GAMEPLAY
## Deli Rewind — Versi Naskah Sastra Terintegrasi (Claude, Hezron, Ridwan, & Aisyah)

Dokumen ini adalah naskah master dan pedoman cerita resmi dari game *Deli Rewind*, menggabungkan alur petualangan top-down Sungai Deli dengan naskah revisi sastra yang mengedepankan prinsip *Show, Don't Tell*, keotentikan budaya Melayu Deli / Medan, dan sistem empati 3 langkah.

---

# 1. PRINSIP PENULISAN & TIGA MOTIF UTAMA

### Prinsip Utama:
1. **Tunjukkan lewat benda (*Show, Don't Tell*)**: Emosi tidak diumumkan secara harafiah, melainkan ditunjukkan lewat garis lumpur di dinding setinggi dada, toples gula yang hanyut, sandal jepit yang masih berpasangan di lumpur, dan termos penyok Bapak.
2. **Subteks & Nuansa Manusiawi**: Orang jarang mengatakan persis apa yang mereka rasakan. Mak berkata *"jangan kau pulang"* padahal maksudnya *"pulanglah"*. Warga memiliki alasan di balik perilakunya.
3. **Sentuhan Bahasa Medan–Melayu Deli**: Menggunakan kata sapaan khas seperti *Mak, kau, Bang, cemana, kali, lah, bah, anak kemarin sore*.
4. **Makna Judul *Rewind***: Waktu tidak bisa diputar kembali, tetapi kebiasaan bisa.

### Tiga Motif Utama yang Mengikat Seluruh Cerita:
1. **"Sebelum hujan, bukan sesudahnya"** — Wejangan Bapak tentang atap dan pencegahan.
2. **Bunyi sendok beradu gelas pukul lima pagi** — Simbol kehangatan dan denyut kehidupan warung kopi keluarga.
3. **Mendengar** — Wejangan pertama Datuk Sampan yang menjadi nyawa dari sistem dialog empati 3 langkah.

---

# 2. PROLOG: INTRO DRAMATIS (KOMIK INTERAKTIF)

* **Scene**: `res://scenes/intro/intro_dramatic.tscn`
* **Skrip**: `res://scripts/intro/intro_dramatic.gd`

---

### BAB 1: JAKARTA — HARI PERTAMA KERJA
* **Latar Visual**: Kantor modern Jakarta, pagi hari, jendela kaca memantulkan langit.
* **Header**: `BAB 1 · JAKARTA — HARI PERTAMA KERJA`

1. **[NARASI]**:
   > *"Lantai dua puluh dua. Pagi itu kaca gedung memantulkan langit sebersih kertas baru, dan kopi di mejaku masih mengepul."*
2. **[Manajer]** (neutral):
   > *"Selamat datang. Isi formulir ini dulu untuk data HRD. Nama lengkap, jangan disingkat."*
3. **[AKSI PEMAIN]**:
   * Mengetik nama pada kolom input: `[ Masukkan Nama ]` lalu klik tombol `[ Konfirmasi ]`.
   * Nama disimpan ke `GameState.player_name`.
4. **[Manajer]** (neutral):
   > *"{nama}. Oke. Kontrak satu tahun. Jangan buat saya menyesal."*
5. **[PIKIRAN MC]** (neutral):
   > *"Gaji pertama sudah kuhitung di kepala. Separuhnya untuk Medan, untuk atap warung yang bocor tiap hujan."*
6. **[PIKIRAN MC]** (neutral):
   > *"Bapak selalu bilang atap itu urusan sebelum hujan, bukan sesudahnya. Aku tersenyum. Sebelum hujan, ada waktu."*

---

### BAB 2: JAKARTA — PHK
* **Latar Visual**: Kantor malam hari, lampu setengah mati, hujan badai di luar kaca.
* **Header**: `BAB 2 · JAKARTA — PHK`

1. **[NARASI]**:
   > *"Sebelas bulan kemudian, hujan mengetuk kaca seperti orang yang tak sabar. Separuh meja di lantai ini sudah kosong. Yang tersisa hanya bekas debu berbentuk kotak."*
2. **[Manajer]** (neutral):
   > *"Duduk dulu, {nama}. Perusahaan sedang efisiensi. Kontrakmu tidak diperpanjang. Saya minta maaf."*
3. **[NARASI]**:
   > *"Selembar surat, dua paragraf. Sebelas bulanku muat di sana, dan masih menyisakan ruang kosong."*
4. **[MC]** (sad):
   > *"Baik, Pak. Terima kasih."*
5. **[PIKIRAN MC]** (sad):
   > *"Terima kasih. Kata yang paling sopan untuk sesuatu yang sebenarnya tak ingin kuucapkan."*
6. **[NARASI]**:
   > *"Saat kardus itu penuh, ponselku bergetar di atas meja. Di layar: Mak."*
7. **[TELEPON MASUK - Bu Mira / Mak]**:
   > *"Nak… sungai naik. Bapakmu lagi angkat kursi ke atas meja. Kau tak usah pulang, kerja sajalah di sana... Eh. Pulang lah, kalau sempat."*
8. **[MC]** (sad):
   > *"Mak? Mak…"*
9. **[PIKIRAN MC]** (sad):
   > *"Sambungan putus. Hujan di Jakarta dan hujan di Medan. Aku tak tahu itu hujan yang sama atau bukan, tapi malam itu aku membeli tiket."*

---

### BAB 3: MEDAN — KEMBALI KE WARUNG
* **Latar Visual**: Tepi Sungai Deli, langit kelabu, warung kayu berlumpur.
* **Header**: `BAB 3 · MEDAN — TEPI SUNGAI DELI`

1. **[NARASI]**:
   > *"Medan, dua hari kemudian. Deli sudah surut, tetapi surut bukan berarti pergi. Ia meninggalkan jejaknya setinggi dada di dinding setiap rumah."*
2. **[NARASI]**:
   > *"Warung kami berdiri miring di bantaran, seperti orang yang menahan tangis. Garis lumpur melintang di dindingnya, lurus dan tak bisa dibantah. Kursi-kursi telentang. Toples gula entah di mana."*
3. **[PIKIRAN MC]** (sad):
   > *"Dulu pukul lima pagi di sini ada bunyi sendok beradu gelas. Sekarang hanya air yang menetes dari atap."*
4. **[NARASI]**:
   > *"Di tepi sungai, sampah menumpuk setinggi pinggang: kasur, kantong plastik, botol, dan sepasang sandal yang masih berpasangan. Air telah mencari jalannya, dan jalan itu sudah diambil."*
5. **[PIKIRAN MC]** (sad):
   > *"Sebanyak ini. Sejak kapan ia menumpuk? Dan kenapa aku tak pernah melihatnya?"*
6. **[TRANSISI GAMEPLAY]**:
   * Layar memudar ke hitam (*fade to black*).
   * GameState berpindah: `in_world = true`, `world_zone = "hulu"`.
   * Pemain langsung muncul di depan warung keluarga di zona Hulu.

---

# 3. ZONA 1: HULU SUNGAI DELI (MATA AIR & HUTAN)

* **Lokasi**: Warung panggung tepi sungai, tebing berbatu, mata air, dan hutan hulu.
* **Status Awal**: Kesehatan Sungai = `40%` (Meter Bencana = `60%`), Utang = `Rp 500.000`.

---

### A. Misi 1: Warung Keluarga (Mak & Bapak)
* **NPC**: `npc_ibu_mc` (`Bu Mira` & `Pak Hendra`)
* **File Dialog**: `res://data/dialog/h1_warung.json`

```
[Bu Mira] (neutral): "(sapu berhenti) Sudah sampai kau."
[MC] (neutral): "Maaf, Mak. Harusnya aku pulang lebih cepat."
[Bu Mira] (sad): "Banjir tak menunggu siapa-siapa, Nak. Jangan kau pikul yang bukan bagianmu."
[Pak Hendra] (sad): "(menunjuk garis lumpur di dinding) Setinggi situ. Gula, kopi, kursi, hanyut semua. Toples biru Mak pun."
[Bu Mira] (sad): "Sudahlah, Pak... Dua bulan lalu air naik sedikit. Kami pinjam lima ratus ribu untuk menambal dinding. Minggu ini air naik lagi, dan tambalannya ikut hanyut."
[MC] (sad): "(Di Jakarta, lima ratus ribu cuma dua kali makan malam dan ongkos. Di sini, ia sebuah dinding yang sudah roboh.)"
[Pak Hendra] (neutral): "Jangan kau benci sungai itu, Nak. Air itu mencari jalan, sama seperti orang. Kalau jalannya kita tutup, dia lewat rumah kita."
```
* **Pilihan Percabangan**:
  * **[A]** *"Aku mulai dari sungainya dulu, Pak."*
    * ➜ **[Bu Mira]** (happy): *"Bawa topi. Matahari hulu tak kenal anak Jakarta."*
  * **[B]** *"Aku cari kerja dulu, Mak. Utang itu harus dibayar."*
    * ➜ **[Bu Mira]** (neutral): *"Boleh. Cari kerja bisa besok, lumpur ini tak bisa menunggu. Sehari saja, ya."*

---

### B. Misi 2: Datuk Sampan
* **NPC**: `npc_datuk`
* **File Dialog**: `res://data/dialog/h1_datuk.json`

```
[MC] (surprised): "Siapa di situ?"
[Datuk Sampan] (neutral): "Orang yang melamun di tepi air biasanya tak sadar ada yang menemani."
[MC] (neutral): "Aku terlalu capek. Kalau kau halusinasi, tolong cepat hilang."
[Datuk Sampan] (neutral): "Kalau aku halusinasi, aku halusinasi yang tahu nama setiap batu di sungai ini. Panggil saja Datuk Sampan. Aku kenal bapakmu waktu ia setinggi itu."
[Datuk Sampan] (neutral): "Sungai tak minta dipuji, Nak. Ia hanya minta dijaga."
[MC] (sad): "Menjaga sungai sendirian? Aku bahkan tak bisa menjaga pekerjaanku."
[Datuk Sampan] (happy): "Tak ada yang bisa sendirian. Makanya, besok jangan mulai dengan tangan. Mulailah dengan telinga. Setiap orang di sini punya alasan untuk sampah yang mereka buang. Dengar alasannya dulu."
```

---

### C. Misi 3: Penjaga Hutan & 5 Pohon
* **NPC**: `npc_penjaga_hutan`
* **File Dialog**: `res://data/dialogues/level1.json`

```
[Penjaga Hutan]: "Kau dengar itu? Dulu bunyinya seperti hujan yang tak habis-habis... Sekarang dengar sendiri."
Pilihan:
  1. "Apa yang terjadi di sini, Pak?"
     -> [Penjaga Hutan]: "Pohonnya ditebang. Akar itu semacam spons, Nak. Tanpa akar, hujan tak sempat meresap. Ia langsung lari ke bawah, membawa tanah, sampai ke rumah-rumah kalian."
     -> [MC]: "Bibitnya di mana?" (+2% Air, Quest: Tanam 5 pohon di Hulu)
  2. "Aku bisa bantu." (+2% Air)
     -> [Penjaga Hutan]: "(melirik tanganmu) Tangan orang kantoran. Tak apa, tanah tak pilih-pilih. Tanah bertanda itu: dekati, tekan aksi. Tak usah dalam-dalam, cukup tak terbalik."
     -> [MC]: "Siap!" (Quest: Tanam 5 pohon di Hulu)

Dialog Penutup [Penjaga Hutan]:
"Pohon yang kau tanam hari ini mungkin tak sempat kau teduhi. Tak apa. Pohon yang meneduhimu sekarang pun bukan kau yang tanam."
```

* **Syarat Gerbang Desa Terbuka**: Minimal 5 pohon tertanam + Kesehatan Sungai $\ge 40\%$.
* *Narasi Transisi*: *"Di bawah, atap-atap seng desa berkilat basah. Di sebuah belokan sungai, sekilas, ada sampan yang berlayar tanpa dayung."*

---

# 4. ZONA 2: DESA SUNGAI DELI (BANTARAN & PERTANIAN)

* **Misi**: Pilah 10 sampah desa & Bicara dengan 2 warga (Pak Darwis & Kak Rina).
* **Syarat Gerbang Kota**: 10 sampah terpilah + 2 warga diajak bicara + Kesehatan Sungai $\ge 60\%$.

---

### A. Pak Darwis (Petani Bantaran)
* **File Dialog**: `res://data/dialog/h6_darwis.json`
* **Kalimat Pembuka**:
  > *"Dulu kasur rusak kami lepas ke air, hanyut sendiri sampai ke laut. Tak ada yang marah. Sekarang tiba-tiba itu dosa. Zaman ini memang aneh."*

* **Langkah 1 (Dengarkan)**:
  * **[A]** *"Dulu sungainya seperti apa, Pak? Waktu Bapak muda."* ($\Delta\text{Meter}=0$, $\Delta\text{Sikap}=0$)
    * ➜ [Pak Darwis] (happy): *"Bening, Nak. Ikan lewat bisa kau lihat sebelum sampai ke kaki. Kami mandi di situ, cuci piring di situ. Orangnya sedikit. Apa yang kami lepas, sungai terima, dan dia diam saja."* ➜ Lanjut Langkah 2.
  * **[B]** *"Cara itu sudah tidak cocok sekarang, Pak."* ($\Delta\text{Meter}=+3$)
    * ➜ [Pak Darwis] (neutral): *"(menyeret kasur lagi) Anak kemarin sore. Hmm."* (Berakhir).
  * **[C]** *"Bapak sendiri yang mengajari warga buang sampah ke sungai!"* ($\Delta\text{Meter}=+5$, Sikap $\rightarrow$ Menolak)
    * ➜ [Pak Darwis] (sad): *"Kau menuduh aku? Aku sudah makan garam sebelum kau lahir! Tak sopan kau!"* (Pemicu Sampah Balasan).

* **Langkah 2 (Pahami)**:
  * Pertanyaan MC: *"Bagaimana menjelaskannya tanpa membuat dia merasa dihakimi?"*
  * **[A]** *"Jadi bukan Bapak yang berubah. Sungainya yang tak sanggup lagi: orang makin banyak, dan plastik tak ikut hanyut."* ($\Delta\text{Sikap}=+1$ Ragu)
    * ➜ [Pak Darwis] (neutral): *"(lama diam) Kasur zaman dulu kapuk, hancur sendiri di air. Yang sekarang ini busa… Iya juga ya."* ➜ Lanjut Langkah 3.
  * **[B]** *"Plastik itu ratusan tahun baru hancur, Pak."* ($\Delta\text{Meter}=+3$)
    * ➜ [Pak Darwis] (neutral): *"Aku tak akan hidup ratusan tahun. Jadi bukan urusanku."* (Berakhir).
  * **[C]** *"Orang tua memang keras kepala kalau dibilangin."* ($\Delta\text{Meter}=+5$, Sikap $\rightarrow$ Menolak)
    * ➜ [Pak Darwis] (sad): *"Kalau aku keras kepala, kau keras mulut!"* (Pemicu Sampah Balasan).

* **Langkah 3 (Solusi)**:
  * **[A]** *"Kasur itu kalau dicincang, busanya bisa dijual ke pengepul di hulu, Pak. Lebih baik jadi uang daripada jadi sampah di muara."* ($\Delta\text{Meter}=-3$, Sikap $\rightarrow$ **Peduli**)
    * ➜ [Pak Darwis] (happy): *"Dijual? Busa? Parangku masih tajam. Mulai sekarang kasur ini tak ke sungai lagi."*
  * **[B]** *"Bapak bawa saja ke TPA sendiri."*
    * ➜ [Pak Darwis] (neutral): *"TPA itu sepuluh kilo. Kau yang angkat?"* (Berakhir).
  * **[C]** *"Kalau buang lagi, Bapak kulaporkan ke lurah!"* ($\Delta\text{Meter}=+5$, Sikap $\rightarrow$ Menolak)
    * ➜ [Pak Darwis] (neutral): *"Lapor lah. Lurah itu keponakanku."* (Pemicu Sampah Balasan).

---

### B. Kak Rina (Pedagang Gorengan)
* **File Dialog**: `res://data/dialog/h4_rina.json`
* **Kalimat Pembuka**:
  > *"Eh, Dek! Mau gorengan? Baru angkat, panas-panas."*

* **Langkah 1 (Dengarkan)**:
  * **[A]** *"Minyak bekasnya Kakak biasa buang ke mana?"* ($\Delta\text{Meter}=0$, $\Delta\text{Sikap}=0$)
    * ➜ [Kak Rina] (neutral): *"Ke selokan belakang, lah. Mau ke mana lagi? Botolnya mahal, tempatnya tak ada."* ➜ Lanjut Langkah 2.
  * **[B]** *"Jangan dibuang ke selokan, Kak, nanti mencemari."* ($\Delta\text{Meter}=+3$)
    * ➜ [Kak Rina] (neutral): *"Iya, iya. Jadi, Dek, mau beli apa tidak?"* (Berakhir).
  * **[C]** *"Kakak sadar tidak, minyak itu merusak sungai?"* ($\Delta\text{Meter}=+5$, Sikap $\rightarrow$ Menolak)
    * ➜ [Kak Rina] (sad): *"Adek baru pulang sudah menyalahkan orang yang cari makan?!"* (Pemicu Sampah Balasan).

* **Langkah 2 (Pahami)**:
  * **[A]** *"Repot ya, Kak, kalau tak ada yang mau menampung minyak bekas."* ($\Delta\text{Sikap}=+1$ Ragu)
    * ➜ [Kak Rina] (neutral): *"Nah! Kalau ada yang mau beli, Kakak kumpul, Dek. Sayang, itu minyak, bukan air."* ➜ Lanjut Langkah 3.
  * **[B]** *"Tapi selokan jadi bau dan mampat, Kak."* ($\Delta\text{Meter}=+3$)
    * ➜ [Kak Rina] (neutral): *"Bau? Kakak yang tiap hari menciumnya."* (Berakhir).
  * **[C]** *"Gorengan laku, selokan jadi korban."* ($\Delta\text{Meter}=+5$, Sikap $\rightarrow$ Menolak)
    * ➜ [Kak Rina] (sad): *"Oh, jadi Kakak penjahatnya."* (Pemicu Sampah Balasan).

* **Langkah 3 (Solusi)**:
  * **[A]** *"Kak, kumpulkan di jeriken. Bank sampah beli Rp 3.000 per liter untuk biodiesel."* ($\Delta\text{Meter}=-3$, Sikap $\rightarrow$ **Peduli**)
    * ➜ [Kak Rina] (happy): *"Dibeli?! Tiga ribu seliter? Itu dua bungkus terigu, Dek! Mulai hari ini Kakak simpan jelantahnya."*
  * **[B]** *"Kakak gali lubang saja di tanah."*
    * ➜ [Kak Rina] (neutral): *"Nanti rembes ke sumur tetangga. Berantem Kakak."* (Berakhir).
  * **[C]** *"Pokoknya jangan ke selokan lagi!"* ($\Delta\text{Meter}=+5$, Sikap $\rightarrow$ Menolak)
    * ➜ [Kak Rina] (sad): *"Pokoknya, pokoknya. Kau kira Kakak buang minyak karena senang?"* (Pemicu Sampah Balasan).

---

### C. Pemuka Desa
* **NPC**: `npc_pemuka_desa`
* **File Dialog**: `res://data/dialogues/level2.json`

```
[Pemuka Desa]: "Selamat datang. Di sini, urusan sungai selalu kami bicarakan bersama-sama. Tak ada yang bekerja sendirian."
Pilihan:
  1. "Kenapa harus dibicarakan bersama?"
     -> [Pemuka Desa]: "Karena sungai melewati rumah semua orang, Nak. Kalau keputusan diambil bersama, semua ikut menjaga. Orang Melayu bilang: berat sama dipikul, ringan sama dijinjing."
  2. "Aku siap membantu warga." (+2% Air)
     -> [Pemuka Desa]: "Bagus. Mulailah dari yang kecil: pilah sampahmu, sapa warga. Kalau hati sudah terbuka, pekerjaan besar jadi ringan."
```

* **Syarat Gerbang Kota Terbuka**: Minimal 10 sampah desa terpilah + 2 warga diajak bicara + Kesehatan Sungai $\ge 60\%$.
* *Narasi Transisi*: *"Di kejauhan, kota naik seperti dinding. Di antara atap-atapnya, bunyi klakson datang lebih dulu daripada bayangan. Sungai berbelok ke sana, lalu menyempit."*

---

# 5. ZONA 3: KOTA MEDAN (URBAN & DRAINASE)

* **Misi**: Pilah 6 sampah kota & Bicara dengan 4 warga & Puzzle tuas drainase 1-3-2.
* **Syarat Gerbang Hilir**: 6 sampah terpilah + 4 warga diajak bicara + Kesehatan Sungai $\ge 75\%$.

---

### A. Bang Jali (Warga Gang Padat)
* **File Dialog**: `res://data/dialog/h2_jali.json`
* **Kalimat Pembuka**:
  > *"Apa lihat-lihat, Bang?"*

* **Langkah 1 (Dengarkan)**:
  * **[A]** *"Aku baru pulang, Bang. Boleh aku tanya, kenapa dibuang di situ?"* ($\Delta\text{Meter}=0$, $\Delta\text{Sikap}=0$)
    * ➜ [Bang Jali] (neutral): *"Haha. Cemana lagi, Bang? Tong sampah itu di ujung jalan sana, dua ratus meter. Truknya pun tak muat masuk gang. Kau mau bawa kantong ini tiap pagi, sambil kerja, sambil gendong anak?"* ➜ Lanjut Langkah 2.
  * **[B]** *"Sungai lagi sakit, Bang. Tolong jangan buang sampah ya."* ($\Delta\text{Meter}=+3$)
    * ➜ [Bang Jali] (neutral): *"Sakit? Aku yang sakit, Bang."* (Berakhir).
  * **[C]** *"Kalian ini jorok! Gara-gara kalian kampung banjir!"* ($\Delta\text{Meter}=+5$, Sikap $\rightarrow$ Menolak)
    * ➜ [Bang Jali] (sad): *"Siapa kau ceramahi aku? Baru pulang sudah sok pintar!"* (Pemicu Sampah Balasan).

* **Langkah 2 (Pahami)**:
  * Pertanyaan MC: *"Apa yang sebenarnya jadi masalahnya?"*
  * **[A]** *"Berarti bukan karena malas. Tempat buangnya yang tak terjangkau."* ($\Delta\text{Sikap}=+1$ Ragu)
    * ➜ [Bang Jali] (happy): *"Nah! Akhirnya ada yang ngerti, Bang. Kau pikir aku suka kampung ini kumuh?"* ➜ Lanjut Langkah 3.
  * **[B]** *"Mungkin Abang buru-buru karena kerja ya."* ($\Delta\text{Meter}=+3$)
    * ➜ [Bang Jali] (neutral): *"Ya… itu juga."* (Berakhir).
  * **[C]** *"Pokoknya malas! Anak muda sekarang begitu semua."* ($\Delta\text{Meter}=+5$, Sikap $\rightarrow$ Menolak)
    * ➜ [Bang Jali] (sad): *"Aku empat puluh satu, Bang. Kau yang anak muda."* (Pemicu Sampah Balasan).

* **Langkah 3 (Solusi)**:
  * **[A]** *"Bagaimana kalau kita buat bak sampah roda di mulut gang? Ditarik bergiliran ke jalan besar."* ($\Delta\text{Meter}=-3$, Sikap $\rightarrow$ **Peduli**)
    * ➜ [Bang Jali] (happy): *"Mantap kali ide Abang! Nanti kubilang sama anak-anak muda sini, kita iuran buat bak sampahnya."*
  * **[B]** *"Bawa sajalah ke TPS depan tiap pagi."*
    * ➜ [Bang Jali] (neutral): *"Kau yang bawa?"* (Berakhir).
  * **[C]** *"Kalau malas ya sampai kiamat pun banjir terus."* ($\Delta\text{Meter}=+5$, Sikap $\rightarrow$ Menolak)
    * ➜ [Bang Jali] (sad): *"Bah."* (Pemicu Sampah Balasan).

---

### B. Warga Kota Lainnya & Puzzle Drainase
* **Ibu Rumah Tangga**: *"Got di belakang rumahku mampat lagi... Di bawah jembatan ada pintu air. Buka yang paling depan dulu (1), lalu yang paling belakang (3), baru yang tengah (2)."*
* **Budi (Anak Sekolah)**: *"Pantun itu cara orang Melayu menyampaikan yang berat dengan cara yang ringan. Jadi tak ada yang tersinggung."*
* **Pak RT**: *"Sungai adalah urat nadi kehidupan. Kalau urat nadi tersumbat, tubuhnya yang sakit. Musyawarah dan gotong royong adalah kuncinya."*
* **Puzzle Tuas Drainase**:
  * Urutan benar: **1 ➜ 3 ➜ 2**.
  * Berhasil: +10% Kesehatan Sungai, +Rp 2.500, Kartu `card_drainase_01`.
* *Narasi Transisi*: *"Bau garam mulai terbawa angin. Sungai yang tadi menyempit di kota kini melebar, pelan-pelan, seperti orang yang akhirnya boleh bernapas panjang."*

---

# 6. ZONA 4: HILIR SUNGAI DELI (MUARA & PESISIR)

* **Misi**: Tanam 8 Mangrove, Pilah 10 Sampah Pesisir, Bicara 2 Warga, & Lengkapi Pantun Melayu Deli.
* **Syarat Gerbang Epilog**: 8 Mangrove + 10 Sampah + 2 Warga + Kesehatan Sungai $\ge 80\%$.

---

### A. Warga Pesisir
* **Pak Nelayan**:
  > *"Hati-hati melangkah, Nak. Banyak pecahan botol. Dulu sepanjang pantai ini bakau semua... Di bawah akarnya, anak ikan bersembunyi sampai cukup besar untuk takut. Kami cari makan dari laut yang sehat. Kalau laut sakit, anak-anak kami yang pergi merantau."*
* **Penjaga Sungai**:
  > *"Lihat itu. Semua yang dibuang di hulu akhirnya sampai ke sini. Muara itu tempat sungai menyerahkan semua yang dibawanya. Susuri pesisir, pilah sampahnya. Gunungan ini juga tak datang dalam sehari."*

---

### B. Papan Pantun Melayu Deli (Rima Bersajak a-b-a-b)
* **Pantun 1 (Datuk Sampan - Pelestarian Sungai)**:
  * *Sampiran*: `Sampan tua menyusur tebing, Pagi berkabut di hulu Deli.`
  * *Pilihan Benar [A]*: `Sungai dirawat airnya bening, Apa dibuang pasti kembali.` ($\Delta\text{Meter}=-2\%$)
* **Pantun 2 (Kak Rina - Pengelolaan Jelantah)**:
  * *Sampiran*: `Pagi hari menggoreng pisang, Wajan hitam di atas tungku.`
  * *Pilihan Benar [A]*: `Minyak sisa jangan dibuang, Ditampung dulu, jadi rezeki baru.` ($\Delta\text{Meter}=-2\%$)
* **Pantun 3 (Bang Jali - Gotong Royong TPS)**:
  * *Sampiran*: `Lewat gang membawa karung, Menuju TPS di ujung jalan.`
  * *Pilihan Benar [A]*: `Kerja bersama hati tak murung, Sampah terangkut, ringan pikiran.` ($\Delta\text{Meter}=-2\%$)

* *Narasi Transisi Epilog*: *"Angin berubah arah. Dari muara, tampak aliran sungai yang tadi kususuri, utuh dari hulu sampai laut, seperti urat nadi yang akhirnya mengalirkan darah lagi. Aku berjalan masuk ke fajar yang belum sepenuhnya datang."*

---

# 7. EPILOG: EMPAT AKHIR PERJALANAN

---

### 🌟 ENDING A: Harapan Baru Deli (Terbaik)
* **Syarat**: Meter Bencana $\le 20\%$, Tiga Warga Kunci (Jali, Rina, Darwis) Peduli, Utang Lunas 100%. Air biru kristal `Color(0.18, 0.65, 0.92)`.
* **Naskah**:
  ```
  [MC] (happy): "Enam bulan kemudian. Pukul lima pagi, dari dalam warung terdengar bunyi yang sudah lama hilang: sendok beradu gelas."
  [Pak Hendra] (happy): "Atap sudah kutambal. Sebelum hujan, kali ini."
  [Pak Hendra] (happy): "Warga sekarang kerja bakti tiap Minggu jaga tanggul. Bang Jali pegang iuran bak roda, Kak Rina setor jelantah tiap Kamis, dan Pak Darwis paling rajin cincang kasur."
  [MC] (happy): "Sungai Deli jernih sampai ke dasar. Batu-batunya yang dulu tak pernah kulihat kini bisa kuhitung."
  [Datuk Sampan] (happy): "Aku bukan hantu, Nak. Aku ingatan kampung ini tentang cara menjaga sungai. Selama ada yang mengingat, aku ada."
  [MC] (happy): "Waktu tak bisa diputar kembali. Yang bisa hanya kebiasaan. Dan kebiasaan dimulai dari mendengar."
  ```

---

### 🌤 ENDING B: Keluarga Mandiri (Baik)
* **Syarat**: Meter Bencana $\le 40\%$, Minimal 2 Warga Peduli, Utang Lunas $\ge 70\%$. Air biru kehijauan `Color(0.28, 0.58, 0.78)`.
* **Naskah**:
  ```
  [MC] (happy): "Hujan datang lagi bulan itu, deras seperti dulu. Warung kami basah, tapi tidak tenggelam."
  [Bu Mira] (happy): "Air naik sampai tangga kedua. Dulu sampai meja. Kita tak menang, Nak, tapi kita tak kalah seperti dulu."
  [MC] (neutral): "Utang pokok sudah hampir tak bersisa di buku Mak, seperti sebuah janji yang belum jatuh tempo."
  [Datuk Sampan] (happy): "Kau tak sendirian lagi, Nak. Yang tadinya hanya mendengar, sekarang ada yang ikut menjaga. Teruskan."
  ```

---

### 🌥 ENDING C: Bertahan di Tepian (Netral)
* **Syarat**: Meter Bencana $\le 60\%$, Minimal 1 Warga Peduli. Air keruh keabuan `Color(0.42, 0.52, 0.58)`.
* **Naskah**:
  ```
  [MC] (sad): "Hujan lebat datang lagi. Warung bertahan, dindingnya basah sampai ke garis lumpur yang lama. Utang masih tersisa, dan sungai masih rawan."
  [MC] (sad): "Seperti menambal atap saat hujan sudah turun. Bisa, tapi tak pernah benar-benar kering."
  [Datuk Sampan] (neutral): "Sungai belajar dari kita, seperti kita belajar darinya. Jalanmu masih panjang. Jangan berhenti di tengah."
  ```

---

### 🌧 ENDING D: Terpaksa Menyerah (Buruk + Tombol Rewind)
* **Syarat**: Meter Bencana $> 60\%$ atau kriteria lain tidak terpenuhi. Air coklat pekat.
* **Pesan Moral**: *"Satu orang membuang, semua menanggung."*
* **Naskah**:
  ```
  [MC] (sad): "Banjir bandang datang malam hari tanpa aba-aba. Air coklat pekat menelan bantaran dan warung keluarga. Pagi harinya, hanya tiang yang tersisa dan sandal yang masih berpasangan."
  [Datuk Sampan] (sad): "Sungai tak membenci siapa pun, Nak. Ia hanya kembali ke jalannya. Kalau kau diberi kesempatan sekali lagi, dengarkan dulu sebelum bicara."
  [MC] (sad): "Satu orang membuang. Semua yang menanggung."
  ```
* **Mekanik Rewind**:
  * Tombol utama berubah menjadi **⏪ Rewind** (`GameState.rewind()`).
  * Narasi Rewind: *"Air surut mundur. Lumpur naik kembali ke dinding. Dari kejauhan, bunyi sendok beradu gelas pukul lima pagi. Waktu berputar ke awal. Yang tak ikut terputar adalah apa yang telah kupelajari."*

---

# 8. ADDENDUM v1.1 — TITIK TAK KEMBALI & BANJIR PEMICU

Untuk mencegah pemain terjebak (*softlock*) akibat pilihan-pilihan kasar di tengah perjalanan, sistem menyediakan 3 tahapan bencana dinamis:
1. **Tahap Pertanda (Meter $\ge 65\%$)**: Langit menggelap, gerimis mulai berbunyi di atap seng warung.
2. **Tahap Siaga (Meter $\ge 75\%$)**: HUD Meter berkedip merah, Datuk Sampan muncul 1 kali memberi peringatan: *"Sungai yang sehat selalu berisik. Yang diam sedang menahan sesuatu. Kalau masih ada yang bisa kau dengarkan, dengarkan sekarang."*
3. **Tahap Banjir Pemicu (Meter $\ge 80\%$ atau Tak Mungkin Menang)**: Kontrol terkunci, cutscene banjir bandang melanda zona pemain berada beserta reaksi warga sesuai sikap mereka, lalu transisi langsung ke Ending D dan tombol **Rewind**.
4. **Catatan Refleksi Datuk Pasca-Rewind**:
   * Sering memilih [C] (menuduh): *"Kemarin kau bicara lebih cepat daripada mendengar. Coba lain kali pelankan."*
   * Sering memilih [B] (menggurui): *"Memberi tahu itu bukan mendengarkan, Nak. Tanyalah dulu."*
   * Banyak sampah diabaikan: *"Telinga saja tak cukup. Tangan juga perlu bekerja."*
   * Puzzle/tanam terlewat: *"Ada hal-hal yang tak bisa diselesaikan dengan bicara. Pohon, misalnya."*
