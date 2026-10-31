# RANCANGAN GAME — DELI REWIND (Revisi Selesai)

## Konsep Utama
Slice-of-life open world. MC pulang ke Medan setelah PHK, bantu orang tua perbaiki warung yang rusak akibat banjir Sungai Deli, cegah banjir dengan membersihkan lingkungan, cari uang lunasi utang Rp 500.000.

---

## 1. Alur Naratif
- **Prolog**: Intro Dramatic (Jakarta PHK → pulang Medan → warung rusak)
- **Trigger**: Dialog Ibu membuka quest utama: "Pulihkan Warung & Sungai"
- **Loop Harian**: Kumpul sampah / tanam pohon / jual ke pengepul / setor uang / tidur
- **Progress**: River Health naik → zona terbuka → warung pulih → ending

---

## 2. Struktur Dunia (No Level)
Satu map besar: `world_sungai_deli.tscn`
- **Zona 1** (Warung & Hulu): Terbuka awal
- **Zona 2** (Desa): Unlock River Health 40%
- **Zona 3** (Hilir): Unlock River Health 70%

---

## 3. Sistem Utama

### River Health (0-100%)
- Sampah: Organik +0.5%, Plastik +1%, B3 +2%
- Pohon hulu: +3%, Mangrove hilir: +5%
- Edukasi warga: +5-10%, Proyek komunitas: +10%

### Rupiah & Utang
- Utang awal: Rp 500.000
- Dapat: Jual sampah, quest, side quest, mini-game, warung (setelah 50% pulih)
- Pakai: Cicil utang, bibit, alat, donasi proyek, makanan

### Energy (0-100)
- Kumpul sampah -5, tanam pohon -10, mangrove -15
- Restore: Tidur (full), makan (+20-30), istirahat (+10)

### Day
- Milestone: Hari 1-7 tutorial, 8-20 ekspansi, 21-30 mid-game, 30+ end-game
- Event: Hari 7 banjir (jika RH <40%), Hari 14 pedagang, Hari 21 festival pantun, Hari 28 penagih

---

## 4. Quest
- **Utama**: "Pulihkan Warung & Sungai" (no deadline)
- **Harian**: Reset tiap tidur, fleksibel
- **Side Quest**: Pak Tani, Nenek Pantun, Pak Lurah

---

## 5. Edukasi & Kearifan Lokal
- **Edukasi**: Dialog NPC, Knowledge Cards (Sampah & Banjir, Pohon Hulu, Mangrove)
- **Lokal**: Pantun Melayu, gotong royong, makanan khas Medan, istilah lokal

---

## 6. Ending (4 Varian)
- **A (Terbaik)**: RH 80-100% + Utang 100%
- **B (Baik)**: RH 60-79% + Utang 70-99%
- **C (Netral)**: RH 40-59% + Utang 50-69%
- **D (Buruk)**: RH <40% + Utang <50%

---

## 7. HUD Layout
```
💧 [████████░░] 45% │ 📅 Hari 12 │ 💰 Rp 85.000 │ ⚡ 60/100 │ 🏠 Utang: Rp 300.000
📋 MISI HARI INI (hidden sampai dialog Ibu)
```

---

## 8. File Penting
- `world_sungai_deli.tscn` (map besar, ganti semua level)
- `autoload/game_state.gd` (energy, zone_unlocked, debt_paid)
- `autoload/quest_manager.gd` (baru)
- `scripts/zone_gate.gd` (baru)
- `scripts/world_sungai_deli.gd` (baru)
- `scenes/ui/hud.tscn` (update energy, debt)

---

## 9. Implementation Priority
1. Core Refactor: Gabung level → satu map, zone gate, game_state update
2. Quest Trigger: Hidden mission, lock gameplay, dialog Ibu
3. Gameplay Loop: Jual sampah, bayar utang, visual warung
4. Energy & Day: System waktu, event harian, refresh map
5. Polish: Knowledge cards, pantun, ending
