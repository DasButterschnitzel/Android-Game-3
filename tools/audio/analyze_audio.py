"""Objective checks for generated audio (we cannot listen in CI/agent environments).

Usage: python3 tools/audio/analyze_audio.py [--report docs/audio/AUDIO_REPORT.md]
Checks per file: duration, peak dBFS, RMS dBFS, DC offset, clipped samples,
share of energy below 80 Hz (phone speakers can't reproduce it; it only eats
headroom), spectral centroid, isolated clicks (a 5 ms frame whose energy above
9 kHz stands far above both neighbours, e.g. a tone that stops abruptly), and
for *_loop files the seam discontinuity.
Exit code 1 if a hard rule is violated.
"""
from __future__ import annotations

import subprocess
import sys
import wave
from pathlib import Path

import numpy as np
from scipy import signal as sg

ROOT = Path(__file__).resolve().parents[2]
AUDIO = ROOT / "game/assets/audio"


def load(path: Path) -> tuple[np.ndarray, int]:
    if path.suffix == ".ogg":
        raw = subprocess.run(["ffmpeg", "-loglevel", "error", "-i", str(path), "-f", "s16le", "-ac", "1", "-ar", "44100", "-"],
                             capture_output=True, check=True).stdout
        return np.frombuffer(raw, dtype="<i2").astype(np.float64) / 32768.0, 44100
    with wave.open(str(path)) as w:
        sr = w.getframerate()
        x = np.frombuffer(w.readframes(w.getnframes()), dtype="<i2").astype(np.float64) / 32768.0
        if w.getnchannels() == 2:
            x = x.reshape(-1, 2).mean(axis=1)
    return x, sr


def analyze(path: Path) -> dict:
    x, sr = load(path)
    spec = np.abs(np.fft.rfft(x)) ** 2
    freqs = np.fft.rfftfreq(len(x), 1 / sr)
    total = spec.sum() + 1e-12
    r = {
        "file": str(path.relative_to(AUDIO)),
        "dur": len(x) / sr,
        "peak_db": 20 * np.log10(np.max(np.abs(x)) + 1e-12),
        "rms_db": 20 * np.log10(np.sqrt(np.mean(x ** 2)) + 1e-12),
        "dc": float(np.mean(x)),
        "clipped": int(np.sum(np.abs(x) >= 0.999)),
        "low_share": float(spec[freqs < 80].sum() / total),
        "centroid": float((freqs * spec).sum() / total),
        "seam": None,
    }
    r["click"] = click_score(x, sr)
    if "loop" in path.stem:
        # Jump between last and first sample relative to typical sample-to-sample change.
        typical = np.median(np.abs(np.diff(x))) + 1e-9
        r["seam"] = float(abs(x[-1] - x[0]) / typical)
    return r


def click_score(x: np.ndarray, sr: int) -> float:
    """Largest ratio (dB) of a frame's >9 kHz energy over its louder neighbour,
    ignoring the first 30 ms (the intended attack)."""
    hp = sg.sosfilt(sg.butter(4, 9000 / (sr / 2), btype="highpass", output="sos"), x)
    fl = int(0.005 * sr)
    n = len(hp) // fl
    if n < 8:
        return 0.0
    e = np.sqrt(np.mean(hp[: n * fl].reshape(n, fl) ** 2, axis=1)) + 1e-7
    # Ignore spikes quieter than what a ~-40 dBFS step produces above 9 kHz
    # (calibrated with a cosine cut off at amplitude 0.014: frame RMS 4e-4).
    floor = 3e-4
    best = 0.0
    for i in range(max(2, int(0.03 * sr / fl)), n - 2):
        if e[i] < floor:
            continue
        neigh = max(e[i - 2], e[i + 2])
        best = max(best, 20 * np.log10(e[i] / neigh))
    return float(best)


def main() -> int:
    files = sorted([p for p in AUDIO.rglob("*") if p.suffix in (".wav", ".ogg")])
    rows = [analyze(p) for p in files]
    problems = []
    for r in rows:
        if r["peak_db"] > -0.9:
            problems.append(f"{r['file']}: peak {r['peak_db']:.1f} dBFS (headroom < 0.9 dB)")
        if r["clipped"] > 0:
            problems.append(f"{r['file']}: {r['clipped']} clipped samples")
        if abs(r["dc"]) > 0.005:
            problems.append(f"{r['file']}: DC offset {r['dc']:.4f}")
        if r["low_share"] > 0.35:
            problems.append(f"{r['file']}: {r['low_share']*100:.0f}% energy below 80 Hz")
        if r["click"] > 15.0:
            problems.append(f"{r['file']}: isolated click ({r['click']:.0f} dB above its neighbours)")
        if r["seam"] is not None and r["seam"] > 25:
            problems.append(f"{r['file']}: loop seam jump {r['seam']:.1f}x typical step")
    lines = ["| Datei | Dauer s | Peak dBFS | RMS dBFS | <80 Hz | Schwerpunkt Hz | Klick dB | Loop-Naht |", "|---|---|---|---|---|---|---|---|"]
    for r in rows:
        seam = "–" if r["seam"] is None else f"{r['seam']:.1f}×"
        lines.append(f"| {r['file']} | {r['dur']:.2f} | {r['peak_db']:.1f} | {r['rms_db']:.1f} | {r['low_share']*100:.0f} % | {r['centroid']:.0f} | {r['click']:.0f} | {seam} |")
    table = "\n".join(lines)
    print(table)
    print("\nProbleme:" if problems else "\nKeine Regelverletzungen.")
    for p in problems:
        print(" -", p)
    if "--report" in sys.argv:
        out = Path(sys.argv[sys.argv.index("--report") + 1])
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text("# Audio-Prüfbericht (automatisch)\n\nErzeugt von `tools/audio/analyze_audio.py`. Objektive Messwerte – "
                       "ersetzen kein Anhören auf echten Geräten.\n\nRegeln: Peak ≤ −0,9 dBFS, kein Clipping, |DC| ≤ 0,005, "
                       "< 35 % Energie unter 80 Hz, kein isolierter Klick (≤ 15 dB über den Nachbar-Frames oberhalb 9 kHz), "
                       "Loop-Naht ≤ 25× typischer Sampleschritt.\n\n" + table + "\n\n" +
                       ("Keine Regelverletzungen.\n" if not problems else "Probleme:\n" + "\n".join(f"- {p}" for p in problems) + "\n"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
