#!/usr/bin/env python3
"""Generates the NACHHALL sprite atlas (own artwork, procedural, no external assets).

One texture for every soft dot, ring and symbol of a scene, so they batch into a
single draw call (see game/scripts/gameplay/fx/batch_2d.gd). Shapes are computed
analytically on an 8x supersampled grid; transparent pixels keep the colour of the
nearest shape (alpha bleeding) so linear filtering shows no dark or light fringes.

Output: game/assets/sprites/atlas.png (320x272). The cell table must match
ArtKit.ATLAS_CELLS in game/scripts/gameplay/fx/art_kit.gd (a unit test checks it).
"""
import math, os
import numpy as np
from PIL import Image

OUT = os.path.join(os.path.dirname(__file__), "..", "..", "game", "assets", "sprites", "atlas.png")
SS = 8
INK = np.array([0x0A, 0x06, 0x13], dtype=np.float64) / 255.0
WHITE = np.ones(3)
TAU = math.tau

# name: (x, y, w, h, reference radius) -- same numbers as ArtKit.ATLAS_CELLS
CELLS = {
    "glow": (0, 0, 64, 64, 32.0),
    "disc64": (64, 0, 64, 64, 30.0),
    "disc32": (128, 0, 32, 32, 14.0),
    "disc16": (160, 0, 16, 16, 6.5),
    "slot": (176, 0, 16, 16, 5.5),
    "tri": (192, 0, 32, 32, 11.5),
    "square": (224, 0, 32, 32, 11.0),
    "diamond": (192, 32, 32, 32, 12.0),
    "guide": (0, 64, 80, 80, 32.0),
    "plates": (80, 64, 80, 80, 32.0),
    "plates3": (160, 64, 80, 80, 32.0),
    "track": (240, 64, 64, 64, 27.5),
    "dashring": (0, 144, 128, 128, 60.0),
    "hitring": (128, 144, 96, 96, 44.0),
}


def grid(w, h):
    """Supersampled pixel-centre coordinates relative to the cell centre."""
    ys, xs = np.mgrid[0:h * SS, 0:w * SS]
    return (xs + 0.5) / SS - w / 2.0, (ys + 0.5) / SS - h / 2.0


def down(rgba, w, h):
    """Average SS x SS blocks; colour is averaged weighted by alpha (straight alpha)."""
    a = rgba[..., 3]
    rgb = rgba[..., :3] * a[..., None]
    a_m = a.reshape(h, SS, w, SS).mean(axis=(1, 3))
    rgb_m = rgb.reshape(h, SS, w, SS, 3).mean(axis=(1, 3))
    bleed = rgba[..., :3].reshape(h, SS, w, SS, 3).mean(axis=(1, 3))  # colour of empty pixels
    out = np.zeros((h, w, 4))
    with np.errstate(invalid="ignore", divide="ignore"):
        out[..., :3] = np.where(a_m[..., None] > 1e-6, rgb_m / a_m[..., None], bleed)
    out[..., 3] = a_m
    return out


def layer(shape, color, alpha, bleed):
    """shape: boolean mask; colour where covered, `bleed` colour where transparent."""
    out = np.zeros(shape.shape + (4,))
    out[...] = np.append(bleed, 0.0)
    out[shape] = np.append(color, alpha)
    return out


def over(dst, src):
    a = src[..., 3:4]
    res = dst.copy()
    res[..., 3:4] = a + dst[..., 3:4] * (1 - a)
    with np.errstate(invalid="ignore", divide="ignore"):
        res[..., :3] = np.where(res[..., 3:4] > 1e-9,
                                (src[..., :3] * a + dst[..., :3] * dst[..., 3:4] * (1 - a)) / res[..., 3:4],
                                np.where(a > 0, src[..., :3], dst[..., :3]))
    return res


def glow(w, h, r):
    x, y = grid(w, h)
    d = np.minimum(np.hypot(x, y) / r, 1.0)
    stops = [(0.0, 1.0), (0.25, 0.65), (0.6, 0.12), (1.0, 0.0)]
    a = np.interp(d, [s[0] for s in stops], [s[1] for s in stops])
    out = np.ones(d.shape + (4,))
    out[..., 3] = a
    return out


def disc(w, h, r):
    x, y = grid(w, h)
    return layer(np.hypot(x, y) <= r, WHITE, 1.0, WHITE)


def ring(w, h, r, hw, segments=None):
    x, y = grid(w, h)
    mask = np.abs(np.hypot(x, y) - r) <= hw
    if segments:
        mask &= in_segments(x, y, segments)
    return layer(mask, WHITE, 1.0, WHITE)


