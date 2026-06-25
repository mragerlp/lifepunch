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

## The three machines

| Codename | What it is | Where | Primary job |
|----------|------------|-------|-------------|
| **VENGEANCE** | Owner's primary PC | Desk — `C:\Users\jared\Projects\lifepunchaddons` | Cursor, agents, **GitHub monorepo = source of truth**, integrate partner work |
| **Cornerman** | Local AI workstation | Home LAN — `192.168.1.227`, hostname `cornerman` | Mic (AT2020), local LLM/STT, voice relay, Tier-3 prep/RAG — **not** source of truth |
| **lifepunchnet** | Always-on hosted server | Internet — `205.209.104.22`, Windows hostname **`lifepunchnet`** | DXRP/server ops, Whisper (`:9000`), watchdog (`:9101`), session hub (`:9102`), Odysseus (optional), GitLab `lifepunch-rdp-server` |

**lifepunchnet git root:** `C:\lifepunch\lifepunch-rdp-server` — `C:\lifepunch` is only a parent folder
(clones + `C:\lifepunch\status\` for watchdog). Do not `git pull` at `C:\lifepunch` itself.

### One-line disambiguation (memorize)

- **VENGEANCE** = where the owner **builds and decides** (GitHub).
- **Cornerman** = home **helper** on the LAN (mic + cheap local AI).
- **lifepunchnet** = hosted **venue** that stays on 24/7 (game server ops + shared services).

### CVL Architect family (roles — machines are not roles)

| Role | Host | Legacy alias |
|------|------|--------------|
| **Design Architect** | VENGEANCE — ChatGPT | Architect |
| **Integration Architect** | VENGEANCE — Cursor | Integrator |
| **Distillation Architect** | Cornerman — local LM | Distiller |
| **Operations Architect** | lifepunchnet — RDP agent | RDP server agent |
| **Bloodwave** | — | Owner / final authority |

**lifepunchnet is NOT Cornerman. lifepunchnet is NOT VENGEANCE.**

---

## How agents should refer to people (alias-first)

**June 2026 aliases:** **Bloodwave** = visible (in-game · Steam · Discord). **mrragerlp** = proprietary /
legal author on code. **Mr. Rager** = email and legacy contact. Full policy: `BLOODWAVE_ALIAS.md`.

| Who | Visible / agent | Proprietary / legal | Contact |
|-----|-----------------|---------------------|---------|
| Owner | **Bloodwave** | **mrragerlp** | Mr. Rager, Jared; GitHub remote `mragerlp` |
| Partner | **shottaWEB** | — | Brian |

Prefer **Bloodwave** in agent prose; **mrragerlp** in proprietary headers.

---

## Owner identity (one person)

| Context | Names |
|---------|--------|
| Agent default | **Bloodwave** (in-game · Steam · Discord · agent chat) |
| Proprietary / legal author | **mrragerlp** |
| Contact / legacy | Mr. Rager, Jared |
| GitHub monorepo remote | mragerlp |
| Git author accounts | mrragerlp, mragerlp |

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
| Owner / addons agent (**Integrator**) | **VENGEANCE** | GitHub monorepo |
| **Architect** (design brain) | **VENGEANCE** (ChatGPT — same desk as Integrator) | **No git** — CURSOR BRIEFs only |
| **shottaWEB** (Brian) | Partner PC | GitLab `lifepunch-website` |
| RDP server agent | **lifepunchnet** | GitLab `lifepunch-rdp-server` |
| Cornerman agent (**Distiller**) | **Cornerman** | GitHub clone (read-only deploy key → patch handoff to VENGEANCE) |

**Architect** is not a machine — it is ChatGPT on Red. See `ARCHITECT.md`.

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
| **Cornerman (RDP)** | Green | `192.168.1.227` |
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
| All agents | `AGENT_ONBOARDING.md`, `ARCHITECT.md`, `OPS_CLARITY_CHECKPOINT.md`, `AGENT_PROMPT.md` Block 0 |
| VENGEANCE | Block A |
| **shottaWEB** | Block B, `SHOTTAWEB_HANDOFF.txt` |
| lifepunchnet | Block C, `LIFEPUNCHNET_INSTRUCTIONS.txt`, `LIFEPUNCHNET_RDP_ODYSSEUS.txt` |
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
