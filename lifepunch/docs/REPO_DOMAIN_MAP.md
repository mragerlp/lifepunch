# LIFEPUNCH™ — Repo domain map

**Status:** Foundation index (Phase 0 — docs only).  
**Updated:** 2026-06-30  
**Read with:** `GITLAB_ORGANIZATION.md` · `PUBLISH_REPO_LANE.md` · `gitlab-projects.json`

This document answers: *where does this folder live, who owns edits, and which GitLab lane exports it?*

---

## Three layers (do not collapse)

| Layer | Git remote | Role |
|-------|------------|------|
| **GitHub monorepo** | `github.com/mragerlp/lifepunch` | **Single source of truth** — all domains, all WIP, all law |
| **GitLab lane exports** | `gitlab.com/mragerlp/lifepunch-*` | Focused working copies for partners/agents — **not** a replacement for GitHub |
| **Publish snapshot** | `github.com/mragerlp/lifepunch-published` | Portal-ready addon tree only — export from core, never invent law here |

**Law:** Edit on GitHub (VENGEANCE). Re-export GitLab lanes after cross-lane or grounding changes. See `Export-GitLabLane.ps1` / `setup-gitlab-projects.ps1`.

---

## Domains

| Domain | What it is | Typical editor |
|--------|------------|----------------|
| **PRODUCT** | Shippable DXRP addon source, staging, publish scaffolding | Owner (Cursor) |
| **PLATFORM** | Hosted DXRP ops — gamemode, servers, portal, staff, economy, integrations | RDP server agent · owner |
| **BUSINESS** | Brand, legal, site, marketing — not s&box gameplay | Owner · shottaWEB (website) |
| **TOOLING** | Docs, scripts, MCP config, ModelDoc studio, dev overlays | Owner |
| **LOCAL-ONLY** | Secrets and machine-local material — never export | Owner only |

---

## Repo root (outside `lifepunch/`)

| Path | Domain | GitLab lane | Notes |
|------|--------|-------------|-------|
| `.cursor/` | TOOLING | `lifepunch-foundation` | Rules + hooks — **grounding bundle**; edit in monorepo only |
| `.vscode/` | TOOLING | — (monorepo-only) | Dev ergonomics; not in GitLab export today |
| `.cornerman-patches/` | TOOLING | — (monorepo-only) | Patch-handoff artifacts for read-only Cornerman clone |
| `scripts/` | TOOLING | `lifepunch-foundation` | Repo-root validators, GitLab export, workspace scripts |
| `reference/` | — | — | Third-party study material — **never ship**; not LifePunch IP |
| `lifepunch/` | (see below) | (per folder) | All product/platform/business/tooling trees |
| `README.md` | TOOLING | `lifepunch-foundation` | Entry point — points here |

---

## `lifepunch/*` — complete folder index

### PRODUCT

| Folder | GitLab lane | Primary agent | Purpose |
|--------|-------------|---------------|---------|
| `lifepunch/addons/` | `lifepunch-addons` | Owner | s&box addon project — Code, Assets, config, docs. **Active ship:** `adminmenu`, `bitcoinmining` / `lpbitcoin` staging. Quarantine law: `addons/config/portfolio.json`, `addons/docs/QUARANTINE_REGISTER.md`. |
| `lifepunch/publish-lane/` | — (monorepo-only) | Owner | **Pointer/scaffold** for the external publish repo — not the live publish tree. Canonical export: `lifepunch-published` per `PUBLISH_REPO_LANE.md`. Contains scaffold README + sample `addons.json` only. |

**External PRODUCT repo (not a folder here):** `mragerlp/lifepunch-published` — populated by `Export-LifepunchPublishLane.ps1`, not by editing `publish-lane/` as source of truth.

---

### PLATFORM

All rows export to **`lifepunch-rdp-server`** unless noted. Primary agent: **RDP server agent** (lifepunchnet); owner integrates via GitHub monorepo.

| Folder | Purpose |
|--------|---------|
| `lifepunch/admin-panel/` | Staff hierarchy, roles, permission policy |
| `lifepunch/API/` | API contracts, schemas, non-secret integration notes |
| `lifepunch/audit/` | Portal/staff/admin accountability workflows |
| `lifepunch/discord/` | Discord community ops and bot planning |
| `lifepunch/economy/` | Economy, inventory, market, money-flow policy |
| `lifepunch/gamemode/` | Gamemode exports/imports, addon revision pins, equipment/market rows |
| `lifepunch/maps/` | Mapping plans, source refs, future S&box map workflow |
| `lifepunch/players/` | Player support procedures (privacy-safe) |
| `lifepunch/portal/` | DXRP.net portal tab documentation |
| `lifepunch/server/` | `lifepunchmainserver` / `lifepunchdevelopment` records, dxrp-host, observability |
| `lifepunch/webhooks/` | Webhook routes and integration docs |

**Export hazard:** `Export-GitLabLane.ps1` **replaces** entire PLATFORM paths from GitHub. GitLab-only files under `lifepunch/server/` are wiped on export until ported to monorepo — see `GITLAB_ORGANIZATION.md`.

---

### BUSINESS

| Folder | GitLab lane | Primary agent | Purpose |
|--------|-------------|---------------|---------|
| `lifepunch/website/` | `lifepunch-website` | **shottaWEB** (owner integrates) | lifepunch.co — Cloudflare worker, rules mirrors, deployments |
| `lifepunch/legal/` | `lifepunch-foundation` | Owner | Trademark, IP doctrine, specimens, filing runbooks — no secrets in git |
| `lifepunch/marketing/` | — (monorepo-only)* | Owner | YouTube/social copy templates, release tags — **assigned BUSINESS Phase 0** |
| `lifepunch/branding/` | — (monorepo-only)* | Owner | Ops console assets, shortcut icons, UNIFORM_STANDARDS mirror — **assigned BUSINESS Phase 0** |

