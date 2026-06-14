"""Record audio while PTT talk key is held."""
from __future__ import annotations

import queue
import time
from typing import Callable

import numpy as np
import sounddevice as sd

import config
import ptt_keys


def _working_rate(device_idx: int) -> int:
    info = sd.query_devices(device_idx)
    rate = int(info["default_samplerate"] or config.SAMPLE_RATE)
    return rate if rate >= 16000 else config.SAMPLE_RATE


def _resample_to_16k(audio: np.ndarray, sr: int) -> np.ndarray:
    if sr == config.TARGET_RATE:
        return audio.astype(np.float32)
    n_out = int(round(len(audio) * config.TARGET_RATE / sr))
    if n_out < 1:
        return np.zeros(0, np.float32)
    x_old = np.linspace(0.0, 1.0, num=len(audio), endpoint=False)
    x_new = np.linspace(0.0, 1.0, num=n_out, endpoint=False)
    return np.interp(x_new, x_old, audio).astype(np.float32)


def _rms(frame: np.ndarray) -> float:
    return float(np.sqrt(np.mean(frame.astype(np.float64) ** 2)))


def _auto_gain(audio: np.ndarray) -> np.ndarray:
    peak = float(np.max(np.abs(audio)))
    if peak < 1e-6:
        return audio
    target = 0.85
    gain = min(4.0, target / peak)
    return np.clip(audio * gain, -1.0, 1.0).astype(np.float32)


def _is_speech(frame: np.ndarray) -> bool:
    return _rms(frame) >= config.RMS_SPEECH_THRESHOLD


def record_ptt(
    *,
    device_idx: int,
    vk: int | None = None,
    armed: bool = True,
    on_release: Callable[[], None] | None = None,
    verbose: bool = True,
) -> np.ndarray | None:
    vk = ptt_keys.talk_vk() if vk is None else vk
    sr = _working_rate(device_idx)
    frame_len = int(sr * config.VAD_FRAME_MS / 1000)
    frame_dt = config.VAD_FRAME_MS / 1000.0
    q: queue.Queue = queue.Queue()

    def _cb(indata, frames, time_info, status):  # noqa: ARG001
        q.put(indata[:, 0].copy())

    stream = sd.InputStream(
        samplerate=sr,
        channels=1,
        dtype="float32",
        device=device_idx,
        blocksize=frame_len,
        callback=_cb,
    )

    if not armed:
        ptt_keys.wait_tap(vk)
    stream.start()

    captured: list[np.ndarray] = []
    buf = np.zeros(0, np.float32)
    total = 0.0
    silence_secs = 0.0
    released = False
    release_at = 0.0
    hold_started = time.time()

    def _mark_released(*, forced: bool = False) -> None:
        nonlocal released, release_at
        if released:
            return
        released = True
        release_at = time.time()
        if forced and verbose:
            print("  (max hold — sending)")
        if on_release:
            on_release()

    try:
        while True:
            try:
                chunk = q.get(timeout=1.0)
            except queue.Empty:
                if not released:
                    if time.time() - hold_started >= config.MAX_PTT_HOLD_SECONDS:
                        _mark_released(forced=True)
                        continue
                    if ptt_keys.is_released(vk):
                        _mark_released()
                    continue
                if time.time() - release_at >= config.SILENCE_HANG_SECONDS + 0.5:
                    raise StopIteration
                continue

            buf = np.concatenate([buf, chunk])
            while buf.size >= frame_len:
                frame = buf[:frame_len]
                buf = buf[frame_len:]
                if not released:
                    captured.append(frame)
                    total += frame_dt
                    if ptt_keys.is_released(vk):
                        _mark_released()
                    elif time.time() - hold_started >= config.MAX_PTT_HOLD_SECONDS:
                        _mark_released(forced=True)
                    continue

                captured.append(frame)
                total += frame_dt
                speech = _is_speech(frame)
                silence_secs = 0.0 if speech else silence_secs + frame_dt
                if silence_secs >= config.SILENCE_HANG_SECONDS or total >= config.MAX_RECORD_SECONDS:
                    raise StopIteration
                if time.time() - release_at >= config.SILENCE_HANG_SECONDS + 0.5 and not speech:
                    raise StopIteration
    except StopIteration:
        pass
    finally:
        stream.stop()
        stream.close()

    if not captured:
        if verbose:
            print("  (no audio)")
        return None

    speech_secs = sum(frame_dt for frame in captured if _is_speech(frame))
    if speech_secs < config.MIN_SPEECH_SECONDS:
        if verbose:
            print("  (too short)")
        return None

    audio = np.concatenate(captured).astype(np.float32)
    return _auto_gain(_resample_to_16k(audio, sr))
