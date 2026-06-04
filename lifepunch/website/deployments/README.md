# Website Deployments

This folder tracks deployable website worker code and deployment notes. Do not store live secrets here.

## Cloudflare Worker Secrets

Configure these in Cloudflare, not in Git:

- `ADMIN_STEAMIDS`: comma-separated SteamID64 values that can access `/admin`.
- `DISCORD_CLIENT_ID` and `DISCORD_CLIENT_SECRET`: Discord OAuth app credentials.
- `DISCORD_GUILD_ID`: LifePunch Discord server ID for reward verification.
- `DISCORD_REWARDS_WEBHOOK_URL`: Discord webhook for reward notifications.
- `DISCORD_WEBHOOK_URL`: Discord webhook for store/admin notifications.
- `DXRP_TOKEN_SYNC_SECRET`: shared secret required by `/api/v1/sync-auth-token`.
- `STEAM_API_KEY`: Steam Web API key for profile lookup.
- `STRIPE_SECRET_KEY`: Stripe secret key for checkout creation.
- `STRIPE_WEBHOOK_SECRET`: Stripe endpoint signing secret for `/webhook`.

Required bindings:

- `LINKS`: Cloudflare KV namespace for sessions, links, purchases, rewards, and config.
- `DB`: Cloudflare D1 database for email inbox/admin data.
- `EMAIL`: Cloudflare email sending binding.

## Security Notes

- Rotate any webhook URL or token that was ever committed to Git.
- Keep package names and prices validated server-side in `cloudflare-worker.mjs`.
- Keep Stripe webhook fulfillment idempotent by checking processed event IDs before awarding perks.
- Do not add fallback production secrets to the Worker source.

## OneDrive deploy files (Cloudflare paste)

Canonical edit location on this machine:

```text
%USERPROFILE%\OneDrive\Lifepunch\Rules\
  Rules-V1.txt    — production paste (full worker)
  Rules-Test1.txt — sandbox (optional experiments)
  Rules-V2.txt    — layout comparison copy (regenerate from V1)
```

Repo mirror: `lifepunch/website/deployments/Rules/` and `cloudflare-worker.mjs`.

Sync scripts (`lifepunch/website/deployments/scripts/`):

- **Push** (repo worker → **Test1 only**): `sync-rules-from-onedrive.ps1 -Direction Push`
- **Pull** (OneDrive Test1 → repo worker): `sync-rules-from-onedrive.ps1 -Direction Pull`
- **Promote** (Test1 → **V1** production paste): `sync-rules-from-onedrive.ps1 -Direction Promote`

Active testing paste: `Rules-Test1.txt`. Production paste: `Rules-V1.txt` (only after Promote).
