# Secure Local Information

This folder is for local LifePunch secrets and sensitive operational details.

Real secret files in this folder are ignored by git. Keep templates and documentation tracked, but do not commit live tokens, passwords, private keys, webhook secrets, API keys, or server credentials unless you intentionally change the security model later.

Recommended local files:

```text
secure/
  dxrp.portal.local.env
  website.local.env
  discord.local.env
  cloudflare.local.env
  server-hosting.local.env
  notes.local.md

On lifepunchnet install root (not in monorepo git) — single folder `C:\S&BOX DXRP Server\`:
  C:\S&BOX DXRP Server\secure\official.local.env
  C:\S&BOX DXRP Server\secure\development.local.env
  Templates: secure/templates/official.local.env.example
```

Use `templates/secrets-inventory.md` to document what exists and where it is used without exposing the raw values in normal docs.

Rules:

- Prefer `.local.env` for real values.
- Never paste secrets into public docs.
- Redact values in screenshots unless the exact value is required for the current task.
- If a value is needed by code later, wire it through environment variables or a secrets manager instead of hardcoding it.
