# Hacker Job — CVL kickoff (2026-06-11)

**Portal:** `019e448c-4958-77d1-84b7-c7ec3f1bc328` · **Addon:** `lifepunch.hackerjob`

Owner directive: **start Hacker Job** — sync all lanes, then Red playtests H1→H2.

---

## Lane assignments

| Lane | System | Now |
|------|--------|-----|
| **Red** | VENGEANCE | Sync DXRP → H1 smoke → H2 prefab preview → ModelDoc CRT + server rack |
| **Green** | Cornerman | Distill puzzle catalog + PvP flow + UI review notes → `outbox/` |
| **Blue** | lifepunchnet | Odysseus hub (passive); STT on PTT only |

---

## Red — first hour

```powershell
powershell -File lifepunch/scripts/Get-CvlUniversalCheckpoint.ps1
powershell -File lifepunch/scripts/Sync-LifePunchAddonsToDxrp.ps1 -Addon hackerjob,adminmenu
```

Editor play (host):

```text
lifepunch_spawn_testbot Greg
lp_cornerman_ui
scan
hack <steamid>
```

Advanced:

```text
lp_vengeance_ui
govdb
infil govdb-tax-01
```

World kit:

```text
lp_hacker_kit_preview
```

Canon: `RED_HACKER_JOB_BUILD.md` · `hackerjob/docs/HACKER_JOB_PLAYTEST.md`

**Polish tracker:** `addons/docs/CYBER_JOBS_POLISH_CHECKLIST.md` (Phase E — hub → terminal → advanced rack → advanced terminal)

---

## Green — dispatch (from VENGEANCE)

```powershell
powershell -File lifepunch/scripts/Push-CornermanHackerJobKickoff.ps1
powershell -File lifepunch/scripts/Send-CornermanWorkflow.ps1 -Action MonorepoPull
powershell -File lifepunch/scripts/Send-CornermanWorkflow.ps1 -Action WarmDistill -Message "Hacker Job P0 distill"
```

---

## Entities (ship tree)

| Slug | Program | Status |
|------|---------|--------|
| `hacker-terminal` | `cornerman.exe` | Code + prefab; ModelDoc vmats |
| `advanced-hacker-terminal` | `vengeance.exe` | Code + prefab; govdb stub |
| `server-rack` | Rack power + upgrades | Code + prefab; rack menu UI |

---

## Phase gates

| Phase | Scope | Gate |
|-------|-------|------|
| **1** (now) | UI, scan, puzzles, rack menu shell | H1/H2 playtest pass — **no wallet RPC** |
| **2** | Server-validated puzzles + wallet steal | Opus sign-off |

Cross-ref: `LIFEPUNCH_CYBER_ECOSYSTEM.md` (hacker offense ↔ bitcoin hub defense).
