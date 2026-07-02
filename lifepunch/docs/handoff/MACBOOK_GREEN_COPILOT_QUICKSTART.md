# Mac → Cornerman → Copilot — Green B (RDP copy/paste pack)

**Green B** = Copilot on Cornerman via RDP.  
**Green A** (Mac native): `MAC_GREEN_COPILOT_NATIVE_GROUNDING_PASTE.txt`  
**One-shot chat paste:** `GREEN_CORNERMAN_COPILOT_GROUNDING_PASTE.txt` (@ `80a0ffa` canon)  
**Short first message:** `GREEN_COPILOT_SESSION_FIRST_MESSAGE.txt`

**Canon branch:** `checkpoint-lpbitcoin-pre-sleep-20260701`

---

## Copilot vs Cursor on Green B

| | **Copilot Green B** | **Cursor Green B** |
|--|---------------------|---------------------|
| MCP 3/3 | `claudebridge` · `chromr-mcp` · `jct-server` | `sbox` · `sbox-editor` · `cornerman-lm` |
| After preflight | Open project in Copilot — **no Reload Window** | Cursor → **Reload Window** |
| Preflight | Map → Tunnel → `Test-Path` (same) | Map → Tunnel → `Test-Path` (same) |

---

## 1. Mac → RDP

Microsoft Remote Desktop → `192.168.1.229` · user `jared` · password (not PIN)

Open **GitHub Copilot** → open folder `C:\Projects\lifepunch`

---

## 2. Cornerman preflight (always — Red editor must be up)

```powershell
cd C:\Projects\lifepunch
git fetch origin
git checkout checkpoint-lpbitcoin-pre-sleep-20260701
git pull --rebase

powershell -NoProfile -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\Map-CornermanBridgeShare.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\Start-CornermanSboxEditorTunnel.ps1 -Background
Test-Path \\VENGEANCE\SboxBridgeIpc\status.json
```

Must return **True**. Then open project in Copilot → confirm MCP **3/3** green.

---

## 3. New Copilot chat — paste

`lifepunch/docs/handoff/GREEN_CORNERMAN_COPILOT_GROUNDING_PASTE.txt`

---

## 4. Follow-up

```text
Report git status -sb, Test-Path result, MCP 3/3 status, and ACTIVE_WORKSTREAM + H4/H5 GO
```

---

## Links

| Doc | Purpose |
|-----|---------|
| `GREEN_CORNERMAN_COPILOT_GROUNDING_PASTE.txt` | Green B Copilot one paste |
| `GREEN_CORNERMAN_CURSOR_GROUNDING_PASTE.txt` | Green B Cursor one paste |
| `MAC_GREEN_COPILOT_NATIVE_GROUNDING_PASTE.txt` | Green A Mac Copilot |
| `GREEN_PATCH_HANDOFF_QUICKREF.txt` | Ship commits to Red |
