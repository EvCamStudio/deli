"""Potret dialog untuk Deli Rewind.

Digambar di kanvas 60x85 lalu di-upscale 2x NEAREST menjadi 120x170, jadi
kerapatan pikselnya sama dengan sprite dunia (16x24 @ zoom 2x) dan gaya
pikselnya konsisten.

Palet tiap tokoh disamakan dengan sprite top-down CC0 di
assets/sprites/characters/ (lihat tools/opensource/CREDITS.md).

Output: assets/sprites/portraits/<key>_<ekspresi>.png  (120x170)
Ekspresi: neutral, happy, sad, surprised.

Jalankan: python tools/generate_portraits.py
"""

from __future__ import annotations

import os
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "assets")

W, H = 60, 85
SCALE = 2

OUT = (48, 34, 26, 255)
CLEAR = (0, 0, 0, 0)

WHITE = (252, 248, 238, 255)
IRIS = (92, 68, 50, 255)
PUPIL = (26, 20, 18, 255)
MOUTH_DARK = (134, 58, 54, 255)
MOUTH_INNER = (98, 38, 38, 255)
TEETH = (246, 238, 222, 255)

# Kontur kepala (simetris terhadap x=30), dagu di y=52.
HEAD = [
    (30, 5), (38, 6), (44, 10), (47, 17), (48, 26),
    (47, 34), (44, 41), (39, 47), (34, 51), (30, 52),
    (26, 51), (21, 47), (16, 41), (13, 34),
    (12, 26), (13, 17), (16, 10), (22, 6),
]

EYE_L, EYE_R = 24, 36
EYE_TOP = 24


# ------------------------------------------------------------------ helpers --
def shade(c, f: float):
    return (
        max(0, min(255, int(c[0] * f))),
        max(0, min(255, int(c[1] * f))),
        max(0, min(255, int(c[2] * f))),
        255,
    )


def lighten(c, amount: float):
    return tuple(int(c[i] + (255 - c[i]) * amount) for i in range(3)) + (255,)


def save(img: Image.Image, *parts: str) -> None:
    path = os.path.join(ASSETS, *parts)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)


# --------------------------------------------------------------- latar belakang --
def draw_backdrop(d: ImageDraw.ImageDraw, accent) -> None:
    # Tanpa diskus: panel dialog sudah bertekstur kertas, dan cincin warna
    # aksen terbaca sebagai oval kelabu di belakang kepala.
    return


# --------------------------------------------------------------------- rambut --
def draw_hair_back(d: ImageDraw.ImageDraw, hair, style: str) -> None:
    if style == "long":
        d.ellipse((10, -2, 50, 44), fill=hair)
        d.rounded_rectangle((8, 16, 16, 58), radius=3, fill=hair)
        d.rounded_rectangle((44, 16, 52, 58), radius=3, fill=hair)
        d.rectangle((8, 16, 16, 50), fill=hair)
        d.rectangle((44, 16, 52, 50), fill=hair)


