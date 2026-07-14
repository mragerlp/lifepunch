---
name: TRIP-1-plan
description: Plan a new feature following project standards
argument-hint: "describe the feature you want to build"
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

# Planning Mode

You are now in **planning mode** for **LIFEPUNCH**.

## Prerequisites - Read First

Before creating any plan, you MUST read ALL THE LINES of:

1. @ARCHI.md - Understand current system architecture

## Your Task

Plan the following feature: $ARGUMENTS

---

## Step 1: Discovery & Clarification (Interactive)

**Do NOT start writing a plan immediately.** First, engage in a discovery conversation to fully understand the user's intent.

### 1.1 Initial Understanding

After reading the feature request, summarize your understanding in 2-3 sentences, then **use the `AskUserQuestion` tool** to present clarifying questions with structured options.

Frame questions around:

- **Scope**: What's included vs excluded?
- **Behavior**: How should it work from the user's perspective?
- **Constraints**: Any technical limitations, deadlines, or dependencies?
- **Priority**: What's most important if trade-offs are needed?

For each question, provide 2-4 concrete options based on your analysis of the codebase and the feature request. Always let the user provide custom input via the built-in "Other" option.

After the user answers, proceed **directly to writing the plan** (Step 2)  -  no approach-confirmation question. Ask a follow-up round with `AskUserQuestion` only if a blocking ambiguity remains (**maximum 3 rounds total**; if still unclear, summarize what you know and proceed with noted assumptions).

---

## Step 2: Plan Document Creation

Once understanding is confirmed, create the plan document.

### File Naming

Depending on the feature (major, minor, patch), propose a new version using SemVer (x.y.z) and create:
`docs/1-plans/F_[version]_[feature-name].plan.md`

### Required Sections

```markdown
# [Feature Name] Implementation Plan

## Overview

[2-4 sentences describing the feature and its purpose]

## Problem Statement (if applicable)

[Current limitations/issues this feature addresses]

## Solution Architecture

[High-level design approach]

## Implementation Details

### 1. [Component/Module/File Name]

**File**: `path/to/file`

[Detailed description of changes needed]

**Current state** (if modifying existing):
[Describe what currently exists]

**Modifications**:

- Specific change 1 (around line X)
- Specific change 2 (around line Y)

### 2. [Next Component/Module/File]

[Continue with same pattern]

## Technical Considerations

- **Pattern Usage**: Follow ARCHI.md + the matching `lifepunch-*` skill (economy / config / razor-ui / editor-gate / grounding).
- **CVL authority**: Bloodwave GO for merge/push/tag; DRIVE is board-named; skills are capability not authority.
- **Editor sync**: Repo edits are not playable until `Sync-LifePunchAddonsToDxrp.ps1` (`-WhatIf` first) when the slice needs runtime proof.
- **Economy / donor rails**: Law A/B, Donor Law exceptions only when signed; never multiply portal `$BTC` redeem without an explicit ruling.
- **Attribution**: author `mragerlp <mragerlp@gmail.com>` only; zero AI trailers on any git surface.
- **Sensor Law**: every behavioral claim needs a sensor (compile log postdates write, test pass count, screenshot, etc.).
- **Edge Cases**: host vs caller identity, TOCTOU on debit/restore, play-mode vs edit-mode MCP mutators.

## Files to Modify/Create

[Comprehensive numbered list with purposes]

1. `path/to/file1` (modify) - Purpose description
2. `path/to/file2` (new) - Purpose description

## Type Definitions (if applicable)

[New types, interfaces, structs, or modifications to existing ones]

## Performance & Cost Impact (if applicable)

[Expected performance implications]

## Backward Compatibility (if applicable)

[Migration strategy if needed]

## Test Impact

[2-5 bullets: which existing tests the change affects, what new logic will need tests, whether an integration/E2E check applies. No test code  -  the TRIP-2 testing gate consumes this section.]

## To-dos

### Phase 1: [Phase Name] (if multiple phases are needed) or simply skip title if only one phase is needed

- [ ] Task description
- [ ] Another task

### Phase 2: [Phase Name] (if applicable)

- [ ] Task description
- [ ] Another task

**Note**: For simple plans, a single phase is sufficient. Split into multiple phases only for complex features requiring sequential implementation.

**Note**: Do NOT write test code during planning  -  the Test Impact section above only names what the TRIP-2 testing gate will run and author.
```

