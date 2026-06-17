# Start Dev Server (lifepunchnet)

**Law:** Nothing else is testable until Dev is **Steam-connected** and `dxrp-server.cs` reaches **`[7/7]`**.

Dxura's launcher (not bare `sbox-server.exe +game dxura.rp`):

```bat
cd /d "C:\S&BOX DXRP Server"
server2_start.bat
```

That runs `dotnet run dxrp-server.cs --token %DXRP_TOKEN_DEVELOPMENT%` using `secure\development.local.env`.

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

1. Kill stale `dotnet` / `sbox-server` under `C:\S&BOX DXRP Server`
2. **One** `server2_start.bat` — wait for console

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
