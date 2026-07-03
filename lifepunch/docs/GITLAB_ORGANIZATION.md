# LifePunch — GitLab Organization

> How GitLab fits alongside the **GitHub monorepo** (June 2026+).
> Read after `AGENT_ONBOARDING.md`. If this disagrees with `.cursor/rules`, the rules win.

## Source of truth (non-negotiable)

**`https://github.com/mragerlp/lifepunch`** — the private **monorepo** on GitHub.

- Holds all lanes: `lifepunch/addons/`, `lifepunch/website/`, `lifepunch/server/`, `.cursor/rules`,
  `lifepunch/docs/`, everything.
- Primary PC checkout: `C:\Users\jared\Projects\lifepunchdxrp`
- Git `origin` stays GitHub. Always `git pull --rebase` + `git push` to `origin`.
- Do **not** use OneDrive clones (removed June 2026 — git-corruption risk).

GitLab does **not** replace GitHub. It provides **per-lane project repos** so shottaWEB and the
RDP server agent work in focused workspaces without the full monorepo.

## Status (June 2026)

| Item | State |
|------|-------|
| GitHub canonical | `https://github.com/mragerlp/lifepunch` — **live**, `origin` on Primary PC |
| GitLab account | `gitlab.com/mragerlp` — Cursor integration connected |
| GitLab lane projects | **Live + synced** — all four created (private), seeded from the monorepo (`migrationStatus: lanes-synced`) |
| Branch protection | `lifepunch-website` + `lifepunch-rdp-server` `main`: **Developer push allowed, force-push BANNED**. `lifepunch-foundation` + `lifepunch-addons`: owner/Maintainer push only |
| shottaWEB access | Email-invited (`br.black4022@gmail.com`): **Developer** on `lifepunch-website`, **Reporter/read** on `lifepunch-foundation`. Pending: shottaWEB must create/sign in to a GitLab account on that email and accept |
| RDP agent access | Provisioned via an **SSH deploy key** generated on the box: public key added to `lifepunch-rdp-server` (**write enabled**) and the same key enabled on `lifepunch-foundation` (read). Only the **public** key leaves the box — no secret/token transfer. **Verified:** clone + grounding OK |
| Lane sync | Owner exports lane slices from the GitHub monorepo → GitLab; partner lane commits land on GitLab first, then owner integrates back into the monorepo |

## GitLab lane projects (target layout)

Namespace: **`gitlab.com/mragerlp`**

| Project slug | URL | Monorepo paths | Primary agent |
|--------------|-----|----------------|---------------|
| `lifepunch-foundation` | `https://gitlab.com/mragerlp/lifepunch-foundation` | `.cursor/rules`, `lifepunch/docs`, `lifepunch/legal`, `lifepunch/marketing`, `lifepunch/branding`, `lifepunch/config`, `lifepunch/templates`, `scripts/`, `README.md` | All read; owner writes (via GitHub monorepo) |
| `lifepunch-addons` | `https://gitlab.com/mragerlp/lifepunch-addons` | `lifepunch/addons/**` | Owner |
| `lifepunch-website` | `https://gitlab.com/mragerlp/lifepunch-website` | `lifepunch/website/**` | **shottaWEB** |
| `lifepunch-rdp-server` | `https://gitlab.com/mragerlp/lifepunch-rdp-server` | `lifepunch/server`, `portal`, `gamemode`, `maps`, `admin-panel`, `economy`, `audit`, `players`, `discord`, `webhooks`, `API` | **RDP server agent** |

**Red — `lifepunch-rdp-server` export hazard:** `Export-GitLabLane.ps1` **replaces entire
`monorepoPaths` trees** from the GitHub monorepo on every export. Any GitLab-only files under
`lifepunch/server/` (e.g. Official/Dev launcher scripts committed on-box at `aba788c`) are
**wiped** until one of:

1. **Port to GitHub** — merge Blue-only server scripts into the monorepo `lifepunch/server/`, then export; or
2. **Exclude paths** — change export mapping so Blue-only paths are not overwritten (not implemented today).

Until then, warn Blue after each `lifepunch-rdp-server` export if `lifepunch/server/dxrp-host/scripts/`
or launcher bats differ from monorepo. Blue keeps on-box `aba788c` launcher fixes unless export
intentionally changed server paths.

Known GitLab-only files removed by export `@463dc02` (2026-06-25): `DEV_ENGINE_ROLLBACK.md`,
`dxrp-host/development/tail_dev_server_log.bat`, `Pin-OfficialStableEngine.ps1`,
`Populate-DevEngine.ps1`, `Restore-OfficialStableEngine.ps1`, `Update-DevStagingEngine.ps1`.

**Git branch lane (not GitLab):** `lane/ak47` — quarantined AK viewmodel experiment. See
`lifepunch/docs/lanes/AK47_LANE.md`. **Never merge to `main` without owner sign-off.**

