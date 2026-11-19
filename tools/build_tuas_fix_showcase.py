import os
from PIL import Image, ImageDraw, ImageFont

base_dir = '/home/arisyah/.gemini/antigravity/brain/d1c3a421-8729-49fd-a2ca-5379619e28e8'

# Before: User screenshot showing Tuas 3 stuck behind roof & blocked by collision
before_img = Image.open(os.path.join(base_dir, '.user_uploaded/media_1795069088229_3018a1cd.jpg')).convert('RGB')

# After: In-game verified screenshot showing Tuas 3 in open plaza with [Tarik] prompt and yellow quest arrow
after_img = Image.open(os.path.join(base_dir, 'verify_tuas_3_clean_fixed.png')).convert('RGB')

w, h = 540, 500

# Crop Before: Center on the house and roof where the yellow arrow and lever were
w_b, h_b = before_img.size
c_before = before_img.crop((w_b//2 - 270, h_b//2 - 320, w_b//2 + 270, h_b//2 + 180)).resize((w, h), Image.Resampling.LANCZOS)

# Crop After: Center on player and lever 3
w_a, h_a = after_img.size
# Camera is centered around (864, 380), on 1280x720 screen that's near center
c_after = after_img.crop((640 - 270, 360 - 250, 640 + 270, 360 + 250))

total_w = w * 2 + 50
total_h = h + 110
canvas = Image.new('RGB', (total_w, total_h), (22, 24, 30))
draw = ImageDraw.Draw(canvas)

try:
    font_header = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 18)
    font_title = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 15)
    font_sub = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 12)
except:
    font_header = None
    font_title = None
    font_sub = None

draw.text((25, 18), "PERBAIKAN POSISI & INTERAKSI TUAS 3 (KOTA MEDAN)", fill=(255, 230, 150), font=font_header)

# Left: Before
x_left = 20
y_top = 75
canvas.paste(c_before, (x_left, y_top))
draw.rectangle([x_left, y_top, x_left + w, y_top + h], outline=(255, 80, 80), width=3)
draw.text((x_left + 10, 50), "SEBELUM: Tuas 3 di Belakang Atap (Terkunci Kolisi & Tak Nampak)", fill=(255, 100, 100), font=font_title)

# Right: After
x_right = x_left + w + 15
canvas.paste(c_after, (x_right, y_top))
draw.rectangle([x_right, y_top, x_right + w, y_top + h], outline=(90, 220, 120), width=3)
draw.text((x_right + 10, 50), "SESUDAH: Tuas 3 di Plaza Terbuka Depan Toko (Prompt [Tarik] Aktif)", fill=(100, 230, 130), font=font_title)

out_showcase = os.path.join(base_dir, 'showcase_tuas_3_fix.png')
canvas.save(out_showcase)
print("Saved showcase_tuas_3_fix.png successfully!")

