"""Generate premium 16x24 top-down character sprites (4 arah x 4 frame).

Digambar prosedural dengan palet bertingkat (shadow/base/light), outline
otomatis, dan detail khas per karakter supaya tidak ada yang kembar.
Output: sprite sheet 64x96 yang dibaca player_topdown.gd / npc_topdown.gd.

Jalankan:  python tools/generate_characters.py
"""

from __future__ import annotations

import os
from dataclasses import dataclass
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "assets", "sprites", "characters")

W, H = 16, 24
OUTLINE = (34, 26, 30, 255)


# ------------------------------------------------------------------ helpers --
def shade(c, f):
    return (
        max(0, min(255, int(c[0] * f))),
        max(0, min(255, int(c[1] * f))),
        max(0, min(255, int(c[2] * f))),
        255,
    )


def tint(c, other, amount):
    return tuple(int(c[i] * (1 - amount) + other[i] * amount) for i in range(3)) + (255,)


def tone(c):
    return (c[0], c[1], c[2], 255)


class Canvas:
    def __init__(self) -> None:
        self.px: dict[tuple[int, int], tuple[int, int, int, int]] = {}

    def put(self, x: int, y: int, c) -> None:
        if 0 <= x < W and 0 <= y < H:
            self.px[(x, y)] = c

    def rect(self, x0: int, y0: int, x1: int, y1: int, c) -> None:
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.put(x, y, c)

    def outline(self) -> None:
        edges = []
        for (x, y) in list(self.px.keys()):
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < W and 0 <= ny < H and (nx, ny) not in self.px:
                    edges.append((nx, ny))
        for p in edges:
            self.px[p] = OUTLINE

    def image(self) -> Image.Image:
        img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        for (x, y), c in self.px.items():
            img.putpixel((x, y), c)
        return img


@dataclass
class Look:
    """Deskripsi visual satu karakter."""

    key: str
    skin: tuple[int, int, int] = (236, 186, 146)
    hair: tuple[int, int, int] = (52, 38, 32)
    shirt: tuple[int, int, int] = (70, 106, 160)
    pants: tuple[int, int, int] = (66, 62, 58)
    shoes: tuple[int, int, int] = (54, 44, 40)
    accent: tuple[int, int, int] = (222, 214, 196)
    style: str = "short"      # short|long|hijab|peci|caping|cap|ranger
    pattern: str = ""         # stripe|plaid|zip|badge|epaulet|trim
    beard: bool = False
    moustache: bool = False
    backpack: bool = False
    apron: bool = False
    vest: bool = False
    kid: bool = False
    elder: bool = False
    hat_color: tuple[int, int, int] = (198, 168, 104)
    pack_color: tuple[int, int, int] | None = None


