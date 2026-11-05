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
    cols, rows = 8, 4
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
    # fillers
    for cx in range(8):
        for cy in range(3, 4):
            x, y = cell(cx, cy)
            rect(d, (x, y, x + 15, y + 15), (0, 0, 0, 0))
    save(img, "tilesets", "pilot_tileset.png")


# ---------------------------------------------------------------- characters --
def draw_character(direction: str, frame: int, shirt, pants, hair_color, skin=SKIN, style="short", kid=False):
    img = Image.new("RGBA", (16, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    bob = 1 if frame == 2 else 0
    if kid:
        bob += 1

    # legs
    lx = 5 if frame in (1, 2) else 4
    rx = 9 if frame in (1, 2) else 8
    rect(d, (lx, 19, lx + 2, 23), pants)
    rect(d, (rx, 19, rx + 2, 23), pants)
    rect(d, (lx, 22, lx + 2, 23), (72, 50, 38, 255))
    rect(d, (rx, 22, rx + 2, 23), (72, 50, 38, 255))

    # body
    top = 11 + bob
    rect(d, (4, top, 11, top + 7), shirt)
    rect(d, (4, top, 4, top + 7), OUT)
    rect(d, (11, top, 11, top + 7), OUT)
    if direction == "down":
        d.line((5, top + 1, 10, top + 1), fill=tuple(min(255, c + 22) for c in shirt[:3]) + (255,))
    # arms
    if direction == "left":
        rect(d, (3, top + 1, 4, top + 6), skin)
    elif direction == "right":
        rect(d, (11, top + 1, 12, top + 6), skin)
    else:
        rect(d, (3, top + 1, 3, top + 5), skin)
        rect(d, (12, top + 1, 12, top + 5), skin)

    # head
    hy = 3 + bob
    rect(d, (4, hy, 11, hy + 7), skin)
    rect(d, (4, hy, 4, hy + 7), OUT)
    rect(d, (11, hy, 11, hy + 7), OUT)
    # hair
    if style == "hijab":
        rect(d, (3, hy - 1, 12, hy + 4), hair_color)
        rect(d, (3, hy - 1, 3, hy + 9), hair_color)
        rect(d, (12, hy - 1, 12, hy + 9), hair_color)
        rect(d, (5, hy + 5, 10, hy + 8), skin)
    elif style == "caping":
        # Caping jerami khas nelayan: lebar di bawah, mengerucut di atas.
        rect(d, (2, hy - 1, 13, hy + 1), (214, 186, 110, 255))
        rect(d, (2, hy + 1, 13, hy + 1), OUT)
        rect(d, (5, hy - 3, 10, hy - 1), (196, 168, 96, 255))
        rect(d, (5, hy - 3, 10, hy - 3), OUT)
        rect(d, (4, hy + 2, 11, hy + 2), hair_color)
    elif style == "peci":
        rect(d, (3, hy - 1, 12, hy + 2), hair_color)
        rect(d, (3, hy - 1, 12, hy), OUT)
        rect(d, (4, hy + 2, 11, hy + 4), hair_color)
    else:
        rect(d, (3, hy - 1, 12, hy + 2), hair_color)
        if style == "long":
            rect(d, (3, hy, 3, hy + 10), hair_color)
            rect(d, (12, hy, 12, hy + 10), hair_color)
        elif style == "kid":
            rect(d, (3, hy, 12, hy + 3), hair_color)

    # face
    if direction == "down":
        d.point((6, hy + 3), fill=OUT); d.point((9, hy + 3), fill=OUT)
        d.line((7, hy + 5, 8, hy + 5), fill=(172, 104, 86, 255))
    elif direction == "left":
        d.point((5, hy + 3), fill=OUT)
        d.point((3, hy + 3), fill=OUT)
    elif direction == "right":
        d.point((10, hy + 3), fill=OUT)
        d.point((12, hy + 3), fill=OUT)
    # up = back of head, no face

    return img


def build_character_sheet(name, shirt, pants, hair_color, style="short", kid=False):
    sheet = Image.new("RGBA", (16 * 4, 24 * 4), (0, 0, 0, 0))
    for row, direction in enumerate(("down", "left", "right", "up")):
        for col in range(4):
            frame = draw_character(direction, col, shirt, pants, hair_color, style=style, kid=kid)
            sheet.alpha_composite(frame, (col * 16, row * 24))
    save(sheet, "sprites", "characters", f"{name}.png")

    # soft ellipse shadow
    shadow = Image.new("RGBA", (16, 8), (0, 0, 0, 0))
    d = ImageDraw.Draw(shadow)
    d.ellipse((1, 1, 14, 6), fill=(30, 24, 20, 80))
    save(shadow, "sprites", "characters", "shadow.png")


def build_characters() -> None:
    build_character_sheet("player", (66, 124, 176, 255), (78, 63, 53, 255), (54, 40, 34, 255), "short")
    build_character_sheet("pedagang", (196, 128, 68, 255), (70, 66, 58, 255), (62, 44, 34, 255), "peci")
    build_character_sheet("ibu", (156, 84, 104, 255), (96, 74, 62, 255), (170, 92, 112, 255), "hijab")
    build_character_sheet("budi", (224, 224, 216, 255), (52, 82, 124, 255), (46, 36, 30, 255), "kid", kid=True)
    build_character_sheet("pakrt", (108, 136, 92, 255), (64, 58, 50, 255), (48, 38, 32, 255), "short")
    build_character_sheet("penjaga_hutan", (74, 108, 72, 255), (72, 60, 46, 255), (58, 42, 32, 255), "short")
    build_character_sheet("petani", (176, 158, 92, 255), (92, 74, 52, 255), (108, 84, 50, 255), "peci")
    build_character_sheet("nelayan", (64, 92, 112, 255), (86, 74, 58, 255), (52, 40, 34, 255), "caping")


# ---------------------------------------------------------------- portraits ---
def portrait(key: str, expression: str, skin, hair, shirt, style: str, accent=None):
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
    people = {
        "player": dict(skin=SKIN, hair=(54, 40, 34, 255), shirt=(66, 124, 176, 255), style="short", accent=(63, 111, 69, 255)),
        "pedagang": dict(skin=(226, 176, 134, 255), hair=(62, 44, 34, 255), shirt=(196, 128, 68, 255), style="peci", accent=(154, 112, 70, 255)),
        "ibu": dict(skin=(238, 190, 150, 255), hair=(170, 92, 112, 255), shirt=(156, 84, 104, 255), style="hijab", accent=(140, 90, 110, 255)),
        "budi": dict(skin=(242, 196, 154, 255), hair=(46, 36, 30, 255), shirt=(224, 224, 216, 255), style="kid", accent=(80, 120, 160, 255)),
        "pakrt": dict(skin=(220, 170, 128, 255), hair=(48, 38, 32, 255), shirt=(108, 136, 92, 255), style="short", accent=(96, 124, 82, 255)),
        "penjaga_hutan": dict(skin=(224, 176, 134, 255), hair=(58, 42, 32, 255), shirt=(74, 108, 72, 255), style="short", accent=(70, 100, 68, 255)),
        "petani": dict(skin=(228, 178, 132, 255), hair=(108, 84, 50, 255), shirt=(176, 158, 92, 255), style="peci", accent=(150, 132, 74, 255)),
        "nelayan": dict(skin=(214, 160, 118, 255), hair=(52, 40, 34, 255), shirt=(64, 92, 112, 255), style="caping", accent=(60, 112, 136, 255)),
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

    # tree
    img = Image.new("RGBA", (32, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rectangle((13, 28, 19, 47), fill=(104, 70, 42, 255), outline=OUT)
    d.ellipse((2, 4, 30, 34), fill=(54, 104, 58, 255), outline=OUT)
    d.ellipse((0, 12, 18, 32), fill=(67, 122, 66, 255), outline=OUT)
    d.ellipse((14, 10, 32, 32), fill=(45, 88, 50, 255), outline=OUT)
    d.ellipse((8, 2, 24, 20), fill=(92, 143, 84, 255))
    save(img, "sprites", "props", "tree.png")

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


def main() -> None:
    build_tileset()
    build_characters()
    build_portraits()
    build_props()
    build_ui()
    build_menu_bg()
    print("assets generated")


if __name__ == "__main__":
    main()
