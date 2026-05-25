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

## DXRP Audit Page

Observed filters:

- `Player ID`
- `Actions`
- `Entity ID`

Observed columns:

- `When`
- `Action`
- `Player`
- `Entity`
- `Description`

Observed action examples:

- `Chat`
- `DispatchAction`
- `Update`
- `GenerateToken`

Role taxonomy is tracked in `config/audit-taxonomy.json`.
