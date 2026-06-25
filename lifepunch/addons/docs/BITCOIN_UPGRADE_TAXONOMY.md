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

- **Defense progression** lives here (firewall tiers, intrusion alerts, encryption policy, command auth, log retention, etc.).
- **Appearance** on the Bitcoin Terminal must stay within HASHD-safe donor cosmetics only (amber/gold/warm white/bronze/dark graphite + controlled accents). Full Cornerman green, VENGEANCE red, or lifepunchnet cyan-blue is prohibited on Bitcoin surfaces.
- Transient hostile lane colors (green/red/cyan) may appear only as attack-state indicators during active breach visualization.

The old blanket statement “Terminal upgrades: None” is superseded for Bitcoin Step 1 planning. See the doctrine for exact constraints on the upcoming Universal Upgrades tab.

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
