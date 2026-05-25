# Website Rewards

This folder documents the LifePunch rewards page.

Observed URL:

```text
https://lifepunch.co/rewards
```

Observed page title:

```text
Unlock Bonuses
```

Observed logged-in state:

- Authenticated controls show `Panel`, `Profile`, and `Logout`.
- Join Discord Reward can show as `Claimed`.
- Weekend Bonus shows a timer/cooldown state.
- Monthly giveaway can show `Claim Entry`.
- Giveaway Status shows time remaining, monthly entry count, visible participant avatars, and last month's winner.

Observed logged-out state:

- Header shows `Login`.
- Page message says the user must be logged into Steam and authorize Discord for rewards.
- Join Discord Reward shows `Claim Reward`.
- Weekend Bonus shows `Claim Reward`.
- Monthly giveaway shows `Login To Enter`.

Observed reward cards:

- Join Discord Reward: link Discord and join the community server to claim a one-time `$10,000` bonus.
- Weekend Bonus: claim a `$10,000` bonus once every weekend, observed as Friday 8pm through Sunday night.
- Monthly `$100,000` Giveaway: enter monthly drawing to win `$100,000`, EVIP Rank, and Builder. Winner is drawn automatically.

Operational rules:

- Treat rewards as website + Steam + Discord integration.
- Do not store raw participant lists, Discord IDs, private player data, or claim records in Git.
- Reward claim/reset behavior must be reviewed through the website admin panel before automation changes.
- Currency rewards are economy-impacting and need owner approval before changing amounts, cooldowns, or fulfillment routes.
