"""Build curated 32x32 pixel-art tileset and planting spot assets from uploaded sprite sheets.

Selects top-down assets from:
  - Sheet 2 (5x3 ground textures, mossy puddles, clover/flower decals)
  - Sheet 3 (1024x1024 meadow grass, wildflowers, ferns, dirt roads + leafy grass edges)
  - Sheet 4 (12x7 agricultural furrows, sprouts, cracked dry earth, coastal mud puddles)
Excludes 2.5D/platformer tiles from Sheet 1 because they clash with top-down perspective.
"""

from __future__ import annotations

import math
import os
import random
from collections import deque
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "assets")

SHEET2_PATH = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/.user_uploaded/media_1794426781609_c64aa95e.jpg"
SHEET3_PATH = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/.user_uploaded/media_1794426840128_b42756f3.jpg"
SHEET4_PATH = "/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8/.user_uploaded/media_1794426916574_cc83a842.jpg"

S4_COLS = [(8, 80), (94, 165), (179, 251), (264, 336), (349, 421), (434, 506),
           (518, 590), (603, 675), (688, 760), (774, 846), (858, 930), (944, 1016)]
S4_ROWS = [(8, 77), (87, 156), (166, 235), (245, 314), (324, 393), (401, 472), (480, 551)]


def harmonize_green_pixel(r: int, g: int, b: int) -> tuple[int, int, int]:
    """Tone down neon-lime greens slightly to match warm tropical Deli forests & parchment UI."""
    if g > 110 and g > b + 45 and r < g - 15:
        nr = int(r * 0.90 + 10)
        ng = int(g * 0.84 + 14)
        nb = int(b * 1.15 + 14)
        return (
            max(0, min(255, nr)),
            max(0, min(255, ng)),
            max(0, min(255, nb)),
        )
    return (r, g, b)


def harmonize_image(img: Image.Image) -> Image.Image:
    out = img.convert("RGBA")
    px = out.load()
    w, h = out.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            nr, ng, nb = harmonize_green_pixel(r, g, b)
            px[x, y] = (nr, ng, nb, a)
    return out


def strip_exterior_white(img: Image.Image, threshold: int = 190, dark_defringe=(58, 38, 24)) -> Image.Image:
    """Flood-fill remove exterior near-white background and aggressively clean neutral gray JPEG halos."""
    rgba = img.convert("RGBA")
    w, h = rgba.size
    px = rgba.load()
    visited = [[False] * w for _ in range(h)]
    q: deque[tuple[int, int]] = deque()

    def is_bg(r: int, g: int, b: int) -> bool:
        return min(r, g, b) > threshold and max(r, g, b) - min(r, g, b) < 42

    for x in range(w):
        for y in (0, h - 1):
            r, g, b, _ = px[x, y]
            if is_bg(r, g, b) and not visited[y][x]:
                visited[y][x] = True
                q.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            r, g, b, _ = px[x, y]
            if is_bg(r, g, b) and not visited[y][x]:
                visited[y][x] = True
                q.append((x, y))

    while q:
        cx, cy = q.popleft()
        px[cx, cy] = (0, 0, 0, 0)
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx]:
                r, g, b, _ = px[nx, ny]
                if is_bg(r, g, b):
                    visited[ny][nx] = True
                    q.append((nx, ny))

    # Defringe 2-pixel rim adjacent to transparent background
    for _pass in range(2):
        to_fix = []
        for y in range(h):
            for x in range(w):
                r, g, b, a = px[x, y]
                if a == 0:
                    continue
                adj_trans = any(
                    0 <= x + dx < w and 0 <= y + dy < h and px[x + dx, y + dy][3] == 0
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))
                )
                is_gray_halo = (max(r, g, b) - min(r, g, b) < 28 and min(r, g, b) > 75) or min(r, g, b) > 125
                if adj_trans and is_gray_halo:
                    to_fix.append((x, y))
        for x, y in to_fix:
            px[x, y] = (dark_defringe[0], dark_defringe[1], dark_defringe[2], 255)
    return rgba


def to32(img: Image.Image) -> Image.Image:
    return img.resize((32, 32), Image.Resampling.BOX)


def extract_s3_cell(s3: Image.Image, col: int, row: int) -> Image.Image:
    crop = s3.crop((col * 64, row * 64, (col + 1) * 64, (row + 1) * 64))
    return harmonize_image(to32(crop))


def extract_s4_cell(s4: Image.Image, col: int, row: int, trim: int = 0) -> Image.Image:
    x0, x1 = S4_COLS[col]
    y0, y1 = S4_ROWS[row]
    return s4.crop((x0 + trim, y0 + trim, x1 - trim, y1 - trim))


