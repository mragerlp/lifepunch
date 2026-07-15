# LIFEPUNCH Banker — three-tier config contract

> **Status: PROPOSED · BANKER-S3 · Issue #140.** Every number below is a
> placeholder pending Bloodwave economy rulings. This document defines config
> shape only; it does not authorize gameplay or economy implementation.

## Tier rules

- **T1 — server engine config:** per-server values; active after the next server
  restart.
- **T2 — gamemode config:** job rows and per-entry overrides; active after Save
  + Sync Servers.
- **T3 — addon shipped defaults:** inherited by an installing gamemode until a
  T2 override replaces them.
- T2 overrides use the same four field names as the T3 addon defaults. The
  schema groups them by tier only to document ownership and activation.

## S0 tunable map

| S0 flow / tunable | Config field | Proposed default | Proposed tier | Activation and reason |
|---|---|---:|---|---|
| Transfer facilitation fee | `transferFacilitationFeePercent` | **2% PROPOSED** | **T3 default; T2 override** | Save + Sync Servers. Shipped Banker balance shape with a server-specific override. Whether the fee is a sink or Banker income remains an open economy ruling; this value does not decide it. |
| Minimum deposit per transaction | `minDepositAmount` | **100 cash PROPOSED** | **T3 default; T2 override** | Save + Sync Servers. Host-side lower transaction bound. |
| Maximum deposit per transaction | `maxDepositAmount` | **100,000 cash PROPOSED** | **T3 default; T2 override** | Save + Sync Servers. Required upper transaction clamp. |
| Vault balance cap per player | `vaultBalanceCapPerPlayer` | **1,000,000 cash PROPOSED** | **T3 default; T2 override** | Save + Sync Servers. Per-player storage ceiling. |
| Deposit / withdrawal cooldown | existing T1 `MoneyCooldown` | **2 seconds PROPOSED** | **T1 server** | Next restart. Reuses the captured DXRP money cooldown instead of creating a Banker-only cooldown key. |
| Daily transfer volume cap | `dailyTransferVolumeCap` | **500,000 cash PROPOSED** | **T2 gamemode** | Save + Sync Servers. Server-economy-scale anti-laundering ceiling. |
| Banker salary | existing T2 `jobs[].salary` | **32 cash PROPOSED** | **T2 gamemode job row** | Save + Sync Servers. Uses the stock salary faucet; no addon salary path. Issue #138 owns the actual job-row proposal. |

The companion schema stub is
`banker-three-tier-config.schema.json`. It is a documentation contract, not a
runtime payload or proof that the portal currently reads new Banker fields.

## Explicit exclusions

- **No interest or yield keys.** Ruling R3 on parent Issue #137 remains open.
  No rate, interval, accrual cap, or yield tier is reserved in either the
  document or schema.
- **No tier-cost keys.** The S0 economy contract names no tier purchase or tier
  cost. Adding a cost ladder here would invent a flow outside the work order.
- No withdrawal amount bounds, Guard salary, raid tunables, currency selector,
  fee destination, or persistence settings: S0 does not name them.
- No secrets belong in T2 or T3 config.

## Cross-slice ownership

- BANKER-S3 owns only this config contract and its schema stub.
- Issue #138 owns `addons.json`, package/job registration, the T2 Banker and
  Bank Guard job-row proposal, and naming reconciliation. This slice does not
  edit those surfaces.
- Issue #141 owns economy implementation and atomicity. These proposed defaults
  do not unlock that gated slice.
