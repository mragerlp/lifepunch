# VENGEANCE → Blue — replicate the working Dev server

**VENGEANCE (works):** `D:\Steam\steamapps\common\sbox`  
**Blue / lifepunchnet:** `C:\S&BOX DXRP Server` (`205.209.104.22`)

Same Dxura commands. Same files. Blue only adds **port 27016** because Official 70p also runs on that box.

---

## What you did on VENGEANCE (keep doing this)

```powershell
cd D:\Steam\steamapps\common\sbox
dotnet run dxrp-server.cs
dotnet run dxrp-server.cs --token <Development token>
```

Pass = `[7/7]` + Connected to Steam + portal pulses.

**Do not** paste extra text after `--token`. One token string only.

---

## Blue — same steps (RDP)

### 1. Folder must contain (same as VENGEANCE)

```text
C:\S&BOX DXRP Server\
  sbox-server.dll
  sbox-server.exe
  sbox-server.runtimeconfig.json
  dxrp-server.cs
```

If missing, copy from VENGEANCE `D:\Steam\steamapps\common\sbox\` (those four) or run `auto_update.bat` elevated on Blue once.

### 2. Token (on-box only)

Put Development token in:

```text
C:\S&BOX DXRP Server\secure\development.local.env
```

```text
DXRP_TOKEN_DEVELOPMENT=<your token>
```

Or let `dxrp-server-config.json` save it after first `--token` run (same as VENGEANCE).

### 3. Start Dev (your exact workflow)

RDP → open `C:\S&BOX DXRP Server` → Terminal in folder:

```powershell
cd "C:\S&BOX DXRP Server"
dotnet run dxrp-server.cs --token <Development token>
```

Or double-click **`server2_start.bat`** (reads env file, adds port 27016 for Blue).

### 4. Blue-only difference — port

VENGEANCE: `extraArgs` empty — one server on your PC.

Blue: Official uses **27015**. Dev must use **27016** or they fight.

`server2_start.bat` stamps `+port 27016` before `dotnet run`. Manual PowerShell users can add once to config:

```json
"extraArgs": "+port 27016 +net_query_port 27017"
```

Official uses `server1_start.bat` → port **27015**.

---

## What NOT to do on Blue

| Skip | Why |
|------|-----|
| `taskkill /IM dotnet.exe` | Kills Official 70p |
| `auto_update_all.bat` | Restarts both servers |
| `Run-DevServer.ps1` / Gate0 / ULX patches | Not needed — VENGEANCE didn't use them |
| New portal server row | Same Development row + token |
| Fresh Steam reinstall | Only if `sbox-server.dll` missing or Steam still broken after `fix_steam.bat` |

---

## If Blue fails but VENGEANCE works

| Check | Action |
|-------|--------|
| `401 Unauthorized` | New token in `--token` and `development.local.env`; delete old token from `dxrp-server-config.json` |
| `not connected to Steam` | `fix_steam.bat` as **same RDP user** (not Admin) |
| Whitelist / compile fail | Dev gamemode has bad addon pin — unpin until server runs (VENGEANCE started with 1 addon only) |
| Wrong portal row pulses | Wrong token (Official vs Dev) or wrong port |

---

## Minimal gamemode (how VENGEANCE passed)

Portal showed **1 addon** (`official.base` r3). No LifePunch pins = no whitelist fight.

**To work on bitcoin tonight:** after Blue pulses like VENGEANCE, pin LifePunch addons on Dev gamemode **one at a time**. If compile breaks, unpin the last one.

---

## One paste block for Blue RDP

```bat
cd /d "C:\S&BOX DXRP Server"
dotnet run dxrp-server.cs --token PASTE_DEV_TOKEN_HERE
```

Or with env file:

```bat
cd /d "C:\S&BOX DXRP Server"
server2_start.bat
```

---

## Related

- Dxura: https://docs.dxrp.net/launching-server-with-addons  
- Change log: `change-log/2026-06-17-vengeance-dev-server-works.md`  
- `BLUE_FRESH_INSTALL.md` — only if binaries folder is corrupt  
