---
name: TRIP-3-release
description: Release a completed implementation - version, code review promotion, changelogs, docs, commit, tag, ff-merge, push
argument-hint: "plan file or feature label"
---

> **CVL SUBORDINATION BANNER (LIFEPUNCH adoption, 2026-07-14).** This skill is ADOPTED
> UNDER CVL LAW per `lifepunch/docs/cvl/TRIP_ADOPTION_2026-07-14.md`. Precedence is fixed:
> CVL law > Bloodwave two-key list > seat charter > this skill. Overrides, non-negotiable:
> (1) **Merge, push, tag, ship, and destructive git are Bloodwave's word EXCLUSIVELY**  - 
> any step below that merges/pushes/tags becomes "propose and HOLD for Bloodwave GO".
> (2) **Author `mragerlp <mragerlp@gmail.com>` only; ZERO AI attribution** on any git surface.
> (3) **Sensor Law applies**  -  every behavioral claim carries its sensor; testing gates in
> this skill are floors, not substitutes. (4) **Transport Law applies**  -  seats do not
> message each other directly; Bloodwave carries every arrow. (5) "Codex" below means the
> board-named implementer lane per `EDITOR_ACCESS_LAW_V2`; the plan seat is Fable.
> (6) `ARCHI.md` is subordinate to `CLAUDE.md`; on conflict, CLAUDE.md wins and ARCHI.md
> is the defect. Skills are capability, not authority.

# Release Mode

You are now in **release mode** for **LIFEPUNCH**.

Release: $ARGUMENTS

This skill runs after `TRIP-2-implement` has converged (implementation done, testing gate green, Codex code review `APPROVED` or explicitly skipped). It is normally chained from TRIP-2 in the same session, but can be invoked standalone in a fresh session.

---

## Prerequisites

- Implementation complete and user-confirmed.
- Testing gate green: affected unit tests pass.
- Codex code review converged (`APPROVED`), or explicitly skipped by the user.
- Lint and type-check/build green.

### Standalone verification (fresh session, not chained from TRIP-2)

If this skill was NOT chained from a TRIP-2 session in the current conversation, verify before any release step:

```powershell
powershell -NoProfile -File lifepunchaddons\scripts\Validate-SboxRazorScss.ps1
# validate-layout.ps1 only when package layout touched (scope failures to this slice)
# TYPECHECK: editor MCP get_compile_errors / code_get_compile_errors = 0 (or n/a if docs-only)
# TEST: focused harness from the plan's Test Impact section
```

All must be green. Also verify the Codex state file exists for the given plan path/label (see Step 3 below); if absent, treat as the skipped-Codex fallback (manual CR) and say so explicitly in the CR.

Any failure blocks the release  -  fix or return to `TRIP-2-implement` first.

---

## Step 1: Get Current Date/Week

Run this command to get date and project week:

```powershell
# Project week anchor = LIFEPUNCH Class 41 first-use date (2026-04-26)
$anchor = Get-Date '2026-04-26'
$week = [int][math]::Floor(((Get-Date) - $anchor).TotalDays / 7) + 1
Get-Date -Format 'dd-MM-yyyy HH:mm'; "Project week: $week"
```

Use the project week in all subsequent steps.

## Step 2: Version Update

- If not already done in the plan phase, propose new SemVer version (x.y.z)
- LIFEPUNCH has **no single monorepo version file**. Skip a global bump unless the touched package already carries its own version field; record the version in the changelog / CR filename only.
- Do not invent a root `package.json` version just for TRIP.

## Step 3: Promote Code Review

Now that week (`a`) and version (`x.y.z`) are known:

1. Compute state file path:
   ```bash
   STATE_KEY="$(realpath <plan-path> | sed 's|^/||; s|/|__|g')"
   STATE_FILE=".agents/skills/codex-code-review/state/${STATE_KEY}.review.txt"
   ```

