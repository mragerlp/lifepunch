# Quiet UI beeps for Cornerman voice relay (Talk to Vengeance).
from __future__ import annotations

import os


def _volume() -> float:
    raw = os.environ.get("CORNERMAN_BEEP_VOLUME", "0.12").strip()
    try:
        return max(0.0, min(1.0, float(raw)))
    except ValueError:
        return 0.12


def ready() -> None:
    """Short low-amplitude chirp when TTS is off; skip when volume is 0."""
    vol = _volume()
    if vol <= 0:
        return
    try:
        import numpy as np
        import sounddevice as sd

        fs = 48_000
        dur = 0.09
        freq = 620.0
        n = int(fs * dur)
        t = np.linspace(0, dur, n, False, dtype=np.float32)
        attack = np.minimum(1.0, t / 0.012)
        release = np.minimum(1.0, (dur - t) / 0.018)
        env = attack * release
        wave = (vol * env * np.sin(2 * np.pi * freq * t)).astype(np.float32)
        sd.play(wave, fs, blocking=True)
    except Exception:  # noqa: BLE001
        import winsound

        # Fallback: one short tone (legacy was two long high beeps).
        winsound.Beep(600, 45)
