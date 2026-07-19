import pathlib

s = pathlib.Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand\404.html").read_text(encoding="utf-8")
assert '--cvl-mono: "IBM Plex Mono", ui-monospace, monospace;' in s
assert s.count("var(--cvl-mono)") == 3
assert "var(--cvl-font)" in s
assert "\u2014" in s and "\u00e2\u20ac" not in s
b = pathlib.Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand\404.html").read_bytes()
assert b[:3] != b"\xef\xbb\xbf"
print("404 token def restored, 3 usages, encoding clean, no BOM")
