# TABLET DOCTRINE (seed v1 — ratified 2026-07-12, Bloodwave)

STATUS: Design canon. Implementation queues behind the build ladder. No code in this arc.

## The Tablet

Not a gadget: the job-side BTC terminal + remote link to hub-based infrastructure, for jobs that must send/receive crypto without owning a mining setup.

## Base Tablet (market item)

- $2500 cash, DXRP market, purchasable anytime.
- Spawn-tablet jobs are BLACKLISTED from purchase (portal market job-blacklist surface — the ratified Law 2 mechanism, portal-authorable, no code gate needed).
- Base functions: purchase upgrades/components (printer upgrades, miner jailbreaks) · locked-transaction crypto exchange (two players meet, lock trade, crypto confirms tablet-to-tablet — mirrors cash exchange with zero swoop-theft window) · remote cash-out for mining-setup owners · attack notifications when tablet is open away from base.

## Spawn-tablet jobs ("<Job> Tablet" = base + job-specific management/upgrade functions)

Chemist (labor hub) · Hacker · Banker (transfer authority) · FBI · Casino Manager · Technician · Mayor · Medic · Hitman.

## Medic extension

Upgrades vanilla med station (improved in-house) + med kit tiers (easier revives, faster/stronger heals) + armor additions at high cost with PERSISTENCE across job switches. No armor station in vanilla (kevlar only) — hospital visits / medic teaming become real perks; medic demand driver.

## Printer Technician (new job, future)

Sells base tablets to non-spawn jobs; in-house printer addon — roleplay loop upgrading DXRP-native printers. Deliberately close to the DXRP engine.

## Weapons lane (boundary)

Gun Dealer = the gun job, larger selection later, NO tablet/hub. Vanilla stock 5 kept + native-feel mirrored models/sounds. Later: 2-3 exclusive Black Market Dealer weapons + weapon locker/attachment system; BMD sells gadgets, receives crypto like any tablet holder.

## Open flags for the implementation design pass

- Law A/B pass per tablet economy touch (faucet audit; $2500 cash vs Law B boundary; "exists after death" test).
- Locked-transaction lane + remote cash-out = new value-flow edges; Gauntlet mapping required.
- Persistence-across-jobs vs Law B test.
- Medic vs Black Market stim-war boundary (INSTITUTIONS_DOCTRINE).
- Cosmetic Firewall untouched.
- DXRP portal Store (dxrp.net/portal/store): persistent namespace:key JSON storage per server, discovered 2026-07-12 post-scan. Study lane owed before tablet persistence design — candidate backend for cross-job persistence (Medic upgrades) and locked-transaction state. UNSTUDIED — no design commitments against it until scanned.
