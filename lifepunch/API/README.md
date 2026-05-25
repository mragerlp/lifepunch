# API

This folder is reserved for LifePunch API contracts and integration plans.

Use it for API documentation, endpoint planning, request/response schemas, and integration notes between the website, Discord, DXRP portal, and server tooling.

Do not store raw API keys, bearer tokens, service credentials, or private keys here.

Future structure:

```text
API/
  docs/
  schemas/
  clients/
  integrations/
```

Secrets belong in `../secure`. Public/non-secret schemas and contracts belong here.

## Verification Integration Areas

Player verification may involve multiple systems:

- Website Steam login.
- SteamID64 identity capture.
- Discord account linking.
- DXRP player profile/rank update.
- `Members` rank sync for verified Discord users.
- VIP/EVIP supporter fulfillment.
- Website reward claims.
- Website weekend reward cooldowns.
- Website monthly giveaway entries.
- Website giveaway winner draw.
- Website transaction lookup.
- Website ban management.
- Website system settings and automation tokens.
- Stripe checkout session creation.
- Stripe webhook fulfillment.
- Store package and rank mapping.

Before changing any integration, audit whether existing API routes or webhook consumers are stale, duplicated, or pointing at old environments.

Do not store access tokens, webhook secrets, OAuth secrets, Steam API keys, Discord bot tokens, or raw player identity exports here.

Website auth/admin observations are tracked in `../website/config/website-auth.json`.
Website rewards observations are tracked in `../website/config/rewards-page.json`.
Store and Stripe observations are tracked in `../website/config/store-page.json`.
