# Structured voice conversation log (local NDJSON) for Cornerman + lifepunchnet sync.
from __future__ import annotations

import json
import os
from datetime import datetime, timezone
from typing import Any

HERE = os.path.dirname(os.path.abspath(__file__))
OUTBOX = os.path.join(HERE, "outbox")
LOG_PATH = os.path.join(OUTBOX, "conversation.ndjson")


def _ts() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def log_turn(
    *,
    channel: str,
    user_text: str,
    ai_text: str | None = None,
    agent: str | None = None,
    intent: dict[str, Any] | None = None,
    project: str | None = None,
    stt: str | None = None,
    tags: list[str] | None = None,
) -> dict[str, Any]:
    os.makedirs(OUTBOX, exist_ok=True)
    entry: dict[str, Any] = {
        "ts": _ts(),
        "channel": channel,
        "user_text": user_text,
        "ai_text": ai_text,
        "agent": agent or (intent or {}).get("agent"),
        "intent": (intent or {}).get("action"),
        "project": project or (intent or {}).get("project"),
        "stt": stt,
        "tags": tags or ["voice"],
    }
    if intent:
        entry["intent_detail"] = intent
    line = json.dumps(entry, ensure_ascii=False)
    with open(LOG_PATH, "a", encoding="utf-8", newline="\n") as f:
        f.write(line + "\n")
    return entry
