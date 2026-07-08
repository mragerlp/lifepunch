# lpbitcoin Upgrade Arc — Locked Design (2026-07-08)

Status: LOCKED — ratified 2026-07-08 by Bloodwave. **Pricing figures are internal
design (non-shippable)** — they never appear in published addon material.
Inputs: Green packets A1/A2/B/C · `handoff/UPGRADE_ARC_DESIGN_INPUTS_2026-07-08.md`
(session artifact, untracked). Doctrine home: `ECONOMY_DOCTRINE.md` (House Pattern).

## Decisions (all confirmed by Bloodwave)

1. **Flagship = unified COMPUTE track (`rack_compute`)**, tiers I–V, replaces
   legacy `CpuUpgradeLevel`/`CoreUpgradeLevel`. No migration debt — legacy
   state was `[Sync]`-only and never survived restart.
2. **Effect vector: rate ×2/4/8/16/32** (T0 = ×1). Absolute apply:
   `Apply(tier)` sets `ClockGhz` + `CoreCount` from tier alone.
3. **Buffer Option A: `BufferCap = tickYield × K`, K=4** (~6 min headroom,
   all tiers). Canon addendum: derived world properties may scale with
   tier; only the hook is purchased.
4. **Base price ladder: 0.25 / 0.75 / 2 / 6 / 16 BTC** (payback-anchored
   P=[30,45,65,90,120] min vs e₀=0.00813 BTC/min, snapped clean).
5. **Advanced rule: `cost(tier) = baseLadder × YieldMultiplier`.**
   Advanced YieldMultiplier = 2.0, priced at parity → identical payback,
   double throughput per slot for double capital. Standard = 1.0.
6. **Flat per-rack pricing** (fleets pay per rack).
7. **Ledger money is integer: `long costSats`** in the record; BTC display +
   `float costBtc` in the OnPurchase payload only. Purchases charge BTC;
   $ display is decorative (rate: $5,000/BTC launch, FIXED; it is the
   coupling knob between mining and the wider economy — pending the
   printer/weed comparables grep).
8. **`OnPurchase(Player, string trackId, int tier, float costBtc)`** raised at
   ledger-commit, never RPC entry (hub AND rack RPCs funnel to one path).
   Commit-then-raise: the event announces a fact.
9. **Ledger wins on rehydrate**; component tier state is the snapshot
   projection (`[Property, ReadOnly]` + `[Sync]`, per the Owner-proven combo).
   **Storage medium (governance addendum 2026-07-08):** the ledger's store is a
   host-local file (`FileSystem.Data`, flushed at commit) — the lean default.
   The network-storage lane is a NAMED alternative only, never a silent
   dependency; switching mediums is an explicit decision on this page.
10. **stackRule: DEFERRED** — `rack_compute` is sole owner of the mining-rate
    hook. Default candidate when forced: multiplicative across tracks.
11. **Track #2 = `terminal_security`** (hack-resistance hook; fitting rule is
    losses-prevented, not payback). Scheduler benched behind it.

## Build order

`[Property]` pass + ledger spine → purchase flow (OnPurchase from first
commit) → effects → stepper (inline I–V, hover name·effect·price, confirm
"Upgrade X to Tier N? COST: $X | X BTC — YES/NO", kills tier-card
sub-pages, seats in `.server-detail-action-lead`).

**Gates:** 2 = Terminal polish (brief drafted) · 3 = rack lights (pure code
per packet C: emissive tint/intensity; T5 = hue shift; patterned RGB =
future asset work). Both post-arc, Bloodwave's call.

**Open (non-blocking):** confirm-modal primitive (Red grep) · printer/weed
comparables (validates $5k rate) · legacy Advanced rack gains the yield
scalar in slice 1–2 (purchase flow reads it at quote time).