def make_seamless_edges(tile: Image.Image, margin: int = 3) -> Image.Image:
    rgba = tile.convert("RGBA")
    w, h = rgba.size
    px = rgba.load()
    out = rgba.copy()
    opx = out.load()
    for y in range(h):
        for i in range(margin):
            t = (i + 1) / (margin + 1)
            l = px[i, y]
            r = px[w - 1 - i, y]
            avg = tuple(int(l[c] * 0.5 + r[c] * 0.5) for c in range(4))
            opx[i, y] = tuple(int(l[c] * t + avg[c] * (1 - t)) for c in range(4))
            opx[w - 1 - i, y] = tuple(int(r[c] * t + avg[c] * (1 - t)) for c in range(4))
    px2 = out.load()
    out2 = out.copy()
    opx2 = out2.load()
    for x in range(w):
        for i in range(margin):
            t = (i + 1) / (margin + 1)
            top = px2[x, i]
            bot = px2[x, h - 1 - i]
            avg = tuple(int(top[c] * 0.5 + bot[c] * 0.5) for c in range(4))
            opx2[x, i] = tuple(int(top[c] * t + avg[c] * (1 - t)) for c in range(4))
            opx2[x, h - 1 - i] = tuple(int(bot[c] * t + avg[c] * (1 - t)) for c in range(4))
    return out2


def blend_edges_to_bg(tile: Image.Image, bg: Image.Image, border: int = 3) -> Image.Image:
    """Fade outer border pixels smoothly into target seamless grass/bg so tiles blend seamlessly."""
    out = tile.convert("RGBA").copy()
    opx = out.load()
    bpx = bg.convert("RGBA").load()
    w, h = out.size
    for y in range(h):
        for x in range(w):
            d = min(x, y, w - 1 - x, h - 1 - y)
            if d < border:
                t = (d + 0.5) / (border + 0.5)
                r, g, b, _ = opx[x, y]
                br, bgc, bb, _ = bpx[x, y]
                opx[x, y] = (
                    int(br * (1 - t) + r * t),
                    int(bgc * (1 - t) + g * t),
                    int(bb * (1 - t) + b * t),
                    255,
                )
    return out


def extract_s2_tile(s2: Image.Image, col: int, row: int) -> Image.Image:
    s2_cols = [(4, 186), (215, 395), (424, 600), (629, 809), (838, 1020)]
    s2_rows = [(9, 180), (201, 372), (393, 559)]
    x0, x1 = s2_cols[col]
    y0, y1 = s2_rows[row]
    return to32(s2.crop((x0, y0, x1, y1)))


def color_match_to_grass(tile: Image.Image, target_grass: Image.Image) -> Image.Image:
    """Match a Sheet 2 grass tile's palette ratio closely to harmonized Sheet 3 meadow."""
    t_px = target_grass.load()
    tw, th = target_grass.size
    tr = sum(t_px[x, y][0] for y in range(th) for x in range(tw)) / (tw * th)
    tg = sum(t_px[x, y][1] for y in range(th) for x in range(tw)) / (tw * th)
    tb = sum(t_px[x, y][2] for y in range(th) for x in range(tw)) / (tw * th)

    rgba = tile.convert("RGBA")
    px = rgba.load()
    w, h = rgba.size
    greens = []
    for y in range(h):
        for x in range(w):
            r, g, b, _ = px[x, y]
            if g > r + 20 and g > b + 40 and 145 < g < 215:
                greens.append((r, g, b))
    if not greens:
        return harmonize_image(rgba)
    sr = sum(c[0] for c in greens) / len(greens)
    sg = sum(c[1] for c in greens) / len(greens)
    sb = sum(c[2] for c in greens) / len(greens)

    out = rgba.copy()
    opx = out.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            # Preserve cool blue-gray / brown mud stones while blending flat green closely to target grass
            if g > r + 22 and g > b + 40:
                gr, gg, gb, _ = t_px[x, y]
                # Blend 60% toward target grass tone while keeping local shading
                shade = (g - sg) * 0.45
                nr = int(gr + shade * 0.5)
                ng = int(gg + shade)
                nb = int(gb + shade * 0.3)
            else:
                nr = int(r * (tr / max(1.0, sr)))
                ng = int(g * (tg / max(1.0, sg)))
                nb = int(b * (tb / max(1.0, sb)))
                if b > r and g < r + 35:
                    nr, ng, nb = int(r * 0.9), int(g * 0.9), int(b * 0.95)
            opx[x, y] = (max(0, min(255, nr)), max(0, min(255, ng)), max(0, min(255, nb)), a)
    return blend_edges_to_bg(out, target_grass, border=3)


