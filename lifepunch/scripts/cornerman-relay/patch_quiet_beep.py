"""One-shot: quieter ready beep + skip beep when TTS guided. Run in cornerman-rag."""
from __future__ import annotations

import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
RELAY = os.path.join(HERE, "relay.py")

BEEP_FUNC = """def _beep_ready() -> None:
    import beep
    beep.ready()
"""

LOOP_OLD = (
    '        if guided:\n'
    '            _say("Ready.", guided=True)\n'
    '        _beep_ready()'
)
LOOP_NEW = (
    '        if guided:\n'
    '            _say("Ready.", guided=True)\n'
    '        else:\n'
    '            _beep_ready()'
)


def main() -> int:
    with open(RELAY, encoding="utf-8") as f:
        relay = f.read()

    changed: list[str] = []
    new_relay, n = re.subn(
        r"def _beep_ready\(\) -> None:[\s\S]*?(?=\ndef )",
        BEEP_FUNC + "\n\n",
        relay,
        count=1,
    )
    if n:
        relay = new_relay
        changed.append("beep func")

    if LOOP_OLD in relay:
        relay = relay.replace(LOOP_OLD, LOOP_NEW)
        changed.append("skip beep when guided")

    if changed:
        with open(RELAY, "w", encoding="utf-8", newline="\n") as f:
            f.write(relay)
        print("Patched:", ", ".join(changed))
    else:
        print("Already up to date")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
