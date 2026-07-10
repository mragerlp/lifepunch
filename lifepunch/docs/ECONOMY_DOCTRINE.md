# LIFEPUNCH Economy Doctrine

Status: CANON — ratified 2026-07-08. Systems must comply or amend this page first.
Companions (ratified 2026-07-09): `UPGRADE_ECONOMY_DOCTRINE.md` (what things
cost and why) · `INSTITUTIONS_DOCTRINE.md` (who owns what, who can take it).

## The Three Laws

1. **CAPITAL INCOME IS ATTACKABLE.** Passive earners hold exposed state:
   printer balances are stealable, racks leak BTC pre-hub, wallets are
   crackable pre-deposit, Bank and City Funds are hack targets.
2. **LABOR INCOME IS SAFE.** Drug entities are explicitly hack-immune.
   Drug Chemist is the top earner BECAUSE of labor. This is by design.
   No NPC vendors, ever — all selling routes through map-placed drops,
   the labor lane's exposure point (amendment 2026-07-08,
   `DRUG_ECONOMY_LANE.md`).
3. **DEFENSE IS THE CITIZEN'S PROBLEM.** FBI defends government assets
   (City Funds, Data Center, Bank premiums). Citizens and criminals
   protect themselves — primarily via HASHD Terminal security tiers.

## Risk-Stratified Income (why no single meta wins)

Passive capital pays well but bleeds under pressure. Active labor pays
best and is safe. Everything between prices its own risk. Mining's
premium over printing is compensation for exposure + attention, and
partially offsets its tax immunity.

## Tax Immunity & the Central Conflict

BTC escapes Mayor taxation (0–30%, Mayor-set; taxes drive market prices).
The government therefore BECOMES a miner: the Data Center passively
converts mined BTC to City Funds while a Mayor sits — if Hackers don't
take the balance first. FBI (limited slots, paid premiums from City
Funds for defending Funds/Bank; the rest is duty) defends; Hackers
(plentiful slots) attack. City Funds recycle into bounties and lotteries
— taxes are a loop the Mayor spends, not a pure sink. The Mayor is a job,
not a slider.

## Defense Economy

HASHD Terminal tiers I–V are hack resistance for the base's networked
entities. Hack resolution is a CONTEST (attacker gear tier vs defender
Terminal tier), never binary. Tier V defeats basic attacks. The person
is always exposed — carried cash is crackable, which forces movement
and banking. OPEN: whether printers count as "networked" under Terminal
coverage (analog money — may need its own answer).

**Pairing rule:** Hacker gear ladder and Terminal security ladder are ONE
design — never tune numbers for one in isolation.

**Track specs:** the Terminal renders **SIX track rows** — the five defense
tracks (Endpoint Firewall · Command Authentication · Intrusion Detection ·
Audit Retention · Monitoring Suite) plus **HASHD donor skins** (cosmetic, no
performance change), mirroring the Hub's five + Sound Pack. The five defense
tracks are specced in `UPGRADE_ECONOMY_DOCTRINE.md` (HASHD Terminal table),
fitted on losses-prevented and paired with the Hacker ladder per this rule; the
cosmetic sixth is a NOT-ENABLED true state until skins ship. (Terminal is a live
Entity Detail Contract tenant as of Slice 3.5 — its detail page is all-PLANNED.)

**Defender's status surface (2026-07-09):** the HASHD Terminal sidebar is the
defender's status surface — `SECURITY .... OK` (green) today, the BREACH
surface (red) when the Hacker lane ships; counter-commands live at that CRT,
and `terminal_security`'s tier renders there too (`TERMINAL_POLISH_BRIEF.md`
item 3).

## Role Charters (summary)

- **Banker (1 slot):** map-persistent Vault + Master BTC Miner. Yield is
  BACKED — paid pro-rata from actual vault production (miner output +
  fees), never minted on schedule. HUB upgrades raise real capacity.
  Full charter: `INSTITUTIONS_DOCTRINE.md` **The Fund, Not the Bank** —
  vaults are voluntarily at-risk capital (portal bank balance is always
  safe), vote-required office with Bank Guard slots, and the Banker's own
  props are the deductible (he bleeds first in any raid).
- **Hacker:** skims capital economy (wallets, printer balances, rack leak,
  Funds/Bank/black market/casino). Tuned as a tax, not a jackpot:
  % caps per hit, cost-to-attempt, leaves evidence for FBI gameplay.
- **FBI (≤2 slots):** defends government assets; premiums from City Funds.
  Stabilizer decision OPEN: base salary vs premiums-only (spiral risk:
  drained Funds → no premiums → empty slots → Funds stay drained).
- **Drug Chemist:** top earner, labor-gated, hack-immune. Meth new;
  coke mirrors weed pipeline. Wiremod automation is a supported style.
- **Black Market Dealer:** BTC-accepting margin business (Gun Dealer
  mirror, criminal/hacker toolchain). Post-base-systems.
- **Casino:** the economy's premier SINK — protect its seat; BTC-denominated
  house edge drains the fastest-growing wealth pool. Low priority now.

## House Pattern

Every upgradeable system follows the 5-tier track + cosmetic option.
One ledger serves all systems (trackId-scoped); OnPurchase is the
universal purchase event. `rack_compute` is tenant #1 and the reference
implementation; `terminal_security` is track #2.

## Visible-Status Law (amendment 2026-07-09)

Tier-visible status must remain UNFAKEABLE. Upgrade tracks are paid in
the currency their own operation generates (BTC-only for mining tiers),
so world-visible tier state (rack lights, the T5 hue) is **proof of
operation, never proof of wealth**. Future tracks inherit this: a
system's visible prestige is purchasable only with that system's own
earned output. Cash→BTC exchange, if ever built, is a Banker-toolkit
valve — governed conversion, never a second payment path in any
purchase flow.

Generalized across every entity (ratified 2026-07-09):
`UPGRADE_ECONOMY_DOCTRINE.md` **Visible-Status, Generalized** — every
installation's tiers are BTC-paid and BTC has no faucet, so a glowing rack,
a hardened terminal, or a fat vault each proves its owner ran the operation
(or traded with someone who did). Cosmetics are the sole exception.

## Role-Vacancy Law

State persists; INTERACTION gates on the role. Vault holds but pays no
yield without a Banker; Data Center idles without a Mayor. Vulnerability
while undefended is a feature — it pressures protective slots to fill.

## Appendix: Faucet/Sink Registry (maintain with every system)

- **FAUCETS:** rack mining · printers · Data Center (gov mining) · Bank Master
  Miner · drug drop sales (map-placed drops only — No-NPC Law,
  `DRUG_ECONOMY_LANE.md`) · FBI premiums (recycled, net-neutral if Funds-paid)
- **SINKS:** entity spawn costs · upgrade purchases (all tracks) · taxes (loop,
  Mayor-spent) · Hacker attempt costs · casino house edge (future)
- **TRANSFERS (net-zero):** gun/black-market margins · player drug sales ·
  hacks · bounties · lottery · bank yield (backed)