def extract_s2_decals(s2: Image.Image, col: int, row: int) -> Image.Image:
    # Crop well inside white gutter bounds (margin=8 px inside raw tile) so white edges never leak
    s2_cols = [(12, 178), (223, 387), (432, 592), (637, 801), (846, 1012)]
    s2_rows = [(17, 172), (209, 364), (401, 551)]
    x0, x1 = s2_cols[col]
    y0, y1 = s2_rows[row]
    tile = to32(s2.crop((x0, y0, x1, y1))).convert("RGBA")
    px = tile.load()
    w, h = tile.size
    bg_samples = []
    for y in range(h):
        for x in range(w):
            r, g, b, _ = px[x, y]
            if 70 <= r <= 125 and 155 <= g <= 200 and 15 <= b <= 55:
                bg_samples.append((r, g, b))
    if not bg_samples:
        return tile
    br = sum(c[0] for c in bg_samples) / len(bg_samples)
    bg = sum(c[1] for c in bg_samples) / len(bg_samples)
    bb = sum(c[2] for c in bg_samples) / len(bg_samples)

    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    opx = out.load()
    # Skip 1px outer ring to guarantee zero JPEG gutter bleed
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            r, g, b, _ = px[x, y]
            # Reject neutral near-white / gray pixels from JPEG margins
            if min(r, g, b) > 195 or (min(r, g, b) > 165 and max(r, g, b) - min(r, g, b) < 35):
                continue
            dist = abs(r - br) + abs(g - bg) + abs(b - bb)
            if dist > 28:
                nr, ng, nb = harmonize_green_pixel(r, g, b)
                opx[x, y] = (nr, ng, nb, 255)
    return out


def extract_s3_dirt_patch(s3: Image.Image) -> Image.Image:
    """Create a smooth seamless 32x32 dirt road tile matched to Sheet 3's warm path earth."""
    # Sample core dirt color cleanly from Sheet 3 vertical path interior (x=850..870, y=710..760)
    core = s3.crop((850, 710, 870, 760))
    cpx = core.load()
    rs, gs, bs = [], [], []
    for y in range(core.size[1]):
        for x in range(core.size[0]):
            r, g, b = cpx[x, y]
            if r > 175 and g > 125 and b < 105:
                rs.append(r); gs.append(g); bs.append(b)
    base_r = int(sum(rs) / max(1, len(rs)))
    base_g = int(sum(gs) / max(1, len(gs)))
    base_b = int(sum(bs) / max(1, len(bs)))

    rng = random.Random(19)
    tile = Image.new("RGBA", (32, 32), (base_r, base_g, base_b, 255))
    tpx = tile.load()
    # Gentle mottled earth & tiny warm/cool pebbles without harsh repeating dark blobs
    for y in range(32):
        for x in range(32):
            v = rng.random()
            if v < 0.09:
                tpx[x, y] = (base_r - 12, base_g - 11, base_b - 8, 255)
            elif v < 0.16:
                tpx[x, y] = (min(255, base_r + 10), min(255, base_g + 9), min(255, base_b + 6), 255)
    # A few tiny 2px pebbles matching Sheet 3 dirt style
    for px_x, px_y in ((7, 9), (22, 19), (14, 26)):
        tpx[px_x, px_y] = (base_r - 24, base_g - 22, base_b - 14, 255)
        tpx[px_x + 1, px_y] = (base_r - 14, base_g - 12, base_b - 8, 255)
    return make_seamless_edges(tile, margin=2)


