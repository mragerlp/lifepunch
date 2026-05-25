# LifePunch DXRP Workspace

This repository is the sole working reference for the LifePunch community inside the DXRP gamemode.

All community operations live under the main `lifepunch/` folder:

```text
lifepunch/
  addons/        # DXRP addon packages
  gamemode/      # LifePunch gamemode exports/imports and gamemode config
  server/        # Hosted server configuration and server-page audit trail
  maps/          # Mapping plans, source references, and future map workflow
  portal/        # DXRP.net portal tab documentation
  admin-panel/   # Staff hierarchy and permission policy
  players/       # Player support procedures and privacy-safe operations
  economy/       # Economy, inventory, market, and money-flow policy
  audit/         # Portal/staff/admin accountability workflows
  website/       # LifePunch.co website planning and integrations
  discord/       # Discord community operations and bot planning
  webhooks/      # Webhook routes and integration docs
  API/           # API contracts, schemas, and integration notes
  secure/        # Local sensitive information, ignored by git except templates
  docs/          # Workspace-wide documentation
  templates/     # Operational templates
```

DXRP.net/portal connects the hosted/RDP server side to the DXRP gamemode in S&box on Steam. This repo tracks the structure and procedures around that connection without mixing addon package source, gamemode data, server config, staff policy, and secrets.

## Core Folders

- `lifepunch/addons`: AK47, future weapons, Bitcoin Mining, Hacker Job entities, and all LifePunch DXRP addon packages.
- `lifepunch/gamemode`: LifePunch gamemode exports/imports, addon revision pins, equipment/market rows, and gamemode validation.
- `lifepunch/server`: `lifepunchmainserver` (`70p`) and `lifepunchdevelopment` (`Development`) server records, field inventory, and change logs.
- `lifepunch/maps`: mapping plans and future S&box map workflow.
- `lifepunch/portal`: DXRP portal tab notes and future portal review findings.
- `lifepunch/admin-panel`: staff hierarchy, roles, and permission boundaries.
- `lifepunch/players`: player support procedures without bulk private data.
- `lifepunch/economy`: balance, inventory, market, and money-flow operations.
- `lifepunch/audit`: admin/developer accountability and portal change review.
- `lifepunch/website`: website plans and future `lifepunch.co` integration work.
- `lifepunch/discord`: Discord community operations and bot planning.
- `lifepunch/webhooks`: webhook routing and integration documentation.
- `lifepunch/API`: API contracts, schemas, and non-secret integration notes.
- `lifepunch/secure`: local-only sensitive information such as webhooks/API/server details.

Keep these folders separate even though they work together.

## Validate

Run the workspace validation from the repo root:

```powershell
.\scripts\validate-workspace.ps1
```

Run addon validation from the addon lane:

```powershell
cd .\lifepunch\addons
.\scripts\validate-layout.ps1
```
