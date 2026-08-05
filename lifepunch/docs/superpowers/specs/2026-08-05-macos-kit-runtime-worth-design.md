# MacOS Kit Runtime Worth — Design

**Date:** 2026-08-05  
**Status:** Approved (Bloodwave GO in chat)  
**Machine:** VENGEANCE  
**Kit root:** `C:\Users\jared\OneDrive\Desktop\MACOS WORKSPACE FILES\lifepunch\LifePunch-MacOS-Addon-Planning`

## Problem

Codex on macOS produced a menu redesign kit (Hub / Bitcoin / ULX finals, Tags + Wallet new menus, Banker/Chemist/Blender plans). Without editor/browser proof, that work looks like documentation-only spend.

## Goal

Produce a labeled **proof pack** showing Mac kit surfaces have runtime (or honest preview) worth on VENGEANCE.

## Approach (approved)

**B — ingest runnable pieces, then prove.**

### In scope

1. Overlay Hub-Final `PLAYERHUB` onto editor tree `lifepunchdxrp/game/Code/Addons/lifepunch/playerhub` (backup first).
2. Mount Tags foundation as `lifepunchdxrp/game/Code/Addons/lifepunch/lifepunchtags` from Mac `lifepunchtags/code`.
3. Host play: ConCmds `playerhub`, `lifepunchtags`/`tags`; Bitcoin `lp_bitcoin_preview_hub` as control.
4. Wallet: open `LifePunch-Wallet-Finalized/preview/index.html` + screenshot (browser proof; no fake s&box wallet claim).
5. Matrix table for remaining kit folders (static / plan-only / control).
6. Artifacts under `lifepunch/docs/handoff/macos-kit-runtime-2026-08-05/`.

### Out of scope

- Git commit/push without separate GO
- Production wallet ledger / host rail
- Tags Chat/Scoreboard/Nameplate adapters
- Full Banker/Chemist/Blender implementation

## Success criteria

- Hub menu opens from Mac Hub-Final bytes (screenshot).
- Tags menu opens via `lifepunchtags` or `tags` (screenshot) **or** documented compile blocker with exact CS errors.
- Wallet browser preview screenshot with path to `preview/index.html`.
- One matrix covering every folder Bloodwave listed.

## Self-review

- No placeholders for success criteria.
- Wallet boundary explicit (browser ≠ s&box).
- Editor path is nested fork `lifepunchdxrp`, not Steam-only misload.
