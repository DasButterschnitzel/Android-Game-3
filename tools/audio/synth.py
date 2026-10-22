"""Tiny procedural audio toolkit for the project's own sound effects and music.

Everything here is generated from math (oscillators, noise, filters), so every
produced file is an original work of this project (no third-party samples).
Output: 16-bit PCM WAV, mono by default, 44.1 kHz.
"""
from __future__ import annotations

import wave
from pathlib import Path

import numpy as np
from scipy import signal

SR = 44100


def n_samples(dur: float) -> int:
    return int(round(SR * dur))


def time_axis(dur: float) -> np.ndarray:
    return np.arange(n_samples(dur)) / SR


# --- envelopes ---------------------------------------------------------------

def env_exp(dur: float, decay: float, attack: float = 0.002) -> np.ndarray:
    """Fast attack, exponential decay (decay = time constant in seconds)."""
    t = time_axis(dur)
    env = np.exp(-t / max(decay, 1e-4))
    a = n_samples(attack)
    if a > 0:
        env[:a] *= np.linspace(0.0, 1.0, a)
    return env


def env_adsr(dur: float, a: float, d: float, s: float, r: float) -> np.ndarray:
    n = n_samples(dur)
    na, nd, nr = n_samples(a), n_samples(d), n_samples(r)
    ns = max(n - na - nd - nr, 0)
    env = np.concatenate([
        np.linspace(0, 1, na, endpoint=False),
        np.linspace(1, s, nd, endpoint=False),
        np.full(ns, s),
        np.linspace(s, 0, nr),
    ])
    return np.pad(env, (0, max(0, n - len(env))))[:n]


def fade(x: np.ndarray, in_s: float = 0.002, out_s: float = 0.01) -> np.ndarray:
    x = x.copy()
    a, b = n_samples(in_s), n_samples(out_s)
    if a:
        x[:a] *= np.linspace(0, 1, a)
    if b:
        x[-b:] *= np.linspace(1, 0, b)
    return x


# --- sources -----------------------------------------------------------------

def osc(freq, dur: float, kind: str = "sine", phase: float = 0.0) -> np.ndarray:
    """freq may be a scalar or a per-sample array (for sweeps/vibrato)."""
    n = n_samples(dur)
    f = np.broadcast_to(np.asarray(freq, dtype=float), (n,))
    ph = 2 * np.pi * np.cumsum(f) / SR + phase
    if kind == "sine":
        return np.sin(ph)
    if kind == "tri":
        return 2 / np.pi * np.arcsin(np.sin(ph))
    if kind == "saw":
        return 2 * ((ph / (2 * np.pi)) % 1.0) - 1
    if kind == "square":
        return np.sign(np.sin(ph))
    raise ValueError(kind)


def noise(dur: float, color: str = "white", seed: int = 0) -> np.ndarray:
    rng = np.random.default_rng(seed)
    n = n_samples(dur)
    w = rng.standard_normal(n)
    if color == "white":
        return w / 3.0
    spec = np.fft.rfft(w)
    f = np.fft.rfftfreq(n, 1 / SR)
    f[0] = f[1]
    if color == "pink":
        spec /= np.sqrt(f)
    elif color == "brown":
        spec /= f
    out = np.fft.irfft(spec, n)
    return out / (np.max(np.abs(out)) + 1e-9)


def fm_bell(freq: float, dur: float, ratio: float = 1.4, index: float = 2.5, decay: float = 0.6) -> np.ndarray:
    """Glassy FM bell: carrier modulated by a decaying modulator."""
    t = time_axis(dur)
    mod_env = np.exp(-t / (decay * 0.5))
    mod = index * mod_env * np.sin(2 * np.pi * freq * ratio * t)
    return np.sin(2 * np.pi * freq * t + mod) * env_exp(dur, decay)


def pluck(freq: float, dur: float, brightness: float = 0.5, seed: int = 0) -> np.ndarray:
    """Karplus-Strong plucked string."""
    rng = np.random.default_rng(seed)
    n = n_samples(dur)
    period = max(int(SR / freq), 2)
    buf = rng.uniform(-1, 1, period)
    out = np.empty(n)
    # brightness blends between the classic two-tap average (dark) and no filtering (bright).
    b = np.clip(brightness, 0.0, 0.95)
    for i in range(n):
        k = i % period
        out[i] = buf[k]
        avg = 0.5 * (buf[k] + buf[(k + 1) % period])
        buf[k] = 0.996 * ((1 - b) * avg + b * buf[k])
    return out * env_exp(dur, dur * 0.6)


