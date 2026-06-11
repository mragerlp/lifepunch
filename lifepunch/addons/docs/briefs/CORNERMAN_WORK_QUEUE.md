# Cornerman work queue (Tier-3 prep)

**Issued:** 2026-06-11 · **Updated:** 2026-06-10 — **P0 = Inventory project (Visible Pocket)**

**Green box:** RAG mirror + distill prep. **Red (VENGEANCE)** owns git push, C#, editor, Opus integration.  
**Sync clone:** `Cornerman (Sync from Red)` or `git fetch origin && git reset --hard origin/main`

**Push inbox:** `Push-CornermanInventoryProject.ps1` (primary) · `Push-CornermanOffCursorHandoff.ps1` (handoff refresh)

---

## Priority order

| # | Task | Brief | Model | Deliverable |
|---|------|-------|-------|-------------|
| **P0** | **Inventory project** | `CORNERMAN_INVENTORY_PROJECT_TASK.md` | **distill** | `outbox/VISIBLE_POCKET_*` summaries + optional llad UI notes |
| P0a | llad UI study (no ship) | `LLAD_MODULAR_INVENTORY_STUDY.md` | **distill** | `outbox/VISIBLE_POCKET_UI_NOTES.txt` |
| P0b | HUD scss draft | task 6 in inventory brief | **coder** (Red assigns) | `outbox/VISIBLE_POCKET_HUD_DRAFT.scss` |
| — | ~~AK47 CS2 study~~ | — | — | **CLOSED** on Red `3954155` |
| — | ~~Bitminer Phase 1 terminal~~ | — | — | **CLOSED** `9fa5eb1` |
| — | ~~Bitminer G1–G3~~ | — | — | **CLOSED** Red owns Phase 2 UI |
| 10 | Deagle distill | `CORNERMAN_DEAGLE_DISTILL_TASK.md` | distill | USP stats + `w_deagle/MODEL_BUILD.md` draft |
| 11 | Coke intake | `CORNERMAN_COKE_DRUG_INTAKE_TASK.md` | distill | `UNZIP_MANIFEST.txt` + `COKE_LINE_MAP.md` |
| 12 | Hacker terminal | `CORNERMAN_HACKER_JOB_TERMINAL_TASK.md` | distill | Flow + puzzle catalog (Red owns C#) |
| 13 | Bitminer Phase 2 menu wireframe | `CORNERMAN_BITMINER_PHASE2_MENU_TASK.md` | **coder** | Wireframe + scss tokens (Red ships C#) |

---

## Model rule (every session)

| Work | Warm |
|------|------|
| Inventory docs, distills, llad notes | `WarmDistill` (default) |
| HUD / Razor / scss draft | `WarmCoder` — Red reviews before ship |
| C# / POCKET-01 / play-test | **Red only** |

See `CORNERMAN_MODEL_ROUTING.md`.

---

## Per-task commit messages (Green outbox only — Red commits repo)

```text
docs(visiblepocket): DXRP summary + slots one-pager + UX outline
docs(visiblepocket): llad UI pattern notes (study only)
docs(visiblepocket): HUD scss draft for Red review
```

Ping Red after each batch: `OK cornerman inventory @<sha>` one line.

---

## References on box

| Path | Role |
|------|------|
| `C:\lifepunch\cornerman\inbox\CORNERMAN_INVENTORY_PROJECT_TASK.md` | **Start here** |
| `C:\lifepunch\cornerman\inbox\INVENTORY_PROJECT_DIRECTIVE.json` | P0 directive |
| `C:\lifepunch\cornerman\outbox\` | Distill output for RAG |
| `to-cornerman-visible-pocket.txt` | Red reply slot — fold blockers |
