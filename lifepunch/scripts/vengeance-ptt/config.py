"""VENGEANCE desk PTT — config (no Cornerman relay)."""
from __future__ import annotations

import os

WHISPER_URL = os.environ.get(
    "VENGEANCE_WHISPER_URL",
    "http://205.209.104.22:9000/v1/audio/transcriptions",
).strip()
WHISPER_MODEL = os.environ.get("VENGEANCE_WHISPER_MODEL", "small.en").strip()

# Substring match against sounddevice device names (case-insensitive).
INPUT_MATCH = os.environ.get("VENGEANCE_PTT_INPUT_MATCH", "AT2020").strip()
OUTPUT_MATCH = os.environ.get("VENGEANCE_PTT_OUTPUT_MATCH", "VIRTUOSO").strip()

ARM_KEY = os.environ.get("VENGEANCE_PTT_ARM_KEY", "f7").strip().lower()
TALK_KEY = os.environ.get("VENGEANCE_PTT_TALK_KEY", "f8").strip().lower()

SAMPLE_RATE = 48000
TARGET_RATE = 16000
VAD_FRAME_MS = 30
PREROLL_MS = 300
SILENCE_HANG_SECONDS = 0.45
MIN_SPEECH_SECONDS = 0.25
MAX_RECORD_SECONDS = 90.0
MAX_PTT_HOLD_SECONDS = float(os.environ.get("VENGEANCE_PTT_MAX_HOLD_SEC", "90"))
VAD_GAIN = 1.0
RMS_SPEECH_THRESHOLD = 0.006

OUTBOX_DIR = os.environ.get(
    "VENGEANCE_PTT_OUTBOX",
    os.path.join(os.path.dirname(__file__), "outbox"),
)