def in_segments(x, y, segments):
    ang = np.mod(np.arctan2(y, x), TAU)
    m = np.zeros(x.shape, dtype=bool)
    for a0, a1 in segments:
        m |= (ang >= a0) & (ang <= a1)
    return m


def inked_ring(w, h, r, ink_hw, core_hw, ink_alpha, segments=None):
    """Dark band under a white core band (tinted by the draw colour)."""
    x, y = grid(w, h)
    d = np.abs(np.hypot(x, y) - r)
    seg = in_segments(x, y, segments) if segments else np.ones(x.shape, dtype=bool)
    base = layer((d <= ink_hw) & seg, INK, ink_alpha, INK)
    core = layer((d <= core_hw) & seg, WHITE, 1.0, INK)
    return over(base, core)


def polygon_sd(x, y, pts):
    """Signed distance to a convex polygon (positive inside), edges as lines."""
    sd = np.full(x.shape, np.inf)
    n = len(pts)
    # counter-clockwise check: compute area sign
    area = sum(pts[i][0] * pts[(i + 1) % n][1] - pts[(i + 1) % n][0] * pts[i][1] for i in range(n))
    sgn = 1.0 if area > 0 else -1.0
    for i in range(n):
        (x0, y0), (x1, y1) = pts[i], pts[(i + 1) % n]
        ex, ey = x1 - x0, y1 - y0
        ln = math.hypot(ex, ey)
        # inward normal for this winding
        nx, ny = -ey / ln * sgn, ex / ln * sgn
        sd = np.minimum(sd, (x - x0) * nx + (y - y0) * ny)
    return sd


def symbol(w, h, pts, outline_hw):
    """White polygon with an ink outline centred on its edges (like fill + polyline)."""
    x, y = grid(w, h)
    sd = polygon_sd(x, y, pts)
    fill = layer(sd > 0, WHITE, 1.0, INK)
    line = layer(np.abs(sd) <= outline_hw, INK, 1.0, INK)
    return over(fill, line)


def main():
    W, H = 320, 272
    atlas = np.zeros((H, W, 4))
    atlas[..., :3] = 1.0
    shapes = {}
    shapes["glow"] = lambda w, h, r: glow(w, h, r)
    shapes["disc64"] = lambda w, h, r: disc(w, h, r)
    shapes["disc32"] = lambda w, h, r: disc(w, h, r)
    shapes["disc16"] = lambda w, h, r: disc(w, h, r)
    shapes["slot"] = lambda w, h, r: ring(w, h, r, 0.75)
    # Triangle pointing +x, circumradius r; outline 2 px at the field size (circumradius 8.8).
    shapes["tri"] = lambda w, h, r: symbol(w, h, [(r * math.cos(TAU * k / 3), r * math.sin(TAU * k / 3)) for k in range(3)], 1.0 * r / 8.8)
    shapes["square"] = lambda w, h, r: symbol(w, h, [(-r, -r), (r, -r), (r, r), (-r, r)], 1.0 * r / 7.2)
    shapes["diamond"] = lambda w, h, r: symbol(w, h, [(0, -r), (r, 0), (0, r), (-r, 0)], 0.75 * r / 6.0)
    # Echo strike ring: ink 6 px (alpha 0.5) under a 3 px core, at r 16 -> here at 2x.
    shapes["guide"] = lambda w, h, r: inked_ring(w, h, r, 6.0, 3.0, 0.5)
    plate = [(TAU * k / 6, TAU * k / 6 + TAU / 6 * 0.8) for k in range(6)]
    shapes["plates"] = lambda w, h, r: inked_ring(w, h, r, 3.5, 2.0, 1.0, plate)
    shapes["plates3"] = lambda w, h, r: inked_ring(w, h, r, 3.5, 2.0, 1.0, [p for k, p in enumerate(plate) if k % 2 == 1])
    shapes["track"] = lambda w, h, r: ring(w, h, r, 2.5)
    dashes = [(TAU * i / 16, TAU * i / 16 + TAU / 16 * 0.55) for i in range(16)]
    shapes["dashring"] = lambda w, h, r: ring(w, h, r, 1.6, dashes)
    shapes["hitring"] = lambda w, h, r: ring(w, h, r, 0.87)
    for name, (cx, cy, w, h, r) in CELLS.items():
        cell = down(shapes[name](w, h, r), w, h)
        atlas[cy:cy + h, cx:cx + w] = cell
    img = Image.fromarray(np.clip(np.round(atlas * 255), 0, 255).astype(np.uint8), "RGBA")
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    img.save(OUT, optimize=True)
    print("wrote", os.path.relpath(OUT), img.size)


if __name__ == "__main__":
    main()
