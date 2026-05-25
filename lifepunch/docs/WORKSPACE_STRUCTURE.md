# LifePunch DXRP Workspace Structure

This repository is the organizing reference for the LifePunch community server on DXRP.

## Main Folder

```text
lifepunch/
  addons/
  gamemode/
  server/
  maps/
  portal/
  admin-panel/
  players/
  economy/
  audit/
  website/
  discord/
  webhooks/
  API/
  secure/
  docs/
  templates/
```

The folders are separate because DXRP addon publishing, gamemode integration, server management, mapping, portal administration, staff hierarchy, player support, economy management, audit/accountability, website work, Discord operations, webhooks, and API contracts are separate responsibilities.

## `addons`

Use this folder for package source:

```text
lifepunch/addons/Assets/addons/lifepunch/<ident>/
lifepunch/addons/Code/Addons/lifepunch/<ident>/
lifepunch/addons/config/addons.json
```

This is where AK47, Bitcoin Mining, Hacker Job entities, and future LifePunch addon packages are built.

## `gamemode`

Use this folder for gamemode source:

```text
lifepunch/gamemode/gamemodes/
lifepunch/gamemode/config/
lifepunch/gamemode/docs/
lifepunch/gamemode/scripts/
```

This is where gamemode exports, addon revision pins, equipment rows, market rows, and gamemode validation belong.

## `server`

Use this folder for hosted server source:

```text
lifepunch/server/config/
lifepunch/server/change-log/
lifepunch/server/scripts/
```

This is where `lifepunchmainserver` and `lifepunchdevelopment` server-page fields, audits, and change records belong.

## `maps`

Use this folder for mapping source, planning, testing notes, and future S&box map workflow:

```text
lifepunch/maps/
```

Do not place map source files in `addons`, `gamemode`, or `server`.

## `portal` And `admin-panel`

Use `lifepunch/portal` for DXRP.net portal tab documentation.

Use `lifepunch/admin-panel` for staff hierarchy and permission policy.

## `players`, `economy`, And `audit`

Use these folders for community operations:

```text
lifepunch/players/
lifepunch/economy/
lifepunch/audit/
```

- `players`: support procedures and privacy-safe player operations.
- `economy`: balance, inventory, market, shipment, and money-flow policies.
- `audit`: accountability workflows for portal, staff, developer, and owner-approved changes.

## `website`, `discord`, `webhooks`, And `API`

Use these folders for non-DXRP-package community infrastructure:

```text
lifepunch/website/
lifepunch/discord/
lifepunch/webhooks/
lifepunch/API/
```

- `website`: LifePunch.co planning, deployment notes, and website integration work.
- `discord`: Discord community operations, bot planning, and moderation workflows.
- `webhooks`: webhook routing, event categories, and integration documentation.
- `API`: API contracts, schemas, and non-secret integration notes.

Raw credentials and secrets for these areas belong in `lifepunch/secure`.

## Boundary

Do not mix these responsibilities:

- Addon assets/code do not belong in `lifepunch/gamemode`, `lifepunch/server`, `lifepunch/portal`, or `lifepunch/admin-panel`.
- Gamemode exports do not belong in `lifepunch/addons`.
- Server records do not belong in `lifepunch/gamemode`.
- Map source does not belong in `lifepunch/addons`, `lifepunch/gamemode`, or `lifepunch/server`.
- Player private data and raw economy exports should not be stored in tracked docs.
- Audit records should summarize evidence without exposing secrets or unnecessary private player data.
- Website, Discord, webhook, and API secrets do not belong in tracked docs. Use `lifepunch/secure`.
- Generated publish staging is never source of truth.

Run the root validator after structural changes:

```powershell
.\scripts\validate-workspace.ps1
```
