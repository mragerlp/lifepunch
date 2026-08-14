# RUNBOOK — Web Page Reading (read_web organ) — 2026-07-19

The repeatable process for reading live websites (including JS-rendered ones) from a Claude chat/agent that has terminal access (Desktop Commander or equivalent) on VENGEANCE. This is the universal armor's first proven organ.

## THE PROBLEM
Raw fetch (Desktop Commander `read_file isUrl`, curl, node fetch) only returns the raw HTML the server ships. Modern sites ship a near-empty shell + JavaScript; real content only exists AFTER a browser runs the JS. So raw fetch returns "premature close" / empty / just `<!DOCTYPE html>` on JS sites (collaborativevalueloop.com, github.com rendered pages, most SaaS). Raw fetch DOES work for static/raw endpoints (raw.githubusercontent.com, plain .md/.txt, .json APIs).

## THE FIX — headless Chromium via Playwright (ONE-TIME SETUP)
Node v22 already present. In C:\Users\jared:
```
npm install playwright
npx playwright install chromium
```
Chromium lands at C:\Users\jared\AppData\Local\ms-playwright. One-time; persists.

## THE SCRIPT (batch reader — reads N sites in one run)
Saved at C:\Users\jared\pull.js. Pattern:
```js
const { chromium } = require("playwright");
const urls = process.argv.slice(2);
(async () => {
  const b = await chromium.launch();
  for (const url of urls) {
    try {
      const p = await b.newPage();
      await p.goto(url, { waitUntil: "networkidle", timeout: 45000 });
      const title = await p.title();
      const text = await p.evaluate(() => document.body.innerText);
      console.log("===URL:: " + url);
      console.log("===TITLE:: " + title);
      console.log(text.slice(0, 1200));
      console.log("===END\n");
      await p.close();
    } catch (e) { console.log("===URL:: " + url + " ERR:: " + e.message + "\n"); }
  }
  await b.close();
})();
```
Run: `node pull.js "https://site1.com" "https://site2.com" ...`

## THE KEY TUNING RULE (the lesson that makes it reliable)
The `waitUntil` strategy per site type:
- **Normal JS sites** → `waitUntil: "networkidle"` (waits for network to settle). Best content completeness.
- **Never-idle / heavy-telemetry sites** (github.com rendered pages, some SaaS keep background connections open forever) → `networkidle` TIMES OUT. Use `waitUntil: "domcontentloaded"` + `await p.waitForTimeout(1500)` instead. Saved as pull2.js.
Heuristic: if a site times out on networkidle, retry that URL with domcontentloaded. Could auto-fallback in a hardened version.

## PROVEN (2026-07-19) across 3 failure modes
- JS-shell: collaborativevalueloop.com ✓ (networkidle)
- Normal JS: sbox.game ✓ (networkidle)
- Never-idle: github.com/modelcontextprotocol/servers ✓ (domcontentloaded fallback)

## ARTIFACTS ON DISK (C:\Users\jared\)
- pull.js — batch, networkidle
- pull2.js — batch, domcontentloaded + 1.5s wait (for stubborn sites)
- render.js — single site, detailed (4000 char slice + title)

## ARMOR NOTE
This is the read_web organ, proven standalone. When the CVL super-agent MCP ("universal armor") is built, this becomes a native `read_web(url)` / `read_web_batch(urls)` tool so ANY agent in ANY harness inherits it on connect — not a per-chat terminal script. Playwright is the LEAN web-render path; Windows-MCP is a separate (heavier) OS-screenshot/editor-vision path, not this.

FROM: Fable, 2026-07-19. Proven live this session.

## UPDATE 2026-07-19 (later) — FULL EYE TOOLKIT WIRED (eye.js)
The seeing organ graduated from single-purpose scripts to a 5-mode toolkit at C:\Users\jared\eye.js. This turns a reference from INSPIRATION into EXTRACTABLE SPECIFICATION (the UI-slop killer). Modes:
- `node eye.js text <url> [url2...]` → rendered innerText (research/content)
- `node eye.js shot <url> [out.png]` → full-page screenshot (visual reference; view the PNG)
- `node eye.js dom <url> [selector]` → rendered outerHTML (real DOM after JS, optionally a selector)
- `node eye.js styles <url> <selector>` → computed styles of matched els (exact padding/color/grid/radius etc.)
- `node eye.js tokens <url>` → design DNA: top palette colors, backgrounds, fonts, font-sizes, radii
All modes auto-fallback networkidle→domcontentloaded. This is F12-depth reading: an agent extracts a reference site's EXACT hex/fonts/spacing/tokens and ports THAT, instead of guessing from a picture. PROVEN: `node eye.js tokens collaborativevalueloop.com` returned accent #92FA11 (rgb 146,250,17), IBM Plex Mono + Inter, border-radius 0-2px (terminal-sharp), near-black bg with translucent-accent washes — the exact CVL hacker-terminal DNA, machine-read.
AUTHENTICATED PAGES (your Sixth/dxrp dashboards): eye.js off a cold link gets the LOGIN page, NOT your dashboard — authenticated pages need the fenced session-driver organ (agent drives an already-logged-in session; owner establishes auth; read-only fence). Public links: full depth works now.
ARMOR: eye.js modes become the MCP's read_web_text / read_web_shot / read_web_dom / read_web_styles / read_web_tokens tools — core UI-pipeline organ. Feature-canon entry: the seeing organ turns "look at this site" into "extract this site's complete design DNA and rebuild it in s&box."

## UPDATE 2 — MOTION MODE ADDED + EYE COMPLETE (2026-07-19, later)
eye.js now has SIX proven modes: text / shot / dom / styles / tokens / **motion**. `node eye.js motion <url>` extracts all @keyframes rules + every animated element (name/duration/easing/iterations) + svg/canvas counts. PROVEN on collaborativevalueloop.com — read the full motion DNA: hubPortalIn (black-hole swirl spins in from rotate(540deg) scale(0.1) over 2.6s, cubic-bezier(0.16,1,0.3,1)), hubEyeIn (the eye at the hole's center scales in 0.35→1), stackBridgeDraw (the VEINS — SVG stroke-dashoffset 220→0 draw-on between the four arch-nodes), heroScanSweep (CRT scanline top→bottom), cvlRiseIn (content rises 20px on cubic-bezier(0.22,1,0.36,1)), caretBlink (terminal cursor). 4 SVGs + 1 canvas (canvas = JS-drawn — particle/orbit layer; reading it needs the JS source, a deeper pull). LESSON: a static screenshot CANNOT see animation — the honest way an agent "sees" motion is reading it AS SOURCE (the recipe), which is MORE useful for porting than watching: an agent now extracts exact animation recipes (rotation degrees, easings, dash-draws) and translates them. Motion is part of design DNA. The seeing organ is COMPLETE: words / picture / structure / exact styles / static DNA / motion DNA.
