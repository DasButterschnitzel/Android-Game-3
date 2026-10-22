"""Objective checks for generated audio (we cannot listen in CI/agent environments).

Usage: python3 tools/audio/analyze_audio.py [--report docs/audio/AUDIO_REPORT.md]
Checks per file: duration, peak dBFS, RMS dBFS, DC offset, clipped samples,
share of energy below 80 Hz (phone speakers can't reproduce it; it only eats
headroom), spectral centroid, and for *_loop files the seam discontinuity.
Exit code 1 if a hard rule is violated.
"""
from __future__ import annotations

import subprocess
import sys
import wave
from pathlib import Path

import numpy as np

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
    if "loop" in path.stem:
        # Jump between last and first sample relative to typical sample-to-sample change.
        typical = np.median(np.abs(np.diff(x))) + 1e-9
        r["seam"] = float(abs(x[-1] - x[0]) / typical)
    return r


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
        if r["seam"] is not None and r["seam"] > 25:
            problems.append(f"{r['file']}: loop seam jump {r['seam']:.1f}x typical step")
    lines = ["| Datei | Dauer s | Peak dBFS | RMS dBFS | <80 Hz | Schwerpunkt Hz | Loop-Naht |", "|---|---|---|---|---|---|---|"]
    for r in rows:
        seam = "–" if r["seam"] is None else f"{r['seam']:.1f}×"
        lines.append(f"| {r['file']} | {r['dur']:.2f} | {r['peak_db']:.1f} | {r['rms_db']:.1f} | {r['low_share']*100:.0f} % | {r['centroid']:.0f} | {seam} |")
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
                       "< 35 % Energie unter 80 Hz, Loop-Naht ≤ 25× typischer Sampleschritt.\n\n" + table + "\n\n" +
                       ("Keine Regelverletzungen.\n" if not problems else "Probleme:\n" + "\n".join(f"- {p}" for p in problems) + "\n"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