Machine-readable map: `lifepunch/docs/gitlab-projects.json`.

### Who clones what

| Agent | Clone for work | Canonical push target |
|-------|----------------|----------------------|
| **Owner** (Primary PC) | GitHub monorepo | `github.com/mragerlp/lifepunch` (`origin`) |
| **Owner — AK quarantine** | GitHub branch `lane/ak47` (same monorepo) | `lane/ak47` only for `**/ak47/**` — see `lanes/AK47_LANE.md` |
| **shottaWEB** | GitLab `lifepunch-website` (+ read `lifepunch-foundation` or GitHub monorepo for grounding) | GitLab `lifepunch-website`; owner merges into GitHub |
| **RDP server agent** | GitLab `lifepunch-rdp-server` (+ read foundation) | GitLab `lifepunch-rdp-server`; owner merges into GitHub |
| **Cornerman** | Read-only clone of GitHub monorepo or foundation | Never push |

### Self-grounding lanes (grounding bundle)

Every lane export injects a **synced mirror** of the grounding bundle so each clone is
self-contained and the rules auto-apply at the lane root — no separate foundation clone needed:

- Bundle (from `gitlab-projects.json` → `groundingBundle`): **`.cursor/rules`** + **`lifepunch/docs`**.
- It is injected into **all** lanes by `setup-gitlab-projects.ps1` (deduped — foundation already
  lists it, so it's a no-op there; addons/website/rdp-server get it added).
- It is **READ-ONLY mirror content**: agents must **not** edit `.cursor/rules` or `lifepunch/docs`
  inside a lane. Change grounding in the **GitHub monorepo**, then re-export (it regenerates).

### Lane rules

- **Commit only your lane** on whichever remote you push to.
- **Never force-push.** Single shared `main` per repo.
- Cross-lane or grounding changes (`docs/`, `.cursor/rules`) go through the **GitHub monorepo**
  on the owner's Primary PC, then re-export to GitLab via `setup-gitlab-projects.ps1`.
- **`lifepunch/secure/`** never goes to git — local only.

## Setup (owner checklist) — ✅ completed June 2026

> The four projects are created, synced, protected, and partner access is provisioned (see Status
> table). Steps kept for reference / re-running an export.

1. Create **four empty private GitLab projects** (no README init) with slugs above.
2. From the GitHub monorepo on Primary PC:

   ```powershell
   cd C:\Users\jared\Projects\lifepunchdxrp
   .\lifepunch\scripts\setup-gitlab-projects.ps1 -GitLabNamespace mragerlp
   ```

3. Add GitLab remotes alongside GitHub (script adds `gitlab-<slug>` remotes; **do not** replace `origin`).
4. Set `migrationStatus` to `"lanes-synced"` in `gitlab-projects.json` when first push succeeds.
5. Hand agents their blocks from `lifepunch/docs/AGENT_PROMPT.md`.

## Granting partner access (how it's wired)

- **People (e.g. shottaWEB)** → GitLab **user membership** by email invite. Developer on their write
  lane, Reporter (read) on `lifepunch-foundation`. They accept after creating/signing into a GitLab
  account on the invited email. (Invite API: `POST /projects/:id/invitations`.)
- **Headless agents (e.g. RDP server agent)** → an **SSH deploy key** generated ON the box
  (`~/.ssh/lifepunch_rdp`). Add the **public** key to the write lane (`lifepunch-rdp-server`) with
  **write access enabled**, and enable the same key on `lifepunch-foundation` (read-only). Only the
  public key ever leaves the box — the private key never moves, and no token/secret crosses chat or
  git ("0 leaky pipes"). Revoke the key in GitLab if the box is decommissioned or the key is exposed.
- **Branch protection** on writable lanes allows Developer push but **bans force-push**, enforcing the
  "normal push, never force-push" rule at the server.

## Cursor + GitLab

Cursor's GitLab account link helps with MR/CI context in the IDE. Git remotes are wired
separately — GitHub stays `origin`; GitLab is additional lane remotes.

## Related

- `lifepunch/docs/REPO_DOMAIN_MAP.md` — folder → domain → lane (foundation index)
- `lifepunch/docs/RESTRUCTURE_ROADMAP.md` — phased restructure track (owner pause on addon dev)
- `lifepunch/docs/AGENT_PROMPT.md` — copy/paste per lane
- `lifepunch/docs/AGENT_ONBOARDING.md` — full foundation
- `lifepunch/docs/OPS_CLARITY_CHECKPOINT.md` — voice web + shortcut tiers (June 2026 checkpoint)
- `lifepunch/docs/CI_CD_PLAN.md` — GitLab CI/CD plan (draft, not yet executed)
