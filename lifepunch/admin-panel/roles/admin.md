# Admin

Purpose: manage day-to-day community operations and escalated moderation.

Observed DXRP rank details:

- Rank URL: `https://dxrp.net/portal/ranks/019db2da-0c97-78a1-abca-78203b56daad`
- Rank ID: `019db2da-0c97-78a1-abca-78203b56daad`
- Order: `5`
- Server Restriction: `All Servers`
- Inherits From: `None`
- Permission mode: no wildcard access.
- Flags: `Show In Chat` is enabled; `Hide On Player List` and `Show On Nameplate` are disabled.

Observed permission rule:

- `None` means no access.
- Admin and lower ranks should not have wildcard access.

Should have:

- Dashboard view.
- Player lookup.
- Sanctions creation.
- Limited sanctions removal if audited.
- Limited inventory or player correction access if DXRP supports scoped permissions.
- Limited audit visibility for moderation cases.
- Limited maps/rulesets/factions access if needed for operations.

Should not have:

- Addon publishing.
- Gamemode import/save.
- Server sync/restart.
- Staff permission editing.
- Broad economy editing.

Notes:

- Admins can keep the community running, but should not control the technical release pipeline.
- Any action that changes server behavior or public economy should escalate.
