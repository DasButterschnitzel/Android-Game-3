"""Generates the NACHHALL sound set from scratch (original procedural audio).

Run:  python3 tools/audio/make_nachhall_audio.py
Output: game/assets/audio/sfx/nh_*.wav

Sound identity: "a paper lantern in the night, ink, glass and a canon".
- Every light owns one note of D major pentatonic. The live light sounds as a
  clear bell, its echo as a softer, detuned, reverberant memory of the same
  note, so a defended wave plays as a canon and you hear WHEN each echo strikes.
- A quiet wooden tick per second ("timing track") makes the 8-second run audible.
- Failure sounds are soft (snuffed flame, breath), never buzzers.
Phone speakers: no sub-bass, transients soft, peaks normalised per category.
"""
from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).parent))
from synth import (SR, bandpass, crackle, env_adsr, env_exp, fade, fm_bell, highpass, lowpass,  # noqa: E402
                   midi_hz, mix, n_samples, noise, normalize, osc, pluck, reverb, soft_clip,
                   sweep_lowpass, time_axis, trim_silence, write_wav)

ROOT = Path(__file__).resolve().parents[2]
SFX = ROOT / "game/assets/audio/sfx"

# Light k -> note (MIDI). D major pentatonic, voiced so that any set of lights
# forms a consonant chord: D5 F#5 A5 B5 D6 E6.
LIGHT_NOTES = [74, 78, 81, 83, 86, 88]

LEVEL = {"tick": -18.0, "ui": -9.0, "small": -6.0, "medium": -4.0, "big": -2.5}


def save(name: str, x: np.ndarray, level: str) -> Path:
    x = x - np.mean(x)
    x = highpass(x, 90, 2)  # nothing below what phone speakers can play
    return write_wav(SFX / f"nh_{name}.wav", normalize(fade(trim_silence(x, -62.0)), LEVEL[level]))


def glass(note: float, dur: float, bright: float = 1.6, decay: float = 0.5) -> np.ndarray:
    f = midi_hz(note)
    body = fm_bell(f, dur, ratio=2.76, index=bright, decay=dur * decay)
    partial = 0.18 * fm_bell(f * 2.0, dur * 0.5, ratio=1.0, index=0.4, decay=dur * 0.12)
    return mix(body, partial)


def gen_voices() -> None:
    """Live voice: struck glass bell with a tiny felt transient. Echo voice: the
    same note, darker, slightly detuned (two copies), long tail = a memory."""
    for k, note in enumerate(LIGHT_NOTES):
        felt = bandpass(noise(0.03, "white", 300 + k), 1500, 5000, 2) * env_exp(0.03, 0.005) * 0.5
        live = mix(felt, glass(note, 1.3, 2.0, 0.42))
        save(f"live_{k}", reverb(live, 0.9, 0.18, seed=310 + k), "small")
        f = midi_hz(note)
        echo = mix(fm_bell(f * 1.004, 1.8, 2.76, 0.9, 0.7), fm_bell(f * 0.996, 1.8, 2.76, 0.9, 0.7))
        echo = lowpass(echo, 3800, 2) * env_adsr(1.8, 0.012, 0.2, 0.8, 1.2)
        save(f"echo_{k}", reverb(echo, 2.2, 0.45, seed=330 + k), "small")


def gen_ink_puff() -> None:
    """Ghost destroyed: ink scatters - soft breathy puff with a falling pitch and paper flutter."""
    for i in range(3):
        dur = 0.5
        t = time_axis(dur)
        puff = sweep_lowpass(noise(dur, "pink", 350 + i), 4500, 600) * env_exp(dur, 0.09, 0.004)
        drop = osc(np.linspace(520 + 40 * i, 260, n_samples(dur)), dur, "sine") * env_exp(dur, 0.06) * 0.35
        flutter = bandpass(crackle(dur, 90, seed=360 + i, decay_ms=1.2), 2000, 6500, 2) * env_exp(dur, 0.12) * 0.5
        save(f"puff_{i}", reverb(mix(puff, drop, flutter), 0.8, 0.15, seed=370 + i), "small")


def gen_crack() -> None:
    """Armor cracked by the first light: dry paper tear plus a woody knock."""
    for i in range(2):
        tear = bandpass(crackle(0.22, 900, seed=380 + i, decay_ms=0.8), 1200, 6000, 2) * env_exp(0.22, 0.05)
        knock = pluck(midi_hz(62 + 3 * i), 0.25, 0.2, seed=390 + i) * 0.8
        save(f"crack_{i}", mix(tear, knock), "small")


def gen_twin() -> None:
    """Twin marked (window open): two quick rising ticks. Twins destroyed: open fifth that blooms."""
    tick = lambda n, s: glass(n, 0.18, 1.0, 0.2) * 0.8  # noqa: E731
    ping = mix(tick(93, 0), np.pad(tick(98, 0), (n_samples(0.07), 0)))
    save("twin_ping", ping, "ui")
    a = glass(74, 2.0, 1.4, 0.5)
    b = glass(81, 2.0, 1.4, 0.5)
    swell = sweep_lowpass(noise(0.6, "pink", 400), 500, 6000) * env_adsr(0.6, 0.25, 0.1, 0.5, 0.25) * 0.25
    save("twin_link", reverb(mix(a, b * 0.9, swell), 1.8, 0.3, seed=401), "medium")


