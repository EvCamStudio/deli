"""Impor karakter top-down dari paket CC0 "customizable character pack".

Sumber : https://opengameart.org/content/customizable-character-pack
Penulis: rubberduck (2020), turunan "Kenney RPG Urban Pack" (Kenney, CC0)
Lisensi: CC0 / public domain

Berkas asli ada di tools/opensource/characters/ (sample_character_XX.png),
layout sumber: 4 kolom = arah (kiri, bawah, atas, kanan), 3 baris = frame,
tiap sel 16x32 dengan isi karakter di y=8..31.

Skrip ini memotong tiap karakter menjadi sheet 64x96 (16x24 per sel,
4 kolom frame x 4 baris arah) sesuai yang dibaca player_topdown.gd:
  baris 0 = down, 1 = left, 2 = right, 3 = up
Frame walk dibuat 4 kolom dari 3 frame sumber: f0, f1, f2, f1.

Jalankan: python tools/import_opensource_characters.py
"""

from __future__ import annotations

import os
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "tools", "opensource", "characters")
DST = os.path.join(ROOT, "assets", "sprites", "characters")

CELL_W, CELL_H = 16, 24
SRC_ROW_H = 32
SRC_TOP = 8  # isi sprite sumber mulai di baris y=8

# Arah pada sumber (indeks kolom)
SRC_LEFT, SRC_DOWN, SRC_UP, SRC_RIGHT = 0, 1, 2, 3

# Baris sheet tujuan -> kolom sumber
TARGET_ROWS = [
    ("down", SRC_DOWN),
    ("left", SRC_LEFT),
    ("right", SRC_RIGHT),
    ("up", SRC_UP),
]

# Urutan frame walk (sumber hanya punya 3 frame)
FRAME_ORDER = [0, 1, 2, 1]

# key game -> berkas sumber
CAST = {
    "player": "sample_character_01.png",        # pemuda, topi biru
    "pedagang": "sample_character_09.png",      # pria tua berkacamata
    "ibu": "sample_character_10.png",           # perempuan berkerudung ungu
    "budi": "sample_character_11.png",          # anak muda, rambut hitam
    "pakrt": "sample_character_13.png",         # pria beruban berkacamata
    "penjaga_hutan": "sample_character_12.png", # pria berambut cokelat, kaus hijau
    "petani": "sample_character_05.png",        # topi caping jerami, kulit gelap
    "nelayan": "sample_character_02.png",       # kulit gelap, ikat kepala
}


def build_sheet(src_path: str) -> Image.Image:
    src = Image.open(src_path).convert("RGBA")
    sheet = Image.new("RGBA", (CELL_W * 4, CELL_H * 4), (0, 0, 0, 0))
    for row, (_name, src_col) in enumerate(TARGET_ROWS):
        for col, frame in enumerate(FRAME_ORDER):
            # Potongan diikat ke bawah (kaki menempel di y=32) supaya karakter
            # yang lebih tinggi (mis. topi caping) tidak menggeser posisi kaki.
            box = (
                src_col * CELL_W,
                frame * SRC_ROW_H + SRC_TOP,
                src_col * CELL_W + CELL_W,
                frame * SRC_ROW_H + SRC_TOP + CELL_H,
            )
            sheet.paste(src.crop(box), (col * CELL_W, row * CELL_H))
    return sheet


def main() -> None:
    os.makedirs(DST, exist_ok=True)
    for key, filename in CAST.items():
        sheet = build_sheet(os.path.join(SRC, filename))
        out = os.path.join(DST, f"{key}.png")
        sheet.save(out)
        print(f"  {key:14s} <- {filename}")
    print("karakter opensource diimpor ke assets/sprites/characters/")


if __name__ == "__main__":
    main()