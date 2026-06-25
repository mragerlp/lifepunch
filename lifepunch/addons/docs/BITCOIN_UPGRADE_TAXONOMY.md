# Bitcoin — upgrade taxonomy (canonical ownership)

> **Status:** Active  
> **Why does this exist?** Every upgrade must have one buyer surface and one authoritative owner.  
> **How:** Hub Upgrades tab vs Servers per-rack UI — preserve `LpHashdPanel` chrome.  
> **Status:** Design canon — implementation may still reflect legacy per-rack CPU upgrades until migration slice.  
> **Parent:** `BITCOIN_CONTROLLER_PATTERN.md` · `LIFEPUNCH_GAMEPLAY_LAWS.md` G1

---

## Hub upgrades (controller)

Purchased from **Hub → Hub Upgrades** tab (new — preserve existing hub chrome).

### Categories (canonical)

| Category | Includes (target) | Player-facing story |
|----------|-------------------|---------------------|
| **Intelligence** | Share handling, dispatch policy, yield multipliers | Hub "thinks faster" about work |
| **Controller** | Clock path, scheduler firmware, core threads | Hub dispatches work more efficiently |
| **Economy** | Wallet policy, security/encryption, automation QoL | Hub protects and manages value |

### Example tiers

| Tier name | Category | Gameplay effect (target) |
|-----------|----------|---------------------------|
| **Clock path** | Controller | Hash **speed** — farm effective hashrate |
| **Core count** | Controller / Intelligence | **Yield** — block reward handling |
| **Security / encryption** | Economy | PvP defense vs hacker lane |
| **Automation** (future) | Economy | Job queue polish — optional v1 |

**Not on hub:** GPU die counts, rack thermal paste, per-rack OC sliders.

---

## Rack upgrades (hardware / Servers tab)

Purchased per linked rack from **Hub → Servers** → rack card → upgrade (preserve 3-card layout).

### Categories (canonical)

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

**None.**

Terminal is operator interface only. If a feature feels like an "upgrade" on the CRT, it belongs on hub or rack — or it is a **command unlock**, not a purchase tier.

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
