# Webhooks

This folder tracks webhook integration plans and routing.

Use it for documenting what emits events, where events go, and which LifePunch systems consume them.

Known DXRP Discord webhook categories:

- `Mod Log`
- `Media`
- `Chat Log`

Do not store raw webhook URLs here. Store local values in `../secure` using the tracked templates.

## GitHub Commit Logs

Repository commit notifications are sent by the GitHub Actions workflow at:

```text
.github/workflows/discord-commit-log.yml
```

Required GitHub Actions secret:

```text
DISCORD_COMMIT_WEBHOOK_URL
```

Create the secret in GitHub under `Settings -> Secrets and variables -> Actions -> New repository secret`.

Use the normal Discord webhook URL for this workflow. Do not append `/github`; the workflow sends a Discord-native JSON payload itself.

The workflow runs on pushes to `main` and `master`, and it can be tested manually from GitHub's `Actions -> Discord Commit Log -> Run workflow` button.

Future structure:

```text
webhooks/
  dxrp/
  discord/
  website/
  logs/
```

## Verification And Rank Sync

Potential webhook/event paths to review later:

- Website Steam login completed.
- Discord verification completed.
- `Members` rank assigned or removed.
- Store/supporter purchase completed.
- VIP/EVIP rank assigned or removed.
- Verification failure or stale account link.
- Discord account unlinked from website profile.
- Reward claim created, completed, reset, or failed.
- Weekend reward claim created, completed, or rejected.
- Monthly giveaway entry created or rejected.
- Monthly giveaway winner drawn.
- Store transaction created or refunded.
- Stripe checkout completed.
- Stripe checkout expired.
- Stripe payment failed.
- Stripe refund or dispute created.

Assume some routes may be outdated until confirmed. Record event names, source system, destination system, retry behavior, and owner-approved secrets location before changing anything.

Stripe webhook signing secrets belong in `../secure`, never in tracked docs.
