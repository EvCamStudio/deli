#!/usr/bin/env python3
"""
Hand-crafted authentic retro RPG pixel art generator (v2 - refined)
18x28 cells, 72x112 spritesheets for the 3 main family characters:
  1. player.png (MC)
  2. ibu.png (Bu Mira / Mak)
  3. bapak.png / pak_hendra.png (Pak Hendra)

Strict retro RPG pixel art quality guarantees:
- Preserves original character designs, hairstyles, clothing, colors, proportions, and identities.
- 100% binary alpha (strictly 0 or 255; zero semi-transparent edges/blur).
- Controlled retro color palette (13-15 intentional hue-shifted colors per character).
- Consistent 1px dark outlines, clean pixel clusters, zero AI noise or anti-aliasing.
- Consistent pixel density and cohesive visual style across all 3 characters.
- No top-edge clipping on walk bob frames; smooth 4-frame walk cycles for all 4 directions.
- Outputs ONLY to tools/sprite_cleanup_candidates/ (original assets untouched until approved).
"""

import os
from PIL import Image

OUT_DIR = "tools/sprite_cleanup_candidates"
os.makedirs(OUT_DIR, exist_ok=True)


def hex_rgba(h: str):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


def render_frame(grid, palette):
    assert len(grid) == 28, f"Expected 28 rows, got {len(grid)}"
    im = Image.new("RGBA", (18, 28), (0, 0, 0, 0))
    px = im.load()
    for y, row in enumerate(grid):
        assert len(row) == 18, f"Row {y} expected len 18, got {len(row)}: {row!r}"
        for x, ch in enumerate(row):
            if ch == "." or ch == " ":
                continue
            assert ch in palette, f"Unknown color key {ch!r} at ({x},{y})"
            px[x, y] = palette[ch]
    return im


def mirror_grid(grid):
    return [row[::-1] for row in grid]


def build_sheet(rows_4x4, palette):
    """rows_4x4: [down, left, right, up], each a list of 4 grids."""
    sheet = Image.new("RGBA", (72, 112), (0, 0, 0, 0))
    for r, dir_frames in enumerate(rows_4x4):
        assert len(dir_frames) == 4
        for c, grid in enumerate(dir_frames):
            fr = render_frame(grid, palette)
            sheet.paste(fr, (c * 18, r * 28))
    return sheet


# ==============================================================================
# 1. MC (PLAYER) — Tousled dark charcoal hair with messy bangs, calm eyes,
#    open charcoal zip hoodie over crisp white t-shirt, dark navy-slate pants,
#    clean white/light-gray sneakers.
# ==============================================================================
MC_PAL = {
    "O": hex_rgba("#18131c"),  # Crisp outline & eyes
    "h": hex_rgba("#231e28"),  # Hair shadow
    "H": hex_rgba("#352f3c"),  # Hair base
    "L": hex_rgba("#50485c"),  # Hair highlight
    "s": hex_rgba("#d8a186"),  # Skin shadow
    "S": hex_rgba("#f6cfb5"),  # Skin base
    "j": hex_rgba("#25242d"),  # Hoodie shadow (warm dark charcoal)
    "J": hex_rgba("#3b3a47"),  # Hoodie base
    "K": hex_rgba("#555466"),  # Hoodie highlight (shoulders/hood)
    "w": hex_rgba("#c4c2d1"),  # T-shirt shadow / sneaker shade
    "W": hex_rgba("#f6f4fb"),  # White t-shirt / sneaker bright
    "p": hex_rgba("#1b2130"),  # Pants shadow (cool dark navy-slate)
    "P": hex_rgba("#2c364d"),  # Pants base
}

# Column ruler:
#     012345678901234567
MC_HEAD_DOWN = [
    "..................",  # 0 (breathing room for walk bob!)
    ".....OOOOOOOO.....",  # 1
    "...OOHHHHHHHHOO...",  # 2
    "..OHHHLLLLLLHHHO..",  # 3
    "..OHHLLHHHHLLHHO..",  # 4
    ".OHHHHHHHHHHHHHHO.",  # 5
    ".OHhHHHHHHHHHHhHO.",  # 6
    ".OhOHhHHhhHHhHOhO.",  # 7  <- tousled messy hair silhouette
    "..OOhHhHhhHhHhOO..",  # 8  <- longer cool messy bangs over brow
    "..OOsShSHhhSshOO..",  # 9  <- asymmetric tousled fringe tip!
    "...OSSOSSSSOSSO...",  # 10 <- crisp 1x2 dark eyes (cols 6 & 11)
    "...OSSOSSSSOSSO...",  # 11
    "...OSsSSSSSSsSO...",  # 12 <- clean peach cheeks
    "....OOsSSSSsOO....",  # 13
    ".....OOssssOO.....",  # 14
]

MC_DOWN_0 = MC_HEAD_DOWN + [
    "....OOKJWWJKOO....",  # 15 hoodie collar + crisp 2px white tee
    "...OJJjJWWJjJJO...",  # 16
    "...OJJjJWWJjJJO...",  # 17
    "...OJjjJWWJjjJO...",  # 18
    "...OSOjJwwJjOSO...",  # 19 hands at cuffs
    "...OOOjOwwOjOOO...",  # 20 distinct dark hoodie hem separating pants!
    "....OOPPppPPOO....",  # 21 cool navy-slate pants
    "....OPPPppPPPO....",  # 22
    "....OPPPppPPPO....",  # 23
    "....OPPpOOppPO....",  # 24
    "....OppO..OppO....",  # 25
    "....OWwO..OwWO....",  # 26 clean white sneakers with subtle shade
    ".....OO....OO.....",  # 27
]

