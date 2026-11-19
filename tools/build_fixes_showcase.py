import os
from PIL import Image, ImageDraw, ImageFont

base_dir = '/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8'

# 1. Pak Nelayan interaction
nelayan_full = Image.open(os.path.join(base_dir, 'verify_nelayan_interaction_fixed.png')).convert('RGB')
w_n, h_n = nelayan_full.size
c_nelayan = nelayan_full.crop((w_n//2 - 240, h_n//2 - 200, w_n//2 + 240, h_n//2 + 200)).resize((380, 320), Image.Resampling.LANCZOS)

# 2. Hulu Tile Hole Fixed
tile_fixed = Image.open(os.path.join(base_dir, 'crop_hulu_pantun_fixed.png')).convert('RGB')
c_tile = tile_fixed.resize((380, 320), Image.Resampling.LANCZOS)

# 3. Tuas 3 Plaza Kota
tuas_full = Image.open(os.path.join(base_dir, 'verify_tuas_3_clean_fixed.png')).convert('RGB')
w_t, h_t = tuas_full.size
c_tuas = tuas_full.crop((w_t//2 - 240, h_t//2 - 200, w_t//2 + 240, h_t//2 + 200)).resize((380, 320), Image.Resampling.LANCZOS)

total_w = 380 * 3 + 50
total_h = 320 + 90
canvas = Image.new('RGB', (total_w, total_h), (22, 24, 30))
draw = ImageDraw.Draw(canvas)

try:
    font_header = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 18)
    font_title = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 14)
except:
    font_header = None
    font_title = None

draw.text((25, 18), "VERIFIKASI PERBAIKAN BUG GAMEPLAY (HILIR, DESA, KOTA, HULU)", fill=(255, 230, 150), font=font_header)

cards = [
    ("1. PAK NELAYAN (HILIR)", "Prompt [Bicara] aktif setelah 8 mangrove", (100, 230, 130), c_nelayan),
    ("2. PAPAN PANTUN (HULU)", "Tile jalan mulus tanpa lubang bolong", (100, 190, 255), c_tile),
    ("3. TUAS 3 (KOTA MEDAN)", "Bebas halangan di plaza depan toko [Tarik]", (255, 200, 100), c_tuas),
]

for idx, (title, desc, color, img) in enumerate(cards):
    x_offset = 18 + idx * (380 + 10)
    y_offset = 65
    canvas.paste(img, (x_offset, y_offset))
    draw.rectangle([x_offset, y_offset, x_offset + 380, y_offset + 320], outline=color, width=2)
    draw.text((x_offset + 10, 42), title, fill=color, font=font_title)

out_showcase = os.path.join(base_dir, 'showcase_6_fixes.png')
canvas.save(out_showcase)
print("Saved showcase_6_fixes.png successfully!")

