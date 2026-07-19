# -*- coding: utf-8 -*-
from pathlib import Path

root = Path(__file__).resolve().parent
for rel in [
    "index.html",
    "system/index.html",
    "work/index.html",
    "about/index.html",
    "legal/index.html",
]:
    t = (root / rel).read_text(encoding="utf-8")
    title = next(l.strip() for l in t.splitlines() if "<title>" in l)
    assert "noindex" in t, rel
    assert "CAVELUX" in t, rel
    assert "Collaborative Value Loop" in t, rel
    assert "cavelux.ai" in t, rel
    assert "collaborativevalueloop.com" not in t, rel
    assert "2026 Cavelux" in t, rel
    assert "v3.50" in title, rel
    print(rel, "|", title)
print("SENSOR_OK")
