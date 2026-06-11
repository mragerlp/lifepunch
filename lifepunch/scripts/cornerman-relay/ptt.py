# Push-to-talk key helpers (Windows). Cornerman-local — deployed via Apply-CornermanPushToTalk.ps1
from __future__ import annotations

import ctypes
import os
import time

# Virtual-key codes (GetAsyncKeyState)
VK = {
    "space": 0x20,
    "f6": 0x75,
    "f7": 0x76,
    "f8": 0x77,
    "f9": 0x78,
    "f10": 0x79,
    "f11": 0x7A,
    "f12": 0x7B,
    "scrolllock": 0x91,
    "pause": 0x13,
}


def key_name() -> str:
    return os.environ.get("CORNERMAN_PTT_KEY", "f8").strip().lower()


def arm_key_name() -> str:
    return os.environ.get("CORNERMAN_ARM_KEY", "f7").strip().lower()


def vk_code(name: str | None = None) -> int:
    n = (name or key_name()).strip().lower()
    if n not in VK:
        raise ValueError(f"Unknown key={n!r} - use: {', '.join(sorted(VK))}")
    return VK[n]


def arm_vk_code() -> int:
    return vk_code(arm_key_name())


def is_down(vk: int) -> bool:
    return bool(ctypes.windll.user32.GetAsyncKeyState(vk) & 0x8000)


def is_released(vk: int, polls: int = 2, poll: float = 0.012) -> bool:
    """Treat key as up only after consecutive up samples (debounce bounce/RDP glitches)."""
    for _ in range(max(1, polls)):
        if is_down(vk):
            return False
        time.sleep(poll)
    return True


def wait_down(vk: int, poll: float = 0.02) -> None:
    while not is_down(vk):
        time.sleep(poll)


def wait_tap(vk: int, poll: float = 0.02) -> None:
    """Block until the key is pressed and released once."""
    while not is_down(vk):
        time.sleep(poll)
    while is_down(vk):
        time.sleep(poll)


def wait_up(vk: int, poll: float = 0.02) -> None:
    while is_down(vk):
        time.sleep(poll)