MC_DOWN_1 = MC_HEAD_DOWN[1:] + [
    "....OOKJWWJKOO....",  # 14 (bobbed up 1px cleanly into row 0!)
    "...OJJjJWWJjJJO...",  # 15
    "...OJJjJWWJjJJO...",  # 16
    "...OSjjJWWJjJJO...",  # 17 left arm forward
    "...OOOjJwwJjjSO...",  # 18 right arm back
    "....OOjOwwOjOOO...",  # 19
    "....OOPPppPPOO....",  # 20
    "....OPPPppPPPO....",  # 21
    "....OPPPppPPPO....",  # 22
    "....OPPpOOppPO....",  # 23
    "....OPpO..OppO....",  # 24
    "....OppO..OWwO....",  # 25 right foot lifted back
    "....OWwO...OO.....",  # 26 left foot planted forward
    ".....OO...........",  # 27
]

MC_DOWN_3 = MC_HEAD_DOWN[1:] + [
    "....OOKJWWJKOO....",  # 14
    "...OJJjJWWJjJJO...",  # 15
    "...OJJjJWWJjJJO...",  # 16
    "...OJJjJWWJjjSO...",  # 17 right arm forward
    "...OSjjJwwJjOOO...",  # 18 left arm back
    "...OOOjOwwOjOO....",  # 19
    "....OOPPppPPOO....",  # 20
    "....OPPPppPPPO....",  # 21
    "....OPPPppPPPO....",  # 22
    "....OPPpOOppPO....",  # 23
    "....OppO..OpPO....",  # 24
    "....OwWO..OppO....",  # 25 left foot lifted back
    ".....OO...OwWO....",  # 26 right foot planted forward
    "...........OO.....",  # 27
]

# MC LEFT (clean upright back, crisp profile!)
#     012345678901234567
MC_HEAD_LEFT = [
    "..................",  # 0
    ".....OOOOOOOO.....",  # 1
    "...OOHHHHHHHHOO...",  # 2
    "..OHHHLLLLLLHHHO..",  # 3
    "..OHHLLHHHHLLHHO..",  # 4
    ".OHHHHHHHHHHHHHHO.",  # 5
    ".OHhHHHHHHHHHHhHO.",  # 6
    ".OhOHhHHHHHHHHhHO.",  # 7
    "..OOshHHHHHHHHhO..",  # 8
    "...OsShHHHHHHHhO..",  # 9
    "...OSOSsShHHHHHO..",  # 10 <- crisp eye (col 5)
    "...OSSOSssHHHHHO..",  # 11
    "...OSSSSsOhHHhO...",  # 12
    "....OOsSSsOOOO....",  # 13
    ".....OOsssOO......",  # 14
]

MC_LEFT_0 = MC_HEAD_LEFT + [
    ".....OOWKJJOO.....",  # 15 crisp upright hoodie silhouette
    ".....OWJJKJJO.....",  # 16
    ".....OWJJjJJO.....",  # 17
    ".....OWJJjJJO.....",  # 18
    ".....OwJJSOjO.....",  # 19 hand at side
    ".....OOjjjOO......",  # 20 clean hem
    ".....OOPPPPO......",  # 21 pants
    ".....OPPPPPO......",  # 22
    ".....OPPPpPO......",  # 23
    ".....OPPpPPO......",  # 24
    ".....OppppO.......",  # 25
    "....OWWWwWO.......",  # 26 sneaker facing left
    ".....OOOOO........",  # 27
]

MC_LEFT_1 = MC_HEAD_LEFT[1:] + [
    ".....OOWKJJOO.....",  # 14
    ".....OWJJKJJO.....",  # 15
    "....OWJJjJJJO.....",  # 16 arm swinging forward
    "....OWJJSJjJO.....",  # 17
    ".....OOjjjJO......",  # 18
    ".....OOPPPPO......",  # 19
    ".....OPPPPPO......",  # 20
    "....OPPPpPPPO.....",  # 21
    "....OPPPpPPPO.....",  # 22
    "....OPPpOOpPO.....",  # 23
    "...OPpO...OppO....",  # 24
    "...OppO...OWwO....",  # 25
    "...OWwO....OO.....",  # 26
    "....OO............",  # 27
]

MC_LEFT_3 = MC_HEAD_LEFT[1:] + [
    ".....OOWKJJOO.....",  # 14
    ".....OWJJKJJO.....",  # 15
    ".....OWJJjJJJO....",  # 16 arm swinging back
    ".....OWJJjJJSO....",  # 17
    ".....OOjjjJOO.....",  # 18
    ".....OOPPPPO......",  # 19
    ".....OPPPPPO......",  # 20
    "....OPPPpPPPO.....",  # 21
    "....OPPPpPPPO.....",  # 22
    "....OPpOOOpPO.....",  # 23
    "....OppO..OpPO....",  # 24
    "...OWwO...OppO....",  # 25
    "....OO....OWwO....",  # 26
    "...........OO.....",  # 27
]

