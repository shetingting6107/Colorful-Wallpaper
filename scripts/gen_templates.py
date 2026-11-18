# -*- coding: utf-8 -*-
"""Render 6 wallpaper template mockups (1170x2532) + a contact sheet."""
import os
import numpy as np
from PIL import Image, ImageFilter, ImageDraw, ImageFont
from matplotlib import font_manager

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "data", "templates")
os.makedirs(OUT, exist_ok=True)

W, H = 1170, 2532
rng = np.random.default_rng(42)


def rgb(hex_color):
    h = hex_color.lstrip("#")
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], dtype=np.float64)


def fbm(w, h, octaves=(6, 12, 24, 48), seed=0):
    r = np.random.default_rng(seed)
    out = np.zeros((h, w))
    amp, tot = 1.0, 0.0
    for s in octaves:
        small = r.random((max(2, h // s), max(2, w // s)))
        img = Image.fromarray((small * 255).astype("uint8")).resize((w, h), Image.BICUBIC)
        out += amp * (np.asarray(img, dtype=np.float64) / 255.0)
        tot += amp
        amp *= 0.55
    return out / tot


def grain(arr, sigma=3.0, mottle=5.0, seed=7):
    r = np.random.default_rng(seed)
    noise = r.normal(0, sigma, arr.shape[:2])[..., None]
    low = (fbm(arr.shape[1], arr.shape[0], octaves=(24, 48, 96), seed=seed) - 0.5) * 2 * mottle
    return np.clip(arr + noise + low[..., None], 0, 255)


def vignette(arr, strength=0.06):
    yy, xx = np.mgrid[0:arr.shape[0], 0:arr.shape[1]]
    cx, cy = arr.shape[1] / 2, arr.shape[0] / 2
    r2 = ((xx - cx) / arr.shape[1]) ** 2 + ((yy - cy) / arr.shape[0]) ** 2
    return np.clip(arr * (1 - strength * r2 / r2.max())[..., None], 0, 255)


def save(arr, name):
    img = Image.fromarray(arr.astype("uint8"))
    img.save(os.path.join(OUT, name))
    return img


# ---------- palette ----------
DAISE = rgb("#4A4E69")      # 黛色
TIANQING = rgb("#9EC7C9")   # 天青
YUEBAI = rgb("#D6ECF0")     # 月白
XUANSE = rgb("#2A2626")     # 玄色
MIBAI = rgb("#F5F1E8")      # 米白
SONGHUA = rgb("#057748")    # 松花绿
YANZHI = rgb("#9D2933")     # 胭脂
ZHUSHA = rgb("#E63E21")     # 朱砂

walls = {}

# ---------- T1 solid + paper grain ----------
base = np.ones((H, W, 3)) * DAISE
walls["t1_grain"] = save(vignette(grain(base, sigma=3.2, mottle=4.0), 0.08), "t1_solid_grain.png")

# ---------- T2 duo gradient ----------
t = (np.mgrid[0:H, 0:W][0] / H)[:, :, None]
t = 3 * t * t - 2 * t * t * t  # smoothstep
base = YUEBAI * (1 - t) + TIANQING * t
walls["t2_gradient"] = save(grain(base, sigma=2.2, mottle=3.0), "t2_duo_gradient.png")

# ---------- T3 ink wash ----------
base = grain(np.ones((H, W, 3)) * MIBAI, sigma=2.0, mottle=3.0)
yy, xx = np.mgrid[0:H, 0:W]

def blot(base, cx, cy, R, color, peak, seed, stretch=1.2, edge=1.5, blur=5, fiber=0.5):
    """One layer of ink: steep falloff, fractal edge bite, fibrous texture."""
    dx, dy = (xx - cx) / R, (yy - cy) / (R * stretch)
    r = np.sqrt(dx * dx + dy * dy)
    n_edge = fbm(W, H, octaves=(6, 12, 24, 48), seed=seed)
    n_fiber = fbm(W, H, octaves=(48, 96, 192), seed=seed + 100)
    a = np.clip(1.05 - r * (0.45 + edge * n_edge), 0, 1) ** 1.6
    a = a * (1 - fiber + fiber * n_fiber * 2)
    a_img = Image.fromarray((np.clip(a, 0, 1) * 255).astype("uint8")).filter(ImageFilter.GaussianBlur(blur))
    a = (np.asarray(a_img, dtype=np.float64) / 255.0) * peak
    return base * (1 - a[..., None]) + color * a[..., None]

# layer 1: wide pale water stain
base = blot(base, W * 0.46, H * 0.38, W * 0.62, XUANSE, 0.16, seed=5, stretch=1.15, edge=0.8, blur=26, fiber=0.25)
# layer 2: main wash, defined organic edge
base = blot(base, W * 0.47, H * 0.39, W * 0.42, XUANSE, 0.50, seed=11, stretch=1.25, edge=1.7, blur=6, fiber=0.55)
# layer 3: darker offset core, like the last heavy touch of the brush
base = blot(base, W * 0.52, H * 0.42, W * 0.20, XUANSE, 0.68, seed=19, stretch=1.1, edge=1.9, blur=4, fiber=0.5)
# small companion stain lower-left
base = blot(base, W * 0.24, H * 0.68, W * 0.13, DAISE, 0.35, seed=31, stretch=1.3, edge=1.6, blur=5, fiber=0.5)
walls["t3_ink"] = save(np.clip(base, 0, 255), "t3_ink_wash.png")

# ---------- T4 negative space ----------
base = grain(np.ones((H, W, 3)) * MIBAI, sigma=2.2, mottle=3.5)
y0 = int(H * 0.660)
base[y0:y0 + 6, :] = XUANSE * 0.85           # hairline
band_y0 = y0 + 26
band_h = int(H * 0.115)
band = grain(np.ones((band_h, W, 3)) * SONGHUA, sigma=3.0, mottle=3.0, seed=5)
base[band_y0:band_y0 + band_h, :] = band
walls["t4_space"] = save(vignette(np.clip(base, 0, 255), 0.04), "t4_negative_space.png")

# ---------- T5 lattice geometry ----------
base = grain(np.ones((H, W, 3)) * MIBAI, sigma=2.0, mottle=3.0)
# moon-gate circle in rouge, left-upper golden area
cx, cy, R = W * 0.36, H * 0.34, W * 0.27
r = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2)
circle = np.clip((R - r) / 3.0, 0, 1)
base = base * (1 - circle[..., None]) + YANZHI * circle[..., None]
# lattice window on the right: slimmer bars, airier spacing, quiet grey
lattice = np.zeros((H, W))
bar_w = 7
x_start = int(W * 0.68)
for x in range(x_start, W, 132):
    lattice[:, x:x + bar_w] = 1
for y in range(0, H, 380):
    lattice[y:y + 6, x_start:] = 1
LATTICE_COL = XUANSE * 0.55 + MIBAI * 0.45   # softened ink-grey, not stark black
base = base * (1 - lattice[..., None] * 0.9) + LATTICE_COL * (lattice[..., None] * 0.9)
walls["t5_lattice"] = save(vignette(np.clip(base, 0, 255), 0.05), "t5_lattice.png")

# ---------- T6 seal accent ----------
base = grain(np.ones((H, W, 3)) * MIBAI, sigma=2.2, mottle=3.0)
side = int(W * 0.26)
sx, sy = int(W * 0.58), int(H * 0.30)
mask = np.zeros((H, W))
mask[sy:sy + side, sx:sx + side] = 1
# distressed edges: erode irregularly with fbm threshold
n = fbm(W, H, octaves=(12, 24, 48, 96), seed=77)
mask = mask * np.clip((n - 0.18) * 4, 0, 1)
mask_img = Image.fromarray((mask * 255).astype("uint8")).filter(ImageFilter.GaussianBlur(2.5))
mask = np.asarray(mask_img, dtype=np.float64) / 255.0
seal_col = grain(np.ones((H, W, 3)) * ZHUSHA, sigma=6.0, mottle=8.0, seed=9)
base = base * (1 - mask[..., None] * 0.96) + seal_col * (mask[..., None] * 0.96)
# inner border (negative line)
b = 26
border = np.zeros((H, W))
border[sy + b:sy + side - b, sx + b:sx + b + 9] = 1
border[sy + b:sy + side - b, sx + side - b - 9:sx + side - b] = 1
border[sy + b:sy + b + 9, sx + b:sx + side - b] = 1
border[sy + side - b - 9:sy + side - b, sx + b:sx + side - b] = 1
base = base * (1 - border[..., None] * mask[..., None] * 0.85) + MIBAI * (border[..., None] * mask[..., None] * 0.85)
# tiny balancing dot lower-left
dot_r = 16
dx2, dy2 = xx - W * 0.30, yy - H * 0.68
dot = np.clip(1 - np.sqrt(dx2 * dx2 + dy2 * dy2) / dot_r, 0, 1)
base = base * (1 - dot[..., None] * 0.9) + XUANSE * (dot[..., None] * 0.9)
walls["t6_seal"] = save(vignette(np.clip(base, 0, 255), 0.04), "t6_seal.png")

# ---------- contact sheet ----------
def find_font():
    for f in font_manager.fontManager.ttflist:
        if f.name == "Microsoft YaHei":
            return f.fname
    return None

font_path = find_font()
f_title = ImageFont.truetype(font_path, 34) if font_path else ImageFont.load_default()
f_sub = ImageFont.truetype(font_path, 24) if font_path else ImageFont.load_default()

labels = [
    ("t1_grain", "1 纯色颗粒", "黛色 Daise · paper grain"),
    ("t2_gradient", "2 双色渐变", "天青 → 月白 · duo gradient"),
    ("t3_ink", "3 水墨晕染", "玄色 on 米白 · ink wash"),
    ("t4_space", "4 大面积留白", "松花绿 · negative space"),
    ("t5_lattice", "5 窗格几何", "胭脂 + 玄色 · lattice"),
    ("t6_seal", "6 印章点缀", "朱砂 · seal accent"),
]

tw = 420
th = int(H * tw / W)
pad, gap, cap = 36, 26, 96
sheet_w = pad * 2 + 6 * tw + 5 * gap
sheet_h = pad * 2 + th + gap + cap
sheet = Image.new("RGB", (sheet_w, sheet_h), "#F3F1EC")
d = ImageDraw.Draw(sheet)
for i, (key, zh, en) in enumerate(labels):
    x = pad + i * (tw + gap)
    thumb = walls[key].resize((tw, th), Image.LANCZOS)
    sheet.paste(thumb, (x, pad))
    d.text((x, pad + th + gap), zh, font=f_title, fill="#2B2B2B")
    d.text((x, pad + th + gap + 46), en, font=f_sub, fill="#8A8A8A")
sheet_path = os.path.join(OUT, "contact-sheet.png")
sheet.save(sheet_path)

for k, v in walls.items():
    print(k, v.size)
print("sheet:", sheet_path, sheet.size, os.path.getsize(sheet_path), "bytes")
