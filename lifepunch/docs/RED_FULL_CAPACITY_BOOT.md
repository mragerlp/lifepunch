# VENGEANCE (Red) — full capacity boot paste

**When:** Every session where Green runs Cursor, or after reboot / MCP red pills.  
**Probe:** `Get-CvlConnectivityStatus.ps1 -Pretty` → `allOk: true`  
**Green SMB map:** `GREEN_SMB_BOOT_PASTE.md` (interactive desktop on Cornerman)

---

## Red boot sequence (copy/paste)

Run from `C:\Users\jared\Projects\lifepunchaddons`:

```powershell
cd C:\Users\jared\Projects\lifepunchaddons
git pull --rebase

# 1) Editor + Claude Bridge (IPC must exist before SMB share works)
powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1

# 2) Publish SMB share + refresh Green mcp.json (UNC, not mirror)
powershell -File lifepunch\scripts\Install-CornermanSboxBridgeMcp.ps1
powershell -File lifepunch\scripts\Connect-CornermanBridge.ps1 -SkipLmWarm

# 3) sbox-editor tunnel — pick ONE path:

# A) Green can SSH to Red :22 (preferred if Enable-VengeanceSshTunnel was run):
#    (Green runs Start-CornermanSboxEditorTunnel.ps1 -Background — nothing on Red)

# B) Green CANNOT reach Red :22 (common) — reverse tunnel FROM Red:
powershell -File lifepunch\scripts\Start-VengeanceEditorTunnelToCornerman.ps1 -Background

# 4) Verify Red stack
powershell -File lifepunch\scripts\Get-CvlConnectivityStatus.ps1 -Pretty
Test-Path "$env:TEMP\sbox-bridge-ipc\status.json"
Get-SmbShare -Name SboxBridgeIpc
```

**Pass when:**

| Check | Expected |
|-------|----------|
| `allOk` | `true` |
| Bridge IPC | `Test-Path` → `True` |
| SMB share | `SboxBridgeIpc` → `%TEMP%\sbox-bridge-ipc` |
| Claude Bridge | `get_bridge_status` → `connected: true`, heartbeat &lt; 5s |
| Reverse tunnel (path B) | `Start-VengeanceEditorTunnelToCornerman.ps1` reports pid running |

**Then on Green desktop:** `Map-CornermanBridgeShare.ps1` → Cursor Reload Window → MCP 3/3 green.

---

## Order law

1. **Editor first** — creates `%TEMP%\sbox-bridge-ipc` heartbeat.
2. **Install SMB + Connect** — publishes `\\VENGEANCE\SboxBridgeIpc` and pushes Green scripts + mirror fallback.
3. **Editor tunnel** — path A (Green→Red SSH) **or** path B (Red→Green reverse SSH). Do not run both unless you know why.
4. **Green SMB map** — interactive desktop only; SSH batch sessions cannot see the mapped UNC.

---

## Related

- `GREEN_SMB_BOOT_PASTE.md` — Cornerman desktop steps
- `SBOX_EDITOR_MCP.md` — MCP stack detail
- `CVL_FULL_CAPACITY_UPDATES.md` — post-update maintenance
- Owner editor lane: `Set-DxrpLifepunchOwnerEditorLane.ps1` (art from OneDrive drop, code from repo)
