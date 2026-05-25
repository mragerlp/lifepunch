# Admin Panel

This folder defines LifePunch staff roles, permission boundaries, and access review rules for the DXRP portal.

The goal is least privilege:

- Give staff enough access to do their job.
- Keep addon, gamemode, server, economy, and developer operations protected.
- Keep owner authority separate from visible in-game ranks.
- Keep every high-risk action auditable.

Roles covered:

- Owner
- Moderator
- Admin
- Super Admin
- Community Manager
- Developer

Owner note:

The LifePunch owner role is intentionally not modeled as a public staff role. The owner may use blank in-game rank display while retaining full authority outside normal staff templates.

Owner permission baseline:

- `roles/owner.md`
- `permissions/owner-rank.json`

Observed rank baselines:

- `permissions/owner-rank.json`
- `permissions/super-admin-rank.json`
- `permissions/community-manager-rank.json`
- `permissions/admin-rank.json`
- `permissions/moderator-rank.json`
- `permissions/developer-rank.json`

Start with `permissions/matrix.md`, then review each role in `roles/`.
