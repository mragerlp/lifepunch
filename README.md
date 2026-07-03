# LIFEPUNCHô DXRP Workspace

This repository is the **canonical source of truth** for the **LIFEPUNCHô** community on DXRP (s&box).

**Canonical repo:** [github.com/mragerlp/lifepunch](https://github.com/mragerlp/lifepunch)  
**Community:** [discord.gg/lifepunch](https://discord.gg/lifepunch) ∑ [lifepunch.co](https://lifepunch.co)

---

## Start here (agents)

> **Read `lifepunch/docs/START_HERE_AGENTS.md` first** - the thin router for every new session. Then the one-paste `lifepunch/docs/CVL_AGENT_ONBOARDING.md`, your machine paste in `lifepunch/docs/handoff/AGENT_GROUNDING_INDEX.md`, and the law: `lifepunch/docs/BRANCH_MODEL.md`, `lifepunch/docs/LIFEPUNCH_REPO_LAYOUT.md`, `lifepunch/docs/MACHINE_CAST.md`, `.cursor/rules/`.
>
> **Two lanes (never mix):** private LIFEPUNCH work in `C:\Users\jared\Projects\lifepunch` on `develop`; official DXRP upstream PRs in the separate `C:\Users\jared\Projects\dxrp-public` - see `lifepunch/docs/DXRP_CONTRIBUTOR_LANE.md`.

1. **Sync:** `git fetch` ∑ `git pull --rebase` (stop if behind + dirty).
2. **Domain map:** [`lifepunch/docs/REPO_DOMAIN_MAP.md`](lifepunch/docs/REPO_DOMAIN_MAP.md) ó every folder ? domain, GitLab lane, owner.
3. **Target layout:** [`lifepunch/docs/RESTRUCTURE_TARGET_LAYOUT.md`](lifepunch/docs/RESTRUCTURE_TARGET_LAYOUT.md) ó end-state trees (business + lpbitcoin package).
4. **Restructure track:** [`lifepunch/docs/RESTRUCTURE_ROADMAP.md`](lifepunch/docs/RESTRUCTURE_ROADMAP.md) ó phased plan (Phases 0ñ3 done).
5. **Config SoT:** [`lifepunch/docs/CONFIG_SOURCE_OF_TRUTH.md`](lifepunch/docs/CONFIG_SOURCE_OF_TRUTH.md) ó which JSON is law.
6. **Quarantine index:** [`lifepunchaddons/_QUARANTINE_INDEX.md`](lifepunchaddons/_QUARANTINE_INDEX.md) ó active vs frozen idents.
7. **Production gate:** [`lifepunchaddons/docs/ACTIVE_WORKSTREAM.md`](lifepunchaddons/docs/ACTIVE_WORKSTREAM.md) ó product canon; active lane = lpbitcoin (route via the active-workstream gate rule).
8. **Agent boot:** [`lifepunch/docs/AGENT_PROMPT.md`](lifepunch/docs/AGENT_PROMPT.md) Block 0

---

## Repo layout (two levels)

**GitHub monorepo root** ó small on purpose:

```text
.cursor/          # Agent rules + hooks (foundation lane)
.vscode/          # Dev ergonomics (monorepo-only)
scripts/          # Workspace validation, GitLab export (foundation lane)
reference/        # Third-party study ó never ship
lifepunch/        # Ops ù platform, business, tooling (see domain map)
lifepunchaddons/  # Product ù s&box addon packages (lpbitcoin, ù)
lifepunchdxrp/    # Nested DXRP fork (separate git root; local playtest mount)
README.md
```

**Ops and platform** live under **`lifepunch/`**; **addon product** lives in **`lifepunchaddons/`** at repo root (see `lifepunch/docs/LIFEPUNCH_REPO_LAYOUT.md`).

| Domain | Folders | GitLab lane (export) |
|--------|---------|----------------------|
| **PRODUCT** | `lifepunchaddons/`, `lifepunch/publish-lane/` (scaffold) | `lifepunch-addons` ∑ publish ? `lifepunch-published` repo |
| **PLATFORM** | `server/`, `gamemode/`, `portal/`, `admin-panel/`, `economy/`, `maps/`, `players/`, `audit/`, `discord/`, `webhooks/`, `API/` | `lifepunch-rdp-server` |
| **BUSINESS** | `website/`, `legal/`, `marketing/`, `branding/` | `lifepunch-website` ∑ `lifepunch-foundation` (legal, marketing, branding) |
| **TOOLING** | `docs/`, `templates/`, `scripts/`, `config/`, `modeldoc-studio/`, `dxrp-overlays/` | `lifepunch-foundation` (docs, templates, config) ∑ scripts/modeldoc/overlays monorepo-only |
| **LOCAL-ONLY** | `secure/` | Never exported |

Full table (every folder, primary agent, notes): **[`lifepunch/docs/REPO_DOMAIN_MAP.md`](lifepunch/docs/REPO_DOMAIN_MAP.md)**

---

## GitHub + GitLab + publish (one screen)

| Layer | Remote | Role |
|-------|--------|------|
| **Monorepo** | `github.com/mragerlp/lifepunch` | All WIP, law, quarantine ó edit here on VENGEANCE |
| **GitLab lanes** | `gitlab.com/mragerlp/lifepunch-*` | Partner/agent focused exports ó supplements GitHub |
| **Publish snapshot** | `github.com/mragerlp/lifepunch-published` | Portal-ready addons only ó export from core |

Details: [`lifepunch/docs/GITLAB_ORGANIZATION.md`](lifepunch/docs/GITLAB_ORGANIZATION.md) ∑ [`lifepunch/docs/PUBLISH_REPO_LANE.md`](lifepunch/docs/PUBLISH_REPO_LANE.md)

---

## Validate

From repo root:

```powershell
.\scripts\validate-workspace.ps1
```

Addon layout:

```powershell
cd .\lifepunchaddons
.\scripts\validate-layout.ps1
```
