# LifePunch Official Server — online quickfix (lifepunchnet)

**Symptom:** Portal shows **INACTIVE** or server never pulses; console shows **This game has no code archive!**

**Cause:** Bare `sbox-server.exe +game dxura.rp` no longer works — cloud `dxura.rp` has no dedicated-server code archive.

**Fix:** Official (70p) must use Dxura's **`dotnet run dxrp-server.cs`** launcher — same as Development Server 2.

---

## 1. Deploy launchers (one-time after git pull)

On **lifepunchnet** (RDP box):

```powershell
cd C:\lifepunch\lifepunch-rdp-server
git pull --rebase
cd lifepunch\server\dxrp-host\scripts
powershell -ExecutionPolicy Bypass -File .\Deploy-DxrpHostLaunchers.ps1
```

This copies `server1_start.bat` / `restart_official.ps1` into `C:\S&BOX DXRP Server\`.

---

## 2. Token (on-box only — never commit)

Ensure `C:\S&BOX DXRP Server\secure\official.local.env` exists:

```text
DXRP_TOKEN_OFFICIAL=<portal Server 1 token>
```

Template: `lifepunch/secure/templates/` → copy to on-box `secure\`.

---

## 3. Start Official

1. **Stop** any old shortcut running `sbox-server.exe +game dxura.rp`.
2. Run **`C:\S&BOX DXRP Server\official\server1_start.bat`** (or desktop shortcut from deploy script).
3. Wait for launcher steps **`[2/7]`–`[7/7]`** (first run: clone dxrp + build — several minutes).
4. Confirm DXRP portal **Last Pulsed** updates for **LifePunch Official | 70p**.

---

## 4. If it still fails

| Check | Action |
|-------|--------|
| `dxrp-server.cs` missing | Dxura host files not installed in `C:\S&BOX DXRP Server` — copy from working Dev install |
| Token empty | Fix `secure\official.local.env` |
| Port conflict | Official uses **27015** — kill stale `sbox-server` / `dotnet` processes |
| Build errors in `[5/7]` | Read console; usually stale `dxrp/` checkout — delete `dxrp` folder, restart launcher |
| Pulses but no players | Gamemode/map issue — separate from launcher; check portal gamemode assignment |

---

## 5. Development server (reference — already working)

`C:\S&BOX DXRP Server Dev\development\server2_start.bat` — same pattern, different token in `secure\development.local.env`.

---

Canon: `lifepunch/server/dxrp-host/README.md` · Change log: `lifepunch/server/change-log/2026-06-15-official-dxrp-server-launcher.md`
