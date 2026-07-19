"""Extract every inline <script> block per page and node --check it."""
import pathlib
import re
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand")
pages = ["index.html", "system/index.html", "work/index.html",
         "about/index.html", "legal/index.html", "404.html"]

fail = 0
for page in pages:
    s = (ROOT / page).read_text(encoding="utf-8")
    blocks = re.findall(r"<script(?![^>]*\bsrc=)[^>]*>(.*?)</script>", s, re.S)
    for i, code in enumerate(blocks):
        if not code.strip():
            continue
        with tempfile.NamedTemporaryFile("w", suffix=".js", delete=False,
                                         encoding="utf-8") as f:
            f.write(code)
            tmp = f.name
        r = subprocess.run(["node", "--check", tmp], capture_output=True, text=True)
        status = "OK" if r.returncode == 0 else "FAIL"
        print(f"{page} script[{i}] ({len(code)} ch): {status}")
        if r.returncode != 0:
            fail += 1
            print(r.stderr[:1500])
        pathlib.Path(tmp).unlink()

print("RESULT:", "PASS" if fail == 0 else f"{fail} FAILURES")
sys.exit(1 if fail else 0)
