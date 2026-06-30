# LIFEPUNCH™ DXRP Workspace

This repository is the **canonical source of truth** for the **LIFEPUNCH™** community on DXRP (s&box).

**Canonical repo:** [github.com/mragerlp/lifepunch](https://github.com/mragerlp/lifepunch)  
**Community:** [discord.gg/lifepunch](https://discord.gg/lifepunch) · [lifepunch.co](https://lifepunch.co)

---

## Start here (agents)

1. **Sync:** `git fetch` · `git pull --rebase` (stop if behind + dirty).
2. **Domain map:** [`lifepunch/docs/REPO_DOMAIN_MAP.md`](lifepunch/docs/REPO_DOMAIN_MAP.md) — every folder → domain, GitLab lane, owner.
3. **Target layout:** [`lifepunch/docs/RESTRUCTURE_TARGET_LAYOUT.md`](lifepunch/docs/RESTRUCTURE_TARGET_LAYOUT.md) — end-state trees (business + lpbitcoin package).
4. **Restructure track:** [`lifepunch/docs/RESTRUCTURE_ROADMAP.md`](lifepunch/docs/RESTRUCTURE_ROADMAP.md) — phased plan (Phases 0–3 done).
5. **Config SoT:** [`lifepunch/docs/CONFIG_SOURCE_OF_TRUTH.md`](lifepunch/docs/CONFIG_SOURCE_OF_TRUTH.md) — which JSON is law.
6. **Quarantine index:** [`lifepunch/addons/_QUARANTINE_INDEX.md`](lifepunch/addons/_QUARANTINE_INDEX.md) — active vs frozen idents.
7. **Production gate:** [`lifepunch/addons/docs/ACTIVE_WORKSTREAM.md`](lifepunch/addons/docs/ACTIVE_WORKSTREAM.md) — product canon; implementation paused during restructure.
8. **Agent boot:** [`lifepunch/docs/AGENT_PROMPT.md`](lifepunch/docs/AGENT_PROMPT.md) Block 0

---

## Repo layout (two levels)

**GitHub monorepo root** — small on purpose:

```text
.cursor/          # Agent rules + hooks (foundation lane)
.vscode/          # Dev ergonomics (monorepo-only)
scripts/          # Workspace validation, GitLab export (foundation lane)
reference/        # Third-party study — never ship
lifepunch/        # All product, platform, business, tooling trees (see domain map)
README.md
```

**Everything operational lives under `lifepunch/`**, grouped by **domain**:

| Domain | Folders | GitLab lane (export) |
|--------|---------|----------------------|
| **PRODUCT** | `addons/`, `publish-lane/` (scaffold) | `lifepunch-addons` · publish → `lifepunch-published` repo |
| **PLATFORM** | `server/`, `gamemode/`, `portal/`, `admin-panel/`, `economy/`, `maps/`, `players/`, `audit/`, `discord/`, `webhooks/`, `API/` | `lifepunch-rdp-server` |
| **BUSINESS** | `website/`, `legal/`, `marketing/`, `branding/` | `lifepunch-website` · `lifepunch-foundation` (legal, marketing, branding) |
| **TOOLING** | `docs/`, `templates/`, `scripts/`, `config/`, `modeldoc-studio/`, `dxrp-overlays/` | `lifepunch-foundation` (docs, templates, config) · scripts/modeldoc/overlays monorepo-only |
| **LOCAL-ONLY** | `secure/` | Never exported |

Full table (every folder, primary agent, notes): **[`lifepunch/docs/REPO_DOMAIN_MAP.md`](lifepunch/docs/REPO_DOMAIN_MAP.md)**

---

## GitHub + GitLab + publish (one screen)

| Layer | Remote | Role |
|-------|--------|------|
| **Monorepo** | `github.com/mragerlp/lifepunch` | All WIP, law, quarantine — edit here on VENGEANCE |
| **GitLab lanes** | `gitlab.com/mragerlp/lifepunch-*` | Partner/agent focused exports — supplements GitHub |
| **Publish snapshot** | `github.com/mragerlp/lifepunch-published` | Portal-ready addons only — export from core |

Details: [`lifepunch/docs/GITLAB_ORGANIZATION.md`](lifepunch/docs/GITLAB_ORGANIZATION.md) · [`lifepunch/docs/PUBLISH_REPO_LANE.md`](lifepunch/docs/PUBLISH_REPO_LANE.md)

---

## Validate

From repo root:

```powershell
.\scripts\validate-workspace.ps1
```

Addon layout:

```powershell
cd .\lifepunch\addons
.\scripts\validate-layout.ps1
```
