# CVL connectivity checkpoint — 2026-06-14 ~06:05 UTC

**Git checkpoint:** `f6d4dae` — `fix(bitcoinmining): Ophion hub materials, scale, and MCP preflight`

**Node:** VENGEANCE (Red) · **Session:** Bitcoin miner / DXRP editor

## VENGEANCE — dual MCP (this machine)

| Server | Role | Status |
|--------|------|--------|
| `sbox` | Claude Bridge — play mode, runtime, screenshots | **LIVE** (183 handlers, v1.13.0) |
| `sbox-editor` | chomnr — ModelDoc, prefabs, compile | **LIVE** (`:9090/sbox-mcp`) |
| `cornerman-lm` | Tier-3 distill on Green LAN | **LIVE** (`192.168.1.229:1234`) |

**Editor:** DXRP `rp.sbproj` open · scene `Game` · not in play · 262 objects · no unsaved changes.

**Actions taken:**
- `Install-VengeanceSboxEditorMcp.ps1` — refreshed `~/.cursor/mcp.json`
- `Start-SboxDxrpEditor.ps1 -SyncAddon bitcoinmining` — sync + launch + connectivity watch
- Bitcoinmining code/assets synced (incl. ConCmd duplicate fix)

**Probe:** `Get-CvlConnectivityStatus.ps1` → `vengeance.sboxBridge` + `vengeance.sboxEditor` + `vengeance.mcpDual` = **true**

**If Cursor MCP panel still shows red:** **Ctrl+Shift+P** → **Reload Window** → Enter. No manual relink — `mcp.json` is already wired.

## Cornerman (Green) — intentional layout

Green is **off-Cursor** (`OFF_CURSOR_ACTIVE`). Cornerman does **not** run Cursor or dual MCP locally.

| Check | Status | Note |
|-------|--------|------|
| Tier-3 LM (`:1234`) | **OK** | qwen3.6-35b distill + nomic embed in VRAM |
| LM watchdog | **OK** | `LifePunch-Cornerman-LM-Watchdog` |
| SMB bridge + editor tunnel | **N/A** | Only needed if Green runs Cursor again |
| Triple MCP on Green | **N/A** | Red owns editor + dual MCP |

To revive **Cornerman dual-stack** (SMB `sbox` + SSH tunnel `sbox-editor`): remove off-Cursor mode and run `Connect-CornermanBridge.ps1` + Green tunnel — see `lifepunch/docs/SBOX_EDITOR_MCP.md`.

## Daily preflight (before editor work)

```powershell
powershell -File lifepunch\scripts\Test-PreLaunchCheckup.ps1 -Fix
powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -SyncAddon bitcoinmining
```

Status probe: `Get-CvlConnectivityStatus.ps1`
