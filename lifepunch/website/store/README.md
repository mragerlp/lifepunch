# Website Store

This folder documents the LifePunch donation/store page.

Observed URL:

```text
https://lifepunch.co/store
```

Observed purpose:

- Support LifePunch.
- Purchase ranks/perks.
- View previous transactions.
- Apply referral codes.
- Finalize checkout through Stripe.

Observed store notice:

```text
Support LifePunch with a monthly VIP or EVIP subscription and unlock exclusive perks! Your subscription helps keep our servers running and funds new features. Billed monthly through Stripe — cancel anytime.
```

Observed panels:

- My Transactions.
- Select Package.
- Finalize.
- Stripe checkout.

Observed packages:

- `VIP`: `$10.00/mo` monthly subscription (`price_1TinR5980UYbxT0B4iv7DQ5v`), standard rank.
- `EVIP`: `$25.00/mo` monthly subscription (`price_1TinMD980UYbxT0BPfZs8K8g`), premium rank.
- `SLP - Work In Progress`: in-game currency, shown as work in progress.
- `SLP Currency ($)`: appears in transaction history at `$5.00`.

Observed checkout fields/actions:

- Account, using SteamID64.
- Package.
- Referral code input.
- `Apply` referral action.
- Total.
- `Back`.
- `Subscribe Securely` (VIP/EVIP monthly) or `Pay Securely` (future one-time packages).

Observed Stripe payment methods:

- Card.
- Cash App Pay.
- Klarna.
- Afterpay.
- Crypto.
- Amazon Pay option.

Security rules:

- Do not store Stripe checkout session URLs, customer IDs, payment emails, payment method details, receipt IDs, or transaction exports in Git.
- Do not store Stripe API keys or webhook signing secrets outside `../../secure`.
- Store only package names, public prices, public perk labels, and non-secret workflow notes here.

Policy notes:

- VIP/EVIP are supporter ranks, not administrative roles.
- VIP/EVIP do not grant moderation powers, in-game commands, portal permissions, or administrative tools.
- Store fulfillment should only grant the approved in-game supporter role/perks from the rank baselines.
- Store fulfillment should be tested against `lifepunchdevelopment` or dry-run tooling before affecting live ranks.
