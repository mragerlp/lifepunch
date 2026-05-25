# Webhooks

This folder tracks webhook integration plans and routing.

Use it for documenting what emits events, where events go, and which LifePunch systems consume them.

Known DXRP Discord webhook categories:

- `Mod Log`
- `Media`
- `Chat Log`

Do not store raw webhook URLs here. Store local values in `../secure` using the tracked templates.

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
