# Start Dev Server (lifepunchnet)

**Law:** Nothing else is testable until Dev is **Steam-connected** and `dxrp-server.cs` reaches **`[7/7]`**.

Dxura's launcher (not bare `sbox-server.exe +game dxura.rp`):

```bat
cd /d "C:\S&BOX DXRP Server"
start_dev_server.bat
```

Or `server2_start.bat` (delegates to the same `Run-DevServer.ps1` when deployed).

---

## Dev vs Official — do not kill both

Dev and Official share **`C:\S&BOX DXRP Server`**. They differ by **portal token** and **port** (Dev 27016, Official 27015), not by folder.

They also share **`dxrp-server-config.json`** on disk. `start_dev_server.bat` stamps **Development** ports before launch; `server1_start.bat` stamps **Official** ports. Never hand-edit `+port` in that file.

| Field | Development | Official (70p) |
|-------|-------------|----------------|
| Portal row | LifePunch Official \| DEVELOPMENT SERVER | LifePunch Official \| 70p |
| Token env | `DXRP_TOKEN_DEVELOPMENT` | `DXRP_TOKEN_OFFICIAL` |
| Game port | **27016** | **27015** |
| Host IP (portal) | **205.209.104.22** | **205.209.104.22** |
| Gamemode | Portal-assigned via token — **not** in `extraArgs` | Same |

`dxrp-server.cs` always launches `+game "<local rp.sbproj>" +authorize <token>`. Addons/gamemode pins come from `GET /v1/server/addons` for that token. LifePunch does **not** override gamemode in config.

---

## Session user (Steam registry is per Windows user)

| Rule | Why |
|------|-----|
| **Who RDPs = who fixes Steam = who starts the server** | Admin fix + jared start = broken |
| **`auto_update.bat` may be elevated** | steamcmd OK as Admin; **Steam HKCU fix must run as the interactive RDP user** |

---

## Recovery (same RDP user — NOT elevated)

```bat
cd /d "C:\S&BOX DXRP Server"
fix_steam.bat
```

Or:

```powershell
cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts
powershell -ExecutionPolicy Bypass -File .\Fix-LifepunchnetSteamClient.ps1 -SteamCmdExe 'C:\S&BOX DXRP Server\steamcmd.exe' -InstallRoots @('C:\S&BOX DXRP Server')
```

1. `start_dev_server.bat` stops **Development only** (dev token / port 27016) — **Official 70p is not touched**
2. **One** `start_dev_server.bat` — wait for console

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
