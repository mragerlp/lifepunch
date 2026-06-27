# Bitcoin — upgrade taxonomy (canonical ownership)

> **Status:** Active — **ownership canon**; final five-by-five upgrade taxonomy pending Architect + Bloodwave approval  
> **Why does this exist?** Every upgrade must have one buyer surface and one authoritative owner.  
> **How:** Hub Upgrades tab vs Servers per-rack UI — preserve `LpHashdPanel` chrome.  
> **Parent:** `BITCOIN_CONTROLLER_PATTERN.md` · `LIFEPUNCH_GAMEPLAY_LAWS.md` G1

---

## Hub upgrades (controller)

Purchased from **Hub → Hub Upgrades** tab (new — preserve existing hub chrome).

### Categories (working draft — not final five-by-five)

Bloodwave target: **five Hub upgrades × five tiers** + **five Rack upgrades × five tiers**.  
Current buckets below are **ownership direction only** — not final names, effects, or tier labels.

| Category | Includes (target) | Player-facing story |
|----------|-------------------|---------------------|
| **Intelligence** | Share handling, dispatch policy, yield multipliers | Hub "thinks faster" about work |
| **Controller** | Clock path, scheduler firmware, core threads | Hub dispatches work more efficiently |
| **Economy** | Wallet policy, security/encryption, automation QoL | Hub protects and manages value |

### Example tiers

| Tier name | Category | Gameplay effect (target) |
|-----------|----------|---------------------------|
| **Clock path** | Controller | **Working abstraction — Architect decision pending; do not implement** |
| **Core count** | Controller / Intelligence | **Working abstraction — Architect decision pending; do not implement** |
| **Security / encryption** | Economy | PvP defense vs hacker lane |
| **Automation** (future) | Economy | Job queue polish — optional v1; **unset for v1.0** |

**Not on hub:** GPU die counts, rack thermal paste, per-rack OC sliders.

---

## Rack upgrades (hardware / Servers tab)

Purchased per linked rack from **Hub → Servers** → rack card → upgrade (preserve 3-card layout).

### Categories (working draft — not final five-by-five)

Six Rack buckets today vs five target — **which category merges or retires is unset** (Architect + Bloodwave).

| Category | Player-facing story | Gameplay effect (target) |
|----------|---------------------|---------------------------|
| **Compute** | GPU OC profile, silicon tier | Rack hashrate contribution |
| **Cooling** | Airflow, paste, fan curve | Stability, throttle headroom |
| **Power** | PSU tier | Draw cap before warning state |
| **Efficiency** | Power-to-hash tuning | More hash per watt |
| **Reliability** | Fault tolerance, uptime (future depth) | Fewer WARNING/ERROR transitions |
| **Buffer** | Rack wallet tank expansion | Raises local BTC cap before deposit |

**Not on rack:** Pool connection, hub scheduler, encryption tracks.

---

## Terminal upgrades

**See `CYBER_VISUAL_IDENTITY_DOCTRINE.md` (2026-06-25).**

Terminal is a real surface (defense + appearance) under the three-surface law (Hub / Terminal / Rack).

Canonical tracks (locked in DECISION-0010):

- Endpoint Firewall
- Command Authentication
- Intrusion Detection
- Audit Retention
- Monitoring Suite

- **Defense / capability progression** (the five tracks above) lives here via the universal Upgrades home. The Terminal defense profile is one authoritative logical record.
- **Appearance** on the Bitcoin Terminal must stay within HASHD-safe donor cosmetics only (amber/gold/warm white/bronze/dark graphite + controlled accents). Full Cornerman green, VENGEANCE red, or lifepunchnet cyan-blue is prohibited on Bitcoin surfaces.
- Transient hostile lane colors (green/red/cyan) may appear only as attack-state indicators during active breach visualization.

HASHD Terminal owns presentation, command-session state, and its endpoint defense/capability profile. It does not own mining authority, the farm ledger, purchase billing, or Rack hardware state.

The old blanket statement “Terminal upgrades: None” is superseded. See `CYBER_VISUAL_IDENTITY_DOCTRINE.md` and `DECISION-0010`. Purchases are made from LpHashdPanel (universal home), not on the CRT. Terminal never mines.

