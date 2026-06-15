# LifePunch Gamemode

This folder tracks LifePunch gamemode integration for DXRP.

Keep it separate from `../addons` and `../server`. Addon packages publish assets/code. The gamemode pins addon revisions and owns equipment/market/job rows. Server records and audits live in `../server`.

## Folder Roles

```text
gamemodes/   # exported/importable LifePunch .gamemode files
config/      # stable gamemode IDs, revision refs, import metadata
docs/        # gamemode procedures
scripts/     # gamemode validation/import/export helpers
```

## Boundaries

- Do not place addon assets here.
- Do not place addon code here.
- Do not edit addon package content rows here unless the change is explicitly gamemode attachment data.
- Keep DXRP portal/server operations documented before automating them.

## Current Status

**Ship target:** **LIFEPUNCH™** — `019ec9ec-7527-7cf4-87f9-d04e582989bb` · canonical export `gamemodes/lifepunch-ship.gamemode` (captured 2026-06-15). Not assigned to servers until bitcoin sign-off.

**Legacy / dev:** **LifePunch** gamemode (`019e36c0-a67f-701c-90f2-460e0b0f1487`) — earlier pins and development testing. Do not conflate with **LIFEPUNCH™** ship pins.

This lane stores canonical `.gamemode` exports and revision pins for both portal rows.

Observed legacy LifePunch gamemode:

- Name: `LifePunch`
- ID: `019e36c0-a67f-701c-90f2-460e0b0f1487`
- Visibility: `Private`
- Jobs: `26`
- Addons: `8`
- Default Job: `Citizen`
- Starting Balance: `$15,000`

Start here:

- `docs/NETWORK_OPERATIONS.md`
- `docs/GAMEMODE_PIPELINE.md`
- `config/addon-revisions.json`
- `config/equipment.json`
- `config/market.json`