# ------------------------------------------------------------- body drawing --
def draw_frame(look: Look, direction: str, frame: int) -> Canvas:
    """16x24, gaya top-down 3/4 seperti RPG klasik."""
    cv = Canvas()
    skin = tone(look.skin)
    skin_d = shade(skin, 0.83)
    skin_l = shade(skin, 1.06)
    hair = tone(look.hair)
    hair_d = shade(hair, 0.70)
    hair_l = shade(hair, 1.42)
    shirt = tone(look.shirt)
    shirt_d = shade(shirt, 0.74)
    shirt_l = shade(shirt, 1.18)
    pants = tone(look.pants)
    pants_d = shade(pants, 0.72)
    accent = tone(look.accent)
    shoes = tone(look.shoes)

    kid = look.kid
    foot = 22
    top = 6 if kid else 3
    hw = 3 if kid else 4                # setengah lebar kepala/tubuh
    bob = 1 if frame in (1, 3) else 0
    hy0 = top + bob
    hh = 5 if kid else 6
    hy1 = hy0 + hh
    neck = hy1 + 1
    by0 = neck + 1
    by1 = by0 + (5 if kid else 6)
    hip = by1 + 1
    cx = 8

    side = direction in ("left", "right")
    lean = -1 if direction == "left" else (1 if direction == "right" else 0)
    hx0, hx1 = cx - hw, cx + hw - 1
    bx0, bx1 = cx - hw, cx + hw - 1
    if side:
        hx0 += lean
        hx1 += lean
        bx0 += lean
        bx1 += lean

    # ---------------- kaki ----------------
    if side:
        front = 1 if frame == 1 else (-1 if frame == 3 else 0)
        lx = bx0 + 1
        rx = lx + 2
        if front >= 0:
            cv.rect(lx, hip, lx + 1, foot - 1, pants)
            cv.rect(lx - 1, foot, lx + 1, foot, shoes)
            cv.rect(rx, hip, rx + 1, foot - 2, pants_d)
            cv.rect(rx, foot - 1, rx + 2, foot, shoes)
        else:
            cv.rect(lx, hip, lx + 1, foot - 2, pants_d)
            cv.rect(lx - 1, foot - 1, lx + 1, foot, shoes)
            cv.rect(rx, hip, rx + 1, foot - 1, pants)
            cv.rect(rx, foot, rx + 2, foot, shoes)
    else:
        lx = cx - hw + 1
        rx = cx + hw - 3
        if frame == 1:
            cv.rect(lx, hip, lx + 2, foot - 1, pants)
            cv.rect(lx - 1, foot, lx + 2, foot, shoes)
            cv.rect(rx, hip, rx + 2, foot - 2, pants_d)
            cv.rect(rx, foot - 1, rx + 3, foot, shoes)
        elif frame == 3:
            cv.rect(lx, hip, lx + 2, foot - 2, pants_d)
            cv.rect(lx - 1, foot - 1, lx + 2, foot, shoes)
            cv.rect(rx, hip, rx + 2, foot - 1, pants)
            cv.rect(rx, foot, rx + 3, foot, shoes)
        else:
            cv.rect(lx, hip, lx + 2, foot - 1, pants)
            cv.rect(rx, hip, rx + 2, foot - 1, pants)
            cv.rect(lx, hip, lx, foot - 1, pants_d)
            cv.rect(rx + 2, hip, rx + 2, foot - 1, pants_d)
            cv.rect(lx - 1, foot, lx + 2, foot, shoes)
            cv.rect(rx, foot, rx + 3, foot, shoes)

    # ---------------- badan ----------------
    cv.rect(bx0, by0, bx1, by1, shirt)
    cv.rect(bx0, by0, bx0, by1, shirt_d)
    cv.rect(bx1, by0, bx1, by1, shirt_d)
    cv.rect(bx0 + 1, by0, bx1 - 1, by0, shirt_l)
    cv.rect(bx0, by1, bx1, by1, shade(pants, 0.92))

    if look.pattern == "stripe":
        for yy in range(by0 + 2, by1, 2):
            cv.rect(bx0 + 1, yy, bx1 - 1, yy, shade(accent, 0.95))
    elif look.pattern == "plaid":
        for xx in range(bx0 + 1, bx1, 2):
            cv.rect(xx, by0 + 1, xx, by1 - 1, shade(accent, 0.8))
        for yy in range(by0 + 2, by1, 2):
            cv.rect(bx0 + 1, yy, bx1 - 1, yy, shade(accent, 0.55))
    elif look.pattern == "zip":
        cv.rect(cx - 1, by0 + 1, cx - 1, by1 - 1, shade(accent, 0.85))
        cv.put(cx - 1, by0 + 1, accent)
        if direction == "down":
            cv.rect(bx0 + 1, by1 - 2, bx0 + 2, by1 - 1, accent)
            cv.rect(bx1 - 2, by1 - 2, bx1 - 1, by1 - 1, accent)

    if look.apron:
        cv.rect(bx0 + 2, by0 + 2, bx1 - 2, by1, accent)
        cv.rect(bx0 + 2, by0 + 2, bx0 + 2, by1, shade(accent, 0.84))
        cv.rect(bx0 + 2, by1 - 1, bx1 - 2, by1 - 1, shade(accent, 0.84))
        cv.rect(bx0 + 3, by0 + 3, bx1 - 3, by0 + 3, shade(accent, 0.9))

    if look.vest:
        cv.rect(bx0, by0 + 1, bx0 + 1, by1 - 1, accent)
        cv.rect(bx1 - 1, by0 + 1, bx1, by1 - 1, accent)

    if look.pattern == "badge":
        cv.put(bx0 + 2, by0 + 2, accent)
        cv.put(bx0 + 2, by0 + 3, shade(accent, 0.8))
        cv.rect(bx0 + 1, by0 + 4, bx1 - 1, by0 + 4, shade(accent, 0.75))
    elif look.pattern == "epaulet":
        cv.rect(bx0, by0, bx0 + 1, by0, accent)
        cv.rect(bx1 - 1, by0, bx1, by0, accent)
        cv.rect(bx0, by0 + 4, bx1, by0 + 4, shade(accent, 0.65))
        cv.put(cx, by0 + 4, shade(accent, 1.2))
    elif look.pattern == "trim" and direction == "down":
        cv.rect(bx0, by0, bx0, by1, shade(accent, 0.9))
        cv.rect(bx1, by0, bx1, by1, shade(accent, 0.9))
        cv.rect(bx0, by1, bx1, by1, accent)

    # ---------------- lengan ----------------
    if side:
        ax = bx0 - 1 if lean < 0 else bx1 + 1
        ay0 = by0 + 1
        ay1 = by1 - 1
        if frame == 1:
            cv.rect(ax, ay0 - 1, ax + 1, ay1 - 1, shirt_d)
            cv.rect(ax, ay1 - 1, ax + 1, ay1, skin_d)
        elif frame == 3:
            cv.rect(ax, ay0 + 1, ax + 1, ay1 + 1, shirt_d)
            cv.rect(ax, ay1 + 1, ax + 1, ay1 + 2, skin_d)
        else:
            cv.rect(ax, ay0, ax + 1, ay1, shirt_d)
            cv.rect(ax, ay1, ax + 1, ay1 + 1, skin_d)
        if look.vest:
            cv.rect(ax, ay0, ax + 1, ay0 + 2, accent)
    else:
        ay0 = by0 + 1
        ay1 = by1 - 1
        swing = 1 if frame == 1 else (-1 if frame == 3 else 0)
        one = 1 if swing > 0 else 0
        cv.rect(bx0 - 2, ay0 - one, bx0 - 1, ay1 - one, shirt_d)
        cv.rect(bx0 - 2, ay1 - one, bx0 - 1, ay1 - one + 1, skin_d)
        two = 1 if swing < 0 else 0
        cv.rect(bx1 + 1, ay0 - two, bx1 + 2, ay1 - two, shirt_d)
        cv.rect(bx1 + 1, ay1 - two, bx1 + 2, ay1 - two + 1, skin_d)

    # ---------------- leher & kepala ----------------
    cv.rect(cx - 1, hy1 + 1, cx, hy1 + 1, skin_d)
    cv.rect(hx0, hy0, hx1, hy1, skin)
    cv.rect(hx1, hy0 + 1, hx1, hy1, skin_d)
    cv.rect(hx0, hy0, hx1 - 1, hy0, skin_l)
    cv.rect(hx0 + 1, hy1, hx1 - 1, hy1, skin_d)

    # ---------------- rambut / penutup kepala ----------------
    if look.style == "hijab":
        hc = tint(hair, (255, 255, 255), 0.10)
        cv.rect(hx0 - 1, hy0 - 1, hx1 + 1, hy0 + 2, hc)
        cv.rect(hx0 - 1, hy0 - 1, hx0 - 1, hy1 + 2, hc)
        cv.rect(hx1 + 1, hy0 - 1, hx1 + 1, hy1 + 2, hc)
        cv.rect(hx0 - 1, hy1 + 2, hx1 + 1, hy1 + 3, shade(hc, 0.84))
        cv.rect(hx0, hy0 - 1, hx1, hy0 - 1, shade(hc, 1.14))
        if direction == "up":
            cv.rect(hx0 - 1, hy0 - 1, hx1 + 1, hy1 + 2, hc)
            cv.rect(hx0, hy0 - 1, hx1, hy0 - 1, shade(hc, 1.14))
        else:
            # buka area wajah: kulit digambar ulang di atas kain
            if direction == "down":
                cv.rect(hx0, hy0 + 2, hx1, hy1, skin)
                cv.rect(hx0, hy0 + 2, hx1, hy0 + 2, skin_l)
                cv.rect(hx0 + 1, hy1, hx1 - 1, hy1, skin_d)
                cv.rect(hx0, hy0 + 2, hx0, hy1, skin_d)
                cv.rect(hx1, hy0 + 2, hx1, hy1, shade(skin, 0.78))
                cv.put(cx, hy1 - 1, tone(look.accent))
            else:
                fx0 = hx0 if direction == "left" else hx0 + 2
                fx1 = hx1 - 2 if direction == "left" else hx1
                cv.rect(fx0, hy0 + 2, fx1, hy1, skin)
                cv.rect(fx0, hy0 + 2, fx1, hy0 + 2, skin_l)
                cv.rect(fx0, hy1, fx1, hy1, skin_d)
                if direction == "left":
                    cv.rect(fx0, hy0 + 2, fx0, hy1, skin_d)
                else:
                    cv.rect(fx1, hy0 + 2, fx1, hy1, shade(skin, 0.78))

    elif look.style == "peci":
        cv.rect(hx0 - 1, hy0 - 2, hx1 + 1, hy0 - 1, hair)
        cv.rect(hx0 - 1, hy0 - 2, hx1 + 1, hy0 - 2, shade(hair, 1.5))
        cv.rect(hx0, hy0, hx1, hy0, shade(hair, 0.65))
        cv.rect(hx0, hy0 - 1, hx1, hy0 - 1, shade(hair, 1.15))

    elif look.style == "caping":
        hat = tone(look.hat_color)
        cv.rect(hx0 - 2, hy0, hx1 + 2, hy0, hat)
        cv.rect(hx0 - 2, hy0 + 1, hx1 + 2, hy0 + 1, shade(hat, 0.55))
        cv.rect(hx0 - 1, hy0 - 1, hx1 + 1, hy0 - 1, shade(hat, 1.12))
        cv.rect(hx0, hy0 - 2, hx1, hy0 - 2, hat)
        cv.rect(hx0 + 1, hy0 - 3, hx1 - 1, hy0 - 3, shade(hat, 0.92))
        cv.rect(hx0 - 1, hy0, hx1 + 1, hy0, shade(hat, 0.85))

    elif look.style == "cap":
        cap = tone(look.accent)
        cv.rect(hx0 - 1, hy0 - 2, hx1 + 1, hy0 - 2, shade(cap, 1.15))
        cv.rect(hx0 - 1, hy0 - 1, hx1 + 1, hy0 - 1, cap)
        if direction == "down":
            cv.rect(hx0 - 1, hy0, hx1 + 1, hy0, shade(cap, 0.72))
            cv.put(cx, hy0 - 1, shade(cap, 0.6))
        elif direction == "left":
            cv.rect(hx0 - 2, hy0, hx0 - 1, hy0, shade(cap, 0.8))
        elif direction == "right":
            cv.rect(hx1 + 1, hy0, hx1 + 2, hy0, shade(cap, 0.8))
        else:
            cv.rect(hx0 - 1, hy0, hx1 + 1, hy0, shade(cap, 0.86))

    elif look.style == "ranger":
        hat = tone(look.hat_color)
        cv.rect(hx0 - 2, hy0, hx1 + 2, hy0, hat)
        cv.rect(hx0 - 2, hy0 + 1, hx1 + 2, hy0 + 1, shade(hat, 0.52))
        cv.rect(hx0, hy0 - 2, hx1, hy0 - 1, shade(hat, 1.08))
        cv.rect(hx0, hy0 - 3, hx1, hy0 - 3, shade(hat, 0.96))
        cv.rect(hx0, hy0 - 1, hx1, hy0 - 1, shade(hat, 0.5))
        cv.rect(hx0 - 1, hy0, hx1 + 1, hy0, shade(hat, 0.9))

    elif look.style == "long":
        cv.rect(hx0 - 1, hy0 - 1, hx1 + 1, hy0 + 2, hair)
        cv.rect(hx0 - 1, hy0, hx0 - 1, hy1 + 2, hair)
        cv.rect(hx1 + 1, hy0, hx1 + 1, hy1 + 2, hair)
        cv.rect(hx0, hy0 - 1, hx1, hy0 - 1, hair_l)
        cv.rect(hx0 - 1, hy1 + 1, hx1 + 1, hy1 + 2, hair_d)
        if direction == "up":
            cv.rect(hx0 - 1, hy0 - 1, hx1 + 1, hy1 + 2, hair)
            cv.rect(hx0, hy0 - 1, hx1, hy0, hair_l)

    else:  # short
        cv.rect(hx0 - 1, hy0 - 1, hx1 + 1, hy0 + 1, hair)
        cv.rect(hx0 - 1, hy0, hx0 - 1, hy0 + 3, hair)
        cv.rect(hx1 + 1, hy0, hx1 + 1, hy0 + 3, hair)
        cv.rect(hx0, hy0 - 1, hx1, hy0 - 1, hair_l)
        if direction == "up":
            cv.rect(hx0 - 1, hy0 - 1, hx1 + 1, hy1, hair)
            cv.rect(hx0, hy0 - 1, hx1, hy0, hair_l)
            cv.rect(hx0, hy1, hx1, hy1, hair_d)
        elif direction != "down":
            cv.rect(hx0 - 1, hy0 - 1, hx1 + 1, hy0 + 3, hair)
            cv.rect(hx0, hy0 - 1, hx1, hy0, hair_l)
        if look.elder:
            cv.put(hx0 - 1, hy0, (222, 222, 218, 255))
            cv.put(hx1 + 1, hy0, (222, 222, 218, 255))

    # ---------------- wajah ----------------
    if direction == "down":
        ey = hy0 + 3
        cv.put(hx0 + 2, ey, OUTLINE)
        cv.put(hx1 - 2, ey, OUTLINE)
        cv.put(hx0 + 2, ey - 1, skin_l)
        cv.put(hx1 - 2, ey - 1, skin_l)
        if look.elder:
            cv.rect(hx0 + 1, ey - 1, hx0 + 3, ey - 1, hair_d)
            cv.rect(hx1 - 3, ey - 1, hx1 - 1, ey - 1, hair_d)
        if look.moustache or look.beard:
            cv.rect(hx0 + 2, ey + 1, hx1 - 2, ey + 1, hair_d)
        if look.beard:
            cv.rect(hx0 + 2, ey + 2, hx1 - 2, hy1, hair_d)
            cv.rect(hx0 + 3, ey + 2, hx1 - 3, ey + 2, hair)
        else:
            cv.put(cx - 1, ey + 2, shade(skin, 0.62))
            cv.put(cx, ey + 2, shade(skin, 0.62))
        if kid:
            cv.put(hx0 + 1, ey + 1, (232, 150, 138, 255))
            cv.put(hx1 - 1, ey + 1, (232, 150, 138, 255))
    elif direction in ("left", "right"):
        ex = hx0 + 1 if direction == "left" else hx1 - 1
        ey = hy0 + 3
        cv.put(ex, ey, OUTLINE)
        cv.put(ex + (-1 if direction == "left" else 1), ey + 1, skin_d)
        if look.beard:
            cv.rect(hx0 + 1, ey + 1, hx1 - 1, hy1, hair_d)
        if look.moustache or look.beard:
            cv.rect(hx0 + 1, ey + 1, hx1 - 1, ey + 1, hair_d)
        elif not kid:
            cv.put(ex, ey + 2, shade(skin, 0.7))

    # ---------------- tas punggung ----------------
    if look.backpack:
        pack = tone(look.pack_color) if look.pack_color else shade(accent, 0.55)
        if direction == "up":
            cv.rect(bx0, by0, bx1, by1 - 1, pack)
            cv.rect(bx0, by0, bx1, by0, shade(pack, 1.2))
            cv.rect(bx0, by1 - 1, bx1, by1 - 1, shade(pack, 0.75))
            cv.rect(bx0 + 1, by0 + 2, bx1 - 1, by1 - 2, shade(pack, 0.86))
            cv.rect(bx0 + 2, by0 + 2, bx1 - 2, by0 + 2, shade(pack, 1.1))
        elif direction == "down":
            cv.rect(bx0, by0 + 1, bx0, by1 - 1, shade(pack, 0.9))
            cv.rect(bx1, by0 + 1, bx1, by1 - 1, shade(pack, 0.9))
        else:
            px0 = bx1 if lean < 0 else bx0 - 1
            cv.rect(px0, by0 + 1, px0 + 1, by1 - 1, pack)
            cv.rect(px0, by0 + 1, px0 + 1, by0 + 1, shade(pack, 1.2))
            cv.rect(px0, by1 - 1, px0 + 1, by1 - 1, shade(pack, 0.75))

    cv.outline()
    return cv


