# Economy

This folder is for LifePunch economy and inventory operations.

Use it for procedures and policies around:

- Player balances.
- Inventory corrections.
- Market items and shipments.
- In-game money generation systems.
- Economy-impacting addons such as Bitcoin Mining.

Do not store raw player economy exports or private player data here unless there is a specific incident record and owner approval.

High-risk actions:

- Editing player balances.
- Editing player inventory.
- Changing market prices or shipments.
- Changing money generation rates.
- Deploying addons that affect currency flow.

Economy changes should be tested on `lifepunchdevelopment` before `lifepunchmainserver`.

## Store And Donation Economy

The LifePunch website store is connected to Stripe and includes supporter ranks plus SLP currency packages.

Observed store packages:

- `VIP`: supporter rank, `$10.00`.
- `EVIP`: supporter rank, `$25.00`.
- `SLP - Work In Progress`: in-game currency package.
- `SLP Currency ($)`: observed transaction package at `$5.00`.

Rules:

- Do not store raw Stripe transactions, customer emails, payment details, checkout session URLs, or receipt IDs in Git.
- SLP currency fulfillment is economy-impacting and requires owner review before automation.
- VIP/EVIP fulfillment must match the rank baselines in `../players/ranks/`.
- VIP/EVIP do not grant moderation powers, in-game commands, portal permissions, or administrative tools.
- Supporter fulfillment should only grant approved in-game supporter roles/perks.

## Website Rewards Economy

Observed website rewards include:

- Join Discord Reward: `$10,000` one-time bonus.
- Weekend Bonus: `$10,000` recurring weekend bonus.
- Monthly Giveaway: `$100,000`, EVIP Rank, and Builder prize pool.

Reward fulfillment changes are economy-impacting. Review claim cooldowns, duplicate claim protection, giveaway winner selection, and rank/currency fulfillment before changing automation.
