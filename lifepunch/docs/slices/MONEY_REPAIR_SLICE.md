# MONEY-REPAIR SLICE — brief

> **Class: SLICE BRIEF (tracked 2026-07-12).** Pre-banked at the r3 close so the slice survives
> outside the comms lane. Sources: Green fresh-cites (`RECON_MONEY_REPAIR_SLICE_FRESH_CITES`,
> `RECON_PACKET_P2_VOTEBET_MINIGAME_MONEY_AUDIT`, both 2026-07-12, Cornerman outbox), Codex diffs
> (`comms\codex\0002`), rulings **E/F** (`comms\fable\0012`).
>
> **NOT STARTED.** No code in this slice has been written or verified by Red. Every cite below is
> inherited from Green/Codex and **must be re-verified against the live tree before any edit** —
> line numbers drift, and this arc has already produced one root-cause inversion from trusting
> numbers without eyes.

## Why this slice exists

**The economy is minting money on every restart.** The snapshot restore is **not crash-gated** — it
fires on **every boot**:

> **Sensor (Red, machine-verified):** `lifepunchdxrp/game/Code/System/Recovery/SnapshotSystem.cs`,
> `OnSecondlyUpdate` — `if ( _pendingSnapshot != null && Time.Now > 5f ) → LoadSnapshot( file )`.
> Condition = **snapshot-exists + 5 s elapsed**. **No crash gate.**

Combined with `MoneyEntity` snapshot duplication, that means **every restart mints**. Live config on
Official is `SnapshotEnabled: true`, interval **300 s** — so the mechanism is **armed in production
right now**. That is why (a) is top of the slice.

## Scope, in priority order

**(a) `MoneyEntity` snapshot duplication — ARMED LIVE. Top of slice.**
Every crash-restore (and, per the sensor above, every *boot*) mints. Must separately prove:
**capture**, **restore**, and **repeated restore** — a single restore passing is not proof, because
duplication compounds across restarts. Cite the clean exemplar
`../server-setup/snapshots/WORLD_SNAPSHOT_EMPTY_2026-07-12.json` (verified: zero `MoneyEntity`
occurrences).

**(b) VoteBet restart-burn.** Stakes are debited to the bank while the records live **in memory
only** — a restart burns the stakes with no ledger to restore from.

**(c) Rack-tier upgrade no-debit.** `HackerServerRackEntity.cs:417/420` (inherited cite —
**re-verify**): the tier upgrade applies without debiting. Free upgrades are a faucet.

**(d) `/spawnitem` missing upper quantity clamp.** No upper bound on quantity.

**(e) VoteBet oracle fix (ruling E/F).** **Manage-holders are barred from betting**, and the outcome
is taken from the **vote system**, not from the caller. A caller-supplied outcome on a bet the caller
can influence is an oracle the house does not control.

## The law this slice serves

`lifepunch-economy` skill + the economy canon it points at: **Law A/B**, the Gauntlet's always-safe
terminus, `PayoutTarget` routing, the **debit-before-await (TOCTOU)** hazard and its debit-restore
fix, and the audit reason-string namespace. **Every balance mutation carries an audit line.** A faucet
without an audit line is invisible, and an invisible faucet is unfixable.

## Red's verification gate (must pass before the slice ships)

1. **Re-verify every inherited cite** against the live tree. Green's eyes are covered; Codex's are
   static. Line numbers drift.
2. **Bench repro first, fix second.** Each of (a)–(e) needs a reproduction on the bench **before** a
   patch — the r3 arc proved that a fix built on an unreproduced premise can invert.
   *(And beware the bench itself: `lp_bitcoin_spawn_kit` was the photographic negative of the live
   spawn path until `lp_bitcoin_spawn_kit_market` was built. Assert the bench reproduces the LIVE
   path before trusting any economic observation from it.)*
3. **Repeated-restore proof for (a).** Capture → restore → restore again → assert no mint.
4. **Two identities** for any claim about two players (`PROOF_ENVIRONMENT_DOCTRINE`). Bots have no
   SteamID and never prove economic behaviour.
5. **Audit-line assertion** on every mutation the slice touches.

## Sequencing

Lands **after** the r3 merge and **after** the DXRP upstream re-pin (Green's divergence map proves
the re-pin is a clean fast-forward with **zero money-repair collision**, so the two slices sequence
independently and neither blocks the other).
