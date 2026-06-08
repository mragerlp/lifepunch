# Audit

This folder is for LifePunch audit and accountability workflows.

Use it for:

- Portal change review procedures.
- Developer/admin change summaries.
- Owner approval records.
- Incident follow-up summaries.
- Cross-checks against DXRP portal Audit entries.
- Role-based audit summaries for staff, regular players, and supporters.

Do not copy raw sensitive logs into this folder unless required for an incident and approved by the owner.

Related areas:

- Server changes: `../server/change-log/`
- Admin roles: `../admin-panel/`
- Operational templates: `../templates/`

Future structure:

```text
audit/
  config/
  staff/
    owner/
    moderator/
    admin/
    super-admin/
    community-manager/
    developer/
  players/
    none/
    members/
  supporters/
    vip/
    evip/
  incidents/
  approvals/
```

## DXRP Audit Page (verified live 2026-06-07)

Backed by `GET https://api.dxrp.net/v1/audit/events?pageIndex=&pageSize=` (Bearer, tenant-scoped,
server-side pagination — portal default `pageSize` 50). The REST read exists at the API layer; the
in-game `ServerApiClient` does not yet expose it (see `TECH_DEBT.md` STAFF-07).

Filters (only these two — there is **no** Actions dropdown on the live page):

- `Player ID` (SteamID64, or `system` for server/automated actors)
- `Entity ID`

Observed columns:

- `When`
- `Action` (rendered as a coloured pill)
- `Player` (`system`, dimmed, for server/automated entries; otherwise a SteamID64 link)
- `Entity` (`Server`, `Player`)
- `Description` (free text; may contain localisation keys, e.g. `#system.automessage.rulebreakers`)

Observed action examples:

- `Chat`
- `ModifyBalance`
- `DispatchAction`
- `Update`
- `GenerateToken`

Role taxonomy is tracked in `config/audit-taxonomy.json`.
