"""Apply Codex REVISE CVL-390-1..4 across .tmp-cvlbrand pages."""
from pathlib import Path

root = Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand")

OLD_OVERFLOW = """      html, body {
        overflow-x: hidden;
      }"""
NEW_OVERFLOW = """      html {
        overflow-x: hidden;
      }
      body {
        overflow-x: clip;
      }"""

OLD_DRAWER = """      .nav-links.is-open > li > a {
        font-size: 1.15rem;
        letter-spacing: 0.05em;
        line-height: 1.25;
        padding: 0.2rem 0;
      }"""
NEW_DRAWER = """      .nav-links.is-open > li > a {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        min-width: 44px;
        min-height: 44px;
        box-sizing: border-box;
        font-size: 1.15rem;
        letter-spacing: 0.05em;
        line-height: 1.25;
        padding: 0.2rem 0;
      }"""

for f in sorted(root.rglob("*.html")):
    t = f.read_text(encoding="utf-8")
    n = t
    if OLD_OVERFLOW in n:
        n = n.replace(OLD_OVERFLOW, NEW_OVERFLOW)
        print("overflow", f.relative_to(root))
    elif "overflow-x: clip" in n:
        print("overflow already", f.relative_to(root))
    else:
        # may not have mobile polish block (404?)
        if "overflow-x: hidden" in n and "max-width: 900px" in n:
            print("OVERFLOW MISS", f.relative_to(root))

    if OLD_DRAWER in n:
        n = n.replace(OLD_DRAWER, NEW_DRAWER)
        print("drawer", f.relative_to(root))
    elif "min-height: 44px" in n and ".nav-links.is-open > li > a" in n:
        # check if already applied in that block
        if "nav-links.is-open > li > a {\n        display: inline-flex" in n:
            print("drawer already", f.relative_to(root))
        else:
            print("DRAWER CHECK", f.relative_to(root))
    else:
        if ".nav-links.is-open > li > a" in n:
            print("DRAWER MISS", f.relative_to(root))

    if ">Loop</a>" in n:
        n = n.replace(">Loop</a>", ">The Loop</a>")
        print("nav label", f.relative_to(root))

    if 'class="v2-strip-stack" aria-hidden="true"' in n:
        n = n.replace(
            '<div class="v2-strip-stack" aria-hidden="true">',
            '<div class="v2-strip-stack">',
        )
        print("aria", f.relative_to(root))

    if "v3.90" in n:
        n = n.replace("v3.90", "v3.91")

    if n != t:
        f.write_text(n, encoding="utf-8")
        print("wrote", f.relative_to(root))
    else:
        print("noop", f.relative_to(root))
