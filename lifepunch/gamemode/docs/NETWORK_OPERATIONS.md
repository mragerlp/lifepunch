# LifePunch Network Operations

This document defines how LifePunch should handle DXRP portal operations while addon development is still being built into a reliable pipeline.

## Priorities

1. Protect the live community.
2. Keep addon packages and gamemode integration separate.
3. Test addons and beta features on `lifepunchdevelopment` before considering `lifepunchmainserver`.
4. Keep LifePunch credit attached to LifePunch work.
5. Stay within DXRP, S&box, Facepunch, and Steam rules.
6. Record high-risk changes before and after they happen.

## High-Risk Portal Actions

Do not perform these without explicit owner approval:

- Publish addon revision.
- Import/save gamemode.
- Pin addon revision.
- Sync or restart server.
- Edit staff permissions.
- Edit economy, inventory, or global balance systems.
- Change `lifepunchmainserver` server configuration.
- Add server launch scripts or hosting/security arguments before those details are intentionally provided.

## Change Flow

1. Draft the change in this repo.
2. Identify affected folder: `addons`, `gamemode`, `server`, `portal`, `admin-panel`, or `secure`.
3. Validate locally.
4. Test on `lifepunchdevelopment`.
5. Record portal steps and screenshots.
6. Get owner approval for high-risk actions.
7. Consider `lifepunchmainserver` only after `lifepunchdevelopment` works and the change is compatible with official DXRP-style limitations.

## Portal Evidence

Use `templates/portal-review.md` for tab inspections and screenshots. Do not store secrets, tokens, passwords, or private player data.

For DXRP Servers page changes, use `../server/SERVER_AUDIT_PROCEDURE.md` and `../../templates/server-change.md`.
