"""Per-viewport lime budget: % of pixels close to --cvl-lime (146,250,17)."""
import pathlib
from PIL import Image

DIR = pathlib.Path(r"C:\Users\jared\Projects\lifepunch\.tmp-cvlbrand-scratch\v2b-local")

def lime_pct(path):
    img = Image.open(path).convert("RGB")
    w, h = img.size
    px = img.load()
    lime = 0
    for y in range(0, h, 2):
        for x in range(0, w, 2):
            r, g, b = px[x, y]
            if g > 150 and r < g * 0.85 and b < g * 0.55 and (g - max(r, b)) > 40:
                lime += 1
    total = ((w + 1) // 2) * ((h + 1) // 2)
    return 100.0 * lime / total

worst = 0.0
for f in sorted(DIR.glob("*.png")):
    pct = lime_pct(f)
    worst = max(worst, pct)
    print(f"{f.name}: {pct:.2f}%")
print(f"WORST VIEWPORT: {worst:.2f}%  (threshold 10%) -> {'PASS' if worst <= 10 else 'FAIL'}")
