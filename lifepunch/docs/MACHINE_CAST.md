# LifePunch — Machine Cast (mandatory vocabulary)

> **Every agent must read this on the next session** (after `git pull --rebase`).
> Use these codenames in chat, docs, and scripts. Do not invent aliases.
> Canonical as of **June 2026**. If anything disagrees with this file, update this file in the
> GitHub monorepo — never "fix" it only in a lane clone.

---

## The LifePunch web

VENGEANCE, Cornerman, and lifepunchnet are **nodes in one web** — not separate puzzles or
one-off boxes. Voice, STT, session sync, branding, and git lanes are **edges** between nodes.
**VENGEANCE** is the hub that reaches both LAN (Cornerman) and internet (lifepunchnet).

Say **LifePunch web** (or **the web**) when you mean the whole distributed desk + voice + hosted
stack. Say a **node** when you mean one machine. Do **not** call the three-machine setup a
"puzzle" — that word is reserved for the in-game Hacker Job coding mini-game only.

---

## CVL naming (mandatory)

**CVL** = **C**ornerman · **V**engeance · **L**ifepunchnet — the three-node integration web (RGB tri-stack).

| Machine | Spoken alias | Letter |
|---------|--------------|--------|
| **Cornerman** | **Green** | **C** |
| **VENGEANCE** | **Red** | **V** |
| **lifepunchnet** | **Blue** | **L** |

**Architect** (Mac / MacBook) is **not** a CVL letter — planner and design lane outside the RGB tri-stack.
Integration law: **`CVL_RGB_DOCTRINE.md`**.

---

## The three machines (+ Mac control plane)

| Codename | What it is | Where | Primary job |
|----------|------------|-------|-------------|
| **VENGEANCE** | Owner's primary PC (**Red**) | Desk — `C:\Users\jared\Projects\lifepunch` | **Orchestrate** · s&box editor · bridge · flatgrass proof · **git push** · GitHub source of truth |
| **MacBook** | **Architect** (planner) | macOS — `~/Projects/lifepunch` | Native **Cursor + Copilot** · comms · RDP → Cornerman for workshop/bridge |
| **Cornerman** | **Green** (execution workshop) | LAN — `192.168.1.229` · `C:\Projects\lifepunch` | **Warm LM · distill · heavy agent work** · mic · bridge MCP (SMB to Red) |
| **lifepunchnet** | Always-on hosted server (**Blue**) | `205.209.104.22` | DXRP/server ops, Whisper, watchdog, session hub, GitLab RDP lane |

