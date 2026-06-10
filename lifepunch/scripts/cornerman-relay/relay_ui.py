"""Console layout for Cornerman voice relay — mirrors lifepunch/scripts/Voice-Console.ps1."""
from __future__ import annotations

import shutil
import sys
import textwrap
from datetime import datetime

_session_count = 0

# Keep in sync with Voice-Console.ps1 ($VoiceConsoleWidth = 64)
CONSOLE_WIDTH = 64
_LABEL_PAD = 11


def _vt() -> bool:
    if not sys.stdout.isatty():
        return False
    if sys.platform == "win32":
        try:
            import ctypes
            kernel = ctypes.windll.kernel32  # type: ignore[attr-defined]
            handle = kernel.GetStdHandle(-11)
            mode = ctypes.c_uint32()
            if kernel.GetConsoleMode(handle, ctypes.byref(mode)):
                kernel.SetConsoleMode(handle, mode.value | 0x0004)
        except Exception:  # noqa: BLE001
            return False
    return True


_VT = _vt()


def _c(code: str, text: str) -> str:
    if not _VT:
        return text
    return f"\033[{code}m{text}\033[0m"


def _width() -> int:
    """Clamp to shared console width unless terminal is narrower."""
    term = shutil.get_terminal_size(fallback=(CONSOLE_WIDTH, 24)).columns
    return max(52, min(term - 2, CONSOLE_WIDTH))


def _rule(color: str = "1;92") -> None:
    print(_c(color, "=" * _width()))


def _divider() -> None:
    print(_c("37", "-" * _width()))


def _meta(label: str, value: str) -> None:
    # Gray label + white value — readable on black (mirrors Voice-Console.ps1)
    print(
        _c("90", f"  {label.ljust(_LABEL_PAD)}  ")
        + _c("97", value)
    )


def _event(name: str, detail: str = "", *, color: str = "1;92", stamp: bool = True) -> None:
    ts = datetime.now().strftime("%H:%M:%S")
    prefix = f"  [{ts}]  " if stamp else "  "
    line = f"{prefix}{name}"
    if detail:
        line += f"  {detail}"
    print(_c(color, line))


def reset_session() -> None:
    global _session_count
    _session_count = 0


def _voice_header(title: str, subtitle: str = "") -> None:
    print()
    _rule()
    print(_c("1;92", f"  {title}"))
    if subtitle:
        print(_c("37", f"  {subtitle}"))
    _rule()
    print()


# --- PTT (default) ---------------------------------------------------------

def ptt_banner() -> None:
    _voice_header(
        "CORNERMAN VOICE RELAY  (Talk to VENGEANCE)",
        "tap F7 arm -> Ready -> hold F8 talk -> clipboard -> VENGEANCE",
    )


def ptt_mode_info(mic: str, arm_key: str, talk_key: str) -> None:
    _meta("Mode", "ARM then PUSH-TO-TALK")
    _meta("Mic", mic)
    _meta("Arm", f"tap {arm_key.upper()} when you want a round")
    _meta("Talk", f"hold {talk_key.upper()} after Ready")
    _meta("Stop", "Ctrl+C in this window")
    print()


def ptt_armed(talk_key: str) -> None:
    _event("ARMED", f"hold {talk_key.upper()} to talk")


def ptt_recording(key: str) -> None:
    _event("RECORDING", f"{key.upper()} held - release to send", color="1;91")


def clipboard_copied() -> None:
    print()
    _divider()
    _event("COPIED TO CLIPBOARD", "Ctrl+V on VENGEANCE")
    _divider()
    print()


def message_divider(n: int) -> None:
    print()
    _divider()
    print(_c("90", f"  message {n}"))


# --- Shared output ---------------------------------------------------------

def section_title(title: str) -> None:
    print()
    print(_c("1;36", f"  -- {title} " + "-" * max(0, _width() - len(title) - 6)))


def section_body(text: str) -> None:
    inner = _width() - 4
    for para in text.strip().split("\n"):
        for line in textwrap.wrap(para, width=inner) or [""]:
            print(_c("97", f"  {line}"))


def heard_preview(text: str, max_len: int = 80) -> None:
    preview = text if len(text) <= max_len else text[: max_len - 3] + "..."
    print(_c("97", f"  I HEARD: {preview}"))


def session_log(entries: list[str], title: str = "SESSION LOG") -> None:
    if not entries:
        return
    print()
    print(_c("1;35", f"  {title}"))
    for line in entries[-8:]:
        print(_c("35", f"    {line}"))
    print()


def conversation_log(entries: list[str]) -> None:
    session_log(entries)


def message_sent(n: int, text: str) -> None:
    global _session_count
    _session_count = n
    preview = text if len(text) <= 70 else text[:67] + "..."
    print(_c("90", f"  #{n} sent  |  {preview}"))


def dim(msg: str) -> None:
    print(_c("90", msg))


def warn(msg: str) -> None:
    print(_c("1;91", msg))


def success(title: str, lines: list[str]) -> None:
    print()
    _divider()
    _event(title.upper(), stamp=False)
    for ln in lines:
        for part in textwrap.wrap(ln, width=_width() - 4) or [""]:
            print(_c("92", f"  {part}"))
    _divider()
    print()


# --- Legacy wake-phrase (Talk to Vengeance Wake.cmd only) ------------------

def banner() -> None:
    ptt_banner()


def session_info(mic: str, wake_phrase: str) -> None:
    _meta("Mic", mic)
    _meta("Wake", f'say "{wake_phrase}"')
    _meta("Stop", "Ctrl+C or goodbye vengeance")
    print()


def idle_waiting(wake_phrase: str) -> None:
    print(_c("90", f'  [WAITING]  say "{wake_phrase}" to arm the mic'))


def armed_listening() -> None:
    _event("LISTENING", "say your message, then pause", color="1;93")


def next_round(n: int) -> None:
    message_divider(n)
