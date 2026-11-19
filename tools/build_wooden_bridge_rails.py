#!/usr/bin/env python3
"""
Generate vertical wooden bridge rails for Hilir (and any other vertical wooden bridges):
- bridge_rail_wood_left.png (8x80)
- bridge_rail_wood_right.png (8x80)
Uses the authentic 4-color retro RPG wood palette from bridge_rail_wood.png:
- C_OUTLINE   = (45, 24, 9, 255)
- C_DARK      = (74, 39, 15, 255)
- C_MID       = (122, 72, 32, 255)
- C_LIGHT     = (168, 108, 55, 255)
"""

from PIL import Image

C_OUTLINE = (45, 24, 9, 255)
C_DARK    = (74, 39, 15, 255)
C_MID     = (122, 72, 32, 255)
C_LIGHT   = (168, 108, 55, 255)
C_TRANS   = (0, 0, 0, 0)

def make_vertical_wood_rail(is_left: bool) -> Image.Image:
    w, h = 8, 80
    im = Image.new("RGBA", (w, h), C_TRANS)
    pix = im.load()

    # Vertical post every 16 pixels (at y=0, 16, 32, 48, 64, and end cap at 76..79)
    # Posts are 6px wide (x=1..6), topped with a carved rounded post head.
    # Connecting horizontal/angled wooden rails run along x=2..5.

    # 1. Base rail beams running full vertical length
    for y in range(h):
        if is_left:
            # Left railing: post/outer beam on x=1..3, inner face on x=4..5
            pix[1, y] = C_OUTLINE
            pix[2, y] = C_DARK
            pix[3, y] = C_MID
            pix[4, y] = C_LIGHT
            pix[5, y] = C_OUTLINE
        else:
            # Right railing: inner face on x=2..3, post/outer beam on x=4..6
            pix[2, y] = C_OUTLINE
            pix[3, y] = C_LIGHT
            pix[4, y] = C_MID
            pix[5, y] = C_DARK
            pix[6, y] = C_OUTLINE

    # 2. Prominent wooden posts at intervals (y=0..12, 16..28, 32..44, 48..60, 64..76)
    for py in [0, 16, 32, 48, 64]:
        # Post top cap (rounded 3D post top)
        for y_off in range(3):
            y = py + y_off
            if y < h:
                for x in range(1, 7):
                    if (y_off == 0 and x in (1, 6)):
                        pix[x, y] = C_TRANS
                    elif y_off == 0:
                        pix[x, y] = C_LIGHT
                    else:
                        pix[x, y] = C_LIGHT if x in (2, 3) else (C_MID if x == 4 else C_DARK)
                pix[1, y] = C_OUTLINE
                pix[6, y] = C_OUTLINE

        # Post body (wider 6px beam with timber shading)
        for y_off in range(3, 14):
            y = py + y_off
            if y < h:
                pix[1, y] = C_OUTLINE
                pix[2, y] = C_LIGHT if is_left else C_MID
                pix[3, y] = C_MID
                pix[4, y] = C_MID if is_left else C_DARK
                pix[5, y] = C_DARK
                pix[6, y] = C_OUTLINE

        # Post shadow at base
        if py + 14 < h:
            for x in range(1, 7):
                pix[x, py + 14] = C_OUTLINE

    return im

def main():
    left_im = make_vertical_wood_rail(is_left=True)
    right_im = make_vertical_wood_rail(is_left=False)

    left_im.save("assets/sprites/props/bridge_rail_wood_left.png")
    right_im.save("assets/sprites/props/bridge_rail_wood_right.png")
    print("Saved bridge_rail_wood_left.png and bridge_rail_wood_right.png (8x80)")

if __name__ == "__main__":
    main()

