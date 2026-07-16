# LIFEPUNCH™ Black Market Dealer — S1 registration proposal

Status: PROPOSAL ONLY — GitHub issue #146 (BM-S1), 2026-07-15.

Decision owner: Bloodwave. This document does not resolve open rulings R2 or R7.

## Scope and fences

This package proposes:

1. an R7 package-identity resolution;
2. a T2 Black Market Dealer job row and both R2 market-access variants;
3. the future `packages.json` and `addons.json` registration shapes; and
4. a money-disabled, server-authoritative job-gate contract for later stubs.

It introduces no runtime source, portal mutation, economy path, Razor/SCSS, or
fencing/stolen-goods design. Prices, BTC debit, grants, stock, transfers,
wallets, ledgers, and payouts remain outside BM-S1.

## Consumed canon

- `INSTITUTIONS_DOCTRINE.md`: the Black Market Dealer is the capability
  keystone selling heist machinery and unlocks.
- `ECONOMY_DOCTRINE.md`: black-market margins are net-zero transfers, never a
  faucet; BM-S1 therefore creates no balance reads or writes.
- `TABLET_DOCTRINE.md`: player-facing commerce has moved to the Player Hub.
  This proposal does not create a dealer tablet or a new commerce UI.
- `PACKAGE_NAMING_STANDARD.md`: public package slug, package folder, s&box
  identifier, and transitional repo ident are separate fields.
- `GAMEMODE_CONFIG_T2_2026-07-12.json`: the Gun Dealer job and its shipment
  rows are the structural T2 exemplars.

## R7 — identity recommendation

### Observed state

`package-staging.json` currently records:

```text
packageFolder:      lpblackmarket
packageSlug:        TBD
repoIdent:          blackmarketdealer
publishAssetsMount: addons/lifepunch/blackmarketdealer
```

The naming standard assigns a different purpose to each value:

| Field | Proposed value | Reason |
|---|---|---|
| `packageSlug` | `lifepunchblackmarket` | Required public `lifepunch{product}` form |
| `packageFolder` | `lpblackmarket` | Required `lp{product}` package-parent form |
| `sboxIdentifier` | `lifepunch.blackmarket` | Derived from the package slug |
| `repoIdent` | `blackmarketdealer` | Existing transitional monorepo/mount identity |
| `dxrpAddonIdentifier` | `lifepunchblackmarket` | Proposed portal identity; only after portal creation |

### Recommendation — not a ruling

Recommend `lpblackmarket` over `blackmarketdealer` for the package folder, but
do not use either value as the public package slug. The standards-compliant
public identity is `lifepunchblackmarket`, with s&box identifier
`lifepunch.blackmarket`.

`blackmarketdealer` should remain only as the legacy `repoIdent` and existing
publish-assets mount until a separately approved path-migration slice performs
the required `git mv` work. This avoids adding new source under a legacy ident
while also avoiding an unapproved asset-path migration in BM-S1.

Bloodwave R7 must confirm this field map before either manifest is changed.

## T2 common job-row proposal

Both R2 variants use the same job row. The UUID is allocated by the portal and
then replaces every `<BLACK_MARKET_DEALER_JOB_ID>` token in this document.

The row mirrors the Gun Dealer's civilian-business shape where useful, but
places the role in the existing Criminal group and sets salary to zero so S1
does not create a faucet.

```jsonc
{
  "id": "<BLACK_MARKET_DEALER_JOB_ID>",
  "gameModeJobGroupId": "37ba5dc8-1690-542c-a0f3-5fd9cdf3a179",
  "prerequisiteJobId": null,
  "name": "Black Market Dealer",
  "description": "Operates the underground equipment market for player buyers.",
  "color": 8917522,
  "model": "",
  "clothes": [],
  "jobTags": ["BlackMarketDealer"],
  "salary": 0,
  "includeDefaultEquipment": true,
  "gameModeEquipmentIds": [],
  "health": 100,
  "demoteOnRespawn": false,
  "interaction": null,
  "selectable": true,
  "demotable": true,
  "playTime": 30,
  "maxCount": 3,
  "voteRequired": false,
  "electionRequired": false
}
```

Portal-entry notes:

- Confirm the portal accepts literal `name` and `description` values. If it
  requires localization keys, create the localization contract before using
  `#roleplay.job.blackmarketdealer.*`; do not ship unresolved keys.
- `gameModeJobGroupId` is the T2 Criminal group.
- `salary: 0` is deliberate for the money-disabled slice.
- No equipment, content, or commerce grant is attached in S1.
- `BlackMarketDealer` is a proposed job tag for future policy targeting; remove
  it if the portal does not support custom job tags.

## R2 variant A — dealer-only market

In this variant, the Black Market Dealer is the operator and the only direct
buyer of portal market stock. Every future black-market market row mirrors the
Gun Dealer's `whitelistJobIds` pattern:

