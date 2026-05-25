# Network Settings

This folder documents the DXRP portal Network settings page for LifePunch.

Observed page:

- Header: `Settings`
- Subtitle: `Configure your experience`
- Tabs:
  - `Network`
  - `API Keys`

## Network Fields

Observed editable fields:

- Network Name: `LifePunch`
- Network Identifier: `lifepunch`

Note from portal:

```text
Requires relog to appear everywhere.
```

## Discord Webhooks

Observed webhook categories:

- `Mod Log`
  - Purpose shown in portal: moderation actions, sanctions, bans, automated checks.
- `Media`
  - Purpose shown in portal: screenshots and media uploads.
- `Chat Log`
  - Purpose shown in portal: server and chat log output.

The portal displays Discord webhook URLs, but raw webhook URLs should live only in local secure files, not tracked docs/config.

Use `../../secure/templates/local-env.example` as the tracked template and copy it into a `.local.env` file before adding real values.

## Actions

Observed action:

- `Save Changes`

Operational rule:

- Do not click `Save Changes` without explicit owner approval.
- Any change to network name, identifier, or webhook URLs should be recorded with a change request.

## Confirmation Still Needed

- API Keys tab fields.
- Whether webhook fields accept blank values.
- Whether changing webhooks takes effect immediately or after relog/restart.
- Whether network identifier changes affect URLs, API routing, or server linkage.
