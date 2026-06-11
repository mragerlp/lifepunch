# Cornerman — Inventory project (Visible Pocket P1)

**Issued:** 2026-06-10 · **Lane:** Green Tier-3 prep · **Red:** VENGEANCE (C#, editor, git push)  
**Ship package:** `lifepunch.visiblepocket` — **not** llad MIS

---

## Sync first

```powershell
# Desktop: Cornerman (Sync from Red)  OR
cd C:\Projects\lifepunch
git fetch origin
git reset --hard origin/main
```

Read inbox (after Red runs `Push-CornermanInventoryProject.ps1`):

| File | Role |
|------|------|
| `CORNERMAN_INVENTORY_PROJECT_TASK.md` | **This brief — start here** |
| `VISIBLE_POCKET_SPEC.md` | Canonical rules |
| `DXRP_POCKET_DISCOVERY.md` | Step 1 detail (reference) |
| `VISIBLE_POCKET_DXRP_SUMMARY.txt` | 10-line distill (verify, don't rewrite) |
| `LLAD_MODULAR_INVENTORY_STUDY.md` | llad = study only — UI patterns, not ship |
| `CORNERMAN_MODEL_ROUTING.md` | Which LM Studio model per task |

---

## Model routing (mandatory)

| Work | LM Studio | Red warms |
|------|-----------|-----------|
| Spec review, distill, outbox summaries, llad UI **notes** | **distill** `qwen/qwen3.6-35b-a3b` | `WarmDistill` (default on boot) |
| P2 hotbar **wireframe** or `.razor.scss` token draft (when assigned) | **coder** `qwen2.5-coder-32b-instruct` | `WarmCoder` |
| C# integration, POCKET-01 gate, play-test | **Red only** | — |
| llad MIS as ship inventory | **Never** | — |

**If the brief does not say `WarmCoder`, stay on distill.**

```powershell
# VENGEANCE before Green session
powershell -File lifepunch\scripts\Send-CornermanWorkflow.ps1 -Action WarmDistill
```

---

## Your deliverables (priority order)

| # | Task | Model | Output on Green |
|---|------|-------|-----------------|
| 1 | **Maintain** `VISIBLE_POCKET_DXRP_SUMMARY.txt` — fix only if spec/discovery drift | distill | `outbox/VISIBLE_POCKET_DXRP_SUMMARY.txt` |
| 2 | **Slot table one-pager** — tiers, VIP/EVIP floors, cash unlocks for RAG | distill | `outbox/VISIBLE_POCKET_SLOTS_ONEPAGER.txt` |
| 3 | **Use/Drop UX outline** — right-click menu rules from spec § Interaction | distill | `outbox/VISIBLE_POCKET_UX_OUTLINE.txt` |
| 4 | **llad UI study** — grid/hotbar chrome only; cite `reference/intake/llad-modularinventorysystem/` | distill | `outbox/VISIBLE_POCKET_UI_NOTES.txt` |
| 5 | **Watch Red reply** | distill | Fold `to-cornerman-visible-pocket.txt` into outbox notes; ping one line when blockers land |
| 6 | **P2 HUD draft** (only when Red assigns) | **coder** | `outbox/VISIBLE_POCKET_HUD_DRAFT.scss` — Red/Opus reviews before ship |

---

## Do not (inventory project)

- Mount llad as production inventory or add `addons.json` llad row
- Commit C#, Razor ship code, or `addons.json` visiblepocket changes from Green
- Run s&box / ModelDoc on Green
- Treat Qwen 2.5 coder output as done without Red review
- Replace DXRP `PocketSystem` with a parallel grid database

---

## What Red owns (same sprint)

| Item | Doc |
|------|-----|
| POCKET-01 per-player gate | `TECH_DEBT.md` |
| Dev cmds play-test | `VISIBLE_POCKET_PLAYTEST.md` |
| BitcoinMiningAddon RGB shader | `RGB_FAN_LED_SHADER.md` (parallel P0) |
| `to-cornerman-visible-pocket.txt` reply | `handoff/cornerman-outbox/` |

---

## Push refresh (VENGEANCE)

```powershell
powershell -File lifepunch\scripts\Push-CornermanInventoryProject.ps1
powershell -File lifepunch\scripts\Send-CornermanWorkflow.ps1 -Action WarmDistill
```

Ping when batch done: `OK cornerman inventory @<sha>` one line.
