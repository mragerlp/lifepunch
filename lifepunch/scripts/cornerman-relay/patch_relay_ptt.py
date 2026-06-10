"""Run on Cornerman inside cornerman-rag after ptt.py + ptt_capture.py are copied."""
from __future__ import annotations

import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RELAY = os.path.join(HERE, "relay.py")
RELAY_UI = os.path.join(HERE, "relay_ui.py")
RELAY_PS1 = os.path.join(HERE, "relay.ps1")
PTT_CMD = os.path.join(HERE, "Talk to Vengeance (PTT).cmd")

PTT_BLOCK = r'''
def run_ptt_loop(
    *,
    lemonade: bool = False,
    remote_url: str = "",
    guided: bool = True,
) -> int:
    import ptt
    import ptt_capture

    ui.reset_session()
    dev = stt.pick_input_device()
    mic_name = stt.sd.query_devices(dev)["name"]
    key = ptt.key_name()

    ui.banner()
    ui.ptt_mode_info(mic_name, key)

    if guided:
        _say(
            f"Push to talk ready. Hold {key} while you speak, then release.",
            guided=True,
        )

    msg_n = 0
    while True:
        ui.ptt_idle(key)
        ptt.wait_down(ptt.vk_code())
        ui.ptt_recording(key)
        _beep_ready()
        audio = ptt_capture.record_ptt(verbose=False, vk=ptt.vk_code(), armed=True)
        if audio is None:
            continue

        try:
            text = transcribe(audio, lemonade=lemonade, remote_url=remote_url)
        except requests.RequestException as exc:
            ui.warn(f"  Transcribe error: {exc}")
            continue

        if not text:
            ui.dim("  (empty transcript - try again)")
            continue
        if _is_exit(text):
            ui.success("SESSION ENDED", ['You said "goodbye vengeance". See you next time.'])
            if guided:
                _say("Goodbye.", guided=True)
            return 0

        msg_n += 1
        if msg_n > 1:
            ui.next_round(msg_n)
        deliver(text, msg_n, guided=guided, wake_phrase=f"hold {key}")
'''

UI_SNIPPET = r'''

def ptt_mode_info(mic: str, key: str) -> None:
    print(_c("1;92", f"  Mode         PUSH-TO-TALK (hold {key.upper()})"))
    print(_c("90", f"  Mic          {mic}"))
    print(_c("90", '  End session  say "goodbye vengeance" after a send, or Ctrl+C'))
    print()


def ptt_idle(key: str) -> None:
    print()
    print(_c("1;92", f"  [PTT READY]  Hold {key.upper()} to talk, release to send"))
    print()


def ptt_recording(key: str) -> None:
    print(_c("1;91", f"  [RECORDING]  {key.upper()} held - release to send"))
    print()
'''

MAIN_HOOK = """
    if args.ptt:
        return run_ptt_loop(
            lemonade=args.lemonade,
            remote_url=remote,
            guided=guided,
        )
"""

ARG_HOOK = "    p.add_argument('--ptt', action='store_true', help='Push-to-talk (hold CORNERMAN_PTT_KEY, default F8)')"


def patch_file(path: str, raw: str) -> str:
    return raw


def main() -> int:
    changed = []

    with open(RELAY_UI, encoding="utf-8") as f:
        ui = f.read()
    if "def ptt_idle" not in ui:
        with open(RELAY_UI, "a", encoding="utf-8", newline="\n") as f:
            f.write(UI_SNIPPET)
        changed.append("relay_ui.py")

    with open(RELAY, encoding="utf-8") as f:
        relay = f.read()
    if "def run_ptt_loop" not in relay:
        relay = relay.rstrip() + "\n\n" + PTT_BLOCK.strip() + "\n"
        changed.append("relay.py (block)")
    if "--ptt" not in relay:
        relay = relay.replace(
            '    p.add_argument("--loop", action="store_true"',
            ARG_HOOK + "\n    p.add_argument(\"--loop\", action=\"store_true\"",
        )
        changed.append("relay.py (--ptt arg)")
    if "if args.ptt:" not in relay:
        relay = relay.replace("    if args.loop:", MAIN_HOOK + "    if args.loop:")
        changed.append("relay.py (main hook)")
    if "relay.py" in " ".join(changed):
        with open(RELAY, "w", encoding="utf-8", newline="\n") as f:
            f.write(relay)

    with open(RELAY_PS1, encoding="utf-8") as f:
        ps1 = f.read()
    if "PushToTalk" not in ps1:
        ps1 = ps1.replace(
            "[switch] $Loop",
            "[switch] $Loop\n    [switch] $PushToTalk",
        )
        ps1 = ps1.replace(
            "if ($Loop)       { $pyArgs += '--loop' }",
            "if ($PushToTalk) { $pyArgs += '--ptt' }\nif ($Loop)       { $pyArgs += '--loop' }",
        )
        with open(RELAY_PS1, "w", encoding="utf-8", newline="\n") as f:
            f.write(ps1)
        changed.append("relay.ps1")

    cmd = (
        "@echo off\r\n"
        "title Talk to VENGEANCE (PTT)\r\n"
        "color 0A\r\n"
        'cd /d "C:\\Projects\\cornerman-rag"\r\n'
        "cls\r\n"
        'powershell -NoProfile -ExecutionPolicy Bypass -File ".\\relay.ps1" -PushToTalk\r\n'
        "echo.\r\n"
        "pause\r\n"
    )
    with open(PTT_CMD, "w", encoding="ascii", newline="\r\n") as f:
        f.write(cmd)
    changed.append("Talk to Vengeance (PTT).cmd")

    print("Patched:", ", ".join(changed) if changed else "already up to date")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