def draw_hair_front(d: ImageDraw.ImageDraw, hair, style: str, key: str) -> None:
    hi = lighten(hair, 0.26)
    lo = shade(hair, 0.76)

    if style == "long":
        d.rounded_rectangle((16, 2, 44, 17), radius=5, fill=hair)
        d.polygon([(16, 12), (21, 20), (25, 13), (30, 21), (35, 13), (39, 20), (44, 12),
                   (44, 8), (16, 8)], fill=hair)
        d.rectangle((14, 8, 19, 26), fill=hair)
        d.rectangle((41, 8, 46, 26), fill=hair)
        d.line((19, 8, 24, 7), fill=hi)
        d.line((19, 9, 23, 8), fill=hi)
        d.line((36, 8, 41, 9), fill=lo)
        return

    if style == "caping":
        d.rounded_rectangle((16, 6, 44, 16), radius=4, fill=hair)
        d.polygon([(16, 12), (22, 17), (26, 12), (31, 18), (36, 12), (44, 16),
                   (44, 9), (16, 9)], fill=hair)
        d.line((20, 8, 26, 7), fill=hi)
        return

    if style == "kid":
        # potongan mangkuk bocah: rata depan, menutup dahi
        d.rounded_rectangle((14, 3, 46, 20), radius=7, fill=hair)
        d.polygon([(14, 15), (20, 22), (26, 15), (31, 23), (37, 15), (46, 20),
                   (46, 8), (14, 8)], fill=hair)
        d.polygon([(13, 12), (17, 11), (17, 26), (13, 27)], fill=hair)
        d.polygon([(47, 12), (43, 11), (43, 26), (47, 27)], fill=hair)
        d.line((19, 7, 27, 6), fill=hi)
        d.line((19, 8, 25, 7), fill=hi)
        d.line((34, 7, 42, 10), fill=lo)
        return

    # rambut pendek
    d.rounded_rectangle((15, 3, 45, 18), radius=5, fill=hair)
    if key in ("pedagang", "pakrt", "budi"):
        # belahan samping: poni turun miring ke kanan
        d.polygon([(16, 12), (23, 19), (28, 14), (33, 19), (38, 15), (45, 17),
                   (45, 7), (16, 8)], fill=hair)
    else:
        d.polygon([(16, 13), (20, 18), (24, 13), (30, 19), (35, 13), (39, 18), (45, 13),
                   (45, 7), (16, 7)], fill=hair)
    # pelipis mengikuti lengkung kepala (mulai di bawah garis topi)
    d.polygon([(15, 13), (19, 12), (19, 23), (16, 25)], fill=hair)
    d.polygon([(45, 13), (41, 12), (41, 23), (44, 25)], fill=hair)
    # garis rambut lebih gelap supaya tidak terlihat seperti topi
    d.line((19, 17, 26, 16), fill=lo)
    d.line((34, 16, 41, 18), fill=lo)
    # kilau rambut
    d.line((20, 6, 27, 5), fill=hi)
    d.line((20, 7, 25, 6), fill=hi)
    d.line((33, 7, 40, 9), fill=lo)


def draw_neck(d: ImageDraw.ImageDraw, skin) -> None:
    d.rectangle((26, 42, 34, 61), fill=shade(skin, 0.97))
    # bayangan dagu di leher
    d.rectangle((26, 42, 34, 49), fill=shade(skin, 0.80))


def draw_ears(d: ImageDraw.ImageDraw, skin) -> None:
    for x0 in (9, 47):
        d.rectangle((x0, 24, x0 + 4, 31), fill=skin, outline=shade(skin, 0.55), width=1)
        d.rectangle((x0 + 1, 26, x0 + 3, 29), fill=shade(skin, 0.84))


def draw_face(d: ImageDraw.ImageDraw, skin) -> None:
    dark = shade(skin, 0.80)
    d.polygon(HEAD, fill=skin)
    # pipi terang
    d.ellipse((18, 20, 28, 38), fill=lighten(skin, 0.11))
    d.ellipse((32, 20, 42, 38), fill=lighten(skin, 0.11))
    # rahang sedikit lebih gelap (tipis saja, jangan sampai seperti brewok)
    d.polygon([(17, 33), (21, 42), (26, 47), (30, 49), (34, 47), (39, 42), (43, 33),
               (40, 41), (34, 47), (30, 49), (26, 47), (20, 41)], fill=shade(skin, 0.95))
    # sisi kiri kena bayangan
    d.polygon([(13, 19), (14, 31), (19, 40), (25, 47), (23, 39), (18, 30), (15, 22)],
              fill=shade(skin, 0.97))
    # dagu terang
    d.ellipse((26, 42, 34, 50), fill=lighten(skin, 0.06))
    d.line(HEAD + [HEAD[0]], fill=dark, width=1, joint="curve")


def draw_face_features(d: ImageDraw.ImageDraw, expression: str, skin,
                       moustache: bool, beard: bool, hair, glasses: bool) -> None:
    draw_eyes(d, expression, glasses)
    draw_brows(d, expression)
    draw_nose(d, skin)
    draw_blush(d)
    if beard:
        draw_beard(d, hair)
    if moustache:
        draw_moustache(d, hair)
    draw_mouth(d, expression, skin)