# MC UP (facing back — draped hood detail on upper back!)
MC_HEAD_UP = [
    "..................",  # 0
    ".....OOOOOOOO.....",  # 1
    "...OOHHHHHHHHOO...",  # 2
    "..OHHHLLLLLLHHHO..",  # 3
    "..OHHLLHHHHLLHHO..",  # 4
    ".OHHHHHHHHHHHHHHO.",  # 5
    ".OHHHHHHHHHHHHHHO.",  # 6
    ".OHhHHHHHHHHHHhHO.",  # 7
    "..OHhHHHHHHHHhHO..",  # 8
    "..OHhhHHHHHHhhHO..",  # 9
    "...OHhhhhhhhhHO...",  # 10
    "...OOhhhhhhhhOO...",  # 11
    "....OOOhhhhOOO....",  # 12
    "....OOKKKKKKOO....",  # 13 hood collar
    "...OJKjjjjjjKJO...",  # 14 draped hood fold!
]

MC_UP_0 = MC_HEAD_UP + [
    "...OJJjKKKKjJJO...",  # 15 back of hood tip
    "...OJJJjjjjJJJO...",  # 16
    "...OJJJJJJJJJJO...",  # 17
    "...OJjjJJJJjjJO...",  # 18
    "...OSOjJJJJjOSO...",  # 19
    "...OOOjOjjOjOOO...",  # 20
    "....OOPPppPPOO....",  # 21
    "....OPPPppPPPO....",  # 22
    "....OPPPppPPPO....",  # 23
    "....OPPpOOppPO....",  # 24
    "....OppO..OppO....",  # 25
    "....OWwO..OwWO....",  # 26
    ".....OO....OO.....",  # 27
]

MC_UP_1 = MC_HEAD_UP[1:] + [
    "...OJJjKKKKjJJO...",  # 14
    "...OJJJjjjjJJJO...",  # 15
    "...OJJJJJJJJJJO...",  # 16
    "...OSjjJJJJjJJO...",  # 17
    "...OOOjJJJJjjSO...",  # 18
    "....OOjOjjOjOOO...",  # 19
    "....OOPPppPPOO....",  # 20
    "....OPPPppPPPO....",  # 21
    "....OPPPppPPPO....",  # 22
    "....OPPpOOppPO....",  # 23
    "....OPpO..OppO....",  # 24
    "....OppO..OWwO....",  # 25
    "....OWwO...OO.....",  # 26
    ".....OO...........",  # 27
]

MC_UP_3 = mirror_grid(MC_UP_1)

MC_ROWS = [
    [MC_DOWN_0, MC_DOWN_1, MC_DOWN_0, MC_DOWN_3],
    [MC_LEFT_0, MC_LEFT_1, MC_LEFT_0, MC_LEFT_3],
    [mirror_grid(MC_LEFT_0), mirror_grid(MC_LEFT_1), mirror_grid(MC_LEFT_0), mirror_grid(MC_LEFT_3)],
    [MC_UP_0, MC_UP_1, MC_UP_0, MC_UP_3],
]


# ==============================================================================
# 2. IBU / BU MIRA — Dark brown softly side-parted hair with low back bun,
#    warm eyes, lavender/purple blouse with collar, cream/beige apron,
#    dark brown skirt (continuous hem, not pants!), neat dark shoes.
# ==============================================================================
IBU_PAL = {
    "O": hex_rgba("#1c1418"),  # Warm dark outline & eyes
    "h": hex_rgba("#2f2226"),  # Hair shadow
    "H": hex_rgba("#48363c"),  # Hair base
    "L": hex_rgba("#685058"),  # Hair highlight
    "s": hex_rgba("#d99e82"),  # Skin shadow / gentle blush
    "S": hex_rgba("#f5cbb0"),  # Skin base
    "b": hex_rgba("#6d567a"),  # Purple blouse shadow
    "B": hex_rgba("#987ca8"),  # Purple blouse base
    "C": hex_rgba("#c1a7d1"),  # Blouse highlight / collar
    "a": hex_rgba("#b59a80"),  # Apron shadow / ties / fold
    "A": hex_rgba("#dfc9b1"),  # Apron base (warm beige)
    "W": hex_rgba("#f6ecdc"),  # Apron highlight (warm cream)
    "k": hex_rgba("#35262a"),  # Skirt shadow & shoes
    "K": hex_rgba("#523d42"),  # Skirt base (warm dark brown)
}

#     012345678901234567
IBU_HEAD_DOWN = [
    "..................",  # 0
    ".....OOOOOOOO.....",  # 1
    "...OOHHHHHHHHOO...",  # 2
    "..OHHHLLLLLLHHHO..",  # 3
    "..OHHLLHHHHLLHHO..",  # 4
    ".OHHHHHHHHHHHHHHO.",  # 5
    ".OHHHHHHhHHHHHHHO.",  # 6  <- gentle natural side-part!
    ".OHhHHhSSsHHHhHHO.",  # 7  <- sweeping warm bangs (faithful to Bu Mira!)
    ".OHhHssSSSSssHhHO.",  # 8
    ".OhHOSSSSSSSSOHhO.",  # 9
    ".OhOSSOSSSSOSSOO..",  # 10 <- subtle low bun peeking on left + crisp eyes (6 & 11)
    "..OOSSOSSSSOSSO...",  # 11
    "...OSsSSSSSSsSO...",  # 12 <- gentle warm cheeks
    "....OOsSSSSsOO....",  # 13
    ".....OOssssOO.....",  # 14
]

