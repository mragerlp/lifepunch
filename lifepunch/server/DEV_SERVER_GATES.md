# LifePunch Dev Server Gates (lifepunchnet)

**Law:** Nothing is testable until **Gate 0** passes. Addon publish, gamemode pins, lpbitcoin smoke, staff menu — all blocked until Dev is **Steam-connected** and `dxrp-server.cs` finishes startup.

This doc exists because a **session-user mismatch** (RDP as `administrator` vs fix/start as another user) wasted a full day while we chased the wrong problems (ULX revisions, compile paths).

---

## Gate 0 — Steam + startup (mandatory)

| Check | Pass |
|-------|------|
| Dev console | No **"not connected to Steam"** |
| Launcher | `dxrp-server.cs` reaches **`[7/7]`** |
| Portal | **DEVELOPMENT SERVER** **Last Pulsed** refreshes |

**Fail Gate 0 → stop.** Do not publish addon revisions, pin gamemodes, or debug addon compile until Steam is green.

---

## Session user law (root cause 2026-06-17)

Steam registry (`HKCU\SOFTWARE\Valve\Steam\ActiveProcess`) is **per Windows user**.

| Rule | Why |
|------|-----|
| **Who RDPs = who fixes Steam = who starts the server** | Admin fix + jared start = broken forever |
| **`auto_update.bat` is elevated** | steamcmd OK as Admin; **Steam HKCU fix must run as the interactive RDP user** (fixed in `Update-LifepunchnetSboxServers.ps1`) |
| **Check active session before any advice** | VENGEANCE: `GET :9101/status` → `sessions[].user`; lifepunchnet: `query user` |

Allowed server operators on lifepunchnet: **`jared`** or **`administrator`** — pick one per session and stay consistent.

---

## Engine / DXRP / addon update order

When **s&box**, **DXRP**, or **LifePunch addons** change:

### A. lifepunchnet (dedicated server)

1. **Preflight** (normal user — the one who will start the server):
   ```powershell
   cd C:\lifepunch\lifepunch-rdp-server\lifepunch\server\dxrp-host\scripts
   powershell -ExecutionPolicy Bypass -File .\Test-LifepunchnetDevServerReady.ps1
   ```
2. **Update binaries** (elevated OK — `auto_update.bat` or `Update-LifepunchnetSboxServers.ps1`).
3. **Recover Dev** (same RDP user as step 1 — **not** a different account):
   ```powershell
   .\fix_dev_server_now.bat
   ```
4. **Verify Gate 0** — Steam + `[7/7]` + portal pulse.
5. **Only then** — portal addon revision, gamemode pin, in-game smoke.

### B. VENGEANCE (editor / addons)

1. `Get-SboxEnginePatchStatus.ps1` — if WARN, read `SBOX_ENGINE_PATCHES.md`.
2. Editor compile + local playtest.
3. `prepare-publish.ps1 -Addon <ident>` → portal publish.
4. lifepunchnet pins revision **after** Gate 0 is green.

### C. CVL same-page (omniscient)

| Node | Before declaring "server OK" |
|------|------------------------------|
| **VENGEANCE** | `:9101/status` — `sessions`, `git.head`, no blocker alerts |
| **lifepunchnet** | `Test-LifepunchnetDevServerReady.ps1` → all PASS |
| **Cornerman** | Does not own server ops — distill only after Red/Blue report Gate 0 |

Hub line on material change: tier `lifepunchnet`, type `dev-server-gate`, text `gate0=pass|fail steam=... user=...`.

---

## What NOT to do (2026-06-17 lessons)

- Do **not** publish portal revisions to fix a server that fails **Steam**.
- Do **not** assume ULX / 11-file bundle is the blocker without Gate 0 green.
- Do **not** run `fix_steam` as Admin then `server2_start` as jared (or reverse).
- Do **not** spend a session on wrong install paths — lifepunchnet has **one** root: `C:\S&BOX DXRP Server\`.
- Do **not** claim overnight work ran without an artifact (commit, hub line, or file on disk).

---

## One-shot recovery (lifepunchnet Cursor)

```powershell
cd C:\lifepunch\lifepunch-rdp-server
git pull --rebase
cd lifepunch\server\dxrp-host\scripts
powershell -ExecutionPolicy Bypass -File .\Fix-LifepunchnetDevServerNow.ps1
```

---

## Related

- `SERVER_ONLINE_QUICKFIX.md` — launcher + Steam symptom index
- `dxrp-host/README.md` — deploy + `auto_update`
- `docs/CVL_FULL_CAPACITY_UPDATES.md` — § lifepunchnet dedicated server
- `change-log/2026-06-17-sbox-26-06-10-server-update.md`
