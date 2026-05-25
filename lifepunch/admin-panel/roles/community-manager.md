# Community Manager

Purpose: manage community-facing operations, communication, staff coordination, and player trust.

Observed DXRP rank details:

- Rank URL: `https://dxrp.net/portal/ranks/019e1a5e-8866-7a44-8137-35cd32f13c06`
- Rank ID: `019e1a5e-8866-7a44-8137-35cd32f13c06`
- Order: `7`
- Server Restriction: `All Servers`
- Inherits From: `None`
- Permission mode: `Grant all permissions (wildcard)`
- Flags: `Show In Chat` is enabled; `Hide On Player List` and `Show On Nameplate` are disabled.

Current portal risk:

- The observed Community Manager rank has unrestricted wildcard access.
- This is broader than the LifePunch least-privilege target below.
- Before assigning Community Manager broadly, remove wildcard access and keep technical release, API key, economy-wide, and staff-permission actions protected.

Should have:

- Dashboard view.
- Announcements edit.
- Player lookup for support.
- Broad audit visibility for staff accountability.
- Limited sanctions access for escalations.
- Factions/ranks visibility and limited edits if needed for community structure.

Should not have:

- Addon publishing.
- Gamemode import/save.
- Server sync/restart.
- Developer-only technical access.
- Economy editing by default.

Notes:

- Community Manager can coordinate the community without owning technical release controls.
- Keep website/Discord responsibilities separate until those systems are added to this repo later.