def build_leafy_dirt_autotiles(s3: Image.Image, grass_base: Image.Image, dirt_base: Image.Image) -> dict[str, Image.Image]:
    """Build complete, zero-artifact grass-to-dirt autotile edges & corners by rotating clean S3 left rim."""
    # Look at zoom_s3_paths.png around col 12..13: grass->dirt leafy rim sits at x=834..840.
    # Cropping 824..888 puts the leafy rim cleanly at x=5..8 (out of 32), leaving generous walkable dirt!
    left_src = to32(s3.crop((824, 704, 888, 768)))
    px = left_src.convert("RGBA").load()
    left_overlay = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    opx = left_overlay.load()
    for y in range(32):
        for x in range(11):
            r, g, b, _ = px[x, y]
            is_dirt = (r > 138 and r > g + 10 and g > b + 15 and b < 115)
            if not is_dirt:
                nr, ng, nb = harmonize_green_pixel(r, g, b)
                opx[x, y] = (nr, ng, nb, 255)

    # Rotate clean left rim cleanly so top, bottom, left, right have identical lush leafy style
    right_overlay = left_overlay.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    top_overlay = left_overlay.transpose(Image.Transpose.ROTATE_270)
    bottom_overlay = left_overlay.transpose(Image.Transpose.ROTATE_90)

    def compose(*overlays: Image.Image) -> Image.Image:
        res = dirt_base.copy()
        for ov in overlays:
            res.alpha_composite(ov)
        return res

    # Rounded outer corner fillet ONLY inside the inner dirt quadrant x>=8, y>=8
    def make_outer_corner(flip_x: bool, flip_y: bool) -> Image.Image:
        res = compose(top_overlay, left_overlay)
        rpx = res.load()
        gpx = grass_base.load()
        leaf_dark = harmonize_green_pixel(44, 102, 26) + (255,)
        leaf_mid = harmonize_green_pixel(68, 138, 36) + (255,)
        for y in range(8, 15):
            for x in range(8, 15):
                d = math.hypot(14.5 - x, 14.5 - y)
                if d > 6.5:
                    rpx[x, y] = gpx[x, y]
                elif d > 5.0:
                    rpx[x, y] = leaf_dark if (x + y) % 2 == 0 else leaf_mid
        if flip_x:
            res = res.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        if flip_y:
            res = res.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
        return res

    # Rounded small inner corner (used where vertical path T-junction meets horizontal path)
    def make_inner_corner(flip_x: bool, flip_y: bool) -> Image.Image:
        in_tl = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
        hpx = top_overlay.load()
        vpx = left_overlay.load()
        ipx = in_tl.load()
        gpx = grass_base.load()
        for y in range(11):
            for x in range(11):
                d = math.hypot(x + 0.5, y + 0.5)
                if d <= 5.5:
                    ipx[x, y] = gpx[x, y]
                elif d <= 7.8:
                    cand = hpx[x, 6] if hpx[x, 6][3] > 0 else vpx[6, y]
                    ipx[x, y] = cand if cand[3] > 0 else harmonize_green_pixel(46, 108, 28) + (255,)
                elif d <= 9.2 and (x * 3 + y * 5) % 4 == 0:
                    ipx[x, y] = harmonize_green_pixel(62, 134, 34) + (255,)
        if flip_x:
            in_tl = in_tl.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        if flip_y:
            in_tl = in_tl.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
        return compose(in_tl)

    return {
        "top": compose(top_overlay),
        "bottom": compose(bottom_overlay),
        "left": compose(left_overlay),
        "right": compose(right_overlay),
        "outer_tl": make_outer_corner(False, False),
        "outer_tr": make_outer_corner(True, False),
        "outer_bl": make_outer_corner(False, True),
        "outer_br": make_outer_corner(True, True),
        "inner_tl": make_inner_corner(False, False),
        "inner_tr": make_inner_corner(True, False),
        "inner_bl": make_inner_corner(False, True),
        "inner_br": make_inner_corner(True, True),
        "vert_1tile": compose(left_overlay, right_overlay),
        "horiz_1tile": compose(top_overlay, bottom_overlay),
    }


def make_dirt_circle_tile(s3: Image.Image, grass_base: Image.Image, col: int, row: int) -> Image.Image:
    cell = extract_s3_cell(s3, col, row)
    res = grass_base.copy()
    cpx = cell.load()
    rpx = res.load()
    for y in range(32):
        for x in range(32):
            r, g, b, _ = cpx[x, y]
            if min(r, g, b) > 195:
                continue
            rpx[x, y] = (r, g, b, 255)
    return blend_edges_to_bg(res, grass_base, border=2)


def extract_s4_seamless_furrow(s4: Image.Image, col: int, row: int) -> Image.Image:
    inner = extract_s4_cell(s4, col, row, trim=6)
    return make_seamless_edges(to32(inner).convert("RGBA"), margin=2)


def extract_s4_on_bg(s4: Image.Image, col: int, row: int, bg_tile: Image.Image, soften: bool = False) -> Image.Image:
    trim = 5 if soften else 1
    raw = strip_exterior_white(extract_s4_cell(s4, col, row, trim=trim), threshold=188)
    fg = to32(raw)
    out = bg_tile.copy().convert("RGBA")
    if soften:
        # Organic circular-feathered blend onto light sand (no hard square frame!)
        fpx = fg.load()
        bpx = out.load()
        for y in range(32):
            for x in range(32):
                r, g, b, a = fpx[x, y]
                if a == 0:
                    continue
                d = math.hypot((x - 15.5) / 13.5, (y - 15.5) / 13.5)
                if d > 1.0:
                    continue
                t = max(0.0, min(0.88, (1.0 - d) * 1.65))
                br, bgc, bb, _ = bpx[x, y]
                bpx[x, y] = (
                    int(br * (1 - t) + r * t),
                    int(bgc * (1 - t) + g * t),
                    int(bb * (1 - t) + b * t),
                    255,
                )
        return out
    out.alpha_composite(fg)
    return out


