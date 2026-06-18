# Blue — clean Steam + s&box install (do this after install finishes)

**Goal:** Dev server on **205.209.104.22** only — same flow as VENGEANCE, not your home PC.

**Stop Dev on VENGEANCE first** (Ctrl+C in that PowerShell).

---

## Also install on Blue (if missing)

| Tool | Verify |
|------|--------|
| **.NET 10 SDK** | `dotnet --version` |
| **Git** | `git --version` |

Dxura requires both: https://docs.dxrp.net/launching-server-with-addons

---

## Find your s&box folder after Steam install

Usually:

```text
C:\Program Files (x86)\Steam\steamapps\common\sbox
```

Or check Steam → s&box → Manage → Browse local files.

Must contain **`sbox-server.dll`** after s&box finishes downloading.

---

## Copy Dxura launcher into that folder

Copy your download (or repo package) into the **same folder as `sbox-server.dll`**:

```text
dxrp-server.cs
```

From VENGEANCE package:

```text
lifepunch\server\blue-dev-package\dxrp-server.cs
```

Or: `Downloads\dxrp-server (1).cs` → rename to `dxrp-server.cs`

---

## Tokens (backup from old install)

```text
C:\S&BOX DXRP Server\secure\development.local.env
  DXRP_TOKEN_DEVELOPMENT=<portal Development token>
```

Keep Official token file if 70p will use `C:\S&BOX DXRP Server` later.

---

## Portal (before start)

**LIFEPUNCH™ Official | Development**

- IP: **205.209.104.22**
- Port: **27016**

---

## Start Dev — same as VENGEANCE

Open Terminal in the **s&box** folder (Steam → Browse local files → right-click → Open in Terminal):

```powershell
cd "C:\Program Files (x86)\Steam\steamapps\common\sbox"
dotnet run dxrp-server.cs --token YOUR_DEVELOPMENT_TOKEN
```

**Blue-only:** if Official 70p also runs on this box, add port once to `dxrp-server-config.json` after first run:

```json
"extraArgs": "+port 27016 +net_query_port 27017"
```

Or run from `C:\S&BOX DXRP Server` with `server2_start.bat` after copying `sbox-server.*` + `dxrp-server.cs` there.

---

## Pass

- `[7/7]`
- `Connected to Steam`
- Portal Development **Last Pulsed** updates
- **No** Dev server running on VENGEANCE

---

## Gamemode

Start **minimal** (like VENGEANCE — base content only). Pin LifePunch addons after pulse works.

Whitelist error → unpin last addon on Dev gamemode.

---

## Optional: keep using `C:\S&BOX DXRP Server`

After Steam install, copy into that folder:

```bat
copy "C:\Program Files (x86)\Steam\steamapps\common\sbox\sbox-server.dll" "C:\S&BOX DXRP Server\"
copy "C:\Program Files (x86)\Steam\steamapps\common\sbox\sbox-server.exe" "C:\S&BOX DXRP Server\"
copy "C:\Program Files (x86)\Steam\steamapps\common\sbox\sbox-server.runtimeconfig.json" "C:\S&BOX DXRP Server\"
copy dxrp-server.cs "C:\S&BOX DXRP Server\"
mkdir "C:\S&BOX DXRP Server\secure"
```

Then:

```bat
cd /d "C:\S&BOX DXRP Server"
dotnet run dxrp-server.cs --token YOUR_DEVELOPMENT_TOKEN
```

LifePunch scripts + `server2_start.bat` expect this folder.
