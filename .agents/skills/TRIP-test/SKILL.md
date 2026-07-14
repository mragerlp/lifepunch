---
name: TRIP-test
description: Write/run tests following project standards (deep test authoring)
disable-model-invocation: true
argument-hint: "component or feature to test"
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

# Testing Mode

You are now in **testing mode** for **LIFEPUNCH**.

This skill is the **deep test-authoring reference**: the `TRIP-2-implement` testing gate points here for heavy authoring work and full guidance. Invoke it standalone for test backfill or coverage work outside an implementation session.

## Prerequisites - Read First

Before testing, you MUST read:

1. @docs/ARCHI.md - Understand system architecture
2. @docs/4-unit-tests/TESTING.md - Testing guidelines

## Your Task

Test: $ARGUMENTS

---

## Testing Guidelines

### Scope

- Only run tests for relevant files that changed (not the whole project)
- Focus on the new feature/fix/refactor

### Commands

```bash
# [ADAPT_TO_PROJECT: Replace with actual test commands during Init]

# Run all tests
[TEST_COMMAND_ALL]

# Run specific test
[TEST_COMMAND_SPECIFIC]

# With coverage
[TEST_COMMAND_COVERAGE]
```

### Test Structure

[ADAPT_TO_PROJECT: Describe where tests are located and naming conventions during Init]

### Testing Priorities

<!-- [ADAPT_TO_PROJECT: Replace with project-specific testing priorities during Init] -->

**Unit Tests**:

- Core logic functions
- Utility functions
- Individual modules/components

**Integration Tests**:

- Module interactions
- External service integration
- End-to-end flows

**What to Test**:

- Happy path scenarios
- Error states and error handling
- Edge cases (null, empty, boundary values)
- Invalid inputs

---

## Hard-to-Test Code

Seam ladder, cheapest first: **exported pure helper → injectable client/adapter → module mock → integration/emulator test**. Take the first rung that works; refactor for a seam only if the refactor is smaller than the feature you're shipping  -  otherwise it's coverage debt. Before refactoring legacy code, pin it with characterization tests (assert current behavior as-is, then refactor safely).

Uncovered risky paths: one line each in `docs/4-unit-tests/COVERAGE-DEBT.md` (`path | why hard | escape plan`). Delete a ledger line in the same change that gives its path meaningful coverage.

---

## Post-Testing Summary

After completing tests, create a summary file:

**File**: `docs/4-unit-tests/wa_vx.y.z_test.md`
(a = project week, x.y.z = version)

**Content**:

```markdown
# Test Summary - Week a, V. x.y.z

## What Was Tested

[List of tested components/functions]

## Test Results

- Total tests: X
- Passed: X
- Failed: X
- Coverage: X%

## Key Findings

[Any issues discovered, edge cases found, etc.]

## Notes

[Additional context or recommendations]
```
