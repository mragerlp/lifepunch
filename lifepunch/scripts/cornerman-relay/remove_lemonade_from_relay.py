"""Strip dead AMD Lemonade STT paths from cornerman-rag relay.py (run on Cornerman)."""
from __future__ import annotations

import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RELAY = os.path.join(HERE, "relay.py")


def main() -> int:
    if not os.path.isfile(RELAY):
        print(f"skip: missing {RELAY}", file=sys.stderr)
        return 1

    with open(RELAY, encoding="utf-8") as f:
        raw = f.read()

    original = raw
    changed: list[str] = []

    raw, n = re.subn(
        r"\nLEMONADE_URL = os\.environ\.get\([\s\S]*?\)\n"
        r'LEMONADE_MODEL = os\.environ\.get\("CORNERMAN_LEMONADE_MODEL"[^\n]*\)\n',
        "\n",
        raw,
        count=1,
    )
    if n:
        changed.append("LEMONADE_* constants")

    raw, n = re.subn(
        r"\ndef transcribe_lemonade\(audio: np\.ndarray\) -> str:[\s\S]*?"
        r"return _clean\(\(payload\.get\(\"text\"\) or \"\"\)\.strip\(\)\)\n",
        "\n",
        raw,
        count=1,
    )
    if n:
        changed.append("transcribe_lemonade()")

    raw, n = re.subn(
        r"def transcribe\(\n    audio: np\.ndarray,\n    \*,\n    lemonade: bool = False,\n    remote_url: str = \"\",\n\) -> str:",
        "def transcribe(\n    audio: np.ndarray,\n    *,\n    remote_url: str = \"\",\n) -> str:",
        raw,
        count=1,
    )
    if n:
        changed.append("transcribe() signature")

    raw, n = re.subn(
        r"\n    if lemonade:\n        log_stt_path\(\"lemonade\", LEMONADE_URL\)\n"
        r"        return transcribe_lemonade\(audio\)\n",
        "\n",
        raw,
        count=1,
    )
    if n:
        changed.append("transcribe() lemonade branch")

    raw = raw.replace("lemonade=lemonade, remote_url=remote_url", "remote_url=remote_url")
    raw = raw.replace("lemonade=lemonade,", "")
    raw = raw.replace("lemonade=args.lemonade,\n        ", "")
    raw = raw.replace("lemonade: bool = False,\n    ", "")
    raw = raw.replace("    lemonade: bool,\n", "")

    raw, n = re.subn(
        r'\n    p\.add_argument\("--lemonade", action="store_true"[^\n]*\)\n',
        "\n",
        raw,
    )
    if n:
        changed.append("--lemonade arg")

    if raw == original:
        print("already clean")
        return 0

    with open(RELAY, "w", encoding="utf-8", newline="\n") as f:
        f.write(raw)

    print("patched relay.py:", ", ".join(changed) if changed else "misc lemonade refs")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