def gen_leak() -> None:
    """A ghost reaches the lantern: the flame gutters - soft low thump, breath, paper crumple."""
    dur = 1.1
    thump = osc(np.linspace(190, 110, n_samples(0.35)), 0.35, "sine") * env_exp(0.35, 0.09)
    breath = sweep_lowpass(noise(dur, "pink", 410), 2500, 300) * env_adsr(dur, 0.02, 0.15, 0.5, 0.8) * 0.7
    crumple = bandpass(crackle(0.4, 260, seed=412, decay_ms=1.5), 800, 4000, 2) * env_exp(0.4, 0.1) * 0.6
    x = soft_clip(mix(thump, breath, crumple) * 1.2, 1.3)
    save("leak", reverb(x, 1.2, 0.2, seed=413), "medium")


def gen_flame_out() -> None:
    """A flame dies when leaks are banked: hiss that fades into a small smoke curl."""
    dur = 1.2
    hiss = sweep_lowpass(noise(dur, "white", 420), 6000, 900) * env_adsr(dur, 0.01, 0.2, 0.4, 0.9)
    low = glass(62, 1.2, 0.6, 0.4) * 0.35
    save("flame_out", reverb(mix(hiss * 0.8, low), 1.4, 0.25, seed=421), "medium")


def gen_run_start() -> None:
    """Light released from its ring: short upward air swish with a soft chime on top."""
    dur = 0.35
    swish = sweep_lowpass(noise(dur, "pink", 430), 700, 6000) * env_adsr(dur, 0.12, 0.05, 0.4, 0.15)
    chime = glass(86, 0.5, 1.0, 0.25) * 0.4
    save("run_start", mix(swish, np.pad(chime, (n_samples(0.08), 0))), "ui")


def gen_ready() -> None:
    """Recharge complete: a tiny glass tink, barely there (only for the live light)."""
    save("ready", glass(98, 0.16, 0.6, 0.15), "tick")


def gen_ticks() -> None:
    """Timing track: wooden tick each second; the downbeat (start of the run) is a little brighter."""
    for i, (lo, hi) in enumerate([(1800, 5200), (1200, 3600)]):
        tick = bandpass(noise(0.05, "white", 440 + i), lo, hi, 2) * env_exp(0.05, 0.006)
        knock = pluck(midi_hz(79 if i == 0 else 74), 0.08, 0.3, seed=445 + i) * 0.5
        save(f"tick_{i}", mix(tick, knock), "tick")


def gen_wave_bell() -> None:
    """Start of a wave ('the hour strikes'): distant, soft bell with long tail."""
    f = midi_hz(62)
    body = mix(fm_bell(f, 3.0, 1.4, 1.6, 0.55), 0.5 * fm_bell(f * 2.01, 2.0, 1.4, 0.8, 0.4))
    body = lowpass(body, 2600, 2)
    save("wave_bell", reverb(body, 2.8, 0.45, seed=450), "medium")


def gen_perfect() -> None:
    """Perfect run: the canon chord blooms upwards."""
    out = np.zeros(n_samples(1.8))
    for k, note in enumerate(LIGHT_NOTES):
        b = glass(note, 1.2, 1.2, 0.4) * (0.75 - 0.06 * k)
        s = n_samples(0.045 * k)
        out[s:s + len(b)] += b[: len(out) - s]
    save("perfect", reverb(out, 1.6, 0.3, seed=460), "medium")


def gen_dawn() -> None:
    """Night survived: warm chord swell and the lantern's bells ringing out."""
    dur = 4.0
    chord = sum(osc(midi_hz(n), dur, "tri") * a for n, a in [(62, 0.45), (66, 0.32), (69, 0.32), (74, 0.24), (78, 0.16)])
    chord = lowpass(chord, 2400, 2) * env_adsr(dur, 1.0, 0.4, 0.7, 1.8)
    bells = np.zeros(n_samples(dur))
    for k, note in enumerate([86, 88, 90, 93, 95]):
        b = glass(note, 1.6, 1.0, 0.4) * 0.35
        s = n_samples(0.6 + 0.18 * k)
        bells[s:s + len(b)] += b[: len(bells) - s]
    save("dawn", reverb(mix(chord, bells), 2.2, 0.32, seed=470), "big")


def gen_lantern_out() -> None:
    """Night lost: three descending soft bells over a breath of wind."""
    dur = 3.2
    wind = bandpass(noise(dur, "pink", 480), 300, 1800, 2) * env_adsr(dur, 0.6, 0.4, 0.5, 1.8) * 0.5
    out = np.zeros(n_samples(dur))
    for k, note in enumerate([81, 78, 74]):
        b = glass(note, 1.6, 0.9, 0.45) * (0.8 - 0.1 * k)
        s = n_samples(0.35 * k)
        out[s:s + len(b)] += b[: len(out) - s]
    save("lantern_out", reverb(mix(wind, out), 2.4, 0.4, seed=481), "big")


def gen_second_light() -> None:
    """A second finger lights a second light: bright double chime."""
    a = glass(86, 0.6, 1.4, 0.3)
    b = np.pad(glass(90, 0.6, 1.4, 0.3), (n_samples(0.06), 0))
    save("second_light", mix(a, b * 0.8), "small")


def main() -> None:
    SFX.mkdir(parents=True, exist_ok=True)
    for fn in [gen_voices, gen_ink_puff, gen_crack, gen_twin, gen_leak, gen_flame_out, gen_run_start,
               gen_ready, gen_ticks, gen_wave_bell, gen_perfect, gen_dawn, gen_lantern_out, gen_second_light]:
        fn()
        print("ok", fn.__name__)


if __name__ == "__main__":
    main()
