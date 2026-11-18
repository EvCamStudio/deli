#!/usr/bin/env python3
"""
Extract and build Mother (Bu Mira / Mak) sprites and portraits from the user-uploaded sprite sheet.
- Topdown sprite sheet: 4 cols x 4 rows (Down, Left, Right, Up), 18x28 cell size, 72x112 total.
- Dialogue portraits: 160x200 canvases for neutral, happy, sad, surprised, angry.
"""

import os
from PIL import Image

SRC_PATH = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/.user_uploaded/media_1794895926521_db5206e0.png"
CHAR_OUT = "assets/sprites/characters/ibu.png"
PORTRAIT_DIR = "assets/sprites/portraits"

def main():
    img = Image.open(SRC_PATH)
    print("Opened source image:", img.size, img.mode)

    # ──────────────────────────────────────────────────────────────────────────
    # 1. TOPDOWN CHARACTER SPRITESHEET (18x28 cell, 72x112 sheet)
    # ──────────────────────────────────────────────────────────────────────────
    down_cols = [(41, 104), (124, 185), (202, 262), (280, 340)]
    left_cols = [(42, 107), (121, 186), (202, 268), (284, 351)]
    right_cols = [(409, 475), (488, 554), (565, 630), (642, 708)]
    up_cols = [(418, 471), (492, 545), (567, 620), (642, 694)]

    def get_clean_frame(col_box, y0, y1):
        c = img.crop((col_box[0], y0, col_box[1], y1))
        bbox = c.getbbox()
        c = c.crop(bbox)
        pix = c.load()
        for y in range(c.height):
            for x in range(c.width):
                if pix[x, y][3] < 20:
                    pix[x, y] = (0, 0, 0, 0)
        return c

    rows_frames = [
        [get_clean_frame(b, 35, 155) for b in down_cols],   # Row 0: Down
        [get_clean_frame(b, 186, 305) for b in left_cols],  # Row 1: Left
        [get_clean_frame(b, 186, 305) for b in right_cols], # Row 2: Right
        [get_clean_frame(b, 35, 155) for b in up_cols]      # Row 3: Up
    ]

    sheet_28 = Image.new("RGBA", (4 * 18, 4 * 28), (0, 0, 0, 0))
    scale = 27.0 / 120.0
    for r, row in enumerate(rows_frames):
        for c, frame in enumerate(row):
            nw = max(1, int(round(frame.width * scale)))
            nh = max(1, int(round(frame.height * scale)))
            f_scaled = frame.resize((nw, nh), Image.Resampling.LANCZOS)
            spix = f_scaled.load()
            for y in range(nh):
                for x in range(nw):
                    if spix[x, y][3] < 25:
                        spix[x, y] = (0, 0, 0, 0)
            ox = c * 18 + (18 - nw) // 2
            oy = r * 28 + (28 - nh) # Anchored to bottom (feet on ground)
            sheet_28.alpha_composite(f_scaled, (ox, oy))

    sheet_28.save(CHAR_OUT)
    print(f"Saved character sheet to {CHAR_OUT} ({sheet_28.size})")

    # ──────────────────────────────────────────────────────────────────────────
    # 2. DIALOGUE PORTRAITS (160x200 canvas)
    # ──────────────────────────────────────────────────────────────────────────
    # Expressions section mapping:
    # expr_0_0: neutral warm smile
    # expr_0_1: happy eyes closed smile
    # expr_1_2: sad / worried
    # expr_1_1: surprised / speaking
    # expr_1_0: angry (vein mark)
    portraits_map = {
        "neutral": (730, 74, 837, 163),
        "happy": (844, 74, 926, 163),
        "sad": (927, 177, 1004, 266),
        "surprised": (844, 177, 926, 266),
        "angry": (730, 177, 837, 266),
    }

    scale_p = 1.85
    for emotion, box in portraits_map.items():
        cell = img.crop(box)
        bbox = cell.getbbox()
        tight = cell.crop(bbox)
        # Clean alpha
        tpix = tight.load()
        for y in range(tight.height):
            for x in range(tight.width):
                if tpix[x, y][3] < 20:
                    tpix[x, y] = (0, 0, 0, 0)

        nw = int(round(tight.width * scale_p))
        nh = int(round(tight.height * scale_p))
        scaled_p = tight.resize((nw, nh), Image.Resampling.LANCZOS)

        canvas = Image.new("RGBA", (160, 200), (0, 0, 0, 0))
        ox = (160 - nw) // 2
        oy = 200 - nh # touch bottom
        canvas.alpha_composite(scaled_p, (ox, oy))

        out_path = os.path.join(PORTRAIT_DIR, f"ibu_{emotion}.png")
        canvas.save(out_path)
        print(f"Saved portrait ibu_{emotion}.png ({canvas.size}) - tight bbox: {canvas.getbbox()}")

if __name__ == "__main__":
    main()

