"""Run on Cornerman inside cornerman-rag after deploy copies ptt + relay_ui."""
from __future__ import annotations

import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
RELAY = os.path.join(HERE, "relay.py")
RELAY_PS1 = os.path.join(HERE, "relay.ps1")
PRIMARY_CMD = os.path.join(HERE, "Talk to Vengeance.cmd")
PTT_CMD = os.path.join(HERE, "Talk to Vengeance (PTT).cmd")
WAKE_CMD = os.path.join(HERE, "Talk to Vengeance (Wake).cmd")

PTT_CMD_BODY = (
    "@echo off\r\n"
    "title Talk to VENGEANCE\r\n"
    "color 0A\r\n"
    'cd /d "C:\\Projects\\cornerman-rag"\r\n'
    "cls\r\n"
    'powershell -NoProfile -ExecutionPolicy Bypass -File ".\\relay.ps1" -PushToTalk\r\n'
    "echo.\r\n"
    "pause\r\n"
)

WAKE_CMD_BODY = (
    "@echo off\r\n"
    "title Talk to VENGEANCE (Wake - legacy)\r\n"
    "color 0A\r\n"
    'cd /d "C:\\Projects\\cornerman-rag"\r\n'
    "cls\r\n"
    'powershell -NoProfile -ExecutionPolicy Bypass -File ".\\relay.ps1" -Loop\r\n'
    "echo.\r\n"
    "pause\r\n"
)

RUN_PTT_LOOP = '''
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
    arm_key = ptt.arm_key_name()
    talk_key = ptt.key_name()
    arm_vk = ptt.arm_vk_code()
    talk_vk = ptt.vk_code(talk_key)

    ui.ptt_banner()
    ui.ptt_mode_info(mic_name, arm_key, talk_key)

    msg_n = 0
    while True:
        # Silent until you tap ARM — you decide when Cornerman should listen.
        ptt.wait_tap(arm_vk)

        ui.ptt_armed(talk_key)
        if guided:
            _say("Ready.", guided=True)
        _beep_ready()

        ptt.wait_down(talk_vk)
        ui.ptt_recording(talk_key)

        def _on_release() -> None:
            ui.ptt_released(talk_key)

        audio = ptt_capture.record_ptt(
            verbose=False,
            vk=talk_vk,
            armed=True,
            on_release=_on_release,
        )
        if audio is None:
            ui.dim("  (no audio — tap F7 to arm again)")
            continue

        ui.ptt_transcribing()

        try:
            text = transcribe(audio, lemonade=lemonade, remote_url=remote_url)
        except requests.RequestException as exc:
            ui.warn(f"  Transcribe error: {exc}")
            continue

        if not text:
            ui.dim("  (empty — tap arm again or hold talk key and speak)")
            continue
        if _is_exit(text):
            ui.success("SESSION ENDED", ['You said "goodbye vengeance". See you next time.'])
            if guided:
                _say("Goodbye.", guided=True)
            return 0

        msg_n += 1
        if msg_n > 1:
            ui.message_divider(msg_n)
        deliver(text, msg_n, guided=guided, ptt_key=talk_key)
'''.strip()

SHOW_CLIPBOARD = '''
def show_clipboard(
    *,
    guided: bool,
    wake_phrase: str = "",
    ptt_key: str | None = None,
) -> None:
    if ptt_key:
        ui.clipboard_copied()
        if guided:
            _say("Copied. Paste in Cursor.", guided=True)
        return
    ui.success(
        "CLIPBOARD",
        [
            "Copied for VENGEANCE — paste into Cursor.",
            f'Say "{wake_phrase}" when you want to send another.',
        ],
    )
    if guided:
        _say(
            f"Copied. Paste in Cursor. Say {wake_phrase} when you have another.",
            guided=True,
        )
'''.strip()

SHOW_HEARD = '''
def show_heard(text: str, *, guided: bool) -> None:
    ui.heard_preview(text)
    if guided:
        short = text if len(text) <= 100 else "Got it. Full text is on screen."
        _say(short, guided=True)
'''.strip()

LOAD_SESSION_LOG = '''
def load_session_log() -> list[str]:
    if not os.path.isfile(SESSION_LOG):
        return []
    with open(SESSION_LOG, "rb") as f:
        raw = f.read()
    text = None
    for encoding in ("utf-8-sig", "utf-8", "cp1252"):
        try:
            text = raw.decode(encoding)
            break
        except UnicodeDecodeError:
            continue
    if text is None:
        text = raw.decode("utf-8", errors="replace")
    return [ln.rstrip() for ln in text.splitlines() if ln.strip()]
'''.strip()

DELIVER_SIG = (
    "def deliver(text: str, n: int, *, guided: bool, wake_phrase: str = \"\", "
    "ptt_key: str | None = None) -> None:"
)

MAIN_HOOK = """
    if args.ptt:
        return run_ptt_loop(
            lemonade=args.lemonade,
            remote_url=remote,
            guided=guided,
        )
"""

ARG_HOOK = (
    "    p.add_argument('--ptt', action='store_true', "
    "help='Push-to-talk (hold CORNERMAN_PTT_KEY, default F8)')"
)


def _replace_function(raw: str, name: str, new_body: str) -> tuple[str, bool]:
    pattern = rf"def {name}\([\s\S]*?(?=\ndef |\nif __name__ == |\Z)"
    if not re.search(pattern, raw):
        return raw, False
    raw = re.sub(pattern, new_body.strip() + "\n\n", raw, count=1)
    return raw, True