def crackle(dur: float, density: float, seed: int = 0, decay_ms: float = 2.0) -> np.ndarray:
    """Sparse random impulses with tiny decays: burning fuse / sparkler texture."""
    rng = np.random.default_rng(seed)
    n = n_samples(dur)
    out = np.zeros(n)
    count = int(density * dur)
    pos = rng.integers(0, n, count)
    amp = rng.uniform(0.2, 1.0, count) * rng.choice([-1, 1], count)
    out[pos] = amp
    k = env_exp(decay_ms / 1000 * 6, decay_ms / 1000)
    return np.convolve(out, k)[:n]


# --- processing --------------------------------------------------------------

def _sos(kind: str, cutoff, order: int = 4):
    nyq = SR / 2
    c = np.asarray(cutoff, dtype=float) / nyq
    c = np.clip(c, 1e-4, 0.999)
    return signal.butter(order, c, btype=kind, output="sos")


def lowpass(x, cutoff, order=4):
    return signal.sosfilt(_sos("lowpass", cutoff, order), x)


def highpass(x, cutoff, order=4):
    return signal.sosfilt(_sos("highpass", cutoff, order), x)


def bandpass(x, lo, hi, order=4):
    return signal.sosfilt(_sos("bandpass", [lo, hi], order), x)


def sweep_lowpass(x: np.ndarray, start_hz: float, end_hz: float, chunks: int = 64) -> np.ndarray:
    """Time-varying low-pass by filtering overlapping chunks (cheap, no zipper)."""
    out = np.zeros_like(x)
    n = len(x)
    size = max(n // chunks, 256)
    win = np.hanning(size * 2)
    for k, start in enumerate(range(0, n, size)):
        seg = x[max(0, start - size // 2): start + size + size // 2]
        cutoff = start_hz * (end_hz / start_hz) ** (start / max(n - 1, 1))
        y = lowpass(seg, cutoff, 2)
        w = np.hanning(len(y))
        a = max(0, start - size // 2)
        out[a:a + len(y)] += y * w
    return out


def reverb(x: np.ndarray, rt60: float = 1.2, mix: float = 0.25, seed: int = 1, predelay: float = 0.012) -> np.ndarray:
    """Convolution with exponentially decaying filtered noise (small, soft room)."""
    ir_len = rt60 * 1.2
    t = time_axis(ir_len)
    ir = noise(ir_len, "pink", seed) * np.exp(-6.9 * t / rt60)
    ir = lowpass(ir, 6000, 2)
    ir = np.concatenate([np.zeros(n_samples(predelay)), ir])
    ir /= np.sqrt(np.sum(ir ** 2)) + 1e-9
    wet = signal.fftconvolve(x, ir)[: len(x) + len(ir)]
    dry = np.pad(x, (0, len(wet) - len(x)))
    return (1 - mix) * dry + mix * wet * 0.6


def soft_clip(x: np.ndarray, drive: float = 1.5) -> np.ndarray:
    return np.tanh(x * drive) / np.tanh(drive)


def normalize(x: np.ndarray, peak_db: float = -1.0) -> np.ndarray:
    peak = np.max(np.abs(x)) + 1e-12
    return x * (10 ** (peak_db / 20) / peak)


def rms_db(x: np.ndarray) -> float:
    return 20 * np.log10(np.sqrt(np.mean(x ** 2)) + 1e-12)


def trim_silence(x: np.ndarray, thresh_db: float = -60.0) -> np.ndarray:
    thr = 10 ** (thresh_db / 20) * np.max(np.abs(x))
    idx = np.where(np.abs(x) > thr)[0]
    if len(idx) == 0:
        return x
    return x[: idx[-1] + n_samples(0.01)]


def make_loop(x: np.ndarray, xfade: float = 0.25) -> np.ndarray:
    """Crossfades the tail into the head so the file loops seamlessly."""
    k = n_samples(xfade)
    head, body, tail = x[:k], x[k:-k], x[-k:]
    ramp = np.linspace(0, 1, k)
    joined = tail * (1 - ramp) + head * ramp
    return np.concatenate([body, joined])


def mix(*parts: np.ndarray) -> np.ndarray:
    n = max(len(p) for p in parts)
    out = np.zeros(n)
    for p in parts:
        out[: len(p)] += p
    return out


def midi_hz(note: float) -> float:
    return 440.0 * 2 ** ((note - 69) / 12)


# --- output ------------------------------------------------------------------

def write_wav(path: str | Path, x: np.ndarray) -> Path:
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    pcm = np.clip(x, -1.0, 1.0)
    pcm = (pcm * 32767).astype("<i2")
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    return path
