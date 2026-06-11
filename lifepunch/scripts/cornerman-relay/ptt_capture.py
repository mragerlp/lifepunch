# Record one utterance while a PTT key is held (release + short hang to catch word tails).
from __future__ import annotations

import collections
import os
import queue
import time
from typing import Callable

import numpy as np
import sounddevice as sd

import config
import ptt
import stt

# If F8 release is never seen (focus/RDP/key bounce), stop waiting — avoids infinite hang.
MAX_PTT_HOLD_SECONDS = float(os.environ.get("CORNERMAN_PTT_MAX_HOLD_SEC", "90"))

try:
    import webrtcvad

    _HAVE_VAD = True
except Exception:  # noqa: BLE001
    _HAVE_VAD = False


def record_ptt(
    *,
    verbose: bool = True,
    vk: int | None = None,
    armed: bool = False,
    on_release: Callable[[], None] | None = None,
) -> np.ndarray | None:
    """Record while PTT key is held; finish after release + hang. If not armed, wait for key down first."""
    vk = vk if vk is not None else ptt.vk_code()
    dev = stt.pick_input_device()
    sr = stt._working_rate(dev)
    frame_len = int(sr * config.VAD_FRAME_MS / 1000)
    frame_dt = config.VAD_FRAME_MS / 1000.0
    vad = webrtcvad.Vad(config.VAD_AGGRESSIVENESS) if _HAVE_VAD else None

    q: queue.Queue = queue.Queue()

    def _cb(indata, frames, time_info, status):  # noqa: ARG001
        q.put(indata[:, 0].copy())

    stream = sd.InputStream(
        samplerate=sr,
        channels=1,
        dtype="float32",
        device=dev,
        blocksize=frame_len,
        callback=_cb,
    )

    if verbose and not armed:
        print(f"  (PTT - hold {ptt.key_name().upper()} to talk)")

    if not armed:
        ptt.wait_down(vk)
    stream.start()

    pre_frames = max(1, int(config.PREROLL_MS / config.VAD_FRAME_MS))
    preroll: collections.deque = collections.deque(maxlen=pre_frames)
    captured: list = []
    buf = np.zeros(0, np.float32)
    total = 0.0
    silence_secs = 0.0
    released = False
    release_at = 0.0
    hold_started = time.time()

    def is_speech(frame: np.ndarray) -> bool:
        if vad is not None:
            return vad.is_speech(stt._to_pcm16(frame, config.VAD_GAIN), sr)
        lvl = stt._rms(frame)
        return lvl >= 0.006

    def _mark_released(*, forced: bool = False) -> None:
        nonlocal released, release_at
        if released:
            return
        released = True
        release_at = time.time()
        captured.extend(preroll)
        if forced and verbose:
            print("  (PTT — max hold reached; sending anyway)")
        if on_release:
            on_release()

    try:
        while True:
            try:
                chunk = q.get(timeout=1.0)
            except queue.Empty:
                if not released:
                    if time.time() - hold_started >= MAX_PTT_HOLD_SECONDS:
                        _mark_released(forced=True)
                        continue
                    if ptt.is_released(vk):
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
                    preroll.append(frame)
                    if ptt.is_released(vk):
                        _mark_released()
                    elif time.time() - hold_started >= MAX_PTT_HOLD_SECONDS:
                        _mark_released(forced=True)
                    continue

                captured.append(frame)
                total += frame_dt
                speech = is_speech(frame)
                silence_secs = 0.0 if speech else silence_secs + frame_dt
                hang_elapsed = time.time() - release_at
                if silence_secs >= config.SILENCE_HANG_SECONDS or total >= config.MAX_RECORD_SECONDS:
                    raise StopIteration
                if hang_elapsed >= config.SILENCE_HANG_SECONDS + 0.5 and not speech:
                    raise StopIteration
    except StopIteration:
        pass
    finally:
        stream.stop()
        stream.close()

    if not captured:
        if verbose:
            print("  (PTT — no audio captured)")
        return None

    audio = np.concatenate(captured).astype(np.float32)
    speech_secs = max(0.0, total - silence_secs)
    if speech_secs < config.MIN_SPEECH_SECONDS:
        if verbose:
            print("  (PTT — too short)")
        return None

    audio = stt._resample_to_16k(audio, sr)
    audio = stt._auto_gain(audio)
    return audio
