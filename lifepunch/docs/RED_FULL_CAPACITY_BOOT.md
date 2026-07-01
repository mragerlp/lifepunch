# VENGEANCE (Red) — full capacity boot paste

**When:** Every session where Green runs Cursor, or after reboot / MCP red pills.  
**Probe:** `Get-CvlConnectivityStatus.ps1 -Pretty` → `allOk: true`  
**Green SMB map:** `GREEN_SMB_BOOT_PASTE.md` (interactive desktop on Cornerman)

---

## Red boot sequence (copy/paste)

Run from `C:\Users\jared\Projects\LIFEPUNCH`:

```powershell
cd C:\Users\jared\Projects\LIFEPUNCH
git pull --rebase

# One shot (editor + full Green stack) — use whenever Green Cursor agents need play/MCP:
powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -FullCapacity -PreflightFix -BitcoinOnly -SyncAddon lpbitcoin,bitcoinmining

# Or editor already open:
powershell -File lifepunch\scripts\Start-CvlFullCapacity.ps1
```

Manual steps (same as `Start-CvlFullCapacity.ps1` internals):

```powershell
powershell -File lifepunch\scripts\Restore-CornermanDualStack.ps1
powershell -File lifepunch\scripts\Start-VengeanceEditorTunnelToCornerman.ps1 -Background
powershell -File lifepunch\scripts\Get-CvlConnectivityStatus.ps1 -Pretty
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