def draw_eyes(d: ImageDraw.ImageDraw, expression: str, glasses: bool) -> None:
    for cx in (EYE_L, EYE_R):
        if expression == "happy":
            # mata terbuka lebar dengan kilau besar
            d.rectangle((cx - 3, EYE_TOP - 1, cx + 3, EYE_TOP + 5), fill=WHITE)
            d.rectangle((cx - 2, EYE_TOP, cx + 2, EYE_TOP + 5), fill=IRIS)
            d.rectangle((cx - 1, EYE_TOP + 1, cx + 1, EYE_TOP + 4), fill=PUPIL)
            d.point((cx - 2, EYE_TOP), fill=WHITE)
            d.point((cx + 1, EYE_TOP + 4), fill=IRIS)
            continue
        if expression == "sad":
            d.rectangle((cx - 3, EYE_TOP + 1, cx + 3, EYE_TOP + 5), fill=WHITE)
            d.rectangle((cx - 2, EYE_TOP + 2, cx + 2, EYE_TOP + 5), fill=IRIS)
            d.rectangle((cx - 1, EYE_TOP + 3, cx + 1, EYE_TOP + 5), fill=PUPIL)
            d.line((cx - 3, EYE_TOP + 1, cx + 3, EYE_TOP + 1), fill=shade(OUT, 1.1), width=1)
            continue
        if expression == "surprised":
            d.rectangle((cx - 3, EYE_TOP - 1, cx + 3, EYE_TOP + 6), fill=WHITE)
            d.rectangle((cx - 2, EYE_TOP, cx + 2, EYE_TOP + 6), fill=IRIS)
            d.rectangle((cx - 1, EYE_TOP + 1, cx + 1, EYE_TOP + 5), fill=PUPIL)
            d.point((cx - 2, EYE_TOP + 1), fill=WHITE)
            continue
        # neutral
        d.rectangle((cx - 3, EYE_TOP, cx + 3, EYE_TOP + 5), fill=WHITE)
        d.rectangle((cx - 2, EYE_TOP + 1, cx + 2, EYE_TOP + 5), fill=IRIS)
        d.rectangle((cx - 1, EYE_TOP + 2, cx + 1, EYE_TOP + 5), fill=PUPIL)
        d.point((cx - 2, EYE_TOP + 1), fill=WHITE)
        d.line((cx - 3, EYE_TOP, cx + 3, EYE_TOP), fill=shade(OUT, 1.1), width=1)

    if glasses:
        frame = (66, 54, 46, 240)
        d.rectangle((18, 21, 30, 31), outline=frame, width=1)
        d.rectangle((30, 21, 42, 31), outline=frame, width=1)
        d.line((18, 25, 14, 23), fill=frame, width=1)
        d.line((42, 25, 46, 23), fill=frame, width=1)
        d.line((20, 22, 26, 22), fill=(255, 255, 255, 74))
        d.line((32, 22, 38, 22), fill=(255, 255, 255, 74))


def draw_brows(d: ImageDraw.ImageDraw, expression: str) -> None:
    if expression == "surprised":
        d.line((19, 17, 27, 16), fill=OUT, width=1)
        d.line((33, 16, 41, 17), fill=OUT, width=1)
    elif expression == "sad":
        d.line((19, 19, 27, 16), fill=OUT, width=1)
        d.line((33, 16, 41, 19), fill=OUT, width=1)
    elif expression == "happy":
        d.line((19, 17, 26, 17), fill=OUT, width=1)
        d.line((34, 17, 41, 17), fill=OUT, width=1)
    else:
        d.line((19, 18, 27, 17), fill=OUT, width=1)
        d.line((33, 17, 41, 18), fill=OUT, width=1)


def draw_nose(d: ImageDraw.ImageDraw, skin) -> None:
    d.rectangle((29, 30, 31, 35), fill=shade(skin, 0.93))
    d.rectangle((28, 35, 32, 36), fill=shade(skin, 0.80))
    d.point((29, 31), fill=lighten(skin, 0.24))


