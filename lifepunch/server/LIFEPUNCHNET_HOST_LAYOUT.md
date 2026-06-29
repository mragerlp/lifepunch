# lifepunchnet — split install layout (Official vs Development)

**Host:** Blue / lifepunchnet (`205.209.104.22`)  
**VENGEANCE (local dev):** `D:\Steam\steamapps\common\sbox` — same launcher, one server, no port split.

As of June 2026, lifepunchnet runs **two separate s&box install roots** so Official 70p and Development never fight over binaries, ports, or `dxrp/` checkouts.

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

| Profile | How binaries update | Branch |
|---------|---------------------|--------|
| **Official** | SteamCMD `-beta staging` → `C:\SBOX-DXRP-Server` | **staging** |
| **Development** | Steam client install + Betas → **staging** | **staging** |

Update scripts (after `git pull` + deploy):

- **Dev only:** `auto_update.bat` (in Dev root) or `Update-LifepunchnetSboxServers.ps1`
- **Official staging only:** `auto_update_official.bat` (Official root). `-OfficialRelease` for release engine later.
- **Dev + Official:** `auto_update_all.bat` (Official root only) or `-IncludeOfficial`

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

- **Official root:** `server1_start.bat`, `restart_official.ps1`, staging update bats, shared helpers
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

## VENGEANCE ↔ Blue

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
