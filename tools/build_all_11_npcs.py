#!/usr/bin/env python3
"""
Batch-build topdown spritesheets (72x112, 18x28 cells, 4 dirs x 4 frames)
and chest-up dialogue portraits (158x219, centered, bottom anchored to y=219)
for all 11 remaining game NPCs from the user's uploaded RGBA PNG sheets.
"""

import os
from PIL import Image

UPLOAD_DIR = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/.user_uploaded"
CHAR_DIR = "assets/sprites/characters"
PORTRAIT_DIR = "assets/sprites/portraits"
CANVAS_SIZE = (158, 219)

# (display_name, filename, sprite_keys_to_save, portrait_keys_to_save, split_y)
NPCS = [
    ("Penjaga Hutan",    "media_1794990943665_b30e25a5.png", ["penjaga_hutan"],            ["penjaga_hutan"],            397),
    ("Pak Darwis",       "media_1794990943706_4bf20e14.png", ["petani", "pak_darwis"],     ["petani", "pak_darwis"],     408),
    ("Pemilik Toko",     "media_1794990943829_c8bed0e0.png", ["pemilik_toko"],             ["pemilik_toko"],             419),
    ("Kak Rina",         "media_1794991120021_3a0eeffa.png", ["kak_rina"],                 ["kak_rina"],                 398),
    ("Pemuka Desa",      "media_1794991317845_b495d62b.png", ["pemuka_desa"],              ["pemuka_desa"],              436),
    ("Bang Jali",        "media_1794991405160_28391cec.png", ["pedagang", "bang_jali"],    ["pedagang", "bang_jali"],    424),
    ("Ibu Rumah Tangga", "media_1794991479201_1cd8dd28.png", ["ibu_rumah"],                ["ibu_rumah"],                419),
    ("Budi",             "media_1794991621796_4e4b72e1.png", ["budi"],                     ["budi"],                     427),
    ("Pak RT",           "media_1794991651328_ded56e65.png", ["pakrt"],                    ["pakrt"],                    410),
    ("Pak Nelayan",      "media_1794991724863_eaf28e15.png", ["nelayan"],                  ["nelayan"],                  437),
    ("Penjaga Sungai",   "media_1794991770444_3f0b0d20.png", ["penjaga_sungai"],           ["penjaga_sungai"],           440),
]


def find_x_spans(im, min_w=50):
    w, h = im.size
    pix = im.load()
    active = [any(pix[x, y][3] > 35 for y in range(h)) for x in range(w)]
    spans = []
    in_s = False
    st = 0
    for x, a in enumerate(active):
        if a and not in_s:
            in_s = True
            st = x
        elif not a and in_s:
            in_s = False
            if x - st >= min_w:
                spans.append((st, x))
    if in_s and w - st >= min_w:
        spans.append((st, w))
    return spans


def clean_tight(crop_im, alpha_thresh=25):
    a_mask = crop_im.split()[3].point(lambda p: 255 if p > alpha_thresh else 0)
    bb = a_mask.getbbox()
    return crop_im.crop(bb) if bb else crop_im


