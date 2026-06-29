# Start Dev Server (lifepunchnet)

**Law:** Nothing else is testable until Dev is **Steam-connected** and `dxrp-server.cs` reaches **`[7/7]`**.

**Canon:** `LAUNCHING_SERVER_WITH_ADDONS.md` · https://docs.dxrp.net/launching-server-with-addons

Dxura's launcher (not bare `sbox-server.exe +game dxura.rp`):

```bat
cd /d "C:\Program Files (x86)\Steam\steamapps\common\sbox"
server2_start.bat
```

Or `start_dev_server.bat` when deployed from repo.

**Layout:** `LIFEPUNCHNET_HOST_LAYOUT.md` — Dev uses Steam `sbox`; Official 70p is `C:\SBOX-DXRP-Server`.

---

## Dev vs Official — separate install roots

| Field | Development | Official (70p) |
|-------|-------------|----------------|
| Install root | Steam `sbox` | `C:\SBOX-DXRP-Server` |
| Portal row | DEVELOPMENT SERVER | LifePunch Official \| 70p |
| Token env | `DXRP_TOKEN_DEVELOPMENT` | `DXRP_TOKEN_OFFICIAL` |
| Token file | `C:\SBOX-DXRP-Server\secure\development.local.env` | `C:\SBOX-DXRP-Server\secure\official.local.env` |
| Game port | **27016** / query **27017** | **27015** / query **27018** |
| Start script | `server2_start.bat` | `server1_start.bat` |

Each root has its own `dxrp-server-config.json`. Launch scripts stamp ports before `dotnet run`.

---

## Session user (Steam registry is per Windows user)

| Rule | Why |
|------|-----|
| **Who RDPs = who fixes Steam = who starts the server** | Admin fix + jared start = broken |
| **`auto_update.bat` may be elevated** | steamcmd OK as Admin; **Steam HKCU fix must run as the interactive RDP user** |

---

## Recovery (same RDP user — NOT elevated)

```bat
cd /d "C:\Program Files (x86)\Steam\steamapps\common\sbox"
fix_steam.bat
```

Or:

```powershell
cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts
powershell -ExecutionPolicy Bypass -File .\Fix-LifepunchnetSteamClient.ps1 -InstallRoots @('C:\Program Files (x86)\Steam\steamapps\common\sbox','C:\SBOX-DXRP-Server')
```

1. `restart_development.ps1` stops **Development only** (dev token / port 27016) — **Official 70p is not touched**
2. Run **`server2_start.bat`** from Steam `sbox` — wait for console

**Pass:** `Connected to Steam` (not "not connected to Steam") + launcher **`[7/7]`** + portal **DEVELOPMENT SERVER** Last Pulsed refreshes.

**Fail → stop.** Do not publish addon revisions or debug ULX until Steam is green.

---

## Engine update order

1. **Binaries** (elevated OK): `auto_update.bat` or `Update-LifepunchnetSboxServers.ps1`
2. **Steam fix** (normal RDP user): `fix_steam.bat`
3. **Start** (same user): `server2_start.bat`
4. **Verify** Steam + `[7/7]`
5. **Only then** — portal pin / in-game smoke

---

## Related

- `SERVER_ONLINE_QUICKFIX.md` — symptom index
- `dxrp-host/README.md` — deploy + `auto_update`
- `change-log/2026-06-17-simplify-dev-server-ops.md`
