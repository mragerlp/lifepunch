# -*- coding: utf-8 -*-
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parent
FAV = Path(r"C:\lifepunch\brand-intake\cvlbrand\favicon")

(ROOT / "_headers").write_text(
    "/*\n"
    "  X-Robots-Tag: noindex, nofollow, noarchive\n"
    "  Referrer-Policy: no-referrer\n"
    "  X-Content-Type-Options: nosniff\n"
    "  X-Frame-Options: DENY\n",
    encoding="utf-8",
)
(ROOT / "robots.txt").write_text("User-agent: *\nDisallow: /\n", encoding="utf-8")

fav_dst = ROOT / "favicon"
fav_dst.mkdir(exist_ok=True)
for name in [
    "apple-touch-icon.png",
    "favicon-16.png",
    "favicon-32.png",
    "favicon-48.png",
    "favicon-64.png",
    "favicon-128.png",
    "favicon-256.png",
    "favicon.ico",
]:
    src = FAV / name
    if src.exists():
        shutil.copy2(src, fav_dst / name)
shutil.copy2(FAV / "favicon.ico", ROOT / "favicon.ico")
svg = ROOT / "favicon.svg"
if svg.exists() and "<html" in svg.read_text(encoding="utf-8", errors="ignore")[:200].lower():
    svg.unlink()

(fav_dst / "site.webmanifest").write_text(
    '{\n'
    '  "name": "Cavelux",\n'
    '  "short_name": "Cavelux",\n'
    '  "icons": [\n'
    '    { "src": "/favicon/favicon-32.png", "sizes": "32x32", "type": "image/png" },\n'
    '    { "src": "/favicon/favicon-48.png", "sizes": "48x48", "type": "image/png" },\n'
    '    { "src": "/favicon/apple-touch-icon.png", "sizes": "180x180", "type": "image/png" }\n'
    '  ],\n'
    '  "display": "standalone",\n'
    '  "start_url": "/"\n'
    '}\n',
    encoding="utf-8",
)
print("static OK")
for p in [ROOT / "_headers", ROOT / "robots.txt", ROOT / "favicon.ico"]:
    print(p.name, p.stat().st_size)
print("favicon dir:", sorted(x.name for x in fav_dst.iterdir()))