def build_npc(name, filename, sprite_keys, portrait_keys, split_y):
    src_path = os.path.join(UPLOAD_DIR, filename)
    im = Image.open(src_path).convert("RGBA")

    # 1. TOPDOWN SPRITESHEET (72x112, 18x28 cells)
    top = im.crop((0, 0, im.width, split_y))
    spans = find_x_spans(top, min_w=50)
    assert len(spans) == 4, f"{name}: expected 4 top sprite spans, got {spans}"

    # Image order: [0]=Left, [1]=Down, [2]=Up, [3]=Right
    # Sheet rows:  Row 0=Down, Row 1=Left, Row 2=Right, Row 3=Up
    ordered = [spans[1], spans[0], spans[3], spans[2]]

    sheet = Image.new("RGBA", (72, 112), (0, 0, 0, 0))
    for r, (x0, x1) in enumerate(ordered):
        fig = clean_tight(top.crop((x0, 0, x1, top.height)), alpha_thresh=25)
        # Preserve exact aspect ratio (never squish wide hats!)
        scale = min(27.0 / float(fig.height), 18.0 / float(fig.width))
        nw = max(1, int(round(fig.width * scale)))
        nh = max(1, int(round(fig.height * scale)))
        s = fig.resize((nw, nh), Image.Resampling.LANCZOS)

        spix = s.load()
        for y in range(nh):
            for x in range(nw):
                if spix[x, y][3] < 25:
                    spix[x, y] = (0, 0, 0, 0)

        ox = (18 - nw) // 2
        oy = 28 - nh
        for c in range(4):
            cell_ox = c * 18 + ox
            cell_oy = r * 28 + oy
            if c in (1, 3):
                # Subtle 1px walk bob (clamp to cell top >= r*28)
                sheet.alpha_composite(s, (cell_ox, max(r * 28, cell_oy - 1)))
            else:
                sheet.alpha_composite(s, (cell_ox, cell_oy))

    for sk in sprite_keys:
        out_s = os.path.join(CHAR_DIR, f"{sk}.png")
        sheet.save(out_s)

    # 2. DIALOGUE PORTRAIT (158x219, chest-up, centered, anchored at bottom y=219)
    bot = im.crop((0, split_y, im.width, im.height))
    tight_p = clean_tight(bot, alpha_thresh=25)

    # Keep portrait tall & prominent (target height 215px, leaving 4px top margin),
    # while ensuring wide-hat characters (like Pak Nelayan's caping or ranger boonie hats)
    # stay well-framed without chopping off the hat!
    cw, ch = CANVAS_SIZE
    scale_h = 215.0 / float(tight_p.height)
    # Allow up to 192px width (natural slight sleeve tuck like Pemuka Desa/Bapak),
    # and cap ultra-wide hats (Pak Nelayan caping) at 186px so face stays prominent!
    if tight_p.width * scale_h > 192.0:
        scale_p = 186.0 / float(tight_p.width)
    else:
        scale_p = scale_h

    nw_p = int(round(tight_p.width * scale_p))
    nh_p = int(round(tight_p.height * scale_p))
    s_p = tight_p.resize((nw_p, nh_p), Image.Resampling.LANCZOS)

    spix = s_p.load()
    for y in range(nh_p):
        for x in range(nw_p):
            r, g, b, a = spix[x, y]
            if a < 25:
                spix[x, y] = (0, 0, 0, 0)
            elif a >= 230:
                spix[x, y] = (r, g, b, 255)

    canvas = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    ox_p = (cw - nw_p) // 2
    oy_p = ch - nh_p
    canvas.alpha_composite(s_p, (ox_p, oy_p))

    for pk in portrait_keys:
        for emo in ["neutral", "happy", "sad", "surprised"]:
            out_p = os.path.join(PORTRAIT_DIR, f"{pk}_{emo}.png")
            canvas.save(out_p)

    print(
        f"[OK] {name:18s} | spr={sprite_keys[0]:15s} | port_tight={str(tight_p.size):10s} "
        f"| scaled=({nw_p:3d}x{nh_p:3d}) ox={ox_p:3d} oy={oy_p:2d}"
    )
    return sheet, canvas


def main():
    results = []
    for spec in NPCS:
        sheet, port = build_npc(*spec)
        results.append((spec[0], sheet, port))

    # Build visual verification contact sheet:
    # Top section: All 11 portraits inside the real ornate dialogue frame window!
    # Bottom section: All 11 topdown idle sprites (Front/Down) at 5x on grass ground!
    BRAIN = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8"
    frame_bg = Image.open("assets/ui/dialogue_frame_ornate.png").convert("RGBA").crop((0, 0, 205, 272))

    cols = 6
    rows = 2
    pw, ph = frame_bg.size
    pad = 12
    port_grid = Image.new("RGBA", (cols * (pw + pad) + pad, rows * (ph + pad) + pad), (42, 34, 28, 255))
    for i, (name, _, port) in enumerate(results):
        r, c = divmod(i, cols)
        tile = frame_bg.copy()
        # Inner portrait window in dialogue_frame_ornate.png is at (22, 33) size (159, 219)
        tile.alpha_composite(port, (22, 33))
        port_grid.alpha_composite(tile, (pad + c * (pw + pad), pad + r * (ph + pad)))
    port_grid.save(f"{BRAIN}/verify_all_11_portraits.png")

    # Sprite lineup (5x nearest) on village dirt+grass
    s_scale = 5
    sw, sh = 18 * s_scale, 28 * s_scale
    spr_strip = Image.new("RGBA", (11 * (sw + 10) + 20, sh + 40), (122, 160, 102, 255))
    for i, (name, sheet, _) in enumerate(results):
        down_idle = sheet.crop((0, 0, 18, 28)).resize((sw, sh), Image.Resampling.NEAREST)
        spr_strip.alpha_composite(down_idle, (10 + i * (sw + 10), 20))
    spr_strip.save(f"{BRAIN}/verify_all_11_sprites.png")
    print("Saved verify_all_11_portraits.png and verify_all_11_sprites.png!")


if __name__ == "__main__":
    main()
