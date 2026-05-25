# Staff Permission Matrix

This is the starting policy for LifePunch staff access. It should be adjusted only after confirming exact DXRP portal permission switches.

Legend:

- `Yes`: role should normally have access.
- `Limited`: role may have constrained or read-only access.
- `No`: role should not have access by default.
- `Owner only`: requires direct owner action or explicit one-time approval.
- DXRP portal `None`: no access.

| Area | Moderator | Admin | Super Admin | Community Manager | Developer |
| --- | --- | --- | --- | --- | --- |
| Dashboard view | Yes | Yes | Yes | Yes | Limited |
| Announcements edit | No | Limited | Yes | Yes | No |
| Player lookup | Yes | Yes | Yes | Yes | Limited |
| Player economy edit | No | No | Owner only | Owner only | No |
| Inventory edit | No | Limited | Yes | Limited | No |
| Sanctions create | Limited | Yes | Yes | Limited | No |
| Sanctions remove | No | Limited | Yes | Limited | No |
| Audit view | No | Limited | Yes | Yes | Limited |
| Ranks edit | No | No | Limited | Limited | No |
| Staff permissions edit | No | No | Owner only | Owner only | No |
| Servers view | No | Limited | Yes | Limited | Limited |
| Server sync/restart | No | No | Owner only | No | Owner only |
| Game mode import/save | No | No | Owner only | No | Owner only |
| Addon view | No | Limited | Yes | Limited | Yes |
| Addon publish/edit | No | No | Owner only | No | Owner only |
| Maps/rulesets edit | No | Limited | Yes | Limited | Limited |
| Factions edit | No | Limited | Yes | Yes | No |

## High-Risk Actions

These actions should always require owner approval:

- Publishing addon revisions.
- Importing or saving gamemodes.
- Pinning addon revisions on the gamemode.
- Syncing or restarting servers.
- Editing staff permissions.
- Making economy-wide changes.
- Granting hidden or elevated access.

## Owner Baseline

Owner is tracked separately from normal staff roles:

- Rank ID: `64367f56-9492-4340-91e4-e2866d1b653a`
- Order: `69`
- Server restriction: `All Servers`
- Inherits from: `None`
- Permission mode: `Grant all permissions (wildcard)`

Use `owner-rank.json` as the ceiling when deciding what lower roles should not receive.

## Developer Observed State

The current DXRP Developer rank is broader than the intended policy target:

- Rank ID: `019dee95-9eb9-7e04-99ce-b70562842e08`
- Order: `10`
- Server restriction: `All Servers`
- Inherits from: `None`
- Flags: `Show On Nameplate`, `Show In Chat`
- Permission mode: `Grant all permissions (wildcard)`

Before assigning Developer to anyone outside direct owner-controlled work, remove wildcard access and scope the role back to the Developer column above.

## Super Admin Observed State

The current DXRP Super Admin rank is also broader than the intended policy target:

- Rank ID: `019dff06-68ca-700a-89f2-acdbed20e74a`
- Order: `9`
- Server restriction: `All Servers`
- Inherits from: `None`
- Flags: `Show In Chat`
- Permission mode: `Grant all permissions (wildcard)`

Before assigning Super Admin broadly, remove wildcard access and keep owner-only technical, economy-wide, and permission changes protected.

## Community Manager Observed State

The current DXRP Community Manager rank is broader than the intended policy target:

- Rank ID: `019e1a5e-8866-7a44-8137-35cd32f13c06`
- Order: `7`
- Server restriction: `All Servers`
- Inherits from: `None`
- Flags: `Show In Chat`
- Permission mode: `Grant all permissions (wildcard)`

Before assigning Community Manager broadly, remove wildcard access and keep technical release, API key, economy-wide, and staff-permission actions protected.

## Admin Observed State

The current DXRP Admin rank is the first confirmed non-wildcard staff rank:

- Rank ID: `019db2da-0c97-78a1-abca-78203b56daad`
- Order: `5`
- Server restriction: `All Servers`
- Inherits from: `None`
- Flags: `Show In Chat`
- Permission mode: no wildcard access

For Admin and lower ranks, treat `None` as no access. Do not grant wildcard access to Admin, Moderator, player, or supporter ranks.

## Moderator Observed State

The current DXRP Moderator rank is non-wildcard:

- Rank ID: `019db2da-5dc9-7e36-b0f5-09a713791c26`
- Portal label: `Mod`
- Order: `4`
- Server restriction: `All Servers`
- Inherits from: `None`
- Flags: `Show In Chat`
- Permission mode: no wildcard access

For Moderator and lower ranks, treat `None` as no access. Keep all technical, economy, inventory, server, and permission-management access denied or unset unless explicitly owner-approved.

## Portal Confirmation Needed

The exact DXRP permission toggles still need live portal confirmation. Until confirmed, use this file as the LifePunch policy target, not proof that the portal already enforces it.