\* *Not in `gitlab-projects.json` export paths today. Canonical edits on GitHub; add to foundation or website export in a future Phase 1 if partner lanes need them.*

---

### TOOLING

| Folder | GitLab lane | Primary agent | Purpose |
|--------|-------------|---------------|---------|
| `lifepunch/docs/` | `lifepunch-foundation` | Owner | Onboarding, CVL, MCP, handoff, business context — **grounding bundle** |
| `lifepunch/templates/` | `lifepunch-foundation` | Owner | Operational templates |
| `lifepunch/scripts/` | — (monorepo-only)* | Owner | VENGEANCE automation — s&box boot, GitLab export, Cornerman, publish prep |
| `lifepunch/config/` | — (monorepo-only)* | Owner | Machine pins — MCP ports, CVL stack, Cornerman models, DXRP upstream pin |
| `lifepunch/modeldoc-studio/` | — (monorepo-only)* | Owner | Standalone ModelDoc s&box project (`lifepunch.modeldoc`) — mesh P0 without full DXRP gamemode |
| `lifepunch/dxrp-overlays/` | — (monorepo-only)* | Owner | Local DXRP dev overlays (MCP autostart, dev API hooks) — not upstream DXRP |

\* *Monorepo-only until explicitly added to a GitLab `monorepoPaths` list.*

**Root `scripts/` vs `lifepunch/scripts/`:** Root `scripts/` = workspace-wide validation and GitLab tooling (foundation export). `lifepunch/scripts/` = LifePunch product/ops automation (VENGEANCE-heavy).

---

### LOCAL-ONLY

| Folder | GitLab lane | Purpose |
|--------|-------------|---------|
| `lifepunch/secure/` | **Never exported** | Sensitive templates and local-only material — see `.gitignore`. Do not commit secrets. |

---

## GitLab lane quick reference

| GitLab project | Monorepo paths (export) | Write access |
|----------------|-------------------------|--------------|
| `lifepunch-foundation` | `.cursor/rules`, `.cursor/hooks*`, `lifepunch/docs`, `lifepunch/legal`, `lifepunch/templates`, `scripts/`, `README.md` | Owner |
| `lifepunch-addons` | `lifepunch/addons/**` | Owner |
| `lifepunch-website` | `lifepunch/website/**` | shottaWEB + owner |
| `lifepunch-rdp-server` | PLATFORM folders listed above | RDP agent + owner |

**Grounding bundle** (injected into every lane): `.cursor/rules`, `.cursor/hooks*`, `lifepunch/docs` — read-only mirror inside lane clones.

Machine-readable: `lifepunch/docs/gitlab-projects.json`.

---

## Git branch lanes (not GitLab)

| Branch | Scope | Law |
|--------|-------|-----|
| `lane/ak47` | `lifepunch/addons/**/ak47/**` + AK scripts | Quarantined FP experiment — never merge to `main` without owner sign-off. `lifepunch/docs/lanes/AK47_LANE.md`. |

---

## Separate repos (not under `lifepunch/`)

| Repo | Domain | Relationship to monorepo |
|------|--------|---------------------------|
| `mragerlp/lifepunch` | All | **Canonical** — this checkout |
| `mragerlp/lifepunch-published` | PRODUCT (ship) | Export snapshot — `PUBLISH_REPO_LANE.md` |
| `mragerlp/dxrp-public` | Upstream contrib | DXRP bounty/PR lane — vanilla, no LP headers — `DXRP_CONTRIBUTOR_LANE.md` |
| `gitlab.com/mragerlp/lifepunch-*` | Per lane | Export targets — `GITLAB_ORGANIZATION.md` |

**Runtime (never commit):** `D:\Steam\steamapps\common\sbox\dxrp` — local DXRP install synced by owner scripts.

---

## Agent decision tree

```text
Touching s&box addon code/assets?
  → PRODUCT · lifepunch/addons · check ACTIVE_WORKSTREAM + portfolio.json first

Touching server/gamemode/portal/staff?
  → PLATFORM · lifepunch-rdp-server lane · integrate via GitHub

Touching lifepunch.co / trademark / marketing copy?
  → BUSINESS · website or legal lane · rules OneDrive SoT for Cloudflare rules

Touching MCP scripts, ModelDoc, docs, export tooling?
  → TOOLING · foundation or monorepo-only paths

Portal-ready upload only?
  → lifepunch-published export — NOT publish-lane/ as live source

Unsure?
  → Read this file + GITLAB_ORGANIZATION.md · ask Bloodwave before cross-domain moves
```

---

## Phase 0 scope (this document)

- **Done:** Every `lifepunch/*` top-level folder has domain + lane assignment.
- **Not done yet (future phases):** Physical folder moves, new GitHub repos, adding monorepo-only paths to GitLab export, per-addon `.sbproj` split.

When restructuring begins, use one slice per session and re-validate against `scripts/validate-workspace.ps1`.

---

## Related

- `WORKSPACE_STRUCTURE.md` — original folder responsibilities (historical; this map supersedes for lane ownership)
- `AGENT_PROMPT.md` Block 0 — agent boot read order
- `AGENT_ONBOARDING.md` — full foundation
