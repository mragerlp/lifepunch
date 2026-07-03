# Mac → Cornerman → Cursor — Green B (RDP copy/paste pack)

**Green B** = bridge-capable Windows IDE via RDP.  
**Green A** (Mac native, no RDP): `MAC_GREEN_NATIVE_GROUNDING_PASTE.txt`  
**One-shot Cornerman Cursor chat paste:** `GREEN_CORNERMAN_CURSOR_GROUNDING_PASTE.txt`  
**Full detail:** `MACBOOK_CORNERMAN_MOBILE.md`

**Canon branch:** `checkpoint-lpbitcoin-pre-sleep-20260701`

---

## When to use Green B (this doc)

RDP to Cornerman when you need:

- `get_bridge_status` + bridge screenshots
- MCP **3/3** over SMB (`sbox` · `sbox-editor` · `cornerman-lm`)
- Cornerman heavy LM in the same session as bridge work

For Mac-native comms only → **Green A** (`MAC_GREEN_NATIVE_GROUNDING_PASTE.txt`).

---

## Before you start

- Mac on **same home LAN** as Cornerman (`192.168.1.229`) and VENGEANCE.
- **Red** must have s&box editor + bridge up before SMB check passes.
- USB-C hub + Ethernet on the Mac recommended if Wi‑Fi is flaky.

---

### 1. Mac (before RDP)

Microsoft Remote Desktop → add PC:

| Field | Value |
|-------|--------|
| PC name | `192.168.1.229` |
| User | `jared` |
| Password | Cornerman account password (**not** Windows Hello PIN) |

Connect → on Cornerman: **Cursor** → **Open Folder** → `C:\Projects\lifepunch`

---

### 2. Cornerman PowerShell (before first paste)

**Git sync** (full branch checkout — do not cherry-pick `f1f3303` alone):

```powershell
cd C:\Projects\lifepunch
git fetch origin
git checkout checkpoint-lpbitcoin-pre-sleep-20260701
git pull --rebase
```

**Bridge wiring** (once per reboot if sbox MCP red; Red editor must be up):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\Map-CornermanBridgeShare.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\Start-CornermanSboxEditorTunnel.ps1 -Background
Test-Path \\VENGEANCE\SboxBridgeIpc\status.json
```

Must return **True**. Then **Cursor → Reload Window** → MCP **3/3** green.

Full SMB law: `lifepunch/docs/GREEN_SMB_BOOT_PASTE.md`

---

### 3. New Cursor chat — paste this

**Recommended:** paste entire file `lifepunch/docs/handoff/GREEN_CORNERMAN_CURSOR_GROUNDING_PASTE.txt`

**Or short session line** from `GREEN_SESSION_FIRST_MESSAGE.txt` (same text as below):

```text
GREEN SESSION — Cornerman Integration Architect (Cursor) · Green B

Machine: Cornerman 192.168.1.229 · repo C:\Projects\lifepunch
Red: VENGEANCE hosts s&box + Claude Bridge · SMB \\VENGEANCE\SboxBridgeIpc
Law: lifepunch/docs/GREEN_SMB_BOOT_PASTE.md · MACHINE_CAST.md
Full boot: lifepunch/docs/handoff/GREEN_CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt
Grounding paste: lifepunch/docs/handoff/GREEN_CORNERMAN_CURSOR_GROUNDING_PASTE.txt
Patch-handoff (when shipping): lifepunch/docs/handoff/GREEN_PATCH_HANDOFF_QUICKREF.txt

Boot confirm:
1. get_bridge_status (sbox MCP)
2. git pull --rebase in clone
3. Report MCP 3/3 + branch + clean/dirty

Active lane: lpbitcoin Phase A · H4/H5 GO pending
Git: read-only deploy key — patch-handoff to VENGEANCE for push
```

---

### 4. First follow-up message (same chat)

```text
Run get_bridge_status and git status -sb
```

---

### 5. When Green B is good

```text
Green session live
```

Then paste your task.

---

### 6. Only when shipping local work to Red

`lifepunch/docs/handoff/GREEN_PATCH_HANDOFF_QUICKREF.txt`

---

## Red (VENGEANCE) — keep bridge alive

```powershell
cd C:\Users\jared\Projects\lifepunchdxrp
powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -FullCapacity -PreflightFix -BitcoinOnly -SyncAddon lpbitcoin,adminmenu
```

---

## Links

| Doc | Path |
|-----|------|
| Green A (Mac native) | `MAC_GREEN_NATIVE_GROUNDING_PASTE.txt` |
| Green B grounding (one paste) | `GREEN_CORNERMAN_CURSOR_GROUNDING_PASTE.txt` |
| Green B steps (this file) | `MACBOOK_GREEN_QUICKSTART.md` |
| Full Mac roles | `MACBOOK_CORNERMAN_MOBILE.md` |
| Patch-handoff | `GREEN_PATCH_HANDOFF_QUICKREF.txt` |
