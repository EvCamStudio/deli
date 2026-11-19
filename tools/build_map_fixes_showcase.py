#!/usr/bin/env python3
"""
Assemble a showcase collage for the 7 map fixes:
1. Hilir: Clean Tree between houses (zero clipping/overlap bugs)
2. Hilir: Wooden Bridge with vertical railings on left and right
3. & 4. Kota: Kios Kelontong & Toko Sembako (no duplicate Toko Jaya & no duplicate Warung Bu Sri)
5. Desa: Warung Barokah cleaned (zero bottom wireframe lines)
6. Desa: House Brick on clean grass lawn (no roads cutting through it)
7. Desa: Toko Jaya cleaned (zero bounding box outline)
"""

import os
from PIL import Image, ImageDraw, ImageFont

BRAIN = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8"

ITEMS = [
    ("1. Pohon Hilir Rapi & Bebas Bug Rumah", "verify_1_hilir_tree_clean.png", (200, 100, 1080, 620)),
    ("2. Pagar Jembatan Kayu Hilir (Kiri & Kanan)", "verify_2_hilir_bridge_rails.png", (250, 120, 1030, 640)),
    ("3 & 4. Kota Medan: Pasar Kelontong & Sembako (Tanpa Duplikat)", "verify_3_4_kota_markets_no_dupes.png", (200, 100, 1080, 620)),
    ("5. Warung Barokah Bersih (Tanpa Garis Kotak Bawah)", "verify_5_desa_warung_barokah_clean.png", (250, 120, 1030, 640)),
    ("6. Rumah Brick Desa di Pekarangan Rumput (Bebas Jalan)", "verify_6_desa_house_brick_clean.png", (250, 120, 1030, 640)),
    ("7. Toko Jaya Desa Bersih (Tanpa Garis Bounding Box)", "verify_7_desa_toko_jaya_clean.png", (250, 120, 1030, 640)),
]

def make_showcase():
    thumb_w, thumb_h = 560, 360
    pad = 16
    header_h = 32
    cols = 2
    rows = 3

    total_w = cols * thumb_w + (cols + 1) * pad
    total_h = rows * (thumb_h + header_h) + (rows + 1) * pad

    sheet = Image.new("RGBA", (total_w, total_h), (28, 22, 18, 255))
    draw = ImageDraw.Draw(sheet)

    for i, (title, fname, crop_box) in enumerate(ITEMS):
        c = i % cols
        r = i // cols
        x = pad + c * (thumb_w + pad)
        y = pad + r * (thumb_h + header_h + pad)

        # Card outline
        draw.rectangle([x - 2, y - 2, x + thumb_w + 2, y + thumb_h + header_h + 2], fill=(42, 34, 28, 255), outline=(139, 107, 72, 255), width=2)
        # Header banner
        draw.rectangle([x, y, x + thumb_w, y + header_h], fill=(62, 48, 38, 255))
        draw.text((x + 12, y + 8), title, fill=(245, 230, 195, 255))

        # Crop and resize screenshot
        src_path = os.path.join(BRAIN, fname)
        im = Image.open(src_path)
        crop = im.crop(crop_box)
        thumb = crop.resize((thumb_w, thumb_h), Image.Resampling.LANCZOS)
        sheet.paste(thumb, (x, y + header_h))

    out_path = os.path.join(BRAIN, "verify_map_7_fixes_showcase.png")
    sheet.save(out_path)
    print(f"Saved {out_path} ({total_w}x{total_h})")

if __name__ == "__main__":
    make_showcase()

