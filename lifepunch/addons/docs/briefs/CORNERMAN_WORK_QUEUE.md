# Cornerman work queue (Tier-3 prep)

**Issued:** 2026-06-11 · **Updated:** 2026-06-11 — **P0 = Hacker Job · P1b = Bitminer test audit · P1 = Cyber ecosystem**

**Green box:** RAG mirror + distill prep. **Red (VENGEANCE)** owns git push, C#, editor, Opus integration.  
**Sync clone:** `Cornerman (Sync from Red)` or `git stash` + `git pull --rebase origin/main`

**Push inbox:** `Push-CornermanHackerJobKickoff.ps1` (P0) · `Push-CornermanBitminerAssetTestAudit.ps1` (P1b) · `Push-CornermanCyberEcosystemBrief.ps1` (P1)

---

## Priority order

| # | Task | Brief | Model | Deliverable |
|---|------|-------|-------|-------------|
| **P0** | **Hacker Job distill** | `CORNERMAN_HACKER_JOB_TERMINAL_TASK.md` | **distill** | `outbox/HACKER_TERMINAL_FLOW_NOTES.md` · `TERMINAL_PUZZLE_CATALOG.md` · `HACKER_PVP_INFRA_FLOW.md` |
| P0a | Auth pattern + UI review | `UPGRADE_TIER_STANDARD.md` + owner intake | distill | `HASHD_AUTH_PATTERN.md` · `HACKER_UI_REVIEW_NOTES.md` |
| **P1b** | **Bitminer test audit** | `CORNERMAN_BITMINER_ASSET_TEST_AUDIT_TASK.md` | distill | `outbox/BITMINER_TEST_READINESS.md` — *can we playtest today?* |
| **P1** | Cyber ecosystem | `CORNERMAN_CYBER_ECOSYSTEM_TASK.md` | distill | `outbox/CYBER_ECOSYSTEM_ONE_PAGER.md` + encryption table |
| P2 | Staff menu SCSS fix | `CORNERMAN_STAFF_MENU_TASK.md` | **coder** | `outbox/STAFF_MENU_SCSS_FIX.scss` (when Red assigns) |
| P2 | Inventory (shipped P2 on Red) | `CORNERMAN_INVENTORY_PROJECT_TASK.md` | distill | backlog — pocket HUD live on VENGEANCE |
| — | ~~AK47 CS2 study~~ | — | — | **CLOSED** on Red `3954155` |
| — | ~~Bitminer Phase 1 terminal~~ | — | — | **CLOSED** `9fa5eb1` |
| — | ~~Visible Pocket P2~~ | — | — | **CLOSED** Red shipped hotbar |
| 10 | Deagle distill | `CORNERMAN_DEAGLE_DISTILL_TASK.md` | distill | USP stats + `w_deagle/MODEL_BUILD.md` draft |
| 11 | Coke intake | `CORNERMAN_COKE_DRUG_INTAKE_TASK.md` | distill | `UNZIP_MANIFEST.txt` + `COKE_LINE_MAP.md` |
| 12 | Bitminer Phase 2 menu | `CORNERMAN_BITMINER_PHASE2_MENU_TASK.md` | **coder** | Wireframe + scss tokens (Red ships C#) |

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
| `C:\lifepunch\cornerman\inbox\to-cornerman-hacker-job.txt` | **P0 start** |
| `C:\lifepunch\cornerman\inbox\to-cornerman-bitminer-asset-test.txt` | **P1b — bitminer test audit** |
| `C:\lifepunch\cornerman\inbox\HACKER_JOB_DIRECTIVE.json` | P0 directive |
| `C:\lifepunch\cornerman\inbox\CYBER_ECOSYSTEM_DIRECTIVE.json` | P1 parallel |
| `C:\lifepunch\cornerman\outbox\` | Distill output for RAG |
