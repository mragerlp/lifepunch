# UPGRADE ARC — design-session inputs (2026-07-08)

Digest of the four Green (Cornerman) reports for the upgrade-reality design pass.
Extraction order fixed by Bloodwave: A2 → B → A1 → C.

**Sources (all `qwen/qwen3.6-35b-a3b`, live runs, ack log on Green):**
- A1 `task-20260708-111548-upgrade-ui-inventory-a1` (ack 12:08:01Z)
- A2 `task-20260708-111621-entity-economy-dependency-map-a2` (ack 12:33:44Z)
- B  `task-20260708-114612-economy-baseline-extraction-r2` (ack 12:36:57Z)
- C  `task-20260708-102946-job-assets-folder-manifest` (ack 12:04:29Z)

Superseded failures on the log (for the record): the combined A packet blew the 120k
prompt ceiling (152,473 chars); economy r1 was rejected on forbiddenScope `portal`.
Both reruns succeeded. **Ops flag:** A2's meta shows THREE big models resident on
LM Studio (35b-a3b + 27b + coder-32b) — violates the one-big-model law; runs
succeeded anyway, but the reboot gate ("one qwen line") was not met at run time.

Labels: `REPORT` = verbatim from a Green report · `DERIVED` = my arithmetic from
REPORT constants · `NOT COVERED` = the report is silent, needs Red-side proof.

---

## 1. From A2 — dependency map (purchase-flow ground truth)

**Is mining rate cleanly addressable per-rack? YES.** `REPORT` All rate factors
live on `LpBitcoinRackEntity`: `ClockGhz`, `CoreCount`, `YieldMultiplier`
(per-rack read of `LpBitcoinIdent.BaseRackYieldMultiplier`), with
`LpBitcoinEconomy.BaseSpeed` as the global constant. Tick payout =
`ClockGhz × BaseSpeed × CoreCount × YieldMultiplier`, computed per rack.
Effect application points are per-rack: `ApplyUpgradeCpu` / `ApplyUpgradeCores`
mutate `ClockGhz` / `CoreCount` directly.

**Which component holds the tier int? NONE today — that's the build.** `REPORT`
No `TrackTier` field exists anywhere for any of the 18 tracks. The only tier-like
ints are the legacy `CpuUpgradeLevel` / `CoreUpgradeLevel` on `LpBitcoinRackEntity`
(proxies for the Compute Profile track only). Every other track: partial or NO
backing data path (Pool Client, Cooling, Power Delivery, Efficiency Tuning, all
cosmetics = nothing). New per-track tier state must be created; per the locked
architecture it lives as rehydrated projection, with the SteamID ledger as truth.

