# CORNERMAN — LPBITCOIN Realistic Mining Upgrade Redesign (Hub + Terminal + Rack)

**Date:** 2026-06-27  
**Priority:** High — background work while Red works on UI  
**Model:** Green Deep (qwen/qwen3.6-27b) + embeddings  
**Eyes covered:** Yes — work strictly from repo + this brief.

## Mission

Design a **realistic bitcoin mining operation upgrade system** for the lpbitcoin redesign.

The goal is to move away from the old abstract "CPU/Core" toy upgrades and create upgrades that meaningfully affect a real mining farm across three surfaces:

- **HUB** — Controller / Intelligence / Operations policy
- **TERMINAL** — Defense, visibility, and operator capability
- **GPU RACK** — Physical hardware characteristics

Upgrades must feel like they belong in a serious industrial crypto mining operation on a DXRP roleplay server.

## Strict Rules

- Stay within the three-surface law (DECISION-0010).
- Every track must have a clear in-world explanation that passes Law G1: *"I bought [X] so the [entity] now [verb] [effect]."*
- Respect ownership:
  - Hub owns controller-level effects (dispatch, policy, overall efficiency, security posture).
  - Racks own physical hardware effects (hashrate contribution, power draw, thermal behavior, efficiency, local buffer).
  - Terminal owns defense, monitoring, command integrity, and operator tools.
- Do **not** put rack hardware upgrades on the Hub or vice versa.
- Preserve current canon baselines where possible (Advanced rack ~2.0× yield).
- Output must be usable for implementation: concrete track names, tier effects, data model suggestions, and UI implications.
- Save all major deliverables to both:
  - `C:\LIFEPUNCH\Reports\`
  - `C:\lifepunch\cornerman\outbox\`
- Filename pattern: `YYYY-MM-DD_HHMM_LPBitcoin_Upgrades_[Topic].md`
- After each major deliverable, append one line to `C:\LIFEPUNCH\Reports\foundation-index.txt`.

## Required Reading (from repo)

- `lifepunch/addons/docs/BITCOIN_UPGRADE_TAXONOMY.md`
- `lifepunch/docs/DECISIONS/DECISION-0010-Universal-Upgrades-Home.md`
- `lifepunch/addons/docs/BITCOIN_CONTROLLER_PATTERN.md`
- `lifepunch/addons/docs/BITCOIN_DATA_FLOW.md`
- `lifepunch/docs/LIFEPUNCH_GAMEPLAY_LAWS.md` (especially G0, G1)
- Current Hub / Rack / Terminal entity code (for data shape understanding)
- `CYBER_VISUAL_IDENTITY_DOCTRINE.md` (for Terminal appearance vs defense separation)

## High-Value Deliverables (work through these in order)

### 1. Final 15-Track Catalog (5 per surface)

Lock clean, player-facing names for all 15 tracks.

For each track provide:
- Surface (HUB / TERMINAL / GPU RACK)
- Short description
- In-world flavor sentence (Law G1 test)
- Primary realistic effect category (hashrate, power, thermal, efficiency, stability, buffer, defense, visibility, etc.)

### 2. Tier Progression & Realistic Effects (I → V)

For every track, define what Tier I (baseline) through Tier V does in concrete mining terms:

Suggested dimensions to affect (mix per track, not all at once):
- Base hashrate contribution (TH/s or multiplier)
- Power draw (watts or %)
- Thermal / heat generation
- Thermal stability / throttling threshold
- Efficiency (J/TH or hash per watt)
- Local buffer size (USD + BTC dual cap)
- Stability / error rate under load
- Defense / detection values (for Terminal tracks)
- Monitoring / telemetry quality
- Risk surface (hacker attractiveness, etc.)

Provide approximate deltas per tier (you may use relative multipliers or absolute values — be consistent).

### 3. Cross-Surface Interactions & Synergies

Document meaningful interactions, for example:
- Better Hub "Clock Path" + good Rack Cooling allows higher safe overclock on racks.
- Strong Terminal "Intrusion Detection" reduces effectiveness of certain hacker actions.
- High Hub "Security Policy" reduces buffer loss on hack events.
- Rack "Efficiency" upgrades reduce power draw, which indirectly helps thermal and PSU tracks.

### 4. Data Model & Entity Shape Recommendations

Propose the minimal clean fields that should live on:
- `LpBitcoinHubEntity`
- `LpBitcoinRackEntity` (standard + advanced)
- `LpBitcoinTerminalEntity`

Include:
- Which entity owns which upgrade state
- How upgrades are stored (levels per track)
- What needs to be networked / synced
- Any derived values that should be computed (total hashrate, current power draw, effective efficiency, etc.)

### 5. In-World Explanation & Flavor Text Bank

For the top 8–10 tracks, write strong player-facing descriptions that would appear in the Universal Upgrades UI.

### 6. UI Implications for the Universal Upgrades Home

Given the current v1 shell (surface chips → per-surface views), recommend:
- How to show rack selection for GPU RACK surface (Rack 1 / Rack 2 / Advanced)
- What stats should be visible per upgrade card (current effect, next tier effect, power/thermal side effects)
- Any summary panels that should live on the Hub Overview when upgrades are purchased (e.g. "Total Farm Hashrate", "Average Efficiency", "Current Thermal Headroom")

### 7. Migration / Legacy Cleanup Notes

Clear guidance on what must be removed or migrated from the old CPU/Core per-rack upgrade system.

## Output Quality Bar

Be specific and implementation-ready. Avoid vague "improves performance." Say things like:

> "Clock Path III increases Hub work dispatch rate by +18% while raising controller power draw by +12%."

## Start Now

Begin with Deliverable 1 (the clean 15-track catalog with short descriptions and Law G1 sentences). Then move to tier effects.

Once you have a solid first pass on 1 + 2, produce a single consolidated document called something like:

`LPBITCOIN_REALISTIC_MINING_UPGRADES_V1_DESIGN.md`

Keep iterating in the background. This is the foundation Red will implement the UI against.

You have until further notice. Prioritize depth and realism over speed.