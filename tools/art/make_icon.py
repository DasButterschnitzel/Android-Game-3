#!/usr/bin/env python3
"""Generates the NACHHALL launcher icons (own artwork, procedural, no external assets).

Outputs (game/assets/icon/):
  icon_192.png              legacy launcher icon / project icon
  icon_fg_432.png           adaptive icon foreground (lantern + echo rings, transparent)
  icon_bg_432.png           adaptive icon background (night sky)
  icon_mono_432.png         adaptive monochrome layer (Android 13 themed icons)
  icon_512.png              store-size preview (Play Console needs 512x512)
"""
import math, os, random
from PIL import Image, ImageDraw, ImageFilter

OUT = os.path.join(os.path.dirname(__file__), "..", "..", "game", "assets", "icon")
SS = 4  # supersampling

def sky(size):
    im = Image.new("RGB", (size, size))
    d = ImageDraw.Draw(im)
    top, bot = (0x24, 0x1f, 0x4d), (0x0c, 0x0a, 0x22)
    for y in range(size):
        t = y / (size - 1)
        d.line([(0, y), (size, y)], fill=tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)))
    # A few big stars only (small ones vanish at 48 dp).
    for (fx, fy) in [(0.16, 0.18), (0.82, 0.14), (0.88, 0.62), (0.12, 0.7), (0.7, 0.86)]:
        r = 3.2 * size / 432
        x, y = fx * size, fy * size
        d.ellipse([x - r, y - r, x + r, y + r], fill=(255, 245, 220))
    return im

def lantern_layer(size, mono=False, rings=True):
    S = size * SS
    im = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    c = S / 2
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    if not mono:
        for i in range(30, 0, -1):
            r = S * 0.30 * i / 30
            a = int(150 * (1 - i / 30) ** 1.6)
            gd.ellipse([c - r, c - r, c + r, c + r], fill=(255, 150, 70, a))
        im = Image.alpha_composite(im, glow)
    d = ImageDraw.Draw(im)
    if rings:
        # Two echo arcs in the cool "moonlight" palette, inside the adaptive-icon
        # safe zone: on 432 px the outer edge is at r 128 (safe zone ends at 132).
        cols = [(166, 240, 255), (41, 204, 177)]
        for k, rr in enumerate([90 / 432, 118 / 432]):
            r = S * rr
            col = (255, 255, 255, 255) if mono else cols[k] + (255,)
            w = int(S * 20 / 432)
            start = -70 + k * 40
            d.arc([c - r, c - r, c + r, c + r], start, start + 250, fill=col, width=w)
    # lantern body (~110 px wide on 432)
    rx, ry = S * 0.128, S * 0.153
    body = (255, 255, 255, 255) if mono else (255, 213, 138, 255)
    d.ellipse([c - rx, c - ry, c + rx, c + ry], fill=body)
    if not mono:
        rib = (224, 166, 86, 255)
        for k in (-0.62, -0.25, 0.25, 0.62):
            pts = []
            for i in range(25):
                a = -math.pi / 2 + math.pi * i / 24
                pts.append((c + k * rx * math.cos(a), c + math.sin(a) * ry * 0.98))
            d.line(pts, fill=rib, width=int(S * 0.008))
        d.ellipse([c - rx, c - ry, c + rx, c + ry], outline=rib, width=int(S * 0.009))
        cap = (58, 43, 63, 255)
        d.rectangle([c - rx * 0.55, c - ry * 1.12, c + rx * 0.55, c - ry * 0.94], fill=cap)
        d.rectangle([c - rx * 0.45, c + ry * 0.94, c + rx * 0.45, c + ry * 1.1], fill=cap)
        # three little flames
        for i in range(3):
            fx = c + (i - 1) * rx * 0.5
            fy = c + ry * 0.28
            h = ry * 0.42
            d.polygon([(fx - rx * 0.12, fy), (fx, fy - h), (fx + rx * 0.12, fy), (fx, fy + ry * 0.1)], fill=(255, 154, 60, 255))
            d.polygon([(fx - rx * 0.06, fy), (fx, fy - h * 0.6), (fx + rx * 0.06, fy), (fx, fy + ry * 0.06)], fill=(255, 243, 196, 255))
        d.line([(c, 0), (c, c - ry * 1.12)], fill=(140, 128, 155, 200), width=int(S * 0.006))
    else:
        cut = (0, 0, 0, 0)
        d.rectangle([c - rx * 0.55, c - ry * 1.12, c + rx * 0.55, c - ry * 0.94], fill=(255, 255, 255, 255))
    return im.resize((size, size), Image.LANCZOS)

def main():
    os.makedirs(OUT, exist_ok=True)
    bg = sky(432)
    bg.save(os.path.join(OUT, "icon_bg_432.png"))
    fg = lantern_layer(432)
    fg.save(os.path.join(OUT, "icon_fg_432.png"))
    lantern_layer(432, mono=True).save(os.path.join(OUT, "icon_mono_432.png"))
    for size in (192, 512):
        full = sky(size).convert("RGBA")
        full = Image.alpha_composite(full, lantern_layer(size))
        # rounded square like most launchers show legacy icons
        mask = Image.new("L", (size * SS, size * SS), 0)
        ImageDraw.Draw(mask).rounded_rectangle([0, 0, size * SS - 1, size * SS - 1], radius=size * SS * 0.18, fill=255)
        mask = mask.resize((size, size), Image.LANCZOS)
        out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        out.paste(full, (0, 0), mask)
        out.save(os.path.join(OUT, f"icon_{size}.png"))
    print("icons written to", os.path.normpath(OUT))

if __name__ == "__main__":
    main()