IBU_DOWN_0 = IBU_HEAD_DOWN + [
    "....OOBCWWCBOO....",  # 15 lavender collar + cream apron bib
    "...OBBbAWWAbBBO...",  # 16 purple sleeves + apron straps
    "...OBBbAWWAbBBO...",  # 17
    "...OBbbAWWAbbBO...",  # 18
    "...OSObAAAAbOSO...",  # 19 hands at cuffs + apron waist
    "...OOOaWWWWaOOO...",  # 20 apron skirt top
    "....OKaWWWWaKO....",  # 21 dark brown skirt + bright cream apron
    "....OKaWWWWaKO....",  # 22
    "....OKaAAAAaKO....",  # 23 apron hem
    "....OKKKKKKKKO....",  # 24 continuous skirt hem!
    "....OkkkkkkkkO....",  # 25
    "....OkkO..OkkO....",  # 26 neat dark shoes peeking below skirt
    ".....OO....OO.....",  # 27
]

IBU_DOWN_1 = IBU_HEAD_DOWN[1:] + [
    "....OOBCWWCBOO....",  # 14
    "...OBBbAWWAbBBO...",  # 15
    "...OBBbAWWAbBBO...",  # 16
    "...OSbbAWWAbBBO...",  # 17 left arm forward
    "...OOObAAAAbbSO...",  # 18 right arm back
    "....OOaWWWWaOOO...",  # 19
    "....OKaWWWWaKO....",  # 20
    "....OKaWWWWaKO....",  # 21
    "....OKaAAAAaKO....",  # 22
    "....OKKKKKKKKO....",  # 23
    "....OkkkkkkkkO....",  # 24
    "....OkkO..OkkO....",  # 25 right shoe lifted
    "....OkkO...OO.....",  # 26 left shoe planted
    ".....OO...........",  # 27
]

IBU_DOWN_3 = mirror_grid(IBU_DOWN_1)

# IBU LEFT (clean tucked back silhouette — NO stray purple bulge — rounded low bun!)
#     012345678901234567
IBU_HEAD_LEFT = [
    "..................",  # 0
    "....OOOOOOOO......",  # 1
    "..OOHHHHHHHHOO....",  # 2
    ".OHHHLLLLLLHHHO...",  # 3
    ".OHHLLHHHHLLHHO...",  # 4
    ".OHHHHHHHHHHHHHO..",  # 5
    ".OHhHHHHHHHHHHhO..",  # 6
    ".OhOshHHHHHHHHhO..",  # 7
    "..OsSShHHHHHHHhOO.",  # 8  <- bun begins gracefully at nape
    "..OSSShHHHHHHhLHHO",  # 9  <- unmistakable classic low bun
    "..OSOSsShHHHHhHHHO",  # 10 <- crisp eye at col 4
    "..OSSOSssHHHHhhHHO",  # 11
    "..OSSSSsOhHHHhhOO.",  # 12
    "...OOsSSsOOOOOO...",  # 13
    "....OOsssOO.......",  # 14
]

IBU_LEFT_0 = IBU_HEAD_LEFT + [
    "....OOCBBBOO......",  # 15 clean straight back (col 11)
    "....OWABBBBBO.....",  # 16 cream apron front + lavender sleeve
    "....OWABBCBbO.....",  # 17
    "....OWABBBbbO.....",  # 18
    "....OaABBSObO.....",  # 19 hand at side
    "....OAWWWaOO......",  # 20 apron waist tie
    "....OAWWWaKKO.....",  # 21 apron front + dark skirt back
    "....OAWWWaKKO.....",  # 22
    "....OAAAAaKKO.....",  # 23
    "....OKKKKKkkO.....",  # 24 continuous skirt hem
    ".....OkkkkkO......",  # 25
    "....OkkkkkO.......",  # 26 shoes facing left
    ".....OOOOO........",  # 27
]

IBU_LEFT_1 = IBU_HEAD_LEFT[1:] + [
    "....OOCBBBOO......",  # 14
    "....OWABBBBBO.....",  # 15
    "...OWABBBCBbO.....",  # 16 arm forward
    "...OWABBSBbbO.....",  # 17
    "....OAWWWbbO......",  # 18
    "....OAWWWaOO......",  # 19
    "....OAWWWaKKO.....",  # 20
    "....OAWWWaKKO.....",  # 21
    "...OAAAAaKKKO.....",  # 22 skirt sways naturally
    "...OKKKKKkkkO.....",  # 23
    "...OkkkkkkkO......",  # 24
    "...OkkO..OkkO.....",  # 25 back foot lifted
    "...OkkO...OO......",  # 26 front foot planted
    "....OO............",  # 27
]

IBU_LEFT_3 = IBU_HEAD_LEFT[1:] + [
    "....OOCBBBOO......",  # 14
    "....OWABBBBBO.....",  # 15
    "....OWABBCBBBO....",  # 16 arm back
    "....OWABBBBBbSO...",  # 17
    "....OAWWWbbBOO....",  # 18
    "....OAWWWaOO......",  # 19
    "....OAWWWaKKO.....",  # 20
    "....OAWWWaKKO.....",  # 21
    "...OAAAAaKKKO.....",  # 22
    "...OKKKKKkkkO.....",  # 23
    "...OkkkkkkkO......",  # 24
    "...OkkO..OkkO.....",  # 25
    "....OO...OkkO.....",  # 26
    "..........OO......",  # 27
]

