# Website Profile

This folder documents the authenticated LifePunch website profile page.

Observed URL:

```text
https://lifepunch.co/profile
```

Observed authenticated controls:

- `Panel`
- `Profile`
- `Logout`

Observed profile sections:

- Steam/profile card.
- Steam display name.
- SteamID64 display.
- Account creation date.
- Discord Integration.
- Referral Program.

Observed Discord Integration behavior:

- Linked Discord account is shown on the profile page.
- `Unlink` action is available.
- Discord identifiers should not be copied into public docs unless needed for an approved support/audit record.

Observed Referral Program fields:

- Total referrals.
- Earned credit.

Operational rules:

- Treat SteamID64 as the stable identity key.
- Treat Discord linking as a secondary identity link after Steam login.
- Do not store private Discord IDs, tokens, session data, or raw referral records in Git.
- Use this page as the starting point for future verification and account-linking audits.
