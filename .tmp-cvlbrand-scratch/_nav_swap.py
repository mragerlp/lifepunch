import pathlib

ROOT = pathlib.Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand")
old = '<span class="nav-brand-sub">Collaborative Value Loop</span>'
new = '<span class="nav-brand-sub">CAVELUX</span>'
for f in ["index.html", "about/index.html", "system/index.html", "work/index.html", "legal/index.html"]:
    p = ROOT / f
    s = p.read_text(encoding="utf-8")
    n = s.count(old)
    assert n == 1, f"{f}: {n}"
    p.write_text(s.replace(old, new), encoding="utf-8")
    print(f, "nav sub -> CAVELUX")