# ------------------------------------------------------------------- output --
def build_sheet(look: Look) -> Image.Image:
    sheet = Image.new("RGBA", (W * 4, H * 4), (0, 0, 0, 0))
    for row, direction in enumerate(("down", "left", "right", "up")):
        for col in range(4):
            frame = draw_frame(look, direction, col)
            sheet.alpha_composite(frame.image(), (col * W, row * H))
    return sheet


CHARACTERS: list[Look] = [
    # Raka — pemuda perantau: jaket biru berzip, celana gelap, tas punggung.
    Look(
        "player",
        skin=(235, 186, 146),
        hair=(48, 36, 32),
        shirt=(58, 100, 168),
        pants=(52, 56, 70),
        shoes=(238, 238, 234),
        accent=(206, 88, 68),
        style="short",
        pattern="zip",
        backpack=True,
        pack_color=(72, 78, 96),
    ),
    # Pak Warung — peci hitam, kemeja krem, celemek coklat, kumis.
    Look(
        "pedagang",
        skin=(212, 156, 114),
        hair=(40, 32, 28),
        shirt=(240, 228, 202),
        pants=(104, 82, 62),
        shoes=(62, 48, 40),
        accent=(150, 100, 62),
        style="peci",
        moustache=True,
        apron=True,
    ),
    # Ibu — hijab mauve, gamis hijau tua dengan aksen krem.
    Look(
        "ibu",
        skin=(228, 176, 140),
        hair=(170, 96, 120),
        shirt=(70, 112, 100),
        pants=(60, 96, 86),
        shoes=(80, 58, 52),
        accent=(232, 206, 172),
        style="hijab",
        pattern="trim",
    ),
    # Budi — anak sekolah: kaos putih bergaris, celana biru, topi merah.
    Look(
        "budi",
        skin=(240, 196, 156),
        hair=(44, 34, 30),
        shirt=(242, 242, 236),
        pants=(58, 100, 164),
        shoes=(224, 82, 70),
        accent=(64, 122, 190),
        style="cap",
        pattern="stripe",
        kid=True,
        backpack=True,
        pack_color=(226, 186, 84),
    ),
    # Pak RT — seragam hijau, peci, kumis, tanda pengenal.
    Look(
        "pakrt",
        skin=(220, 166, 124),
        hair=(38, 32, 28),
        shirt=(92, 132, 86),
        pants=(70, 92, 68),
        shoes=(52, 44, 38),
        accent=(228, 222, 198),
        style="peci",
        pattern="badge",
        moustache=True,
        elder=True,
    ),
    # Penjaga Hutan — topi rimba lebar, kemeja olive, janggut, sepatu bot.
    Look(
        "penjaga_hutan",
        skin=(206, 152, 112),
        hair=(58, 44, 34),
        shirt=(86, 110, 62),
        pants=(82, 72, 52),
        shoes=(70, 54, 40),
        accent=(198, 172, 112),
        style="ranger",
        pattern="epaulet",
        beard=True,
        hat_color=(146, 128, 84),
    ),
    # Petani — caping, kemeja kotak-kotak, lengan digulung.
    Look(
        "petani",
        skin=(198, 142, 100),
        hair=(60, 46, 34),
        shirt=(196, 172, 100),
        pants=(104, 84, 58),
        shoes=(92, 70, 48),
        accent=(112, 146, 88),
        style="caping",
        pattern="plaid",
        moustache=True,
        hat_color=(216, 188, 112),
    ),
    # Nelayan — caping lebar, kemeja biru bergaris, janggut, kaki telanjang.
    Look(
        "nelayan",
        skin=(176, 122, 88),
        hair=(76, 62, 52),
        shirt=(70, 110, 138),
        pants=(92, 82, 66),
        shoes=(116, 92, 70),
        accent=(196, 172, 126),
        style="caping",
        pattern="stripe",
        beard=True,
        hat_color=(160, 138, 96),
    ),
]


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    for look in CHARACTERS:
        sheet = build_sheet(look)
        path = os.path.join(OUT_DIR, f"{look.key}.png")
        sheet.save(path)
        print("  saved", os.path.relpath(path, ROOT), sheet.size)

    shadow = Image.new("RGBA", (16, 8), (0, 0, 0, 0))
    d = ImageDraw.Draw(shadow)
    d.ellipse((1, 1, 14, 6), fill=(26, 22, 24, 74))
    shadow.save(os.path.join(OUT_DIR, "shadow.png"))
    print("  saved shadow.png")


if __name__ == "__main__":
    main()
