# DEFECT NOTE — COMMIT ON `develop`, AND THE SPLIT SLICE IT HID

**Date:** 2026-07-13 · **Seat:** Red (Claude Code Opus) · **Class:** RECORD (write-once)
**Ruled by:** Bloodwave — REPAIR RULING (branch surgery) + SPLIT-SLICE RULING (unify, delete, ratify)
**Ratifies:** the BRANCH ASSERTION AT THE COMMIT line now carried by `RED_BOOT.md` and `CODEX_BOOT.md`.

## What happened

During the canon/consult/superpowers slice, commit `1a0781e`
(*docs(cvl): Editor Access Law v2, Superpowers doctrine, boot addenda, ledger reconcile*)
was authored **directly onto `develop`**, a protected lane branch that takes changes by PR only.
It was caught at the commit gate, before any push. `origin/develop` never contained it —
verified after a fresh `git fetch` with `git branch -r --contains 1a0781e`, which returned empty.

The repair created the slice branch at the stranded HEAD, moved the commit onto it, and reset
local `develop` to `origin/develop` (`c1a8d8a`). No force-push was needed or used; nothing was lost.

## Root cause

The session was standing on `develop` because of an **incomplete branch-return**, not a missed
branch step. The reflog is the sensor:

```
15:58:34  checkout develop → red/cvl-canon-consult-superpowers-2026-07-13
15:58:54  commit c18f6f4   (on the slice branch — correct)
15:59:03  checkout back to develop          ← the defect moment
15:59:21  commit 1a0781e   ON DEVELOP       ← the stranding
```

The work was correctly started on a slice branch and correctly committed there. The session then
checked *back out* to `develop` — a legitimate move on its own, to inspect base state — and **never
re-entered a branch before the next commit.** Twenty-eight seconds later, `1a0781e` went in on
`develop`. There was no boot-state failure.

The defect is that the seat treated *"am I on a branch?"* as a fact **established once at task
start** rather than a **precondition re-asserted immediately before every commit.** A checkout to
`develop` mid-slice silently disarms the task-time check, and nothing re-arms it.

## The rule this ratifies

> Before **every** commit, assert `git branch --show-current` is not `develop` / `main`.
> A mid-slice checkout silently disarms task-time branch checks, so the assertion lives
> **at the commit, not at the task.**

This is the only check that survives a mid-slice checkout. It now sits in `RED_BOOT.md` §3 and
`CODEX_BOOT.md` §3 — **both** implementer seats, because under `EDITOR_ACCESS_LAW_V2` either may
hold DRIVE and a rule only Red obeys is a rule that breaks on the next swap.

A **mechanical pre-commit hook is BANKED as follow-up**, not built here: hooks are Class C standing
rules under `CONSOLE_PLUGINS_DOCTRINE` and need their own Bloodwave GO.

## The second defect, which the first one hid

The repair's own sensor pass surfaced a fault the repair ruling could not have known about: the
slice already had a branch. `red/cvl-canon-consult-superpowers-2026-07-13` carried `c18f6f4`
(`CORNERMAN_CONSULT_DOCTRINE.md` + `ask-cornerman.ps1`). Creating a *second*, similarly-named branch
left the slice **split across two branches, neither an ancestor of the other.**

That mattered because `1a0781e` lands a `CLAUDE.md` citing `CORNERMAN_CONSULT_DOCTRINE.md` as canon
in two places, and pointing at `ask-cornerman.ps1` by path. Both files lived **only** on the other
branch. A PR from the named branch alone would have merged a grounding file whose canon list points
at two files that do not exist on `develop` — **broken grounding for every seat that boots after it.**

Ruled: UNIFY. `c18f6f4` was cherry-picked onto the named branch (local-only, unpushed — no rewrite
hazard), giving one branch, three commits, one PR, and no intermediate state that ever ships. Blob
identity was asserted before the stale branch was deleted: both files hash-match their originals
(`68d75dcc…`, `b290d1bb…`). Every repo path cited by `CLAUDE.md` was then resolved mechanically —
22 cited, 0 missing.

## Lessons for the sensors

1. **`git status` and `git log origin/develop..develop` are insufficient sensors for branch surgery.**
   Both looked exactly as predicted; the sibling branch is invisible to them because it is neither
   checked out nor an ancestor of anything in play. **The reflog is the sensor that sees it.**
2. **A stale remote-tracking ref makes "local-only" a false negative.** `origin/develop` is a cache.
   Fetch first, then ask reachability directly (`git branch -r --contains <sha>`).
3. **Dangling canon is a merge-blocking defect, not a cosmetic one.** When a commit adds a pointer to
   a file, the file and the pointer must ride the same PR. Resolve every cited path mechanically
   before opening it — *write-once canon that the grounding order cannot read is canon nobody reads.*
4. **Symmetric canon needs a symmetric sensor.** Both defects in this arc share one shape: a change
   applied to the file in hand and not to its twin. `1a0781e` gave `CODEX_BOOT.md` full v2 grant
   language while leaving `RED_BOOT.md` asserting Red was the "sole canonical-tree implementer and
   default editor DRIVE authority" — a line `EDITOR_ACCESS_LAW_V2` explicitly kills. Ask, always:
   *which other file asserts the thing I just changed?*
