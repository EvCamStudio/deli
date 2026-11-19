#!/usr/bin/env python3
"""
Extract and build topdown spritesheet and chest-up dialogue portraits for Datuk Sampan
from the user-uploaded JPEG (with baked checkerboard background).
- Clean exterior BFS flood-fill removes 100% of gray/white checkerboard background
  without touching interior white hair, mustache, goatee, or cream baju.
- Topdown character spritesheet: 72x112 (18x28 cell, 4 dirs x 4 frames) -> assets/sprites/characters/datuk.png
- Dialogue portraits: 158x219 canvas, centered, anchored at bottom (zero gap) -> assets/sprites/portraits/datuk_*.png
"""

import os
from collections import deque
from PIL import Image

SRC_PATH = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/.user_uploaded/media_1794988087392_01182a1f.jpg"
CHAR_OUT = "assets/sprites/characters/datuk.png"
PORTRAIT_DIR = "assets/sprites/portraits"
CANVAS_SIZE = (158, 219)
TARGET_H = 215


def remove_checkerboard_bfs(img_rgb):
    w, h = img_rgb.size
    pix = img_rgb.load()
    visited = bytearray(w * h)
    q = deque()

    def is_bg(r, g, b):
        mx = max(r, g, b)
        mn = min(r, g, b)
        # Checkerboard squares are white (~255) and light gray (~226-235), with JPEG artifacts down to ~185
        return mn >= 182 and (mx - mn) <= 24

    for x in range(w):
        for y in (0, h - 1):
            idx = y * w + x
            if not visited[idx] and is_bg(*pix[x, y]):
                visited[idx] = 1
                q.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            idx = y * w + x
            if not visited[idx] and is_bg(*pix[x, y]):
                visited[idx] = 1
                q.append((x, y))

    while q:
        cx, cy = q.popleft()
        for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
            if 0 <= nx < w and 0 <= ny < h:
                idx = ny * w + nx
                if not visited[idx]:
                    if is_bg(*pix[nx, ny]):
                        visited[idx] = 1
                        q.append((nx, ny))

    # Build RGBA
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    opix = out.load()
    for y in range(h):
        for x in range(w):
            if not visited[y * w + x]:
                r, g, b = pix[x, y]
                opix[x, y] = (r, g, b, 255)

    # 1-pass bright/gray JPEG fringe cleanup ONLY on exterior boundary pixels touching alpha=0
    to_clear = []
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            r, g, b, a = opix[x, y]
            if a == 255:
                mx, mn = max(r, g, b), min(r, g, b)
                if mn >= 155 and (mx - mn) <= 26:
                    # Check if touching transparent exterior
                    if (
                        opix[x - 1, y][3] == 0
                        or opix[x + 1, y][3] == 0
                        or opix[x, y - 1][3] == 0
                        or opix[x, y + 1][3] == 0
                    ):
                        to_clear.append((x, y))
    for x, y in to_clear:
        opix[x, y] = (0, 0, 0, 0)

    return out


def find_x_spans(im, min_w=40):
    w, h = im.size
    pix = im.load()
    active = [any(pix[x, y][3] > 50 for y in range(h)) for x in range(w)]
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


def main():
    im_rgb = Image.open(SRC_PATH).convert("RGB")
    print("Opened Datuk Sampan source:", im_rgb.size)
    cutout = remove_checkerboard_bfs(im_rgb)

    # 1. TOPDOWN CHARACTER SPRITESHEET (72x112, 18x28 cells)
    top = cutout.crop((0, 0, cutout.width, 395))
    spans = find_x_spans(top, min_w=60)
    print("Detected top sprite spans (Left, Down, Up, Right):", spans)
    assert len(spans) == 4, f"Expected 4 sprite spans, got {spans}"

    # Order in image: [0]=Left, [1]=Down, [2]=Up, [3]=Right
    # Sheet row order: Row 0=Down, Row 1=Left, Row 2=Right, Row 3=Up
    ordered_spans = [spans[1], spans[0], spans[3], spans[2]]

    sheet = Image.new("RGBA", (72, 112), (0, 0, 0, 0))
    target_sprite_h = 27
    for r, (x0, x1) in enumerate(ordered_spans):
        fig = top.crop((x0, 0, x1, top.height))
        tight = fig.crop(fig.getbbox())
        scale = target_sprite_h / float(tight.height)
        nw = min(18, max(1, int(round(tight.width * scale))))
        nh = target_sprite_h
        s = tight.resize((nw, nh), Image.Resampling.LANCZOS)

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
                sheet.alpha_composite(s, (cell_ox, cell_oy - 1))
            else:
                sheet.alpha_composite(s, (cell_ox, cell_oy))

    sheet.save(CHAR_OUT)
    print(f"Saved Datuk Sampan character spritesheet: {CHAR_OUT} ({sheet.size})")

    # 2. DIALOGUE PORTRAITS (158x219, chest-up, centered, anchored at bottom)
    bot = cutout.crop((0, 395, cutout.width, cutout.height))
    tight_bot = bot.crop(bot.getbbox())
    print("Datuk portrait tight size:", tight_bot.size)

    scale_p = TARGET_H / float(tight_bot.height)
    nw_p = int(round(tight_bot.width * scale_p))
    nh_p = TARGET_H
    s_p = tight_bot.resize((nw_p, nh_p), Image.Resampling.LANCZOS)

    spix = s_p.load()
    for y in range(nh_p):
        for x in range(nw_p):
            r, g, b, a = spix[x, y]
            if a < 25:
                spix[x, y] = (0, 0, 0, 0)
            elif a >= 230:
                spix[x, y] = (r, g, b, 255)

    cw, ch = CANVAS_SIZE
    canvas = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    ox_p = (cw - nw_p) // 2
    oy_p = ch - nh_p
    canvas.alpha_composite(s_p, (ox_p, oy_p))
    print(f"Datuk portrait built: size={canvas.size}, scale={scale_p:.4f}, ox={ox_p}, oy={oy_p}, bbox={canvas.getbbox()}")

    for emo in ["neutral", "happy", "sad", "surprised"]:
        out_p = os.path.join(PORTRAIT_DIR, f"datuk_{emo}.png")
        canvas.save(out_p)
        print(f"Saved portrait: {out_p}")

    print("All Datuk Sampan assets built cleanly!")


if __name__ == "__main__":
    main()

