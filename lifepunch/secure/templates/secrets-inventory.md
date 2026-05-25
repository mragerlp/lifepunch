# Secrets Inventory

Use this file as a template. Copy it to `secure/secrets-inventory.local.md` before adding real values or private notes.

## DXRP Portal

- Item:
- Stored in:
- Used by:
- Rotation notes:

## Discord

- Item: DXRP Mod Log webhook
- Stored in: `secure/*.local.env` as `DXRP_DISCORD_WEBHOOK_MOD_LOG`
- Used by: DXRP moderation actions, sanctions, bans, automated checks
- Rotation notes:

- Item: DXRP Media webhook
- Stored in: `secure/*.local.env` as `DXRP_DISCORD_WEBHOOK_MEDIA`
- Used by: DXRP screenshots and media uploads
- Rotation notes:

- Item: DXRP Chat Log webhook
- Stored in: `secure/*.local.env` as `DXRP_DISCORD_WEBHOOK_CHAT_LOG`
- Used by: DXRP server and chat log output
- Rotation notes:

## Website

- Item: Stripe secret key
- Stored in: `secure/*.local.env`
- Used by: Website store checkout and payment fulfillment
- Rotation notes:

- Item: Stripe webhook signing secret
- Stored in: `secure/*.local.env`
- Used by: Website store webhook verification
- Rotation notes:

- Item: Website store/admin automation token
- Stored in: `secure/*.local.env`
- Used by: Store fulfillment, reward claims, system settings
- Rotation notes:

## Cloudflare

- Item:
- Stored in:
- Used by:
- Rotation notes:

## Server Hosting

- Item:
- Stored in:
- Used by:
- Rotation notes:

## Webhooks / API Integrations

- Item:
- Stored in:
- Used by:
- Rotation notes:
