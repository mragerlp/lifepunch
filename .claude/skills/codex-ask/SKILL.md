---
name: codex-ask
description: Ask Codex for a grounded second opinion on any question - advisory, not gating
argument-hint: "<topic-label> <question> | reset <topic-label> | show <topic-label>"
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

# Codex Ask

Free-form second opinion from Codex CLI on **any matter**  -  architecture decisions, debugging hypotheses, research conclusions, trade-off calls  -  not just plans and diffs. Codex answers from inside the repository (read-only sandbox), so its opinion is grounded in the actual code, not in whatever excerpt happened to be quoted.

**Advisory, not authoritative.** Unlike `codex-plan-review` / `codex-code-review`, there are no verdict tags and nothing is gated on the answer: treat the response as one input to your judgment, exactly like a colleague's opinion. Agreement is weak evidence; *disagreement* is a strong signal that something deserves the user's attention.

State persisted per topic label under `.claude/skills/codex-ask/state/`  -  follow-ups resume the same thread, enabling multi-round discussion. The shared scripts from `codex-plan-review` do all the work; always export first:

```bash
export STATE_DIR=".claude/skills/codex-ask/state"
```

## Arguments

- `<topic-label>`  -  short kebab-case label for the discussion (becomes the state key), e.g. `orchestrator-choice`, `flaky-auth-test`. Auto: start if no thread, resume if one exists.
- `<question>`  -  the actual question, passed as trailing text. Include your own draft position when you have one ("Here is my recommendation: … Red-team it").
- `reset <topic-label>` / `show <topic-label>`  -  drop state / display last answer.

## Execution

1. **Start** a discussion:
   ```bash
   bash .claude/skills/codex-plan-review/scripts/start.sh \
       --prompt-file .claude/skills/codex-ask/prompts/ask.tpl \
       <topic-label> "<question  -  include your draft position and ask for disagreement>"
   ```

2. **Follow up** in the same thread (counterpoints, new evidence):
   ```bash
   bash .claude/skills/codex-plan-review/scripts/resume.sh \
       --prompt-file .claude/skills/codex-ask/prompts/followup.tpl \
       <topic-label> "<follow-up or counterpoint>"
   ```

3. **Reset**: `bash .claude/skills/codex-plan-review/scripts/reset.sh <topic-label>`  -  **Show**: `show.sh <topic-label>`

## When to use

- Second opinion on an architecture/design decision **before it hardens** (e.g., at the end of a research session, before writing the plan).
- Root-cause help when genuinely stuck on a bug  -  fresh eyes, different blind spots.
- "Red-team this conclusion" on a memo or recommendation you are about to present.

## When NOT to use

- Questions that need the **user's** preference or judgment  -  ask the user, not Codex.
- Trivial lookups or anything settled by reading the code yourself  -  every ask costs a Codex run.
- As a gate: never block or approve work based on the answer; that is what the review skills with verdict tags are for.

## Notes

- Read-only sandbox  -  Codex can read the repo but change nothing.
- Model/effort come from `codex-plan-review/scripts/_common.sh` (non-implement flows get the review-class model by default); override per run via `CODEX_MODEL` / `CODEX_EFFORT`.
- Surface Codex's answer to the user verbatim when it disagrees with your position  -  the disagreement itself is the valuable output.
