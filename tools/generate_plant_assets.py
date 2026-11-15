"""Generate the planting-spot ring and seedling sprites.

Run from the project root:
    python tools/generate_plant_assets.py

The existing tree_spot.png (sprout + dashed ring) is split into two assets:
  * tree_spot_ring.png  - only the ground ring, shown before planting
  * seedling_tree.png   - the sprout with a soil mound, shown right after planting
  * seedling_mangrove.png - same sprout recoloured for mangrove spots

Keeping the generator here makes the art reproducible if the palette changes.
"""

from pathlib import Path

import math

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
PROPS = ROOT / "assets" / "sprites" / "props"

CREAM = (246, 232, 192, 220)
CREAM_DIM = (214, 196, 154, 170)
SHADOW = (31, 49, 26, 55)
SOIL_DARK = (72, 48, 30, 255)
SOIL_MID = (122, 86, 48, 255)
SOIL_LIGHT = (158, 116, 68, 255)

# Mappings from the tree sprout palette to the mangrove palette.
MANGROVE_MAP = {
    (36, 54, 28): (24, 58, 38),
    (62, 118, 56): (58, 116, 74),
    (92, 158, 74): (76, 138, 84),
    (138, 202, 92): (112, 170, 100),
    (146, 108, 64): (96, 70, 46),
    (122, 86, 48): (58, 42, 30),
    (28, 48, 22): (20, 40, 28),
}


def build_ring() -> Image.Image:
    """A dashed, slightly squashed ground circle (no sprout)."""
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy, rx, ry = 8.0, 11.0, 6.0, 3.0

    # Soft shadow under the bottom arc to ground the ring on the grass.
    draw.arc(
        (cx - rx, cy + 1 - ry, cx + rx, cy + 1 + ry),
        start=0,
        end=180,
        fill=SHADOW,
        width=1,
    )

    # 12 cream dashes around the ellipse.
    dashes = 12
    for i in range(dashes):
        a = (i + 0.5) / dashes * math.tau
        x = round(cx + rx * math.cos(a))
        y = round(cy + ry * math.sin(a))
        draw.point((x, y), fill=CREAM)
        x2 = round(cx + rx * math.cos(a + 0.16))
        y2 = round(cy + ry * math.sin(a + 0.16))
        draw.point((x2, y2), fill=CREAM_DIM)
    return img


def _sprout_pixels() -> list[tuple[int, int, tuple[int, int, int, int]]]:
    src = Image.open(PROPS / "tree_spot.png").convert("RGBA")
    pixels = []
    for y in range(src.height):
        for x in range(src.width):
            r, g, b, a = src.getpixel((x, y))
            if a == 0:
                continue
            # Drop the cream ring; keep only the green/brown sprout.
            if r > 200 and g > 170 and b > 120:
                continue
            pixels.append((x, y, (r, g, b, 255)))
    return pixels


def build_seedling(mangrove: bool) -> Image.Image:
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Soil mound at the base, drawn behind the sprout.
    draw.ellipse((5, 13, 10, 15), fill=SOIL_MID)
    draw.line((5, 15, 10, 15), fill=SOIL_DARK)
    draw.point((6, 13), fill=SOIL_LIGHT)
    draw.point((9, 14), fill=SOIL_LIGHT)

    # Reuse the original sprout, shifted down so its base sits on the mound.
    for x, y, color in _sprout_pixels():
        if mangrove:
            color = MANGROVE_MAP.get(color[:3], color[:3]) + (255,)
        ny = y + 2
        if ny <= 15:
            img.putpixel((x, ny), color)
    return img


def save(img: Image.Image, name: str) -> None:
    path = PROPS / name
    img.save(path)
    print("wrote", path.relative_to(ROOT))


def main() -> None:
    save(build_ring(), "tree_spot_ring.png")
    save(build_seedling(False), "seedling_tree.png")
    save(build_seedling(True), "seedling_mangrove.png")


if __name__ == "__main__":
    main()
