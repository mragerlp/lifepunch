from pathlib import Path

root = Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand")

NOINDEX_PAIR = (
    '  <meta name="robots" content="noindex, nofollow, noarchive" />\n'
    '  <meta name="googlebot" content="noindex, nofollow, noarchive" />\n'
)
INDEX = '  <meta name="robots" content="index, follow" />\n'

for f in sorted(root.rglob("*.html")):
    t = f.read_text(encoding="utf-8")
    n = t
    rel = f.relative_to(root).as_posix()
    if rel == "404.html":
        # keep noindex; strip googlebot dup if any, leave robots noindex
        pass
    else:
        if NOINDEX_PAIR in n:
            n = n.replace(NOINDEX_PAIR, INDEX)
        else:
            n = n.replace(
                '<meta name="robots" content="noindex, nofollow, noarchive" />',
                '<meta name="robots" content="index, follow" />',
            )
            n = n.replace(
                '  <meta name="googlebot" content="noindex, nofollow, noarchive" />\n',
                "",
            )
    if "v3.92" in n:
        n = n.replace("v3.92", "v3.93")
    if n != t:
        f.write_text(n, encoding="utf-8")
        print("ok", rel)
    else:
        print("noop", rel)
