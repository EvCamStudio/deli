#!/usr/bin/env python3
"""
Generate chest-up (sedada) dialogue portraits for MC (Player) and Ibu (Bu Mira)
scaled to fill the ornate frame naturally, horizontally centered, resting cleanly
at the bottom border with zero halo / white fringe.
Canvas: (158, 219) matching the exact inner window of dialogue_frame_ornate.png
and PortraitSlot (88, 122).
"""

import os
from PIL import Image

BRAIN_DIR = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8"
MC_CUTOUT = os.path.join(BRAIN_DIR, "mc_cutout.png")
IBU_CUTOUT = os.path.join(BRAIN_DIR, "ibu_cutout.png")
OUT_DIR = "assets/sprites/portraits"

CANVAS_SIZE = (158, 219) # Exact aspect ratio matching PortraitSlot (88x122) in frame
SCALE_VAL = 0.49         # Matched to user reference image 2
TARGET_H = 215           # Height from hair top to bottom of chest

def build_chest_portrait(cutout_path, scale_val=SCALE_VAL, target_h=TARGET_H, canvas_size=CANVAS_SIZE):
    im = Image.open(cutout_path)
    tight = im.crop(im.getbbox())
    
    # Calculate crop height in original resolution for chest-up
    crop_h = int(target_h / scale_val)
    c = tight.crop((0, 0, tight.width, min(tight.height, crop_h)))
    
    # Crop to tight bounding box of upper body so horizontal centering is exact
    tight_c = c.crop(c.getbbox())
    
    nw = int(round(tight_c.width * scale_val))
    nh = int(round(tight_c.height * scale_val))
    scaled = tight_c.resize((nw, nh), Image.Resampling.LANCZOS)
    
    # Clean faint alpha on outer edges (< 25)
    spix = scaled.load()
    for y in range(nh):
        for x in range(nw):
            if spix[x, y][3] < 25:
                spix[x, y] = (0, 0, 0, 0)
                
    cw, ch = canvas_size
    canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    ox = (cw - nw) // 2
    oy = ch - nh # anchored at bottom to touch the frame border
    canvas.alpha_composite(scaled, (ox, oy))
    return canvas

def main():
    print("Generating chest-up portraits for MC and Ibu...")
    port_mc = build_chest_portrait(MC_CUTOUT)
    port_ibu = build_chest_portrait(IBU_CUTOUT)
    
    print(f"MC portrait size: {port_mc.size}, bbox: {port_mc.getbbox()}")
    print(f"Ibu portrait size: {port_ibu.size}, bbox: {port_ibu.getbbox()}")
    
    # Save MC portraits
    for emo in ["neutral", "happy", "sad", "surprised"]:
        out_path = os.path.join(OUT_DIR, f"player_{emo}.png")
        port_mc.save(out_path)
        print(f"Saved: {out_path} ({port_mc.size})")
        
    # Save Ibu portraits
    for emo in ["neutral", "happy", "sad", "surprised", "angry"]:
        out_path = os.path.join(OUT_DIR, f"ibu_{emo}.png")
        port_ibu.save(out_path)
        print(f"Saved: {out_path} ({port_ibu.size})")
        
    print("Done generating chest-up portraits!")

if __name__ == "__main__":
    main()
