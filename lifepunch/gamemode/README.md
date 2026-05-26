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

This lane is where the canonical `lifepunch.gamemode` file will live when we import/export through the DXRP portal Game Modes page.

Observed LifePunch gamemode:

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
