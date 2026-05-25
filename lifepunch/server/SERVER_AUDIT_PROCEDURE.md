# Server Audit Procedure

Use this procedure when reviewing the DXRP portal Servers page or auditing developer/admin changes.

## Review Scope

Review only the two LifePunch hosted servers:

- `lifepunchmainserver` (`70p`)
- `lifepunchdevelopment` (`Development`)

Do not add workflows for unmanaged servers unless the owner adds them later.

## Baseline Capture

For each server, capture:

- Server name and ID.
- Current status.
- Player count or capacity.
- Assigned gamemode.
- Assigned ruleset.
- Assigned map.
- Last sync state.
- Visible action buttons.
- Any warning/error banners.

Update `../../config/servers.json` for stable server identity data.

Update `../../config/server-page-fields.json` if the portal exposes new fields/actions.

## Change Review

For each observed change:

1. Identify the affected server.
2. Identify the exact field or action.
3. Record before/after values.
4. Check whether owner approval was required.
5. Link any audit entry or screenshot.
6. Document rollback steps.

Use `change-log/YYYY-MM-DD-short-description.md` copied from `../../templates/server-change.md`.

## Risk Rules

Treat these as critical:

- Sync.
- Restart.
- Stop/start.
- Delete.
- Save configuration.
- Change assigned gamemode.
- Change assigned ruleset.
- Change assigned map.
- Change addon/gamemode revision pins.

Critical actions require owner approval even if the portal permits another role to click them.

## Developer Access

Developers may inspect technical server state if needed, but should not change `lifepunchmainserver` directly.

`lifepunchdevelopment` changes should still be documented when they affect addon testing, beta features, or gamemode behavior.
