# Brand intake — LIFEPUNCH™ assets drop-zone

**Canon:** BRAND AGENT SEAT ruling 2026-07-15 (`dispatch\red\0003` item 7; ruling doc rides Red's canon slice / PR #127).  
**Lane A bridge (generate):** `lifepunch/scripts/ask-grok-image.ps1` (KEY_LEDGER **GX-1**, env `XAI_API_KEY`).  
**Lane A watcher:** `lifepunch/scripts/watch-brand-intake.ps1`  
**Scratch drop-zone:** `C:\lifepunch\brand-intake` — keepers graduate **here** (repo path below) on Bloodwave word.

Assets are **sensors**. Nothing lands without provenance.

## Lane A flow

1. **Grok render** — Imagine web app (Tier 1) or `ask-grok-image.ps1` (Tier 2, after GX-1 mint + `-Preflight`).
2. **Drop** the image into `C:\lifepunch\brand-intake\`.
3. **Watcher** (`watch-brand-intake.ps1`) stubs a `.provenance.md` sidecar + appends `_intake-log.md`, and schema-checks the filename (`brand_<surface>_<name>_v<N>` or `concept-*`).
4. **Bloodwave fills FILL fields** in the stub (dimensions, surface, exact prompt, etc.).
5. **Graduation sweep** copies image + sidecar into this folder (`_intake/brand/`).
6. **Commits** ride the normal PR flow (issue-centric / Rule 26).

Do **not** run the watch loop from an agent seat unless Bloodwave asks. `-Once` is the allowed smoke.

```powershell
# Watch (Bloodwave console)
powershell -NoProfile -File lifepunch\scripts\watch-brand-intake.ps1

# Single sweep / smoke (empty or real intake dir)
powershell -NoProfile -File lifepunch\scripts\watch-brand-intake.ps1 -Once
```

### Graduation helper (document only — no second script)

From repo root, after FILL fields are complete and Bloodwave says keep:

```powershell
$src = 'C:\lifepunch\brand-intake'
$dst = 'lifepunchaddons\Assets\addons\lifepunch\_intake\brand'
# Copy keepers (image + matching provenance). Adjust -Include / names per keep list.
Copy-Item -Path (Join-Path $src 'brand_*') -Destination $dst -Force
# Or robocopy one slug:
# robocopy $src $dst brand_<surface>_<name>_vN.png brand_<surface>_<name>_vN.provenance.md
```

Do **not** copy `_intake-log.md` into the repo unless Bloodwave asks.

## Delivery schema (verbatim from `dispatch\red\0003` item 7)

Naming: `brand_<surface>_<name>_v<N>`

Surfaces:

- `discord`
- `steam`
- `motd`
- `workshop-thumb`
- `social`
- `hub-hero`
- `addon-panel`

Drafts stay `*_v0` or `concept-*` until sign-off.

Every **v1+** delivery carries a required block:

| Field | Required |
|---|---|
| asset slug | yes |
| dimensions | yes |
| format | yes |
| intended surface | yes |
| EXACT generation prompt (provenance) | yes |
| proprietary footer on visuals | yes — `LIFEPUNCH™` proprietary IP · `lifepunch.co` |

**Provenance sidecar:** each committed asset is accompanied by a `.provenance.md` (or matching sidecar) with the exact prompt, model, timestamp, and intended surface. Watcher stubs use `FILL` placeholders until Bloodwave completes them.

Standing brief lives with Bloodwave (chat-carried v1; graduate to `docs/` if it stabilizes).

## Seat rules

- Grok Imagine web app = **OUTPUT-ONLY** art/branding seat — no comms, no git, no authority.
- Bloodwave is sole transport into this path.
- Seats never read credential files (C-1). Do not mint or paste GX-1 here.
