# Audit

Purpose: review administrative actions and operational changes.

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

Observed entity examples:

- `Server`
- `ServerAction`

Operational rules:

- Audit logs are accountability data.
- Do not delete, alter, or hide audit history.
- Use audit entries to verify who changed ranks, sanctions, gamemode pins, addon revisions, and server syncs.
- Store only summarized findings in this repo unless an incident requires exact references.
- Categorize curated audit reviews under `../../audit` by staff/player/supporter rank.
- Use SteamID64 values to identify players when needed.

Recommended access:

- Moderator: no access or limited own-action visibility.
- Admin: limited moderation-related visibility.
- Super Admin: broad visibility.
- Community Manager: broad visibility.
- Developer: technical-change visibility only if needed.

Portal confirmation needed:

- Full Actions dropdown values.
- Export availability.
- Role-specific audit permissions.
