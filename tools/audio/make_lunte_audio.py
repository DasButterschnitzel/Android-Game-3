"""Generates every LUNTE sound effect and music loop from scratch.

Run:  python3 tools/audio/make_lunte_audio.py
Output: game/assets/audio/sfx/*.wav (short, low latency) and game/assets/audio/music/*.ogg

Sound identity: "night, paper, embers, little bells". Soft transients, no harsh
highs, controlled bass (mobile speakers; no boomy sub), pentatonic notes so that
chains of ignitions always form a melody instead of noise.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).parent))
from synth import (SR, bandpass, crackle, env_adsr, env_exp, fade, fm_bell, highpass, lowpass,  # noqa: E402
                   make_loop, midi_hz, mix, n_samples, noise, normalize, osc, reverb, soft_clip,
                   sweep_lowpass, time_axis, trim_silence, write_wav)

ROOT = Path(__file__).resolve().parents[2]
SFX = ROOT / "game/assets/audio/sfx"
MUSIC = ROOT / "game/assets/audio/music"

# D major pentatonic over two octaves (MIDI): D E F# A B
PENTA = [74, 76, 78, 81, 83, 86, 88, 90, 93, 95]

# Target peak levels by category (dBFS) keep the mix consistent.
LEVEL = {"ui": -9.0, "small": -6.0, "medium": -4.0, "big": -2.5, "loop": -14.0, "music": -16.0}


def save(name: str, x: np.ndarray, level: str) -> Path:
    x = x - np.mean(x)  # no DC offset
    return write_wav(SFX / f"{name}.wav", normalize(fade(trim_silence(x)), LEVEL[level]))


def bell(note: float, dur: float = 1.2, bright: float = 2.2) -> np.ndarray:
    f = midi_hz(note)
    body = fm_bell(f, dur, ratio=3.5, index=bright, decay=dur * 0.35)
    shimmer = 0.25 * fm_bell(f * 2.0, dur * 0.6, ratio=1.41, index=1.0, decay=dur * 0.15)
    return mix(body, shimmer)


def gen_fuse_loop() -> None:
    """Burning fuse: crackle + soft hiss, seamless 2 s loop (pitch/volume driven at runtime)."""
    dur = 2.5
    c = crackle(dur, 140, seed=3, decay_ms=1.6)
    c = bandpass(c, 900, 7000, 2)
    hiss = bandpass(noise(dur, "pink", 4), 2500, 7500, 2) * 0.10
    pops = crackle(dur, 9, seed=5, decay_ms=6.0) * 0.6
    pops = bandpass(pops, 300, 2500, 2)
    x = make_loop(mix(c, hiss, pops), 0.25)
    save("fuse_loop", x, "loop")


def gen_draw_loop() -> None:
    """Soft paper scratch while drawing (volume follows drawing speed)."""
    dur = 2.2
    n = noise(dur, "white", 9)
    x = bandpass(n, 1800, 5200, 2) * (0.6 + 0.4 * np.sin(2 * np.pi * 7.0 * time_axis(dur)) ** 2)
    save("draw_loop", make_loop(x, 0.2), "loop")


def gen_thread() -> None:
    """Threading a firework onto the fuse: wooden tok + tiny bell."""
    for i, note in enumerate([86, 88, 90]):
        tok = bandpass(noise(0.08, "white", 20 + i), 600, 2400, 2) * env_exp(0.08, 0.012)
        tick = 0.35 * bell(note, 0.35, 1.2)
        save(f"thread_{i}", mix(tok, tick), "ui")


def gen_ignite_notes() -> None:
    """One pentatonic bell per chain step: chains climb the scale."""
    for i, note in enumerate(PENTA):
        b = bell(note, 1.4, 2.0)
        x = reverb(b, rt60=1.1, mix=0.22, seed=30 + i)
        save(f"note_{i}", x, "small")


def gen_bursts() -> None:
    """Fountain burst: soft pop + glittery sizzle."""
    for i in range(3):
        pop = bandpass(noise(0.16, "white", 40 + i), 250, 3000, 2) * env_exp(0.16, 0.035)
        sizzle = highpass(crackle(1.2, 420, seed=50 + i, decay_ms=1.6), 2500, 2) * env_exp(1.2, 0.45) * 0.9
        x = reverb(mix(pop, sizzle), 0.9, 0.18, seed=60 + i)
        save(f"burst_{i}", x, "medium")


def gen_rocket() -> None:
    """Rocket: rising whistle with flutter + air."""
    dur = 0.75
    t = time_axis(dur)
    f = 650 * (2.9 ** (t / dur)) * (1 + 0.015 * np.sin(2 * np.pi * 23 * t))
    tone = osc(f, dur, "sine") * env_adsr(dur, 0.02, 0.1, 0.8, 0.15)
    air = bandpass(noise(dur, "white", 70), 2000, 6000, 2) * env_adsr(dur, 0.05, 0.2, 0.5, 0.3) * 0.25
    save("rocket", mix(tone * 0.6, air), "small")


def gen_banger() -> None:
    """Banger: punchy, short, bass kept in check for phone speakers."""
    for i in range(2):
        body = lowpass(noise(0.6, "white", 80 + i), 2200, 2) * env_exp(0.6, 0.09)
        thump = osc(np.linspace(140, 70, n_samples(0.3)), 0.3, "sine") * env_exp(0.3, 0.08) * 0.8
        tail = bandpass(crackle(1.0, 120, seed=90 + i, decay_ms=3), 500, 5000, 2) * env_exp(1.0, 0.3) * 0.4
        x = soft_clip(mix(body, thump, tail) * 1.4, 1.6)
        x = highpass(x, 55, 2)
        save(f"banger_{i}", reverb(x, 1.0, 0.15, seed=95 + i), "big")


def gen_flare() -> None:
    """Fire jump warning: quick rising whoosh."""
    dur = 0.45
    n = noise(dur, "pink", 110)
    x = sweep_lowpass(n, 500, 7000) * env_adsr(dur, 0.18, 0.05, 0.6, 0.2)
    save("flare", highpass(x, 250, 2), "small")


def gen_loop_chord() -> None:
    """Loop closed around fireworks: shimmering triad."""
    parts = [bell(n, 1.6, 1.6) * a for n, a in [(74, 1.0), (78, 0.8), (81, 0.7)]]
    x = reverb(mix(*parts), 1.6, 0.3, seed=120)
    save("loop_closed", x, "medium")


def gen_short_circuit() -> None:
    """Short circuit: fast cascade up the scale."""
    out = np.zeros(n_samples(1.8))
    for k, note in enumerate(PENTA[:7]):
        b = bell(note, 1.0, 1.8) * (0.9 - 0.06 * k)
        start = n_samples(0.06 * k)
        out[start:start + len(b)] += b[: len(out) - start]
    save("short_circuit", reverb(out, 1.3, 0.25, seed=130), "big")


def gen_caught() -> None:
    """Caught: inhale whoosh into a soft boom (failure should feel like a finale, not a buzzer)."""
    w = sweep_lowpass(noise(0.5, "pink", 140), 300, 5000) * env_adsr(0.5, 0.45, 0.01, 1.0, 0.04)
    boom = lowpass(noise(1.2, "white", 141), 1500, 2) * env_exp(1.2, 0.25)
    thump = osc(np.linspace(170, 95, n_samples(0.5)), 0.5, "sine") * env_exp(0.5, 0.15) * 0.9
    x = highpass(np.concatenate([w, mix(boom, thump)]), 85, 2)
    save("caught", reverb(soft_clip(x * 1.3, 1.4), 1.4, 0.2, seed=142), "big")


def gen_dawn() -> None:
    """Dawn reached: warm major chord swell + bright bell."""
    dur = 3.0
    chord = sum(osc(midi_hz(n), dur, "tri") * a for n, a in [(62, 0.5), (66, 0.35), (69, 0.35), (74, 0.25)])
    chord = lowpass(chord, 2200, 2) * env_adsr(dur, 0.8, 0.4, 0.7, 1.4)
    x = reverb(mix(chord, 0.5 * bell(86, 2.0, 1.4)), 2.0, 0.3, seed=150)
    save("dawn", x, "big")


def gen_ui() -> None:
    tap = bandpass(noise(0.05, "white", 160), 1200, 4000, 2) * env_exp(0.05, 0.008)
    save("ui_tap", mix(tap, 0.3 * bell(93, 0.2, 0.6)), "ui")
    back = bandpass(noise(0.06, "white", 161), 700, 2500, 2) * env_exp(0.06, 0.01)
    save("ui_back", back, "ui")
    warn = mix(osc(880, 0.07, "sine") * env_exp(0.07, 0.02), np.pad(osc(880, 0.07, "sine") * env_exp(0.07, 0.02), (n_samples(0.11), 0)))
    save("spool_low", warn, "ui")


def gen_music() -> None:
    """Two seamless 24 s layers: calm night pad and a pulsing heat layer (crossfaded by heat)."""
    MUSIC.mkdir(parents=True, exist_ok=True)
    dur = 24.0
    t = time_axis(dur)
    # Night pad: slow D-pentatonic voicings, gentle filter breathing.
    voicings = [(50, 57, 62, 66), (52, 59, 64, 69), (47, 54, 62, 66), (50, 57, 64, 69)]
    pad = np.zeros_like(t)
    seg = dur / len(voicings)
    for k, chord in enumerate(voicings):
        e = np.clip(1 - np.abs((t - (k + 0.5) * seg) / (seg * 0.75)), 0, 1) ** 1.5
        for n in chord:
            pad += e * (osc(midi_hz(n) * 1.003, dur, "saw") + osc(midi_hz(n) * 0.997, dur, "saw")) * 0.12
    pad = lowpass(pad, 900, 2)
    sparkle = np.zeros_like(t)
    rng = np.random.default_rng(170)
    for k in range(18):
        start = rng.uniform(0, dur - 2)
        b = bell(PENTA[rng.integers(0, 6)], 1.8, 1.0) * 0.12
        i0 = int(start * SR)
        sparkle[i0:i0 + len(b)] += b[: len(sparkle) - i0]
    night = make_loop(reverb(mix(pad, sparkle), 2.5, 0.35, seed=171)[: len(t) + n_samples(0.5)], 0.5)
    _ogg("night_loop", night)
    # Heat layer: soft pulse at 100 bpm, filtered, tense but quiet.
    beat = 60 / 100
    pulse = np.zeros_like(t)
    for k in range(int(dur / beat)):
        i0 = int(k * beat * SR)
        hit = bandpass(noise(0.18, "white", 180 + k), 120, 900, 2) * env_exp(0.18, 0.04)
        pulse[i0:i0 + len(hit)] += hit[: len(pulse) - i0] * (1.0 if k % 2 == 0 else 0.6)
    drone = lowpass(osc(midi_hz(50), dur, "saw") * 0.2 + osc(midi_hz(57), dur, "saw") * 0.12, 700, 2)
    heat = make_loop(highpass(mix(pulse * 0.8, drone), 95, 2)[: len(t) + n_samples(0.5)], 0.5)
    _ogg("heat_loop", heat)


def _ogg(name: str, x: np.ndarray) -> None:
    wav = MUSIC / f"{name}.wav"
    write_wav(wav, normalize(x - np.mean(x), LEVEL["music"]))
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav), "-c:a", "libvorbis", "-q:a", "4",
                    str(MUSIC / f"{name}.ogg")], check=True)
    wav.unlink()


def main() -> None:
    SFX.mkdir(parents=True, exist_ok=True)
    for fn in [gen_fuse_loop, gen_draw_loop, gen_thread, gen_ignite_notes, gen_bursts, gen_rocket,
               gen_banger, gen_flare, gen_loop_chord, gen_short_circuit, gen_caught, gen_dawn, gen_ui, gen_music]:
        fn()
        print("ok", fn.__name__)


if __name__ == "__main__":
    main()
