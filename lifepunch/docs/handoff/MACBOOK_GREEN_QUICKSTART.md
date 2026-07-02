# Mac → Cornerman → Cursor — copy/paste pack

**Canon branch:** `checkpoint-lpbitcoin-pre-sleep-20260701` @ `af79cdb`+  
**One page.** Full detail: `MACBOOK_CORNERMAN_MOBILE.md`

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

**Git sync** (required — do not cherry-pick `f1f3303` alone):

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

Must return **True**. Then **Cursor → Reload Window** → MCP **3/3** green: `sbox` · `sbox-editor` · `cornerman-lm`.

Full SMB law: `lifepunch/docs/GREEN_SMB_BOOT_PASTE.md`

---

### 3. New Cursor chat — paste this

From file: `lifepunch/docs/handoff/GREEN_SESSION_FIRST_MESSAGE.txt`

```text
GREEN SESSION — Cornerman Integration Architect (Cursor)

Machine: Cornerman 192.168.1.229 · repo C:\Projects\lifepunch
Red: VENGEANCE hosts s&box + Claude Bridge · SMB \\VENGEANCE\SboxBridgeIpc
Law: lifepunch/docs/GREEN_SMB_BOOT_PASTE.md · MACHINE_CAST.md
Full boot: lifepunch/docs/handoff/GREEN_CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt
Patch-handoff (when shipping commits): lifepunch/docs/handoff/GREEN_PATCH_HANDOFF_QUICKREF.txt

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

Target: bridge **connected** · MCP **3/3** · branch `checkpoint-lpbitcoin-pre-sleep-20260701` reported.

---

### 5. When Green is good — start real work

```text
Green session live
```

Then paste your task (or full bootstrap if the agent needs depth).

---

### 6. Only when shipping local work to Red

Paste from: `lifepunch/docs/handoff/GREEN_PATCH_HANDOFF_QUICKREF.txt`

Do **not** paste at session start — only when Green has local commits to publish.

---

## Red (VENGEANCE) — keep bridge alive

Bloodwave on Red before Green bridge check:

```powershell
cd C:\Projects\lifepunch
powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -FullCapacity -PreflightFix -BitcoinOnly -SyncAddon lpbitcoin,adminmenu
```

---

## SSH alternative (no full desktop)

```bash
ssh jared@192.168.1.229
```

---

## Links

| Doc | Purpose |
|-----|---------|
| `GREEN_SESSION_FIRST_MESSAGE.txt` | Short chat paste (§3) |
| `GREEN_CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt` | Full Green agent boot |
| `GREEN_PATCH_HANDOFF_QUICKREF.txt` | Ship commits to Red (§6) |
| `GREEN_SMB_BOOT_PASTE.md` | SMB + MCP law |
| `MACBOOK_CORNERMAN_MOBILE.md` | Roles, Tailscale notes, Mac local AI |
