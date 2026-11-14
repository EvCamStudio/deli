# Aset Pihak Ketiga (Open Source)

Semua aset di bawah ini berlisensi **CC0 / public domain** sehingga bebas
dipakai, dimodifikasi, dan didistribusikan ulang, termasuk untuk proyek komersial.

## Sprite karakter top-down

- **Nama**: customizable character pack
- **Penulis**: rubberduck
- **Sumber**: https://opengameart.org/content/customizable-character-pack
- **Lisensi**: CC0 1.0 Universal (public domain)
- **Catatan**: paket ini merupakan turunan/remix dari
  **Kenney RPG Urban Pack** (Kenney, CC0, https://kenney.nl/assets/rpg-urban-pack).
- **Berkas asli**: `tools/opensource/characters/sample_character_XX.png`
  (16 karakter, 4 arah × 3 frame, sel 16×32)
- **Dipakai oleh**: `tools/import_opensource_characters.py`

### Pemetaan karakter game → berkas sumber

| key              | berkas sumber           | tampilan                        |
| ---------------- | ----------------------- | ------------------------------- |
| `player`         | `sample_character_01.png` | pemuda, topi biru              |
| `pedagang`       | `sample_character_09.png` | pria berkacamata               |
| `ibu`            | `sample_character_10.png` | perempuan berkerudung ungu     |
| `budi`           | `sample_character_11.png` | anak muda, rambut hitam        |
| `pakrt`          | `sample_character_13.png` | pria beruban berkacamata       |
| `penjaga_hutan`  | `sample_character_12.png` | pria berambut cokelat          |
| `petani`         | `sample_character_05.png` | topi caping jerami             |
| `nelayan`        | `sample_character_02.png` | ikat kepala oranye             |

### Format keluaran

`assets/sprites/characters/<key>.png` berukuran **64×96**:

- 4 kolom = frame jalan (f0, f1, f2, f1)
- 4 baris = arah: `0 = down`, `1 = left`, `2 = right`, `3 = up`

Format ini dibaca langsung oleh `scripts/player_topdown.gd` (Rect2 16×24) dan
`scripts/npc_topdown.gd` (frame idle `Rect2(0, 0, 16, 24)`).

## Catatan

- `tools/generate_characters.py` adalah generator prosedural lama dan **tidak
  lagi menjadi sumber sprite**. Menjalankannya akan menimpa hasil impor.
  Gunakan `tools/import_opensource_characters.py` bila perlu membuat ulang.
- Portrait dialog di `assets/sprites/portraits/` digambar sendiri
  (`tools/generate_pilot_assets.py`) agar warna dan atribut wajah konsisten
  dengan sprite CC0 di atas.