#!/usr/bin/env python3
"""Generates store artwork for NACHHALL from the project's own procedural style.

Outputs (docs/store/):
  feature_graphic_1024x500.png   Google Play feature graphic
Screenshots come from real gameplay captures (tools/capture.sh), not from this script.

Only own shapes and the bundled Fredoka font (SIL OFL 1.1) are used.
"""
import math
import os
import random
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

sys.path.insert(0, os.path.dirname(__file__))
from make_icon import lantern_layer  # noqa: E402

ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "docs", "store")
FONT_BOLD = os.path.join(ROOT, "game", "assets", "fonts", "Fredoka-Bold.ttf")
FONT_MED = os.path.join(ROOT, "game", "assets", "fonts", "Fredoka-Medium.ttf")


def night_sky(w, h, seed=3):
    im = Image.new("RGB", (w, h))
    d = ImageDraw.Draw(im)
    top, bot = (0x24, 0x1f, 0x4d), (0x0c, 0x0a, 0x22)
    for y in range(h):
        t = y / (h - 1)
        d.line([(0, y), (w, y)], fill=tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)))
    rnd = random.Random(seed)
    for _ in range(int(w * h / 2500)):
        x, y, r = rnd.uniform(0, w), rnd.uniform(0, h * 0.8), rnd.uniform(0.5, 1.6)
        d.ellipse([x - r, y - r, x + r, y + r], fill=(255, 245, 220))
    return im


def skyline(w, h, seed=11):
    """Cut-paper rooftops along the bottom edge (same idea as ArtKit.skyline)."""
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    rnd = random.Random(seed)
    tones = [(26, 24, 56, 255), (19, 17, 48, 255), (11, 10, 34, 255)]
    for li, tone in enumerate(tones):
        x = -20
        base = h - 60 + li * 18
        pts = [(x, h)]
        while x < w + 20:
            bw = rnd.uniform(40, 110)
            bh = rnd.uniform(20, 90) * (0.6 + 0.2 * (3 - li))
            y = base - bh
            pts.append((x, y))
            if rnd.random() < 0.4:
                pts.append((x + bw * 0.5, y - rnd.uniform(14, 30)))
            pts.append((x + bw, y))
            x += bw
        pts.append((x, h))
        d.polygon(pts, fill=tone)
        for _ in range(int(w / 70)):
            wx, wy = rnd.uniform(0, w), rnd.uniform(base - 40, base + 10)
            if rnd.random() < 0.5:
                d.rectangle([wx, wy, wx + 7, wy + 10], fill=(255, 204, 115, 150))
    return layer


def ghost(d, cx, cy, r, rim, seed):
    rnd = random.Random(seed)
    pts = []
    for i in range(28):
        a = 2 * math.pi * i / 28
        w = 1 + 0.1 * math.sin(3 * a + seed) + (0.15 * abs(math.sin(a * 4 + seed)) if math.sin(a) > 0.35 else 0)
        pts.append((cx + math.cos(a) * r * w, cy + math.sin(a) * r * 1.08 * w))
    d.polygon(pts, fill=(10, 6, 19, 255), outline=rim)
    d.line(pts + [pts[0]], fill=rim, width=max(2, int(r * 0.12)))
    for s in (-1, 1):
        ex, ey = cx + s * r * 0.32 + r * 0.18, cy - r * 0.12
        d.ellipse([ex - r * 0.19, ey - r * 0.19, ex + r * 0.19, ey + r * 0.19], fill=(255, 255, 255, 255))
        d.ellipse([ex + r * 0.03 - r * 0.09, ey - r * 0.09, ex + r * 0.03 + r * 0.09, ey + r * 0.09], fill=(10, 6, 19, 255))


def radial_glow(radius, color, peak):
    """Soft additive-looking glow: alpha falls off smoothly to exactly zero at the radius."""
    import numpy as np
    n = radius * 2
    yy, xx = np.mgrid[0:n, 0:n]
    r = np.hypot(xx - radius + 0.5, yy - radius + 0.5) / radius
    a = (np.clip(1.0 - r, 0.0, 1.0) ** 2 * peak).astype(np.uint8)
    rgba = np.zeros((n, n, 4), dtype=np.uint8)
    rgba[..., 0], rgba[..., 1], rgba[..., 2], rgba[..., 3] = color[0], color[1], color[2], a
    return Image.fromarray(rgba, "RGBA")


def feature_graphic():
    w, h = 1024, 500
    im = night_sky(w, h).convert("RGBA")
    im = Image.alpha_composite(im, skyline(w, h))
    # Lantern with echo rings on the left third.
    lan = lantern_layer(460)
    im.alpha_composite(lan, (40, 20))
    d = ImageDraw.Draw(im)
    ghost(d, 70, 300, 30, (255, 107, 138, 255), 1)
    ghost(d, 420, 150, 26, (197, 139, 255, 255), 2)
    ghost(d, 400, 380, 34, (255, 162, 92, 255), 3)
    for (x, y, c) in [(150, 120, (127, 214, 255)), (360, 300, (166, 255, 158)), (110, 400, (255, 226, 122))]:
        im.alpha_composite(radial_glow(70, c, 170), (x - 70, y - 70))
        d.ellipse([x - 8, y - 8, x + 8, y + 8], fill=c + (255,))
    title = ImageFont.truetype(FONT_BOLD, 96)
    sub = ImageFont.truetype(FONT_MED, 36)
    tw = d.textlength("NACHHALL", font=title)
    tx = int(min(520, 1000 - tw))
    d.text((tx + 4, 130 + 5), "NACHHALL", font=title, fill=(5, 5, 15, 200))
    d.text((tx, 130), "NACHHALL", font=title, fill=(246, 241, 231, 255))
    d.text((tx + 4, 270), "Jeder Lauf wird ein Echo,", font=sub, fill=(255, 179, 71, 255))
    d.text((tx + 4, 318), "das mit dir kämpft.", font=sub, fill=(255, 179, 71, 255))
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, "feature_graphic_1024x500.png")
    im.convert("RGB").save(path)
    print("wrote", path)


if __name__ == "__main__":
    feature_graphic()
