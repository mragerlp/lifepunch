# Ranks

Purpose: manage visible in-game ranks and staff permissions.

LifePunch owner note:

- The owner role may intentionally appear blank in-game so public players do not see ownership status.
- Do not rely on visible in-game rank labels to determine real portal authority.
- Owner authority is tracked separately from normal staff permission templates.

Observed Owner rank baseline:

- Rank ID: `64367f56-9492-4340-91e4-e2866d1b653a`
- Order: `69`
- Flags: no flags set in detail view.
- Server Restriction: `All Servers`.
- Permissions: `All Permissions (Wildcard)` / unrestricted access.
- Edit mode shows `Grant all permissions (wildcard)` enabled.
- Inherits From: `None`.

Observed Developer rank baseline:

- Rank ID: `019dee95-9eb9-7e04-99ce-b70562842e08`
- Order: `10`
- Flags: `Show On Nameplate` and `Show In Chat` enabled.
- Server Restriction: `All Servers`.
- Permissions: `All Permissions (Wildcard)` / unrestricted access.
- Edit mode shows `Grant all permissions (wildcard)` enabled.
- Inherits From: `None`.
- Policy note: this is broader than the desired delegated Developer role and should be narrowed before assigning to anyone else.

Observed Super Admin rank baseline:

- Rank ID: `019dff06-68ca-700a-89f2-acdbed20e74a`
- Order: `9`
- Flags: `Show In Chat` enabled.
- Server Restriction: `All Servers`.
- Permissions: `All Permissions (Wildcard)` / unrestricted access.
- Edit mode shows `Grant all permissions (wildcard)` enabled.
- Inherits From: `None`.
- Policy note: this is broader than the desired delegated Super Admin role and should be narrowed before assigning broadly.

Observed Community Manager rank baseline:

- Rank ID: `019e1a5e-8866-7a44-8137-35cd32f13c06`
- Order: `7`
- Flags: `Show In Chat` enabled.
- Server Restriction: `All Servers`.
- Permissions: `All Permissions (Wildcard)` / unrestricted access.
- Edit mode shows `Grant all permissions (wildcard)` enabled.
- Inherits From: `None`.
- Policy note: this is broader than the desired delegated Community Manager role and should be narrowed before assigning broadly.

Observed Admin rank baseline:

- Rank ID: `019db2da-0c97-78a1-abca-78203b56daad`
- Order: `5`
- Flags: `Show In Chat` enabled.
- Server Restriction: `All Servers`.
- Permissions: no wildcard access.
- Edit mode shows `Grant all permissions (wildcard)` disabled.
- Inherits From: `None`.
- `None` permissions mean no access.
- Policy note: Admin and lower ranks must remain non-wildcard.

Observed Moderator rank baseline:

- Rank ID: `019db2da-5dc9-7e36-b0f5-09a713791c26`
- Portal label: `Mod`
- Order: `4`
- Flags: `Show In Chat` enabled.
- Server Restriction: `All Servers`.
- Permissions: no wildcard access.
- Edit mode shows `Grant all permissions (wildcard)` disabled.
- Inherits From: `None`.
- `None` permissions mean no access.
- Policy note: Moderator and lower ranks must remain non-wildcard.

Observed EVIP rank baseline:

- Rank ID: `019db2db-0656-7893-ae2b-3ae1be47c186`
- Category: supporter/donator, not administrative.
- Order: `3`
- Flags: `Show On Nameplate` and `Show In Chat` enabled.
- Server Restriction: `All Servers`.
- Permissions: no wildcard access.
- Edit mode shows `Grant all permissions (wildcard)` disabled.
- Inherits From: `None`.
- `None` permissions mean no access.
- Observed explicit perks: `Minigame Manage`, `Minigame Participate`, `RP Name`, and `Bypass Max Players`.
- Observed inherited perk: `Use Title`.
- Policy note: EVIP must not receive portal, moderation, server, economy, inventory, API key, or staff-permission access.

Observed VIP rank baseline:

- Rank ID: `019db2da-c303-7c94-99e9-f3dbb6efb525`
- Category: supporter/donator, not administrative.
- Order: `2`
- Flags: `Show On Nameplate` and `Show In Chat` enabled.
- Server Restriction: `All Servers`.
- Permissions: no wildcard access.
- Edit mode shows `Grant all permissions (wildcard)` disabled.
- Inherits From: `None`.
- `None` permissions mean no access.
- Observed explicit perks: `Minigame Manage`, `Minigame Participate`, `RP Name`, and `Bypass Max Players`.
- Observed inherited perk: `Use Title`.
- Policy note: VIP must not receive portal, moderation, server, economy, inventory, API key, or staff-permission access.

Observed Members rank baseline:

- Rank ID: `019db841-3c15-7c69-bd44-07fc15153947`
- Category: regular player, Discord-verified.
- Order: `1`
- Flags: no flags set in detail view.
- Server Restriction: `All Servers`.
- Permissions: no wildcard access.
- Edit mode shows `Grant all permissions (wildcard)` disabled.
- Inherits From: `None`.
- `None` permissions mean no access.
- Observed explicit perks: `Minigame Participate`, `RP Name`, and `Use Title`.
- Policy note: Members must not receive portal, moderation, server, economy, inventory, API key, or staff-permission access.

Observed None rank baseline:

- Rank ID: `100547a0-3f91-42af-b8ec-e5e3a188c045`
- Category: default regular player.
- Order: `0`
- Flag: `Hide On Player List` enabled.
- Server Restriction: `All Servers`.
- Permissions: no wildcard access.
- Edit mode shows `Grant all permissions (wildcard)` disabled.
- Inherits From: `None`.
- `None` permissions mean no access.
- Observed explicit perk: `Use Title`.
- Normal in-game inventory item use is gameplay access, not portal inventory-management access.
- Policy note: the `None` rank must not receive portal, moderation, server, economy, API key, or staff-permission access.

Staff role policy lives in `../../admin-panel`.

Operational rules:

- Rank display and portal permissions must be treated separately.
- Do not grant portal permissions just because a visible in-game rank exists.
- Do not expose hidden owner identity through rank labels or docs intended for staff distribution.
- Server ranks can be visible on player profile pages, e.g. `Super Admin`.
- The owner profile may intentionally show a blank visible rank even when owner authority exists.
- Use `../../admin-panel/permissions/owner-rank.json` as the Owner permission baseline.
- Use `../../admin-panel/permissions/developer-rank.json` as the observed Developer permission baseline.
- Use `../../admin-panel/permissions/super-admin-rank.json` as the observed Super Admin permission baseline.
- Use `../../admin-panel/permissions/community-manager-rank.json` as the observed Community Manager permission baseline.
- Use `../../admin-panel/permissions/admin-rank.json` as the observed Admin permission baseline.
- Use `../../admin-panel/permissions/moderator-rank.json` as the observed Moderator permission baseline.
- Use `../../players/ranks/evip-rank.json` as the observed EVIP supporter baseline.
- Use `../../players/ranks/vip-rank.json` as the observed VIP supporter baseline.
- Use `../../players/ranks/members-rank.json` as the observed Members player baseline.
- Use `../../players/ranks/none-rank.json` as the observed default player baseline.

Portal confirmation needed:

- Exact rank fields.
- Whether rank permissions map directly to portal permissions.
- Whether in-game rank labels can be blank while portal ownership remains intact.
