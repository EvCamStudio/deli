#!/usr/bin/env python3
"""
Clean up warung_barokah.png and warung_toko_jaya.png:
- Remove stray bounding-box wireframe lines (black/gray borders on sides/bottom).
- Remove floating noise pixels in empty space.
- Preserve 100% of authentic building, roof, crates, basins, brooms, and wares.
"""

from PIL import Image
from collections import deque

def clean_warung_barokah():
    path = "assets/sprites/props/warung_barokah.png"
    im = Image.open(path).convert("RGBA")
    w, h = im.size
    pix = im.load()

    # 1. Clear bottom border lines (rows >= 235)
    for y in range(235, h):
        for x in range(w):
            pix[x, y] = (0, 0, 0, 0)

    # 2. Clear left border line (x <= 1, y >= 100)
    for y in range(100, 235):
        for x in range(0, 2):
            pix[x, y] = (0, 0, 0, 0)

    # 3. Clear right border line (x >= 280, y >= 210)
    for y in range(210, 235):
        for x in range(280, w):
            pix[x, y] = (0, 0, 0, 0)

    # 4. Clean stray disconnected noise dots
    visited = set()
    components = []
    for y in range(h):
        for x in range(w):
            if pix[x, y][3] > 10 and (x, y) not in visited:
                comp = []
                q = deque([(x, y)])
                visited.add((x, y))
                while q:
                    cx, cy = q.popleft()
                    comp.append((cx, cy))
                    for dx, dy in [(-1,0), (1,0), (0,-1), (0,1), (-1,-1), (-1,1), (1,-1), (1,1)]:
                        nx, ny = cx + dx, cy + dy
                        if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in visited:
                            if pix[nx, ny][3] > 10:
                                visited.add((nx, ny))
                                q.append((nx, ny))
                components.append(comp)

    # Remove any tiny disconnected islands (size < 15) outside main building
    for c in components:
        if len(c) < 15:
            for cx, cy in c:
                pix[cx, cy] = (0, 0, 0, 0)

    im.save(path)
    print(f"[OK] Cleaned {path}: bbox={im.getbbox()}")

def clean_warung_toko_jaya():
    path = "assets/sprites/props/warung_toko_jaya.png"
    im = Image.open(path).convert("RGBA")
    w, h = im.size
    pix = im.load()

    # 1. Clear left vertical line (x <= 1, y >= 135)
    for y in range(135, h):
        for x in range(0, 2):
            pix[x, y] = (0, 0, 0, 0)

    # 2. Clear right vertical line (x >= 267, y >= 135)
    for y in range(135, h):
        for x in range(267, w):
            pix[x, y] = (0, 0, 0, 0)

    # 3. Clear floating horizontal wireframe line at y in [220, 221]
    # (where x < 15, x in 100..165, x >= 220)
    for y in [220, 221]:
        for x in range(w):
            if x < 15 or (100 <= x <= 165) or (x >= 220):
                pix[x, y] = (0, 0, 0, 0)

    # 4. Clean stray disconnected noise dots (size < 30)
    visited = set()
    components = []
    for y in range(h):
        for x in range(w):
            if pix[x, y][3] > 10 and (x, y) not in visited:
                comp = []
                q = deque([(x, y)])
                visited.add((x, y))
                while q:
                    cx, cy = q.popleft()
                    comp.append((cx, cy))
                    for dx, dy in [(-1,0), (1,0), (0,-1), (0,1), (-1,-1), (-1,1), (1,-1), (1,1)]:
                        nx, ny = cx + dx, cy + dy
                        if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in visited:
                            if pix[nx, ny][3] > 10:
                                visited.add((nx, ny))
                                q.append((nx, ny))
                components.append(comp)

    for c in components:
        if len(c) < 30:
            for cx, cy in c:
                pix[cx, cy] = (0, 0, 0, 0)

    im.save(path)
    print(f"[OK] Cleaned {path}: bbox={im.getbbox()}")

if __name__ == "__main__":
    clean_warung_barokah()
    clean_warung_toko_jaya()