**Cross-system dependency breaking single-hook? YES — dual RPC entry.** `REPORT`
`RequestUpgradeCpu` / `RequestUpgradeCores` exist on BOTH `LpBitcoinHubEntity`
AND `LpBitcoinRackEntity` — two entry points into the same purchase. Consequence:
the OnPurchase hook must be raised at the single apply/ledger-commit point, never
at RPC entry, or one path silently misses the ledger. A2 also flags the
coexistence risk: new track tiers vs legacy levels can desync (e.g. "Compute
Profile IV" with `CpuUpgradeLevel 0`) — the design pass must decide replace vs
alias for the legacy pair.

**[Sync]-only vs [Property] on the rack path: ALL [Sync]-only.** `REPORT`
(persistence finding, packet contextNotes echoed in report §Gaps 2/7): only
`[Property]`-decorated members survive the DXRP snapshot; all current rack-path
members — `LinkedHubId`, `IsMining`, `BitcoinAmount`, `ClockGhz`, `CoreCount`,
`CpuUpgradeLevel`, `CoreUpgradeLevel`, `MiningProgress` — are `[Sync]`-only and
reset on restart. Same for hub wallet/links/buffers. Confirms slice 1
(`[Property, ReadOnly]` alongside `[Sync]`) and the ledger-as-truth binding.
Also `REPORT`: no pricing constants exist for new tracks (only the two legacy
cost arrays), and no OnPurchase code exists yet anywhere.

## 2. From B — economy baseline

**e₀ (stock rack): 0.00813 BTC/min ≈ $40.7/min** `REPORT` (0.0122 BTC/tick,
90s payout tick, $5,000/BTC default). Time-to-capacity 18.44 min (0.15 BTC cap).
Advanced rack is currently IDENTICAL — no distinct yield scalar exists; the
Advanced multiplier is a design-pass invention (B open question #1).

**Progression-stage earn ladder (single rack, `DERIVED` from B constants):**
| Stage | BTC/min | $/min | Cumulative cost |
|---|---|---|---|
| Stock (2.44 GHz, 1 core) | 0.00813 | $40.7 | — |
| CPU maxed only (8.44 GHz, 1 core) | 0.0281 | $141 | $30k |
| Cores maxed only (2.44 GHz, 9 cores) | 0.0732 | $366 | $675k |
| **Maxed (8.44 GHz, 9 cores)** | **0.2532** | **$1,266** | **$705k** |

Steps: CPU +1.5 GHz/level × 4 ($2k/4k/8k/16k) · Cores +2/level × 4
($50k/100k/175k/350k). `REPORT`

**Top end:** 3 maxed racks = 0.7596 BTC/min ≈ 45.6 BTC/hr ≈ **$227.9k/hr**
(vs stock 3-rack 0.0244 BTC/min = $7.3k/hr). Full fleet cost $2.115M. `DERIVED`
**Curve red flag `DERIVED`:** a maxed rack's SINGLE tick (0.3798 BTC) overshoots
the whole 0.15 BTC buffer — capacity binds hard at high tier; top-end earn is
actually collection-cadence-gated, not rate-gated. Payout Buffer track and the
curve must be designed together. (B open questions also: rack-specific capacity?
hub wallet cap? Advanced base stats?)

## 3. From A1 — upgrade-UI inventory (stepper landing zone)

**`.server-detail-action-lead`:** `REPORT` a reserved EMPTY container in
`server-detail-action-row`, left of the "Upgrade this rack" primary button
(which calls `OpenUpgradesForRackSlot(slot)` → Upgrades tab → GPU Rack surface →
that slot's target). The slot is explicitly held for the inline stepper. Clean —
nothing to demolish there.

**Tier-card sub-page kill-list (replaced by the inline I→V stepper):** `REPORT`
- `_openPath` state + `OpenUpgradePath(string name)` entry
- `upgrade-tier-line` five-cell row (`base`/`planned` classes, BASE/PLANNED
  state text, "Planned — purchases not yet enabled" tooltips)
- `upgrades-not-enabled-banner` (lock icon + "PURCHASES NOT YET ENABLED")
- `DevOpenUpgradeTrack` dev preview (retarget or retire with the sub-page)
Keep: surface/rack-target navigation (`EnterUpgradeSurface`, `EnterRackTarget`,
`upgrade-home-grid`, `_rackTargetSelected`) — that's wayfinding, not tier cards.
18 tracks total (5 Hub + 5 Terminal + 5 Rack hardware + 3 cosmetic surfaces),
rack tracks per-target (Rack1/Rack2/Advanced).

**Existing modal/confirm pattern: NOT COVERED.** A1 reports no confirm/modal
idiom in `LpHashdPanel.razor`. Nearest in-house idiom is adminmenu's arg-form →
Confirm flow (different addon; copying it crosses no lane but does cross addon
style). Red-side grep of lpbitcoin panels needed before the stepper's confirm
dialog is designed — treat as a small open item, not a blocker.

## 4. From C — assets, one line

**Tier-driven rack-light states are expressible with manifested assets ONLY as
emissive tint/intensity modulation** — `gpu-rack-gpu.vmat` carries self-illum
(hub has the `fence-led` emissive precedent); there are no per-tier emissive
variant materials, so Fan RGB tiers beyond color/intensity (patterns, reactive
sync) need asset work. `REPORT`+`DERIVED`

---

**Standing open items for the design pass:** Advanced yield scalar + base stats ·
new-track pricing model (per-track tables vs formula) · legacy CPU/Core pair —
replace or alias into Compute Profile · buffer capacity vs top-tier tick overshoot ·
confirm-dialog idiom (Red grep) · flagship track choice (Bloodwave's call).
