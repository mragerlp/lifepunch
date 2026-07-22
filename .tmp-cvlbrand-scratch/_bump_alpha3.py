from pathlib import Path
root = Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand")
old = 'src="/cutouts/CAVELUX_wordmark_glitch.png"'
new = 'src="/cutouts/CAVELUX_wordmark_glitch.png?v=alpha3"'
for f in ["index.html", "work/index.html", "system/index.html", "legal/index.html", "about/index.html", "404.html"]:
    p = root / f
    t = p.read_text(encoding="utf-8")
    t = t.replace("v3.68", "v3.69")
    if "alpha3" not in t:
        t = t.replace(old, new)
    p.write_text(t, encoding="utf-8")
    print("ok", f)
