# DXRP dedicated host — LifePunch launch wrappers (lifepunchnet)

**Canon:** `../LIFEPUNCHNET_HOST_LAYOUT.md` · `../LAUNCHING_SERVER_WITH_ADDONS.md` · Upstream: https://docs.dxrp.net/launching-server-with-addons

**Problem:** `sbox-server.exe +game dxura.rp +authorize …` fails with **This game has no code archive!** — and live portal addons are not mounted without the launcher API path.

**Fix:** Use Dxura's official launcher (`dxrp-server.cs`) — **both Official (70p) and Development**:

```text
dotnet run dxrp-server.cs --token <portal-token>
  → clone/pull dxrp
  → GET /v1/server/addons
  → dotnet build rp.csproj (at launch — verifyAddons false on host)
  → sbox-server.dll +game "<local rp.sbproj>" +authorize <token>
```

**Do not fork `dxrp-server.cs`.** LifePunch only versions wrappers, config examples, and deploy scripts in this folder.

---

## On-box layout (lifepunchnet — split roots)

| Server | Portal name | Install root | Start script | Game port |
|--------|-------------|--------------|--------------|-----------|
| **Server 1 — Official (70p)** | LifePunch Official \| 70p | `C:\SBOX-DXRP-Server` | `server1_start.bat` | **27015** |
| **Server 2 — Development** | DEVELOPMENT SERVER | `C:\Program Files (x86)\Steam\steamapps\common\sbox` | `server2_start.bat` | **27016** |

Each root must contain Dxura's host files (`dxrp-server.cs`, `sbox-server.dll`, etc.). This repo does **not** ship those binaries.

**Tokens (both profiles):** `C:\SBOX-DXRP-Server\secure\official.local.env` + `development.local.env`

### Versioned (git → deploy to box)

```text
lifepunch/server/dxrp-host/
  README.md
  official/          → deploy to C:\SBOX-DXRP-Server only
  development/       → deploy to Steam sbox only
  scripts/           → shared + profile update bats (see Deploy-DxrpHostLaunchers.ps1)
  vendor/ulx-shared/ → manual ULX patch (not deployed by default)
```

**Engine bumps (both servers, same version):** double-click `auto_update.bat` in either install root after a public s&box ship. It runs SteamCMD public release, syncs binaries to Official + Dev, and restarts both.

| Script | What it does |
|--------|----------------|
| `auto_update.bat` | **Canonical** — both servers, public release, version lock |
| `auto_update_all.bat` | Alias → `auto_update.bat` |
| `auto_update_official.bat` | Alias → `auto_update.bat` |
| `auto_update_official_staging.bat` | Staging beta test only (both roots if used with `-UseStagingBranch`) |

### On-box only (never commit)

```text
C:\SBOX-DXRP-Server\secure\*.local.env
<each-root>/dxrp-server-config.json
<each-root>/dxrp/                          # launcher-managed git checkout
```

Copy env templates from `lifepunch/secure/templates/` into `C:\SBOX-DXRP-Server\secure\`.

---

## Deploy after `git pull` (lifepunchnet)

```powershell
cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts
powershell -ExecutionPolicy Bypass -File .\Deploy-DxrpHostLaunchers.ps1
```

Runs cleanup automatically (removes wrong-profile bats, legacy `dev-engine/`, etc.).

## Engine update (26.06.10+)

**Read first:** `../START_DEV_SERVER.md` — Steam + `[7/7]` before any addon or portal work.

| Action | Where to run |
|--------|----------------|
| Dev only | `auto_update.bat` in **Dev** root, or `Update-LifepunchnetSboxServers.ps1` |
| Dev + Official | `auto_update_all.bat` in **Official** root, or `-IncludeOfficial` |

```powershell
powershell -ExecutionPolicy Bypass -File .\Update-LifepunchnetSboxServers.ps1
powershell -ExecutionPolicy Bypass -File .\Update-LifepunchnetSboxServers.ps1 -IncludeOfficial
```

From VENGEANCE: `powershell -File lifepunch\scripts\Invoke-LifepunchnetServerUpdate.ps1`

**Desktop shortcuts** (Administrator desktop): **LIFEPUNCH Official** / **LIFEPUNCH Development** — created by deploy script.

---

## Official migration checklist

1. Stop legacy `sbox-server.exe +game dxura.rp` if still running.
2. Ensure `C:\SBOX-DXRP-Server\secure\official.local.env` has `DXRP_TOKEN_OFFICIAL=…`
3. Run `server1_start.bat` from **`C:\SBOX-DXRP-Server`** (not Dev root).
4. Wait for `[2/7]`–`[7/7]`; confirm portal **Last Pulsed** for Official.

---

## Related

- **Split layout canon:** `../LIFEPUNCHNET_HOST_LAYOUT.md`
- **VENGEANCE handoff:** `../VENGEANCE_TO_BLUE.md`
- Runbook: `../LIFEPUNCHNET_INSTRUCTIONS.txt` (STEP 10)
- Change log: `change-log/2026-06-09-lifepunchnet-split-install-layout.md`
- Secrets: `lifepunch/secure/README.md`
