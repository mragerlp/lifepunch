# Developer

Purpose: help build and test LifePunch technical systems without gaining unnecessary community control.

Observed DXRP rank details:

- Rank URL: `https://dxrp.net/portal/ranks/019dee95-9eb9-7e04-99ce-b70562842e08`
- Rank ID: `019dee95-9eb9-7e04-99ce-b70562842e08`
- Order: `10`
- Server Restriction: `All Servers`
- Inherits From: `None`
- Permission mode: `Grant all permissions (wildcard)`
- Flags: `Show On Nameplate` and `Show In Chat` are enabled; `Hide On Player List` is disabled.

Current portal risk:

- The observed Developer rank has unrestricted wildcard access.
- This is useful as a temporary owner-controlled technical role, but it is broader than the LifePunch least-privilege target below.
- Before assigning Developer to anyone else, replace wildcard access with scoped technical permissions.

Should have:

- Limited dashboard view.
- Addon read access.
- Technical audit visibility for addon/gamemode/server changes.
- `lifepunchdevelopment` server visibility if needed.
- Access to repo-driven addon/gamemode procedures.

Should not have by default:

- Player sanctions.
- Rank or staff permission editing.
- Economy or inventory editing.
- `lifepunchmainserver` sync/restart.
- Gamemode import/save on `lifepunchmainserver`.
- Addon publish affecting `lifepunchmainserver` without owner approval.

Notes:

- Developer access should be scoped to technical work.
- Prefer `lifepunchdevelopment` access over `lifepunchmainserver`.
- All LifePunch addon work must remain credited to LifePunch and flow through the repo pipeline.
