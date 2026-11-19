#!/usr/bin/env python3
"""
Extract and build chest-up dialogue portrait for HRD from the user-uploaded illustration.
- Portrait ONLY (no character spritesheet created, per user request).
- Canvas: 158x219 matching PortraitSlot (88x122) in dialogue_frame_ornate.png.
- Centered horizontally, resting directly on bottom border (y=219, zero gap).
- Clean alpha with zero white halo/fringe.
"""

import os
from PIL import Image

SRC_PATH = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/.user_uploaded/media_1794984140796_dd6ff6ea.png"
OUT_DIR = "assets/sprites/portraits"
CANVAS_SIZE = (158, 219)
TARGET_H = 215  # 4px top breathing room, bottom touches y=219 directly


def main():
    im = Image.open(SRC_PATH).convert("RGBA")
    print("Opened HRD source:", im.size, im.mode)

    # Extract bottom portrait illustration (below top sprites at y=385)
    bot = im.crop((0, 385, im.width, im.height))
    a_mask = bot.split()[3].point(lambda p: 255 if p > 25 else 0)
    tight = bot.crop(a_mask.getbbox())
    print("HRD tight portrait size:", tight.size)

    # Scale so full chest-up (including tie & lanyard ID badge) fits height 215px cleanly
    scale = TARGET_H / float(tight.height)
    nw = int(round(tight.width * scale))
    nh = TARGET_H
    scaled = tight.resize((nw, nh), Image.Resampling.LANCZOS)

    # Clean faint outer alpha fringe (< 25 -> 0) and solidify interior pixels
    spix = scaled.load()
    for y in range(nh):
        for x in range(nw):
            r, g, b, a = spix[x, y]
            if a < 25:
                spix[x, y] = (0, 0, 0, 0)
            elif a >= 230:
                spix[x, y] = (r, g, b, 255)

    cw, ch = CANVAS_SIZE
    canvas = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    ox = (cw - nw) // 2
    oy = ch - nh  # anchored cleanly at bottom border (zero gap)
    canvas.alpha_composite(scaled, (ox, oy))

    print(f"HRD portrait built: size={canvas.size}, scale={scale:.4f}, ox={ox}, oy={oy}, bbox={canvas.getbbox()}")

    for emo in ["neutral", "happy", "sad", "surprised"]:
        out_p = os.path.join(OUT_DIR, f"hrd_{emo}.png")
        canvas.save(out_p)
        print(f"Saved: {out_p}")

    print("Done building HRD dialogue portrait!")


if __name__ == "__main__":
    main()

