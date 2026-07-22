import json, base64
from pathlib import Path

p = Path(r"C:\Users\jared\.cursor\browser-logs\cdp-response-Page.captureScreenshot-2026-07-20T23-44-20-099Z.json")
data = json.loads(p.read_text(encoding="utf-8"))
raw = data.get("data")
if not raw and isinstance(data.get("result"), dict):
    raw = data["result"].get("data")
if not raw:
    raise SystemExit(f"no data; keys={list(data.keys())}")
out = Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand-scratch\orbit_veins_live.png")
out.write_bytes(base64.b64decode(raw))
print("wrote", out, out.stat().st_size)
