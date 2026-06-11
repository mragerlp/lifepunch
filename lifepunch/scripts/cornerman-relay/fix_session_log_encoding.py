"""One-shot patch: robust load_session_log + UTF-8 rewrite of session.log. Run in cornerman-rag."""
from __future__ import annotations

import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
RELAY = os.path.join(HERE, "relay.py")
SESSION_LOG = os.path.join(HERE, "outbox", "session.log")

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


def _replace_function(raw: str, name: str, new_body: str) -> tuple[str, bool]:
    pattern = rf"def {name}\([\s\S]*?(?=\ndef |\nif __name__ == |\Z)"
    if not re.search(pattern, raw):
        return raw, False
    raw = re.sub(pattern, new_body.strip() + "\n\n", raw, count=1)
    return raw, True


def reencode_session_log() -> None:
    if not os.path.isfile(SESSION_LOG):
        return
    with open(SESSION_LOG, "rb") as f:
        raw = f.read()
    for encoding in ("utf-8-sig", "utf-8", "cp1252"):
        try:
            text = raw.decode(encoding)
            break
        except UnicodeDecodeError:
            continue
    else:
        text = raw.decode("utf-8", errors="replace")
    with open(SESSION_LOG, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
        if not text.endswith("\n"):
            f.write("\n")


def main() -> int:
    reencode_session_log()
    with open(RELAY, encoding="utf-8") as f:
        relay = f.read()
    relay, ok = _replace_function(relay, "load_session_log", LOAD_SESSION_LOG)
    if ok:
        with open(RELAY, "w", encoding="utf-8", newline="\n") as f:
            f.write(relay)
        print("patched load_session_log + re-encoded session.log")
    else:
        print("load_session_log already patched or not found")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
