# DXRP dedicated host — LifePunch launch wrappers (lifepunchnet)

**Canon:** `../LAUNCHING_SERVER_WITH_ADDONS.md` · Upstream: https://docs.dxrp.net/launching-server-with-addons

**Problem:** `sbox-server.exe +game dxura.rp +authorize …` fails with **This game has no code archive!** — and live portal addons are not mounted without the launcher API path.

**Fix:** Use Dxura's official launcher (`dxrp-server.cs`) — **both Official (70p) and Development**:

```text
dotnet run dxrp-server.cs --token <portal-token>
  → clone/pull dxrp
  → GET /v1/server/addons
  → dotnet build rp.csproj
  → sbox-server.dll +game "<local rp.sbproj>" +authorize <token>
```

**Do not fork `dxrp-server.cs`.** LifePunch only versions wrappers, config examples, and deploy scripts in this folder.

---

## On-box layout (lifepunchnet)

| Server | Portal name | Start script | Game port |
|--------|-------------|--------------|-----------|
| **Server 1 — Official (70p)** | LifePunch Official \| 70p | `server1_start.bat` | **27015** |
| **Server 2 — Development** | DEVELOPMENT SERVER | `server2_start.bat` (same root) | 27016 (typical) |

**Single install root on lifepunchnet:** `C:\S&BOX DXRP Server\` — Dev and Official share this folder (different bat + token). No `Server Dev` path.

Each install must already contain Dxura's host files (`dxrp-server.cs`, `sbox-server.dll`, etc.). This repo does **not** ship those binaries.

### Versioned (git → deploy to box)

```text
lifepunch/server/dxrp-host/
  official/server1_start.bat
  official/restart_official.ps1
  official/dxrp-server-config.json.example
  development/server2_start.bat
  development/restart_development.ps1
  development/dxrp-server-config.json.example
  scripts/Deploy-DxrpHostLaunchers.ps1
  scripts/Update-LifepunchnetSboxServers.ps1
  scripts/auto_update.bat
  scripts/auto_update_all.bat
```

### On-box only (never commit)

```text
<install-root>/secure/official.local.env      # DXRP_TOKEN_OFFICIAL
<install-root>/secure/development.local.env   # DXRP_TOKEN_DEVELOPMENT
<install-root>/dxrp-server-config.json        # token written by launcher after first run
<install-root>/dxrp/                          # live git checkout (launcher-managed)
<install-root>/logs/                          # optional local logs
```

Copy env templates from `lifepunch/secure/templates/` into each install root's `secure\` folder.

---

## Deploy after `git pull` (lifepunchnet)

```powershell
cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts
powershell -ExecutionPolicy Bypass -File .\Deploy-DxrpHostLaunchers.ps1
```

## Engine update (26.06.10+)

**Read first:** `../START_DEV_SERVER.md` — Steam + `[7/7]` before any addon or portal work.

After s&box Steam updates:

1. **Binaries** (elevated): `Update-LifepunchnetSboxServers.ps1` or `auto_update.bat`
2. **Steam fix** (normal RDP user): `fix_steam.bat`
3. **Start** (same user): `server2_start.bat`
4. **Verify** portal Last Pulsed + Steam connected in console

```powershell
powershell -ExecutionPolicy Bypass -File .\Update-LifepunchnetSboxServers.ps1
# After Dev pulses OK on portal:
powershell -ExecutionPolicy Bypass -File .\Update-LifepunchnetSboxServers.ps1 -IncludeOfficial
```

From VENGEANCE: `powershell -File lifepunch\scripts\Invoke-LifepunchnetServerUpdate.ps1`

**Double-click on lifepunchnet** (after `Deploy-DxrpHostLaunchers.ps1`):

| File | Action |
|------|--------|
| `auto_update.bat` | steamcmd + restart **Development** only |
| `auto_update_all.bat` | steamcmd + restart **Dev + Official** |

Copied to `C:\S&BOX DXRP Server\` (same folder for Dev + Official launchers).

Then **migrate Official** (one-time if still on legacy bat):

1. Stop the old `sbox-server.exe +game dxura.rp` shortcut / batch.
2. Ensure `secure\official.local.env` has `DXRP_TOKEN_OFFICIAL=<portal Server 1 token>`.
3. Double-click desktop shortcut → `server1_start.bat` (or run `restart_official.ps1`).
4. Wait for launcher steps `[2/7]`–`[7/7]` (first run can take several minutes).
5. Confirm portal **Last Pulsed** updates for Official.
6. Portal: confirm LifePunch addons are **Add to Server** on Official gamemode.

---

## Related

- **Canon runbook:** `../LAUNCHING_SERVER_WITH_ADDONS.md`
- Runbook: `lifepunch/server/LIFEPUNCHNET_INSTRUCTIONS.txt` (STEP 10)
- Change log: `lifepunch/server/change-log/2026-06-29-addons-live-launcher-law.md`
- Change template: `lifepunch/templates/server-change.md`
- Secrets: `lifepunch/secure/README.md`
