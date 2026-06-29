# Launching LifePunch DXRP servers with addons

**Status:** HARD LAW (June 2026) — both hosted servers must use Dxura's launcher now that addons are live on the portal.

**Upstream canon:** [Launching Server with Addons](https://docs.dxrp.net/launching-server-with-addons)

**LifePunch wrappers:** `lifepunch/server/dxrp-host/` (deploy to lifepunchnet with `Deploy-DxrpHostLaunchers.ps1`)

---

## Why bare `sbox-server.exe +game dxura.rp` is dead

| Old path | Result |
|----------|--------|
| `sbox-server.exe +game dxura.rp +authorize <token>` | **This game has no code archive!** — portal INACTIVE |
| Manual copy of addon folders into `dxrp/game/` | Stale on every publish; bypasses portal pins |

**Live addons require the launcher.** Each startup it:

1. Pulls latest DXRP game code from GitHub
2. Calls `GET /v1/server/addons` for **your portal token**
3. Clears and re-downloads all addon files assigned to that server
4. Builds and optionally verifies addon code
5. Launches `sbox-server.dll` with local `rp.sbproj` and restarts on crash

Portal **Add to Server** + gamemode pins are the source of truth — not files in the LifePunch git monorepo on the host.

---

## Prerequisites (lifepunchnet / any dedicated host)

1. **.NET 10 SDK** — https://dotnet.microsoft.com/download/dotnet/10.0  
   Verify: `dotnet --version`
2. **Git** — https://git-scm.com/downloads  
   Verify: `git --version`
3. **s&box dedicated server binaries** — `sbox-server.dll` (+ `.exe`, `.runtimeconfig.json`) in the install root (Steam / steamcmd `app_update 1892930`)
4. **Dxura launcher** — download `dxrp-server.cs` from the [official guide](https://docs.dxrp.net/launching-server-with-addons) into the **same folder** as `sbox-server.dll`

```text
C:\SBOX-DXRP-Server\                    ← Official 70p (SteamCMD staging)
├── sbox-server.dll, dxrp-server.cs, server1_start.bat
└── secure\official.local.env + development.local.env   ← BOTH tokens here

C:\Program Files (x86)\Steam\steamapps\common\sbox\   ← Development (Steam staging)
├── sbox-server.dll, dxrp-server.cs, server2_start.bat
```

**Canon:** `LIFEPUNCHNET_HOST_LAYOUT.md`

---

## LifePunch server mapping

| Portal name | Config key | Install root | Start | Game port | Token env |
|-------------|------------|--------------|-------|-----------|-----------|
| **LifePunch Official \| 70p** | `lifepunchmainserver` | `C:\SBOX-DXRP-Server` | `server1_start.bat` | **27015** | `DXRP_TOKEN_OFFICIAL` |
| **DEVELOPMENT SERVER** | `lifepunchdevelopment` | Steam `sbox` | `server2_start.bat` | **27016** | `DXRP_TOKEN_DEVELOPMENT` |

**Tokens:** both in `C:\SBOX-DXRP-Server\secure\` (Dev launcher reads central path).

**Gamemode / map / addon list:** assigned in [dxrp.net portal](https://dxrp.net/portal) for each server token. LifePunch does **not** set `+game` or `+map` in config — `dxrp-server.cs` owns `+game rp.sbproj`.

---

## First-time setup (lifepunchnet)

### 1. Deploy repo launchers

```powershell
cd C:\lifepunch\lifepunch-rdp-server
git pull --rebase
cd lifepunch\server\dxrp-host\scripts
powershell -ExecutionPolicy Bypass -File .\Deploy-DxrpHostLaunchers.ps1
```

### 2. Place upstream host files (if missing)

Copy from a working install or download per Dxura guide into **each** install root:

- Official: `C:\SBOX-DXRP-Server\`
- Development: Steam `sbox\`

Required files: `dxrp-server.cs`, `sbox-server.dll` (+ siblings)

### 3. Tokens (on-box only — never commit)

Copy templates from `lifepunch/secure/templates/` → `C:\SBOX-DXRP-Server\secure\`:

```text
official.local.env      → DXRP_TOKEN_OFFICIAL=<Server 1 portal token>
development.local.env   → DXRP_TOKEN_DEVELOPMENT=<Server 2 portal token>
```

Or pass once on CLI: `dotnet run dxrp-server.cs --token YOUR_TOKEN` (saved to config).

### 4. Portal — assign addons before expecting them in-game

For each server in portal:

- Pin gamemode / ruleset / map as usual
- **Add published LifePunch addons** via **Add to Server** (UUID = `dxrpAddonId` in `addons.json`)
- Publish addon revisions on portal before expecting server pull to pick them up

### 5. Start Official (70p)

1. **Stop** any legacy shortcut using `sbox-server.exe +game dxura.rp`
2. Run `C:\SBOX-DXRP-Server\server1_start.bat` as the **normal RDP user** (not elevated)
3. Wait for launcher **`[1/7]`–`[7/7]`** (first run: git clone + build — several minutes)
4. Confirm portal **Last Pulsed** for **LifePunch Official \| 70p**

Development: run `server2_start.bat` from Steam `sbox`. Full Dev runbook: `START_DEV_SERVER.md`.

---

## Config (`dxrp-server-config.json`)

Shared per install root — **each start script stamps the correct profile** via `Set-DxrpServerConfig.ps1` before `dotnet run`.

| Key | LifePunch value | Notes |
|-----|-----------------|-------|
| `token` | (from env / `--token`) | Portal server token |
| `repoUrl` | `https://github.com/dxura/dxrp.git` | Launcher-managed clone → `dxrp/` |
| `branch` | `main` | DXRP branch to pull |
| `apiEndpoint` | `https://api.dxrp.net` | Addon fetch API |
| `map` | `""` | Empty — portal assigns map |
| `extraArgs` | `+port … +net_query_port … +hostname …` | **No** `+game` or `+map` |
| `verifyAddons` | `false` | Set `true` to fail startup on compile errors |

Examples in repo: `dxrp-host/official/dxrp-server-config.json.example`, `dxrp-host/development/dxrp-server-config.json.example`.

---

## Startup checklist (pass = online with addons)

- [ ] `dotnet --version` shows .NET 10+
- [ ] `dxrp-server.cs` + `sbox-server.dll` in install root
- [ ] Correct token in `secure\*.local.env` or `--token`
- [ ] Console reaches **`[7/7]`**
- [ ] **Connected to Steam** (same Windows user ran `fix_steam.bat` if needed)
- [ ] Portal **Last Pulsed** updates
- [ ] Join smoke: LifePunch addon commands / entities present per portal pins

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `sbox-server.dll not found` | Run from install root; run `auto_update.bat` (elevated) for steamcmd |
| `This game has no code archive!` | Still on legacy launcher — switch to `server1_start.bat` |
| `401` at `[3/7] Fetching addons` | Bad/expired token — re-run with fresh `--token` |
| Build errors at `[5/7]` | Read file/line in console; fix portal publish or set `verifyAddons: false` temporarily |
| Addons missing in-game but server pulses | Portal — confirm addon **added to that server** and revision published |
| Wrong port / both servers die | Shared config stamped wrong profile — use profile start bats only |
| Not connected to Steam | `fix_steam.bat` as **same RDP user** who starts server — see `SERVER_ONLINE_QUICKFIX.md` |

---

## Engine updates

After s&box Steam bumps:

1. **Binaries** (elevated): `auto_update.bat` or `Update-LifepunchnetSboxServers.ps1`
2. **Steam fix** (RDP user): `fix_steam.bat`
3. **Restart** Dev first → verify `[7/7]` → then Official (`-IncludeOfficial` or `auto_update_all.bat`)

From VENGEANCE: `powershell -File lifepunch\scripts\Invoke-LifepunchnetServerUpdate.ps1`

---

## Related

- Quickfix index: `SERVER_ONLINE_QUICKFIX.md`
- Dev-first law: `START_DEV_SERVER.md`
- Wrapper deploy: `dxrp-host/README.md`
- Portal addon IDs: `lifepunch/addons/config/addons.json`
- Publish doctrine: `lifepunch/addons/docs/DXRP_ADDON_PUBLISH_DOCTRINE.md`
- DXRP docs index: `lifepunch/docs/DXRP_DOCS_REFERENCE.md`
