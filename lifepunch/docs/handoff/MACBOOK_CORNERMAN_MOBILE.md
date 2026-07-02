# MacBook + Cornerman (Green) — mobile workflow

**Updated:** 2026-07-01  
**Cornerman:** `192.168.1.229` · Windows 11 Pro · RDP + SSH (LAN-only v1)  
**Red:** VENGEANCE — s&box editor + Claude Bridge + git push  
**Green repo:** `C:\Projects\lifepunch` on Cornerman (read-only deploy key)

Use this when you operate LifePunch from an Apple Silicon MacBook (USB-C only). The Mac does **not** replace Red or Green — it is a **remote control + optional local light inference** node on the same network.

---

## What works from a Mac

| Capability | How | Notes |
|------------|-----|--------|
| RDP to Cornerman | Microsoft Remote Desktop (Mac App Store) | Full Green desktop — Cursor, LM Studio, cornerman scripts |
| SSH to Cornerman | Terminal + `~/.ssh/config` | Lighter than RDP; patch-handoff pings |
| Green Cursor agent | RDP → Cornerman → paste `GREEN_CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt` | MCP 3/3 over SMB + editor tunnel (see `GREEN_SMB_BOOT_PASTE.md`) |
| Local Mac LLM | Ollama or LM Studio for Mac (MLX) | Mobile drafts only — heavy coder stays on Green |
| s&box play proof | **Via bridge on Red** | Mac cannot host DXRP editor truth; Red must Host Play + `lp_authorize` |

---

## What does **not** work via USB-C

There is **no** standard USB-C cable mode that merges Mac Neural Engine / GPU with Cornerman's AMD GPU as one machine. USB-C on the Mac is for **power, hub, and Ethernet onto your LAN** — not compute sharing.

Integration is **network-based**: Mac → (RDP/SSH) → Cornerman → (SMB/tunnel) → VENGEANCE.

---

## Hardware (USB-C MacBook)

1. **USB-C hub or dock** — power passthrough + spare ports.
2. **USB-C → Ethernet** (recommended at home) — stabler RDP and LAN reachability than Wi‑Fi alone.
3. Same **home LAN** as Cornerman and VENGEANCE (192.168.x.x).

---

## RDP setup (Mac → Cornerman)

1. Install [Microsoft Remote Desktop](https://apps.apple.com/app/microsoft-remote-desktop/id1295203466).
2. Add PC:
   - **PC name:** `192.168.1.229` (or hostname `cornerman` if it resolves)
   - **User account:** `jared`
   - **Password:** Cornerman **account password** — **not** the Windows Hello PIN (PIN only works at the physical machine).
3. Connect. You should see the Cornerman desktop (LM Studio, Cursor, etc.).

**Troubleshooting**

- **Cannot connect:** confirm Cornerman is on, RDP enabled (`Enable-CornermanRemote.ps1`), same subnet, firewall Private profile.
- **Credentials fail:** use password auth; PIN will not work over RDP.

---

## SSH setup (Mac → Cornerman)

Add to `~/.ssh/config`:

```sshconfig
Host cornerman
  HostName 192.168.1.229
  User jared
  IdentityFile ~/.ssh/cornerman
```

Generate a key on the Mac if needed (`ssh-keygen -t ed25519 -f ~/.ssh/cornerman`), then add the **public** key to Cornerman via Red's `Enable-CornermanRemote.ps1` (same pattern as VENGEANCE).

```bash
ssh cornerman
```

---

## Role split (do not collapse)

```text
MacBook          Cornerman (Green)       VENGEANCE (Red)
────────         ─────────────────       ───────────────
Remote UI   →    Integration Architect   Copilot in-editor
Optional MLX     Qwen / cornerman-lm     s&box + Claude Bridge
Travel drafts    Green Cursor MCP 3/3    git push origin
                 read-only git clone     Host Play + lp_authorize
```

| Tier | Machine | Job |
|------|---------|-----|
| Red | VENGEANCE | Game truth, bridge eyes, publish |
| Green | Cornerman | Integration slices, heavy local models, Green Cursor |
| Mac mobile | MacBook | RDP/SSH client; optional small local models |

---

## Green session from Mac (via RDP)

After RDP to Cornerman:

1. Red must have editor up (`Start-SboxDxrpEditor.ps1 -FullCapacity …` on VENGEANCE).
2. On Cornerman desktop, run SMB + tunnel scripts — **`GREEN_SMB_BOOT_PASTE.md`** (full paste block).
3. Open Cursor on Cornerman → `C:\Projects\lifepunch`.
4. New agent chat → paste **`handoff/GREEN_SESSION_FIRST_MESSAGE.txt`** (or full **`GREEN_CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt`** if depth needed).
5. Agent runs `get_bridge_status` + `git status -sb`.

**Git on Green:** read-only deploy key — local commits OK; push via patch-handoff on Red (`LOCAL_AI_WORKSTATION.md` §7c · `Pull-CornermanPatches.ps1`).

---

## Mac local AI (optional)

When away from Cornerman or for quick drafts:

- **Ollama** (Mac) or **LM Studio for Mac** — MLX uses Apple Silicon well.
- Keep **Cornerman** as the heavy Tier-3 coder host (`http://192.168.1.229:1234` when on LAN).
- Do **not** route economy / `[Sync]` / multi-file C# through Mac local models without explicit route tags.

---

## Off-LAN (future — not v1)

Current law: **LAN-only** for RDP/SSH/model endpoint. For travel later:

- **Tailscale** tailnet (repo mentions for LM Link evaluation — `LOCAL_AI_WORKSTATION.md` §7d).
- RDP/SSH over Tailscale once enabled — never raw public port-forward.

---

## Related docs

| Doc | Purpose |
|-----|---------|
| `handoff/MACBOOK_GREEN_QUICKSTART.md` | Mac → Cornerman → Cursor copy/paste pack (§1–6) |
| `handoff/GREEN_SESSION_FIRST_MESSAGE.txt` | Short Green chat paste (session start) |
| `GREEN_SMB_BOOT_PASTE.md` | SMB + MCP 3/3 on Cornerman |
| `handoff/GREEN_CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt` | Green agent session boot |
| `RED_FULL_CAPACITY_BOOT.md` | Red editor + bridge |
| `LOCAL_AI_WORKSTATION.md` §7b–7c | SSH/RDP + patch-handoff |
| `MACHINE_CAST.md` | Machine roles |

---

**Quickstart:** see `handoff/MACBOOK_GREEN_QUICKSTART.md`.
