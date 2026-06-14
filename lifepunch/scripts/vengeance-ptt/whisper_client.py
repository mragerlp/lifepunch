"""POST audio to lifepunchnet Whisper (OpenAI-compatible)."""
from __future__ import annotations

import io
import json
import wave

import numpy as np
import requests

import config


def encode_wav_pcm16(samples: np.ndarray, sr: int = config.TARGET_RATE) -> bytes:
    samples = np.clip(samples, -1.0, 1.0)
    pcm = (samples * 32767.0).astype(np.int16)
    buf = io.BytesIO()
    with wave.open(buf, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sr)
        wf.writeframes(pcm.tobytes())
    return buf.getvalue()


def transcribe(samples: np.ndarray) -> str:
    wav = encode_wav_pcm16(samples)
    files = {"file": ("vengeance-ptt.wav", wav, "audio/wav")}
    data = {"model": config.WHISPER_MODEL}
    r = requests.post(config.WHISPER_URL, files=files, data=data, timeout=120)
    r.raise_for_status()
    try:
        payload = r.json()
        if isinstance(payload, dict):
            text = payload.get("text") or payload.get("transcript") or ""
            return str(text).strip()
    except json.JSONDecodeError:
        pass
    return r.text.strip()