# IBU UP (soft sculpted round back bun without boxy inner outline + continuous skirt!)
IBU_HEAD_UP = [
    "..................",  # 0
    ".....OOOOOOOO.....",  # 1
    "...OOHHHHHHHHOO...",  # 2
    "..OHHHLLLLLLHHHO..",  # 3
    "..OHHLLHHHHLLHHO..",  # 4
    ".OHHHHHHHHHHHHHHO.",  # 5
    ".OHHHHHHHHHHHHHHO.",  # 6
    ".OHhHHHHHHHHHHhHO.",  # 7
    "..OHhHLLLLLLHhHO..",  # 8  <- softly sculpted round bun highlight!
    "..OHhhHHHHHHhhHO..",  # 9
    "...OhHhHHHHhHhO...",  # 10
    "...OOhhhhhhhhOO...",  # 11
    "....OOOhhhhOOO....",  # 12
    ".....OOOOOOOO.....",  # 13
    "....OOBCCCBOO.....",  # 14 lavender collar back
]

IBU_UP_0 = IBU_HEAD_UP + [
    "...OBBBCCCCBBBO...",  # 15
    "...OBBBBBBBBBBO...",  # 16
    "...OBBBBBBBBBBO...",  # 17
    "...OBbbBBBBbbBO...",  # 18
    "...OSObAWWAbOSO...",  # 19 cream apron bow tied at back!
    "...OOOaAAAAaOOO...",  # 20
    "....OKKKKKKKKO....",  # 21 continuous dark brown skirt back!
    "....OKKKKKKKKO....",  # 22
    "....OKKKKKKKKO....",  # 23
    "....OKKkkkkKKO....",  # 24
    "....OkkkkkkkkO....",  # 25
    "....OkkO..OkkO....",  # 26
    ".....OO....OO.....",  # 27
]

IBU_UP_1 = IBU_HEAD_UP[1:] + [
    "...OBBBCCCCBBBO...",  # 14
    "...OBBBBBBBBBBO...",  # 15
    "...OBBBBBBBBBBO...",  # 16
    "...OSbbBBBBbBBO...",  # 17
    "...OOObAWWAbbSO...",  # 18
    "....OOaAAAAaOOO...",  # 19
    "....OKKKKKKKKO....",  # 20
    "....OKKKKKKKKO....",  # 21
    "....OKKKKKKKKO....",  # 22
    "....OKKkkkkKKO....",  # 23
    "....OkkkkkkkkO....",  # 24
    "....OkkO..OkkO....",  # 25
    "....OkkO...OO.....",  # 26
    ".....OO...........",  # 27
]

IBU_UP_3 = mirror_grid(IBU_UP_1)

IBU_ROWS = [
    [IBU_DOWN_0, IBU_DOWN_1, IBU_DOWN_0, IBU_DOWN_3],
    [IBU_LEFT_0, IBU_LEFT_1, IBU_LEFT_0, IBU_LEFT_3],
    [mirror_grid(IBU_LEFT_0), mirror_grid(IBU_LEFT_1), mirror_grid(IBU_LEFT_0), mirror_grid(IBU_LEFT_3)],
    [IBU_UP_0, IBU_UP_1, IBU_UP_0, IBU_UP_3],
]


# ==============================================================================
# 3. BAPAK / PAK HENDRA — Tousled center-parted warm dark brown hair, sleek dark
#    rectangular glasses (NO bright white bug eyes!), crisp 1px mustache + small
#    separated goatee, khaki collared button shirt, dark belt + silver buckle,
#    dark brown slacks & shoes.
#    Starts at row 1 (leaving row 0 free so walk bob NEVER clips top outline!).
# ==============================================================================
BAPAK_PAL = {
    "O": hex_rgba("#1b141a"),  # Warm dark outline & eyes
    "h": hex_rgba("#2f2229"),  # Hair shadow, glasses rim, mustache/goatee
    "H": hex_rgba("#4a3840"),  # Hair base (rich warm dark brown)
    "L": hex_rgba("#6b535e"),  # Hair highlight
    "s": hex_rgba("#d2977a"),  # Skin shadow
    "S": hex_rgba("#f3c6a7"),  # Skin base (warm tan)
    "g": hex_rgba("#d6cbc8"),  # Subtle soft warm-gray lens tint (never garish white!)
    "c": hex_rgba("#ae9279"),  # Khaki shirt shadow / collar / pocket
    "C": hex_rgba("#d8bfa5"),  # Khaki shirt base
    "K": hex_rgba("#f0e1cd"),  # Khaki shirt highlight
    "t": hex_rgba("#261f25"),  # Dark belt & leather shoes
    "T": hex_rgba("#c2c9d4"),  # Silver belt buckle
    "p": hex_rgba("#32272d"),  # Slacks shadow
    "P": hex_rgba("#4d3d45"),  # Slacks base
}

