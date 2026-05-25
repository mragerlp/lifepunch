# Players

Purpose: lookup and support individual players.

Player pages use SteamID64 URLs:

```text
https://dxrp.net/portal/players/<steamId64>
```

Owner reference shown by user:

```text
https://dxrp.net/portal/players/76561198103223564
```

Operational rules:

- Do not bulk-export player data into this repo.
- Store only procedures, anonymized examples, or audit references.
- Player sanctions belong in `../sanctions`.
- Role/rank policy belongs in `../../admin-panel`.
- Full player profile field inventory belongs in `../../players/config/player-profile-fields.json`.
- Treat balance, inventory, sanctions, and rank changes as auditable actions.

Portal confirmation needed:

- Exact player fields visible to each admin role.
- Whether player economy/inventory edits exist.
- Whether player moderation actions are available from this tab.
