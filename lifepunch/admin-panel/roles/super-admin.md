# Super Admin

Purpose: trusted senior operations role with broad community-management access.

Observed DXRP rank details:

- Rank URL: `https://dxrp.net/portal/ranks/019dff06-68ca-700a-89f2-acdbed20e74a`
- Rank ID: `019dff06-68ca-700a-89f2-acdbed20e74a`
- Order: `9`
- Server Restriction: `All Servers`
- Inherits From: `None`
- Permission mode: `Grant all permissions (wildcard)`
- Flags: `Show In Chat` is enabled; `Hide On Player List` and `Show On Nameplate` are disabled.

Current portal risk:

- The observed Super Admin rank has unrestricted wildcard access.
- This is broader than the LifePunch least-privilege target below.
- Before assigning Super Admin broadly, replace wildcard access with senior operations permissions that still leave owner-only technical actions protected.

Should have:

- Dashboard view and operational oversight.
- Player lookup.
- Sanctions creation/removal.
- Broad audit visibility.
- Inventory correction access if audited.
- Maps, rulesets, factions, and ranks access where needed.

Should not have by default:

- Addon publishing.
- Gamemode import/save.
- Server sync/restart.
- Staff permission editing without owner approval.
- Hidden owner-level access.

Notes:

- Super Admin is powerful but still not owner.
- Production-impacting technical actions remain owner-approved.
