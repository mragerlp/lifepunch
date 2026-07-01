---
applyTo: "**"
description: "STYLE routing — Agent judges PASS vs VS Code Copilot mirror; Bloodwave does not pick manually"
sourceRule: ".cursor/rules/lifepunch-dxrp-style-gate.mdc"
---

> **Synced from** `.cursor/rules/lifepunch-dxrp-style-gate.mdc` â€” edit source there, then re-run `Sync-CursorRulesToCopilotInstructions.ps1`.

# LifePunch — DXRP STYLE gate (Cursor Agent)

**VS Code can** run Copilot mirror review. **Cursor cannot** run Copilot. Agent **routes** — Bloodwave does not manually decide mirror vs skip.

## After each DXRP-facing or upstream slice

1. **Read upstream reference** in `C:\Users\jared\Projects\dxrp-public` (or cited merged pattern) — TabMenu, Party, Rank, `[Sync(FromHost)]`, `dxrp.json`, Razor class root (`SBOX_RAZOR_SCSS_RULES.md`).
2. **Implement** to match; no LifePunch headers in `dxrp-public`.
3. **Emit exactly one STYLE verdict** in the handoff:

### `STYLE: PASS`

Agent verified against named reference paths. Proceed to flatgrass / commit proposal. Bloodwave takes no VS Code action.

### `STYLE: VS_MIRROR`

Agent needs Copilot in Dimmer's environment. Provide:

- **Files** (paths only, touched this slice)
- **Copilot prompt** (paste into VS Code Copilot Chat — review only, no rewrite):

  ```text
  Review only — do not rewrite. Do these files match DXRP TabMenu / Party / Sync / Razor SCSS conventions? List mismatches in bullets.
  ```

Bloodwave opens files in **VS Code**, runs prompt, pastes Copilot reply back to Cursor if REVISE needed.

## Default

Prefer **`STYLE: PASS`** when references are clear. Use **`VS_MIRROR`** for new UI surfaces, first use of a subsystem, or genuine uncertainty.

## Do not

- Ask Bloodwave to mirror routinely without a STYLE verdict.
- Install Copilot inside Cursor.
- Treat Copilot output as playtest proof.
- Edit files in VS Code during `VS_MIRROR` unless Bloodwave explicitly switches writer.
