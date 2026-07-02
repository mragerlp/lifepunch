# Mac → Cornerman → Copilot — Green B (RDP copy/paste pack)

**Green B** = Copilot on Cornerman via RDP.  
**Green A** (Mac native): `MAC_GREEN_COPILOT_NATIVE_GROUNDING_PASTE.txt`  
**One-shot chat paste:** `GREEN_CORNERMAN_COPILOT_GROUNDING_PASTE.txt`  
**Short first message:** `GREEN_COPILOT_SESSION_FIRST_MESSAGE.txt`

**Canon branch:** `checkpoint-lpbitcoin-pre-sleep-20260701`

---

## 1. Mac → RDP

Microsoft Remote Desktop → `192.168.1.229` · user `jared` · password (not PIN)

Open **GitHub Copilot** (or VS Code + Copilot) → open folder `C:\Projects\lifepunch`

---

## 2. Cornerman preflight

```powershell
cd C:\Projects\lifepunch
git fetch origin
git checkout checkpoint-lpbitcoin-pre-sleep-20260701
git pull --rebase
```

Bridge (only if play-adjacent this session; Red editor must be up):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\Map-CornermanBridgeShare.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\Start-CornermanSboxEditorTunnel.ps1 -Background
Test-Path \\VENGEANCE\SboxBridgeIpc\status.json
```

For **`get_bridge_status` / MCP eyes** → use **Cursor Green B** (`GREEN_CORNERMAN_CURSOR_GROUNDING_PASTE.txt`), not Copilot chat.

---

## 3. New Copilot chat — paste

`lifepunch/docs/handoff/GREEN_CORNERMAN_COPILOT_GROUNDING_PASTE.txt`

---

## 4. Follow-up

```text
Run git status -sb and summarize ACTIVE_WORKSTREAM gate + H4/H5 GO status
```

---

## Links

| Doc | Purpose |
|-----|---------|
| `GREEN_CORNERMAN_COPILOT_GROUNDING_PASTE.txt` | Green B Copilot one paste |
| `MAC_GREEN_COPILOT_NATIVE_GROUNDING_PASTE.txt` | Green A Mac Copilot |
| `COPILOT_NEW_SESSION_BOOTSTRAP.txt` | Full Copilot law (fix paths to C:\Projects\lifepunch on Green) |
| `GREEN_PATCH_HANDOFF_QUICKREF.txt` | Ship commits to Red |