**lifepunchnet git root:** `C:\lifepunch\lifepunch-rdp-server` — `C:\lifepunch` is only a parent folder
(clones + `C:\lifepunch\status\` for watchdog). Do not `git pull` at `C:\lifepunch` itself.

### One-line disambiguation (memorize)

- **VENGEANCE (Red)** = orchestrate · runtime truth · proof · publish.
- **Architect (Mac)** = planner · design briefs · RDP to Green when needed.
- **Cornerman (Green)** = warm · distill · execute heavy work on local mirror.
- **lifepunchnet (Blue)** = hosted venue 24/7 (game server ops + shared services).

Full workflow: **`GREEN_EXECUTION_MODEL.md`** · agent pastes: **`handoff/AGENT_GROUNDING_INDEX.md`**

### CVL Architect family (roles — machines are not roles)

| Role | Host | Alias |
|------|------|-------|
| **Design Architect** | **Architect (Mac)** · VENGEANCE (Red at desk) — ChatGPT | Architect |
| **Integration Architect** | Red + Green + Mac comms | Integrator |
| **Distillation Architect** | Cornerman (Green) — warm + distill + execute | Distiller |
| **Operations Architect** | lifepunchnet — RDP agent | RDP server agent |
| **Bloodwave** | — | Owner / final authority |

**lifepunchnet is NOT Cornerman. lifepunchnet is NOT VENGEANCE.**

---

## Execution surfaces (July 2026)

**Bloodwave orchestrates on Red.** Cornerman **warms, distills, and executes** heavy agent work.
**Architect (Mac)** is the planner (native Cursor + Copilot; RDP → Green when needed).
**Red always owns runtime** (s&box, Claude Bridge, Host Play, flatgrass proof, primary git push).

| Surface | Where | IDE | Use when |
|---------|--------|-----|----------|
| **Architect** | MacBook (macOS) | Cursor + Copilot · **ChatGPT Design Architect** | Planning · ideation · CURSOR BRIEFs · RDP → Green |
| **Green** | Cornerman (`192.168.1.229`) | **Headless — no IDE (by role)** | Heavy implementation · distill · bridge MCP · Cornerman LM · patch-handoff to Red |

**Sync law:** whoever did heavy work — other nodes **`git pull --rebase`** (Cornerman → Red via patch-handoff).

Agent pastes (Cursor + Copilot × Red · Cornerman · Mac): **`handoff/AGENT_GROUNDING_INDEX.md`**

---

## How agents should refer to people (alias-first)

**June 2026 aliases:** **Bloodwave** = visible (in-game · Steam · Discord). **mrragerlp**
(`mrragerlp@lifepunch.co`) = proprietary / legal author on code. **Mr. Rager** = legacy contact.
Full policy: `BLOODWAVE_ALIAS.md`.

| Who | Visible / agent | Proprietary / legal | Contact |
|-----|-----------------|---------------------|---------|
| Owner | **Bloodwave** | **mrragerlp** · mrragerlp@lifepunch.co | Mr. Rager, Jared; GitHub remote `mragerlp` |
| Partner | **shottaWEB** | — | Brian |

Prefer **Bloodwave** in agent prose; **mrragerlp** in proprietary headers.

---

## Owner identity (one person)

| Context | Names |
|---------|--------|
| Agent default | **Bloodwave** (in-game · Steam · Discord · agent chat) |
| Proprietary / legal author | **mrragerlp** · **mrragerlp@lifepunch.co** |
| Contact / legacy | Mr. Rager, Jared |
| GitHub monorepo remote | mragerlp |
| Git commit author | **mragerlp** · mragerlp@gmail.com |

**lifepunchnet RDP** may show Windows user **`administrator`** — still Bloodwave/owner. Watchdog `allowedUsers`: `jared`, `administrator`.

---

## Partner identity (one person — website lane)

| Context | Names |
|---------|--------|
| Agent default | **shottaWEB** |
| Person (human) | Brian |
| GitLab | `lifepunch-website` · invite `br.black4022@gmail.com` |

**partner** = **shottaWEB** = Brian. In agent chat, say **shottaWEB** first — not Cornerman, not lifepunchnet, not the owner.

---

## Agent roles vs machines

| Role | Runs on | Git write lane |
|------|---------|----------------|
| Owner / addons agent (**Integrator**) | **VENGEANCE (Red)** orchestrate · **Cornerman (Green)** execute | GitHub monorepo (Red push; Cornerman patch-handoff) |
| **Architect** (planner) | **MacBook (Mac)** | Mac clone (optional push; sync with Red/Green) |
| **Design Architect** (ChatGPT) | **Architect (Mac)** primary · Red when at desk | **No git** — CURSOR BRIEFs only |
| **shottaWEB** (Brian) | Partner PC | GitLab `lifepunch-website` |
| RDP server agent | **lifepunchnet (Blue)** | GitLab `lifepunch-rdp-server` |
| Cornerman agent (**Distiller + executor**) | **Cornerman (Green)** | Read-only deploy key → patch handoff to Red |

**Architect** is the Mac planner lane (ChatGPT + Cursor). See `ARCHITECT.md`.

When someone says **"RDP server agent"**, they mean the **Cursor agent on lifepunchnet** — not a separate machine name.

---

## Deprecated names (do not use)

| Old / vague | Use instead |
|-------------|-------------|
| Server Host, RDP Server Host, "the server box" | **lifepunchnet** |
| Primary PC (in agent chat) | **VENGEANCE** |
| `serverHost` in JSON configs | `lifepunchnet` (legacy `serverHost` still accepted in `remote-hosts.local.json`) |
| "RDP" alone | Name the machine: **lifepunchnet** or **Cornerman** |
| Green A, Green B | **Architect (Mac)** · **Green (Cornerman)** |

---

## Voice + STT + session routing

| Stage | Machine |
|-------|---------|
| Microphone capture | **Cornerman** |
| STT (hosted) | **lifepunchnet** `:9000` (`CORNERMAN_REMOTE_WHISPER_URL`, `small.en`) |
| Paste into Cursor / agent chat | **VENGEANCE** (`LifePunch Voice Comms` shortcut or `start-voice-comms.ps1`) |
| Session log sync | **VENGEANCE** bridge → **lifepunchnet** `http://205.209.104.22:9102/ingest` (Bearer = `status-token.txt`; `start-session-sync.ps1`) |
| Read logs + Odysseus / long context | **lifepunchnet** (RDP) — `LIFEPUNCHNET_RDP_ODYSSEUS.txt` |

Cornerman stays thin (mic + relay). **lifepunchnet** transcribes and stores session history.
**VENGEANCE** is the only host that reaches both Cornerman (LAN) and lifepunchnet (internet).

---

## How to connect (VENGEANCE shortcuts)

Icons = **destination / scope** (at a glance, not a telescope). Full checkpoint:
`lifepunch/docs/OPS_CLARITY_CHECKPOINT.md`.

| Shortcut | Icon tier | Target / job |
|----------|-----------|----------------|
| **LifePunch — Start Day** | Universal (tri-stack) | Full voice stack — gate + watchers + Cornerman relay |
| **LifePunch Voice Preflight** | Universal | Cross-node health check |
| **LifePunch Voice Comms** | Red (VENGEANCE) | VENGEANCE watchers only |
| **Talk to Vengeance** | Red (VENGEANCE) | Cornerman PTT (icon red: voice **to** VENGEANCE) |
| **Cornerman (RDP)** | Green | `192.168.1.229` |
| **lifepunchnet (RDP)** | Blue | `205.209.104.22` |

Config: `lifepunch/scripts/remote-hosts.json` + gitignored `remote-hosts.local.json`.
Refresh all shortcut icons: `lifepunch/scripts/Install-LifePunchShortcutIcons.ps1`.

**Explorer icons (all nodes):** gray folder + gray `.txt` — `OneDrive\Desktop\uniforms\PNGs\`;
`lifepunch/branding/lifepunch-ops/Set-LifePunchExplorerIcons.ps1`. Standards:
`UNIFORM_STANDARDS.md` (OneDrive + repo mirror).

---

## Key docs by machine

| Machine | Runbook / prompt |
|---------|------------------|
| All agents | `AGENT_ONBOARDING.md`, `GREEN_EXECUTION_MODEL.md`, `handoff/AGENT_GROUNDING_INDEX.md`, `ARCHITECT.md`, `AGENT_PROMPT.md` Block 0 |
| VENGEANCE (Red) | Block A · `RED_CURSOR_GROUNDING_PASTE.txt` · `RED_COPILOT_GROUNDING_PASTE.txt` · `RED_FULL_CAPACITY_BOOT.md` |
| MacBook (Architect) | Block M · `MAC_GREEN_*` · **`ARCHITECT_ONBOARDING_PASTE.txt`** · `ARCHITECT.md` |
| Cornerman (Green) | Block D · `GREEN_CORNERMAN_*_GROUNDING_PASTE.txt` · `GREEN_SMB_BOOT_PASTE.md` · `LOCAL_AI_WORKSTATION.md` |
| **shottaWEB** | Block B, `SHOTTAWEB_HANDOFF.txt` |
| lifepunchnet | Block C, `LIFEPUNCHNET_INSTRUCTIONS.txt`, `LIFEPUNCHNET_RDP_ODYSSEUS.txt` |

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
