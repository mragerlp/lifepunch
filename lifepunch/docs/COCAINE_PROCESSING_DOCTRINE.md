# COCAINE PROCESSING DOCTRINE — v1
Canon home when landed: lifepunch/docs/COCAINE_PROCESSING_DOCTRINE.md
Source: Bloodwave design sketch (whiteboard image), 2026-07-13, transcribed
verbatim-in-substance by Fable #4; PROPOSED sections marked and awaiting
Bloodwave ratification. Lands in-tree via Red at the next docs-carrying PR
(Canon Persistence Law).

> **A1–A15 RULED (2026-07-16) — see `lifepunch/docs/CHEMIST_RULINGS_A1-A15_2026-07-16.md`.** That record
> graduates the full chemist ruling set and carries three things that bind this doc: **A3** package ident
> `advanceddrugprocessing` (final); **A10** — **U3 conditionally ratified · U4 held · U5 excluded from
> v1** (updates §2 below, where U3–U5 were PROPOSED); and **A6 under the PHYSICAL-PAYOUT LAW**
> (`DESIGN_LAWS.md`): payout fires at a **physical drop entity** on delivery, **no payout UI surface** in
> the lane (the money wiring stays gated behind the lpbitcoin ledger pass, §3). Read that record before
> building.

## 1. THE CHAIN (ratified — Bloodwave's sketch)

COCO SEED -> COCO LEAF -> COCAINE BRICK

STAGE 1 — COCO SEED. Uses the DXRP NATIVE pot + soil + water grow
loop: plant a coco seed in a native pot, water it. No new grow
system is built — cocaine is a model/config swap on the existing
weed grow process (ratified in the addon build ladder).
GROWTH TIME: cocaine plants take 25% LONGER than weed. The
multiplier is expected to live within dxrp native config/code —
CONFIG LAYER CHECK REQUIRED (T1 -> T2 -> T3) before any code is
written; if native config exposes the grow duration, no fork edit
is needed.

STAGE 2 — COCO LEAF. Harvested when the plant matures. Leaves
CANNOT BE POCKETED — deliberate friction: the leaf is a
grab-and-carry world entity that must be physically placed into a
DRUG LAB. This creates the exposed-transport risk window (same
design grammar as rack->hub cash carry in the Gauntlet).

STAGE 3 — DRUG LAB PROCESSING. Base spec:
  - Capacity: 3 coco leaves loaded at once
  - Rate: 120 seconds per leaf, sequential
  - Output: 1 Cocaine Brick per leaf on completion
Bricks are DISPENSED from the Drug Lab, ARE pocketable, and are
sold at a DROP LOCATION (existing lpdrugdrops train/truck drop
surfaces are the natural sale points).

## 2. TABLET UPGRADE PATHS (2 ratified, 3 PROPOSED)

The Drug Lab is a tablet-upgradeable entity. Five upgrade paths
total. No cosmetic-upgrade lane exists for Drug Dealer entities
and none is planned (ratified — Bloodwave's sketch).

RATIFIED:
  U1 PROCESSING SPEED — reduces the 120s/leaf rate.
  U2 LEAF CAPACITY — raises the 3-leaf simultaneous load cap.

PROPOSED (Fable, mirroring the Monnow printer ~48-key schema
grammar: intervals/storage/silencer/cooling — awaiting Bloodwave
ratification, individually strikeable):
  U3 OUTPUT BUFFER — finished bricks accumulate inside the lab up
     to a buffer cap instead of requiring immediate dispense;
     reduces babysitting, raises the raid-loss stake (risk/reward
     symmetry with the rack buffer).
  U4 HEAT SUPPRESSION — reduces the lab's detection surface
     (smell/alert radius, minimap ping, or police-notify chance —
     whichever detection mechanic the lane ships). The "silencer"
     analog.
  U5 YIELD REFINEMENT — chance of a bonus brick per batch OR a
     higher-value refined brick tier. FAUCET WARNING: this path
     directly scales the money faucet and must be priced/tuned
     against the laundering-boundary math below; ships LAST of the
     five and only after the lpbitcoin ledger pass proves the
     audit rail.

## 3. ECONOMY BOUNDARY (standing canon, restated for this doc)

Law A (Currency of Act): drug sales pay CASH. No BTC faucet here.
The drug lane as shipped upstream is a NET FAUCET THAT LAUNDERS
(costs leave the on-ledger bank; revenue arrives in the off-ledger
wallet; portal sees a single "ATM Deposit" verb) — Packet N
finding, standing. THEREFORE: cocaine CONTENT may ship fast
(assets + entities + processing loop), but its MONEY WIRING is
gated behind the lpbitcoin ledger-discipline pass. The Drug Lab's
sale/payout hookup adopts whatever audit-sensor pattern that pass
ratifies (LP_*_SENSOR convention at minimum; issuance must not be
silent — J4-F3 lesson).
Upgrade purchases follow Law B pricing (persistent entity
upgrades) — the exact currency rail (cash vs BTC) for Drug Lab
tablet upgrades is an OPEN RULING, deliberately not decided here;
it inherits the resolution of the hacker-rack BTC-rail design.

## 4. CONFIG SHAPE (inherits the shipped lpbitcoin hybrid pattern)

Tunables ship as T3 defaults + portal-Store live knobs, per the
proven two-layer pattern (#70): atomic Store key
"lifepunch:chemist:config:settings" (exact <addon>:config:settings
shape), read RAW via GetStore (never GetStoreJson — silent
default(T) swallow, Packet O FLAG 3), per-field positive
validation, legacy fallback. Candidate keys: GrowTimeMultiplier
(1.25 base), ProcessSecondsPerLeaf (120), LeafCapacity (3),
BufferCap (U3), HeatFactor (U4), YieldBonus (U5), upgrade tier
costs.

## 5. OPEN ITEMS

  - Upgrade currency rail ruling (§3).
  - U3-U5 ratification (individually).
  - Detection mechanic selection for U4 (depends on what the lane
    ships for police interaction).
  - Config-layer check for the native grow-duration knob (§1).
  - Drop-location sale pricing pass (cash values) at playtest.

FROM: Fable #4 (doctrine draft author) — Bloodwave ratifies; Red lands verbatim.
