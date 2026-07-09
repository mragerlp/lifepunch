# LIFEPUNCH Drug Economy Lane

Status: FUTURE LANE — design captured 2026-07-08. NOT current work.
Blocks nothing; blocked by nothing. Assets exist (stashed); no code exists.
Current priority remains lpbitcoin (see `UPGRADE_ARC_DESIGN.md`).
Doctrine home: `ECONOMY_DOCTRINE.md` (labor lane; Drug Chemist charter).

## No-NPC Law (doctrine amendment, effective now)

No NPC vendors, ever — all selling routes through map-placed drops.
Drops are the labor lane's exposure point: hack-immune income still
carries transit/camp risk at fixed locations.

## Window Drop System

4 landmark locations; 2 open at any time (staggered). Example cadence:
animated train, 15 min open / 45 closed. Windows accept ALL drug bricks
(weed, cocaine, meth — value order); they are the ONLY drops accepting
cocaine/meth bricks. Regular weed drops continue unchanged.

Police alerted on high-tier window open (future event-bus citizen,
same family as OnPurchase/HackAttempt — see `LIFEPUNCH_ADDON_ARCHITECTURE.md`).

Design intent: converts the top-earner lane to PULSED income — throughput
capped by window time, inventory float between windows is the risk,
scheduled convergence replaces camping. Tuning knobs: window duration,
cadence, stagger offsets, per-window limits — before touching prices.

## Three Markets (requires custom price-config work)

- **Weed @ windows:** duplicated drop entity, price tracks the vanilla
  server drug-drop config IDENTICALLY (no arbitrage vs regular drops).
- **Cocaine:** new custom entity + independent fluctuating price config.
  Coke pipeline mirrors weed (different plants/bricks; assets ready).
- **Meth:** new custom entity + independent config, HIGHEST volatility and
  ceiling. Meth production is new and hardest. Volatility × pulsed
  windows = hold-or-sell gameplay; holding deepens physical exposure.

Limitation acknowledged: vanilla config covers weed only — coke/meth
pricing requires our own addon/server config layer. That layer is the
main build cost of this lane.

**Config template reference (vanilla weed, extracted Packet D 2026-07-08):**
drop price band 175–350 (`DrugDropMinPrice`/`DrugDropMaxPrice`), price change
cycle 1800s (`DrugDropPriceChangeCycle`), sell time 10s (`DrugDropSellTime`) —
the fluctuation shape the coke/meth configs mirror, with wider band / higher
ceiling per market (meth widest, per Three Markets above).

## Chemist Production Track (future, house pattern)

Drug Chemist gets 5-tier upgrade track(s) for cocaine/meth production
(unified vs per-drug split: undecided). Follows the house pattern — ledger
tenant, OnPurchase, cosmetic option (`ECONOMY_DOCTRINE.md` House Pattern).

DESIGN CONSTRAINT: value fits against WINDOW-GATED throughput, not
continuous rate — pure speed tiers saturate the sale window (the
buffer-overshoot analog). Candidate effect axes: cook speed (early
tiers), brick value/purity (monetizes via price config, scales with
volatility), batch/carry capacity (value per window trip).

Hack-immunity unchanged; higher tiers deepen physical float exposure
between windows by design. Numbers wait on the lane build + the
Packet D window-gated math.

## Deferred Decisions (settle when lane is scheduled)

- Stagger pattern vs synchronized openings (income density + server rhythm)
- Volatility model (bounded random walk vs supply-responsive)
- Per-window sale caps, if any
- Packet D note: meth/coke $/min uses WINDOW-GATED throughput math,
  never the continuous formula used for weed.
