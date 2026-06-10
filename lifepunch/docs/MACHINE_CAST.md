# LifePunch — Machine Cast (mandatory vocabulary)

> **Every agent must read this on the next session** (after `git pull --rebase`).
> Use these codenames in chat, docs, and scripts. Do not invent aliases.
> Canonical as of **June 2026**. If anything disagrees with this file, update this file in the
> GitHub monorepo — never "fix" it only in a lane clone.

---

## The three machines

| Codename | What it is | Where | Primary job |
|----------|------------|-------|-------------|
| **VENGEANCE** | Owner's primary PC | Desk — `C:\Users\jared\Projects\lifepunchaddons` | Cursor, agents, **GitHub monorepo = source of truth**, integrate partner work |
| **Cornerman** | Local AI workstation | Home LAN — `192.168.1.227`, hostname `cornerman` | Mic (AT2020), local LLM/STT, voice relay, Tier-3 prep/RAG — **not** source of truth |
| **lifepunchnet** | Always-on hosted server | Internet — `205.209.104.22`, Windows hostname **`lifepunchnet`** | DXRP/server ops, Whisper hub (`:9000`), security watchdog (`:9101`), GitLab `lifepunch-rdp-server` |

**lifepunchnet git root:** `C:\lifepunch\lifepunch-rdp-server` — `C:\lifepunch` is only a parent folder
(clones + `C:\lifepunch\status\` for watchdog). Do not `git pull` at `C:\lifepunch` itself.

### One-line disambiguation (memorize)

- **VENGEANCE** = where the owner **builds and decides** (GitHub).
- **Cornerman** = home **helper** on the LAN (mic + cheap local AI).
- **lifepunchnet** = hosted **venue** that stays on 24/7 (game server ops + shared services).

**lifepunchnet is NOT Cornerman. lifepunchnet is NOT VENGEANCE.**

---

## Agent roles vs machines

| Role | Runs on | Git write lane |
|------|---------|----------------|
| Owner / addons agent | **VENGEANCE** | GitHub monorepo |
| shottaWEB (website partner) | Partner PC | GitLab `lifepunch-website` |
| RDP server agent | **lifepunchnet** | GitLab `lifepunch-rdp-server` |
| Cornerman agent | **Cornerman** | GitHub clone (read-only deploy key → patch handoff to VENGEANCE) |

When someone says **"RDP server agent"**, they mean the **Cursor agent on lifepunchnet** — not a separate machine name.

---

## Deprecated names (do not use)

| Old / vague | Use instead |
|-------------|-------------|
| Server Host, RDP Server Host, "the server box" | **lifepunchnet** |
| Primary PC (in agent chat) | **VENGEANCE** |
| `serverHost` in JSON configs | `lifepunchnet` (legacy `serverHost` still accepted in `remote-hosts.local.json`) |
| "RDP" alone | Name the machine: **lifepunchnet** or **Cornerman** |

---

## Voice + STT routing

| Stage | Machine |
|-------|---------|
| Microphone capture | **Cornerman** |
| STT today (home LAN) | Cornerman Lemonade `:13305` (`model=Whisper-Small`) |
| STT target (hosted) | **lifepunchnet** `:9000` (`CORNERMAN_REMOTE_WHISPER_URL`) |
| Paste into Cursor / agent chat | **VENGEANCE** |

Cornerman captures audio; **lifepunchnet** transcribes when Whisper is live; **VENGEANCE** receives the text.

---

## How to connect (VENGEANCE shortcuts)

| Shortcut | Target |
|----------|--------|
| Cornerman (RDP) | `192.168.1.227` |
| lifepunchnet (RDP) | `205.209.104.22` |

Config: `lifepunch/scripts/remote-hosts.json` + gitignored `remote-hosts.local.json`.
Refresh shortcuts: `lifepunch/scripts/Install-LifePunchRemoteShortcuts.ps1`.

---

## Key docs by machine

| Machine | Runbook / prompt |
|---------|------------------|
| All agents | `AGENT_ONBOARDING.md`, `AGENT_PROMPT.md` Block 0 |
| VENGEANCE | Block A |
| shottaWEB | Block B, `SHOTTAWEB_HANDOFF.txt` |
| lifepunchnet | Block C, `lifepunch/server/LIFEPUNCHNET_INSTRUCTIONS.txt` |
| Cornerman | Block D, `DAY_ONE_AGENT_PROMPT.md`, `LOCAL_AI_WORKSTATION.md` |

---

## Sync requirement (all lanes)

Grounding (`lifepunch/docs` + `.cursor/rules`) is a **read-only mirror** in GitLab lanes.
It regenerates from the GitHub monorepo on export.

**Before your next task:**

1. `git fetch` → if working tree clean, `git pull --rebase`
2. Read **`lifepunch/docs/MACHINE_CAST.md`** (this file)
3. Confirm you can name which machine you are on and which you are *not*

If your lane looks stale (no `MACHINE_CAST.md`), tell the owner — the monorepo needs a push and
lane re-export (`setup-gitlab-projects.ps1`).
