"""Generate placeholder pixel-art assets for the Deli Rewind Citampi-style pilot.

Everything is drawn procedurally so the project has a coherent, original art kit
without depending on third-party asset packs for the vertical slice.
"""

from __future__ import annotations

import math
import os
import random
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "assets")

OUT = (58, 42, 30, 255)
CREAM = (246, 231, 193, 255)
CREAM_DARK = (224, 202, 158, 255)
BROWN = (107, 74, 47, 255)
BROWN_LIGHT = (146, 103, 64, 255)
GREEN = (63, 111, 69, 255)
GREEN_LIGHT = (92, 143, 84, 255)
RIVER = (62, 143, 176, 255)
GOLD = (224, 163, 62, 255)
RED = (198, 91, 78, 255)
SKIN = (244, 198, 158, 255)
SKIN_DARK = (214, 155, 117, 255)
HAIR = (61, 43, 35, 255)
WHITE = (255, 248, 231, 255)


def ensure(*parts: str) -> str:
    path = os.path.join(ASSETS, *parts)
    os.makedirs(path, exist_ok=True)
    return path


def save(img: Image.Image, *parts: str) -> None:
    path = os.path.join(ASSETS, *parts)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)


def rect(d: ImageDraw.ImageDraw, box, color):
    d.rectangle(box, fill=color)


def speckle(d: ImageDraw.ImageDraw, x: int, y: int, w: int, h: int, colors, rng: random.Random, count: int):
    for _ in range(count):
        px = x + rng.randrange(w)
        py = y + rng.randrange(h)
        d.point((px, py), fill=rng.choice(colors))


