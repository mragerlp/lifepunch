"""Push-to-talk keys (Windows VK)."""
from __future__ import annotations

import ctypes
import time

import config

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


def vk_code(name: str) -> int:
    n = name.strip().lower()
    if n not in VK:
        raise ValueError(f"Unknown key={n!r}")
    return VK[n]


def arm_vk() -> int:
    return vk_code(config.ARM_KEY)


def talk_vk() -> int:
    return vk_code(config.TALK_KEY)


def is_down(vk: int) -> bool:
    return bool(ctypes.windll.user32.GetAsyncKeyState(vk) & 0x8000)


def is_released(vk: int, polls: int = 2, poll: float = 0.012) -> bool:
    for _ in range(max(1, polls)):
        if is_down(vk):
            return False
        time.sleep(poll)
    return True


def wait_tap(vk: int, poll: float = 0.02) -> None:
    while not is_down(vk):
        time.sleep(poll)
    while is_down(vk):
        time.sleep(poll)


def wait_down(vk: int, poll: float = 0.02) -> None:
    while not is_down(vk):
        time.sleep(poll)
