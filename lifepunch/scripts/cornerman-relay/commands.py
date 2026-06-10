# Natural spoken command parser for Cornerman voice network.
from __future__ import annotations

import re
from typing import Any

PREFIX_RE = re.compile(r"^cornerman[,\s]+", re.IGNORECASE)

# phrase substring -> (action, default_agent, extra fields)
_PHRASES: list[tuple[str, str, str, dict[str, Any]]] = [
    ("summarize this", "summarize", "cornerman", {}),
    ("open the dxrp project", "open_project", "router", {"project": "dxrp"}),
    ("open dxrp", "open_project", "router", {"project": "dxrp"}),
    ("send this to the finance ai", "route_agent", "finance", {}),
    ("send to finance", "route_agent", "finance", {}),
    ("remember this for the lifepunch site", "remember", "shottaweb", {"project": "website"}),
    ("remember for the website", "remember", "shottaweb", {"project": "website"}),
    ("explain this like i'm new", "explain_eli5", "cornerman", {}),
    ("explain like i'm new", "explain_eli5", "cornerman", {}),
    ("send message", "vengeance_paste", "vengeance", {}),
]


def strip_prefix(text: str) -> str:
    t = (text or "").strip()
    return PREFIX_RE.sub("", t).strip() or t


def parse(text: str) -> dict[str, Any]:
    """Return intent dict: action, agent, payload, optional project/tags."""
    raw = (text or "").strip()
    body = strip_prefix(raw)
    low = body.lower()

    for phrase, action, agent, extra in _PHRASES:
        if low == phrase or phrase in low:
            return {
                "action": action,
                "agent": agent,
                "payload": body,
                "matched_phrase": phrase,
                **extra,
            }

    return {
        "action": "freeform",
        "agent": "cornerman",
        "payload": body or raw,
    }
