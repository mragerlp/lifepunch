"""Pick AT2020 USB+ input and Virtuoso output on VENGEANCE."""
from __future__ import annotations

import sounddevice as sd

import config


def _match(name: str, needle: str) -> bool:
    return needle.lower() in (name or "").lower()


def list_input_devices() -> list[tuple[int, str]]:
    out: list[tuple[int, str]] = []
    for i, dev in enumerate(sd.query_devices()):
        if dev["max_input_channels"] > 0:
            out.append((i, dev["name"]))
    return out


def pick_input_device() -> tuple[int, str]:
    devices = list_input_devices()
    needles = [config.INPUT_MATCH, "Audio-Technica", "AT2020"]
    seen: set[str] = set()
    for needle in needles:
        if not needle or needle in seen:
            continue
        seen.add(needle)
        for idx, name in devices:
            if _match(name, needle):
                return idx, name
    if devices:
        idx, name = devices[0]
        return idx, name
    raise RuntimeError("No audio input devices found")


def pick_output_device() -> tuple[int | None, str]:
    for i, dev in enumerate(sd.query_devices()):
        if dev["max_output_channels"] > 0 and _match(dev["name"], config.OUTPUT_MATCH):
            return i, dev["name"]
    return None, "(system default)"


def configure_stream_devices(input_idx: int, output_idx: int | None) -> None:
    if output_idx is not None:
        sd.default.device = (input_idx, output_idx)
    else:
        sd.default.device = input_idx
