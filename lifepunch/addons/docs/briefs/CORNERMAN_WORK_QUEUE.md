# Cornerman work queue (Tier-3 prep)

**Issued:** 2026-06-11 · **Updated:** 2026-06-25 — **P0-prep = Hub/GPU upgrade architecture distill · P0 = Hacker Job · P1c = Bitcoin Miner job solidification · P1d = Bitcoin sounds research · P1b = asset test audit · P1 = Cyber ecosystem**

**Green box:** RAG mirror + distill prep. **Red (VENGEANCE)** owns git push, C#, editor, Opus integration.  
**Sync clone:** `Cornerman (Sync from Red)` or `git stash` + `git pull --rebase origin/main`

**Push inbox:** `Push-CornermanBitcoinMiningHubUpgradeArch.ps1` (P0-prep) · `Push-CornermanCyberAssetAudit.ps1` (P0b) · `Push-CornermanHackerJobKickoff.ps1` (P0) · `Push-CornermanBitcoinMiningJobSolidification.ps1` (P1c) · `Push-CornermanBitcoinMiningSounds.ps1` (P1d) · `Push-CornermanBitcoinMiningAssetTestAudit.ps1` (P1b) · `Push-CornermanCyberEcosystemBrief.ps1` (P1)

---

## Priority order

| # | Task | Brief | Model | Deliverable |
|---|------|-------|-------|-------------|
| **P0-prep** | **Hub/GPU upgrade architecture** (owner ChatGPT plan incoming — **distill only, no code**) | `CORNERMAN_BITCOINMINING_HUB_UPGRADE_ARCH_TASK.md` | **distill** | `outbox/BITCOINMINING_CONTROLLER_VS_HARDWARE.md` + taxonomy + migration + UI tab plan + terminal copy + doc drift + merge shell |
| **P0b** | **Cyber asset audit** (owner on legal) | `CORNERMAN_CYBER_ASSET_AUDIT_TASK.md` | **distill** | Validate `cornerman-outbox/*_2026-06-11.md` · ping Red one-liner |
| **P0** | **Hacker Job distill** | `CORNERMAN_HACKER_JOB_TERMINAL_TASK.md` | **distill** | `outbox/HACKER_TERMINAL_FLOW_NOTES.md` · `TERMINAL_PUZZLE_CATALOG.md` · `HACKER_PVP_INFRA_FLOW.md` |
| P0a | Auth pattern + UI review | `UPGRADE_TIER_STANDARD.md` + owner intake | distill | `HASHD_AUTH_PATTERN.md` · `HACKER_UI_REVIEW_NOTES.md` |
| **P1c** | **Bitcoin Miner job solidification** | `CORNERMAN_BITCOINMINING_JOB_SOLIDIFICATION_TASK.md` | distill | `outbox/BITCOINMINING_JOB_ROLEPLAY_ONE_PAGER.md` + Market draft + stale doc fixlist |
| **P1d** | **Cyber console sounds** (bitcoin + hacker + shared keyboard + GPU fan lifecycle) | `CORNERMAN_BITCOINMINING_SOUNDS_TASK.md` + `CORNERMAN_CYBER_CONSOLE_SOUNDS_SUPPLEMENT.md` | distill | `BITCOINMINING_SOUND_SHORTLIST.md` (+ optional `HACKERJOB_SOUND_SHORTLIST.md`) |
| **P1b** | **BitcoinMiningAddon test audit** | `CORNERMAN_BITCOINMINING_ASSET_TEST_AUDIT_TASK.md` | distill | `outbox/BITCOINMINING_TEST_READINESS.md` — *can we playtest today?* |
| **P1** | Cyber ecosystem | `CORNERMAN_CYBER_ECOSYSTEM_TASK.md` | distill | `outbox/CYBER_ECOSYSTEM_ONE_PAGER.md` + encryption table |
| P2 | Staff menu SCSS fix | `CORNERMAN_STAFF_MENU_TASK.md` | **coder** | `outbox/STAFF_MENU_SCSS_FIX.scss` (when Red assigns) |
| P2 | Inventory (shipped P2 on Red) | `CORNERMAN_INVENTORY_PROJECT_TASK.md` | distill | backlog — pocket HUD live on VENGEANCE |
| — | ~~AK47 CS2 study~~ | — | — | **CLOSED** on Red `3954155` |
| — | ~~BitcoinMiningAddon Phase 1 terminal~~ | — | — | **CLOSED** `9fa5eb1` |
| — | ~~Visible Pocket P2~~ | — | — | **CLOSED** Red shipped hotbar |
| 10 | Deagle distill | `CORNERMAN_DEAGLE_DISTILL_TASK.md` | distill | USP stats + `w_deagle/MODEL_BUILD.md` draft |
| 11 | Coke intake | `CORNERMAN_COKE_DRUG_INTAKE_TASK.md` | distill | `UNZIP_MANIFEST.txt` + `COKE_LINE_MAP.md` |
| 12 | BitcoinMiningAddon Phase 2 menu | `CORNERMAN_BITCOINMINING_PHASE2_MENU_TASK.md` | **coder** | Wireframe + scss tokens (Red ships C#) |

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
| `C:\lifepunch\cornerman\inbox\to-cornerman-bitcoinmining-job-solidification.txt` | **P1c — miner job canon + Market draft** |
| `C:\lifepunch\cornerman\inbox\to-cornerman-bitcoinmining-sounds.txt` | **P1d — sound slot research + shortlist** |
| `C:\lifepunch\cornerman\inbox\to-cornerman-cyber-sounds-supplement.txt` | **P1d supplement — universal keyboard + GPU fan + hacker matrix** |
| `C:\lifepunch\cornerman\inbox\to-cornerman-bitcoinmining-asset-test.txt` | **P1b — bitcoinmining test audit** |
| `C:\lifepunch\cornerman\inbox\HACKER_JOB_DIRECTIVE.json` | P0 directive |
| `C:\lifepunch\cornerman\inbox\CYBER_ECOSYSTEM_DIRECTIVE.json` | P1 parallel |
| `C:\lifepunch\cornerman\outbox\` | Distill output for RAG |