# Column ruler:
#     012345678901234567
BAPAK_HEAD_DOWN = [
    "..................",  # 0 (breathing room for walk bob — ZERO clipping!)
    ".....OOOOOOOO.....",  # 1
    "...OOHHHHHHHHOO...",  # 2
    "..OHHHLLLLLLHHHO..",  # 3
    "..OHHLLHHHHLLHHO..",  # 4
    ".OHHHHHHHHHHHHHHO.",  # 5
    ".OHhHHHHssHHHHhHO.",  # 6  <- signature middle-parted curtain hair!
    ".OhOHhHSSSShHHOhO.",  # 7  <- clean forehead parting!
    "..OOhsSSSSSSshOO..",  # 8
    "...OhgOhhhOgshO...",  # 9  <- wait check exact symmetry!
]
# Let's craft Bapak's face (cols 4..13, outline at 3 & 14) with 100% symmetry:
# idx: 012345678901234567
# r8 : ..OOsSSSSSSSSsOO..  (clean brow)
# r9 : ...OhOgShhgOhO...  -> count!
#   col 3=O, 4=h(temple), 5=g(outer lens), 6=O(eye), 7=h(inner rim), 8=h(bridge), 9=h(bridge), 10=h(inner rim), 11=O(eye), 12=g(outer lens), 13=h(temple), 14=O -> len=18!
#   Wait: let's make eye slightly more open & kind:
#   col 4=h(temple), 5=O(eye), 6=g(soft lens), 7=S? No, inner rim should frame the lens!
#   Even better & SUPER handsome in classic RPG pixel art:
#   r9 : ...OhgOShhSOghO...  (4=h temple, 5=g soft lens, 6=O eye, 7=S/g? Wait: 6=O, 7=S leaves bridge 8,9=h!)
#   Wait: let's check both rows 9 and 10:
#   r9 : ...OhgOghhgOghO... -> 4=h, 5=g, 6=O, 7=g, 8=h, 9=h, 10=g, 11=O, 12=g, 13=h (len=18!)
#   r10: ...OSOhOSSOhOSO... -> wait: 3=O, 4=S, 5=O? Better: soft `s` or `h` bottom rim ONLY under eye:
#   r10: ...OShOSSSSOhSO... -> 3=O, 4=S, 5=h, 6=O, 7=S, 8=S, 9=S, 10=S, 11=O, 12=h, 13=S, 14=O (len=18!)
#   Look at r9 + r10:
#   - Eyes are 1x2 crisp dark `O` at cols 6 & 11 (exact same friendly eye placement as MC & Ibu!)
#   - Soft warm-gray lens tint `g` sits delicately on row 9 around the eyes, connected by a thin 2px dark bridge `hh` at 8,9 and side temples `h` at 4,13!
#   - Below eyes (r11): `...OSSSSSSSSSSO...` (clean nose & warm cheeks!)
#   - Mustache (r12): `...OSSshhhhssSO...`? Wait: make it clean & centered!
#     `...OSSSHHHHSSSO...` (cols 7,8,9,10 = warm brown `H`, NOT stark black — reads immediately as a neat trimmed mustache!)
#   - Clean chin skin + tiny 2px goatee on r13:
#     `....OOsShhSsOO....` (wait: if H is right above h with no skin gap, they connect slightly like a circle beard; let's check original Bapak! In original Bapak, he has a mustache, 1px peach mouth/lip gap, and a small goatee right on his chin! With 1px skin gap or placing mustache on r11 and goatee on r13? Let's check!)
#     r9 : glasses top + upper eyes
#     r10: lower eyes (clean cheeks!)
#     r11: clean cheeks + neat 4px mustache (`H` at 7..10) -> Wait: r11 is directly below eyes, let's keep 1px nose/cheek gap!
#     Actually: shift eyes up 1px to r8..r9! Let's check:
#     r1..r6: hair (6px tall crown — exact same fullness!)
#     r7: parted forehead (`..OOhsSSSSSSshOO..`)
#     r8: glasses + upper eyes (`...OhgOghhgOghO...`)
#     r9: lower eyes (`...OShOSSSSOhSO...`)
#     r10: clean nose & cheeks (`...OSSSSSSSSSSO...`)
#     r11: neat brown mustache (`...OSSShhhhSSSO...` -> cols 7..10 in `H`!)
#     r12: clean lower lip / peach skin (`...OSSSSSSSSSSO...`)
#     r13: neat small goatee on chin (`....OOsSHHsOO.....` -> `....OOsSHHSsOO....`, len 18!)
#     r14: neck (`.....OOssssOO.....`)
# OH!! THAT GIVES A CLEAN 1px SKIN GAP BETWEEN MUSTACHE (r11) AND GOATEE (r13)!!
# That will look SO HANDSOME, WARM, AND 100% RECOGNIZABLE AS PAK HENDRA!!

BAPAK_HEAD_DOWN = [
    "..................",  # 0 (safe bob room!)
    ".....OOOOOOOO.....",  # 1
    "...OOHHHHHHHHOO...",  # 2
    "..OHHHLLLLLLHHHO..",  # 3
    "..OHHLLHHHHLLHHO..",  # 4
    ".OHHHHHHHHHHHHHHO.",  # 5
    ".OHhHHHssSSHHHhHO.",  # 6  <- fluffy curtain-parted hair crown!
    ".OhOHhHsSSsHhHOhO.",  # 7  <- parted bangs framing forehead cleanly!
    "..OhHgOghhgOgHhO..",  # 8  <- side locks frame glasses temples!
    "..OOSsOSSSSOsSOO..",  # 9  <- clean lower eyes (friendly & natural!)
    "...OSSSSSSSSSSO...",  # 10 <- clean nose & cheeks
    "...OSSSHHHHSSSO...",  # 11 <- neat warm-brown mustache (cols 7..10)
    "...OSsSSSSSSsSO...",  # 12 <- clean 1px skin gap below mustache!
    "....OOsSHHSsOO....",  # 13 <- neat small goatee on chin (cols 8..9)!
    ".....OOssssOO.....",  # 14 <- neck
]