def draw_beard(d: ImageDraw.ImageDraw, hair) -> None:
    d.polygon([(15, 33), (17, 41), (23, 48), (30, 51), (37, 48), (43, 41), (45, 33),
               (39, 41), (30, 46), (21, 41)], fill=hair)
    d.polygon([(21, 41), (30, 45), (39, 41), (34, 47), (30, 49), (26, 47)],
              fill=lighten(hair, 0.18))


def draw_moustache(d: ImageDraw.ImageDraw, hair) -> None:
    d.polygon([(22, 37), (26, 39), (30, 38), (34, 39), (38, 37),
               (37, 41), (30, 42), (23, 41)], fill=hair)
    d.line((24, 37, 27, 38), fill=lighten(hair, 0.22))


def draw_mouth(d: ImageDraw.ImageDraw, expression: str, skin) -> None:
    if expression == "happy":
        d.polygon([(25, 40), (35, 40), (33, 45), (30, 47), (27, 45)],
                  fill=MOUTH_INNER, outline=MOUTH_DARK)
        d.line((27, 41, 33, 41), fill=TEETH)
        d.line((24, 39, 26, 40), fill=shade(skin, 0.84))
        d.line((36, 39, 34, 40), fill=shade(skin, 0.84))
    elif expression == "sad":
        d.line((26, 43, 30, 41), fill=MOUTH_DARK, width=1)
        d.line((30, 41, 34, 43), fill=MOUTH_DARK, width=1)
        d.point((25, 42), fill=MOUTH_DARK)
        d.point((35, 42), fill=MOUTH_DARK)
    elif expression == "surprised":
        d.rectangle((28, 40, 32, 45), fill=MOUTH_INNER, outline=MOUTH_DARK)
    else:
        d.line((26, 41, 30, 42), fill=MOUTH_DARK, width=1)
        d.line((30, 42, 34, 41), fill=MOUTH_DARK, width=1)


def draw_blush(d: ImageDraw.ImageDraw) -> None:
    blush = (226, 138, 126, 148)
    d.ellipse((16, 31, 23, 36), fill=blush)
    d.ellipse((37, 31, 44, 36), fill=blush)


# ---------------------------------------------------------------------- badan --
def draw_torso(d: ImageDraw.ImageDraw, shirt, accent, key: str) -> None:
    dark = shade(shirt, 0.74)
    light = lighten(shirt, 0.26)

    d.rounded_rectangle((-4, 60, 64, 92), radius=12, fill=shirt)
    d.polygon([(-3, 74), (-3, 92), (12, 92), (9, 63)], fill=dark)
    d.polygon([(63, 74), (63, 92), (48, 92), (51, 63)], fill=dark)

    if key != "ibu":
        # sorot dada hanya untuk baju berkrah; kerudung tidak punya krah
        d.rounded_rectangle((20, 61, 40, 74), radius=5, fill=light)

    if key == "pedagang":
        # celemek warung
        d.polygon([(20, 71), (40, 71), (43, 92), (17, 92)],
                  fill=(234, 214, 172, 255), outline=shade(shirt, 0.5), width=1)
        d.line((23, 78, 37, 78), fill=(178, 134, 84, 255), width=1)
        d.line((23, 84, 37, 84), fill=(178, 134, 84, 255), width=1)
    elif key == "pakrt":
        # kemeja batik
        for y in range(70, 92, 4):
            for x in range(4, 58, 4):
                d.point((x, y), fill=accent)
                d.point((x + 1, y + 1), fill=shade(accent, 0.76))
        d.line((30, 60, 30, 92), fill=dark, width=1)
    elif key == "budi":
        d.rectangle((34, 70, 40, 76), fill=shade(shirt, 0.88), outline=shade(shirt, 0.6), width=1)
        d.rectangle((26, 60, 34, 63), fill=accent)
    elif key == "penjaga_hutan":
        d.polygon([(13, 61), (20, 61), (18, 92), (10, 92)], fill=shade(shirt, 0.62))
        d.polygon([(47, 61), (40, 61), (42, 92), (50, 92)], fill=shade(shirt, 0.62))
        d.line((15, 66, 16, 90), fill=shade(shirt, 0.46))
        d.line((45, 66, 44, 90), fill=shade(shirt, 0.46))
    elif key == "nelayan":
        d.polygon([(18, 60), (30, 66), (42, 60), (42, 64), (30, 70), (18, 64)],
                  fill=(240, 240, 234, 255), outline=shade(shirt, 0.45), width=1)

    # kerah baju
    d.polygon([(24, 60), (30, 66), (36, 60)], fill=shade(shirt, 0.62))
    # bayangan leher di kerah
    d.polygon([(26, 58), (34, 58), (32, 63), (28, 63)], fill=shade((236, 194, 158, 255), 0.86))


