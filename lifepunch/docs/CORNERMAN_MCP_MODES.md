# Cornerman MCP modes (Green B)

**Status:** Active — July 2026  
**Canon ports:** `lifepunch/config/sbox-mcp-ports.json` → `cornerman.modes`  
**Install:** `Set-CornermanMcpMode.ps1` · `Install-CornermanIdeMcp.ps1`

---

## Problem we solved

Port **9090 on Cornerman** can only be one thing:

| Binds `:9090` on Green | Meaning |
|------------------------|---------|
| Red `ssh -R 9090:…` | Green Cursor → **Red** chomnr |
| Local chomnr | Green Cursor → **Green** editor |

**Never both.** Pick a **mode** per session.

---

## Three modes

| Mode | When | `sbox` IPC | `sbox-editor` | Red tunnel |
|------|------|------------|---------------|------------|
| **RedEditor** | Default CVL — Red owns editor | `\\VENGEANCE\SboxBridgeIpc` | `:9090` via tunnel → Red | **On** (Red `-R`) |
| **LocalEditor** | Green runs local s&box | `%LOCALAPPDATA%\Temp\sbox-bridge-ipc` | **`:9091`** local chomnr | **Off** |
| **DualEditor** | Red + Green editors same time | local on Green | **`:9091`** on Green | **Off** |

Red always uses **9090** (chomnr) and **29015** (jtc). Green does **not** run jtc today (3/3 MCP).

---

## Commands

### Green local editor (today’s session)

**On Red first:**
```powershell
cd C:\Users\jared\Projects\lifepunch
powershell -File lifepunch\scripts\Start-VengeanceEditorTunnelToCornerman.ps1 -Stop
```

**On Cornerman desktop:**
```powershell
cd C:\Projects\lifepunch
git fetch origin --prune
git checkout develop
git pull --rebase origin develop

powershell -NoProfile -ExecutionPolicy Bypass -File lifepunch\scripts\Set-CornermanMcpMode.ps1 -Mode LocalEditor
# or after scripts sync to C:\lifepunch\cornerman:
powershell -File C:\lifepunch\cornerman\Set-CornermanMcpMode.ps1 -Mode LocalEditor
```

**In s&box editor:** MCP dock → Settings → port **9091** → Apply → restart MCP server.

**Cursor:** Reload Window → expect **sbox** + **sbox-editor** green (3/3 with cornerman-lm).

If **9090 still blocked** on Green (stale sshd forward): admin `Restart-Service sshd -Force`, then retry chomnr on 9091.

---

### Back to Red editor (normal CVL)

**On Red:**
```powershell
powershell -File lifepunch\scripts\Set-CornermanMcpMode.ps1 -Mode RedEditor
powershell -File lifepunch\scripts\Start-VengeanceEditorTunnelToCornerman.ps1 -Background
```

Close Green local editor first.

---

## Mode state file

`C:\lifepunch\cornerman\mcp-mode.json` — written by install scripts.  
Red reverse tunnel **refuses to start** if mode is `LocalEditor` or `DualEditor` (use `-Force` to override).

---

## Cursor server keys (unchanged)

| Key | Red | Green |
|-----|-----|-------|
| `sbox` | local IPC | mode-dependent |
| `sbox-editor` | `:9090` | `:9090` tunnel or `:9091` local |
| `sbox-jtc` | `:29015` | ❌ |
| `cornerman-lm` | LAN → Green | local |

---

## Related

- `SBOX_EDITOR_MCP.md` — full stack  
- `handoff/CORNERMAN_MCP_SETUP_PASTE.txt` — step-by-step  
- `BRANCH_MODEL.md` — git branches (separate from MCP modes)