def _strip_trailing_ptt(raw: str) -> tuple[str, bool]:
    """Remove run_ptt_loop accidentally appended after __main__."""
    marker = 'if __name__ == "__main__":'
    idx = raw.rfind(marker)
    if idx < 0:
        return raw, False
    tail = raw[idx:]
    if "def run_ptt_loop" not in tail:
        return raw, False
    head = raw[:idx]
    tail = re.sub(r"\ndef run_ptt_loop[\s\S]*$", "\n", tail)
    return head + tail, True


def _ensure_ptt_before_main(raw: str) -> tuple[str, bool]:
    if "def run_ptt_loop" in raw.split("def main()")[0]:
        return raw, False
    raw, _ = _strip_trailing_ptt(raw)
    raw = raw.replace("def main() -> int:", RUN_PTT_LOOP + "\n\n\ndef main() -> int:", 1)
    return raw, True


def main() -> int:
    changed: list[str] = []

    with open(RELAY, encoding="utf-8") as f:
        relay = f.read()

    relay, ok = _strip_trailing_ptt(relay)
    if ok:
        changed.append("relay.py (drop trailing ptt)")

    if "def run_ptt_loop" not in relay.split("def main()")[0]:
        relay, ok = _ensure_ptt_before_main(relay)
        if ok:
            changed.append("relay.py (ptt before main)")
    elif "wait_tap" not in relay or "on_release" not in relay:
        relay, ok = _replace_function(relay, "run_ptt_loop", RUN_PTT_LOOP)
        if ok:
            changed.append("relay.py (arm+ptt loop)")

    if "ptt_key: str | None" not in relay:
        relay = relay.replace(
            "def deliver(text: str, n: int, *, guided: bool, wake_phrase: str) -> None:",
            DELIVER_SIG,
        )
        relay = relay.replace(
            "show_clipboard(guided=guided, wake_phrase=wake_phrase)",
            "show_clipboard(guided=guided, wake_phrase=wake_phrase, ptt_key=ptt_key)",
        )
        changed.append("relay.py (deliver ptt_key)")
    if "ui.clipboard_copied" not in relay or "ptt_ready_line" in relay or "wait_tap" not in relay:
        relay, ok = _replace_function(relay, "show_clipboard", SHOW_CLIPBOARD)
        if ok:
            changed.append("relay.py (show_clipboard)")
    if "ui.heard_preview" not in relay:
        relay, ok = _replace_function(relay, "show_heard", SHOW_HEARD)
        if ok:
            changed.append("relay.py (show_heard)")

    if 'errors="replace"' not in relay and "cp1252" not in relay:
        relay, ok = _replace_function(relay, "load_session_log", LOAD_SESSION_LOG)
        if ok:
            changed.append("relay.py (load_session_log encoding)")

    if "--ptt" not in relay:
        relay = relay.replace(
            '    p.add_argument("--loop", action="store_true"',
            ARG_HOOK + "\n    p.add_argument(\"--loop\", action=\"store_true\"",
        )
        changed.append("relay.py (--ptt arg)")
    if "if args.ptt:" not in relay:
        relay = relay.replace("    if args.loop:", MAIN_HOOK + "    if args.loop:")
        changed.append("relay.py (main hook)")

    settle_needle = "    if prefilled:\n        return prefilled\n\n    ui.armed_listening()"
    settle_patch = (
        "    if prefilled:\n        return prefilled\n\n"
        "    import config\n"
        "    import time\n"
        "    time.sleep(config.SETTLE_SECONDS)\n\n"
        "    ui.armed_listening()"
    )
    if settle_needle in relay:
        relay = relay.replace(settle_needle, settle_patch)
        changed.append("relay.py (wake settle)")

    if changed:
        with open(RELAY, "w", encoding="utf-8", newline="\n") as f:
            f.write(relay)

    with open(RELAY_PS1, encoding="utf-8") as f:
        ps1 = f.read()
    ps1_changed = False
    if "[switch] $Loop\n    [switch] $PushToTalk" in ps1:
        ps1 = ps1.replace(
            "[switch] $Loop\n    [switch] $PushToTalk",
            "[switch] $Loop,\n    [switch] $PushToTalk",
        )
        ps1_changed = True
    if "PushToTalk" not in ps1:
        ps1 = ps1.replace(
            "[switch] $Loop",
            "[switch] $Loop,\n    [switch] $PushToTalk",
        )
        ps1 = ps1.replace(
            "if ($Loop)       { $pyArgs += '--loop' }",
            "if ($PushToTalk) { $pyArgs += '--ptt' }\nif ($Loop)       { $pyArgs += '--loop' }",
        )
        ps1_changed = True
    if "-not $Loop)" in ps1 and "-not $PushToTalk" not in ps1:
        ps1 = ps1.replace(
            "if (-not $Loop) {",
            "if (-not $Loop -and -not $PushToTalk) {",
        )
        ps1_changed = True
    if ps1_changed:
        with open(RELAY_PS1, "w", encoding="utf-8", newline="\n") as f:
            f.write(ps1)
        changed.append("relay.ps1")

    for path, body, label in (
        (PRIMARY_CMD, PTT_CMD_BODY, "Talk to Vengeance.cmd"),
        (PTT_CMD, PTT_CMD_BODY, "Talk to Vengeance (PTT).cmd"),
        (WAKE_CMD, WAKE_CMD_BODY, "Talk to Vengeance (Wake).cmd"),
    ):
        with open(path, "w", encoding="ascii", newline="\r\n") as f:
            f.write(body)
        changed.append(label)

    print("Patched:", ", ".join(changed) if changed else "already up to date")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
