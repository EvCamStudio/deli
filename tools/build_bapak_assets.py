#!/usr/bin/env python3
"""
Build topdown spritesheet and dialogue portraits for Bapak MC (Pak Hendra)
from user-uploaded assets.
- Topdown character spritesheet: 72x112 (18x28 cell), 4-directional (Down, Left, Right, Up).
- Dialogue portraits: 158x219 canvas, chest-up, horizontally centered, anchored to bottom.
"""

import os
from PIL import Image

SRC_PATH = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/.user_uploaded/media_1794904203123_29ecf611.png"
CHAR_DIR = "assets/sprites/characters"
PORTRAIT_DIR = "assets/sprites/portraits"

CANVAS_SIZE = (158, 219)

def main():
    im = Image.open(SRC_PATH)
    print("Opened source image:", im.size, im.mode)

    # 1. TOPDOWN CHARACTER SPRITESHEET (72x112)
    top = im.crop((0, 0, im.width, 390))
    ranges = [(293, 468), (51, 235), (754, 937), (525, 698)] # Down, Left, Right, Up
    
    sheet = Image.new("RGBA", (72, 112), (0, 0, 0, 0))
    target_h = 27
    
    for r, (x0, x1) in enumerate(ranges):
        fig = top.crop((x0, 0, x1, 390))
        # clean alpha
        a = fig.split()[3].point(lambda p: 255 if p > 20 else 0)
        tight = fig.crop(a.getbbox())
        
        scale = target_h / tight.height
        nw = int(round(tight.width * scale))
        nh = target_h
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
            if c in [1, 3]:
                sheet.alpha_composite(s, (cell_ox, cell_oy - 1))
            else:
                sheet.alpha_composite(s, (cell_ox, cell_oy))
                
    sheet.save(os.path.join(CHAR_DIR, "bapak.png"))
    sheet.save(os.path.join(CHAR_DIR, "pak_hendra.png"))
    print(f"Saved character spritesheet to {CHAR_DIR}/bapak.png and pak_hendra.png ({sheet.size})")

    # 2. DIALOGUE PORTRAIT (158x219)
    bottom = im.crop((0, 380, im.width, im.height))
    a_bot = bottom.split()[3].point(lambda p: 255 if p > 20 else 0)
    tight_bot = bottom.crop(a_bot.getbbox())
    
    # Scale 0.37 gives matching head size (~122px) and chest-up framing
    scale_p = 0.37
    target_canvas_h = 215
    crop_h = min(tight_bot.height, int(target_canvas_h / scale_p))
    c_p = tight_bot.crop((0, 0, tight_bot.width, crop_h))
    
    nw_p = int(round(c_p.width * scale_p))
    nh_p = int(round(c_p.height * scale_p))
    s_p = c_p.resize((nw_p, nh_p), Image.Resampling.LANCZOS)
    
    # Clean alpha fringe
    spix = s_p.load()
    for y in range(nh_p):
        for x in range(nw_p):
            if spix[x, y][3] < 25:
                spix[x, y] = (0, 0, 0, 0)
                
    canv = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    ox = (158 - nw_p) // 2
    oy = 219 - nh_p
    canv.alpha_composite(s_p, (ox, oy))
    print(f"Bapak portrait generated: size={canv.size}, bbox={canv.getbbox()}")
    
    # Save portraits
    for prefix in ["bapak", "pak_hendra"]:
        for emo in ["neutral", "happy", "sad", "surprised"]:
            out_p = os.path.join(PORTRAIT_DIR, f"{prefix}_{emo}.png")
            canv.save(out_p)
            print(f"Saved portrait: {out_p}")

    print("All Bapak MC assets built successfully!")

if __name__ == "__main__":
    main()

