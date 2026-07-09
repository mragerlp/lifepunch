# UPGRADE_ECONOMY_DOCTRINE.md

Status: CANON — ratified 2026-07-09. Derived from the LIFEPUNCH economy
doctrine; governs what every upgrade in every system costs and why.
Companion: `INSTITUTIONS_DOCTRINE.md` (who owns what, and who can take it).

---

## LAW A — CURRENCY OF ACT

**Every act pays in the currency it produces.** Currency attaches to the act,
never to the job.

- You mined it → BTC.
- You cooked it and sold it at a drop → cash.
- You cracked a rack buffer or a hub wallet → BTC.
- You picked a pocket, robbed a pile, ran a shipment → cash.
- You banked it → bank balance (portal-persistent).

**BTC has no game-side faucet.** It is *mined*, *stolen*, or *bought from a
player*. Nothing in the world sells BTC for cash except the Banker's window
and whatever two players agree on in an alley. This single scarcity rule is
what makes mining a supply business rather than a solo idle loop.

A job may produce more than one currency (the Hacker does). This is not a
special case — it is Law A working correctly. Each of his acts pays in what
that act produced.

## LAW B — CURRENCY OF PURCHASE

**Entities and unlocks cost BTC. Equipment and weapons cost cash.**

The test is one question: *does the thing exist in the world after I die?*

| Costs BTC (persists, compounds, can be stolen) | Costs cash (spent, dies, expires) |
|---|---|
| Racks, hubs, terminals, vaults, labs | Guns, ammunition, armor |
| Tier upgrades on any installation | Consumables, bribes, licences |
| Black Market jailbreaks | Gadgets: pickpocket kit, cuffs, unarrest baton |
| The Advanced Hacker Terminal unlock | Shipments, seeds, precursors |
| Chemist purity tiers (pure coke/meth) | Chemist accelerators (faster cook/grow) |
| Hub firmware, Terminal defense tiers | Anything issued with a job |

**The nature of the thing decides. Never the job that holds it.**

A Hacker buying a cracking rig pays BTC (machine). The same Hacker buying a
burner or a bribe pays cash. A Chemist cooking faster buys accelerators with
cash (labor); a Chemist reaching purity pays BTC (mastery is a machine).

### The consequence: mastery costs exposure

Because top-tier capability is BTC-locked and BTC has no faucet, every job's
ceiling is gated on entering the wider economy. The Chemist who wants pure
product must mine (and thereby own exposed installations), steal, or trade
with a miner. **Nothing is walled off; everything worth having has a door,
and the door is other people.**

## THE GAUNTLET

Value is **exposed** from the moment it is produced until it reaches bank
balance. Every stage where value rests is a stage where value can be taken.

```
rack buffer ─▶ hub wallet ─▶ carried cash ─▶ BANK BALANCE (safe)
  skimmable      hackable       muggable         portal, persistent
```

Bank balance is the only true terminus. Everything upstream is at risk by
design. **Purchases that shorten the gauntlet are a legitimate upgrade
category** — the Hub's Share Pipeline (auto-deposit), buffer sizing, the
Terminal's defense tiers all buy the same product: *less time exposed*.

The pickpocket and the Hacker are the two ends of the same predation — one
takes physical value in transit, one takes digital. The bank is the only end
of the road.

## PAYOUTTARGET — one field, three institutions

`LpBitcoinHubEntity.PayoutTarget` decides where cashed-out BTC lands:

| Value | Destination | Institution |
|---|---|---|
| `PlayerBank` | owner's DXRP portal balance | every player rig (default) |
| `FundPile` | the Banker's investment pool, paid pro-rata to investors | Bank Master Miner |
| `CityFunds` | the public treasury, converted hourly at the Mayor's rate | Government Data Center |

The Data Center and the Bank's Master Miner are **configurations of the
mining system**, not new systems. The government's mined BTC has no personal
beneficiary — draining the Data Center robs the public, not the Mayor.

## THE THREE FITTING RULES

Different entities buy different *kinds* of value. Their prices are fitted
against different rules. **No non-rack track may directly multiply mining
rate** — racks own rate; everything else owns friction.

