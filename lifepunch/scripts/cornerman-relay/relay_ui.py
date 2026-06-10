"""Console layout for Talk to VENGEANCE — push-to-talk first, event-driven output."""
from __future__ import annotations

import shutil
import sys
import textwrap

_session_count = 0


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
    w = shutil.get_terminal_size(fallback=(72, 24)).columns
    return max(52, min(w - 2, 78))


def reset_session() -> None:
    global _session_count
    _session_count = 0


# --- PTT (default) ---------------------------------------------------------

def ptt_banner() -> None:
    w = _width()
    title = " TALK TO VENGEANCE "
    sub = " hold key -> speak -> clipboard -> paste in Cursor "
    bar = "=" * w
    print()
    print(_c("1;96", bar))
    print(_c("1;96", title.center(w)))
    print(_c("96", sub.center(w)))
    print(_c("1;96", bar))


def ptt_mode_info(mic: str, key: str) -> None:
    print(_c("1;92", f"  Mode         PUSH-TO-TALK (hold {key.upper()})"))
    print(_c("90", f"  Mic          {mic}"))
    print(_c("90", "  End session  Ctrl+C, or say goodbye vengeance in a message"))
    print()


def ptt_ready_line(key: str) -> None:
    """Single quiet ready cue — no WAITING boxes, no log spam."""
    print(_c("1;92", f"  [READY]  Hold {key.upper()} when you want to talk"))


def ptt_recording(key: str) -> None:
    print(_c("1;91", f"  [RECORDING]  {key.upper()} held — release to send"))


def clipboard_ready(ptt_key: str) -> None:
    w = _width()
    print()
    print(_c("1;92", "+" + "-" * (w - 2) + "+"))
    print(_c("1;92", "|" + "  CLIPBOARD READY  ".center(w - 2) + "|"))
    for ln in (
        "Copied to clipboard — paste into Cursor (Ctrl+V).",
        f"Hold {ptt_key.upper()} when you have another message.",
    ):
        for part in textwrap.wrap(ln, width=w - 6) or [""]:
            print(_c("92", "|  " + part.ljust(w - 5) + "|"))
    print(_c("1;92", "+" + "-" * (w - 2) + "+"))
    print()


def message_divider(n: int) -> None:
    print()
    print(_c("90", "-" * _width()))
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


def conversation_log(entries: list[str]) -> None:
    if not entries:
        return
    print()
    print(_c("1;35", "  CONVERSATION THIS SESSION"))
    for line in entries[-8:]:
        print(_c("35", f"  {line}"))
    print()


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
    w = _width()
    print()
    print(_c("1;92", "+" + "-" * (w - 2) + "+"))
    print(_c("1;92", "|" + f"  {title}  ".center(w - 2) + "|"))
    for ln in lines:
        for part in textwrap.wrap(ln, width=w - 6) or [""]:
            print(_c("92", "|  " + part.ljust(w - 5) + "|"))
    print(_c("1;92", "+" + "-" * (w - 2) + "+"))
    print()


# --- Legacy wake-phrase (Talk to Vengeance Wake.cmd only) ------------------

def banner() -> None:
    ptt_banner()


def session_info(mic: str, wake_phrase: str) -> None:
    print(_c("90", f"  Mic          {mic}"))
    print(_c("90", f'  Wake phrase  say "{wake_phrase}"'))
    print(_c("90", '  End session  say "goodbye vengeance"  (or Ctrl+C)'))
    print()


def idle_waiting(wake_phrase: str) -> None:
    print(_c("90", f'  [WAITING]  say "{wake_phrase}" to arm the mic'))


def armed_listening() -> None:
    print(_c("1;93", "  [LISTENING]  say your message, then pause"))


def next_round(n: int) -> None:
    message_divider(n)
