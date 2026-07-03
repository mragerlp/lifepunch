# LIFEPUNCH™ — Worktree Lane Safety

**Status:** Active — July 2026
**Applies to:** every agent / session that can **write** to `C:\Users\jared\Projects\lifepunch`
**Read with:** `START_HERE_AGENTS.md` · `BRANCH_MODEL.md` · `DXRP_CONTRIBUTOR_LANE.md`

> **Why this exists (incident 2026‑07‑03):** a second lane restored older snapshots into the shared
> `lifepunch` worktree. It **discarded another lane's uncommitted work** *and* **reverted already‑committed
> P0 canon** (the `START_HERE_AGENTS.md` pointer, `lifepunchaddons/docs/` path normalization, and
> `BRANCH_MODEL.md` clone paths). Recovery cost a full diagnostic pass plus `git checkout HEAD -- …` and a
> re‑apply (fix shipped as `1a6bec0`). This guard exists so it never happens again.

---

## Law — one writable agent per worktree

Only **one** writable agent/session may hold uncommitted work in a given worktree at a time. Parallel
**writable** lanes use a **separate worktree or clone** (§5). Read‑only agents (Green distill, review) may
share a worktree **only** if they never modify files.

---

## 1. Lane‑switch preflight (mandatory)

Before starting a lane, switching lanes, or letting another writable agent into the repo:

```powershell
cd C:\Users\jared\Projects\lifepunch
git status -sb
git diff --name-status
```

Then **identify which lane owns any dirty files.** If the tree is dirty and the changes are **not your
lane**, STOP — do not edit, restore, or commit. Resolve ownership first (§3).

---

## 2. Never clobber another lane

While another lane owns uncommitted work in this worktree, **do not** run:

- `git restore` / `git checkout -- <path>`
- `git reset` (any mode)
- `git clean`
- sync / regeneration / install scripts that rewrite shared paths

These are exactly what caused the 2026‑07‑03 canon reversion.

---

## 3. Dirty files must be resolved — pick one

Before a lane switch, every dirty file must be **one** of:

1. **Committed** — with Bloodwave **GO**, own‑lane, clean scope; or
2. **Parked / stashed** — see §4; or
3. **Moved** — to a separate worktree / clone (§5); or
4. **Explicitly discarded** — only on Bloodwave's explicit instruction.

Never leave another lane's uncommitted work dirty while you switch context.

---

## 4. Parking protocol (preserve + clear)

Safely park unfinished lane work and return the worktree to clean:

```powershell
cd C:\Users\jared\Projects\lifepunch

git status -sb
git diff --name-status

New-Item -ItemType Directory -Force C:\Users\jared\Projects\lifepunch-parking | Out-Null

git diff > C:\Users\jared\Projects\lifepunch-parking\<lane-name>-<YYYY-MM-DD-HHMM>.patch

git stash push -u -m "PARK: <lane-name> before <next-lane>"

git status -sb
git stash list
```

- The **patch backup lives outside the repo** (`C:\Users\jared\Projects\lifepunch-parking\`) so it survives
  even if the stash is later dropped.
- **Verify clean** after the stash — `git status -sb` should show only the branch line.
- Restore later with `git stash pop` (or `git apply` the patch) **in the lane that owns it**.

---

## 5. Parallel writable lanes → isolate

Two writable lanes must **not** share one working tree. Give each its own worktree or clone:

```powershell
git worktree add C:\Users\jared\Projects\lifepunch-<lane> <branch>
```

Read‑only agents may share a worktree **only** if they modify nothing.

---

## 6. Before official DXRP (upstream) work

Private LIFEPUNCH and official DXRP are **different repos** — never cross them (bible:
`DXRP_CONTRIBUTOR_LANE.md`):

1. The private `C:\Users\jared\Projects\lifepunch` worktree must be **clean** (parked or committed) first.
2. Official DXRP work happens **only** in `C:\Users\jared\Projects\dxrp-public` (from `upstream/develop`).

---

## 7. Commit / push discipline

- **No commit or push without Bloodwave GO.** Propose scope (files + one‑line summary); wait for an explicit yes.
- **No AI / agent trailers** in commit messages (`Co-authored-by: Cursor`, Claude, Copilot, `Generated-by`,
  `Assisted-by`, any agent attribution). Author is `mragerlp <mragerlp@gmail.com>` only — see
  `.cursor/rules/lifepunch-commit-hygiene.mdc`.

---

## Quick reference

| Situation | Do |
|---|---|
| Starting / switching lanes | Preflight §1 (`git status -sb` + `git diff --name-status`) |
| Tree dirty, not your lane | STOP — resolve ownership §3; never restore / reset / sync §2 |
| Unfinished lane work | Park §4 (patch backup + stash + verify clean) |
| Two writable lanes | Separate worktree / clone §5 |
| Switching to upstream DXRP | Private repo clean first; work in `dxrp-public` §6 |
| Ready to commit | Bloodwave GO · `mragerlp` author · no AI trailer §7 |
