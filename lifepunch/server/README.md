# Servers

Purpose: manage the two hosted LifePunch DXRP servers, environment state, and sync actions.

The Servers page is expected to contain only the two hosted LifePunch servers:

- `lifepunchmainserver` (`70p`): vanilla DXRP server capped around 70 players and intended to mirror official DXRP server limitations.
- `lifepunchdevelopment` (`Development`): addon and beta-feature testing server.

Observed dashboard names:

- `lifepunchmainserver`: `LifePunch Official | 70p`
- `lifepunchdevelopment`: `LifePunch Official | DEVELOPMENT SERVER`

Treat these as the main operational focus. Do not design workflows around external or unmanaged servers unless the owner adds them later.

Expected data to document here:

- `lifepunchmainserver` DXRP server ID.
- `lifepunchdevelopment` DXRP server ID.
- Server name/description/visibility.
- Version.
- Current gamemode assignment.
- Ruleset assignment.
- Map assignment.
- Player capacity.
- Online/status state.
- Created age.
- Last pulsed time.
- Last sync state.
- Dashboard live overview status.
- Addon/gamemode sync controls.
- Restart or deployment controls, if present.

Observed Servers page table:

- Search field: `Search by ID or Name`.
- Buttons: `Clear`, `Refresh`, `Add`.
- Columns: `Name`, `Version`, `Players`, `Uptime`, `Created`, `Last Pulsed`, `Actions`.
- Pagination: `Showing 1 to 2 of 2 servers`.
- Rows per page observed: `9`.

Observed server rows:

- `LifePunch Official | 70p`
  - Version: `26.05.20`
  - Created: `1 month ago`
  - Last Pulsed: `9 minutes ago`
- `LifePunch Official | DEVELOPMENT SERVER`
  - Version: `26.05.20`
  - Created: `3 weeks ago`
  - Last Pulsed: `2 days ago`

Observed actions:

- Pencil/edit icon.
- Magnifier/view or search icon.

Treat `Add` and pencil/edit as high-risk until exact modal fields are documented.

Operational rules:

- Treat sync, restart, publish, and deployment buttons as high-risk actions.
- Never trigger server sync without explicit owner approval.
- Keep `lifepunchmainserver` and `lifepunchdevelopment` procedures separate.
- Test addon/gamemode/beta-feature changes on `lifepunchdevelopment` before considering `lifepunchmainserver`.
- **On-box launch wrappers** (versioned): `dxrp-host/` — deploy to `C:\S&BOX DXRP Server` via `Deploy-DxrpHostLaunchers.ps1`. Tokens stay in on-box `secure/*.local.env` only.
- **Launch law (addons live):** `LAUNCHING_SERVER_WITH_ADDONS.md` — both servers use `dotnet run dxrp-server.cs`; portal token controls addon pull.
- **Server won't pulse / INACTIVE?** → `SERVER_ONLINE_QUICKFIX.md` (Official must use `dotnet run dxrp-server.cs`, not `+game dxura.rp`).
- Do not commit live tokens, `dxrp-server-config.json` with secrets, or fork upstream `dxrp-server.cs`.
- Keep the server inventory in `../../config/servers.json`.
- Keep the visible server-page field inventory in `../../config/server-page-fields.json`.
- Record developer/admin changes in `change-log/` using `../../templates/server-change.md`.
- Review `../docs/DXRP_DOCS_REFERENCE.md` and the DXRP `Launching Server with Addons` docs before documenting server launch/sync automation.

## Change Tracking

Every meaningful server-page change should have a record. This includes configuration edits, sync/restart actions, map/ruleset/gamemode changes, and revision pin changes.

Use:

```text
server/change-log/YYYY-MM-DD-short-description.md
```

Do not store raw secrets or private keys in change records. If a secret is involved, reference `../secure/` and record only the purpose.

Portal confirmation needed:

- Exact server IDs.
- Exact edit modal fields.
- Which buttons are destructive or runtime-affecting.
- Whether sync actions affect only one server or all servers.
