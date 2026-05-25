# Website Admin Panel

This folder documents the authenticated LifePunch website admin panel.

Observed URL:

```text
https://lifepunch.co/admin
```

Observed modules:

- Ban Management: manage website bans for users.
- Transactions: view and search store purchases.
- Reward Claims: manage and reset Discord reward claims.
- Email Inbox: view and manage login/auth emails.
- System Settings: manage automation tokens and global config.

Risk notes:

- This is separate from the DXRP portal admin panel tracked in `../../admin-panel`.
- `System Settings` is high risk because it may expose automation tokens or global configuration.
- `Transactions` and `Reward Claims` are high risk for donation/supporter fulfillment.
- `Email Inbox` may contain private login/auth data.

Operational rules:

- Do not store raw emails, transaction records, tokens, or private account data in Git.
- Use curated audit summaries for changes.
- Owner approval is required before changing system settings, automation tokens, purchase handling, or reward fulfillment behavior.