BAPAK_DOWN_0 = BAPAK_HEAD_DOWN + [
    "....OOKcSScKOO....",  # 15 khaki shirt open collar
    "...OCCCKccKCCCO...",  # 16 short-sleeve button-up shirt
    "...OCCCcKKcCCCO...",  # 17 center placket + chest pocket hint
    "...OSCcCKKcCcSO...",  # 18 bare forearms below short sleeves
    "...OSOcCCCCcOSO...",  # 19 hands at sides
    "...OOOttTTttOOO...",  # 20 dark belt + crisp silver buckle!
    "....OOPPppPPOO....",  # 21 dark brown slacks
    "....OPPPppPPPO....",  # 22
    "....OPPPppPPPO....",  # 23
    "....OPPpOOppPO....",  # 24
    "....OppO..OppO....",  # 25
    "....OttO..OttO....",  # 26 dark brown leather shoes
    ".....OO....OO.....",  # 27
]

BAPAK_DOWN_1 = BAPAK_HEAD_DOWN[1:] + [
    "....OOKcSScKOO....",  # 14 (bobs up 1px cleanly into row 0!)
    "...OCCCKccKCCCO...",  # 15
    "...OCCCcKKcCCCO...",  # 16
    "...OSCcCKKcCCCO...",  # 17 left arm forward
    "...OOOcCCCCcCSO...",  # 18 right arm back
    "....OOttTTttOOO...",  # 19
    "....OOPPppPPOO....",  # 20
    "....OPPPppPPPO....",  # 21
    "....OPPPppPPPO....",  # 22
    "....OPPpOOppPO....",  # 23
    "....OPpO..OppO....",  # 24
    "....OppO..OttO....",  # 25
    "....OttO...OO.....",  # 26
    ".....OO...........",  # 27
]

BAPAK_DOWN_3 = mirror_grid(BAPAK_DOWN_1)

# BAPAK LEFT (clean sleek profile glasses + mustache + short-sleeve khaki shirt!)
#     012345678901234567
BAPAK_HEAD_LEFT = [
    "..................",  # 0
    ".....OOOOOOOO.....",  # 1
    "...OOHHHHHHHHOO...",  # 2
    "..OHHHLLLLLLHHHO..",  # 3
    "..OHHLLHHHHLLHHO..",  # 4
    ".OHHHHHHHHHHHHHHO.",  # 5
    ".OhOHhHHHHHHHHhHO.",  # 6
    "..OOshHHHHHHHHhO..",  # 7
    "...OgOghhHHHHHhO..",  # 8  <- sleek profile glasses + dark temple arm!
    "...OsOSssHHHHHHO..",  # 9  <- eye + warm cheek
    "...OSSSSsOhHHhO...",  # 10 <- clean nose & ear
    "...OHsSSSsOOOO....",  # 11 <- neat profile mustache under nose
    "...OSSsSSsOO......",  # 12 <- clean skin gap
    "....OOHSSsOO......",  # 13 <- tiny chin goatee
    ".....OOsssOO......",  # 14
]

BAPAK_LEFT_0 = BAPAK_HEAD_LEFT + [
    ".....OOKCCCOO.....",  # 15 khaki collar
    ".....OCCKCCCO.....",  # 16 short sleeve
    ".....OCCCKCcO.....",  # 17
    ".....OCCCSOcO.....",  # 18 bare forearm
    ".....OcCCSOcO.....",  # 19 hand
    ".....OTttttO......",  # 20 belt + buckle at front
    ".....OOPPPPO......",  # 21 slacks
    ".....OPPPPPO......",  # 22
    ".....OPPPpPO......",  # 23
    ".....OPPpPPO......",  # 24
    ".....OppppO.......",  # 25
    "....OtttttO.......",  # 26 dark shoe facing left
    ".....OOOOO........",  # 27
]

BAPAK_LEFT_1 = BAPAK_HEAD_LEFT[1:] + [
    ".....OOKCCCOO.....",  # 14
    ".....OCCKCCCO.....",  # 15
    "....OCCCCKCcO.....",  # 16 arm forward
    "....OCCCcSOcO.....",  # 17
    ".....OcCCcOO......",  # 18
    ".....OTttttO......",  # 19
    ".....OOPPPPO......",  # 20
    ".....OPPPPPO......",  # 21
    "....OPPPpPPPO.....",  # 22 legs striding
    "....OPPpOOpPO.....",  # 23
    "...OPpO...OppO....",  # 24
    "...OppO...OttO....",  # 25
    "...OttO....OO.....",  # 26
    "....OO............",  # 27
]

