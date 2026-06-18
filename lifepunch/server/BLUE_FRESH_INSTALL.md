# Blue (lifepunchnet) — fresh s&box dedicated install

**Blue** = lifepunchnet RDP box (`205.209.104.22`). Install root: `C:\S&BOX DXRP Server\`.

Use this when the folder is a mess and you want the **same simple start** you had before Cursor:

```bat
cd /d "C:\S&BOX DXRP Server"
dotnet run dxrp-server.cs --token <token>
```

The `.bat` files now do exactly that (+ stamp port 27016/27015 so Dev and Official don't fight).

---

## What a fresh install fixes vs doesn't

| Fixes | Does NOT fix |
|-------|----------------|
| Broken/corrupt `sbox-server.dll` | Whitelist compile — bad **addon pin** on Dev gamemode |
| Steam DLL/registry per user | Wrong token in env file |
| Stale `dxrp/` / `dev-patches` junk | Portal IP/port misconfigured |

**Official already pulses on 26.06.17** — you do not need to nuke everything to prove the box works. Fresh install is for when dedicated binaries or Steam wiring on disk are suspect.

---

## Before you delete anything

**Backup tokens** (copy off-box or to OneDrive):

```text
C:\S&BOX DXRP Server\secure\official.local.env
C:\S&BOX DXRP Server\secure\development.local.env
```

After regenerating Dev token, update `development.local.env` with the new value.

---

## Fresh install (Blue)

### 1. Stop servers

Close any `dotnet` / server console windows for Dev and Official. Do **not** `taskkill /IM dotnet.exe` (kills both).

### 2. Quarantine old folder (optional but safe)

```bat
cd /d C:\
rename "S&BOX DXRP Server" "S&BOX DXRP Server.old"
mkdir "S&BOX DXRP Server"
mkdir "C:\S&BOX DXRP Server\secure"
```

Copy `secure\*.local.env` back from `.old\secure\`.

### 3. Dedicated server binaries (elevated CMD)

Install/update via steamcmd — **not** the s&box game client from Steam library (dedicated host uses app **1892930**):

```bat
cd /d "C:\S&BOX DXRP Server"
```

If `steamcmd.exe` lives in the old folder, copy it first. Then either:

- Double-click `auto_update.bat` (after deploy), **or**
- Run steamcmd `app_update 1892930 validate` per Dxura/Facepunch dedicated docs

You need in the install root:

- `sbox-server.dll`
- `sbox-server.exe` (if present)

### 4. Dxura launcher

Download `dxrp-server.cs` from [Launching Server with Addons](https://docs.dxrp.net/launching-server-with-addons) into `C:\S&BOX DXRP Server\`.

### 5. Steam client (optional but helps 26.06.10+)

Install **Steam** desktop on Blue and log in once as the **same RDP user** who starts servers — satisfies Steam redist/registry some dedicated builds need.

Then as that user (**not** elevated):

```bat
cd /d "C:\S&BOX DXRP Server"
fix_steam.bat
```

### 6. Deploy LifePunch launchers from git

```bat
cd C:\lifepunch\lifepunch-rdp-server
git pull --rebase
cd lifepunch\server\dxrp-host\scripts
powershell -ExecutionPolicy Bypass -File .\Deploy-DxrpHostLaunchers.ps1
```

Copies:

- `server1_start.bat` — Official, port **27015**
- `server2_start.bat` / `start_dev_server.bat` — Dev, port **27016**
- `fix_steam.bat`, `Set-DxrpServerConfig.ps1`, etc.

### 7. Start Dev (your original steps)

1. Open `C:\S&BOX DXRP Server` in File Explorer  
2. **Open in Terminal** or CMD in this folder  
3. Either:

```bat
server2_start.bat
```

or:

```bat
dotnet run dxrp-server.cs --token YOUR_DEVELOPMENT_TOKEN
```

**Pass:** `Connected to Steam` + `[7/7]` → portal **Development** Last Pulsed updates.

### 8. Official (only when you want 70p up)

```bat
server1_start.bat
```

Dev and Official use **different** tokens and ports. Same folder is fine.

---

## If compile still fails after fresh install

Portal → **Development gamemode** → unpin the addon named in `SB1000` / whitelist errors. Fresh Steam does not fix bad published addon code.

---

## Related

- `START_DEV_SERVER.md`
- `LIFEPUNCHNET_PASTE_ALL.txt`
- Dxura: https://docs.dxrp.net/launching-server-with-addons