## Quality Standards

- **Zero Ambiguity**: Every step must be clear and actionable
- **File-Level Specificity**: List exact files and functions to modify
- **Architecture Alignment**: Must conform to existing patterns in ARCHI.md
- **Risk Assessment**: Highlight potential failure points

---

## Step 3: Codex Second-Opinion Review

Before the user sees the plan, run the Codex plan review loop.

### Confirm

`AskUserQuestion`: "I'll run Codex as a second-opinion reviewer and iterate until clean. Proceed?"
Options: "Yes, run Codex review" (recommended) / "Skip Codex, go to user review" / "Cap iterations at N"

Skip for trivial plans (single-file, low-risk). Run for non-trivial (new module, schema/algorithm change).

### Loop

1. **Start**: `bash .agents/skills/codex-plan-review/scripts/start.sh --prompt-file .agents/skills/codex-plan-review/prompts/start.tpl <plan-path>`
2. **Parse trailing tag**: `APPROVED` -> Step 4. `NEEDS_REWORK` -> surface to user. `REQUEST_CHANGES` -> continue.
3. **Address findings critically**  -  quote each P1/P2, push back on incorrect ones, fix legitimate ones by editing the plan in place.
4. **Write implementer notes** (1-3 sentences): which findings you fixed, which you pushed back on and why, any user decisions that override existing docs or environment limitations that can't be resolved in the plan.
5. **Resume** with notes:
   ```bash
   bash .agents/skills/codex-plan-review/scripts/resume.sh \
       --prompt-file .agents/skills/codex-plan-review/prompts/resume.tpl \
       --notes "Fixed X. Pushed back on Y because Z. User decided W." \
       <plan-path>
   ```
   -> back to step 2.
6. **Cap at 5 rounds** (or user-specified). Surface remaining findings and let user decide.

Surface Codex reviews verbatim. Keep edits scoped to findings. Reset thread (`reset.sh <plan-path>`) only if context is genuinely confused.

---

## Step 4: User Review & Validation

After Codex review converges (or is skipped), present a summary to the user including:

- **Feature**: [name]
- **Approach**: [1-2 sentences]
- **Files affected**: [count] files ([list key ones])
- **Estimated complexity**: [simple/moderate/complex]
- **Codex status**: [APPROVED / skipped / capped at N rounds with open findings]

Then **use the `AskUserQuestion` tool** to collect feedback:

- **Question**: "Please review the plan at `docs/1-plans/F_x.y.z_feature-name.plan.md`. How would you like to proceed?"
- **Options**: "Approved" (ready for implementation), "Request changes" (I have modifications), "Needs rework" (significant issues to address)

Handle feedback:

- **If "Request changes"**: Update the plan and re-present. Run another Codex pass if changes are substantive.
- **If "Needs rework"**: Discuss issues, rework the plan, and re-present.
- **If "Other" (custom input)**: Handle accordingly.
- **If "Approved"**: **Use the `AskUserQuestion` tool** to ask:
  - **Question**: "Plan approved. Would you like to start implementation now?"
  - **Options**: "Yes, implement now" (proceed with `TRIP-2-implement` using this plan), "Not yet" (I'll implement later)

---

## IMPORTANT: No Code Implementation

**DO NOT write code snippets or implement anything during planning.**

This is a high-level planning phase only. Your plan should describe:

- WHAT needs to be done (features, changes, structures)
- WHERE changes will happen (files, modules, functions)
- WHY certain approaches are chosen (trade-offs, rationale)

But NOT:

- Actual code implementations
- Detailed algorithm code

Keep it architectural and descriptive. Code comes in the `TRIP-2-implement` phase.

## For Bitcoin / cyber entity slices

- Hub → Terminal → GPU Rack order unless a Bloodwave ruling opens another lane.
- Prefer reuse (Law 1) over new systems; park unrelated ideas in BACKLOG.

## For Razor / SCSS UI

- Class root on `<root class="...">`; run `Validate-SboxRazorScss.ps1` before playtest.
- `BuildHash` must include every private UI flag that changes markup.

## For economy / persistence

- Read `lifepunch-economy` before editing payout, purchase, ledger, or Audit paths.
- Portal token absence = outbound Audit/rank feed **unverified**, not assumed green.

## For editor / MCP work

- One DRIVE holder; Launch Report before editor-gated instruments.
- Sync repo → DXRP game tree before claiming hotload proof.