BAPAK_LEFT_3 = BAPAK_HEAD_LEFT[1:] + [
    ".....OOKCCCOO.....",  # 14
    ".....OCCKCCCO.....",  # 15
    ".....OCCCKCCCO....",  # 16 arm back
    ".....OCCCCcCSO....",  # 17
    ".....OcCCCCOO.....",  # 18
    ".....OTttttO......",  # 19
    ".....OOPPPPO......",  # 20
    ".....OPPPPPO......",  # 21
    "....OPPPpPPPO.....",  # 22
    "....OPpOOOpPO.....",  # 23
    "....OppO..OpPO....",  # 24
    "...OttO...OppO....",  # 25
    "....OO....OttO....",  # 26
    "...........OO.....",  # 27
]

# BAPAK UP (hair covers nape nicely down to khaki collar — matches original!)
BAPAK_HEAD_UP = [
    "..................",  # 0
    ".....OOOOOOOO.....",  # 1
    "...OOHHHHHHHHOO...",  # 2
    "..OHHHLLLLLLHHHO..",  # 3
    "..OHHLLHHHHLLHHO..",  # 4
    ".OHHHHHHHHHHHHHHO.",  # 5
    ".OHHHHHHHHHHHHHHO.",  # 6
    ".OHhHHHHHHHHHHhHO.",  # 7
    "..OHhHHHHHHHHhHO..",  # 8
    "..OHhhHHHHHHhhHO..",  # 9
    "...OHhhhhhhhhHO...",  # 10
    "...OOhhhhhhhhOO...",  # 11
    "....OOOhhhhOOO....",  # 12 <- hair neatly tapers to nape
    "....OOKKKKKKOO....",  # 13 <- khaki shirt collar back
    "...OCCCCCCCCCCO...",  # 14 <- shoulders
]

BAPAK_UP_0 = BAPAK_HEAD_UP + [
    "...OCCKKKKKKCCO...",  # 15
    "...OCCCCCCCCCCO...",  # 16
    "...OCcCCCCCCcCO...",  # 17
    "...OScCCCCCCcSO...",  # 18 bare forearms below short sleeves
    "...OSOcCCCCcOSO...",  # 19
    "...OOOttttttOOO...",  # 20 belt back
    "....OOPPppPPOO....",  # 21
    "....OPPPppPPPO....",  # 22
    "....OPPPppPPPO....",  # 23
    "....OPPpOOppPO....",  # 24
    "....OppO..OppO....",  # 25
    "....OttO..OttO....",  # 26
    ".....OO....OO.....",  # 27
]

BAPAK_UP_1 = BAPAK_HEAD_UP[1:] + [
    "...OCCKKKKKKCCO...",  # 14
    "...OCCCCCCCCCCO...",  # 15
    "...OCcCCCCCCcCO...",  # 16
    "...OScCCCCCCcCO...",  # 17
    "...OOOcCCCCccSO...",  # 18
    "....OOttttttOOO...",  # 19
    "....OOPPppPPOO....",  # 20
    "....OPPPppPPPO....",  # 21
    "....OPPPppPPPO....",  # 22
    "....OPPpOOppPO....",  # 23
    "....OPpO..OppO....",  # 24
    "....OppO..OttO....",  # 25
    "....OttO...OO.....",  # 26
    ".....OO...........",  # 27
]

BAPAK_UP_3 = mirror_grid(BAPAK_UP_1)

BAPAK_ROWS = [
    [BAPAK_DOWN_0, BAPAK_DOWN_1, BAPAK_DOWN_0, BAPAK_DOWN_3],
    [BAPAK_LEFT_0, BAPAK_LEFT_1, BAPAK_LEFT_0, BAPAK_LEFT_3],
    [mirror_grid(BAPAK_LEFT_0), mirror_grid(BAPAK_LEFT_1), mirror_grid(BAPAK_LEFT_0), mirror_grid(BAPAK_LEFT_3)],
    [BAPAK_UP_0, BAPAK_UP_1, BAPAK_UP_0, BAPAK_UP_3],
]


def verify_sprite(name, im):
    assert im.size == (72, 112), f"{name}: bad size {im.size}"
    pixels = list(im.getdata())
    opaque = [p for p in pixels if p[3] > 0]
    semi = [p for p in pixels if 0 < p[3] < 255]
    unique_rgb = set(p[:3] for p in opaque)
    assert len(semi) == 0, f"{name}: found {len(semi)} semi-transparent pixels!"
    assert len(unique_rgb) <= 16, f"{name}: too many colors ({len(unique_rgb)})!"
    print(f"[PASS] {name:16s} | size={im.size} | colors={len(unique_rgb):2d} | semi_alpha=0 | opaque_px={len(opaque)}")


def main():
    mc_sheet = build_sheet(MC_ROWS, MC_PAL)
    ibu_sheet = build_sheet(IBU_ROWS, IBU_PAL)
    bapak_sheet = build_sheet(BAPAK_ROWS, BAPAK_PAL)

    verify_sprite("player.png", mc_sheet)
    verify_sprite("ibu.png", ibu_sheet)
    verify_sprite("bapak.png", bapak_sheet)

    mc_sheet.save(os.path.join(OUT_DIR, "player.png"))
    ibu_sheet.save(os.path.join(OUT_DIR, "ibu.png"))
    bapak_sheet.save(os.path.join(OUT_DIR, "bapak.png"))
    bapak_sheet.save(os.path.join(OUT_DIR, "pak_hendra.png"))
    print("Saved all v2 candidate sprites to", OUT_DIR)


if __name__ == "__main__":
    main()
