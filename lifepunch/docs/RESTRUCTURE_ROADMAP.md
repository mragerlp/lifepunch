# LIFEPUNCH™ — Monorepo restructure roadmap

**Status:** Active owner track (June 2026).  
**Updated:** 2026-06-30  
**Read with:** `REPO_DOMAIN_MAP.md` · `GITLAB_ORGANIZATION.md` · `PACKAGE_NAMING_STANDARD.md`

---

## Owner directive

**Bloodwave (June 2026):** Pause addon **implementation** (Hub H4/H5, new features) until monorepo structure is trustworthy. **Restructure track is active** until Phase 2 sign-off below.

This does **not** change product canon (Bitcoin three-surface, quarantine law, publish doctrine). It changes **session priority**: agents do foundation/restructure slices before hub code.

When restructure is signed off, resume from `ACTIVE_WORKSTREAM.md` and `OWNER_PROGRESS_TRACKER.txt` without re-litigating folder law.

---

## What we are fixing

| Problem | Fix (not mass GitHub repo split) |
|---------|----------------------------------|
| Orphan folders (`marketing/`, `branding/`, `config/`, …) | Map + GitLab export alignment |
| Agents guess “who owns this?” | `REPO_DOMAIN_MAP.md` + this roadmap |
| Quarantined addons mixed with active | Visibility + compile gate (already) → optional physical separation later |
| `repoIdent` vs `packageSlug` path drift | Per-package migration after foundation stable |
| One monolithic `addons.sbproj` | Per-package projects **after** path migration + ship proof |

**Law preserved:** GitHub monorepo = canonical · GitLab = lane exports · `lifepunch-published` = ship snapshot.

---

## Phase summary

| Phase | Name | Moves code/assets? | Owner sign-off |
|-------|------|--------------------|----------------|
| **0** | Domain map | No | ✅ Done (`1343abc`) |
| **1** | Export & canon alignment | No | Required before Phase 2 |
| **2** | Quarantine visibility | Optional small moves | Required before Phase 4 |
| **3** | Config source-of-truth matrix | No | — |
| **4** | Addon path migration | Yes (`git mv`, one package) | Per package |
| **5** | Tooling lane export | Optional | — |
| **6** | Per-addon s&box projects | Yes (project files) | After Phase 4 + flatgrass |

**Rule:** One slice per session · `git mv` not delete+recreate · run validators after each slice · propose commit; owner approves.

---

## Phase 0 — Domain map ✅

- [x] `lifepunch/docs/REPO_DOMAIN_MAP.md`
- [x] Root `README.md` domain table + boot order

---

## Phase 1 — Export & canon alignment (in progress)

**Goal:** GitLab lane exports match documented domains. No folder moves.

### Phase 1a — Foundation export paths ✅ (this commit)

Add to `lifepunch-foundation` export (`gitlab-projects.json`):

- `lifepunch/marketing/` — BUSINESS (YouTube/social templates)
- `lifepunch/branding/` — BUSINESS (ops assets, UNIFORM_STANDARDS mirror)
- `lifepunch/config/` — TOOLING (MCP ports, CVL pins, Cornerman models)

Update: `GITLAB_ORGANIZATION.md`, `REPO_DOMAIN_MAP.md`, this file.

**After push (owner on VENGEANCE):**

```powershell
cd C:\Users\jared\Projects\lifepunchaddons
.\lifepunch\scripts\setup-gitlab-projects.ps1 -GitLabNamespace mragerlp
# or: .\lifepunch\scripts\Export-GitLabLane.ps1 -Slug lifepunch-foundation
```

### Phase 1b — Boot path consolidation (next slice)

- [ ] `AGENT_PROMPT.md` Block 0: add `REPO_DOMAIN_MAP.md` + `RESTRUCTURE_ROADMAP.md` to read order
- [ ] `GITLAB_ORGANIZATION.md` → link `REPO_DOMAIN_MAP.md` in Related
- [ ] `WORKSPACE_STRUCTURE.md` banner: superseded by domain map for lane ownership

### Phase 1c — Monorepo-only tooling (decision slice)

Decide export vs stay mono-only:

| Path | Recommendation |
|------|----------------|
| `lifepunch/scripts/` | Stay monorepo-only (VENGEANCE-heavy; large) |
| `lifepunch/modeldoc-studio/` | Stay monorepo-only until Phase 6 |
| `lifepunch/dxrp-overlays/` | Stay monorepo-only (local DXRP dev) |
| `lifepunch/publish-lane/` | Stay mono scaffold; live ship = `lifepunch-published` |

