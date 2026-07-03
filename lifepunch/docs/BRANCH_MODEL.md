# LIFEPUNCH™ — Branch model (GitHub monorepo)

**Status:** Active — July 2026  
**Repo:** `github.com/mragerlp/lifepunch`  
**Parallel:** DXRP fork uses the same **`main` + `develop`** mental model (`C:\Users\jared\Projects\dxrp` → `upstream` `dxura/dxrp`).

Read with: `GIT_CHECKPOINTS.md` · `DXRP_CONTRIBUTOR_LANE.md` · `PATH_CANON_VENGEANCE.md`

---

## Branches (two long-lived lines)

| Branch | Role | Who pulls | When to merge |
|--------|------|-----------|---------------|
| **`develop`** | Daily integration — agents, docs, scripts, active addon WIP | **VENGEANCE (Red)** every session; Mac optional | — |
| **`main`** | Ship-ready snapshot — handoff, GitLab export source, “Green is safe on this” | **Cornerman** distill mirror; Blue after Red export | Owner **GO** after lane milestone |

**Do not** use `lifepunch/main` or `lifepunch/develop` as branch names — use plain **`main`** and **`develop`**.

**Retired pattern:** long-lived `checkpoint-*` branches → replaced by **`develop`** + short-lived `lane/*` or `bitcoin/*` feature branches.

---

## Feature branches (short-lived)

Fork from **`develop`**, merge back to **`develop`** via PR or owner-approved merge.

| Prefix | Example | Use |
|--------|---------|-----|
| `bitcoin/*` | `bitcoin/ui-polish` | Active workstream (sole lane per ACTIVE_WORKSTREAM) |
| `lane/*` | `lane/ak47` | Scoped addon or asset lanes |
| `fix/*` | `fix/spawn-prefab` | Focused bugfix |
| `docs/*` | `docs/handoff-kit` | Large doc-only passes (GO DOCS) |

**Never** commit LifePunch proprietary work on `dxrp` fork branches — see `DXRP_CONTRIBUTOR_LANE.md`.

---

## Session workflow (Red)

```text
git fetch origin
git checkout develop
git pull --rebase origin develop

# work …

# daily checkpoint
git commit → push origin develop

# ship milestone (owner GO)
git checkout main && git pull --rebase origin main
git merge --ff-only origin/develop   # or PR develop → main on GitHub
git push origin main
git checkout develop
```

**Export law:** `Export-GitLabLane.ps1 -Slug lifepunch-rdp-server` runs from a **`main`** checkout (or immediately after merging develop → main).

---

## Pull law by machine

| Machine | Branch | Notes |
|---------|--------|-------|
| **VENGEANCE (Red)** | `develop` daily; `main` for export/tag | Source of truth writes |
| **MacBook (Green A)** | `develop` or `main` | Match whatever Red last pushed for the task |
| **Cornerman (Green B)** | `main` preferred for distill | Read-only deploy key; patch-handoff to Red |
| **lifepunchnet (Blue)** | GitLab `lifepunch-rdp-server` `main` | Server lane — not GitHub direct |

---

## Migration (July 2026)

- **`develop`** created at `3c69965` from former `checkpoint-lpbitcoin-pre-sleep-20260701` tip.
- **`main`** lags until next owner GO merge from `develop`.
- Open PRs targeting `checkpoint-*` should retarget **`develop`**.
- Stale **`copilot/*`** remote branches: safe to delete (merged, no unique commits).

---

## GitHub settings (recommended)

- **Default branch for new PRs:** `develop` (change in repo Settings → Branches when ready).
- **Branch protection (optional):** `main` — require PR + owner review; `develop` — allow agent pushes with hygiene hook.

---

## Quick agent paste

```text
BRANCH LAW: mragerlp/lifepunch
  develop = daily commits (pull --rebase here)
  main    = ship snapshot only (owner GO)
  feature = bitcoin/* or lane/* off develop
  dxrp fork = separate repo at C:\Users\jared\Projects\dxrp (develop upstream)
```