def build_procedural_complement_tiles(grass_base: Image.Image) -> dict[str, Image.Image]:
    out: dict[str, Image.Image] = {}
    rng = random.Random(42)

    RIVER = (62, 143, 176, 255)
    RIVER_LIGHT = (96, 181, 204, 255)
    RIVER_DARK = (48, 122, 156, 255)
    for idx, shift in enumerate((0, 8)):
        wimg = Image.new("RGBA", (32, 32), RIVER)
        wd = ImageDraw.Draw(wimg)
        for ry in (5, 13, 21, 29):
            x0 = (ry * 3 + shift) % 20 + 1
            wd.line((x0, ry, x0 + 8, ry), fill=RIVER_LIGHT, width=1)
            wd.line((x0 + 2, ry + 2, x0 + 9, ry + 2), fill=RIVER_DARK, width=1)
        out[f"water_{idx}"] = wimg

    SAND_BASE = (224, 200, 144, 255)
    SAND_SPECK_A = (206, 180, 126, 255)
    SAND_SPECK_B = (238, 218, 166, 255)
    for idx in range(2):
        simg = Image.new("RGBA", (32, 32), SAND_BASE)
        spx = simg.load()
        for _ in range(42):
            spx[rng.randrange(32), rng.randrange(32)] = SAND_SPECK_A if rng.random() < 0.55 else SAND_SPECK_B
        for _ in range(3):
            px_x = rng.randrange(3, 29)
            px_y = rng.randrange(3, 29)
            spx[px_x, px_y] = (188, 160, 112, 255)
            spx[px_x + 1, px_y] = (244, 228, 188, 255)
        out[f"sand_{idx}"] = simg

    for idx, is_top in enumerate((True, False)):
        bimg = out["sand_0"].copy()
        bd = ImageDraw.Draw(bimg)
        y_edge = 0 if is_top else 30
        bd.line((0, y_edge, 31, y_edge), fill=(168, 204, 198, 255), width=2)
        out[f"bank_{idx}"] = bimg

    # Organic leafy grass-to-sand transitions (matching Sheet 3's lush rim look!)
    sand_ref = out["sand_0"]
    gpx = grass_base.load()
    leaf_dark = harmonize_green_pixel(44, 104, 26) + (255,)
    leaf_mid = harmonize_green_pixel(64, 138, 36) + (255,)
    sand_shadow = (190, 164, 114, 255)
    for name, edge in (("gs_top", "top"), ("gs_bot", "bot"), ("gs_left", "left"), ("gs_right", "right")):
        tile = sand_ref.copy()
        tpx = tile.load()
        for y in range(32):
            for x in range(32):
                pos = x if edge in ("top", "bot") else y
                wobble = int(2.3 * math.sin(pos * 0.42 + 0.6) + 1.1 * math.cos(pos * 0.9))
                dist = {"top": y, "bot": 31 - y, "left": x, "right": 31 - x}[edge]
                limit = 10 + wobble
                if dist < limit - 1:
                    tpx[x, y] = gpx[x, y]
                elif dist == limit - 1:
                    tpx[x, y] = leaf_mid if (x + y) % 2 == 0 else gpx[x, y]
                elif dist == limit:
                    tpx[x, y] = leaf_dark
                elif dist == limit + 1:
                    tpx[x, y] = leaf_mid if (pos % 3 == 0) else sand_shadow
                elif dist == limit + 2 and pos % 2 == 0:
                    tpx[x, y] = sand_shadow
        out[name] = tile

    # Kota cobblestone paving
    for idx, shade in enumerate((0, -8)):
        st = Image.new("RGBA", (32, 32), (166 + shade, 164 + shade, 154 + shade, 255))
        sd = ImageDraw.Draw(st)
        mortar = (120 + shade, 118 + shade, 110 + shade, 255)
        hi = (192 + shade, 190 + shade, 180 + shade, 255)
        for row_y in range(0, 32, 8):
            sd.line((0, row_y, 31, row_y), fill=mortar)
            sd.line((0, row_y + 1, 31, row_y + 1), fill=hi)
            off = 0 if (row_y // 8) % 2 == 0 else 8
            for vx in range(off, 32, 16):
                sd.line((vx, row_y, vx, row_y + 7), fill=mortar)
                if vx + 1 < 32:
                    sd.line((vx + 1, row_y + 1, vx + 1, row_y + 6), fill=hi)
        spx = st.load()
        for _ in range(28):
            spx[rng.randrange(32), rng.randrange(32)] = (146 + shade, 144 + shade, 136 + shade, 255)
        out[f"stone_{idx}"] = st

    # Wooden bridge planks
    for idx, vertical in enumerate((False, True)):
        pimg = Image.new("RGBA", (32, 32), (156, 108, 62, 255))
        pd = ImageDraw.Draw(pimg)
        seam = (98, 64, 34, 255)
        hi = (196, 146, 94, 255)
        nail = (68, 46, 28, 255)
        if not vertical:
            for y in range(0, 32, 8):
                pd.line((0, y, 31, y), fill=seam)
                pd.line((0, y + 1, 31, y + 1), fill=hi)
                pd.point((3, y + 4), fill=nail)
                pd.point((28, y + 4), fill=nail)
            pd.line((6, 0, 6, 31), fill=(124, 84, 46, 255))
            pd.line((25, 0, 25, 31), fill=(124, 84, 46, 255))
        else:
            for x in range(0, 32, 8):
                pd.line((x, 0, x, 31), fill=seam)
                pd.line((x + 1, 0, x + 1, 31), fill=hi)
                pd.point((x + 4, 3), fill=nail)
                pd.point((x + 4, 28), fill=nail)
            pd.line((0, 6, 31, 6), fill=(124, 84, 46, 255))
            pd.line((0, 25, 31, 25), fill=(124, 84, 46, 255))
        out[f"plank_{idx}"] = pimg

    # Bricks & Roofs
    bimg = Image.new("RGBA", (32, 32), (176, 122, 82, 255))
    bd = ImageDraw.Draw(bimg)
    for row_y in range(0, 32, 8):
        bd.line((0, row_y, 31, row_y), fill=(126, 82, 54, 255))
        off = 0 if (row_y // 8) % 2 == 0 else 8
        for vx in range(off, 32, 16):
            bd.line((vx, row_y, vx, row_y + 7), fill=(126, 82, 54, 255))
    out["brick"] = bimg

    rimg = Image.new("RGBA", (32, 32), (168, 82, 64, 255))
    rd = ImageDraw.Draw(rimg)
    for row_y in range(0, 32, 8):
        rd.line((0, row_y, 31, row_y), fill=(118, 48, 40, 255))
        rd.arc((2, row_y, 16, row_y + 7), 180, 360, fill=(208, 114, 84, 255))
        rd.arc((16, row_y, 30, row_y + 7), 180, 360, fill=(208, 114, 84, 255))
    out["roof"] = rimg

    # Rustic seamless wooden fences
    DARK_OUT = (62, 42, 26, 255)
    WOOD_MID = (146, 98, 56, 255)
    WOOD_HI = (182, 130, 82, 255)
    WOOD_SHADE = (112, 72, 40, 255)
    for idx in range(2):
        fimg = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
        fd = ImageDraw.Draw(fimg)
        for ry in (11, 21):
            fd.rectangle((0, ry, 31, ry + 4), fill=WOOD_MID, outline=DARK_OUT)
            fd.line((0, ry + 1, 31, ry + 1), fill=WOOD_HI)
            fd.line((0, ry + 3, 31, ry + 3), fill=WOOD_SHADE)
        for px0 in ((3, 19) if idx == 0 else (7, 23)):
            fd.rectangle((px0, 4, px0 + 5, 30), fill=WOOD_MID, outline=DARK_OUT)
            fd.line((px0 + 1, 5, px0 + 4, 5), fill=WOOD_HI)
            fd.line((px0 + 1, 6, px0 + 1, 29), fill=WOOD_HI)
            fd.line((px0 + 4, 6, px0 + 4, 29), fill=WOOD_SHADE)
        out[f"fence_{idx}"] = fimg

    # Lush textured bush & mossy stone
    bush = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    bd = ImageDraw.Draw(bush)
    bd.ellipse((4, 23, 28, 30), fill=(26, 54, 22, 110))
    bd.ellipse((2, 9, 20, 27), fill=harmonize_green_pixel(44, 102, 38) + (255,), outline=harmonize_green_pixel(28, 66, 24) + (255,))
    bd.ellipse((12, 6, 30, 26), fill=harmonize_green_pixel(54, 120, 42) + (255,), outline=harmonize_green_pixel(28, 66, 24) + (255,))
    bd.ellipse((7, 13, 25, 28), fill=harmonize_green_pixel(38, 92, 32) + (255,), outline=harmonize_green_pixel(28, 66, 24) + (255,))
    bd.ellipse((8, 7, 22, 18), fill=harmonize_green_pixel(88, 162, 54) + (255,))
    bd.ellipse((15, 10, 26, 19), fill=harmonize_green_pixel(74, 146, 46) + (255,))
    out["bush"] = bush

    rock = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    rd = ImageDraw.Draw(rock)
    rd.ellipse((4, 22, 28, 29), fill=(36, 42, 34, 90))
    rd.polygon([(5, 23), (4, 15), (10, 9), (21, 9), (27, 15), (26, 24), (16, 27)], fill=(126, 130, 126, 255), outline=(66, 68, 64, 255))
    rd.polygon([(7, 15), (11, 10), (20, 10), (23, 14), (17, 18), (10, 18)], fill=(162, 166, 160, 255))
    rd.line((10, 11, 18, 11), fill=(192, 196, 190, 255))
    rd.polygon([(6, 21), (8, 17), (12, 19), (10, 23)], fill=harmonize_green_pixel(64, 130, 44) + (255,))
    out["rock"] = rock

    pebbles = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    pd = ImageDraw.Draw(pebbles)
    pd.ellipse((6, 18, 13, 23), fill=(138, 132, 120, 255), outline=(78, 74, 66, 255))
    pd.ellipse((18, 12, 24, 16), fill=(154, 148, 136, 255), outline=(78, 74, 66, 255))
    pd.ellipse((14, 22, 19, 25), fill=(236, 216, 182, 255), outline=(146, 126, 98, 255))
    out["pebbles"] = pebbles

    return out


def build_tree_spot_sprite() -> None:
    """Create crisp 16x16 transparent tree-sapling marker with subtle ring (zero soil/dirt)."""
    spot = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    px = spot.load()

    ring = (246, 232, 192, 145)
    shadow = (28, 48, 22, 65)
    for x in range(6, 11):
        px[x, 12] = shadow
    for x, y in [
        (5, 9), (6, 9), (10, 9), (11, 9),
        (3, 10), (13, 10),
        (2, 11), (14, 11),
        (2, 12), (14, 12),
        (3, 13), (13, 13),
        (5, 14), (7, 14), (9, 14), (11, 14),
    ]:
        px[x, y] = ring

    stem_c = (122, 86, 48, 255)
    stem_hi = (146, 108, 64, 255)
    leaf_hi = (138, 202, 92, 255)
    leaf_mid = (92, 158, 74, 255)
    leaf_dk = (62, 118, 56, 255)
    out = (36, 54, 28, 255)

    fill_map: dict[tuple[int, int], tuple[int, int, int, int]] = {
        # Woody green-brown stem anchored cleanly over shadow
        (8, 12): stem_c, (8, 11): stem_hi, (8, 10): stem_c, (8, 9): stem_hi, (8, 8): leaf_dk,
        # Top shoot bud
        (7, 4): leaf_hi, (8, 4): leaf_mid, (7, 5): leaf_mid, (8, 5): leaf_dk,
        # Left young leaf
        (3, 6): leaf_hi, (4, 6): leaf_hi, (5, 6): leaf_mid, (6, 6): leaf_dk,
        (4, 7): leaf_mid, (5, 7): leaf_dk, (6, 7): leaf_dk,
        # Right young leaf
        (10, 5): leaf_hi, (11, 5): leaf_hi, (12, 5): leaf_mid,
        (9, 6): leaf_mid, (10, 6): leaf_mid, (11, 6): leaf_dk,
        (9, 7): leaf_dk, (10, 7): leaf_dk,
    }
    for (fx, fy), col in fill_map.items():
        px[fx, fy] = col
    for fx, fy in list(fill_map.keys()):
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = fx + dx, fy + dy
            if (nx, ny) not in fill_map and 0 <= nx < 16 and 0 <= ny < 16:
                px[nx, ny] = out

    path = os.path.join(ASSETS, "sprites", "props", "tree_spot.png")
    spot.save(path)
    print("Saved", path, spot.size)


def main() -> None:
    s2 = Image.open(SHEET2_PATH).convert("RGB")
    s3 = Image.open(SHEET3_PATH).convert("RGB")
    s4 = Image.open(SHEET4_PATH).convert("RGB")

    g0 = make_seamless_edges(extract_s3_cell(s3, 0, 0), margin=3)
    g1 = make_seamless_edges(extract_s3_cell(s3, 1, 2), margin=3)
    g2 = make_seamless_edges(extract_s3_cell(s3, 2, 1), margin=3)

    dirt_pure = extract_s3_dirt_patch(s3)
    dirt_pure2 = make_seamless_edges(dirt_pure.transpose(Image.Transpose.FLIP_LEFT_RIGHT), margin=3)
    path_tiles = build_leafy_dirt_autotiles(s3, g0, dirt_pure)
    comp = build_procedural_complement_tiles(g0)

    s2_flora_decals = extract_s2_decals(s2, 3, 1)
    meadow_clover_flowers = g0.copy()
    meadow_clover_flowers.alpha_composite(s2_flora_decals)

    s2_mossy_puddle = color_match_to_grass(extract_s2_tile(s2, 3, 0), g0)
    s2_mud_puddle = color_match_to_grass(extract_s2_tile(s2, 2, 2), g0)

    def extract_s3_decal(col: int, row: int) -> Image.Image:
        c = extract_s3_cell(s3, col, row)
        cpx = c.load()
        out = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
        opx = out.load()
        for y in range(3, 29):
            for x in range(3, 29):
                r, g, b, _ = cpx[x, y]
                if abs(r - 84) + abs(g - 159) + abs(b - 49) > 30:
                    opx[x, y] = (r, g, b, 255)
        return out

    meadow_white_fl = blend_edges_to_bg(extract_s3_cell(s3, 5, 1), g0, border=3)
    meadow_pink_fl = blend_edges_to_bg(extract_s3_cell(s3, 3, 4), g0, border=3)
    meadow_moss_patch = blend_edges_to_bg(extract_s3_cell(s3, 5, 5), g0, border=3)
    decal_fern = extract_s3_decal(6, 0)
    decal_flowers = s2_flora_decals

    circle_dirt = make_dirt_circle_tile(s3, g0, 9, 1)
    circle_dark_earth = make_dirt_circle_tile(s3, g0, 8, 12)

    furrow_h_dry = extract_s4_seamless_furrow(s4, 8, 1)
    furrow_h_moist = extract_s4_seamless_furrow(s4, 5, 1)
    furrow_sprouts = extract_s4_seamless_furrow(s4, 11, 3)
    furrow_v_moist = extract_s4_seamless_furrow(s4, 9, 1)

    loam_sprout_grass = extract_s4_on_bg(s4, 10, 4, g0)
    cracked_grass = extract_s4_on_bg(s4, 6, 4, g0)
    mud_puddle_tile = extract_s4_on_bg(s4, 8, 5, g0)
    waterlogged_furrow = extract_s4_seamless_furrow(s4, 7, 6)

    mud_sand = extract_s4_on_bg(s4, 8, 5, comp["sand_0"], soften=True)
    cracked_sand = extract_s4_on_bg(s4, 6, 4, comp["sand_0"], soften=True)

    atlas = Image.new("RGBA", (8 * 32, 8 * 32), (0, 0, 0, 0))

    def put(cx: int, cy: int, tile: Image.Image) -> None:
        atlas.paste(tile.convert("RGBA"), (cx * 32, cy * 32))

    # Row 0: Base ground, dirt, path, stone
    put(0, 0, g0); put(1, 0, g1); put(2, 0, g2)
    put(3, 0, make_seamless_edges(to32(extract_s4_cell(s4, 0, 0, trim=6)), margin=2))
    put(4, 0, dirt_pure); put(5, 0, dirt_pure2)
    put(6, 0, comp["stone_0"]); put(7, 0, comp["stone_1"])

    # Row 1: Water, banks, sand, planks
    put(0, 1, comp["water_0"]); put(1, 1, comp["water_1"])
    put(2, 1, comp["bank_0"]); put(3, 1, comp["bank_1"])
    put(4, 1, comp["sand_0"]); put(5, 1, comp["sand_1"])
    put(6, 1, comp["plank_0"]); put(7, 1, comp["plank_1"])

    # Row 2: Bricks, roofs, fences, bush, rock
    put(0, 2, comp["brick"]); put(1, 2, comp["brick"])
    put(2, 2, comp["roof"]); put(3, 2, comp["roof"])
    put(4, 2, comp["fence_0"]); put(5, 2, comp["fence_1"])
    put(6, 2, comp["bush"]); put(7, 2, comp["rock"])

    # Row 3: Rich Meadow & Forest Ground Variants
    put(0, 3, meadow_white_fl)
    put(1, 3, meadow_pink_fl)
    put(2, 3, meadow_clover_flowers)
    put(3, 3, meadow_moss_patch)
    put(4, 3, s2_mossy_puddle)
    put(5, 3, s2_mud_puddle)
    put(6, 3, circle_dirt)
    put(7, 3, circle_dark_earth)

    # Row 4: Grass-to-Dirt Path Edges
    put(0, 4, path_tiles["top"])
    put(1, 4, path_tiles["bottom"])
    put(2, 4, path_tiles["left"])
    put(3, 4, path_tiles["right"])
    put(4, 4, path_tiles["outer_tl"])
    put(5, 4, path_tiles["outer_tr"])
    put(6, 4, path_tiles["outer_bl"])
    put(7, 4, path_tiles["outer_br"])

    # Row 5: Inner Corners + 1-Tile Paths + Transparent Decals
    put(0, 5, path_tiles["inner_tl"])
    put(1, 5, path_tiles["inner_tr"])
    put(2, 5, path_tiles["inner_bl"])
    put(3, 5, path_tiles["inner_br"])
    put(4, 5, path_tiles["vert_1tile"])
    put(5, 5, path_tiles["horiz_1tile"])
    put(6, 5, decal_flowers)
    put(7, 5, decal_fern)

    # Row 6: Agricultural Farm Furrows, Sprouts, Cracked Earth & Wet Mud
    put(0, 6, furrow_h_dry)
    put(1, 6, furrow_h_moist)
    put(2, 6, furrow_sprouts)
    put(3, 6, furrow_v_moist)
    put(4, 6, loam_sprout_grass)
    put(5, 6, cracked_grass)
    put(6, 6, mud_puddle_tile)
    put(7, 6, waterlogged_furrow)

    # Row 7: Sand Transitions & Coastal Mud / Pebbles
    put(0, 7, comp["gs_top"])
    put(1, 7, comp["gs_bot"])
    put(2, 7, comp["gs_left"])
    put(3, 7, comp["gs_right"])
    put(4, 7, mud_sand)
    put(5, 7, cracked_sand)
    put(6, 7, comp["pebbles"])

    out_path = os.path.join(ASSETS, "tilesets", "pilot_tileset.png")
    atlas.save(out_path)
    print("Saved", out_path, atlas.size)

    build_tree_spot_sprite()


if __name__ == "__main__":
    main()