If Hub persistence serializes the Terminal profile, Hub acts only as infrastructure — no two independently mutable copies.

---

## Yield and capacity baselines (owner canon)

| Slot | Base yield | Default local buffer (before deposit) |
|------|------------|----------------------------------------|
| Standard GPU Rack | **1.0×** | **max($10,000 USD, 1 BTC)** |
| Advanced GPU Rack | **2.0×** | **max($20,000 USD, 2 BTC)** |

Upgrades may raise buffer caps — not rack **count**.

---

## Legacy drift (code today — Integrator migration)

| Topic | Code today | Target |
|-------|------------|--------|
| CPU clock / cores | `CpuUpgradeLevel` / `CoreUpgradeLevel` on **rack** entity | **Hub** controller upgrades |
| Advanced 2× | `YieldMultiplier` always `1f` | **2.0×** base on advanced slot |
| Capacity | Flat `0.15 BTC` all racks | USD+BTC dual cap per tier |
| Upgrade UI | Servers sub-view sells CPU on rack | Hub tab + GPU-focused Servers |

Track migration in `TECH_DEBT.md` when slices start — do not silent-drift.

---

## In-world explanation test (Law G1)

Every tier must pass:

> "I bought **[X]** so **[entity]** now **[plain verb]**."

Examples:

- ✅ "I bought **Clock Path II** so the **hub** dispatches work **faster**."
- ✅ "I bought **Rack Cooling III** so **GPU Rack 1** stays **stable** under OC."
- ❌ "I bought **CPU Cores** on the **rack** so the **hub** …" (wrong owner)

---

*v1.1 — 2026-06-25 — Architect Phase 2*

---

## Cross-lane reuse contract (Hacker, Banker, Government, …)

Bitcoin is the **reference**. Future jobs (Hacker "Server Rack HUB" + Hacker Terminal, etc.) will reuse the same structural contract:

- **Three-surface model**: Hub (controller) / Terminal (operator + defense) / Satellite workers (racks / miners / processors).
- **Universal Upgrades home**: Single purchase surface (`LpHashdPanel` style with surface chips + path buttons + 5-tier line detail). Not per-satellite shops.
- **Servers / status dashboard**: Pure read-only live status for the linked entities (power, link state, per-upgrade tier readouts 1/5, derived runtime stats like hashrate/balance when active). No buy buttons here.
- **Power/link cascade**: Hub power-off unlinks Terminal + all workers. Player must re-link in order. Status page reflects "unlinked / hub offline".
- **Upgrade taxonomy shape**: 5 paths × 5 tiers per surface is the working target. Paths map to real stats on the owning entity. Cosmetics are visual-only.
- **UI invariants** (s&box Razor):
  - `BuildHash()` must capture every flag that changes markup (open path, preview tier rev, surface, link/power state).
  - SCSS must pass `Validate-SboxRazorScss.ps1` (no dashed borders, no gradients, no `display:block/none`, class root on `<root>`).
- **Authority**: Host owns state via `[Sync(FromHost)]`. Purchases are host-validated RPCs from the panel. Client never mutates sync fields directly.
- **Reference first (Law 1)**: Before implementing a new job's HUB/Terminal upgrades or status page, state explicitly what it reuses from this Bitcoin contract.

**See also (do not re-derive in every lane):**
- `lifepunch/docs/handoff/ARCHITECT_BRIEF_BITCOIN_UPGRADE_SYSTEM_AND_SERVERS_STATUS_2026-06-27.md` (the full steer request + constraints)
- `DECISION-0010-Universal-Upgrades-Home.md`
- `BITCOIN_CONTROLLER_PATTERN.md`
- `LIFEPUNCH_HUB_PATTERN.md`
- `CYBER_REFERENCE_LAWS.md` (Law 1, Law 8)

When a new lane (e.g. hackerjob) is unblocked, clone the **contract shape** (universal home + status dashboard + 5×5 + cascade), not the Bitcoin numbers or exact track names. Populate `BITCOIN_REFERENCE_IMPLEMENTATION.md` on Law 10 sign-off so future lanes have a complete bible.

Track any temporary deviations in `TECH_DEBT.md` with a single, obvious swap point back to the reference.
