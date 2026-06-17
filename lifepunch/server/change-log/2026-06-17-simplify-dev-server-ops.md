# Simplify lifepunchnet dev-server ops (align with GitLab 52459ec)

**Date:** 2026-06-17  
**Lane:** `lifepunch-rdp-server` + GitHub monorepo `lifepunch/server/`

## What changed

- **Removed** Gate0 orchestration scripts that added cost without delivering a proven running server:
  - `Run-LifepunchnetGate0.ps1`
  - `Fix-LifepunchnetDevServerNow.ps1`
  - `Test-LifepunchnetDevServerReady.ps1`
  - `fix_dev_server_now.bat`
  - `DEV_SERVER_GATES.md`, `LIFEPUNCHNET_CURSOR_GATE0.txt`, `FIX_DEV_SERVER_NOW.txt`
- **Added** `START_DEV_SERVER.md` — single runbook: `fix_steam.bat` → `server2_start.bat` → Steam + `[7/7]`
- **Fixed** `Fix-LifepunchnetSteamClient.ps1` for PS 5.1 (`S&BOX` path defaults + steamcmd arg arrays)
- **Updated** deploy script, quickfix, CVL notes, `Invoke-LifepunchnetServerUpdate.ps1` clipboard

## What did NOT change

- ULX source (`lifepunch/addons/Code/Addons/lifepunch/adminmenu/`) — intact
- Portal r8 bundle — still the ship target
- Dxura launcher law: `dotnet run dxrp-server.cs --token <token>`

## Lessons (2026-06-17)

- `dev-patches/` stubs on lifepunchnet overwrote portal r8 — caused whitelist compile failures; removed on box
- Session-user mismatch (Admin Steam fix + jared start) broke Gate 0 for hours
- Agents chased ULX revisions before proving one Dxura start command
- **Dev + Official share one install folder** — blanket `taskkill dotnet.exe` / kill-all-under-root murdered Official 70p whenever Dev started; fixed with `Dxrp-HostProcess.ps1` (token/port scoped stop)

## Operator path (lifepunchnet)

```bat
cd /d "C:\S&BOX DXRP Server"
fix_steam.bat
server2_start.bat
```

Pass = `Connected to Steam` + `[7/7]`. See `lifepunch/server/START_DEV_SERVER.md`.
