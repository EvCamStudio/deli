# CADANGAN (BACKUP): TUGAS AISYAH (ORANG 2: DIALOG & NPC)
Waktu Pencadangan: 2026-11-03
Branch Asal: heiz-dialog

Folder ini menyimpan seluruh pekerjaan Orang 2 (Dialog & NPC) sesuai spesifikasi PDF "Orang 2 Dialog dan NPC":
1. `autoload/dialogue_manager.gd`: Sistem dialog dengan sinyal `dialog_selesai`, `sampah_balasan`, pembaca JSON, dan integrasi Meter Bencana.
2. `autoload/empati_manager.gd`: Sistem Empati 3 Langkah (Dengarkan, Pahami, Solusi) dengan kalkulasi sikap NPC (Menolak, Ragu, Peduli), bisikan Datuk Sampan, dan transparansi dinamis.
3. `data/dialog/*.json`: 16 file dialog lengkap dari naskah Bagian 14 Dokumen Utama.
4. `data/pantun_data.json`: 3 pantun orisinal kearifan lokal Melayu Deli.
5. `scripts/datuk_sampan.gd` & `scenes/world/datuk_sampan.tscn`: Tokoh khayalan penutur lisan Melayu.
6. `scripts/pantun_minigame.gd`: Minigame sambung pantun berhadiah penurunan Meter Bencana.
7. `scripts/portrait_dialogue.gd` & `scenes/ui/portrait_dialogue.tscn`: Kotak dialog portrait 4 emosi.
8. `scripts/npc_topdown.gd`: Skrip interaksi NPC dengan parameter `dialog_id` dan `empati_npc`.

