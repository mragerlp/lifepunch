# -*- coding: utf-8 -*-
from pathlib import Path
import re

root = Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand")
for rel in [
    "index.html",
    "system/index.html",
    "work/index.html",
    "about/index.html",
    "legal/index.html",
]:
    p = root / rel
    t = p.read_text(encoding="utf-8")
    t2 = re.sub(
        r'(<div class="footer-copy">)[^<]*(</div>)',
        r"\1&copy; 2026 Cavelux\2",
        t,
        count=1,
    )
    p.write_text(t2, encoding="utf-8")
    print(rel, "&copy; 2026 Cavelux" in t2)
