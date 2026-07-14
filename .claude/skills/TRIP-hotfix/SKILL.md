---
name: TRIP-hotfix
description: Urgent fix bypassing full TRIP workflow
disable-model-invocation: true
argument-hint: "what is broken in production?"
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

# Hotfix Mode

You are now in **hotfix mode** - a streamlined workflow for urgent production fixes.

> **Warning**: Only use this for genuine emergencies. For regular bugs, use the full TRIP workflow (`TRIP-1-plan` → `TRIP-2-implement`).

## Your Task

Hotfix: $ARGUMENTS

---

## Step 1: Assess Urgency

Before proceeding, confirm this is a genuine hotfix:

**Use the `AskUserQuestion` tool** to confirm urgency:

- **Question**: "Is this a production-critical issue that cannot wait for the normal TRIP workflow?"
- **Options**: "Yes  -  critical issue" (security vulnerability, data corruption, service outage, or critical user-facing bug), "No  -  regular bug" (redirect to `TRIP-1-plan` for proper workflow)

**If "No"**: Redirect to `TRIP-1-plan` for proper workflow.

**If "Yes"**: Proceed with hotfix.

---

## Step 2: Create Hotfix Branch

```bash
git checkout main && git pull
git checkout -b hotfix/[short-description]
```

---

## Step 3: Minimal Investigation

First, you MUST read ALL THE LINES of @ARCHI.md then explore the codebase and read the files relevant to the issue.

Quickly identify:

1. **Root cause** (1-2 sentences)
2. **Affected files** (list)
3. **Fix approach** (brief)

No formal plan document needed.

---

## Step 4: Implement Fix

- Focus only on the fix - no refactoring, no "while I'm here" improvements
- Minimal changes to resolve the issue
- Follow existing patterns from the codebase

---

## Step 5: Quick Verification

- Manually test the fix
- Run relevant tests only: `[test command] [affected files]`
- Confirm the issue is resolved

---

## Step 6: Version & Changelog

### Version Bump

Increment **patch** version only (x.y.Z+1) in version file.

### Minimal Changelog Entry

Add to top of `docs/2-changelog/changelog_table.md`:

```markdown
| `x.y.z` | W | hotfix: [brief description] |
```

Add to Changelog Summary:

```markdown
- **vX.Y.Z (Hotfix - Week W, DD-MM-YYYY)**:
  - **Issue**: [What was broken]
  - **Fix**: [What was done]
  - **Root Cause**: [Brief explanation]
```

---

## Step 7: Commit

```bash
git add -A && git commit -m "hotfix: [brief description]"
```

---

## Step 8: Merge & Tag

```bash
git checkout main
git merge hotfix/[short-description]
git tag vx.y.z
git push && git push --tags
git branch -d hotfix/[short-description]
```

---

## Step 9: Post-Hotfix

After the immediate crisis is resolved:

1. **Document**: Create a brief incident report in `docs/6-memo/` if significant
2. **Follow-up**: If deeper fixes are needed, create a proper TRIP plan
3. **Retrospective**: Consider what could prevent similar issues

---

## What This Workflow Skips

Compared to full TRIP:

- No interactive discovery questions
- No formal plan document
- No full code review checklist
- No tutorial generation
- No ARCHI.md update (unless architecture changed)
- No README update (unless relevant)

These are acceptable trade-offs for genuine emergencies only.
