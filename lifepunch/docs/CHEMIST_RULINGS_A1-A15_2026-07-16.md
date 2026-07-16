# CHEMIST RULINGS — A1–A15 (RULED) — 2026-07-16

> **Canon home:** `lifepunch/docs/CHEMIST_RULINGS_A1-A15_2026-07-16.md`. This record **graduates** the
> A1–A15 chemist ruling set out of the comms lane and into the tree (Canon Persistence Law — the
> substance previously lived only in a dispatch; Green X2 flag 2). **Source:** the A1–A15 slate in
> Fable's ruling consolidation (`fable\0096`) **ruled under Bloodwave's delegation** ("take the
> recommended steps") in `fable\0102` — *"A1–A15 CHEMIST: all per `fable\0096` recs — YES/confirm across
> the board,"* with the three explicit amendments called out below. Reconciled against
> `COCAINE_PROCESSING_DOCTRINE.md`, `DRUG_PROCESSING_HUB_DOCTRINE_2026-07-15.md`, and the
> `DESIGN_LAWS.md` (PHYSICAL-PAYOUT LAW). Unblocks chemist issues #121–#126.

## The rulings

| # | Question (fable\0096) | RULED |
|---|---|---|
| A1 | Job label: Drug Dealer (player-facing) + Chemist Operations (system)? | **YES** |
| A2 | Mark: violet flask (Bloodwave's eye), flask + violet accent? | **YES** — flask + violet accent |
| A3 | Package ident = `advanceddrugprocessing`? | **YES — CRITICAL, FINAL.** Burned-ident precedent; gates the first file. The addon already exists (meth-focused, flat); cocaine S1 adds *into* it. |
| A4 | Player Hub supersedes tablet/BM purchase prose? | **YES** |
| A5 | U1/U2 persistence: permanent tiers? | **YES — PERMANENT tiers.** This one ruling also closes **Storage #168-R5** and **VisiblePocket #169-R4** (one rails answer, three locks). |
| A6 | Payout terminus: direct bank cash? | **YES — cash (no BTC faucet)**, *under the PHYSICAL-PAYOUT LAW*: the payout terminus is a **physical drop entity**, not a menu; cash lands in bank **on delivery**. See reconciliation note below. |
| A7 | V1 routes: existing train/truck only? | **YES** — existing `lpdrugdrops` train/truck drop surfaces are the sale points. |
| A8 | Prices: T3 defaults + Store live band, no numbers until playtest? | **YES** |
| A9 | Config admin: reuse lpbitcoin permission? | **YES** |
| A10 | U3 conditionally ratify / U4 hold / U5 exclude v1? | **YES / YES / YES** — U3 conditionally ratified, U4 held, U5 excluded from v1. Updates the cocaine doctrine §2 (where U3–U5 were PROPOSED). |
| A11 | (U4 hold) | **HOLD** (see A10). |
| A12 | (U5 exclude v1) | **EXCLUDE v1** (see A10). |
| A13 | Terminal: Layer 1 only for v1? | **YES** — Layer-2+ terminal deferred. |
| A14 | Growth: 1.25× in native resource? | **YES** — cocaine plants take 25% longer than weed; the multiplier lives in DXRP-native config (config-layer check T1→T2→T3 before any fork edit). |
| A15 | Oven semantics: shared entity, one batch, each lane's bricks from each lane's inputs — NOT a combined hybrid? | **CONFIRM as stated — shared entity, one batch, per-lane bricks, NO hybrid product.** (`DRUG_PROCESSING_HUB_DOCTRINE_2026-07-15.md`.) |

## Reconciliation notes (binding on the build)

- **A6 × PHYSICAL-PAYOUT LAW.** A6 fixes the *currency* (cash, no BTC faucet — Law A of the economy
  boundary). The *mechanism* is governed by the universal **PHYSICAL-PAYOUT LAW** (`DESIGN_LAWS.md` §2):
  bricks are pocketed, physically carried, and delivered to a drop entity — payment fires **at delivery**,
  and there is **no payout UI surface** in the lane. The cocaine doctrine already ships this shape
  (`COCAINE_PROCESSING_DOCTRINE.md` §1 Stage 3: bricks "sold at a DROP LOCATION"). **The money wiring
  stays gated** behind the lpbitcoin ledger-discipline pass (`COCAINE_PROCESSING_DOCTRINE.md` §3): the
  drug lane as shipped upstream is a net faucet that launders, so cocaine *content* may ship fast but its
  *sale/payout hookup* adopts the ratified audit-sensor pattern (`LP_*_SENSOR` at minimum; no silent
  issuance).
- **A5 tiers × persistence rails.** Permanent tiers align with the cocaine doctrine's U1/U2 (ratified
  upgrades). The persistence rail is the same one that answers Storage #168-R5 and VisiblePocket #169-R4.
- **A10 updates the doctrine.** `COCAINE_PROCESSING_DOCTRINE.md` §2 lists U3–U5 as PROPOSED; per A10 they
  are now **U3 conditionally ratified · U4 held · U5 excluded from v1.** U5 (yield refinement) remains the
  faucet-warning path and ships last, only after the ledger pass proves the audit rail.
- **DO-NOT-BUILD (v1).** U4 held; U5 excluded; Layer-2+ terminal deferred (A13); no hybrid oven product
  (A15); no payout UI (PHYSICAL-PAYOUT LAW).

*Ruled by Bloodwave under delegation (`fable\0102`), recorded by Fable; landed in-tree by Red under the
Canon Persistence Law. `CLAUDE.md` is the canon of record; on any conflict it wins.*