Document decision in `REPO_DOMAIN_MAP.md` — no moves.

**Phase 1 done when:** 1a–1c checked · GitLab foundation re-exported · owner OK.

---

## Phase 2 — Quarantine visibility

**Goal:** Active vs frozen addons obvious in tree and docs. **Do not** block on mass `git mv`.

### Phase 2a — Docs + index (no moves)

- [ ] `lifepunch/addons/_QUARANTINE_INDEX.md` — links to `portfolio.json` + `QUARANTINE_REGISTER.md` + list of frozen idents
- [ ] Root of each quarantined ident: optional one-line `QUARANTINED.md` stub (only if owner GO — many files)

### Phase 2b — Physical separation (optional, one ident pilot)

- [ ] Pilot: move **one** quarantined ident to `lifepunch/addons/_quarantined/{ident}/` using `git mv`
- [ ] Update `addons.csproj` Remove paths + validators + docs
- [ ] **Do not** move active `adminmenu` / `bitcoinmining` / `lpbitcoin` in this phase

**Phase 2 done when:** Agent cannot miss quarantine status · compile gate unchanged or improved · owner OK.

---

## Phase 3 — Config source-of-truth matrix

**Goal:** One doc answers “which config file is law?”

- [ ] `lifepunch/docs/CONFIG_SOURCE_OF_TRUTH.md`

| Domain | Canonical path | Notes |
|--------|----------------|-------|
| Addon registry | `lifepunch/addons/config/addons.json` | Portal titles, ownership |
| Package slugs | `lifepunch/addons/config/packages.json` | packageSlug vs repoIdent |
| Portfolio / quarantine | `lifepunch/addons/config/portfolio.json` | active vs frozen |
| MCP / CVL machine | `lifepunch/config/` | Ports, pins |
| GitLab lanes | `lifepunch/docs/gitlab-projects.json` | Export paths |
| Website auth/store | `lifepunch/website/config/` | shottaWEB lane |

No file moves unless a duplicate is proven harmful.

---

## Phase 4 — Addon path migration (one package per slice)

**Goal:** Align folders with `PACKAGE_NAMING_STANDARD.md` (`packageSlug` / entity slugs).

**Order (owner law):**

1. `lifepunchbitcoin` / `lpbitcoin` — **last** among products (active dev tree; highest risk)
2. `lifepunchulx` / `adminmenu` — after bitcoin path stable or in parallel only if isolated
3. Quarantined packages — only on **promotion**, not during quarantine

Each slice:

- Plan: all refs (`addons.json`, csproj, publish scripts, sync scripts, docs)
- `git mv` only
- `validate-layout.ps1` + `validate-workspace.ps1`
- Flatgrass proof if active ident touched

---

## Phase 5 — Tooling export (optional)

If partners need ModelDoc or overlays on lane clones — add to `gitlab-projects.json` or document permanent monorepo-only status.

---

## Phase 6 — Per-addon s&box projects (post-ship)

Separate `.sbproj` per publishable package. **Not** before Phase 4 for that package.

Reference: `lifepunch/modeldoc-studio/game/modeldoc.sbproj` pattern.

---

## Validators (every slice)

```powershell
.\scripts\validate-workspace.ps1
cd .\lifepunch\addons; .\scripts\validate-layout.ps1
```

---

## Explicitly out of scope

- Splitting `website/`, `legal/`, `marketing/` into **new GitHub repos** (GitLab lanes + monorepo canon stay)
- Deleting quarantined code
- Touching `reference/` third-party study trees
- Upstream DXRP changes in this track (see `DXRP_CONTRIBUTOR_LANE.md`)
- Hub H4/H5 implementation until **restructure sign-off** or explicit owner unpause

---

## Resume dev checklist

When Bloodwave signs restructure complete:

- [ ] Phase 1 + 2 owner sign-off recorded (commit message or tracker note)
- [ ] `CURSOR_NEW_CHAT_BOOTSTRAP_PASTE.txt` still accurate
- [ ] GitLab lanes re-exported after final Phase 1 paths
- [ ] Return to `ACTIVE_WORKSTREAM.md` — next slice H4/H5 or tracker item

---

## Related

- `REPO_DOMAIN_MAP.md` — folder → domain → lane
- `GITLAB_ORGANIZATION.md` — export mechanics
- `PUBLISH_REPO_LANE.md` — core vs lifepunch-published
- `BACKLOG_PARKING_LOT.md` — product ideas deferred during restructure
