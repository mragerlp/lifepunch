# Moderator

Purpose: handle routine player-facing moderation without access to technical or economy-critical systems.

Observed DXRP rank details:

- Rank URL: `https://dxrp.net/portal/ranks/019db2da-5dc9-7e36-b0f5-09a713791c26`
- Rank ID: `019db2da-5dc9-7e36-b0f5-09a713791c26`
- Portal label: `Mod`
- Order: `4`
- Server Restriction: `All Servers`
- Inherits From: `None`
- Permission mode: no wildcard access.
- Flags: `Show In Chat` is enabled; `Hide On Player List` and `Show On Nameplate` are disabled.

Observed permission rule:

- `None` means no access.
- Moderator and lower ranks must not have wildcard access.

Should have:

- Dashboard view.
- Player lookup.
- Limited sanctions creation if DXRP supports constrained sanction permissions.
- Access to moderation procedures.

Should not have:

- Addon publishing.
- Gamemode import/save.
- Server sync/restart.
- Rank or staff permission editing.
- Economy or inventory editing.
- Full audit access.

Notes:

- Moderators should not be able to affect server infrastructure.
- Escalate permanent bans, staff issues, economy issues, and technical issues to Admin or higher.