# ---------------------------------------------------------------- tileset -----
def build_tileset() -> None:
    tile = 16
    cols, rows = 8, 6
    img = Image.new("RGBA", (tile * cols, tile * rows), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rng = random.Random(7)

    def cell(cx: int, cy: int):
        return cx * tile, cy * tile

    def grass(cx, cy, tone):
        x, y = cell(cx, cy)
        base = (74 + tone, 120 + tone, 64 + tone, 255)
        rect(d, (x, y, x + 15, y + 15), base)
        speckle(d, x, y, 16, 16, [(86 + tone, 136 + tone, 72, 255), (62 + tone, 106 + tone, 56, 255)], rng, 22)
        for _ in range(3):
            gx, gy = x + rng.randrange(2, 14), y + rng.randrange(2, 14)
            d.line((gx, gy, gx, gy - 2), fill=(54 + tone, 96 + tone, 50, 255))

    def dirt(cx, cy):
        x, y = cell(cx, cy)
        rect(d, (x, y, x + 15, y + 15), (151, 112, 74, 255))
        speckle(d, x, y, 16, 16, [(132, 96, 64, 255), (174, 132, 88, 255)], rng, 24)

    def path(cx, cy, tone=0):
        x, y = cell(cx, cy)
        rect(d, (x, y, x + 15, y + 15), (198 + tone, 166 + tone, 112 + tone, 255))
        speckle(d, x, y, 16, 16, [(178, 146, 96, 255), (216, 186, 132, 255)], rng, 16)
        d.line((x + 2, y + 13, x + 7, y + 13), fill=(170, 138, 90, 255))

    def stone(cx, cy, tone=0):
        x, y = cell(cx, cy)
        rect(d, (x, y, x + 15, y + 15), (154 + tone, 154 + tone, 146 + tone, 255))
        d.line((x, y + 7, x + 15, y + 7), fill=(122, 122, 116, 255))
        d.line((x + 8, y, x + 8, y + 7), fill=(122, 122, 116, 255))
        d.line((x + 4, y + 7, x + 4, y + 15), fill=(122, 122, 116, 255))
        d.line((x + 12, y + 7, x + 12, y + 15), fill=(122, 122, 116, 255))

    def water(cx, cy, phase=0):
        x, y = cell(cx, cy)
        rect(d, (x, y, x + 15, y + 15), RIVER)
        for row in range(3):
            yy = y + 4 + row * 4 + phase
            d.line((x + 1, yy, x + 6, yy), fill=(96, 181, 204, 255))
            d.line((x + 9, yy + 1, x + 14, yy + 1), fill=(48, 122, 156, 255))

    def sand(cx, cy, tone=0):
        x, y = cell(cx, cy)
        rect(d, (x, y, x + 15, y + 15), (222 + tone, 198 + tone, 140 + tone, 255))
        speckle(d, x, y, 16, 16, [(204, 178, 124, 255), (238, 216, 160, 255)], rng, 20)

    def planks(cx, cy, vertical=False):
        x, y = cell(cx, cy)
        rect(d, (x, y, x + 15, y + 15), (158, 110, 64, 255))
        if vertical:
            for i in range(0, 16, 4):
                d.line((x + i, y, x + i, y + 15), fill=(112, 74, 42, 255))
            d.line((x, y + 3, x + 15, y + 3), fill=(196, 148, 96, 255))
        else:
            for i in range(0, 16, 4):
                d.line((x, y + i, x + 15, y + i), fill=(112, 74, 42, 255))
            d.line((x + 3, y, x + 3, y + 15), fill=(196, 148, 96, 255))

    def bricks(cx, cy):
        x, y = cell(cx, cy)
        rect(d, (x, y, x + 15, y + 15), (178, 124, 84, 255))
        for row in range(4):
            yy = y + row * 4
            d.line((x, yy, x + 15, yy), fill=(132, 88, 58, 255))
            offset = 0 if row % 2 == 0 else 4
            d.line((x + offset, yy, x + offset, yy + 3), fill=(132, 88, 58, 255))
            d.line((x + offset + 8, yy, x + offset + 8, yy + 3), fill=(132, 88, 58, 255))

    def roof(cx, cy):
        x, y = cell(cx, cy)
        rect(d, (x, y, x + 15, y + 15), (170, 82, 64, 255))
        for row in range(4):
            yy = y + row * 4
            d.line((x, yy, x + 15, yy), fill=(122, 52, 44, 255))
            d.arc((x + 1, yy, x + 9, yy + 4), 180, 360, fill=(210, 116, 86, 255))
            d.arc((x + 7, yy, x + 15, yy + 4), 180, 360, fill=(210, 116, 86, 255))

    def fence(cx, cy):
        x, y = cell(cx, cy)
        rect(d, (x, y, x + 15, y + 15), (0, 0, 0, 0))
        d.line((x + 2, y + 4, x + 2, y + 15), fill=BROWN, width=2)
        d.line((x + 12, y + 4, x + 12, y + 15), fill=BROWN, width=2)
        d.line((x + 1, y + 7, x + 15, y + 7), fill=BROWN_LIGHT, width=2)
        d.line((x + 1, y + 12, x + 15, y + 12), fill=BROWN_LIGHT, width=2)

    def bush(cx, cy):
        x, y = cell(cx, cy)
        rect(d, (x, y, x + 15, y + 15), (0, 0, 0, 0))
        d.ellipse((x + 1, y + 4, x + 10, y + 14), fill=(54, 104, 58, 255))
        d.ellipse((x + 6, y + 2, x + 15, y + 13), fill=(67, 122, 66, 255))
        d.ellipse((x + 4, y + 7, x + 13, y + 15), fill=(45, 88, 50, 255))

    def rock(cx, cy):
        x, y = cell(cx, cy)
        rect(d, (x, y, x + 15, y + 15), (0, 0, 0, 0))
        d.ellipse((x + 2, y + 6, x + 14, y + 15), fill=(128, 130, 128, 255))
        d.ellipse((x + 4, y + 5, x + 11, y + 11), fill=(158, 160, 158, 255))

    # ---- tile kota (baris 3-4): aspal, trotoar, zebra cross, paving ----
    ASPHALT = (68, 70, 76, 255)
    ASPHALT_L = (84, 86, 92, 255)
    ASPHALT_D = (52, 54, 58, 255)
    PAINT = (226, 226, 214, 255)
    CONCRETE = (146, 144, 136, 255)
    CONCRETE_L = (166, 164, 154, 255)
    CONCRETE_D = (112, 110, 104, 255)
    PAVING = (176, 168, 152, 255)
    PAVING_D = (142, 134, 120, 255)
    PAVING_L = (198, 190, 172, 255)

    def asphalt_tile(cx, cy, variant=0):
        x, y = cell(cx, cy)
        rect(d, (x, y, x + 15, y + 15), ASPHALT if variant == 0 else ASPHALT_L)
        speckle(d, x, y, 16, 16, [ASPHALT_D, ASPHALT_L], rng, 30)
        if variant == 1:
            d.line((x + 3, y + 10, x + 5, y + 12), fill=ASPHALT_D)
            d.line((x + 5, y + 12, x + 4, y + 14), fill=ASPHALT_D)
        if variant == 2:
            # retak halus
            d.line((x + 11, y + 2, x + 9, y + 6), fill=ASPHALT_D)
            d.line((x + 9, y + 6, x + 10, y + 9), fill=ASPHALT_D)

    def road_mark(cx, cy, axis):
        asphalt_tile(cx, cy, 0)
        x, y = cell(cx, cy)
        if axis == "h":
            for sx in (x + 1, x + 9):
                rect(d, (sx, y + 14, sx + 5, y + 15), PAINT)
        else:
            for sy in (y + 1, y + 9):
                rect(d, (x + 14, sy, x + 15, sy + 5), PAINT)

    def sidewalk(cx, cy, curb=False, tone=0):
        x, y = cell(cx, cy)
        rect(d, (x, y, x + 15, y + 15), CONCRETE)
        speckle(d, x, y, 16, 16, [CONCRETE_L, CONCRETE_D], rng, 16)
        d.line((x, y + 7, x + 15, y + 7), fill=CONCRETE_D)
        d.line((x + 7, y, x + 7, y + 7), fill=CONCRETE_D)
        d.line((x + 11, y + 8, x + 11, y + 15), fill=CONCRETE_D)
        d.line((x, y, x + 15, y), fill=CONCRETE_L)
        if curb == "bottom":
            rect(d, (x, y + 12, x + 15, y + 15), CONCRETE_L)
            d.line((x, y + 12, x + 15, y + 12), fill=CONCRETE_D)
            d.line((x, y + 15, x + 15, y + 15), fill=(92, 90, 84, 255))
        elif curb == "top":
            rect(d, (x, y, x + 15, y + 3), CONCRETE_L)
            d.line((x, y, x + 15, y), fill=(92, 90, 84, 255))
            d.line((x, y + 3, x + 15, y + 3), fill=CONCRETE_D)
        elif curb == "left":
            rect(d, (x, y, x + 3, y + 15), CONCRETE_L)
            d.line((x, y, x, y + 15), fill=(92, 90, 84, 255))
            d.line((x + 3, y, x + 3, y + 15), fill=CONCRETE_D)
        elif curb == "right":
            rect(d, (x + 12, y, x + 15, y + 15), CONCRETE_L)
            d.line((x + 12, y, x + 12, y + 15), fill=CONCRETE_D)
            d.line((x + 15, y, x + 15, y + 15), fill=(92, 90, 84, 255))

    def crosswalk(cx, cy, axis):
        asphalt_tile(cx, cy, 0)
        x, y = cell(cx, cy)
        if axis == "h":
            # zebra untuk menyeberang jalan horizontal
            for sx in range(x + 1, x + 16, 5):
                rect(d, (sx, y + 1, sx + 2, y + 14), PAINT)
        else:
            for sy in range(y + 1, y + 16, 5):
                rect(d, (x + 1, sy, x + 14, sy + 2), PAINT)

    def plaza(cx, cy, variant=0):
        x, y = cell(cx, cy)
        rect(d, (x, y, x + 15, y + 15), PAVING if variant == 0 else PAVING_L)
        d.line((x, y + 7, x + 15, y + 7), fill=PAVING_D)
        d.line((x, y + 15, x + 15, y + 15), fill=PAVING_D)
        d.line((x + 7, y, x + 7, y + 7), fill=PAVING_D)
        d.line((x + 3, y + 8, x + 3, y + 15), fill=PAVING_D)
        d.line((x + 11, y + 8, x + 11, y + 15), fill=PAVING_D)
        if variant == 1:
            speckle(d, x, y, 16, 16, [PAVING_D], rng, 10)

    def manhole(cx, cy):
        asphalt_tile(cx, cy, 0)
        x, y = cell(cx, cy)
        d.ellipse((x + 4, y + 4, x + 11, y + 11), fill=(58, 60, 64, 255))
        d.ellipse((x + 5, y + 5, x + 10, y + 10), fill=(96, 98, 102, 255))
        d.line((x + 6, y + 7, x + 9, y + 7), fill=(70, 72, 76, 255))

    def planter(cx, cy):
        # Kisi besi pelindung akar (tree grate), bukan rumput.
        x, y = cell(cx, cy)
        rect(d, (x, y, x + 15, y + 15), CONCRETE_D)
        rect(d, (x + 2, y + 2, x + 13, y + 13), (62, 58, 52, 255))
        for gx in range(x + 3, x + 13, 2):
            d.line((gx, y + 3, gx, y + 12), fill=(108, 102, 92, 255))
        for gy in range(y + 3, y + 13, 2):
            d.line((x + 3, gy, x + 12, gy), fill=(96, 90, 82, 255))
        d.rectangle((x + 2, y + 2, x + 13, y + 13), outline=(44, 42, 38, 255))
        d.line((x, y, x + 15, y), fill=CONCRETE_L)
        d.line((x, y + 15, x + 15, y + 15), fill=(92, 90, 84, 255))

    def drain(cx, cy):
        sidewalk(cx, cy)
        x, y = cell(cx, cy)
        rect(d, (x + 2, y + 2, x + 13, y + 5), (66, 68, 72, 255))
        for sx in range(x + 3, x + 13, 2):
            d.line((sx, y + 3, sx, y + 4), fill=(140, 142, 146, 255))

    asphalt_tile(0, 3, 0)
    asphalt_tile(1, 3, 1)
    road_mark(2, 3, "h")
    road_mark(3, 3, "v")
    sidewalk(4, 3)
    sidewalk(5, 3, curb="bottom")
    crosswalk(6, 3, "h")
    crosswalk(7, 3, "v")

    plaza(0, 4, 0)
    plaza(1, 4, 1)
    manhole(2, 4)
    asphalt_tile(3, 4, 2)
    sidewalk(4, 4, curb="top")
    drain(5, 4)
    sidewalk(6, 4)
    crosswalk(7, 4, "h")

    sidewalk(0, 5, curb="left")
    sidewalk(1, 5, curb="right")
    planter(2, 5)

    grass(0, 0, 0); grass(1, 0, 6); grass(2, 0, -6)
    dirt(3, 0)
    path(4, 0); path(5, 0, 4); stone(6, 0); stone(7, 0, -8)
    water(0, 1, 0); water(1, 1, 2)
    # bank edges are sand with a dark lip
    for cx in (2, 3):
        x, y = cell(cx, 1)
        sand(cx, 1, 0)
        if cx == 2:
            d.line((x, y, x + 15, y), fill=(120, 150, 130, 255))
        else:
            d.line((x, y + 15, x + 15, y + 15), fill=(120, 150, 130, 255))
    sand(4, 1); sand(5, 1, 4)
    planks(6, 1); planks(7, 1, vertical=True)
    bricks(0, 2); bricks(1, 2)
    roof(2, 2); roof(3, 2)
    fence(4, 2); bush(6, 2); rock(7, 2)
    planks(5, 2)
    save(img, "tilesets", "pilot_tileset.png")


# ---------------------------------------------------------------- portraits ---
def portrait(key: str, expression: str, skin, hair, shirt, style: str, accent=None, moustache: bool = False, beard: bool = False):
    base = Image.new("RGBA", (80, 100), (0, 0, 0, 0))
    d = ImageDraw.Draw(base)
    accent = accent or (53, 92, 74, 255)

    # backdrop disc
    d.ellipse((4, 8, 76, 92), fill=(246, 231, 193, 90))
    d.ellipse((8, 12, 72, 88), fill=(accent[0], accent[1], accent[2], 60))

    # shoulders / shirt
    d.rounded_rectangle((12, 67, 68, 104), radius=10, fill=shirt, outline=OUT, width=2)
    d.rectangle((30, 60, 50, 74), fill=skin)
    d.rectangle((29, 60, 51, 62), fill=tuple(max(0, c - 28) for c in skin[:3]) + (255,))

    # head
    d.ellipse((22, 20, 58, 64), fill=skin, outline=OUT, width=2)
    # ears
    d.ellipse((19, 38, 25, 50), fill=skin, outline=OUT, width=1)
    d.ellipse((55, 38, 61, 50), fill=skin, outline=OUT, width=1)

    # hair styles
    if style == "hijab":
        d.rounded_rectangle((17, 14, 63, 62), radius=16, fill=hair, outline=OUT, width=2)
        d.ellipse((25, 21, 55, 59), fill=skin)
    elif style == "caping":
        d.ellipse((20, 12, 60, 50), fill=hair)
        d.ellipse((24, 22, 56, 62), fill=skin)
        d.rectangle((21, 24, 25, 36), fill=hair)
        d.rectangle((55, 24, 59, 36), fill=hair)
        d.ellipse((12, 24, 68, 38), fill=(214, 186, 110, 255), outline=OUT, width=2)
        d.rounded_rectangle((26, 4, 54, 28), radius=9, fill=(196, 168, 96, 255), outline=OUT, width=2)
        d.line((30, 18, 50, 18), fill=(160, 130, 68, 255), width=2)
    elif style == "peci":
        d.ellipse((20, 14, 60, 52), fill=hair)
        d.rectangle((20, 15, 60, 23), fill=(42, 34, 30, 255), outline=OUT, width=1)
        d.ellipse((24, 22, 56, 62), fill=skin)
        d.rectangle((21, 27, 24, 45), fill=hair)
    elif style == "long":
        d.ellipse((18, 13, 62, 60), fill=hair)
        d.rectangle((17, 30, 23, 74), fill=hair)
        d.rectangle((57, 30, 63, 74), fill=hair)
        d.ellipse((24, 23, 56, 62), fill=skin)
        d.ellipse((28, 18, 54, 36), fill=hair)
    elif style == "kid":
        d.ellipse((20, 12, 60, 48), fill=hair)
        d.ellipse((24, 21, 56, 62), fill=skin)
        d.rectangle((22, 24, 25, 40), fill=hair)
        d.rectangle((55, 24, 58, 40), fill=hair)
    else:
        d.ellipse((20, 12, 60, 50), fill=hair)
        d.ellipse((24, 22, 56, 62), fill=skin)
        d.rectangle((21, 24, 25, 40), fill=hair)
        d.rectangle((55, 24, 59, 40), fill=hair)
        d.rectangle((26, 21, 54, 29), fill=hair)

    # brows + eyes
    eye_y = 40
    if expression == "happy":
        d.arc((29, eye_y - 2, 36, eye_y + 4), 200, 340, fill=OUT, width=2)
        d.arc((44, eye_y - 2, 51, eye_y + 4), 200, 340, fill=OUT, width=2)
    elif expression == "sad":
        d.line((29, eye_y - 5, 36, eye_y - 3), fill=OUT, width=1)
        d.line((44, eye_y - 3, 51, eye_y - 5), fill=OUT, width=1)
        d.ellipse((30, eye_y - 1, 35, eye_y + 4), fill=WHITE)
        d.ellipse((45, eye_y - 1, 50, eye_y + 4), fill=WHITE)
        d.ellipse((32, eye_y + 1, 34, eye_y + 3), fill=OUT)
        d.ellipse((46, eye_y + 1, 48, eye_y + 3), fill=OUT)
    elif expression == "surprised":
        d.ellipse((29, eye_y - 4, 37, eye_y + 5), fill=WHITE, outline=OUT)
        d.ellipse((43, eye_y - 4, 51, eye_y + 5), fill=WHITE, outline=OUT)
        d.ellipse((32, eye_y - 1, 35, eye_y + 3), fill=OUT)
        d.ellipse((45, eye_y - 1, 48, eye_y + 3), fill=OUT)
        d.ellipse((37, 52, 43, 58), fill=(120, 58, 54, 255))
    else:
        d.line((29, eye_y - 4, 36, eye_y - 4), fill=OUT, width=1)
        d.line((44, eye_y - 4, 51, eye_y - 4), fill=OUT, width=1)
        d.ellipse((30, eye_y - 1, 35, eye_y + 4), fill=WHITE)
        d.ellipse((45, eye_y - 1, 50, eye_y + 4), fill=WHITE)
        d.ellipse((32, eye_y + 1, 34, eye_y + 3), fill=OUT)
        d.ellipse((46, eye_y + 1, 48, eye_y + 3), fill=OUT)
        d.point((33, eye_y + 1), fill=WHITE)
        d.point((47, eye_y + 1), fill=WHITE)

    if beard:
        d.arc((25, 40, 55, 68), 10, 170, fill=hair, width=7)
        d.arc((29, 43, 51, 64), 15, 165, fill=tuple(max(0, c - 24) for c in hair[:3]) + (255,), width=3)

    # nose + mouth
    d.line((40, 45, 39, 49), fill=tuple(max(0, c - 40) for c in skin[:3]) + (255,))
    if expression == "happy":
        d.arc((35, 49, 45, 58), 10, 170, fill=(150, 64, 62, 255), width=2)
    elif expression == "sad":
        d.arc((36, 54, 44, 60), 190, 350, fill=(150, 64, 62, 255), width=2)
    elif expression == "surprised":
        d.ellipse((38, 52, 42, 57), fill=(150, 64, 62, 255))
    else:
        d.line((37, 54, 43, 54), fill=(150, 64, 62, 255), width=1)

    if moustache:
        d.rectangle((34, 50, 46, 52), fill=hair)
        d.rectangle((32, 52, 34, 53), fill=hair)
        d.rectangle((46, 52, 48, 53), fill=hair)

    # blush
    d.ellipse((27, 48, 33, 52), fill=(232, 158, 142, 255))
    d.ellipse((47, 48, 53, 52), fill=(232, 158, 142, 255))

    # batik / apron details
    if key == "pakrt":
        for x in range(20, 62, 8):
            for y in range(76, 100, 8):
                d.point((x, y), fill=(226, 200, 140, 255))
    if key == "pedagang":
        d.rectangle((24, 76, 56, 100), fill=(226, 200, 140, 255), outline=OUT, width=1)
        d.line((28, 82, 52, 82), fill=(160, 110, 70, 255))
    if key == "budi":
        d.polygon([(38, 68), (42, 68), (44, 74), (36, 74)], fill=RED)

    # outline/hair shine
    d.line((29, 18, 38, 16), fill=(255, 255, 255, 45), width=2)

    return base.resize((160, 200), Image.Resampling.NEAREST)


def build_portraits() -> None:
    # Warna disamakan dengan sprite top-down terbaru (tools/generate_characters.py).
    people = {
        "player": dict(skin=(235, 186, 146, 255), hair=(48, 36, 32, 255), shirt=(58, 100, 168, 255), style="short", accent=(206, 88, 68, 255)),
        "pedagang": dict(skin=(212, 156, 114, 255), hair=(40, 32, 28, 255), shirt=(240, 228, 202, 255), style="peci", accent=(150, 100, 62, 255), moustache=True),
        "ibu": dict(skin=(228, 176, 140, 255), hair=(170, 96, 120, 255), shirt=(70, 112, 100, 255), style="hijab", accent=(232, 206, 172, 255)),
        "budi": dict(skin=(240, 196, 156, 255), hair=(44, 34, 30, 255), shirt=(242, 242, 236, 255), style="kid", accent=(64, 122, 190, 255)),
        "pakrt": dict(skin=(220, 166, 124, 255), hair=(38, 32, 28, 255), shirt=(92, 132, 86, 255), style="peci", accent=(228, 222, 198, 255), moustache=True),
        "penjaga_hutan": dict(skin=(206, 152, 112, 255), hair=(58, 44, 34, 255), shirt=(86, 110, 62, 255), style="caping", accent=(198, 172, 112, 255), beard=True),
        "petani": dict(skin=(198, 142, 100, 255), hair=(60, 46, 34, 255), shirt=(196, 172, 100, 255), style="caping", accent=(112, 146, 88, 255), moustache=True),
        "nelayan": dict(skin=(176, 122, 88, 255), hair=(76, 62, 52, 255), shirt=(70, 110, 138, 255), style="caping", accent=(196, 172, 126, 255), beard=True),
    }
    for key, cfg in people.items():
        for expression in ("neutral", "happy", "sad", "surprised"):
            save(portrait(key, expression, **cfg), "sprites", "portraits", f"{key}_{expression}.png")


# ---------------------------------------------------------------- props -------
def build_props() -> None:
    # bins
    bin_colors = {"organik": (84, 130, 78, 255), "plastik": (204, 160, 62, 255), "b3": (184, 78, 70, 255)}
    for key, color in bin_colors.items():
        img = Image.new("RGBA", (16, 24), (0, 0, 0, 0))
        d = ImageDraw.Draw(img)
        d.rounded_rectangle((2, 3, 13, 23), radius=2, fill=color, outline=OUT)
        d.rectangle((1, 2, 14, 5), fill=tuple(max(0, c - 26) for c in color[:3]) + (255,), outline=OUT)
        d.rectangle((6, 1, 9, 3), fill=OUT)
        d.line((4, 8, 4, 20), fill=(255, 248, 231, 80))
        save(img, "sprites", "props", f"bin_{key}.png")

    # trash items
    trash = {
        "organik": ((196, 168, 70, 255), "banana"),
        "plastik": ((92, 170, 210, 255), "bottle"),
        "b3": ((196, 78, 70, 255), "battery"),
    }
    for key, (color, shape) in trash.items():
        img = Image.new("RGBA", (12, 12), (0, 0, 0, 0))
        d = ImageDraw.Draw(img)
        if shape == "banana":
            d.arc((1, 2, 10, 10), 190, 340, fill=color, width=3)
            d.point((9, 2), fill=(120, 90, 40, 255))
        elif shape == "bottle":
            d.rounded_rectangle((4, 2, 7, 10), radius=1, fill=color, outline=OUT)
            d.rectangle((5, 0, 6, 2), fill=(220, 230, 220, 255))
            d.line((5, 4, 5, 8), fill=(220, 245, 255, 120))
        else:
            d.rectangle((2, 3, 9, 9), fill=color, outline=OUT)
            d.rectangle((4, 1, 7, 3), fill=(180, 180, 180, 255))
            d.line((4, 5, 7, 5), fill=(255, 220, 100, 255))
        save(img, "sprites", "props", f"trash_{key}.png")

    # lever
    for state in ("off", "on"):
        img = Image.new("RGBA", (16, 24), (0, 0, 0, 0))
        d = ImageDraw.Draw(img)
        d.rectangle((6, 14, 9, 23), fill=(120, 118, 112, 255), outline=OUT)
        d.rectangle((4, 21, 11, 23), fill=(92, 90, 86, 255), outline=OUT)
        if state == "off":
            d.line((8, 15, 13, 5), fill=(198, 158, 72, 255), width=3)
            d.ellipse((11, 2, 15, 6), fill=RED, outline=OUT)
        else:
            d.line((8, 15, 3, 6), fill=(198, 158, 72, 255), width=3)
            d.ellipse((1, 3, 5, 7), fill=GREEN_LIGHT, outline=OUT)
        save(img, "sprites", "props", f"lever_{state}.png")

    # gate
    img = Image.new("RGBA", (32, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle((3, 2, 29, 46), fill=(126, 82, 48, 255), outline=OUT)
    for x in range(6, 29, 5):
        d.line((x, 5, x, 43), fill=(168, 116, 68, 255))
    d.rectangle((1, 0, 31, 5), fill=(92, 60, 38, 255), outline=OUT)
    d.ellipse((13, 22, 19, 28), fill=GOLD, outline=OUT)
    save(img, "sprites", "props", "gate_closed.png")
    img = Image.new("RGBA", (32, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle((2, 2, 8, 46), fill=(126, 82, 48, 255), outline=OUT)
    d.rectangle((24, 2, 30, 46), fill=(126, 82, 48, 255), outline=OUT)
    d.rectangle((1, 0, 31, 5), fill=(92, 60, 38, 255), outline=OUT)
    save(img, "sprites", "props", "gate_open.png")

    # tree — memakai aset pohon mangga (56x51) yang sudah final.
    # Jangan ditimpa gambar prosedural: sumber mentahnya ada di assets/source_art/.
    tree_path = os.path.join(ASSETS, "sprites", "props", "tree.png")
    if not os.path.exists(tree_path):
        print("  ! tree.png tidak ada — lewati (jangan timpa aset pohon mangga)")

    # mangrove — arching roots and a dense coastal canopy
    img = Image.new("RGBA", (32, 40), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    for x1, y1 in ((5, 38), (26, 38), (1, 31), (30, 31)):
        d.line((16, 24, x1, y1), fill=(96, 70, 46, 255), width=2)
    d.rectangle((14, 17, 18, 31), fill=(112, 82, 52, 255), outline=OUT)
    d.ellipse((2, 2, 30, 24), fill=(45, 96, 62, 255), outline=OUT)
    d.ellipse((0, 8, 16, 25), fill=(58, 116, 74, 255), outline=OUT)
    d.ellipse((16, 6, 32, 24), fill=(38, 84, 56, 255), outline=OUT)
    d.ellipse((8, 0, 24, 14), fill=(76, 138, 84, 255))
    save(img, "sprites", "props", "mangrove.png")

    # tree spot marker — dashed planting ring with a small sprout
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    ring = (246, 231, 193, 165)
    for i in range(0, 12, 4):
        d.arc((2, 3, 13, 14), i * 30, i * 30 + 20, fill=ring, width=1)
    d.line((8, 13, 8, 7), fill=(58, 108, 54, 255), width=1)
    d.ellipse((4, 5, 8, 9), fill=(92, 143, 84, 255), outline=OUT)
    d.ellipse((8, 4, 12, 8), fill=(76, 128, 74, 255), outline=OUT)
    save(img, "sprites", "props", "tree_spot.png")

    # pantun board
    img = Image.new("RGBA", (24, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle((10, 18, 13, 31), fill=(104, 70, 42, 255), outline=OUT)
    d.rectangle((2, 2, 21, 19), fill=(224, 202, 158, 255), outline=OUT)
    d.rectangle((4, 4, 19, 17), fill=(246, 231, 193, 255))
    for y in (7, 10, 13):
        d.line((6, y, 17, y), fill=(120, 90, 60, 255))
    d.rectangle((2, 2, 21, 5), fill=BROWN, outline=OUT)
    save(img, "sprites", "props", "pantun_board.png")

    # river reeds
    img = Image.new("RGBA", (16, 20), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rng = random.Random(31)
    for i in range(7):
        x = 3 + rng.randrange(10)
        h = 8 + rng.randrange(10)
        lean = -1 if i % 2 == 0 else 1
        d.line((x, 19, x + lean, 19 - h), fill=(58, 108, 54, 255), width=2)
        d.line((x, 19, x + lean * 2, 19 - h + 1), fill=(82, 138, 70, 255), width=1)
    d.ellipse((4, 16, 13, 20), fill=(46, 82, 45, 255))
    save(img, "sprites", "props", "reed.png")

    # buildings (origin bottom-center)
    def building(key, w, h, wall, roof_color, sign_color):
        img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        d = ImageDraw.Draw(img)
        d.rectangle((2, 18, w - 3, h - 1), fill=wall, outline=OUT, width=2)
        d.polygon([(0, 20), (w // 2, 2), (w - 1, 20)], fill=roof_color, outline=OUT)
        d.rectangle((w // 2 - 8, h - 22, w // 2 + 8, h - 2), fill=(92, 64, 44, 255), outline=OUT)
        d.rectangle((6, 26, 22, 36), fill=(150, 200, 210, 255), outline=OUT)
        d.rectangle((w - 24, 26, w - 8, 36), fill=(150, 200, 210, 255), outline=OUT)
        d.rectangle((w // 2 - 16, 20, w // 2 + 16, 26), fill=sign_color, outline=OUT)
        # sign scribbles
        for i in range(3):
            d.line((w // 2 - 12 + i * 8, 22, w // 2 - 8 + i * 8, 22), fill=(60, 44, 32, 255))
        save(img, "sprites", "props", f"{key}.png")

    building("warung", 96, 64, (214, 176, 120, 255), (170, 82, 64, 255), (204, 160, 62, 255))
    building("house", 96, 64, (228, 210, 176, 255), (148, 94, 72, 255), (108, 136, 92, 255))
    building("shop", 96, 64, (190, 198, 204, 255), (106, 92, 86, 255), (84, 136, 156, 255))


# ---------------------------------------------------------------- UI ----------
def build_ui() -> None:
    def panel(path, size, border, fill, edge, inner=None):
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        d = ImageDraw.Draw(img)
        d.rectangle((0, 0, size - 1, size - 1), fill=fill, outline=edge, width=border)
        if inner:
            d.rectangle((border + 2, border + 2, size - border - 3, size - border - 3), outline=inner)
        # corner notches for a crafted look
        for x, y in ((0, 0), (size - 1, 0), (0, size - 1), (size - 1, size - 1)):
            d.point((x, y), fill=(0, 0, 0, 0))
        save(img, "ui", path)

    panel("panel_paper.png", 48, 3, CREAM, BROWN, CREAM_DARK)
    panel("panel_dialog.png", 64, 4, CREAM, BROWN, CREAM_DARK)
    panel("panel_dark.png", 48, 3, (45, 54, 50, 235), (28, 34, 30, 255), (70, 88, 70, 255))

    def button(path, fill, edge, top, bottom):
        img = Image.new("RGBA", (48, 24), (0, 0, 0, 0))
        d = ImageDraw.Draw(img)
        d.rounded_rectangle((0, 0, 47, 23), radius=5, fill=fill, outline=edge, width=2)
        d.line((5, 3, 42, 3), fill=top, width=1)
        d.line((5, 20, 42, 20), fill=bottom, width=1)
        save(img, "ui", path)

    button("button.png", (222, 188, 128, 255), BROWN, (248, 224, 174, 255), (176, 138, 88, 255))
    button("button_hover.png", (238, 206, 146, 255), BROWN, (255, 240, 198, 255), (188, 150, 98, 255))
    button("button_pressed.png", (190, 152, 96, 255), BROWN, (160, 126, 78, 255), (222, 188, 128, 255))

    # slot
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((1, 1, 30, 30), radius=4, fill=(232, 212, 172, 255), outline=BROWN, width=2)
    d.rectangle((6, 6, 25, 25), outline=(190, 162, 116, 255))
    save(img, "ui", "slot.png")

    # joystick
    img = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse((2, 2, 93, 93), fill=(30, 38, 34, 110), outline=(246, 231, 193, 160), width=3)
    d.ellipse((18, 18, 77, 77), outline=(246, 231, 193, 80), width=1)
    save(img, "ui", "joystick_base.png")

    img = Image.new("RGBA", (40, 40), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse((2, 2, 37, 37), fill=(224, 163, 62, 220), outline=BROWN, width=3)
    d.ellipse((10, 8, 22, 16), fill=(255, 238, 190, 120))
    save(img, "ui", "joystick_knob.png")

    for state, fill in (("", (224, 163, 62, 225)), ("_pressed", (190, 128, 48, 235))):
        img = Image.new("RGBA", (56, 56), (0, 0, 0, 0))
        d = ImageDraw.Draw(img)
        d.ellipse((2, 2, 53, 53), fill=fill, outline=BROWN, width=3)
        d.ellipse((10, 8, 30, 20), fill=(255, 238, 190, 80))
        save(img, "ui", f"action_button{state}.png")

    # icons
    def icon(name, painter):
        img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
        d = ImageDraw.Draw(img)
        painter(d)
        save(img, "ui", "icons", f"{name}.png")

    icon("droplet", lambda d: (d.polygon([(8, 1), (13, 8), (8, 15), (3, 8)], fill=(92, 184, 212, 255), outline=BROWN), d.line((6, 8, 6, 10), fill=WHITE)))
    icon("coin", lambda d: (d.ellipse((2, 2, 13, 13), fill=GOLD, outline=BROWN, width=1), d.rectangle((6, 5, 9, 10), fill=(246, 220, 140, 255))))
    icon("clock", lambda d: (d.ellipse((1, 1, 14, 14), fill=CREAM, outline=BROWN, width=1), d.line((8, 8, 8, 4), fill=BROWN, width=1), d.line((8, 8, 11, 10), fill=BROWN, width=1)))
    icon("home", lambda d: (d.polygon([(1, 8), (8, 1), (15, 8)], fill=(198, 91, 78, 255), outline=BROWN), d.rectangle((3, 8, 12, 15), fill=CREAM, outline=BROWN)))
    icon("chat", lambda d: (d.rounded_rectangle((1, 2, 14, 11), radius=3, fill=CREAM, outline=BROWN), d.polygon([(5, 11), (5, 15), (9, 11)], fill=CREAM, outline=BROWN)))
    icon("hand", lambda d: (d.rectangle((5, 4, 10, 14), fill=SKIN, outline=OUT), d.rectangle((3, 7, 5, 11), fill=SKIN, outline=OUT), d.rectangle((10, 7, 12, 11), fill=SKIN, outline=OUT)))
    icon("leaf", lambda d: (d.polygon([(2, 13), (7, 2), (14, 4), (10, 12)], fill=GREEN_LIGHT, outline=OUT), d.line((3, 13, 11, 5), fill=GREEN, width=1)))
    icon("card", lambda d: (d.rectangle((2, 3, 13, 13), fill=CREAM, outline=BROWN), d.rectangle((4, 5, 11, 8), fill=(204, 160, 62, 255)), d.line((4, 10, 11, 10), fill=BROWN)))
    icon("check", lambda d: d.line((2, 8, 6, 12, 13, 3), fill=(92, 170, 92, 255), width=2))
    icon("cross", lambda d: (d.line((3, 3, 12, 12), fill=RED, width=2), d.line((12, 3, 3, 12), fill=RED, width=2)))


# ---------------------------------------------------------------- menu bg -----
def build_menu_bg() -> None:
    w, h = 640, 360
    img = Image.new("RGBA", (w, h), (0, 0, 0, 255))
    d = ImageDraw.Draw(img)
    # sky gradient
    for y in range(h):
        t = y / h
        color = (
            int(126 + 60 * t),
            int(184 + 40 * t),
            int(206 + 20 * t),
            255,
        )
        d.line((0, y, w, y), fill=color)
    # sun
    d.ellipse((520, 36, 586, 102), fill=(255, 228, 160, 255))
    d.ellipse((528, 44, 578, 94), fill=(255, 244, 196, 255))
    # clouds
    for cx, cy, s in ((80, 56, 1.0), (210, 38, 0.7), (390, 66, 0.85), (500, 40, 0.6)):
        d.ellipse((cx, cy, cx + int(70 * s), cy + int(26 * s)), fill=(255, 250, 232, 220))
        d.ellipse((cx + int(24 * s), cy - int(10 * s), cx + int(78 * s), cy + int(20 * s)), fill=(255, 250, 232, 220))
    # distant hills
    d.polygon([(0, 210), (120, 130), (250, 210)], fill=(116, 150, 112, 255))
    d.polygon([(140, 210), (300, 120), (460, 210)], fill=(102, 138, 104, 255))
    d.polygon([(360, 210), (520, 140), (640, 210)], fill=(122, 156, 116, 255))
    # ground
    d.rectangle((0, 200, w, h), fill=(74, 120, 64, 255))
    for i in range(400):
        x = random.randrange(w); y = random.randrange(204, h)
        d.point((x, y), fill=random.choice([(86, 136, 72, 255), (62, 106, 56, 255)]))
    # river winding
    points = [(0, 330), (90, 310), (180, 330), (280, 300), (380, 326), (480, 300), (580, 320), (640, 306)]
    for i in range(len(points) - 1):
        x1, y1 = points[i]; x2, y2 = points[i + 1]
        d.line((x1, y1, x2, y2), fill=(78, 160, 190, 255), width=34)
        d.line((x1, y1 - 8, x2, y2 - 8), fill=(126, 204, 220, 255), width=5)
    # houses
    for hx, hy, s in ((50, 232, 1.0), (250, 224, 0.8), (440, 238, 0.9)):
        bw, bh = int(64 * s), int(48 * s)
        d.rectangle((hx, hy, hx + bw, hy + bh), fill=(228, 210, 176, 255), outline=(90, 66, 46, 255), width=2)
        d.polygon([(hx - 6, hy), (hx + bw // 2, hy - 28), (hx + bw + 6, hy)], fill=(170, 82, 64, 255), outline=(90, 66, 46, 255))
        d.rectangle((hx + bw // 2 - 7, hy + 18, hx + bw // 2 + 7, hy + bh), fill=(110, 76, 48, 255), outline=(90, 66, 46, 255))
        d.rectangle((hx + 8, hy + 10, hx + 20, hy + 20), fill=(150, 200, 210, 255), outline=(90, 66, 46, 255))
    # trees
    for tx, ty, s in ((20, 210, 1.0), (150, 218, 0.8), (360, 214, 0.9), (600, 220, 0.7)):
        d.rectangle((tx + 10, ty + 20, tx + 16, ty + 46), fill=(104, 70, 42, 255))
        d.ellipse((tx - 10, ty - 6, tx + 38, ty + 34), fill=(54, 104, 58, 255), outline=(40, 76, 44, 255))
    # foreground reeds
    for i in range(40):
        x = random.randrange(w)
        y = random.randrange(330, 359)
        d.line((x, y, x - 2, y - random.randrange(8, 20)), fill=(92, 143, 84, 255))
    save(img, "ui", "menu_bg.png")


def build_city_props() -> None:
    """Perabot jalan kota: lampu, bangku, hidran, mobil, lampu lalu lintas."""
    pole = (78, 80, 86, 255)
    pole_l = (120, 122, 128, 255)

    # lampu jalan
    img = Image.new("RGBA", (12, 34), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle((5, 8, 6, 33), fill=pole, outline=OUT)
    d.line((5, 8, 5, 33), fill=pole_l)
    d.rectangle((3, 31, 8, 33), fill=(64, 66, 70, 255), outline=OUT)
    d.line((5, 8, 10, 5), fill=pole, width=2)
    d.rounded_rectangle((7, 2, 11, 5), radius=1, fill=(248, 226, 148, 255), outline=OUT)
    d.point((8, 3), fill=(255, 250, 220, 255))
    save(img, "sprites", "props", "lamp.png")

    # bangku taman
    img = Image.new("RGBA", (22, 12), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle((1, 3, 20, 5), fill=(150, 104, 62, 255), outline=OUT)
    d.line((2, 3, 19, 3), fill=(184, 132, 82, 255))
    d.rectangle((1, 7, 20, 9), fill=(132, 92, 56, 255), outline=OUT)
    d.line((3, 10, 3, 11), fill=(70, 72, 76, 255), width=2)
    d.line((18, 10, 18, 11), fill=(70, 72, 76, 255), width=2)
    save(img, "sprites", "props", "bench.png")

    # hidran
    img = Image.new("RGBA", (10, 14), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle((3, 4, 6, 13), fill=(198, 70, 62, 255), outline=OUT)
    d.ellipse((2, 1, 7, 5), fill=(214, 84, 74, 255), outline=OUT)
    d.rectangle((1, 6, 2, 8), fill=(168, 56, 50, 255), outline=OUT)
    d.rectangle((7, 6, 8, 8), fill=(168, 56, 50, 255), outline=OUT)
    d.rectangle((2, 12, 7, 13), fill=(96, 96, 100, 255), outline=OUT)
    save(img, "sprites", "props", "hydrant.png")

    # mobil (putih, diwarnai lewat modulate di game)
    img = Image.new("RGBA", (20, 28), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    body = (238, 238, 240, 255)
    d.rounded_rectangle((2, 1, 17, 26), radius=3, fill=body, outline=OUT)
    d.rounded_rectangle((3, 2, 16, 25), radius=2, fill=(250, 250, 252, 255))
    # kaca depan & belakang
    d.rectangle((4, 5, 15, 9), fill=(96, 132, 152, 255), outline=OUT)
    d.rectangle((4, 18, 15, 21), fill=(84, 116, 136, 255), outline=OUT)
    # atap
    d.rectangle((4, 10, 15, 17), fill=body)
    d.line((4, 10, 15, 10), fill=(200, 202, 206, 255))
    # lampu
    d.rectangle((3, 24, 5, 26), fill=(250, 232, 160, 255), outline=OUT)
    d.rectangle((14, 24, 16, 26), fill=(250, 232, 160, 255), outline=OUT)
    d.rectangle((3, 1, 5, 3), fill=(198, 66, 60, 255), outline=OUT)
    d.rectangle((14, 1, 16, 3), fill=(198, 66, 60, 255), outline=OUT)
    # spion
    d.rectangle((1, 8, 2, 10), fill=(60, 62, 66, 255), outline=OUT)
    d.rectangle((17, 8, 18, 10), fill=(60, 62, 66, 255), outline=OUT)
    save(img, "sprites", "props", "car.png")

    # pagar jembatan (dipasang tegak di tepi dek)
    img = Image.new("RGBA", (8, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle((0, 0, 7, 2), fill=(170, 172, 176, 255), outline=OUT)
    d.rectangle((0, 61, 7, 63), fill=(170, 172, 176, 255), outline=OUT)
    d.rectangle((1, 0, 2, 63), fill=(158, 160, 166, 255), outline=OUT)
    d.rectangle((5, 0, 6, 63), fill=(116, 118, 124, 255), outline=OUT)
    for py in range(6, 58, 12):
        d.rectangle((0, py, 7, py + 2), fill=(104, 106, 112, 255), outline=OUT)
    save(img, "sprites", "props", "rail.png")

    # lampu lalu lintas
    img = Image.new("RGBA", (12, 30), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle((4, 12, 5, 29), fill=pole, outline=OUT)
    d.rectangle((2, 27, 7, 29), fill=(64, 66, 70, 255), outline=OUT)
    d.rounded_rectangle((2, 1, 9, 13), radius=2, fill=(58, 60, 64, 255), outline=OUT)
    d.ellipse((4, 2, 7, 5), fill=(214, 78, 70, 255))
    d.ellipse((4, 6, 7, 9), fill=(226, 186, 74, 255))
    d.ellipse((4, 10, 7, 13), fill=(84, 168, 96, 255))
    d.point((5, 7), fill=(255, 246, 200, 255))
    save(img, "sprites", "props", "traffic_light.png")


def main() -> None:
    build_tileset()
    build_portraits()
    build_props()
    build_city_props()
    build_ui()
    build_menu_bg()
    print("  (karakter dibuat oleh tools/generate_characters.py)")

    print("assets generated")


if __name__ == "__main__":
    main()
