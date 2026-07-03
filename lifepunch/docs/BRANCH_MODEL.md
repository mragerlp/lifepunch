# LIFEPUNCH™ — Branch model (GitHub monorepo)

**Status:** Active — July 2026  
**Repo:** `github.com/mragerlp/lifepunch`  
**Clone (VENGEANCE):** `C:\Users\jared\Projects\lifepunchdxrp` (junction `lifepunch` OK)  
**Parallel:** DXRP fork — same **`main` + `develop`** shape at `C:\Users\jared\Projects\dxrp`.

Read with: `GIT_CHECKPOINTS.md` · `DXRP_CONTRIBUTOR_LANE.md` · `PATH_CANON_VENGEANCE.md`  
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

**Never** commit LifePunch IP on the DXRP fork — see `DXRP_CONTRIBUTOR_LANE.md`.

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
| **Cornerman (Green B)** | **`main`** | Distill / mirror truth; patch-handoff to Red |
| **lifepunchnet (Blue)** | GitLab `lifepunch-rdp-server` **`main`** | Server lane — not GitHub direct |

---

## GitHub settings (recommended)

| Setting | Value |
|---------|--------|
| **Default branch** | **`develop`** |
| **Protect `main`** | Require PR or owner-only push; no force-push |
| **Protect `develop`** | Optional; allow agent pushes with commit hygiene hook |

---

## Pre-merge checklist (`develop` → `main`)

- [ ] Lane proof done (compile / flatgrass / owner test)
- [ ] No accidental asset deletes
- [ ] Docs/handoff updated if canon changed
- [ ] Bloodwave **GO** (`merge to main` / open PR)
- [ ] After merge: **`main` → `develop`** sync on Red

---

## Quick agent paste

```text
BRANCH LAW — mragerlp/lifepunch
  main    = TRUTH (never delete; Cornerman pulls this)
  develop = TEST (daily commits; default branch on GitHub)
  ship    = PR develop → main on owner GO, then merge main → develop
  clone   = C:\Users\jared\Projects\lifepunchdxrp
  dxrp    = separate repo C:\Users\jared\Projects\dxrp (develop upstream)
```
