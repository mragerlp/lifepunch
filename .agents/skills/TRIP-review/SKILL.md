---
name: TRIP-review
description: Review code following project standards (manual fallback/audit path)
disable-model-invocation: true
argument-hint: "version or feature to review"
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

# Review Mode

You are now in **code review mode** for **LIFEPUNCH**.

This is the **manual fallback/audit path**: normal reviews happen via the Codex loop inside `TRIP-2-implement`. Use this skill to audit a past version, review unplanned work, or replace the Codex loop when it is unavailable.

Review: $ARGUMENTS

## Prerequisites

Read before reviewing:
1. @ARCHI.md  -  verify architectural compliance
2. Related plan in `docs/1-plans/`
3. Related changelog in `docs/2-changelog/`
4. @.agents/skills/TRIP-review/checklist.md  -  **single source of truth** for review criteria, severity classification, and approval gate

---

## Apply the Checklist

Walk every section of `checklist.md` against the change. Tick passing items. Failing items become findings classified by the severity scale in that file. Approval requires the gate at the bottom of `checklist.md`.

Do not copy the checklist into output  -  link to it.

---

## Create Review File

Save to `docs/3-code-review/CR_wa_vx.y.z.md` (a=project week, x.y.z=version).

Render the skeleton from `@.agents/skills/TRIP-review/cr-template.md`:
1. Copy the markdown block from that file.
2. Replace every `<angle-bracket placeholder>` with concrete content.
3. Tick `[x]` for passing checklist items; leave unchecked with a one-line caveat otherwise.

Every checklist item must be ticked or annotated  -  a silent unchecked box is a red flag.
