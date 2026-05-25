# Players

This folder is for LifePunch player support operations.

Use it for player support procedures, privacy-safe review templates, escalation rules, and non-sensitive schemas related to the DXRP portal Players page.

Do not bulk-store player records, private identifiers, emails, IPs, sanctions evidence, or economy data here.

Future structure:

```text
players/
  ranks/
  support/
  privacy/
  reviews/
  templates/
```

Player-specific incidents should use `../templates/incident-report.md` and avoid unnecessary private data.

## Rank Baselines

Non-administrative rank baselines live in `ranks/`.

Supporter ranks such as `VIP` and `EVIP` are player/supporter records, not admin roles. They must not grant portal, moderation, server, economy, inventory, API key, or staff-permission access.

## Player Identity

DXRP player pages use SteamID64 values.

LifePunch website login enters the Steam sign-in flow, so SteamID64 should be treated as the stable identity key for future verification review.

URL pattern:

```text
https://dxrp.net/portal/players/<steamId64>
```

Owner reference:

```text
https://dxrp.net/portal/players/76561198103223564
```

The owner profile may intentionally show no visible owner rank. Do not use the visible server rank dropdown alone to determine owner authority.

## Verification Notes

The expected player verification path is:

1. Player logs into `lifepunch.co` through Steam.
2. Website captures or resolves SteamID64.
3. Player links/verifies Discord.
4. Verified player receives the `Members` rank.

This flow still needs backend/API/webhook confirmation before automation changes. Do not assume existing integrations are current; some API connections or webhooks may be outdated.

Observed LifePunch website profile fields:

- Steam display name.
- SteamID64.
- Account created date.
- Linked Discord account.
- Referral total.
- Earned credit.
- Discord `Unlink` action.

Website profile notes are tracked in `../website/profile/`.

## Observed Profile Fields

From the authenticated player profile screenshots:

- Avatar.
- Steam/display name.
- RP name.
- Balance, with edit icon.
- Level, with edit icon.
- Play Time.
- Staff Notes textarea.
- Staff Notes character counter, observed as `0/2000`.
- Inventory button.
- Rank dropdown.
- Joined timestamp.
- Last seen timestamp.
- SteamID64 display/copy/open actions.
- `Get Age` action.
- `Back` action.

## Observed Panels

Sanctions:

- Columns: `Issued`, `Type`, `Reason`, `Active`.
- `Show All` control.
- `Sanction` button.
- Total sanctions count.

Audit Log:

- Columns: `When`, `Action`, `Description`.
- Action filter dropdown.
- Refresh controls.
- Observed actions include `Death`, `Kill`, `Job`, `PocketPickup`, `ClearAllEntities`, `JobForce`, `Vote`, and `SetHealth`.

## Rank Display Notes

Visible server ranks can appear on player profiles, as seen with `Super Admin` on the `shotta` profile.

The owner profile is intentionally different: owner authority may be hidden or blank in the visible rank area.