2. Content source:
   - **Multi-round loop**: state file has synthesized review + `PROMOTION_READY`. Strip sentinel.
   - **Turn 1 convergence**: state file has full review already.
   - **Skipped Codex**: write CR from `.agents/skills/TRIP-review/cr-template.md` with body "Code review skipped  -  trivial change." Verdict: `APPROVED with observations`.

3. Replace `<x.y.z>` with actual version. Fill any remaining `<...>` placeholders.

4. Save to `docs/3-code-review/CR_wa_vx.y.z.md` (create the folder if missing; scratch-ok until promoted under Bloodwave GO).

5. Verify: no `<...>` placeholders, no `PROMOTION_READY`, version matches the changelog entry.

## Step 4: Commit Message

Propose a one-line commit message.

## Step 5: Changelog File

Create `docs/2-changelog/wa_vx.y.z.md` (a=project week, x.y.z=version):

```markdown
# Changelog - Week a, DD-MM-YYYY, V. x.y.z

**Release Date**: Week a, DD-MM-YYYY at HH:MM
**Version**: x.y.z (previously x0.y0.z0)
**Object**: the commit message
**Code review**: `docs/3-code-review/CR_wa_vx.y.z.md` (Codex loop, N rounds -> verdict)

## Changes

[Describe what changed]
```

## Step 6: Changelog Table

Add entry on top of `docs/2-changelog/changelog_table.md`:

```markdown
| `x.y.z` | a | the commit message |
```

Also add a summary entry in the Changelog Summary section.

## Step 7: Architecture Update

1. Read fully `CLAUDE.md` (canon) + `ARCHI.md` subordination header (no separate ARCHI-rules.md in this repo)
2. Update @ARCHI.md following the rules
3. Run `bash .agents/skills/TRIP-compact/count-tokens.sh ARCHI.md` to check token count

**Warning: If ARCHI.md exceeds ~20,000 tokens**, warn the user:

> "ARCHI.md is at ~X tokens. Consider running `TRIP-compact` to reduce it before committing."

<!-- [TUTORIAL_STEP]
### Step 8: Tutorial

Create `docs/5-tuto/tuto_x.y.z.md` explaining the core principle.

**User context for tutorials**:

- Level: [USER_LEVEL]
- Learning focus: [USER_LEARNING_FOCUS]
- Style: [USER_PREFERRED_STYLE]
-->

## Step 8: README Update

Update `README.md` with the new version number.
Also update relevant sections whenever needed.

---

After completing all documentation steps, **use the `AskUserQuestion` tool** to ask:

- **Question**: "All documentation steps are complete. Ready to commit?"
- **Options**: "Yes, commit now" (proceed with git commit and tag), "Not yet" (review changes first)

**ONLY after user selects "Yes"**, proceed:

## Step 9: Commit

```bash
git add -A && git commit -m "<commit message from Step 4>"
```

**Important**: Only use the commit message. Do NOT add Co-Authored-By or any other trailer.

## Step 10: Tag

```bash
git tag vx.y.z
```

## Step 11: Merge (PR to develop — Bloodwave only)

LIFEPUNCH does **not** ff-merge locally onto a protected branch. Open a PR with base **`develop`** (never commit on `develop`/`main`). **Merge stays Bloodwave's word** (CVL subordination banner). Propose the PR URL and HOLD.

```powershell
# After review+tests: push feature branch, open PR against develop, do not merge.
gh pr create --base develop --head <feature-branch> --title "<title>" --body-file <body.md>
```

## Step 12: Push / tag

Push the **feature branch** when opening the PR. Tags and any push to `main`/`develop` require Bloodwave GO.

**Use the `AskUserQuestion` tool** to ask:

- **Question**: "Release prep for vx.y.z is committed on the feature branch. Open/update the PR against develop (merge HELD)?"
- **Options**: "Yes, open/update PR" / "Not yet"

**If "Yes"**: push `-u` if needed and ensure the PR exists. Do **not** merge, force-push protected branches, or push tags without Bloodwave GO.