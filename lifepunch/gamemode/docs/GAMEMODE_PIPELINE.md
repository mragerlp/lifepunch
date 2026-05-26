# LifePunch Gamemode Pipeline

The gamemode lane coordinates LifePunch server integration on DXRP. It works with addon packages but does not contain addon package source.

## Responsibilities

- Store canonical LifePunch `.gamemode` exports.
- Track DXRP addon revision pins for the LifePunch gamemode.
- Track content-to-equipment relationships when DXRP requires equipment rows.
- Track market, job, and entity placement changes.
- Document `lifepunchdevelopment` server sync steps.
- Document portal steps before automating them.

## Separation From Addons

Addon package data belongs in `../../addons/config/addons.json`.

Gamemode data belongs here:

```text
lifepunch/gamemode/config/
lifepunch/gamemode/gamemodes/
```

Do not copy `Assets/addons/lifepunch/<ident>` or `Code/Addons/lifepunch/<ident>` into this folder.

## Tracking Files

Use these files for gamemode-side integration data:

```text
config/gamemode.json          # LifePunch gamemode id, environment, server names
config/addon-revisions.json   # addon revision pins used by the gamemode
config/equipment.json         # equipment rows linked to addon content rows
config/market.json            # market/shipments that expose equipment/entities
gamemodes/lifepunch.gamemode  # canonical import/export file
```

AK47 is tracked through separate addon, equipment, and market states. A published addon revision must be pinned first, then the AK47 equipment content must be exposed through the LifePunch gamemode Market tab before it appears in the in-game Market section on `lifepunchdevelopment`.

## Portal Workflow

The DXRP portal Game Modes page is the management surface for the LifePunch gamemode.

Observed workflow:

1. Open `Game Modes`.
2. Select `LifePunch`.
3. Use detail tabs to review `General`, `Addons (8)`, `Content`, `Jobs`, `Market`, and `Minigames`.
4. Use `Edit` to enter edit mode.
5. Use `Export` before risky changes to capture a rollback file.
6. Use `Import` when applying the canonical `gamemodes/lifepunch.gamemode` file in the future.
7. Save only after review.
8. Sync servers only after validation and owner approval.

High-risk actions:

- `Save`
- `Sync Servers`
- `Import`
- `Reset to Vanilla`
- `Delete Game Mode`
- changes under `Addons`, `Content`, `Jobs`, `Market`, or `Minigames`

## Operating Rule

Publish addon revisions first, then update gamemode references and revision pins. Do not assume a successful addon publish means the gamemode can use the content until the gamemode lane confirms it.
