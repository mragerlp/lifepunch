# Brand intake — LIFEPUNCH™ assets drop-zone

**Canon:** BRAND AGENT SEAT ruling 2026-07-15 (`dispatch\red\0003` item 7; ruling doc rides Red's canon slice).  
**Bridge:** `lifepunch/scripts/ask-grok-image.ps1` (KEY_LEDGER **GX-1**, env `XAI_API_KEY`).  
**Scratch generate-to:** `C:\lifepunch\brand-intake` — keepers graduate **here** on Bloodwave word.

Assets are **sensors**. Nothing lands without provenance.

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

**Provenance sidecar:** each committed asset is accompanied by a `.provenance.md` (or matching sidecar) with the exact prompt, model, timestamp, and intended surface.

Standing brief lives with Bloodwave (chat-carried v1; graduate to `docs/` if it stabilizes).

## Seat rules

- Grok Imagine web app = **OUTPUT-ONLY** art/branding seat — no comms, no git, no authority.
- Bloodwave is sole transport into this path.
- Seats never read credential files (C-1). Do not mint or paste GX-1 here.