| Entity | What tiers buy | Fitting rule |
|---|---|---|
| **Rack** | rate | payback in earned BTC (T1 ≈ 30 min of the rack's own output) |
| **Hub** | retention, automation, farm scale | waste-reduction: value = BTC that would otherwise be lost or unclaimed |
| **Terminal** | protection, evidence, visibility | losses-prevented: value = expected theft avoided, tuned against the Hacker gear ladder |

Terminal numbers are **paired** with the Hacker's gear ladder and may never
be tuned in isolation (see ECONOMY_DOCTRINE, Defense Economy).

---

## THE FIFTEEN TRACKS — effect specs (PLANNED; hooks named, numbers deferred)

Three entities, three verbs: **racks make BTC faster · hubs make BTC keep
more of itself · terminals make BTC stay yours.** Rate, retention,
protection.

### GPU RACK — Hardware & Output (rate)

| Track | Effect axis | Status |
|---|---|---|
| **Compute Profile** | rate: `ClockGhz = base × 2^tier`, ×2/4/8/16/32 | **LIVE** (slices 1–3) |
| Cooling System | sustain: reduces thermal throttle / uptime penalty at high tiers | PLANNED |
| Power Delivery | efficiency: reduces the power draw that Cooling and Firmware must cover | PLANNED |
| Efficiency Tuning | yield-per-watt: raises effective output without touching the rate ladder | PLANNED |
| Payout Buffer | gauntlet: buffer capacity (currently derived `tick × 4`) | PLANNED |
| *Fan RGB* | cosmetic | NOT ENABLED |

### BITCOIN HUB — Controller & Farm Operations (retention)

| Track | Effect axis | Notes |
|---|---|---|
| **Job Scheduler** | waste: staggers rack ticks so no rack sits full while another sits empty; T5 drains buffers toward the hub as they approach cap | The benched "scheduler" flagship candidate lives here, correctly — it never touches rate |
| **Share Pipeline** | gauntlet: manual deposit (T1) → auto-deposit at buffer threshold → continuous streaming (T5) | Value denominated in **losses-prevented** once the Hacker ships; buffers are what he steals |
| **Pool Client** | variance: solo (T1) → smoother payouts; higher tiers may permit player-hosted pools with a host fee | Social hook; expected value unchanged, variance reduced |
| **Farm Firmware** | scale + QoL: per-rack power (T1) → mining-start-all → auto-restart after power loss; **gates how many racks a hub can address** | Farm size is a hub-tier property. This is the Hub's real scaling knob |
| **Trust Policy** | access: owner-only (T1) → named co-owners → party/faction whitelist → timed guest access. **Also governs who may pick up the hub** | The anti-grief layer for a carryable hub; counterpart to the Terminal PIN |
| *Sound Pack* | cosmetic | The stock power-on sound is T1. Ship the joke. |

### HASHD TERMINAL — Defense & Monitoring (protection)

The `terminal_security` family. **Designed together with the Hacker gear
ladder; never tuned alone.**

| Track | Effect axis | Notes |
|---|---|---|
| **Endpoint Firewall** | contest: attacker gear tier vs firewall tier → base success probability | What makes Cornerman-tier vs Vengeance-tier meaningful |
| **Command Authentication** | loot limit: a cracked terminal at T5 still cannot `cash out` or `unlink` without a second factor | Firewall stops the door; Auth limits the haul. Two defensive personalities |
| **Intrusion Detection** | evidence: silent loss (T1) → BREACH alert on the terminal → attacker traced to the log, and to the FBI if government | **This track is the FBI's gameplay.** Canon requires hacking to leave evidence |
| **Audit Retention** | history: volatile logs (T1, shipped — AlertFeed empties on restart by design) → permanent, tamper-evident | Survives the restart a hacker might trigger to cover tracks |
| **Monitoring Suite** | visibility: STATUS block (T1) → per-rack tenant lines → retro tier readout → remote alerts | **The Terminal's own UI is a purchasable upgrade.** Tiers literally unlock rows of the sidebar |
| *HASHD donor skins* | cosmetic | dialect re-skins per TERMINAL_IDENTITY_SYSTEM |

### The progression this creates

A mature operator's spend order tells a story: **rate first** (racks — they
pay back), **then retention** (the Hub, once rate is big enough that waste
hurts), **then protection** (the Terminal, once holdings are worth stealing).
Each entity becomes valuable *because the previous one succeeded*. The
Hacker's arrival retroactively makes the third leg mandatory.

Fifteen tracks, three chapters.

---

## THE ENTITY DETAIL CONTRACT (UI consequence)

Every upgradeable surface renders through one component; the entity supplies
its parts (`EntityDetailModel`: Title · IdentToken · Chips[] · Stats[] ·
Tracks[] · InvestedSats · CTA). Tracks without an effect binding render
grey + `PLANNED` — a true state, not a placeholder. **The page does not wait
for tracks; tracks arrive into the page.**

This is the landlord pattern (one ledger, `trackId`-scoped) reaching the
presentation layer. Hub, Terminal, Banker HUB, black-market and hacker
terminals, and the Chemist's tablet all inherit it free.

## VISIBLE-STATUS, GENERALIZED

The Visible-Status Law now reads across every entity: **world-visible tier
state is proof of operation, never proof of wealth**, because every
installation's tiers are paid in BTC and BTC has no faucet. A glowing rack,
a hardened terminal, a fat vault — each says its owner *ran the operation
that produced the coin*, or traded with someone who did.

Cosmetics are the sole exception: they claim no capability, so they may be
bought with anything, and they prove nothing.
