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
   coupling knob between mining and the wider economy).
   **Rate VALIDATED (rate leg) — Packet D comparables, 2026-07-08:** stock
   mining $40.7/min vs vanilla printer $25/min = 1.63×, inside the 1.5–2.5×
   target band; risk-ladder ordering preserved (attended weed ≤ $92.6/min >
   mining > printer). Capital leg pending the printer spawn-cost grep
   (cost constant lives in market/config files outside the D payload).
8. **`OnPurchase(Player, string trackId, int tier, float costBtc)`** raised at
   ledger-commit, never RPC entry (hub AND rack RPCs funnel to one path).
   Commit-then-raise: the event announces a fact.
9. **Ledger wins on rehydrate**; component tier state is the snapshot
   projection (`[Property, ReadOnly]` + `[Sync]`, per the Owner-proven combo).
   **Storage medium (governance addendum 2026-07-08):** the ledger's store is a
   host-local file (`FileSystem.Data`, flushed at commit) — the lean default.
   The network-storage lane is a NAMED alternative only, never a silent
   dependency; switching mediums is an explicit decision on this page.
   **Format (gate-1 corrected, 2026-07-08):** one JSON array document
   (`lifepunch-upgrade-ledger.json`), rewritten whole and flushed at every
   commit — NOT line-per-record JSONL (s&box `Json.Serialize` pretty-prints
   with no compact mode; gate-1's first true disk reload caught it). Load is
   scene-keyed: a read in one FileSystem context never serves another.
10. **stackRule: DEFERRED** — `rack_compute` is sole owner of the mining-rate
    hook. Default candidate when forced: multiplicative across tracks.
11. **Track #2 = `terminal_security`** (hack-resistance hook; fitting rule is
    losses-prevented, not payback). Scheduler benched behind it.

## Build order

`[Property]` pass + ledger spine → purchase flow (OnPurchase from first
commit) → effects → stepper (inline I–V, hover name·effect·price, confirm
"Upgrade X to Tier N? COST: $X | X BTC — YES/NO", kills tier-card
sub-pages, seats in `.server-detail-action-lead`).

**Gates:** 2 = Terminal polish (brief: `TERMINAL_POLISH_BRIEF.md`) · 3 = rack lights (pure code
per packet C: emissive tint/intensity; T5 = hue shift; patterned RGB =
future asset work). Both post-arc, Bloodwave's call.

**Open (non-blocking):** confirm-modal primitive (Red grep) · printer
spawn-cost grep (closes the comparables capital leg; rate leg validated
2026-07-08) · legacy Advanced rack gains the yield scalar in slice 1–2
(purchase flow reads it at quote time).

**Slice-2 test infrastructure (filed 2026-07-08):** Cornerman may join as an
authorized second player for multiplayer checks (per its canon test-client
exception) — use for slice-2's multi-operator purchase/permission cases
(non-owner buy rejection, concurrent purchase race, cross-operator ledger
isolation).

**Slice-3 design notes (filed 2026-07-09, no build yet):**
- **Animation pipeline PROOF (pre-slice-3 side quest):** one asset, one
  authored animation — hub power-on — pulled Blender→FBX→ModelDoc→playable.
  The historical blocker was IDE tooling, now replaced (Blender MCP on the
  Fable seat, kamishell bridge, chomnr ModelDoc lane). Prove the pipe once
  before slice 3 leans on it; the needed assets already carry their animations.
- **Audio doctrine:** interaction sounds are SUBTLE — low intensity, easy on
  ears (one-liner also owed to LIFEPUNCH_UI_STANDARD next docs pass).
  Restorations owed: PIN click + terminal typing sounds (both existed, both
  regressed — find the break). Replacement owed: hub power-on sound (too loud,
  replace not adjust). SFX set is a small remake: clicks, ticks, power states,
  purchase confirm. Skafinity is music only — never SFX.
- **Gate-3 reframe (stands as filed):** tier lights = world-visible purchase
  confirmation, OnPurchase subscriber #1, T5 hue shift, optional purchase
  flare + sound tick. Lights carry the Visible-Status Law
  (`ECONOMY_DOCTRINE.md` amendment 2026-07-09): tier state is proof of
  operation, never proof of wealth — unfakeable because mining tiers are
  BTC-only purchases.
- **Purchase result envelope (landed in slice 2, feedback amendment):** the
  flow returns {newTier, newClockGhz, costPaidSats, newBufferCap} on success /
  typed reasons (InsufficientFunds{shortfallSats}, PreconditionTier, HubGuard)
  on failure — the socket the slice-3 stepper plugs into.

**Slice-3.5 (queued, opens on the slice-3 merge — sequencing ruling option a):**
- Scope per the amendment relay: rack-detail reverts to stat rows (restyled,
  grey slab → standard dark plate) · Upgrades rows get centered stepper +
  UPGRADE/MAX TIER buttons · the track card section becomes the purchase
  surface (solo-I / pair / solo-MAX states per Bloodwave's sketches) · chip
  re-anchors to the card's Purchase button · Law 9 amended in the same slice.
  The built MAX card is the acceptance standard — the move re-homes it, never
  rebuilds it.
- **Tooltip preservation (ruling 2026-07-09):** the per-bubble hover tooltip
  ("COMPUTE V · ×32 rate · owned" — state-adaptive third clause: owned /
  ₿ price on frontier / requires Tier N beyond) is KEPT permanently and MUST
  survive the re-home — it rides the circuit stepper in every location it
  renders. Gate-3.5 case: hover any bubble in every stepper location →
  correct state-adaptive tooltip. (UI standard law 12 filed same day.)
- **Power-gated hub portability (R2 amendment 2026-07-09, supersedes the
  pack-up verb):** hub powered ON = anchored (machine law holds,
  hands_interact stripped) · powered OFF = carryable, **CLAIM SURVIVES** the
  move (PIN/owner/wallet ride — relocating, not abandoning) · racks HOLD
  their slot bindings while the hub travels; the membership sweep reconciles
  on re-place + power-on. The anchored-grab Notify ("HUB is anchored — power
  off to move it.") shipped in slice 3; the gate itself builds here. Gate-3.5
  case: power off → carry → re-place → power on → racks intact per bindings.
- **Terminal collision triage (queued 2026-07-09):** the HASHD terminal's world
  collision feels oversized — players clip space the model doesn't occupy. Two
  suspects: bounding-box hull (ModelDoc pass) vs the machine law's
  static-collider treatment (`LifePunchPropPhysics.SyncBoxColliderFromModel` —
  same law as the hub). Verdict + fix-class to the owner; rides 3.5 or later.
- Gate-3.5 case list rides the 3.5 proposal per house rule.
