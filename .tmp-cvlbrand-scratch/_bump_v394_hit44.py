from pathlib import Path

root = Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand")
files = list(root.glob("**/index.html")) + [root / "404.html"]

old_cta = """    .nav-cta {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
      padding: 0.6rem 1.15rem;"""

new_cta = """    .nav-cta {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
      box-sizing: border-box;
      min-height: 44px;
      padding: 0.6rem 1.15rem;"""

for f in files:
    t = f.read_text(encoding="utf-8")
    orig = t
    hits = []
    if "v3.93" in t:
        t = t.replace("v3.93", "v3.94")
        hits.append("ver")
    if f.name != "system" and "system" not in str(f).replace("\\", "/").split("/")[-2:]:
        # system already patched; patch nav-cta on other pages
        pass
    # Always try nav-cta (system may already have min-height)
    if "min-height: 44px;\n      padding: 0.6rem 1.15rem;" not in t and old_cta in t:
        t = t.replace(old_cta, new_cta)
        hits.append("cta")
    elif "min-height: 44px;\n      padding: 0.6rem 1.15rem;" in t:
        hits.append("cta-already")
    else:
        if ".nav-cta" in t:
            hits.append("cta-miss")
    if t != orig:
        f.write_text(t, encoding="utf-8")
        print("PATCHED", f.relative_to(root), hits)
    else:
        print("NOCHANGE", f.relative_to(root), hits)