def draw_hijab_drape(d: ImageDraw.ImageDraw, hair) -> None:
    """Kain kerudung: hood di belakang kepala + drape di bahu (digambar
    sebelum wajah, jadi bukaan wajah otomatis tertutup kontur kepala)."""
    hood = shade(hair, 0.97)
    d.rounded_rectangle((5, -8, 55, 44), radius=18, fill=hood)
    # drape bahu padat: menutup seluruh area leher supaya diskus latar tidak bocor
    d.polygon([(5, 30), (8, 44), (6, 66), (54, 66), (52, 44), (55, 30)], fill=hood)
    # lipatan kain
    d.polygon([(8, 10), (14, 4), (15, 46), (9, 40)], fill=shade(hair, 0.80))
    d.polygon([(52, 10), (46, 4), (45, 46), (51, 40)], fill=shade(hair, 0.80))
    d.polygon([(14, 50), (21, 62), (14, 62)], fill=shade(hair, 0.84))
    d.polygon([(46, 50), (39, 62), (46, 62)], fill=shade(hair, 0.84))
    d.arc((9, -2, 39, 30), 200, 310, fill=lighten(hair, 0.26), width=1)
    d.line((11, 36, 13, 50), fill=shade(hair, 0.78))
    d.line((49, 36, 47, 50), fill=shade(hair, 0.78))


# --------------------------------------------------------------------- topi ---
def draw_cap(d: ImageDraw.ImageDraw) -> None:
    cap = (78, 88, 132, 255)
    d.ellipse((14, -6, 46, 18), fill=cap)
    d.ellipse((16, -4, 44, 14), fill=lighten(cap, 0.12))
    d.rectangle((14, 9, 46, 16), fill=shade(cap, 0.82))
    d.ellipse((20, -2, 31, 6), fill=lighten(cap, 0.34))
    d.ellipse((31, -5, 35, -1), fill=shade(cap, 0.94))
    # brim menjorok ke kiri, pendek
    d.rounded_rectangle((7, 14, 30, 20), radius=3, fill=shade(cap, 0.70))
    d.line((9, 16, 27, 16), fill=shade(cap, 0.95))
    d.line((7, 20, 30, 20), fill=shade(cap, 0.52))
    # jahitan panel
    d.line((16, 2, 34, 0), fill=shade(cap, 0.88))


def draw_caping(d: ImageDraw.ImageDraw) -> None:
    straw = (214, 186, 112, 255)
    straw_hi = lighten(straw, 0.20)
    straw_dark = (168, 138, 72, 255)
    # kerucut
    d.polygon([(22, -18), (38, -18), (41, 6), (19, 6)], fill=straw)
    d.polygon([(22, -18), (29, -18), (30, 6), (20, 6)], fill=straw_hi)
    d.line((38, -16, 41, 6), fill=straw_dark)
    # lingkaran lebar
    d.ellipse((1, 2, 59, 18), fill=straw)
    d.point((30, 2), fill=straw_hi)
    d.arc((3, 4, 57, 17), 195, 345, fill=straw_dark)
    for x in range(5, 56, 5):
        d.line((x, 5, x + 1, 15), fill=straw_dark)
    for x in range(24, 38, 4):
        d.line((x, -10, x + 1, 4), fill=straw_dark)
    d.line((19, -2, 41, -2), fill=straw_dark)
    d.line((3, 16, 57, 16), fill=shade(straw_dark, 0.92))


