# Discord

This folder is reserved for LifePunch Discord community operations.

Use it for Discord structure, moderation workflow, bot plans, channel policy, announcement procedures, and community integration notes.

Do not store raw bot tokens, webhook URLs, or private staff/player information here.

Future structure:

```text
discord/
  docs/
  bots/
  moderation/
  announcements/
```

Discord secrets belong in `../secure`. DXRP webhook categories are tracked in `../webhooks` and `../portal/network`.

## Website Discord Page

The public website Discord page is tracked in `../website/discord/`.

Observed actions:

- `Join Server`
- `Copy Invite Link`

This page is the community invite surface. Discord verification, reward claims, and rank sync are separate flows and should be reviewed through website profile/rewards plus API/webhook behavior.

## Verification Rank

The DXRP `Members` rank is reserved for players who have verified their Discord account.

The public LifePunch website login enters Steam sign-in first. Treat Discord verification as a linked step after Steam identity is known, unless future backend/API review shows a different source of truth.

Rules:

- `Members` is still a regular player rank.
- `Members` must not grant administrative tools or portal access.
- Rank automation must not store Discord tokens, raw private player data, or unnecessary identifiers in Git.
- The rank baseline is tracked in `../players/ranks/members-rank.json`.
- SteamID64 should be the stable player identifier when connecting website login, Discord verification, DXRP player profile records, and rank sync.

## Website Rewards

The website Rewards page requires Steam login and Discord authorization.

Observed reward paths:

- Join Discord Reward for a one-time in-game money bonus.
- Weekend Bonus claim.
- Monthly giveaway entry.

Do not store raw Discord participant lists, private Discord IDs, or reward claim records in Git. Rewards behavior is tracked in `../website/config/rewards-page.json`.
