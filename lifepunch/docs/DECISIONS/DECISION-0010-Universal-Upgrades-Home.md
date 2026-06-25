# DECISION-0010 — Universal Upgrades Home and Terminal Defense Progression

> **Status:** Draft for owner review (2026-06-25)  
> **Date:** 2026-06-25  
> **Proposed by:** Integration Architect (per Architect plan)  
> **Approved by:** Pending — Bloodwave  
> **Parent:** `CYBER_VISUAL_IDENTITY_DOCTRINE.md` · `BITCOIN_UPGRADE_TAXONOMY.md`

## Decision

A single **Universal Upgrades** home is added to `LpHashdPanel` as a first-class top tab.

Inside it, ULX-style upper sub-tabs:

- **HUB** — five controller / intelligence / economy policy tracks
- **TERMINAL** — five defense and capability tracks (firewall, intrusion detection, encryption policy, command auth, monitoring / audit)
- **GPU RACK** — five hardware tracks (compute, cooling, power, efficiency, buffer)

Terminal progression is **real** (defense + ops capability). Terminal **never mines**. Purchases are made from the universal home (not a shop directly on the CRT).

Donor visuals remain a separate cosmetic lane (HASHD amber family only).

## Reason

- Players need one obvious place for all purchasable progression.
- Terminal as "just presentation" is superseded by owner direction: Terminal is a defended operator surface in the cyber ecosystem.
- Three-surface law (Hub / Terminal / Rack) matches the Bitcoin machine stack and future lanes.
- Preserves `LpHashdPanel` shell (per DECISION-0007).

## Changes from prior canon

- Supersedes legacy "Terminal upgrades: None" statements in `BITCOIN_UPGRADE_TAXONOMY.md` and `UPGRADE_TIER_STANDARD.md` for the Bitcoin lane.
- Amends DECISION-0006: Terminal upgrade shop on CRT rejected; Terminal defense tracks via universal Hub Upgrades home accepted.
- DECISION-0005 (Terminal never mines) remains fully in force.

## Systems affected

- `LpHashdPanel.razor` + SCSS (new top tab + sub-chips)
- `BITCOIN_UPGRADE_TAXONOMY.md`
- `BITCOIN_CONTROLLER_PATTERN.md`
- `BITCOIN_DATA_FLOW.md`
- `BITCOIN_PLAYER_DESIGN.md`
- `LIFEPUNCH_CYBER_SYSTEM_PATTERN.md`
- `LIFEPUNCH_HUB_PATTERN.md`
- `PATTERN_LIBRARY.md`
- `TERMINAL_BRAND_MATRIX.md`
- `BITCOIN_SHIP_ROADMAP.md`
- `ARCHITECT_CURRENT_STATE.md`
- `BITCOINMINING_DONOR_PERKS.md` (alignment only)
- New: `DECISION-0010` (this file)
- Reference: `CYBER_VISUAL_IDENTITY_DOCTRINE.md` and `MODEL_ROUTING_AMENDMENT_GROK_BUILD_1.md`

## Constraints (locked)

- Universal Upgrades home lives in `LpHashdPanel`.
- Sub-tabs: HUB · TERMINAL · GPU RACK.
- 2 Standard + 1 Advanced rack maximum.
- HASHD remains amber; green/red/cyan are reserved lane identities.
- Donor visuals = cosmetic only, zero earn impact.
- No Hacker or Government production work in this pass.
- No code changes during documentation reconciliation pass.

## Next

After owner review:
- Approve this DECISION-0010.
- Proceed to GO SHELL (empty Upgrades tab + three sub-tabs + placeholders, no economy).
- Full tree and economy after H10 + explicit GO.

*Draft prepared by Integration Architect. Owner approval required before canon promotion.*
