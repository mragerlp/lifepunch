# LIFEPUNCH™ — Terminology (repo-wide vocabulary)

> **Status:** Active  
> **Why does this exist?** One word = one meaning across **the whole repo** — machines, people, paths, packages, CVL nodes. Stops agents from working on the wrong entity or wrong folder.  
> **Not the same as:** `KNOWLEDGE/` — learned balance notes, rejected ideas, player feel essays. **Terminology = what we call things.** Knowledge = what we learned about them.  
> **Law:** New docs use these terms. Add rows here before inventing synonyms.

---

## Terminology vs knowledge

| | **Terminology** (`TERMINOLOGY.md`) | **Knowledge** (`KNOWLEDGE/`) |
|---|-----------------------------------|------------------------------|
| **Scope** | Entire monorepo — CVL, paths, entities, roles | Lane notes, tuning, rejections, optional player feel |
| **Changes** | Architect + owner when naming settles | Architect curates anytime |
| **Example** | "Green = Cornerman" | "Hour 20 = second rack target" |

Bitcoin-specific **names** live here. Bitcoin-specific **balance/progression** lives in `KNOWLEDGE/bitcoin/`.

---

## CVL machines (RGB)

| Name | Color | Also called | Role |
|------|-------|-------------|------|
| **VENGEANCE** | **Red** | Red, primary PC, desk | GitHub source of truth · Cursor · s&box MCP · Architect chat |
| **Cornerman** | **Green** | Green, local AI box, headless LM | Tier-3 distill · LAN prep · **not** source of truth |
| **lifepunchnet** | **Blue** | Blue, hosted server, L | DXRP ops · Whisper · session hub · `lifepunch-rdp-server` lane |

**Cornerman ≠ lifepunchnet.** VENGEANCE reaches both.

Directed ping shorthand: **R → G**, **G → B**, **B → R**. Full law: `MACHINE_CAST.md` · `CVL_RGB_DOCTRINE.md`.

---

## CVL brains (roles)

| Term | Machine | Meaning |
|------|---------|---------|
| **Architect** | Red (ChatGPT) | Design — gameplay, UX, economy, briefs |
| **Integrator** | Red (Cursor) | Ship — repo law, MCP, code |
| **Distiller** | Green (Cornerman LM) | Prep — distill, cite `DECISION-####` |
| **Bloodwave** | — | Owner public alias (in-game · Steam · Discord · agent chat) |
| **mrragerlp** | — | Proprietary author on code / GitHub |
| **Mr. Rager** | — | Email / legacy contact (same person) |

---

## Repo paths & package naming

| Term | Meaning | Example |
|------|---------|---------|
| **Ident** | Legacy repo folder / code namespace | `bitcoinmining` |
| **packageSlug** | Public branch / portal name | `lifepunchbitcoin` |
| **sboxIdentifier** | Engine package id | `lifepunch.bitcoinmining` |
| **lp\*** staging | ModelDoc / upload-ready tree | `lpbitcoin/bitcoinhub/` |
| **Portal** | DXRP / s&box addon upload | Compiled `_c` required |

### Bitcoin naming (do not conflate)

| Say | Not | Why |
|-----|-----|-----|
| **lpbitcoin** / **bitcoinhub** | vague "bitcoin miner" | Staging + hub entity slug |
| **bitcoinmining** | when you mean portal package | Repo **ident** only |
| **lifepunchbitcoin** | when you mean repo path | Public **packageSlug** |
| **Hub** | HASHD Terminal, GPU Rack | Controller entity |
| **HASHD Terminal** | Hub | Operator CRT only |
| **GPU Rack** | Advanced GPU Rack | Standard worker tier |
| **Advanced GPU Rack** | GPU Rack | 2× worker tier (1 max) |

Clean paths (examples):

```text
addons/docs/BITCOIN_*.md
Assets/addons/lifepunch/lpbitcoin/bitcoinhub/
Code/Addons/lifepunch/bitcoinmining/
```

---

## Brand & platform

| Term | Meaning |
|------|---------|
| **LIFEPUNCH™** | Our owned mark — Peak Performance Products LLC · `™` not `®` while pending |
| **DXRP** | Third-party gamemode (Dxura) — we build **on** it |
| **s&box** | Facepunch engine — nominative use only |
| **Package** | Shippable addon (`addons.json`) |

---

## Cyber architecture terms

| Term | Meaning |
|------|---------|
| **Cyber System** | Controller + operator + workers + economy |
| **Controller** | Authoritative brain entity |
| **Operator Interface** | Player commands + status (terminal, hub panel) |
| **Worker** | World entity that performs work |
| **Digital Machine** | Entity stack — not a static prop |
| **Lane** | One profession workstream (e.g. `lifepunchbitcoin`) |
| **Pattern** | Reusable solved design — `PATTERN_LIBRARY.md` |

---

## Bitcoin entities (canonical)

| Term | Slug | Role |
|------|------|------|
| **Hub** | `bitcoinhub` | Controller — mining, wallet, dispatch |
| **HASHD Terminal** | `hashdterminal` | Operator — rig0, status (**never mines**) |
| **GPU Rack** | `gpurack` (standard) | Worker — 1.0× |
| **Advanced GPU Rack** | `gpurack` (advanced) | Worker — 2.0× |
| **rig0** | — | Terminal prompt |
| **hashd** | — | Daemon metaphor in copy |

---

## Workflow & doc types

| Term | Meaning |
|------|---------|
| **CURSOR BRIEF** | Architect Step 1 → Integrator |
| **DECISION-####** | Settled design — `DECISIONS/` |
| **RFC-####** | Draft — not law until promoted |
| **Knowledge** | `KNOWLEDGE/` — learned, not law |
| **Flatgrass** | Playtest truth map |
| **Fantasy Check** | Optional feel gate — see `KNOWLEDGE/gameplay/player-feel.md` |
| **Law 10 exit** | Bitcoin reference done → next cyber lane |

---

## Synonyms to avoid

| Don't say | Say instead |
|-----------|-------------|
| "Green server" / "AI server" (ambiguous) | **Cornerman** (Green) or **lifepunchnet** (Blue) |
| "Bitcoin computer" | **HASHD Terminal** |
| "Miner prop" | **Hub** or **GPU Rack** (name the role) |
| "ChatGPT" (role name) | **Architect** |
| "Cursor" (role name) | **Integrator** |
| `bitcoinmining` folder | when you mean **portal** → `lifepunchbitcoin` |
| DXRP Admin Menu (product) | **LIFEPUNCH Admin Menu for DXRP** |

---

*v1.1 — 2026-06-25 — Repo-wide CVL + path clarity*
