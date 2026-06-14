#!/usr/bin/env python3
"""VENGEANCE desk PTT — AT2020 USB+ -> lifepunchnet Whisper -> clipboard -> Cursor."""
from __future__ import annotations

import os
import subprocess
import sys
from datetime import datetime, timezone

import audio_devices
import capture
import config
import ptt_keys
import whisper_client

CONSOLE_WIDTH = 64


def _rule() -> None:
    print("=" * CONSOLE_WIDTH)


def _meta(label: str, value: str) -> None:
    print(f"  {label.ljust(11)}  {value}")


def _event(name: str, detail: str = "") -> None:
    ts = datetime.now().strftime("%H:%M:%S")
    line = f"  [{ts}]  {name}"
    if detail:
        line += f"  {detail}"
    print(line)


def _set_clipboard(text: str) -> None:
    if sys.platform == "win32":
        subprocess.run(
            ["powershell", "-NoProfile", "-Command", "$input | Set-Clipboard"],
            input=text,
            text=True,
            encoding="utf-8",
            check=False,
        )
    else:
        subprocess.run(["clip"], input=text.encode("utf-8"), check=False)


def _write_outbox(text: str) -> str:
    os.makedirs(config.OUTBOX_DIR, exist_ok=True)
    path = os.path.join(config.OUTBOX_DIR, "to-cursor.txt")
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    log_path = os.path.join(config.OUTBOX_DIR, "ptt.log")
    stamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    with open(log_path, "a", encoding="utf-8", newline="\n") as f:
        f.write(f"{stamp}\t{text}\n")
    return path


def list_devices() -> int:
    print("Input devices:")
    for idx, name in audio_devices.list_input_devices():
        mark = ""
        if config.INPUT_MATCH.lower() in name.lower():
            mark = "  <-- match"
        print(f"  [{idx}] {name}{mark}")
    out_idx, out_name = audio_devices.pick_output_device()
    print(f"\nOutput (listen): [{out_idx}] {out_name}")
    try:
        in_idx, in_name = audio_devices.pick_input_device()
        print(f"\nSelected input: [{in_idx}] {in_name}")
    except RuntimeError as exc:
        print(f"\nNo input: {exc}")
        return 1
    return 0


def run_ptt() -> int:
    in_idx, in_name = audio_devices.pick_input_device()
    out_idx, out_name = audio_devices.pick_output_device()
    audio_devices.configure_stream_devices(in_idx, out_idx)

    print()
    _rule()
    print("  VENGEANCE VOICE PTT  (desk — no Cornerman)")
    print("  F7 arm -> Ready -> hold F8 -> lifepunchnet Whisper -> clipboard")
    _rule()
    print()
    _meta("Input", in_name)
    _meta("Output", out_name)
    _meta("Whisper", config.WHISPER_URL)
    _meta("Arm", f"tap {config.ARM_KEY.upper()}")
    _meta("Talk", f"hold {config.TALK_KEY.upper()} after Ready")
    _meta("Stop", "Ctrl+C")
    print()
    print("  Focus this window while using PTT keys.")
    print()

    while True:
        _event("WAITING", f"tap {config.ARM_KEY.upper()} to arm")
        ptt_keys.wait_tap(ptt_keys.arm_vk())
        _event("ARMED", f"hold {config.TALK_KEY.upper()} to talk")
        ptt_keys.wait_down(ptt_keys.talk_vk())
        _event("RECORDING", f"{config.TALK_KEY.upper()} held — release to send")

        def on_release() -> None:
            _event("RELEASED", f"{config.TALK_KEY.upper()} up")

        audio = capture.record_ptt(
            device_idx=in_idx,
            armed=True,
            on_release=on_release,
        )
        if audio is None:
            _event("SKIP", "no usable audio — tap F7 to retry")
            continue

        _event("TRANSCRIBING", "lifepunchnet Whisper")
        try:
            text = whisper_client.transcribe(audio)
        except Exception as exc:  # noqa: BLE001
            _event("ERROR", str(exc))
            continue

        if not text:
            _event("SKIP", "empty transcript")
            continue

        _write_outbox(text)
        _set_clipboard(text)
        _event("CLIPBOARD", "paste Ctrl+V into Cursor")
        print()
        print("--- transcript ---")
        print(text)
        print("------------------")
        print()


def main() -> int:
    if len(sys.argv) > 1 and sys.argv[1] == "--list-devices":
        return list_devices()
    try:
        run_ptt()
    except KeyboardInterrupt:
        print("\n  Stopped.")
        return 0
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
