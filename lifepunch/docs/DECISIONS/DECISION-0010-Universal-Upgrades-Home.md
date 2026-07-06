# DECISION-0010 — Universal Upgrades Home and Terminal Defense Progression

> **Status:** Active  
> **Date:** 2026-06-25  
> **Proposed by:** Design Architect  
> **Approved by:** Bloodwave  
> **Parent:** `CYBER_VISUAL_IDENTITY_DOCTRINE.md` · `BITCOIN_UPGRADE_TAXONOMY.md`

> Integration Architect grounded the decision in repo canon and executed the merge. Design Architect owns the product decision. Bloodwave approved.

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

## Supersedes

- Bitcoin-lane “Terminal upgrades: None”
- Servers-as-primary-upgrade-shop UX

## Related

- DECISION-0005 (Terminal never mines)
- DECISION-0006 (Hub controller upgrades)
- DECISION-0007 (Preserve hub UI shell)
- `CYBER_VISUAL_IDENTITY_DOCTRINE.md`
- `MODEL_ROUTING_AMENDMENT_GROK_BUILD_1.md`

## Changes from prior canon

- Supersedes legacy "Terminal upgrades: None" statements in `BITCOIN_UPGRADE_TAXONOMY.md` and `UPGRADE_TIER_STANDARD.md` for the Bitcoin lane.
- Amends DECISION-0006: Terminal upgrade shop on CRT rejected; Terminal defense tracks via universal Hub Upgrades home accepted.
- DECISION-0005 (Terminal never mines) remains fully in force.

## v1.0 Foundation Decision

The complete three-surface structure is a v1.0 foundation:

- Three upgrade domains (Hub controller, Terminal defense/capability, GPU Rack hardware)
- Fifteen canonical tracks (names locked below)
- Five-tier schema (Tier I = stock/default; Tiers II–V = purchased progression)
- Universal Upgrades navigation in LpHashdPanel
- Authoritative ownership design (see Terminal Ownership below)
- Donor-cosmetic separation (HASHD amber family only on Bitcoin surfaces)

Implementation remains staged. v1.0 does not require every future Hacker interaction, advanced simulation formula, or long-term economic balancing to ship in the first slice. The structure itself is v1.0; it lands one approved slice at a time.

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
- `lifepunch/docs/BITCOINMINING_DONOR_PERKS.md` (alignment only)
- New: `DECISION-0010` (this file)
- Reference: `CYBER_VISUAL_IDENTITY_DOCTRINE.md` and `MODEL_ROUTING_AMENDMENT_GROK_BUILD_1.md`

## Constraints (locked)

- Universal Upgrades home lives in `LpHashdPanel`.
- Sub-tabs: HUB · TERMINAL · GPU RACK.
- 2 Standard + 1 Advanced rack maximum.
- HASHD remains amber; green/red/cyan are reserved lane identities.
- Donor visuals = cosmetic only, zero earn impact.
- No Hacker or Government production work in this pass.

## Canonical Upgrade Tracks (v1.0 foundation — names locked)

Every track displays five tiers:

- Tier I = installed stock / default level
- Tiers II–V = purchased progression
- Internal levels may be 0–4
- No player-facing Tier 0

### HUB (controller / intelligence / economy policy)

1. Job Scheduler
2. Share Pipeline
3. Pool Client
4. Farm Firmware
5. Trust Policy

### TERMINAL (defense + capability)

1. Endpoint Firewall
2. Command Authentication
3. Intrusion Detection
4. Audit Retention
5. Monitoring Suite

### GPU RACK (hardware)

1. Compute Profile
2. Cooling System
3. Power Delivery
4. Efficiency Tuning
5. Payout Buffer

### Full Tier Display Names (authoritative for UI shell)

**HUB**

- JOB SCHEDULER: I Basic Queue | II Parallel Dispatch | III Adaptive Scheduling | IV Predictive Queueing | V Autonomous Orchestration
- SHARE PIPELINE: I Single Handler | II Parallel Handling | III Batched Submission | IV Priority Pipeline | V Real-Time Aggregator
- POOL CLIENT: I Basic Stratum Client | II Persistent Session | III Low-Latency Submission | IV Failover Routing | V Optimized Pool Gateway
- FARM FIRMWARE: I Manual Control | II Watchdog Service | III Automatic Recovery | IV Predictive Maintenance | V Autonomous Operations
- TRUST POLICY: I Local Trust | II Registered Devices | III Signed Job Policy | IV Encrypted Control Bus | V Zero-Trust Fabric

**TERMINAL**

- ENDPOINT FIREWALL: I Open Rules | II Port Filtering | III Stateful Inspection | IV Adaptive Firewall | V Hardened Gateway
- COMMAND AUTHENTICATION: I PIN Session | II Session Tokens | III Signed Commands | IV Hardware Attestation | V Zero-Trust Command Chain
- INTRUSION DETECTION: I Manual Review | II Signature Alerts | III Behavioral Detection | IV Live Containment | V Predictive Threat Engine
- AUDIT RETENTION: I Volatile Logs | II Local Archive | III Tamper-Evident Logs | IV Replicated Audit Trail | V Forensic Ledger
- MONITORING SUITE: I Basic Status | II Rack Telemetry | III Alert Correlation | IV Remote Diagnostics | V Operations Command Center

**GPU RACK**

- COMPUTE PROFILE: I Stock Clocks | II Tuned Clocks | III Performance Profile | IV Aggressive Overclock | V Binned Silicon
- COOLING SYSTEM: I Open-Air Cooling | II High-Flow Fans | III Ducted Airflow | IV Liquid Loop | V Immersion Cooling
- POWER DELIVERY: I Consumer PSU | II High-Efficiency PSU | III Server PSU | IV Redundant Power | V Industrial Busbar
- EFFICIENCY TUNING: I Stock Voltage | II Basic Undervolt | III Curve Tuning | IV Dynamic Power Limit | V Adaptive Efficiency Firmware
- PAYOUT BUFFER: I Base Payout Buffer | II Expanded Buffer | III Dual-Queue Buffer | IV High-Capacity Buffer | V Industrial Payout Buffer

## Terminal Logical Ownership (G0 single-authority)

HASHD Terminal owns presentation, command-session state, and its endpoint defense/capability profile.

It does not own mining authority, the farm ledger, purchase billing, or Rack hardware state.

The Terminal defense profile is one authoritative logical record.

If existing persistence architecture requires the Hub to serialize that profile, the Hub may store or restore it as persistence infrastructure, but there must not be two independently mutable copies.

Hub owns purchase authorization, billing, linked-entity validation, and routing. LpHashdPanel is the purchase surface. The Terminal CRT remains an operating console, not a second shop.

## Next

- DECISION-0010 promoted to Active (2026-06-25).
- GO SHELL authorized per Bloodwave review (UI shell only — no economy, no persistence, no gameplay authority changes).
- Full tree, costs, effects, save migration, and economy after H10 + explicit GO UPGRADE DATA.

*Grounded and merged by Integration Architect. Product decision owned by Design Architect. Approved by Bloodwave.*
