# MacBook → Cornerman — quickstart (copy-paste)

**One page.** Full detail: `MACBOOK_CORNERMAN_MOBILE.md`

---

## Before you start

- Mac on **same home Wi‑Fi/LAN** as Cornerman (`192.168.1.229`) and VENGEANCE.
- USB-C **hub + Ethernet** recommended if Wi‑Fi is flaky.
- **Red** must keep s&box editor up for bridge eyes.

---

## 1. Install RDP (once)

Mac App Store → **Microsoft Remote Desktop**

Add PC:

| Field | Value |
|-------|--------|
| PC name | `192.168.1.229` |
| User | `jared` |
| Password | Cornerman account password (**not** Windows Hello PIN) |

Connect → you are on the Green desktop.

---

## 2. Red (VENGEANCE) — keep bridge alive

```powershell
cd C:\Projects\lifepunch
powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -FullCapacity -PreflightFix -BitcoinOnly -SyncAddon lpbitcoin,adminmenu
```

---

## 3. Cornerman (inside RDP session)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\Map-CornermanBridgeShare.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File C:\lifepunch\cornerman\Start-CornermanSboxEditorTunnel.ps1 -Background
Test-Path \\VENGEANCE\SboxBridgeIpc\status.json
```

Must return **True**.

---

## 4. Green Cursor agent chat

Repo: `C:\Projects\lifepunch`

Paste: `lifepunch/docs/handoff/GREEN_CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt`

Ask agent:

```text
Run get_bridge_status and git status -sb
```

Target: bridge **connected** · MCP **3/3** · git branch reported.

---

## 5. Git on Green

```powershell
cd C:\Projects\lifepunch
git fetch; git pull --rebase
```

Read-only key — **no push**. Ping Red for patch-handoff after local commits.

---

## SSH alternative (no full desktop)

```bash
ssh jared@192.168.1.229
```

---

## Mac-only local AI (optional)

Ollama or LM Studio on the Mac for travel drafts — **not** a replacement for Green's heavy models or Red's s&box host.

---

## Links

- SMB law: `lifepunch/docs/GREEN_SMB_BOOT_PASTE.md`
- Green boot paste: `lifepunch/docs/handoff/GREEN_CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt`
- Patch-handoff: `lifepunch/docs/LOCAL_AI_WORKSTATION.md` §7c
