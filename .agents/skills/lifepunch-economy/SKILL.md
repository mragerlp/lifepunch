---
name: lifepunch-economy
description: LIFEPUNCH economy law for any code or design that holds, moves, prices, mints, or destroys value. Use for wallets, cash-out, purchases, market items, payouts, ledgers, faucets, tier costs, balance mutations, or any "does this create/leak money" question. Enforces Law A/B, the Gauntlet's always-safe terminus, the PayoutTarget routing, the debit-before-await (TOCTOU) hazard and its debit-restore fix, the audit reason-string namespace, and the faucet-audit checklist. This skill points at canon; it does not restate it.
---

# LIFEPUNCH economy — the value-flow law

**This skill points at canon. Read the cited file before building or ruling.**

## 1. LAW A / LAW B — the two tests every economy touch faces

Canon: **`lifepunch/docs/UPGRADE_ECONOMY_DOCTRINE.md`** (Law A worked example `:26`) and
**`lifepunch/docs/ECONOMY_DOCTRINE.md`**. Apply both before writing:

- **Currency-of-the-act / purchase test** — an act pays in the currency of the act
  (`UPGRADE_ECONOMY_DOCTRINE.md:26`). Ask what currency the mechanic actually charges/pays and
  whether that matches design intent.
- **"Does it exist after I die?"** — the persistence-vs-Law-B test. Value that survives death
  is a different economic object than value that does not; run this test on any new persistent
  state (armor, upgrades, tablet holdings). See also `INSTITUTIONS_DOCTRINE.md`,
  `TABLET_DOCTRINE.md` open flags.

## 2. THE GAUNTLET — always-safe terminus

Global Balance is a portal-side network ledger — **the Gauntlet's always-safe terminus, by
construction** (`DXRP_PLATFORM_DOCTRINE.md` §7, `:133-149`). Map any new value edge onto the
Gauntlet: every mutation must reach a safe terminus and write portal evidence. LP economy
exits already write audit rows.

**Reason-string namespace law:** every LP economy mutation carries `"LIFEPUNCH <verb>"`
(`DXRP_PLATFORM_DOCTRINE.md:143`). The audit row is a second, portal-side sensor lane — use it.

## 3. PAYOUT ROUTING

`LpBitcoinHubEntity.PayoutTarget` decides where cashed-out BTC lands
(`UPGRADE_ECONOMY_DOCTRINE.md:79`). Cash-out/transfer code routes through it; do not
hardcode a destination.

## 4. THE TOCTOU HAZARD — debit before await

The canonical failure (record): **`lifepunch/docs/handoff/STOPGO_CASHOUT_TOCTOU_2026-07-09.md`**.
A check→**await**→mutate window lets a second call double-act across the yield
(`CashOutHubHost`, window `:1041→1051`); with no clamp on the balance, a double-debit drives
it negative.

**The safe shape (reference implementation):**
`lifepunchaddons/Code/Addons/lifepunch/bitcoinmining/LpBitcoinPurchaseFlow.cs`:
- Commit-order invariant `:40-43` — funds check → debit → ledger append+flush, **no awaits
  between debit and append**.
- Atomic money segment `:104-115` — debit, then on rejection `hub.HubWalletBtc = walletBefore`
  **restores the debit exactly** (additive restore, not a recomputed value).

Rule: **never `await` between the funds check and the debit.** If an await is unavoidable,
debit first and restore-on-failure additively.

## 5. FAUCET-AUDIT CHECKLIST

Before shipping any value source, verify: (a) it has a cap/clamp; (b) its reason-string is
`"LIFEPUNCH <verb>"`; (c) it survives the Law A / death test; (d) it appears in the Gauntlet
map with a safe terminus. Faucet signatures worth flagging live in the portal audit enum
(`DXRP_PLATFORM_DOCTRINE.md` §22 — e.g. a disconnect-decay `MoneySpawn` faucet).

## FLAG — the `marketItem?.Cost ?? 0` contract has NO repo home

Cited in planning as a contract, it is **defined nowhere in the tree** (no `MarketItem.Cost`
field, no `?? 0` cost-resolve in `lifepunchaddons/Code`). Do not cite it as code law. The real,
in-tree purchase contract is `LpBitcoinPurchaseFlow.cs:40-43`. If a market-cost null-default is
wanted, it is a design question, not an existing invariant.
