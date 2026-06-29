# VENGEANCE → Blue — replicate the working Dev server

**VENGEANCE (works):** `D:\Steam\steamapps\common\sbox`  
**Blue / lifepunchnet Dev:** `C:\Program Files (x86)\Steam\steamapps\common\sbox` (`205.209.104.22`)  
**Blue Official 70p:** `C:\SBOX-DXRP-Server` (separate root — do not mix with Dev)

Same Dxura command. Same launcher files. Blue adds **port 27016** for Dev because Official 70p runs on **27015** in its own folder.

---

## What you do on VENGEANCE (keep doing this)

```powershell
cd D:\Steam\steamapps\common\sbox
dotnet run dxrp-server.cs
dotnet run dxrp-server.cs --token <Development token>
```

Pass = `[7/7]` + Connected to Steam + portal **Last Pulsed** updates.

**Do not** paste extra text after `--token`. One token string only.

---

## Blue Development — same steps (RDP)

### 1. Folder must contain (same as VENGEANCE)

```text
C:\Program Files (x86)\Steam\steamapps\common\sbox\
  sbox-server.dll
  sbox-server.exe
  sbox-server.runtimeconfig.json
  dxrp-server.cs
```

If missing, copy from VENGEANCE or run **`auto_update.bat`** in the Dev folder (elevated) once.

### 2. Token (on-box only)

Development token lives in the **central secrets folder** (shared with Official):

```text
C:\SBOX-DXRP-Server\secure\development.local.env
```

```text
DXRP_TOKEN_DEVELOPMENT=<your token>
```

`server2_start.bat` reads this path first, then falls back to `secure\` under the Dev root.

### 3. Start Dev

RDP → double-click desktop **LIFEPUNCH Development**, or:

```bat
cd /d "C:\Program Files (x86)\Steam\steamapps\common\sbox"
server2_start.bat
```

Manual (same as VENGEANCE + port):

```powershell
cd "C:\Program Files (x86)\Steam\steamapps\common\sbox"
dotnet run dxrp-server.cs --token <Development token>
```

`server2_start.bat` stamps **27016 / query 27017** before launch.

### 4. Blue-only — two install roots

| Server | Root | Port |
|--------|------|------|
| Official 70p | `C:\SBOX-DXRP-Server` | **27015** |
| Development | Steam `sbox` | **27016** |

They no longer share one folder. Official uses `server1_start.bat` in its root only.

---

## What NOT to do on Blue

| Skip | Why |
|------|-----|
| `taskkill /IM dotnet.exe` | Kills Official **or** Dev depending on timing |
| `auto_update_all.bat` from Dev folder | Official-only script lives under `C:\SBOX-DXRP-Server` |
| Running Dev from `C:\SBOX-DXRP-Server` | Wrong root — use Steam `sbox` |
| `server1_start.bat` for Dev work | That is Official 70p |
| New portal server row | Same Development row + token |

---

## If Blue Dev fails but VENGEANCE works

| Check | Action |
|-------|--------|
| `401 Unauthorized` | New token in `C:\SBOX-DXRP-Server\secure\development.local.env` |
| `not connected to Steam` | `fix_steam.bat` as **same RDP user** (not Admin) |
| Whitelist / compile fail | Dev gamemode bad addon pin — unpin until server runs |
| Wrong portal row pulses | Wrong token (Official vs Dev) or wrong port |
| Wrong folder | Confirm cwd is Steam `sbox`, not `C:\SBOX-DXRP-Server` |

---

## Deploy / sync wrappers (after git pull on Blue)

```powershell
cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts
powershell -ExecutionPolicy Bypass -File .\Deploy-DxrpHostLaunchers.ps1
```

From VENGEANCE:

```powershell
powershell -File lifepunch\scripts\Invoke-LifepunchnetServerUpdate.ps1
```

---

## One paste block for Blue RDP (Dev)

```bat
cd /d "C:\Program Files (x86)\Steam\steamapps\common\sbox"
server2_start.bat
```

---

## Related

- **Layout canon:** `LIFEPUNCHNET_HOST_LAYOUT.md`
- Dxura: https://docs.dxrp.net/launching-server-with-addons
- Change log: `change-log/2026-06-09-lifepunchnet-split-install-layout.md`
