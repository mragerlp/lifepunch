# Stop VENGEANCE Dev server — run hosted Dev on Blue only

**Problem:** Dev running on VENGEANCE (`D:\Steam\steamapps\common\sbox`) exposes your home IP and wastes local resources. **Development must pulse from lifepunchnet** (`205.209.104.22`).

---

## Step 0 — Stop Dev on VENGEANCE (do this first)

On VENGEANCE, in the PowerShell window where `dotnet run dxrp-server.cs` is running:

- Press **Ctrl+C** to stop the server.

Confirm nothing is listening locally (optional):

```powershell
Get-Process sbox-server,dotnet -ErrorAction SilentlyContinue | Where-Object { $_.Path -like '*\sbox\*' }
```

If processes remain, close them. **Do not leave VENGEANCE pulsing the Development portal row.**

---

## Step 1 — Package working files on VENGEANCE

```powershell
cd C:\Users\jared\Projects\lifepunchaddons
powershell -ExecutionPolicy Bypass -File lifepunch\scripts\Package-BlueDevServerFromVengeance.ps1
```

Creates `lifepunch\server\blue-dev-package\` with `sbox-server.*`, `dxrp-server.cs`, and `BLUE_RDP_PASTE.txt`.

Copy that folder to Blue via RDP (clipboard, shared drive, or zip).

---

## Step 2 — On Blue (RDP lifepunchnet)

1. Copy packaged files into `C:\S&BOX DXRP Server\` (overwrite `sbox-server.dll` / `dxrp-server.cs` if older).
2. Put Development token in `C:\S&BOX DXRP Server\secure\development.local.env`:
   ```text
   DXRP_TOKEN_DEVELOPMENT=<portal Development token>
   ```
3. **Portal** → Development server → IP **`205.209.104.22`**, port **27016**.
4. Same RDP user, **not** elevated:

```bat
cd /d "C:\S&BOX DXRP Server"
fix_steam.bat
dotnet run dxrp-server.cs --token YOUR_DEV_TOKEN
```

Or after `git pull` + deploy: `server2_start.bat`

---

## Step 3 — Pass

- Console: `Connected to Steam` + `[7/7]`
- Portal: **LIFEPUNCH™ Official | Development** — Last Pulsed **just now**, IP shows **205.209.104.22**
- VENGEANCE: no `sbox-server` / dev `dotnet` still running

---

## If Blue fails

| Symptom | Fix |
|---------|-----|
| 401 | New token in `--token` once; update `development.local.env` |
| not connected to Steam | `fix_steam.bat` same RDP user |
| Whitelist compile | Unpin extra addons on Dev gamemode (start minimal like VENGEANCE: base only) |
| Portal still shows home IP | Portal Development row IP must be **205.209.104.22** |

---

## Law

- **VENGEANCE** = editor, MCP, bitcoin **asset/code** work — **not** hosted Dev server.
- **Blue** = only host that should pulse **Development** for players.
