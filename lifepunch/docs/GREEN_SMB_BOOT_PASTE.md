# Green (Cornerman) — SMB primary boot paste

**Law:** Green `sbox` MCP must use **`\\VENGEANCE\SboxBridgeIpc`** (native SMB). The SSH IPC mirror is **fallback only** — slower, polling lag, not full capacity.

Copy everything below into a **Green Cursor** chat after Red editor is up.

---

```
GREEN SMB PRIMARY — full capacity (June 2026)

Law: sbox MCP on Green uses native SMB to Red Claude Bridge IPC — NOT the SSH mirror path.
Mirror (C:\lifepunch\cornerman\sbox-bridge-ipc-mirror) is emergency fallback only.

ON GREEN DESKTOP (interactive PowerShell — not SSH):

1. Map SMB (once per reboot if sbox MCP red):
   powershell -NoProfile -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\Map-CornermanBridgeShare.ps1

2. Editor tunnel (Red chomnr :9090):
   powershell -NoProfile -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\Start-CornermanSboxEditorTunnel.ps1 -Background

3. Verify mcp.json — sbox env MUST be UNC, not mirror:
   Get-Content $env:USERPROFILE\.cursor\mcp.json -Raw | ConvertFrom-Json | Select-Object -ExpandProperty mcpServers | Select-Object -ExpandProperty sbox

   Expected: SBOX_BRIDGE_IPC_DIR = \\VENGEANCE\SboxBridgeIpc
   WRONG:    C:\lifepunch\cornerman\sbox-bridge-ipc-mirror

4. Verify SMB in THIS session:
   Test-Path \\VENGEANCE\SboxBridgeIpc\status.json

5. Cursor → Reload Window → MCP 3/3 green: sbox, sbox-editor, cornerman-lm

6. In this chat: run get_bridge_status (sbox MCP) — must show connected + recent heartbeat.

Red must have s&box editor open (Start-SboxDxrpEditor.ps1) before step 4 passes.

If Map fails (error 86/1326): tell Bloodwave — lpbridge password on Red, not MSA PIN.
If mcp.json shows mirror path: tell Red to run Install-CornermanSboxBridgeMcp.ps1 from VENGEANCE.
```

---

**Red refreshes Green wiring:**

```powershell
powershell -File lifepunch\scripts\Connect-CornermanBridge.ps1
powershell -File lifepunch\scripts\Get-CvlConnectivityStatus.ps1 -Pretty
```
