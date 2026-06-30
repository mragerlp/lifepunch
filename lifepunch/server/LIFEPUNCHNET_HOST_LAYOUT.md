# lifepunchnet — split install layout (Official vs Development)

**Host:** Blue / lifepunchnet (`205.209.104.22`)  
**VENGEANCE (local dev):** `D:\Steam\steamapps\common\sbox` — same launcher, one server, no port split.

As of June 2026, lifepunchnet runs **two separate s&box install roots** so Official 70p and Development never fight over binaries, ports, or `dxrp/` checkouts.

**Repo lane:** `lifepunch-rdp-server` (GitLab) · **GitHub monorepo path:** `lifepunch/server/` — see `lifepunch/docs/REPO_DOMAIN_MAP.md` and `lifepunch/docs/CONFIG_SOURCE_OF_TRUTH.md`.

---

## Repo structure (what git owns vs on-box)

```text
lifepunch/server/
  LIFEPUNCHNET_HOST_LAYOUT.md     ← this file (host canon)
  LAUNCHING_SERVER_WITH_ADDONS.md
  config/servers.json             ← portal server records + lifepunchnet notes
  change-log/                     ← server-page / host change records
  dxrp-host/
    README.md                     ← launcher deploy runbook
    official/                     ← Server 1 templates only (→ C:\SBOX-DXRP-Server)
      server1_start.bat
      restart_official.ps1
      dxrp-server-config.json.example
    development/                  ← Server 2 templates only (→ Steam sbox)
      server2_start.bat
      restart_development.ps1
      start_dev_server.bat, show_dev_server_log.bat
      dxrp-server-config.json.example
    scripts/                      ← deploy + update helpers (copied to both roots)
      Deploy-DxrpHostLaunchers.ps1
      Remove-StaleDxrpHostFiles.ps1
      Update-LifepunchnetSboxServers.ps1
      Set-DxrpServerConfig.ps1, Dxrp-HostProcess.ps1, …
      auto_update.bat, auto_update_all.bat, auto_update_official.bat
    vendor/ulx-shared/            ← optional ULX compile patch (manual)
```

**Not in git (on-box only):** `dxrp-server.cs`, `sbox-server.*`, `dxrp/`, `secure/*.local.env`, live `dxrp-server-config.json`, SteamCMD tree under `C:\SBOX-DXRP-Server`.

**Deploy law:** after `git pull`, run `Deploy-DxrpHostLaunchers.ps1` on lifepunchnet — copies profile-specific bats to each install root only.

---

## Install roots

| Server | Portal row | Install root | Start script | Game / query port |
|--------|------------|--------------|--------------|-------------------|
| **Official 70p** | LifePunch Official \| 70p | `C:\SBOX-DXRP-Server` | `server1_start.bat` | **27015** / **27018** |
| **Development** | DEVELOPMENT SERVER | `C:\Program Files (x86)\Steam\steamapps\common\sbox` | `server2_start.bat` | **27016** / **27017** |

Both use Dxura's launcher:

```text
dotnet run dxrp-server.cs --token <portal-token>
```

**Do not** use legacy `sbox-server.exe +game dxura.rp +authorize …` — portal addons require the launcher path.

---

## Engine source

| Profile | How binaries update | Branch (June 2026 operational) |
|---------|---------------------|----------------------------------|
| **Official 70p** | SteamCMD public pin on-box (`betakey` cleared, `validate`) | **public 26.06.24** (buildid `23900007`) — players use Default Public, no Steam beta |
| **Development** | Steam client + Betas → staging, or `auto_update_all.bat` sync | **staging** |

**Warning:** `auto_update_official.bat` runs SteamCMD **staging** into Official — use only when intentionally testing staging on 70p. Dev engine bumps: `auto_update.bat` (Dev root) or `auto_update_all.bat` (Dev + optional Official staging).

Update scripts (after `git pull` + deploy):

- **Dev only:** `auto_update.bat` (in Dev root) or `Update-LifepunchnetSboxServers.ps1`
- **Dev + Official staging test:** `auto_update_all.bat` (Official root) — `-UpdateDevelopmentBinaries -UseStagingBranch`
- **Official staging only:** `auto_update_official.bat` (Official root)

Official **26.06.24 public** was pinned manually on lifepunchnet (June 2026); there is no separate pin script in git — preserve with care when running update bats.

---

## Secrets (on-box only — never commit)

**Canonical location for both tokens:**

```text
C:\SBOX-DXRP-Server\secure\official.local.env      → DXRP_TOKEN_OFFICIAL
C:\SBOX-DXRP-Server\secure\development.local.env   → DXRP_TOKEN_DEVELOPMENT
```

Templates: `lifepunch/secure/templates/*.local.env.example`

Each install root also has its own `dxrp-server-config.json` (ports + token written by launcher). Dev reads the central token file; Official reads from the same `secure\` folder under its root.

---

## Deploy from git (lifepunchnet)

```powershell
cd C:\lifepunch\lifepunch-rdp-server
git pull --rebase
cd lifepunch\server\dxrp-host\scripts
powershell -ExecutionPolicy Bypass -File .\Deploy-DxrpHostLaunchers.ps1
```

Deploy copies **profile-appropriate files only**:

- **Official root:** `server1_start.bat`, `restart_official.ps1`, `auto_update_official.bat`, `auto_update_all.bat`, shared helpers
- **Dev root:** `server2_start.bat`, dev log bats, `Run-DevServer.ps1`, shared helpers
- **Removes** wrong-profile / legacy files (`Remove-StaleDxrpHostFiles.ps1`)

Desktop shortcuts (Administrator desktop only):

- **LIFEPUNCH Official** → `C:\SBOX-DXRP-Server\server1_start.bat`
- **LIFEPUNCH Development** → Steam `sbox\server2_start.bat`

---

## What lives where (quick)

### Official — `C:\SBOX-DXRP-Server`

```text
dxrp-server.cs, sbox-server.*, steamcmd.exe, dxrp/, secure/, server1_start.bat
```

**Do not** keep Dev launchers or `dev-engine/` / `_pin-test/` here.

### Development — Steam `sbox`

```text
dxrp-server.cs, sbox-server.*, dxrp/, server2_start.bat, logs/ (optional)
```

**Do not** keep Official-only update bats or `server1_start.bat` here.

---

## Portal pins (Dev → 70p)

Portal **Add to Server** + gamemode pins are law — not files in this repo. Dev is tested first; promote to Official on dxrp.net (Sync Servers), then `restart_official.ps1`.

**June 2026 operational (both servers aligned):** kevlar r16, official.base r6, lifepunchulx r10, monnow lpmonnowsprinterupgrade r2. Side-lane portal row: `lifepunch/gamemode/config/lpmonnowsprinterupgrade-portal.json`.

---

## VENGEANCE ↔ Blue Dev Server

| | VENGEANCE | lifepunchnet Dev |
|---|-----------|------------------|
| Folder | `D:\Steam\steamapps\common\sbox` | Steam `sbox` (same layout) |
| Command | `dotnet run dxrp-server.cs --token …` | `server2_start.bat` (adds port 27016) |
| Other server | none | Official on separate root |

See `VENGEANCE_TO_BLUE.md` for copy-paste RDP steps.

---

## Related

- `dxrp-host/README.md` — repo layout + update runbook
- `LAUNCHING_SERVER_WITH_ADDONS.md` — launcher law
- `LIFEPUNCHNET_INSTRUCTIONS.txt` — full box setup (STEP 10)
- Change log: `change-log/2026-06-09-lifepunchnet-split-install-layout.md`
