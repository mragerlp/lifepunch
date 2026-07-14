# PLAYER HUB GATE SET — RULED (both gates)

**RATIFIED 2026-07-14, Bloodwave** (word: *"take the recommended steps"*). Source record:
`comms\fable\0073` (authored by Fable #5 on Bloodwave's word). **Landed verbatim by Red under a
board-named DRIVE grant.**

> **CLASS: RULED. Write-once.** Never edited in place. A change of law supersedes it with a **new record
> citing this one by filename.**

---

## RULING 1 — PACKAGE IDENTITY: **CONFIRMED AS WRITTEN**

```
repo ident:        playerhub
package slug:      lifepunchplayerhub
s&box identifier:  lifepunch.playerhub
command:           lifepunchhub
code root:         lifepunchaddons/Code/Addons/lifepunch/playerhub/
DXRP kind:         code-only
```

**⚠ `code-only` is SUBJECT TO THE INTER FONT PROOF.** If Inter must ship as an **asset**, the manifest
kind **gets its own follow-up ruling** (`kepler\0001` Gate 1). **Do not assume `code-only` survives that
proof** — it is a conditional, not a settled fact.

## RULING 2 — WORKSTREAM: **OPENED**

**`playerhub` is added alongside `lpbitcoin` as an active workstream** in
`lifepunchaddons/docs/ACTIVE_WORKSTREAM.md`. **The bitcoin-only defer clause NO LONGER APPLIES to Player
Hub work.**

---

## RESTATED FOR THE RECORD (prior words — **not new rulings**)

- **`$LP` token:** blue `#017AEF` sign + white amount — **TEMPORARY**, pending the final currency-identity
  ruling (Law 17 family). Carried as **PENDING-RATIFICATION** in the `lifepunch-design-tokens` skill.
- **UI-STANDARD conflict** (`kepler\0001` Gate 3): **MOOT.** Commit **`4aa46d00`** reconciled
  `LIFEPUNCH_UI_STANDARD.md` to blue / 12px / 6px. **Doc and code agree.** *(Sensor: Green OUTBOX `0017`.)*

## CONSEQUENCE

- **Slices 1–5: UNBLOCKED** (fixture-backed, read-only).
- **Slice 6: RECLASSIFIED** per Green `0017`. The `$LP` inventory rail **EXISTS**
  (`ServerApiClient.Inventory.cs`). The remaining work is an **atomicity / idempotency design under
  existing economy law** — **its own slice, its own ruling, after 1–5.** *It was never a missing rail; it
  is a missing guarantee.*
- **Slices 7–8: still GATED** on progression contracts.
- **Slice 1 DRIVE: KEPLER ORCHESTRATOR builds** — its plan, seams pre-verified by Green `0017`, subagent
  reviewers inline per `fable\0072`.
- **RED runs the editor proof gate** when the MCP surfaces recover. **EDITOR TRUTH STAYS RED'S REGARDLESS
  OF WHO BUILDS.**

---

## RELATED CANON

- `lifepunch/docs/cvl/ORCHESTRATOR_SEAT_RULING_2026-07-14.md` — one window = one seat; subagents are tools.
- `lifepunch/docs/cvl/WINDOW_TOPOLOGY_2026-07-14.md` — the two-window topology and the config of record.
- `lifepunchaddons/docs/ACTIVE_WORKSTREAM.md` — Ruling 2's landing site (**two lanes now**).
- `lifepunch/docs/handoff/GREEN_0017_PLAYERHUB_3LANE_SCAN_2026-07-14.md` — the pre-verified seam table.
- `lifepunch/docs/superpowers/specs/2026-07-14-lp-player-hub-implementation-plan.md` — the tracked plan.
- **`.claude/skills/lifepunch-plan-shape/SKILL.md`** — *absence of a contract is a blocker, not permission
  to invent local substitutes.* **Slices 7–8 are gated, not improvised.**
