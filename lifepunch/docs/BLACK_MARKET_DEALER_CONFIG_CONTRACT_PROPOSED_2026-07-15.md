# Black Market Dealer three-tier config contract

Status: **PROPOSED — BM-S3 / Issue #148.** Every numeric value in this record is a
playtest candidate, not a ruled balance value. This is a docs/config contract only;
it adds no consumer and authorizes no economy flow.

Grounding: GitHub Issue #144 S0 economy contract · `ECONOMY_DOCTRINE.md` ·
`INSTITUTIONS_DOCTRINE.md` · `DXRP_PLATFORM_DOCTRINE.md` §21 ·
`handoff/LPBITCOIN_HYBRID_CONFIG_SPEC_V1.2_2026-07-12.md`.

Schema stub:
`schemas/black-market-dealer-config-contract.schema.json`.

## S0 contract mirrored

The Black Market Dealer is a BTC-accepting **margin business**, and black-market
margins are transfers, not faucets. This contract preserves the S0 flows:

- Stock acquisition is a DXRP wallet debit to the system: a sink.
- A sale moves value from buyer to dealer over the entry's wallet or BTC rail.
- Margin is included in that buyer debit and dealer credit. It is never credited
  separately, so margin cannot mint value.
- Shipment and heat-risk fees are explicit system sinks.
- Host code resolves prices; no future client may submit price, quantity, rail, or
  recipient identity.

No `$LP` field, price, multiplier, or fallback exists here. The S0 contract assigns
this lane to BTC/wallet rails only.

## Layer ownership

The 2026-07-12 T1 snapshot has no Black Market Dealer, stock, or heat-specific
native key. T1 therefore owns no field in this proposal. If DXRP later adds a native
knob, T1 wins and the duplicate lower-tier field must be removed.

| Surface | Authority | Activation | BM-S3 ownership |
|---|---|---|---|
| T1 server config | DXRP server | Next restart | None currently; check first before implementation |
| Portal MARKET | T2 gamemode market row | Save + Sync | Stock acquisition cost in wallet units |
| T2 content override | Per catalog/content entry | Save + Sync + restart | Payment rail and entry-specific base sale prices override T3 fallback |
| T3 shipped defaults | Addon config fallback | Revision + install/update + Sync + restart | Sale-price fallback, stock shape, cooldown, heat/risk shape |
| Store live settings | One atomic settings document | Valid reload/refresh | Margin and fee dials only; last-known-good on rejection |

Portal MARKET cost is not duplicated in T3 or Store. T3 never reads Store, and
Store never rewrites per-entry catalog shape.

## Tunable inventory

All defaults below are **PROPOSED**.

| Field / portal value | Proposed default | Unit / valid range | Proposed tier | Reason |
|---|---:|---|---|---|
| `marketItems[].cost` | 2500 | wallet units; integer `> 0` | Portal MARKET | F1 stock acquisition sink; listing must exist |
| `PaymentRail` | `btc` | `btc` or `wallet` | T3 → T2 override | Machines/unlocks default to BTC; cash-class equipment may override to wallet |
| `BaseSalePriceSats` | 500000 | sats; integer `> 0` | T3 → T2 override | Host-resolved BTC quote fallback |
| `BaseSalePriceWallet` | 3000 | wallet units; integer `> 0` | T3 → T2 override | Host-resolved wallet quote fallback |
| `StockCooldownSeconds` | 60 | seconds; integer `1..86400` | T3 → T2 override | Shipped stock timing shape; restart-gated |
| `MaxStockQuantity` | 10 | units; integer `1..100` | T3 → T2 override | Anti-mint quantity clamp |
| `HeatGainPerSale` | 8 | heat points; integer `0..100` | T3 → T2 override | Proposed risk shape; consequence mechanic remains unruled |
| `HeatDecayPerMinute` | 2 | heat points/minute; number `0..100` | T3 → T2 override | Proposed recovery shape |
| `MaxHeat` | 100 | heat points; integer `1..1000` | T3 → T2 override | Bounded heat state |
| `HighRiskHeatThreshold` | 70 | heat points; integer `1..999` | T3 → T2 override | Proposed fee threshold |
| `CriticalRiskHeatThreshold` | 90 | heat points; integer `2..1000` | T3 → T2 override | Must exceed high-risk threshold and not exceed max heat |
| `dealerMarginBps` | 1500 | basis points; integer `0..10000` | Store live dial | 15% proposed spread, transferred buyer → dealer |
| `shipmentFeeWallet` | 250 | wallet units; integer `>= 0` | Store live dial | F5 stock-delivery sink |
| `riskFeeBps` | 500 | basis points; integer `0..10000` | Store live dial | 5% proposed high-heat sink in the active sale rail |

For either sale rail:

```text
dealerTransfer = basePrice + ceil(basePrice * dealerMarginBps / 10000)
riskSink       = highRisk ? ceil(basePrice * riskFeeBps / 10000) : 0
buyerDebit     = dealerTransfer + riskSink
dealerCredit   = dealerTransfer
```

The margin remains net-zero because every margin unit credited to the dealer is
debited from the buyer. The risk fee is separately classified and audited as a
sink. Checked integer arithmetic is required; overflow rejects the quote.

## Validation and last-known-good contract

1. T3 and T2 candidates validate as whole objects. No clamping, per-field repair,
   or zero/default collapse.
2. Only the selected `PaymentRail` price is charged, but both fallback prices must
   remain positive so a portal rail change cannot silently make an item free.
3. `HighRiskHeatThreshold < CriticalRiskHeatThreshold <= MaxHeat`.
4. Store uses one proposed key,
   `lifepunch:blackmarket:config:settings`, with `schemaVersion` and monotonic
   `revision`.
5. Unknown fields, wrong types, malformed JSON, unsupported schema, stale
   revision, and same-revision/different-value collisions reject the whole Store
   document and retain last-known-good.
6. Store contains gameplay numbers only: no tokens, API keys, webhook URLs,
   player balances, inventory, transaction state, or other secrets/state.
7. A future consumer must apply one validated Store candidate atomically on the
   host, then broadcast and audit once. BM-S3 does not build that consumer.

## Explicit exclusions and open rulings

- **R6 fencing/stolen goods is excluded.** There are no buy-back prices,
  fence percentages, provenance fields, stolen-item multipliers, or fencing
  cooldowns. R6 remains open because such a flow would introduce a faucet and
  collide with the No-NPC Law.
- **All `$LP` keys are excluded.** No `$LP` rail, conversion, discount, or
  multiplier is reserved.
- Heat consequences remain open. The proposed heat fields define only a bounded
  config shape; they do not choose a police notification, minimap, smell, raid, or
  other detection mechanic.
- R2–R5 and R7–R8 remain outside BM-S3. This contract does not choose the job
  model, BTC source, grant path, catalog, publish ident, or Player Hub overlap.
- No interest, laundering, cash↔BTC conversion, drug-brick alternate sale point,
  persistence, ledger, purchase, or grant path is designed here.
- No registration files from BM-S1 / Issue #146 are touched.

## Implementation gate

This schema is intentionally non-operative. Before gameplay consumes it, BM-S4
must resolve the relevant open rulings and provide the atomic debit/credit/grant
contract. A portal value with no consumer must never be presented as active.
