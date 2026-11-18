#!/usr/bin/env python3
"""
Extract clean transparent dialogue portraits for MC and Ibu from the user-uploaded illustrations.
- Flood-fills exterior background cleanly (preserving all internal white highlights like white shirts, hoodie strings, eyes, earrings).
- Cuts to neat half-body (waist/hands) so facial features and character outfit are prominent and clear in the ornate portrait frame.
- Centers into standard 160x200 portrait canvas matching dialogue_frame_ornate.png.
"""

import os
from PIL import Image
from collections import deque

MC_SRC = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/.user_uploaded/media_1794899432347_e223be35.jpg"
IBU_SRC = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/.user_uploaded/media_1794899412307_cb51b1c0.jpg"
OUT_DIR = "assets/sprites/portraits"

def clean_cutout(img_path, tol=60):
    im = Image.open(img_path).convert("RGB")
    w, h = im.size
    pix = im.load()
    visited = bytearray(w * h)
    queue = deque()
    
    # Seed boundary pixels
    for x in range(w):
        queue.append((x, 0))
        queue.append((x, h - 1))
        visited[0 * w + x] = 1
        visited[(h - 1) * w + x] = 1
    for y in range(h):
        queue.append((0, y))
        queue.append((w - 1, y))
        visited[y * w + 0] = 1
        visited[y * w + (w - 1)] = 1
    
    thresh = 255 - tol
    while queue:
        cx, cy = queue.popleft()
        for nx, ny in [(cx+1, cy), (cx-1, cy), (cx, cy+1), (cx, cy-1)]:
            if 0 <= nx < w and 0 <= ny < h:
                idx = ny * w + nx
                if not visited[idx]:
                    visited[idx] = 1
                    r, g, b = pix[nx, ny]
                    if r >= thresh and g >= thresh and b >= thresh:
                        queue.append((nx, ny))
                        
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out_pix = out.load()
    for y in range(h):
        for x in range(w):
            if not visited[y * w + x]:
                out_pix[x, y] = (*pix[x, y], 255)
    return out

def build_portrait(cutout, scale_val=0.36, canvas_size=(160, 200), max_canvas_h=196):
    bbox = cutout.getbbox()
    tight = cutout.crop(bbox)
    
    # Crop to half body (height limit based on max_canvas_h)
    crop_h = int(max_canvas_h / scale_val)
    cropped = tight.crop((0, 0, tight.width, min(tight.height, crop_h)))
    
    nw = int(round(cropped.width * scale_val))
    nh = int(round(cropped.height * scale_val))
    scaled = cropped.resize((nw, nh), Image.Resampling.LANCZOS)
    
    # Clean faint alpha on outer edges (< 25)
    spix = scaled.load()
    for y in range(nh):
        for x in range(nw):
            if spix[x, y][3] < 25:
                spix[x, y] = (0, 0, 0, 0)
                
    cw, ch = canvas_size
    canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    ox = (cw - nw) // 2
    oy = ch - nh # anchored at bottom
    canvas.alpha_composite(scaled, (ox, oy))
    return canvas

def main():
    print("Extracting transparent cutouts...")
    cut_mc = clean_cutout(MC_SRC, tol=60)
    cut_ibu = clean_cutout(IBU_SRC, tol=60)
    
    # Scale 0.36 gives the optimal half-body framing with head, face, and hands in pockets/waist
    port_mc = build_portrait(cut_mc, scale_val=0.36)
    port_ibu = build_portrait(cut_ibu, scale_val=0.36)
    
    # Save MC portraits
    for emo in ["neutral", "happy", "sad", "surprised"]:
        out_path = os.path.join(OUT_DIR, f"player_{emo}.png")
        port_mc.save(out_path)
        print(f"Saved MC portrait: {out_path} ({port_mc.size})")
        
    # Save Ibu portraits
    for emo in ["neutral", "happy", "sad", "surprised", "angry"]:
        out_path = os.path.join(OUT_DIR, f"ibu_{emo}.png")
        port_ibu.save(out_path)
        print(f"Saved Ibu portrait: {out_path} ({port_ibu.size})")
        
    print("Done!")

if __name__ == "__main__":
    main()