def draw_band(d: ImageDraw.ImageDraw, accent) -> None:
    d.rectangle((12, 13, 48, 19), fill=accent)
    d.rectangle((12, 13, 48, 15), fill=lighten(accent, 0.30))
    d.rectangle((12, 18, 48, 19), fill=shade(accent, 0.80))
    d.polygon([(48, 15), (54, 19), (53, 24), (46, 21)], fill=shade(accent, 0.88))
    d.line((46, 20, 52, 22), fill=shade(accent, 0.70))


# -------------------------------------------------------------------- potret --
def portrait(key: str, expression: str, skin, hair, shirt, style: str, accent=None,
             moustache: bool = False, beard: bool = False, glasses: bool = False) -> Image.Image:
    accent = accent or (53, 92, 74, 255)
    img = Image.new("RGBA", (W, H), CLEAR)
    d = ImageDraw.Draw(img, "RGBA")

    draw_backdrop(d, accent)

    if style == "hijab":
        draw_hijab_drape(d, hair)
    elif style == "long":
        draw_hair_back(d, hair, style)

    draw_neck(d, skin)
    draw_torso(d, shirt, accent, key)

    draw_face(d, skin)
    if style != "hijab":
        draw_ears(d, skin)
        draw_hair_front(d, hair, style, key)

    draw_face_features(d, expression, skin, moustache, beard, hair, glasses)

    if style == "cap":
        draw_cap(d)
    elif style == "caping":
        draw_caping(d)
    elif style == "band":
        draw_band(d, accent)

    return img.resize((W * SCALE, H * SCALE), Image.Resampling.NEAREST)


PEOPLE = {
    "player": dict(skin=(255, 201, 153, 255), hair=(184, 108, 72, 255), shirt=(72, 69, 70, 255), style="cap", accent=(206, 88, 68, 255)),
    "pedagang": dict(skin=(241, 176, 137, 255), hair=(112, 78, 68, 255), shirt=(72, 69, 70, 255), style="short", accent=(150, 100, 62, 255), moustache=True, glasses=True),
    "ibu": dict(skin=(184, 130, 95, 255), hair=(118, 56, 146, 255), shirt=(133, 62, 192, 255), style="hijab", accent=(232, 206, 172, 255)),
    "budi": dict(skin=(255, 182, 141, 255), hair=(50, 50, 52, 255), shirt=(126, 133, 138, 255), style="kid", accent=(211, 60, 61, 255)),
    "pakrt": dict(skin=(255, 201, 153, 255), hair=(104, 110, 130, 255), shirt=(126, 133, 138, 255), style="short", accent=(228, 222, 198, 255), moustache=True, glasses=True),
    "penjaga_hutan": dict(skin=(141, 82, 67, 255), hair=(220, 134, 82, 255), shirt=(26, 172, 109, 255), style="short", accent=(198, 172, 112, 255), moustache=True),
    "petani": dict(skin=(180, 115, 74, 255), hair=(135, 77, 39, 255), shirt=(111, 137, 184, 255), style="caping", accent=(112, 146, 88, 255), moustache=True),
    "nelayan": dict(skin=(180, 115, 74, 255), hair=(55, 55, 51, 255), shirt=(54, 127, 185, 255), style="band", accent=(226, 106, 58, 255), beard=True),
}


def build_portraits() -> None:
    for key, cfg in PEOPLE.items():
        for expression in ("neutral", "happy", "sad", "surprised"):
            save(portrait(key, expression, **cfg), "sprites", "portraits", f"{key}_{expression}.png")


if __name__ == "__main__":
    build_portraits()
    print("portrait 120x170 (60x85 @2x) dibuat untuk 8 tokoh x 4 ekspresi")