```jsonc
{
  "id": "<PORTAL_ALLOCATED_MARKET_ITEM_ID>",
  "type": "<CONTENT_TYPE>",
  "referenceId": "<REGISTERED_CONTENT_REFERENCE_ID>",
  "grouping": "#entity.category.blackmarket",
  "sortOrder": 0,
  "cost": "<RULING_REQUIRED>",
  "color": 16777215,
  "quantity": "<RULING_REQUIRED>",
  "whitelistJobIds": [
    "<BLACK_MARKET_DEALER_JOB_ID>"
  ],
  "blacklistJobIds": [],
  "whitelistJobTags": [],
  "blacklistJobTags": []
}
```

S1 does not instantiate this row because no black-market content reference,
cost, quantity, or economy ruling exists. The row defines only the access
shape.

Consequences:

- dealer management and stock acquisition are job-gated;
- ordinary players cannot purchase these market rows directly;
- later player-to-player sales remain net-zero transfers and require the
  separately gated economy slice;
- changing jobs immediately removes operator access.

## R2 variant B — public underground shop

In this variant, the same future market row is public. Both whitelist and
blacklist arrays are empty:

```jsonc
{
  "id": "<PORTAL_ALLOCATED_MARKET_ITEM_ID>",
  "type": "<CONTENT_TYPE>",
  "referenceId": "<REGISTERED_CONTENT_REFERENCE_ID>",
  "grouping": "#entity.category.blackmarket",
  "sortOrder": 0,
  "cost": "<RULING_REQUIRED>",
  "color": 16777215,
  "quantity": "<RULING_REQUIRED>",
  "whitelistJobIds": [],
  "blacklistJobIds": [],
  "whitelistJobTags": [],
  "blacklistJobTags": []
}
```

Consequences:

- any job may access the portal market row;
- the Black Market Dealer job remains available for later operator-only
  management of the hub, register, terminal, and locker;
- buyer access must not be accidentally denied by reusing the operator gate;
- no Government blacklist is proposed because "public" must mean public unless
  Bloodwave narrows R2.

## Money-disabled job-gate contract

This is a contract for later source stubs, not source code in BM-S1.

All checks are server-authoritative and use the portal-issued job UUID:

```text
IsDealer(player):
  return player is valid
     and player current job id == configured Black Market Dealer job id

CanManageMachine(player):
  return IsDealer(player)

CanBrowseShop(player):
  R2-A -> IsDealer(player)
  R2-B -> player is valid

OnDenied:
  return a denial result only
  perform no state change

OnAllowedDuringS1:
  return a money-disabled/not-configured result only
  perform no balance, stock, grant, or persistence operation
```

Required invariants:

- never trust a client-supplied job ID;
- never cache authorization across a job change;
- operator access and buyer access are distinct gates;
- no fallback grants access when the configured job UUID is absent;
- no balance, wallet, bank, BTC, ledger, stock, item-grant, or payout API is
  referenced by the S1 stub.

## Package registration draft

These snippets document the post-R7 manifest shape. They are not applied by
BM-S1.

### Proposed `packages.json` row

```jsonc
{
  "packageSlug": "lifepunchblackmarket",
  "sboxIdentifier": "lifepunch.blackmarket",
  "repoIdent": "blackmarketdealer",
  "title": "LIFEPUNCH™ Black Market Dealer for DXRP",
  "status": "quarantine",
  "notes": "Package folder lpblackmarket. Registration remains gated on Bloodwave R7 and portal identity creation."
}
```

### Proposed `addons.json` entry

```jsonc
{
  "ident": "blackmarketdealer",
  "packageSlug": "lifepunchblackmarket",
  "title": "LIFEPUNCH™ Black Market Dealer for DXRP",
  "description": "LIFEPUNCH™ Black Market Dealer for DXRP — an underground capability market operated as a net-zero player business. Published by LIFEPUNCH.",
  "kind": "interactive-entity",
  "hasAssets": true,
  "hasCode": false,
  "dxrpAddonId": "",
  "dxrpAddonIdentifier": "lifepunchblackmarket",
  "sboxIdentifier": "lifepunch.blackmarket",
  "status": "registration-proposed",
  "spec": "docs/BLACK_MARKET_DEALER_S1_REGISTRATION_PROPOSAL.md",
  "notes": "R7 pending. Assets are staged under lpblackmarket; blackmarketdealer remains the transitional repoIdent and publish mount. Zero economy in BM-S1.",
  "contents": []
}
```

`contents` intentionally stays empty. Staged source assets are not compiled,
registered portal content. The future S2 entity slice must prove prefab and
model references before any content row is added.

## Bloodwave decisions required

1. **R7:** approve or replace the proposed identity map:
   `lifepunchblackmarket` / `lpblackmarket` / `lifepunch.blackmarket` /
   transitional `blackmarketdealer`.
2. **R2:** select dealer-only market whitelisting or a public underground shop.
3. Confirm the proposed Criminal job group, three-slot cap, 30-minute playtime,
   zero salary, and optional `BlackMarketDealer` tag before portal entry.

Until those rulings land, the registration remains documentation only and the
runtime surface remains absent.
