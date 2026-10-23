#!/usr/bin/env python3
"""Colour-vision check for captured frames (same maths as assets/shaders/cvd_debug.gdshader).

Usage: python3 tools/art/cvd_sheet.py out.png frame1.png [frame2.png ...]
Writes a sheet with one row per frame: normal | protan | deutan | tritan | grey.
Matrices: Machado, Oliveira & Fernandes 2009, severity 1.0, applied in linear RGB.
"""
import sys

import numpy as np
from PIL import Image

M = {
    "protan": np.array([[0.152286, 1.052583, -0.204868], [0.114503, 0.786281, 0.099216], [-0.003882, -0.048116, 1.051998]]),
    "deutan": np.array([[0.367322, 0.860646, -0.227968], [0.280085, 0.672501, 0.047413], [-0.011820, 0.042940, 0.968881]]),
    "tritan": np.array([[1.255528, -0.076749, -0.178779], [-0.078411, 0.930809, 0.147602], [0.004733, 0.691367, 0.303900]]),
}


def simulate(img, mode):
    a = np.asarray(img.convert("RGB"), dtype=np.float64) / 255.0
    lin = a ** 2.2
    if mode == "grey":
        y = lin @ np.array([0.2126, 0.7152, 0.0722])
        out = np.repeat(y[..., None], 3, axis=2)
    else:
        out = lin @ M[mode].T
    out = np.clip(out, 0, 1) ** (1 / 2.2)
    return Image.fromarray((out * 255 + 0.5).astype(np.uint8))


def main():
    out, frames = sys.argv[1], sys.argv[2:]
    modes = ["normal", "protan", "deutan", "tritan", "grey"]
    w, h = 360, 640
    sheet = Image.new("RGB", (w * len(modes), h * len(frames)))
    for r, f in enumerate(frames):
        img = Image.open(f).convert("RGB")
        for c, m in enumerate(modes):
            tile = img if m == "normal" else simulate(img, m)
            sheet.paste(tile.resize((w, h), Image.LANCZOS), (c * w, r * h))
    sheet.save(out)
    print("wrote", out)


if __name__ == "__main__":
    main()
