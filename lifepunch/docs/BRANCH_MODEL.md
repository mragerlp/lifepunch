# LIFEPUNCH™ — Branch model (GitHub monorepo)

**Status:** Active — July 2026  
**Repo:** `github.com/mragerlp/lifepunch`  
**Clone (VENGEANCE):** `C:\Users\jared\Projects\lifepunch` (monorepo root; nested DXRP mirror = `lifepunchdxrp/`)  
**Parallel:** official DXRP upstream contributor clone at `C:\Users\jared\Projects\dxrp-public` (fork `mragerlp/dxrp-public` → `dxura/dxrp`, from `upstream/develop`; legacy `C:\Users\jared\Projects\dxrp` retired).

Start here: `START_HERE_AGENTS.md` · Read with: `GIT_CHECKPOINTS.md` · `DXRP_CONTRIBUTOR_LANE.md` · `PATH_CANON_VENGEANCE.md`  
**New-chat paste:** `handoff/NEW_CHAT_BRANCH_LAW_PASTE.txt`

---

## One sentence

**`main` is truth.** **`develop` is where we test.** When develop is clean and owner says GO → merge **`develop` → `main`**, then sync **`main` → `develop`**.

---

## Branches (two long-lived lines)

| Branch | Role | Who pulls | Merge when |
|--------|------|-----------|------------|
| **`main`** | **Source of truth** — stable, handoff, Cornerman distill, GitLab export | **Cornerman**, Blue after export, anyone needing canon | Owner **GO** only (via PR or approved merge from `develop`) |
| **`develop`** | **Test / integration** — agents commit, playtest, break safely | **VENGEANCE (Red)** every session; Mac for WIP | Merge to **`main`** when clean + owner GO |

**GitHub default branch:** **`develop`** (where daily work and new PRs land).  
**Never delete `main` or `develop`.**

**Do not** use `lifepunch/main` or `lifepunch/develop` as branch names — plain **`main`** and **`develop`** only.

**Retired:** long-lived `checkpoint-*` branches, `copilot/*` scratch branches.

---

## Feature branches (short-lived)

Fork from **`develop`**, merge back to **`develop`**.

| Prefix | Example | Use |
|--------|---------|-----|
| `bitcoin/*` | `bitcoin/ui-polish` | Active workstream |
| `lane/*` | `lane/ak47` | Scoped addon lanes |
| `fix/*` | `fix/spawn-prefab` | Focused bugfix |
| `docs/*` | `docs/handoff-kit` | GO DOCS / canon passes |

**Hotfix on production:** branch off **`main`** → fix → merge **`main`** → merge **`main` → `develop`**.

**Never** commit LifePunch IP on the DXRP fork. Private LIFEPUNCH work lives in `C:\Users\jared\Projects\lifepunch` on `develop`; official DXRP upstream PRs live only in `C:\Users\jared\Projects\dxrp-public` from `upstream/develop`. Never cross-contaminate IP, headers, paths, or assumptions — see `DXRP_CONTRIBUTOR_LANE.md`.

---

## Session workflow (Red)

```text
git fetch origin
git checkout develop
git pull --rebase origin develop

# work, test, commit …
git push origin develop

# ship (owner GO — develop must be clean)
# GitHub PR: develop → main   (preferred)
# or locally:
git checkout main && git pull origin main
git merge origin/develop
git push origin main

# sync test lane with truth (required after every main merge)
git checkout develop
git merge origin/main
git push origin develop
```

**Export law:** `Export-GitLabLane.ps1 -Slug lifepunch-rdp-server` from a **`main`** checkout only.

---

## Pull law by machine

| Machine | Branch | Notes |
|---------|--------|-------|
| **VENGEANCE (Red)** | **`develop`** daily | Writes; merge to **`main`** on GO |
| **MacBook (Green A)** | **`develop`** for WIP; **`main`** for stable read | Match task |
| **Cornerman (Green B)** | **`main`** (default) | Truth mirror / distill; may read **`develop`** only when the task targets active / `develop`-bound work; read-only / outbox unless Bloodwave opens patch-handoff to Red |
| **lifepunchnet (Blue)** | GitLab `lifepunch-rdp-server` **`main`** | Server lane — not GitHub direct |

---

## GitHub settings (July 2026 — applied)

| Setting | Value | Status |
|---------|--------|--------|
| **Default branch** | **`develop`** | ✓ Applied |
| **Protect `main`** | Ruleset · **Include by pattern `main`** · block deletion + force push · require PR (0 approvals) | ✓ Applied |
| **Protect `develop`** | Optional — not ruleset-protected (daily agent pushes) | Open |

**Ship to truth:** open PR **`develop` → `main`** on GitHub (direct push to `main` is blocked by ruleset).

---

## Pre-merge checklist (`develop` → `main`)

- [ ] **Base assertion** — the PR's ACTUAL base equals its intended destination (`gh pr view --json baseRefName`) before merge. For **stacked PRs**: record the intended final base in the PR body; merge the parent **WITH branch deletion** or explicitly **retarget the child**; **re-inspect the diff after retarget.** (Root cause of the #65 stranding — the checklist checked proof/deletions/GO but never the base.)
- [ ] Lane proof done (compile / flatgrass / owner test)
- [ ] No accidental asset deletes
- [ ] Docs/handoff updated if canon changed
- [ ] Bloodwave **GO** (`merge to main` / open PR)
- [ ] After merge: **`main` → `develop`** sync on Red

---

## Quick agent paste

```text
BRANCH LAW — mragerlp/lifepunch
  main          = TRUTH (never delete; Cornerman mirrors this)
  develop       = TEST/active (daily commits; default branch on GitHub)
  ship          = PR develop → main on owner GO (main ruleset: no direct push / no delete)
  clone         = C:\Users\jared\Projects\lifepunch   (monorepo root)
  lifepunchdxrp = nested private DXRP mirror inside the monorepo (server testing / flatgrass)
  dxrp-public   = SEPARATE official upstream clone C:\Users\jared\Projects\dxrp-public (from upstream/develop)
```
