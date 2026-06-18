# VENGEANCE Dev server — confirmed working (canonical path)

**Date:** 2026-06-17  
**Where:** `D:\Steam\steamapps\common\sbox` (VENGEANCE Steam s&box install)  
**Portal row:** LIFEPUNCH™ Official | Development  

## What worked (owner-verified)

1. Open `D:\Steam\steamapps\common\sbox` in Explorer  
2. Right-click → **Open in Terminal** / PowerShell in this folder  
3. First run (creates config):  
   `dotnet run dxrp-server.cs`  
4. Second run (valid token):  
   `dotnet run dxrp-server.cs --token <Development portal token>`  
5. Result: `[7/7]`, **Connected to Steam**, portal **Last Pulsed** updates  

## What failed (for the record)

| Mistake | Symptom |
|---------|---------|
| `dotnet run` with **old token** in saved `dxrp-server-config.json` | `401 Unauthorized` at `[3/7] Fetching addons` |
| `--token dotnet run dxrp-server.cs --token YOUR_TOKEN` (double-paste) | Token = `YOUR_TOKEN` → 401 |
| Chasing ULX / Gate0 / blanket taskkill | Wasted time — unrelated to this path |

## Working `dxrp-server-config.json` shape (VENGEANCE)

- `token` — saved after `--token` run (portal Development token)  
- `extraArgs` — **empty** (VENGEANCE runs one server; portal handles join)  
- `verifyAddons` — `false` (Dxura default)  
- `map` — empty (no gamemode override)  
- Gamemode/addons — from API for that token only (started with **1 addon**: `official.base` r3)

## Law

**Dxura path only:** `dotnet run dxrp-server.cs --token <token>` from folder containing `sbox-server.dll` + `dxrp-server.cs`. No `Run-DevServer.ps1` required on VENGEANCE.

## Blue replication

See `VENGEANCE_TO_BLUE.md` — same commands, folder `C:\S&BOX DXRP Server`, add `+port 27016` only because Official 70p shares the host.
