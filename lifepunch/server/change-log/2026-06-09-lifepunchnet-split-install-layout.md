# 2026-06-09 — lifepunchnet split install layout

## What changed

- **Official 70p** install root: `C:\SBOX-DXRP-Server` (SteamCMD staging)
- **Development** install root: `C:\Program Files (x86)\Steam\steamapps\common\sbox` (Steam client staging)
- Both launch via `dotnet run dxrp-server.cs --token …` (not legacy `+game dxura.rp`)
- Tokens centralized: `C:\SBOX-DXRP-Server\secure\*.local.env`
- Deploy script copies profile-specific files only; `Remove-StaleDxrpHostFiles.ps1` drops wrong-profile clutter

## Why

Single-folder Dev + Official caused port/config/binary fights and confusing duplicate bats. Split roots match VENGEANCE's Steam layout for Dev while keeping Official on dedicated staging via SteamCMD.

## CVL action

1. Read `LIFEPUNCHNET_HOST_LAYOUT.md`
2. On lifepunchnet: `git pull` → `Deploy-DxrpHostLaunchers.ps1`
3. Use desktop shortcuts or correct `server1` / `server2` bat per root

## Validation

- Deploy + cleanup run on lifepunchnet
- Docs updated: `VENGEANCE_TO_BLUE.md`, `dxrp-host/README.md`, `LIFEPUNCHNET_INSTRUCTIONS.txt` STEP 10
