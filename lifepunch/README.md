# LifePunch

This is the main workspace for the LifePunch community on DXRP.

Treat this folder as the operational source of truth for everything LifePunch needs inside the DXRP gamemode:

```text
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

## Responsibilities

- `addons`: LifePunch DXRP addon packages and publish staging.
- `gamemode`: LifePunch gamemode exports, imports, revision pins, equipment rows, market rows, and gamemode validation.
- `server`: hosted server configuration, server-page field inventory, and change tracking for `lifepunchmainserver` and `lifepunchdevelopment`.
- `maps`: mapping plans, source references, and future S&box map workflow.
- `portal`: DXRP.net portal tab documentation and future portal review findings.
- `admin-panel`: staff hierarchy, roles, and permissions.
- `players`: player support procedures and privacy-safe player operations.
- `economy`: player balances, inventory, markets, and money-flow policy.
- `audit`: portal/staff/developer accountability workflows.
- `website`: LifePunch.co website planning and integrations.
- `discord`: Discord community operations and bot planning.
- `webhooks`: webhook routes and event integration docs.
- `API`: API contracts, schemas, and non-secret integration notes.
- `secure`: local sensitive values and templates.
- `docs`: workspace-wide operating documents.
- `templates`: shared operational templates.

## Server Identities

- `lifepunchmainserver`: portal display name `70p`, vanilla-style LifePunch server that mirrors official DXRP limitations.
- `lifepunchdevelopment`: portal display name `Development`, addon and beta-feature testing server.

## Boundary Rule

Do not mix folder responsibilities. For example, addon assets belong in `addons/Assets`, server records belong in `server/`, mapping work belongs in `maps/`, player support belongs in `players/`, economy policy belongs in `economy/`, audits belong in `audit/`, website work belongs in `website/`, Discord work belongs in `discord/`, webhook routing belongs in `webhooks/`, API contracts belong in `API/`, and staff permissions belong in `admin-panel/`.

Validate from the repository root:

```powershell
.\scripts\validate-workspace.ps1
```
