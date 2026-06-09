# LifePunch — GitLab Organization

> How GitLab fits alongside the **GitHub monorepo** (June 2026+).
> Read after `AGENT_ONBOARDING.md`. If this disagrees with `.cursor/rules`, the rules win.

## Source of truth (non-negotiable)

**`https://github.com/mragerlp/lifepunch`** — the private **monorepo** on GitHub.

- Holds all lanes: `lifepunch/addons/`, `lifepunch/website/`, `lifepunch/server/`, `.cursor/rules`,
  `lifepunch/docs/`, everything.
- Primary PC checkout: `C:\Users\jared\Projects\lifepunchaddons`
- Git `origin` stays GitHub. Always `git pull --rebase` + `git push` to `origin`.
- Do **not** use OneDrive clones (removed June 2026 — git-corruption risk).

GitLab does **not** replace GitHub. It provides **per-lane project repos** so shottaWEB and the
RDP server agent work in focused workspaces without the full monorepo.

## Status (June 2026)

| Item | State |
|------|-------|
| GitHub canonical | `https://github.com/mragerlp/lifepunch` — **live**, `origin` on Primary PC |
| GitLab account | `gitlab.com/mragerlp` — Cursor integration connected |
| GitLab lane projects | **Not created yet** — create empty projects, then run `setup-gitlab-projects.ps1` |
| Lane sync | Owner exports lane slices from the GitHub monorepo → GitLab; partner lane commits
  land on GitLab first, then owner integrates back into the monorepo |

## GitLab lane projects (target layout)

Namespace: **`gitlab.com/mragerlp`**

| Project slug | URL | Monorepo paths | Primary agent |
|--------------|-----|----------------|---------------|
| `lifepunch-foundation` | `https://gitlab.com/mragerlp/lifepunch-foundation` | `.cursor/rules`, `lifepunch/docs`, `lifepunch/legal`, `scripts/`, `README.md` | All read; owner writes (via GitHub monorepo) |
| `lifepunch-addons` | `https://gitlab.com/mragerlp/lifepunch-addons` | `lifepunch/addons/**` | Owner |
| `lifepunch-website` | `https://gitlab.com/mragerlp/lifepunch-website` | `lifepunch/website/**` | **shottaWEB** |
| `lifepunch-rdp-server` | `https://gitlab.com/mragerlp/lifepunch-rdp-server` | `lifepunch/server`, `portal`, `gamemode`, `maps`, `admin-panel`, `economy`, `audit`, `players`, `discord`, `webhooks`, `API` | **RDP server agent** |

Machine-readable map: `lifepunch/docs/gitlab-projects.json`.

### Who clones what

| Agent | Clone for work | Canonical push target |
|-------|----------------|----------------------|
| **Owner** (Primary PC) | GitHub monorepo | `github.com/mragerlp/lifepunch` (`origin`) |
| **shottaWEB** | GitLab `lifepunch-website` (+ read `lifepunch-foundation` or GitHub monorepo for grounding) | GitLab `lifepunch-website`; owner merges into GitHub |
| **RDP server agent** | GitLab `lifepunch-rdp-server` (+ read foundation) | GitLab `lifepunch-rdp-server`; owner merges into GitHub |
| **Cornerman** | Read-only clone of GitHub monorepo or foundation | Never push |

### Lane rules

- **Commit only your lane** on whichever remote you push to.
- **Never force-push.** Single shared `main` per repo.
- Cross-lane or grounding changes (`docs/`, `.cursor/rules`) go through the **GitHub monorepo**
  on the owner's Primary PC, then re-export to GitLab via `setup-gitlab-projects.ps1`.
- **`lifepunch/secure/`** never goes to git — local only.

## Setup (owner checklist)

1. Create **four empty private GitLab projects** (no README init) with slugs above.
2. From the GitHub monorepo on Primary PC:

   ```powershell
   cd C:\Users\jared\Projects\lifepunchaddons
   .\lifepunch\scripts\setup-gitlab-projects.ps1 -GitLabNamespace mragerlp
   ```

3. Add GitLab remotes alongside GitHub (script adds `gitlab-<slug>` remotes; **do not** replace `origin`).
4. Set `migrationStatus` to `"lanes-synced"` in `gitlab-projects.json` when first push succeeds.
5. Hand agents their blocks from `lifepunch/docs/AGENT_PROMPT.md`.

## Cursor + GitLab

Cursor's GitLab account link helps with MR/CI context in the IDE. Git remotes are wired
separately — GitHub stays `origin`; GitLab is additional lane remotes.

## Related

- `lifepunch/docs/AGENT_PROMPT.md` — copy/paste per lane
- `lifepunch/docs/AGENT_ONBOARDING.md` — full foundation
