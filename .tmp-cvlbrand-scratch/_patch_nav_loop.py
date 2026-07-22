from pathlib import Path

root = Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand")

needle = '        <li><a href="/system/">System</a></li>\n        <li><a href="/work/">Work</a></li>'
insert = (
    '        <li><a href="/system/">System</a></li>\n'
    '        <li><a href="/system/#loop">The Loop</a></li>\n'
    '        <li><a href="/work/">Work</a></li>'
)
needle_active = (
    '        <li><a href="/system/" class="is-active">System</a></li>\n'
    '        <li><a href="/work/">Work</a></li>'
)
insert_active = (
    '        <li><a href="/system/" class="is-active">System</a></li>\n'
    '        <li><a href="/system/#loop" id="nav-loop">The Loop</a></li>\n'
    '        <li><a href="/work/">Work</a></li>'
)
# Non-system pages: Loop without id
insert_plain = (
    '        <li><a href="/system/">System</a></li>\n'
    '        <li><a href="/system/#loop">The Loop</a></li>\n'
    '        <li><a href="/work/">Work</a></li>'
)

for f in sorted(root.rglob("*.html")):
    t = f.read_text(encoding="utf-8")
    n = t
    if "The Loop</a></li>" in n and 'href="/system/#loop"' in n:
        print("already", f.relative_to(root))
        continue
    if needle_active in n:
        n = n.replace(needle_active, insert_active, 1)
    elif needle in n:
        n = n.replace(needle, insert_plain, 1)
    else:
        print("SKIP", f.relative_to(root))
        continue
    if n != t:
        f.write_text(n, encoding="utf-8")
        print("ok", f.relative_to(root))
