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

1. @ARCHI.md - Understand system architecture
2. `CLAUDE.md` Sensor Law + the lane's `lifepunch-*` skill (no separate `docs/4-unit-tests/TESTING.md` in this repo)

## Your Task

Test: $ARGUMENTS

---

## Testing Guidelines

### Scope

- Only run tests for relevant files that changed (not the whole project)
- Focus on the new feature/fix/refactor

### Commands

```powershell
# Focused harness named by the plan / round report (preferred)
# Example pattern: a slice-local script under lifepunch\scripts or an in-editor fixture ConCmd.

# Layout / Razor floors (not a substitute for behavioral tests)
powershell -NoProfile -File lifepunchaddons\scripts\Validate-SboxRazorScss.ps1

# Compile sensor (code changes): editor MCP get_compile_errors / code_get_compile_errors
```

### Test Structure

- **In-editor / fixture proof**: ConCmds and play fixtures under `lifepunchaddons/Code/...` (e.g. bitcoinmining donor/devspawn helpers) — preferred for s&box behavior.
- **Scripted floors**: `lifepunchaddons/scripts/Validate-*.ps1`, `validate-layout.ps1` (scoped).
- **Round-report sensors**: pass counts (e.g. 24/24) and P0 checklists filed in `comms/` or `lifepunch/docs/handoff/` are valid sensors when they postdate the change.
- Naming: prefer `Test-*.ps1` / `*Proof*.ps1` for new offline harnesses under `lifepunch/scripts/`.

### Testing Priorities

**Unit / pure-helper tests**:

- Economy math, rank resolution, pure policy helpers (no engine required when extractable)

**Integration / play proof**:

- Flatgrass / `lp_map_flatgrass` for Hub/Terminal/Rack gameplay and UI
- Two-account fixtures when rank/ownership is load-bearing

**Sensor floors (always for code)**:

- Compile clean + focused harness pass count before claiming DONE
- No silent "looks fine from code" visual claims without bridge/screenshot- End-to-end flows

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
