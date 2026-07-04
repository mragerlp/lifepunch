---
applyTo: "**"
description: "s&box engine patch awareness — read patch log, run version check, regression gate on UI/publish"
sourceRule: ".cursor/rules/lifepunch-sbox-patches.mdc"
---

> **Synced from** `.cursor/rules/lifepunch-sbox-patches.mdc` â€” edit source there, then re-run `Sync-CursorRulesToCopilotInstructions.ps1`.

# LifePunch — s&box engine patches

Engine updates can break Razor UI, compile, and publish **without loud errors**. Do not ship UI or
publish work on assumptions from training data — check the live engine.

## Session start (before addon / UI / publish edits)

1. Run `lifepunch/scripts/Get-SboxEnginePatchStatus.ps1`.
2. If **WARN**: fetch latest `https://sbox.game/news`, update
   `lifepunchaddons/docs/SBOX_ENGINE_PATCHES.md`, run its regression checklist.
3. If Bloodwave posts a news URL: triage same session — summarize LifePunch impact in the patch log.

## UI panels (Razor / SCSS) — non-negotiable

- Canonical rules: `lifepunchaddons/docs/SBOX_RAZOR_SCSS_RULES.md`.
- **Class root** on `<root class="...">` — never `ComponentName { }` in `.razor.scss` (silently skipped → title-only empty body).
- Run `lifepunchaddons/scripts/Validate-SboxRazorScss.ps1` before playtest.
- **`PanelComponent`:** `BuildHash` must include every private UI flag that changes markup (PIN digits, entry open, errors, module tab).
- **Stop play → Play** after SCSS edits; grep `D:\Steam\steamapps\common\sbox\logs\sbox-dev.log` for `not valid with` and `error CS`.
- Smoke **world USE**, not only dev ConCmd preview (owner/PIN gates differ).

## Publish / join

- Games ship **precompiled DLLs** (26.06.10+); LifePunch addons still ship compiled `_c` on portal.
- After engine bump: re-smoke DXRP join + `prepare-publish.ps1` for touched addons.

Full patch history + checklist: `lifepunchaddons/docs/SBOX_ENGINE_PATCHES.md`.
