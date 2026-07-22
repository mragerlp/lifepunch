from pathlib import Path

root = Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand")
needle_src = 'src="/cutouts/CVL_wordmark_glitch.png" alt="CVL" width="771" height="238"'
repl_src = 'src="/cutouts/CAVELUX_wordmark_glitch.png" alt="CAVELUX" width="1024" height="212"'
needle_aria = 'aria-label="CVL home"'
repl_aria = 'aria-label="Cavelux home"'

for f in ["index.html", "about/index.html", "system/index.html", "work/index.html", "legal/index.html"]:
    p = root / f
    t = p.read_text(encoding="utf-8")
    # Footer only: replace within footer-glitch context, leave hero CVL wordmark alone
    if "footer-glitch-word" not in t:
        raise SystemExit(f"no footer glitch in {f}")
    # Split on footer-glitch-word occurrences — only those lines should swap src
    parts = t.split('class="pixel footer-glitch-word"')
    if len(parts) != 2:
        raise SystemExit(f"unexpected footer count in {f}: {len(parts)-1}")
    # Fix aria on the link just before this img
    head = parts[0]
    if needle_aria not in head[-200:]:
        # still try global within last chunk
        pass
    head = head[::-1].replace(needle_aria[::-1], repl_aria[::-1], 1)[::-1]
    tail = parts[1]
    if needle_src not in tail[:180]:
        raise SystemExit(f"src needle missing after footer img in {f}: {tail[:180]!r}")
    tail = tail.replace(needle_src, repl_src, 1)
    t = 'class="pixel footer-glitch-word"'.join([head, tail])
    # Ensure hero still points at CVL if present
    t = t.replace("v3.64", "v3.65")
    p.write_text(t, encoding="utf-8")
    # sanity
    assert 'footer-glitch-word" src="/cutouts/CAVELUX_wordmark_glitch.png"' in t or \
           "footer-glitch-word\" src=\"/cutouts/CAVELUX_wordmark_glitch.png\"" in t
    hero_ok = 'hero-glitch" src="/cutouts/CVL_wordmark_glitch.png"' in t or "hero-glitch" not in t
    print("ok", f, "hero_cvl_unchanged=", hero_ok)

p404 = root / "404.html"
p404.write_text(p404.read_text(encoding="utf-8").replace("v3.64", "v3.65"), encoding="utf-8")
print("bumped 404")
