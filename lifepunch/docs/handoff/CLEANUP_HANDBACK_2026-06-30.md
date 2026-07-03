# LifePunch cleanup handback — 2026-06-30

**Prepared for:** Bloodwave (VENGEANCE return)  
**Agent:** Cursor Auto · read-only audit + approved cleanup executed  
**Desktop:** excluded from all actions (per owner)

---

## Executive summary

All VENGEANCE cleanup items from the audit are **done**. Steam DXRP is reset, synced, and aligned with the monorepo. **~57 GB** disk reclaimed.

**Cornerman SSH:** use host alias `cornerman` → `192.168.1.229` (not `.227` in older docs). Sync via `Invoke-CornermanMonorepoSync.ps1` after Red pushes `main`.

---

## Completed (no action needed)

| Item | Status |
|------|--------|
| Delete `lifepunch-dxrp-addons` (~7.8 GB) | **Done** |
| Delete `D:\sbox-public` (~11.1 GB) | **Done** |
| Delete `_onedrive_lifepunch_salvage_20260606` | **Done** |
| Clear Steam `gamecache` + `download` (~38 GB) | **Done** |
| Reset Steam DXRP → `develop` @ `93a9537` | **Done** (matches `Projects\dxrp`) |
| `Sync-LifePunchAddonsToDxrp.ps1 -Addon lpbitcoin,adminmenu` | **Done** |
| DXRP strategy: party git in `dxrp-public` only | **Done** (Steam mount = compile/play) |
| MCP triple-stack libraries on Steam mount | **Present** (probe green) |

---

## Current git / mount state

### Canonical monorepo
- **Path:** `C:\Users\jared\Projects\lifepunch`
- **Branch:** `main`
- **Role:** source of truth → GitHub `mragerlp/lifepunch`

### DXRP clones
| Path | Branch | Role |
|------|--------|------|
| `Projects\dxrp` | develop | Upstream reference |
| `Projects\dxrp` | `lifepunch/party-names` | **Party PR work — git home** |
| `D:\Steam\...\sbox\dxrp` | develop | **Editor compile mount** (synced lifepunch trees) |

### Steam LifePunch mount (post-sync)
- `game/Assets/addons/lifepunch/lpbitcoin/` — entity assets
- `game/Code/Addons/lifepunch/bitcoinmining/` + `lpbitcoin/` + `lifepunchulx/`
- `rp.sbproj` Resources includes `lpbitcoin/**` + `lifepunchulx/**`

---

## Backups (local only — not in git)

**Folder:** `C:\lifepunch\cleanup-backup-20260630\`

| File | Contents |
|------|----------|
| `steam-dxrp-wip/` | 8 party files from Steam clone before reset |
| `steam-dxrp-status.txt` | git status snapshot |
| `lifepunch-dxrp-addons-status.txt` | dirty paths before delete |

**Party work canonical path:** `C:\Users\jared\Projects\dxrp` on branch `lifepunch/party-names`.

---

## Cornerman sync — DONE @ `20b3b00`

```powershell
powershell -File lifepunch\scripts\Invoke-CornermanMonorepoSync.ps1
```

Green `C:\Projects\lifepunch` fast-forwarded to `20b3b00`. SSH alias: **`cornerman` → `192.168.1.229`**.

---

## lifepunchnet (Blue) sync — complete (2026-06-30)

**GitLab `lifepunch-rdp-server`:** **`c418f2a`** — Blue host layout + live ops docs (on top of export **`12748c1`** / mono **`20b3b00`**). Linear history; no merge conflicts.

**VENGEANCE:** cherry-picked **`c418f2a`** into GitHub monorepo (6 files under `lifepunch/docs/` + `lifepunch/server/`).

**On-box (lifepunchnet RDP)** — if local clone is not yet at **`c418f2a`**, paste (non-elevated CMD):

```bat
cd C:\lifepunch\lifepunch-rdp-server
git pull --rebase
cd lifepunch\server\dxrp-host\scripts
powershell -ExecutionPolicy Bypass -File .\Deploy-DxrpHostLaunchers.ps1
```

Remote SSH/watchdog from VENGEANCE still blocked (`:22`, `:9101`, `:9102` closed; RDP `:3389` open). Use `Invoke-LifepunchnetServerUpdate.ps1` for clipboard one-liner + RDP shortcut.

---

## Disk summary

| Reclaimed | Source |
|-----------|--------|
| ~7.8 GB | `lifepunch-dxrp-addons` |
| ~11.1 GB | `D:\sbox-public` |
| ~38 GB | Steam `gamecache` + `download` |
| **~57 GB total** | |

---

## Still in monorepo (restructure track — not deleted)

- **~5.9 GB** quarantined `lp*` asset trees — frozen per `_QUARANTINE_INDEX.md`
- **Phase 4+** awaits explicit owner **GO**
