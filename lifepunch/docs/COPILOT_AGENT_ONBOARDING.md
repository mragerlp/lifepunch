# LIFEPUNCH™ — Copilot Agent Onboarding

**Purpose:** Full context fallback for any Copilot session that does not have VS Code instructions auto-loaded.  
**Read when:** Starting a fresh Copilot session outside VS Code, or when context has been lost.  
**Primary bootstrap (VS Code):** `.github/instructions/*.instructions.md` auto-loads all 20 rules.  
**Operational state:** `lifepunch/docs/handoff/COPILOT_NEW_SESSION_BOOTSTRAP.txt`

---

## Who We Are

**LIFEPUNCH™** — owned by Peak Performance Products LLC (NJ single-member LLC, sole member Jared Zerillo).  
Public alias: **Bloodwave**. Code author: **mragerlp**. Email/legacy: Mr. Rager.  
Mark: `™` only — USPTO registration pending (#402997 / #397871). **Never `®`.**  
We are the **largest community server operator on DXRP** — not an addon studio.  
Our LPAddons are **proprietary** playerbase-retention tools. Not sold to other operators. Not contributed to Dxura/official.  
Community: discord.gg/lifepunch

---

## The Platform

- **s&box** (Facepunch engine) — nominative use only; we don't own it
- **DXRP** (Dxura gamemode) — nominative use only; we don't own it
- **Dimmer** = Dxura/DXRP developer team — they use VS Code + GitHub Copilot (same stack as us)
- We build **on** DXRP, not **for** Dxura

---

## CVL Tri-Stack (three machines, three roles)

| Color | Machine | IP | Role |
|-------|---------|-----|------|
| **Red** | **VENGEANCE** | 192.168.1.236 | Primary PC · GitHub · s&box editor · Copilot (primary IDE) · commits |
| **Green** | **Cornerman** | 192.168.1.229 | Local LM workstation · Tier-3 distill only · never commits · never ships |
| **Blue** | **lifepunchnet** | 205.209.104.22 | Always-on hosted DXRP server · ops runtime |

**VENGEANCE = source of truth.** Cornerman preps; never makes ship decisions.

---

## CVL Agent Family

| Role | Tool | Machine | Authority |
|------|------|---------|-----------|
| **Integration Architect** | GitHub Copilot | Red (VENGEANCE) | Code · MCP · commits (with GO) |
| **Design Architect** | ChatGPT | Red | Player fantasy · laws · economy briefs |
| **Distillation Architect** | Cornerman LM | Green | Distill · prep · never canon |
| **Bloodwave** | Owner | — | Final GO on all commits/ships |

---

## The Cyber Ecosystem (what we're building)

A fully-designed criminal ↔ lawful ↔ city economy loop on DXRP:

```
Bitcoin operators (amber/HASHD) mine BTC → Hackers (green/red) steal wallets
→ Bankers (navy) grow bank passive → Black Market (black) sells contraband for BTC
→ Government (cyan) taxes mining, FBI counters hackers
```

**Bitcoin is the reference implementation** — its quality floor caps all future cyber lanes.

| Lane | Identity | Status |
|------|----------|--------|
| **Bitcoin** (active) | HASHD amber · `bitcoinhub` + `hashdterminal` + `gpurack` | **Phase A Hub polish — active** |
| Banker | Navy `#000080` | Tier 1 after Bitcoin Law 10 |
| Hacker | Green `#00FF7F` (Cornerman) / Red `#E4002B` (VENGEANCE) | Quarantined until Bitcoin done |
| Black Market | Black `#000000` shell | Parked |
| Government | Cyan `#00D4FF` (lifepunchnet) | Blocked until Hacker Phase E |

**No NPC systems ever (Law G9).** Everything is player/machine/infrastructure driven.

---

## Active Lane: lifepunchbitcoin

**Package:** `lifepunchbitcoin` · repo ident `bitcoinmining` · s&box `lifepunch.bitcoin`  
**Phase:** A Hub polish · **Next executable:** H4+H5 (world power/audio) — waiting on Bloodwave GO  
**Phase B** (HASHD Terminal) locked until H10 owner sign-off  
**Phase C** (GPU Rack) locked until Phase B done

**Hub entity tracker:**
- `[~]` H1 — scale/ground pipeline fixed, owner sign-off pending
- `[ ]` H4 — powered vs off world readability (emissive + optional point light)
- `[ ]` H5 — hub audio baseline (startup / fan loop / fan down)
- `[~]` H7 — HASHD admin UI unlinked — owner OK
- `[ ]` H10 — hub hero sign-off → unlocks Phase B

**Parallel lanes (non-gate):**
- `lifepunchulx r10` — committed, portal upload pending
- `lpmonnowsprinterupgrade Rev 9` — staging ready, portal pin pending

---

## MCP Stack (all 4 — `.vscode/mcp.json`)

| Server | Transport | Purpose |
|--------|-----------|---------|
| `sbox` | File IPC / `npx sbox-mcp-server` | Runtime · play proof · spawn · screenshots |
| `sbox-editor` | HTTP `127.0.0.1:9090/sbox-mcp` | Authoring · compile · ModelDoc · prefabs |
| `sbox-jtc` | HTTP `localhost:29015/mcp` | Scene graph · API/docs lookup · editor automation |
| `cornerman-lm` | Node `local-llm-mcp-server` | Cornerman distill/prep tasks |

**Verify connectivity:** `Get-CvlConnectivityStatus.ps1 -Pretty` → `allOk: true`

---

## Model Routing (Copilot on VENGEANCE)

| Tag | Route | When |
|-----|-------|------|
| `AUTO OK` | Claude Sonnet 4.6 (Copilot default) | ~80% of work |
| `OPUS REQUIRED` | Claude Opus 4.8 (manually select) | Architecture · multi-file C# · economy · security |
| `GROK REQUIRED` | Cursor → Grok Build 1 | Bounded Razor/SCSS · planning · ModelDoc maps |
| `GREEN CODE REQUIRED` | Cornerman Qwen Coder | Tier-3 candidate patches |
| `GREEN DEEP REQUIRED` | Cornerman Qwen dense | Distill · warm · bulk prep |

**Never let default Sonnet substitute for:** economy · `[Sync(FromHost)]` · RPCs · migration · power/link state machines.

---

## Hard Laws (never violate)

- **G0:** Hub owns mining + wallet. Terminal **never** mines. Rack owns worker compute.
- **G9:** No LIFEPUNCH NPC dependency — player/machine/infrastructure driven only.
- **Law 5:** Flatgrass host play is truth — not editor screenshots or prefab tab.
- **Law 9:** "While we're here…" → `BACKLOG_PARKING_LOT.md` only. No scope creep.
- **Law 10:** Bitcoin reference complete → only then unlock next cyber lane.
- **DECISION-0010:** Universal Upgrades Home in `LpHashdPanel` (HUB · TERMINAL · GPU RACK) — structure locked.
- **No Co-authored-by AI trailers.** Ever. Author = `mragerlp` only.
- **No commits without Bloodwave GO.** Propose scope; wait for explicit yes.
- **One checklist ID at a time.** No batching across phase gates.

---

## Commit Hygiene

```powershell
cd C:\Users\jared\Projects\lifepunchdxrp
git add <files>
git commit -m "<type>(<scope>): <description>"
git push
```

- No `Co-authored-by` trailers (Copilot or otherwise)
- Commit author = `mragerlp <mragerlp@gmail.com>`
- No commits unprompted — always ask Bloodwave first
- No force-push to `main`

---

## Repo Paths (do not confuse)

| Path | Purpose |
|------|---------|
| `C:\Users\jared\Projects\lifepunchdxrp` | **Source of truth** — GitHub monorepo, edit here |
| `D:\Steam\steamapps\common\sbox\dxrp\game` | Steam runtime — sync target, NEVER commit from here |
| `C:\Users\jared\Projects\dxrp` | DXRP upstream fork — vanilla PRs only, no LifePunch headers |

---

## Key Terminology

| Say | Not |
|-----|-----|
| **lpbitcoin** / **bitcoinhub** | "bitcoin miner" (vague) |
| **bitcoinmining** | when you mean portal package |
| **lifepunchbitcoin** | when you mean repo path |
| **Hub** | HASHD Terminal or GPU Rack |
| **HASHD Terminal** | Hub |
| **LIFEPUNCH™** | LIFEPUNCH® (pending only) |
| **Integration Architect** | Cursor (Cursor is now legacy Grok lane) |

---

## Visual Identity (locked — never mix)

| Lane | Accent | Forbidden on Bitcoin surfaces |
|------|--------|-------------------------------|
| HASHD (Bitcoin) | Amber `#f0a500` | — |
| Cornerman (Hacker) | Green `#00FF7F` | ✗ on Bitcoin UI |
| VENGEANCE (Adv. Hacker) | Red `#E4002B` | ✗ on Bitcoin UI |
| lifepunchnet (Gov) | Cyan `#00D4FF` | ✗ on Bitcoin UI |

---

## Session Boot Sequence

```powershell
# 1. Sync
cd C:\Users\jared\Projects\lifepunchdxrp
git fetch; git pull --rebase

# 2. Start editor + sync addons
powershell -File lifepunch\scripts\Start-SboxDxrpEditor.ps1 -FullCapacity -PreflightFix -BitcoinOnly -SyncAddon lpbitcoin,adminmenu

# 3. Verify connectivity
powershell -File lifepunch\scripts\Get-CvlConnectivityStatus.ps1 -Pretty
```

Target: `allOk: true` · MCP: `sbox` · `sbox-editor` · `cornerman-lm` · `sbox-jtc`

---

## Read Order (lean boot)

1. `lifepunchaddons/docs/ACTIVE_WORKSTREAM.md` — hard gate
2. `lifepunchaddons/docs/BITCOIN_SHIP_ROADMAP.md` — step order
3. `lifepunchaddons/docs/OWNER_PROGRESS_TRACKER.txt` — current state (one ID)
4. `lifepunch/docs/handoff/ARCHITECT_CURRENT_STATE.md` — dated volatile state
5. `lifepunch/docs/MACHINE_CAST.md` — CVL topology

---

*Last updated: 2026-06-30 — Copilot promoted to primary Integration Architect on VENGEANCE.*
